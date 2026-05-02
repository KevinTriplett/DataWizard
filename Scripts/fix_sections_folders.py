#!/usr/bin/env python3
"""
Fix Sections Folder Structure
==============================
Moves section files from shared `Sections/` folders into per-document
named folders like `PDF Sections/Document Name/`.

Also updates wikilinks in the shell notes to point to the new paths.

Usage:
    python3 fix_sections_folders.py "/path/to/folder" --dry-run
    python3 fix_sections_folders.py "/path/to/folder"

Canonical location: _DataWizard/Seed/Scripts/fix_sections_folders.py
"""

import os
import re
import sys
import shutil
import argparse
from pathlib import Path


def clean_heading_for_filename(heading: str) -> str:
    """Sanitize a heading for use as a folder name (mirrors batch script)."""
    safe = heading.replace("/", "-").replace("\\", "-")
    safe = safe.replace('"', '').replace("'", "")
    safe = safe.replace(":", " -").replace("?", "").replace("*", "")
    safe = safe.replace("<", "").replace(">", "").replace("|", "-")
    safe = safe.replace("\n", " ").strip()
    while "  " in safe:
        safe = safe.replace("  ", " ")
    while "--" in safe:
        safe = safe.replace("--", "-")
    if len(safe) > 60:
        safe = safe[:60].rsplit(" ", 1)[0]
    return safe.strip()


def find_shell_notes(root_dir: Path) -> list:
    """Find all .md files with has_sections: true in frontmatter."""
    shell_notes = []
    for md_file in root_dir.rglob("*.md"):
        try:
            with open(md_file, "r", encoding="utf-8") as f:
                content = f.read(500)  # Only need the frontmatter
            if "has_sections: true" in content:
                shell_notes.append(md_file)
        except Exception:
            continue
    return sorted(shell_notes)


def parse_section_links(shell_path: Path) -> list:
    """Extract section filenames from wikilinks in a shell note."""
    with open(shell_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Match [[Sections/filename.md|display text]]
    pattern = r'\[\[Sections/([^|\]]+\.md)\|'
    return re.findall(pattern, content)


def process_shell_note(shell_path: Path, dry_run: bool = True) -> dict:
    """Process one shell note: move its sections to a named subfolder."""
    stem = shell_path.stem
    parent_dir = shell_path.parent
    old_sections_dir = parent_dir / "Sections"
    stem_folder_name = clean_heading_for_filename(stem)
    pdf_sections_dir = parent_dir / "PDF Sections"
    new_sections_dir = pdf_sections_dir / stem_folder_name

    result = {
        "shell": str(shell_path),
        "stem": stem,
        "old_dir": str(old_sections_dir),
        "new_dir": str(new_sections_dir),
        "files_moved": [],
        "files_missing": [],
        "status": "ok",
    }

    # Get section filenames from the shell note
    section_files = parse_section_links(shell_path)

    if not section_files:
        result["status"] = "no-links"
        return result

    if not old_sections_dir.exists():
        result["status"] = "no-sections-dir"
        return result

    # Check if already migrated (new folder exists with files)
    if new_sections_dir.exists() and list(new_sections_dir.glob("*.md")):
        result["status"] = "already-migrated"
        return result

    if dry_run:
        for filename in section_files:
            old_path = old_sections_dir / filename
            if old_path.exists():
                result["files_moved"].append(filename)
            else:
                result["files_missing"].append(filename)
        return result

    # --- Actually move files ---
    new_sections_dir.mkdir(parents=True, exist_ok=True)

    for filename in section_files:
        old_path = old_sections_dir / filename
        new_path = new_sections_dir / filename
        if old_path.exists():
            shutil.move(str(old_path), str(new_path))
            result["files_moved"].append(filename)
        else:
            result["files_missing"].append(filename)

    # Update wikilinks in the shell note
    with open(shell_path, "r", encoding="utf-8") as f:
        content = f.read()

    updated_content = content.replace(
        "[[Sections/",
        f"[[PDF Sections/{stem_folder_name}/"
    )

    with open(shell_path, "w", encoding="utf-8") as f:
        f.write(updated_content)

    # Clean up old Sections/ dir if empty
    if old_sections_dir.exists():
        remaining = list(old_sections_dir.glob("*"))
        # Filter out .DS_Store
        remaining = [f for f in remaining if f.name != ".DS_Store"]
        if not remaining:
            shutil.rmtree(old_sections_dir)
            result["old_dir_removed"] = True

    return result


def main():
    parser = argparse.ArgumentParser(
        description="Fix shared Sections/ folders into per-document named folders"
    )
    parser.add_argument("input_dir", help="Root directory to scan")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show what would be done without making changes")
    args = parser.parse_args()

    root = Path(args.input_dir).resolve()
    if not root.is_dir():
        print(f"Error: {root} is not a directory")
        sys.exit(1)

    print(f"\nScanning for shell notes in: {root}")
    print(f"Mode: {'DRY RUN' if args.dry_run else 'LIVE'}\n")

    shell_notes = find_shell_notes(root)
    print(f"Found {len(shell_notes)} shell notes with has_sections: true\n")

    moved_total = 0
    missing_total = 0
    skipped = 0
    errors = 0

    for shell_path in shell_notes:
        rel = shell_path.relative_to(root)
        try:
            result = process_shell_note(shell_path, dry_run=args.dry_run)
        except Exception as e:
            print(f"  ERROR: {rel}: {e}")
            errors += 1
            continue

        if result["status"] == "already-migrated":
            skipped += 1
            continue
        if result["status"] in ("no-links", "no-sections-dir"):
            skipped += 1
            continue

        n_moved = len(result["files_moved"])
        n_missing = len(result["files_missing"])
        moved_total += n_moved
        missing_total += n_missing

        action = "Would move" if args.dry_run else "Moved"
        new_folder = Path(result["new_dir"])
        stem_name = new_folder.name
        print(f"  {rel}")
        print(f"    {action} {n_moved} files -> PDF Sections/{stem_name}/")
        if n_missing:
            print(f"    Missing: {n_missing} files")
        if result.get("old_dir_removed"):
            print(f"    Removed empty Sections/ dir")

    print(f"\n--- Summary ---")
    print(f"Shell notes found: {len(shell_notes)}")
    print(f"Files {'to move' if args.dry_run else 'moved'}: {moved_total}")
    print(f"Files missing: {missing_total}")
    print(f"Skipped (already migrated or no sections): {skipped}")
    print(f"Errors: {errors}")

    if args.dry_run and moved_total > 0:
        print(f"\nRun without --dry-run to execute.")


if __name__ == "__main__":
    main()
