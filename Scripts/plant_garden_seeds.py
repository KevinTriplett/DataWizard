#!/usr/bin/env python3
"""plant_garden_seeds.py - stamp `gardens: [<Garden Name>]` into the
frontmatter of every seed linked from a garden note's "## Constituent
Seeds" section.

Part of the garden pattern (see Content Type Taxonomy, type: garden).
Because seeds are already backlinked from the garden, this removes the
need to hand-tag each seed: the garden's link list IS the source of truth.

Usage:
    python3 plant_garden_seeds.py "<path to Garden.md>"            # dry-run
    python3 plant_garden_seeds.py "<path to Garden.md>" --apply    # write
    [--name "Garden Name"]   override garden name (default: note basename)
    [--vault "<path>"]       override vault root (default: auto-detect .obsidian)

Safe + idempotent: only ADDS the gardens field/value. Never reformats or
removes existing frontmatter. Re-running only adds newly-linked seeds.
Resolution: builds a vault-wide note index (skipping dot-folders,
x-prefixed and *Archive* folders per DW convention, so superseded copies
never collide with live seeds); on duplicate names prefers the copy inside
the garden's own folder subtree, else flags the ambiguity.
"""
import os, re, sys, argparse

def find_vault(start):
    d = os.path.dirname(os.path.abspath(start))
    while True:
        if os.path.isdir(os.path.join(d, ".obsidian")):
            return d
        parent = os.path.dirname(d)
        if parent == d:
            return os.path.dirname(os.path.abspath(start))
        d = parent

def is_skipped_dir(name):
    """DW convention: dot-folders are hidden; an 'x'/'_x' prefix or an
    'Archive' in the name marks a deprecated/archived folder. Seeds in
    those folders are superseded copies and must not shadow live seeds."""
    return (name.startswith(".")
            or name.startswith("x")
            or name.startswith("_x")
            or "archive" in name.lower())

def add_gardens(content, name):
    lines = content.split("\n")
    if lines and lines[0].strip() == "---":
        close = next((i for i in range(1, len(lines)) if lines[i].strip() == "---"), None)
        if close is None:
            return content, "bad-frontmatter"
        fm, body = lines[1:close], lines[close:]
        g = next((i for i, l in enumerate(fm) if re.match(r"^gardens:", l)), None)
        if g is not None:
            if any(name in l for l in fm):
                return content, "already"
            fm.insert(g + 1, "  - " + name)
            return "\n".join(["---"] + fm + body), "merged"
        fm = ["gardens:", "  - " + name] + fm
        return "\n".join(["---"] + fm + body), "added"
    return "---\ngardens:\n  - " + name + "\n---\n\n" + content, "created-fm"

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("garden")
    ap.add_argument("--name", default=None)
    ap.add_argument("--vault", default=None)
    ap.add_argument("--apply", action="store_true")
    a = ap.parse_args()

    garden = os.path.abspath(a.garden)
    name = a.name or os.path.splitext(os.path.basename(garden))[0]
    vault = a.vault or find_vault(garden)
    garden_dir = os.path.dirname(garden)

    text = open(garden, encoding="utf-8").read()
    sec = text[text.find("## Constituent Seeds"):]
    if not sec:
        print("No '## Constituent Seeds' section found."); return
    names, seen = [], set()
    for m in re.findall(r"\[\[([^\]|]+?)(?:\|[^\]]*)?\]\]", sec):
        n = m.strip()
        if n and n not in seen:
            seen.add(n); names.append(n)

    index = {}
    for root, dirs, files in os.walk(vault):
        # prune hidden / archived folders from the walk (DW convention)
        dirs[:] = [d for d in dirs if not is_skipped_dir(d)]
        for fn in files:
            if fn.endswith(".md"):
                index.setdefault(fn[:-3], []).append(os.path.join(root, fn))

    stats, missing, ambiguous = {}, [], []
    for n in names:
        paths = index.get(n)
        if not paths:
            missing.append(n); continue
        if len(paths) > 1:
            inside = [p for p in paths if p.startswith(garden_dir + os.sep)]
            if len(inside) == 1:
                paths = inside
            else:
                ambiguous.append((n, len(paths))); continue
        content = open(paths[0], encoding="utf-8").read()
        new, status = add_gardens(content, name)
        stats[status] = stats.get(status, 0) + 1
        if a.apply and new != content:
            open(paths[0], "w", encoding="utf-8").write(new)

    print("MODE:", "APPLY" if a.apply else "DRY-RUN")
    print("garden:", name, "| vault:", vault)
    print("linked seeds:", len(names), "| status:", stats)
    if missing: print("UNRESOLVED:", missing)
    if ambiguous: print("AMBIGUOUS (skipped, resolve manually):", ambiguous)

if __name__ == "__main__":
    main()
