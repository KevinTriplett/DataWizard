#!/usr/bin/env python3
"""stamp_editlog.py -- frontmatter array-append primitive.

Append one item to a named YAML frontmatter array (default `edit_log`) without
loading the array into a model context: a byte-faithful textual insert at the
*tail of the array*, O(1) in the array's length. Sibling of stamp_blocks.py;
shares its byte-faithful read/write helpers (keep the two in sync).

Design: [[Frontmatter Array-Append Primitive - Design]] (RW-S70, Fable-reviewed
DW-S303). This script is the executor twin of the append rule now in
session-closer v4.6.4 Step 3.8.

Key behaviours (from the S303 review):
  F2  Insert at the array tail = the line before the next top-level key or the
      closing `---`, after trailing blanks/comments. NEVER the last `- ` line
      (long entries wrap onto 4-space continuation lines; ~1/3 of files do).
  F3  Flow style (`key: [a, b]`) is normalized to block style in the same
      byte-faithful write. Empty forms (`key: []`, bare `key:`) get the first
      item. A missing key is refused unless --create-key.
  F4  Never touches `updated:` unless --updated is passed (caller-owned; the
      updated-field reconciliation owns that scalar).
  F5  Key-agnostic (--key). Dedupe-as-no-op (exact entry already present ->
      exit 0, no write). Entries needing it are double-quoted (`: `, `#`,
      leading specials, surrounding space).
  F6  No lockfile. Read-insert-atomic-rename in one process shrinks the race
      window; --verify confirms presence AND that the item count grew by one
      (or held, on a dedupe no-op).

Modes:
  --file F --entry S       append S to F's array (--key, default edit_log)
  --manifest FILE          JSON list of {"file","entry","key"?,"updated"?}
  --root DIR               base dir for relative paths (default: cwd)
  --updated YYYY-MM-DD|today   also set the `updated:` scalar (F4; off by default)
  --create-key             create the array key if absent (else refuse)
  --dry-run                report only; write nothing
  --verify                 re-read and confirm the entry landed / count grew

Row outcomes: appended | normalized+appended | created+appended |
duplicate-noop | refused:<why>. Exit non-zero on any refusal or verify failure.

Stdlib only; targets Python 3.8+.
"""
import argparse
import json
import os
import re
import sys
import datetime

EOL_RE = re.compile(r"(\r\n|\r|\n)\Z")
# A top-level frontmatter key: no leading whitespace, `name:` shape.
TOPKEY_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_-]*:")
# A block array item line: two-space indent + "- ".
ITEM_RE = re.compile(r"^\s+-\s")
FENCE_CLOSE_RE = re.compile(r"^---\s*\Z")


# ---- byte-faithful helpers (shared with stamp_blocks.py; keep in sync) -------

def splitkeep(text):
    parts = re.split(r"(\r\n|\r|\n)", text)
    lines = []
    for i in range(0, len(parts) - 1, 2):
        lines.append(parts[i] + parts[i + 1])
    if parts[-1] != "":
        lines.append(parts[-1])
    return lines


def split_eol(line):
    m = EOL_RE.search(line)
    if m:
        return line[: m.start()], m.group(1)
    return line, ""


def read_text(path):
    with open(path, "r", encoding="utf-8", newline="") as fh:
        return fh.read()


def write_text(path, text):
    tmp = path + ".stamp.tmp"
    with open(tmp, "w", encoding="utf-8", newline="") as fh:
        fh.write(text)
    os.replace(tmp, path)


def read_lines(path):
    text = read_text(path)
    bom = "﻿" if text.startswith("﻿") else ""
    if bom:
        text = text[len(bom):]
    return bom, splitkeep(text)


def dominant_eol(lines):
    for ln in lines:
        _, eol = split_eol(ln)
        if eol:
            return eol
    return "\n"


# ---- frontmatter / array location -------------------------------------------

def frontmatter_bounds(lines):
    """(open_idx, close_idx) of the --- ... --- block, or (None, None)."""
    if not lines:
        return None, None
    if split_eol(lines[0])[0].strip() != "---":
        return None, None
    for i in range(1, len(lines)):
        if split_eol(lines[i])[0].strip() == "---":
            return 0, i
    return None, None


