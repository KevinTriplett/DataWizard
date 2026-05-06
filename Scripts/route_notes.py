#!/usr/bin/env python3
"""
route_notes.py - Move classified vault notes to their proper folders based on type.

Reads the `type:` YAML field and moves files to the folder defined in the
routing table. Follows the Vault Cleanup Architecture (Session 21).

Usage:
    # Dry run on vault root
    python3 route_notes.py --vault ~/Vaults/Regen\ Vault --folder / --dry-run

    # Dry run on _!nbox
    python3 route_notes.py --vault ~/Vaults/Regen\ Vault --folder _!nbox/ --dry-run

    # Execute moves
    python3 route_notes.py --vault ~/Vaults/Regen\ Vault --folder _!nbox/

    # Include subfolders
    python3 route_notes.py --vault ~/Vaults/Regen\ Vault --folder _!nbox/ --recursive --dry-run

No external dependencies required.
"""

import os
import re
import sys
import shutil
import argparse
from datetime import datetime


# ─────────────────────────────────────────────────────────
# Routing Table — type → destination folder
# From Vault Cleanup Architecture, Session 21
# ─────────────────────────────────────────────────────────

ROUTING_TABLE = {
    # Seeds
    "seed":                  "_Seeds",
    "seedpod":               "_Seeds",

    # Entities, Events, Resources
    "entity":                "_Entities",
    "event":                 "_Events",
    "resource":              "_Resources",
    "resource-list":         "_Resources",

    # People
    "person":                "_People",

    # Clippings (articles, videos)
    "article":               "_Clippings",
    "video":                 "_Clippings",

    # Transcripts
    "video-transcript":      "_Transcripts",
    "podcast-transcript":    "_Transcripts",
    "meeting-transcript":    "_Transcripts",
    "voice-memo-transcript": "_Transcripts/Voice Memos",

    # Meetings
    "meeting-note":          "_Meetings",
    "message":               "_Meetings",

    # Companions
    "companion":             "_Companions",

    # SKIP these — need human judgment
    # "document":            project-specific, can't auto-route
    # "multi-part":          lives with parent series
}

# Types that are SKIPPED (logged but not moved)
SKIP_TYPES = {"document", "multi-part"}


