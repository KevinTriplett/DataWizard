#!/usr/bin/env python3
"""stamp_blocks.py -- on-cite block-ID stamper.

Stamp an Obsidian block ID (^bN prose / ^tN transcript turn) on the *last
line* of a source paragraph at the moment a citation points to it -- on-cite,
sparse, never in bulk. Idempotent: an existing trailing block ID on the target
line (integer or human-minted) is reused, never doubled; otherwise the next
unused integer in the file is assigned.

Writes are byte-faithful: the ID is appended to the target line only, with no
end-of-line normalization, whitespace reflow, or front-matter re-dump, so a
stamp is the minimal diff a downstream updated-field reconciliation treats as a
non-body change.

Modes:
  --manifest FILE      JSON list of rows: {"file","locate","id"?,"prefix"?}
  --file F --locate S  a batch of one (optional --id / --prefix)
  --root DIR           base dir for relative row paths (default: cwd)
  --dry-run            report only; write nothing
  --verify             after processing, re-read each file fresh and confirm
                       the resolved ID appears exactly once and on the located
                       line; non-zero exit on any failure

Row outcomes: stamped <id> | reused <id> | not-found | ambiguous | refused:<why>
Exit is non-zero if any row is not-found / ambiguous / refused, or if --verify
finds an intended ID missing or duplicated.

Behavioural spec: the block-stamper skill. Stdlib only; targets Python 3.8+.
"""
import argparse
import json
import os
import re
import sys

# A trailing block stamp: whitespace, caret, id, optional trailing spaces, EOL.
TRAILING_ID_RE = re.compile(r"\s\^([A-Za-z0-9-]+)[ \t]*\Z")
# A whole line that is only a block id (Obsidian mints these for tables etc.).
STANDALONE_ID_RE = re.compile(r"^\^([A-Za-z0-9-]+)[ \t]*\Z")
EOL_RE = re.compile(r"(\r\n|\r|\n)\Z")
HEADING_RE = re.compile(r"^\s{0,3}#{1,6}\s")
FENCE_RE = re.compile(r"^\s{0,3}(```|~~~)")
SPEAKER_RE = re.compile(r"^\s*\*\*[^*]+\*\*\s*:")
LIST_PREFIX_RE = re.compile(r"^(\s*(?:[-*+]\s+|\d+[.)]\s+|>\s?)+)")
# A line that starts a new list item (so a tight list splits into one block
# per item; continuation/wrapped lines attach to the item above them).
LIST_ITEM_START_RE = re.compile(r"^\s*(?:[-*+]|\d+[.)])\s+\S")
HR_RE = re.compile(r"^\s{0,3}(-{3,}|\*{3,}|_{3,})\s*\Z")
TABLE_SEP_RE = re.compile(r"^\s*\|?\s*:?-{3,}.*\|")


def splitkeep(text):
    """Split into lines keeping exact EOLs; only \\r\\n, \\r, \\n are breaks."""
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
    with open(path, "w", encoding="utf-8", newline="") as fh:
        fh.write(text)


def body_start_index(lines):
    """Index of the first body line, skipping a leading YAML front-matter block."""
    if lines and split_eol(lines[0])[0].strip() == "---":
        for i in range(1, len(lines)):
            if split_eol(lines[i])[0].strip() == "---":
                return i + 1
    return 0


def find_blocks(lines, body_start):
    """Maximal runs of non-blank lines; a new list item also opens a block so a
    tight list splits per item. Fence-internal blank lines stay in their block.
    Returns (start_idx, last_idx) pairs."""
    blocks = []
    cur = None
    in_fence = False
    i = body_start
    n = len(lines)
    while i < n:
        content = split_eol(lines[i])[0]
        is_fence = bool(FENCE_RE.match(content))
        if is_fence:
            in_fence = not in_fence
            cur = [i, i] if cur is None else [cur[0], i]
            i += 1
            continue
        if in_fence:
            cur = [i, i] if cur is None else [cur[0], i]
            i += 1
            continue
        if content.strip() == "":
            if cur is not None:
                blocks.append((cur[0], cur[1]))
                cur = None
            i += 1
            continue
        if LIST_ITEM_START_RE.match(content):
            # a new list item starts its own block
            if cur is not None:
                blocks.append((cur[0], cur[1]))
            cur = [i, i]
            i += 1
            continue
        cur = [i, i] if cur is None else [cur[0], i]
        i += 1
    if cur is not None:
        blocks.append((cur[0], cur[1]))
    return blocks