def find_key_line(lines, open_idx, close_idx, key):
    """Index of the top-level `key:` line within frontmatter, or None."""
    pat = re.compile(r"^" + re.escape(key) + r":")
    for i in range(open_idx + 1, close_idx):
        if pat.match(split_eol(lines[i])[0]):
            return i
    return None


def needs_quote(v):
    if v == "" or v != v.strip():
        return True
    if v[0] in "!&*?{}[],#|>@`\"'%-":
        return True
    if ": " in v or v.endswith(":"):
        return True
    if " #" in v:
        return True
    return False


def emit_item(value, eol):
    if needs_quote(value):
        q = value.replace("\\", "\\\\").replace('"', '\\"')
        body = '"' + q + '"'
    else:
        body = value
    return "  - " + body + eol


def unquote(v):
    v = v.strip()
    if len(v) >= 2 and v[0] == '"' and v[-1] == '"':
        return v[1:-1].replace('\\"', '"').replace("\\\\", "\\")
    if len(v) >= 2 and v[0] == "'" and v[-1] == "'":
        return v[1:-1].replace("''", "'")
    return v


def existing_entries(lines, key_idx, close_idx):
    """Reconstruct existing block-array entries as unquoted strings, so dedupe
    and count work through wrapped continuation lines. Returns list of values;
    empty if the array is empty or flow-style (handled separately)."""
    vals = []
    i = key_idx + 1
    cur = None
    while i < close_idx:
        content = split_eol(lines[i])[0]
        if TOPKEY_RE.match(content):
            break
        m = ITEM_RE.match(content)
        if m:
            if cur is not None:
                vals.append(cur)
            cur = content[m.end():]
        elif content.strip() == "":
            pass
        elif cur is not None:
            cur = cur.rstrip() + " " + content.strip()
        i += 1
    if cur is not None:
        vals.append(cur)
    return [unquote(v) for v in vals]


def array_tail_index(lines, key_idx, close_idx):
    """F2: index of the last line belonging to the array (after which we
    insert), = last non-blank line before the next top-level key / close ---."""
    last = key_idx
    i = key_idx + 1
    while i < close_idx:
        content = split_eol(lines[i])[0]
        if TOPKEY_RE.match(content):
            break
        if content.strip() != "":
            last = i
        i += 1
    return last


FLOW_RE = re.compile(r"^(?P<key>[A-Za-z_][\w-]*:)\s*\[(?P<body>.*)\]\s*\Z")


def parse_flow(body):
    """Split an inline YAML flow list body on top-level commas (quote-aware)."""
    items, buf, depth, quote = [], "", 0, None
    for ch in body:
        if quote:
            buf += ch
            if ch == quote:
                quote = None
            continue
        if ch in "\"'":
            quote = ch
            buf += ch
        elif ch in "\{{":
            depth += 1
            buf += ch
        elif ch in "]}":
            depth -= 1
            buf += ch
        elif ch == "," and depth == 0:
            items.append(buf)
            buf = ""
        else:
            buf += ch
    if buf.strip() != "":
        items.append(buf)
    return [unquote(x) for x in items]


class Row(object):
    def __init__(self, d):
        self.file = d["file"]
        self.entry = d["entry"]
        self.key = d.get("key", "edit_log")
        self.updated = d.get("updated")
        self.outcome = None
        self.status = None


def set_updated(lines, open_idx, close_idx, date):
    idx = find_key_line(lines, open_idx, close_idx, "updated")
    if idx is None:
        return False
    content, eol = split_eol(lines[idx])
    lines[idx] = "updated: " + date + eol
    return True