def extract_type(filepath):
    """Extract type: value from YAML frontmatter using regex."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read(2000)  # Only need the frontmatter
    except (UnicodeDecodeError, FileNotFoundError):
        return None

    # Check for YAML frontmatter
    if not content.startswith('---'):
        return None

    # Find the closing ---
    end = content.find('---', 3)
    if end == -1:
        return None

    frontmatter = content[3:end]

    # Match type: value (handle both quoted and unquoted)
    match = re.search(r'^type:\s*["\']?([a-zA-Z_-]+)["\']?\s*$', frontmatter, re.MULTILINE)
    if match:
        return match.group(1).lower().strip()

    # Also check for Type: (capital T, legacy)
    match = re.search(r'^Type:\s*["\']?([a-zA-Z_-]+)["\']?\s*$', frontmatter, re.MULTILINE)
    if match:
        return match.group(1).lower().strip()

    return None


def scan_folder(vault_path, folder, recursive=False):
    """Scan a folder for .md files and return list of (filepath, type)."""
    if folder == '/':
        scan_dir = vault_path
    else:
        scan_dir = os.path.join(vault_path, folder)

    results = []

    if not os.path.isdir(scan_dir):
        print(f"ERROR: Folder not found: {scan_dir}")
        return results

    if recursive:
        for root, dirs, files in os.walk(scan_dir):
            # Skip hidden and system dirs
            dirs[:] = [d for d in dirs if not d.startswith('.') and d != 'node_modules']
            for f in files:
                if f.endswith('.md') and not f.startswith('.') and not f.startswith('!'):
                    filepath = os.path.join(root, f)
                    note_type = extract_type(filepath)
                    results.append((filepath, note_type))
    else:
        for f in os.listdir(scan_dir):
            filepath = os.path.join(scan_dir, f)
            if os.path.isfile(filepath) and f.endswith('.md') and not f.startswith('.') and not f.startswith('!'):
                note_type = extract_type(filepath)
                results.append((filepath, note_type))

    return results


def route_notes(vault_path, folder, dry_run=True, recursive=False):
    """Route classified notes to their proper folders."""

    results = scan_folder(vault_path, folder, recursive)

    moved = []
    skipped_no_type = []
    skipped_needs_human = []
    skipped_already_home = []
    errors = []

    for filepath, note_type in results:
        filename = os.path.basename(filepath)
        rel_path = os.path.relpath(filepath, vault_path)

        # No type -> skip
        if note_type is None:
            skipped_no_type.append(rel_path)
            continue

        # Type needs human judgment -> skip but log
        if note_type in SKIP_TYPES:
            skipped_needs_human.append((rel_path, note_type))
            continue

        # Type not in routing table -> skip
        if note_type not in ROUTING_TABLE:
            skipped_needs_human.append((rel_path, note_type))
            continue

        dest_folder = ROUTING_TABLE[note_type]
        dest_dir = os.path.join(vault_path, dest_folder)
        dest_path = os.path.join(dest_dir, filename)

        # Already in the right folder?
        current_folder = os.path.dirname(rel_path)
        if current_folder == dest_folder:
            skipped_already_home.append(rel_path)
            continue

        # Check for collision
        if os.path.exists(dest_path):
            errors.append(f"COLLISION: {rel_path} -> {dest_folder}/{filename} (already exists)")
            continue

        # Ensure dest folder exists
        if not dry_run:
            os.makedirs(dest_dir, exist_ok=True)

        # Move
        if dry_run:
            moved.append(f"  {rel_path} -> {dest_folder}/{filename}")
        else:
            try:
                shutil.move(filepath, dest_path)
                moved.append(f"  {rel_path} -> {dest_folder}/{filename}")
            except Exception as e:
                errors.append(f"ERROR moving {rel_path}: {e}")

    return {
        'moved': moved,
        'skipped_no_type': skipped_no_type,
        'skipped_needs_human': skipped_needs_human,
        'skipped_already_home': skipped_already_home,
        'errors': errors,
    }


def main():
    parser = argparse.ArgumentParser(description="Route classified vault notes to proper folders")
    parser.add_argument('--vault', required=True, help='Path to vault root')
    parser.add_argument('--folder', required=True, help='Folder to scan (/ for root)')
    parser.add_argument('--recursive', action='store_true', help='Include subfolders')
    parser.add_argument('--dry-run', action='store_true', default=True,
                        help='Preview moves without executing (default)')
    parser.add_argument('--execute', action='store_true', help='Actually move files')
    args = parser.parse_args()

    vault_path = os.path.expanduser(args.vault)
    dry_run = not args.execute

    if not os.path.isdir(vault_path):
        print(f"ERROR: Vault not found: {vault_path}")
        sys.exit(1)

    print(f"{'DRY RUN' if dry_run else 'EXECUTING'} - Routing notes in {args.folder}")
    print(f"Vault: {vault_path}")
    print(f"Recursive: {args.recursive}")
    print()

    results = route_notes(vault_path, args.folder, dry_run=dry_run, recursive=args.recursive)

    # Report
    if results['moved']:
        print(f"{'Would move' if dry_run else 'Moved'} ({len(results['moved'])} files):")
        for m in results['moved']:
            print(m)
        print()

    if results['skipped_no_type']:
        print(f"Skipped - no type: ({len(results['skipped_no_type'])} files)")
        for s in results['skipped_no_type'][:20]:
            print(f"  {s}")
        if len(results['skipped_no_type']) > 20:
            print(f"  ... and {len(results['skipped_no_type']) - 20} more")
        print()

    if results['skipped_needs_human']:
        print(f"Skipped - needs human routing ({len(results['skipped_needs_human'])} files):")
        for s, t in results['skipped_needs_human']:
            print(f"  [{t}] {s}")
        print()

    if results['skipped_already_home']:
        print(f"Already in correct folder ({len(results['skipped_already_home'])} files):")
        for s in results['skipped_already_home'][:10]:
            print(f"  {s}")
        if len(results['skipped_already_home']) > 10:
            print(f"  ... and {len(results['skipped_already_home']) - 10} more")
        print()

    if results['errors']:
        print(f"ERRORS ({len(results['errors'])}):")
        for e in results['errors']:
            print(f"  {e}")
        print()

    # Summary
    print(f"{'='*60}")
    print(f"SUMMARY")
    print(f"{'='*60}")
    print(f"  {'Would move' if dry_run else 'Moved'}:       {len(results['moved'])}")
    print(f"  No type:          {len(results['skipped_no_type'])}")
    print(f"  Needs human:      {len(results['skipped_needs_human'])}")
    print(f"  Already home:     {len(results['skipped_already_home'])}")
    print(f"  Errors:           {len(results['errors'])}")

    if dry_run:
        print(f"\n  DRY RUN - no files moved.")
        print(f"  Run with --execute to apply {len(results['moved'])} moves.")

    # Write log
    timestamp = datetime.now().strftime('%Y-%m-%d_%H%M')
    mode = "dryrun" if dry_run else "executed"
    log_filename = f"route_log_{timestamp}_{mode}.md"
    log_dir = os.path.join(vault_path, "_DataWizard", "Workshop", "Classification Logs")
    os.makedirs(log_dir, exist_ok=True)
    log_path = os.path.join(log_dir, log_filename)

    with open(log_path, 'w', encoding='utf-8') as f:
        f.write(f"# Route Log - {timestamp} ({'DRY RUN' if dry_run else 'EXECUTED'})\n\n")
        f.write(f"Folder: {args.folder}\n")
        f.write(f"Recursive: {args.recursive}\n\n")

        if results['moved']:
            f.write(f"## Moves ({len(results['moved'])})\n")
            for m in results['moved']:
                f.write(f"{m}\n")
            f.write("\n")

        if results['skipped_needs_human']:
            f.write(f"## Needs Human Routing ({len(results['skipped_needs_human'])})\n")
            for s, t in results['skipped_needs_human']:
                f.write(f"- [{t}] {s}\n")
            f.write("\n")

        if results['errors']:
            f.write(f"## Errors ({len(results['errors'])})\n")
            for e in results['errors']:
                f.write(f"- {e}\n")

    print(f"\n  Log: {log_path}")


if __name__ == "__main__":
    main()