def lead_text(lines, block):
    content = split_eol(lines[block[0]])[0]
    m = LIST_PREFIX_RE.match(content)
    stripped = content[m.end():] if m else content
    return content, stripped


def block_matches(lines, block, locate):
    raw, stripped = lead_text(lines, block)
    return raw.startswith(locate) or stripped.startswith(locate)


def refusal_reason(lines, block):
    first = split_eol(lines[block[0]])[0]
    if HEADING_RE.match(first):
        return "heading"
    if HR_RE.match(first):
        return "horizontal-rule"
    if FENCE_RE.match(first):
        return "code-fence"
    for idx in range(block[0], block[1] + 1):
        if TABLE_SEP_RE.match(split_eol(lines[idx])[0]):
            return "table"
    return None


def existing_id_on_line(content):
    m = TRAILING_ID_RE.search(content)
    if m:
        return m.group(1)
    m = STANDALONE_ID_RE.match(content)
    if m:
        return m.group(1)
    return None


def next_unused_int(lines):
    # Only real block STAMPS count -- a trailing/standalone `^b<int>` on a line.
    # A `#^bN` inside a wikilink citation references another file's block and is
    # never a stamp in this file, so it must not inflate the sequence.
    mx = 0
    stamp_int = re.compile(r"^[bt](\d+)$")
    for ln in lines:
        eid = existing_id_on_line(split_eol(ln)[0])
        if eid:
            m = stamp_int.match(eid)
            if m:
                mx = max(mx, int(m.group(1)))
    return mx + 1


def id_present_count(lines, block_id):
    """(total occurrences as a real stamp, index of the last line carrying it)."""
    count = 0
    where = -1
    pat = re.compile(r"(?:\s|^)\^" + re.escape(block_id) + r"[ \t]*\Z")
    for idx, ln in enumerate(lines):
        if pat.search(split_eol(ln)[0]):
            count += 1
            where = idx
    return count, where


def detect_prefix(lines, body_start, block):
    fm = "".join(split_eol(l)[0] + "\n" for l in lines[:body_start])
    if re.search(r"type:\s*\S*(transcript|voice-memo)", fm):
        return "t"
    if SPEAKER_RE.match(split_eol(lines[block[0]])[0]):
        return "t"
    return "b"


def append_id(lines, target_idx, block_id):
    content, eol = split_eol(lines[target_idx])
    lines[target_idx] = content + " ^" + block_id + eol


class Row(object):
    def __init__(self, d):
        self.file = d["file"]
        self.locate = d["locate"]
        self.id = d.get("id", "next")
        self.prefix = d.get("prefix")
        self.outcome = None       # human string
        self.status = None        # stamped|reused|not-found|ambiguous|refused
        self.resolved_id = None
        self.target_idx = None