def process_row(row, root, dry_run, create_key):
    path = os.path.join(root, row.file)
    if not os.path.isfile(path):
        row.status, row.outcome = "refused", "refused:no-such-file"
        return
    bom, lines = read_lines(path)
    open_idx, close_idx = frontmatter_bounds(lines)
    if open_idx is None:
        row.status, row.outcome = "refused", "refused:no-frontmatter"
        return
    eol = dominant_eol(lines)
    key_idx = find_key_line(lines, open_idx, close_idx, row.key)

    if key_idx is None:
        if not create_key:
            row.status, row.outcome = "refused", "refused:key-absent (%s)" % row.key
            return
        insert_at = close_idx
        new = [row.key + ":" + eol, emit_item(row.entry, eol)]
        lines[insert_at:insert_at] = new
        status = "created+appended"
    else:
        key_content = split_eol(lines[key_idx])[0]
        flow = FLOW_RE.match(key_content)
        if flow:
            items = parse_flow(flow.group("body"))
            if row.entry in items:
                row.status, row.outcome = "duplicate-noop", "duplicate-noop (flow)"
                return
            block = [flow.group("key") + eol]
            for it in items:
                block.append(emit_item(it, eol))
            block.append(emit_item(row.entry, eol))
            lines[key_idx:key_idx + 1] = block
            status = "normalized+appended"
        else:
            existing = existing_entries(lines, key_idx, close_idx)
            if row.entry in existing:
                row.status, row.outcome = "duplicate-noop", "duplicate-noop"
                return
            tail = array_tail_index(lines, key_idx, close_idx)
            insert_at = tail + 1
            lines[insert_at:insert_at] = [emit_item(row.entry, eol)]
            status = "appended"

    if row.updated:
        date = (datetime.date.today().isoformat()
                if row.updated == "today" else row.updated)
        open_idx, close_idx = frontmatter_bounds(lines)
        set_updated(lines, open_idx, close_idx, date)

    if dry_run:
        row.status = "would-" + status
        row.outcome = "would-%s ^%s" % (status, row.key)
        return

    write_text(path, bom + "".join(lines))
    row.status, row.outcome = status, status
    return path


def count_items(path, key):
    _, lines = read_lines(path)
    open_idx, close_idx = frontmatter_bounds(lines)
    if open_idx is None:
        return 0
    key_idx = find_key_line(lines, open_idx, close_idx, key)
    if key_idx is None:
        return 0
    kc = split_eol(lines[key_idx])[0]
    fm = FLOW_RE.match(kc)
    if fm:
        return len(parse_flow(fm.group("body")))
    return len(existing_entries(lines, key_idx, close_idx))


def load_rows(args):
    if args.manifest:
        with open(args.manifest, "r", encoding="utf-8") as fh:
            data = json.load(fh)
        if not isinstance(data, list):
            sys.exit("manifest must be a JSON list of rows")
        return [Row(d) for d in data]
    if args.file and args.entry is not None:
        d = {"file": args.file, "entry": args.entry, "key": args.key}
        if args.updated:
            d["updated"] = args.updated
        return [Row(d)]
    sys.exit("give --manifest FILE, or --file F --entry S")


def main():
    ap = argparse.ArgumentParser(description="frontmatter array-append primitive")
    ap.add_argument("--manifest")
    ap.add_argument("--file")
    ap.add_argument("--entry")
    ap.add_argument("--key", default="edit_log")
    ap.add_argument("--updated", help="YYYY-MM-DD or 'today' (off by default; F4)")
    ap.add_argument("--create-key", action="store_true")
    ap.add_argument("--root", default=".")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--verify", action="store_true")
    args = ap.parse_args()

    rows = load_rows(args)
    bad = 0
    for row in rows:
        before = 0
        if args.verify and not args.dry_run:
            p = os.path.join(args.root, row.file)
            before = count_items(p, row.key) if os.path.isfile(p) else 0
        process_row(row, args.root, args.dry_run, args.create_key)
        print("%-58s %s" % (row.file[-58:], row.outcome))
        if row.status and row.status.startswith("refused"):
            bad += 1
            continue
        if args.verify and not args.dry_run:
            p = os.path.join(args.root, row.file)
            after = count_items(p, row.key)
            if row.status == "duplicate-noop":
                ok = (after == before)
            else:
                ok = (after == before + 1)
            if not ok:
                print("  VERIFY FAILED: %s count %d -> %d (status %s)"
                      % (row.key, before, after, row.status))
                bad += 1

    print("--- %d row(s), %d needing attention%s ---"
          % (len(rows), bad, " [dry-run]" if args.dry_run else ""))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
