#!/usr/bin/env python3
"""generate_garden_base.py - generate an Obsidian .base companion view for a
garden: a live "Planted Seeds" table filtered on gardens.contains("<Garden>").

Part of the garden pattern (see Content Type Taxonomy, type: garden) and the
garden-synthesis skill (Step 8). Constituent seeds are stamped into a garden by
plant_garden_seeds.py; this generates the live view that surfaces them, updating
automatically as seeds are tagged.

Usage:
    python3 generate_garden_base.py "<path to Garden.md>"           # dry-run
    python3 generate_garden_base.py "<path to Garden.md>" --apply   # write
    [--name "Garden Name"]  override garden name (default: note basename)
    [--vault "<path>"]      override vault root (default: auto-detect .obsidian)
    [--bases "<path>"]      override bases dir (default: <vault>/_Bases)
    [--force]               overwrite an existing .base (default: refuse)

The --name MUST match the value plant_garden_seeds.py stamps into gardens:
(both default to the garden note's basename, so they align by default).

Safe: by default refuses to overwrite an existing .base so hand-customized
views are never clobbered - pass --force to replace. Emits the proven
"Planted Seeds" structure (name / type / stage); add per-garden formulas
(e.g. a Cluster column) by hand after generation.
"""
import os, argparse

TEMPLATE = '''filters:
  and:
    - gardens.contains("{name}")
views:
  - type: table
    name: Planted Seeds
    order:
      - file.name
      - type
      - stage
    columnSize:
      file.name: 320
'''

def find_vault(start):
    d = os.path.dirname(os.path.abspath(start))
    while True:
        if os.path.isdir(os.path.join(d, ".obsidian")):
            return d
        parent = os.path.dirname(d)
        if parent == d:
            return os.path.dirname(os.path.abspath(start))
        d = parent

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("garden")
    ap.add_argument("--name", default=None)
    ap.add_argument("--vault", default=None)
    ap.add_argument("--bases", default=None)
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--force", action="store_true")
    a = ap.parse_args()

    garden = os.path.abspath(a.garden)
    name = a.name or os.path.splitext(os.path.basename(garden))[0]
    vault = a.vault or find_vault(garden)
    bases = a.bases or os.path.join(vault, "_Bases")
    out = os.path.join(bases, name + ".base")
    content = TEMPLATE.format(name=name)

    exists = os.path.exists(out)
    print("MODE:", "APPLY" if a.apply else "DRY-RUN")
    print("garden:", name, "| vault:", vault)
    print("target:", out, "(exists)" if exists else "(new)")
    if exists and not a.force:
        print("REFUSING to overwrite existing .base (pass --force to replace).")
        print("--- would write ---")
        print(content)
        return
    if a.apply:
        os.makedirs(bases, exist_ok=True)
        with open(out, "w", encoding="utf-8") as f:
            f.write(content)
        print("WROTE", out)
    else:
        print("--- would write ---")
        print(content)

if __name__ == "__main__":
    main()