def process_row(row, root, dry_run):
    path = os.path.join(root, row.file)
    if not os.path.isfile(path):
        row.status, row.outcome = "refused", "refused:no-such-file"
        return
    text = read_text(path)
    lines = splitkeep(text)
    bstart = body_start_index(lines)
    blocks = find_blocks(lines, bstart)
    matches = [b for b in blocks if block_matches(lines, b, row.locate)]
    if not matches:
        row.status, row.outcome = "not-found", "not-found"
        return
    if len(matches) > 1:
        row.status, row.outcome = "ambiguous", "ambiguous (%d matches)" % len(matches)
        return
    block = matches[0]
    reason = refusal_reason(lines, block)
    if reason:
        row.status, row.outcome = "refused", "refused:" + reason
        return
    target_idx = block[1]
    row.target_idx = target_idx
    existing = existing_id_on_line(split_eol(lines[target_idx])[0])
    if existing:
        row.status, row.resolved_id, row.outcome = "reused", existing, "reused ^" + existing
        return
    spec = (row.id or "next")
    if spec == "next":
        prefix = row.prefix or detect_prefix(lines, bstart, block)
        block_id = prefix + str(next_unused_int(lines))
    else:
        block_id = spec.lstrip("^")
        cnt, _ = id_present_count(lines, block_id)
        if cnt:
            row.status, row.outcome = "refused", "refused:id-collision (^%s already in file)" % block_id
            return
    if dry_run:
        row.status, row.resolved_id, row.outcome = "would-stamp", block_id, "would-stamp ^" + block_id
        return
    append_id(lines, target_idx, block_id)
    write_text(path, "".join(lines))
    # verify-after-claim (collision guard): re-read, ensure unique + on target
    lines2 = splitkeep(read_text(path))
    cnt, where = id_present_count(lines2, block_id)
    if cnt == 1 and where == target_idx:
        row.status, row.resolved_id, row.outcome = "stamped", block_id, "stamped ^" + block_id
    else:
        row.status, row.resolved_id = "refused", block_id
        row.outcome = "refused:verify-failed (^%s count=%d line=%d want=%d)" % (
            block_id, cnt, where, target_idx)


def verify_rows(rows, root):
    """Independent re-read: each resolved row's id occurs once, on its line."""
    failures = []
    for row in rows:
        if row.status not in ("stamped", "reused") or not row.resolved_id:
            continue
        path = os.path.join(root, row.file)
        lines = splitkeep(read_text(path))
        cnt, where = id_present_count(lines, row.resolved_id)
        ok = (cnt == 1) and (row.target_idx is None or where == row.target_idx)
        if not ok:
            failures.append("%s ^%s: count=%d line=%d" % (
                row.file, row.resolved_id, cnt, where))
    return failures


def load_rows(args):
    if args.manifest:
        with open(args.manifest, "r", encoding="utf-8") as fh:
            data = json.load(fh)
        if not isinstance(data, list):
            sys.exit("manifest must be a JSON list of rows")
        return [Row(d) for d in data]
    if args.file and args.locate:
        d = {"file": args.file, "locate": args.locate}
        if args.id:
            d["id"] = args.id
        if args.prefix:
            d["prefix"] = args.prefix
        return [Row(d)]
    sys.exit("give --manifest FILE, or --file F --locate S")


def main():
    ap = argparse.ArgumentParser(description="on-cite block-ID stamper")
    ap.add_argument("--manifest")
    ap.add_argument("--file")
    ap.add_argument("--locate")
    ap.add_argument("--id", help='"next" (default) or an explicit id like b7')
    ap.add_argument("--prefix", choices=["b", "t"])
    ap.add_argument("--root", default=".")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--verify", action="store_true")
    args = ap.parse_args()

    rows = load_rows(args)
    for row in rows:
        process_row(row, args.root, args.dry_run)

    bad = 0
    for row in rows:
        print("%-64s %s" % (row.file[-64:], row.outcome))
        if row.status in ("not-found", "ambiguous", "refused"):
            bad += 1

    if args.verify and not args.dry_run:
        failures = verify_rows(rows, args.root)
        if failures:
            print("VERIFY FAILED:")
            for f in failures:
                print("  " + f)
            bad += len(failures)
        else:
            print("VERIFY OK (%d id(s) resolve uniquely on their line)"
                  % sum(1 for r in rows if r.status in ("stamped", "reused")))

    n = len(rows)
    ok = n - bad
    print("--- %d row(s): %d ok, %d needing attention%s ---"
          % (n, ok, bad, " [dry-run]" if args.dry_run else ""))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
