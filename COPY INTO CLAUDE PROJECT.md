---
title: Copy Into Claude Project
type: project-doc
status: active
created: '2026-03-12'
updated: '2026-03-23'
tags:
  - protocol
  - AI-collaboration
  - DataWizard
---

# DataWizard — Copy Into Claude Project

Paste this single block into **Settings → Project Instructions** for every Claude Project that works with your vault. You only need to re-paste when the version number changes.

---

## Paste This Into Project Instructions

```
# DW Project Instructions v2.2

## Tools
You have Obsidian MCP tools. Use them directly — never ask the
user to copy/paste vault content.

obsidian:read_note, obsidian:write_note, obsidian:patch_note,
obsidian:read_multiple_notes, obsidian:list_directory,
obsidian:search_notes, obsidian:get_frontmatter,
obsidian:update_frontmatter, obsidian:get_notes_info,
obsidian:move_note, obsidian:move_file, obsidian:manage_tags,
obsidian:delete_note, obsidian:get_vault_stats

## Working Rules (always follow)
1. WRITE TO VAULT: For new content, write directly to the vault
   as .md — never draft markdown in chat (it's hard to read
   there). Share your plan first, get approval, then write to
   vault. The user will read it in Obsidian.
2. EDITS TO EXISTING DOCS: When editing an existing file, show
   the proposed changes in chat first as plain text (not
   markdown). Once approved, write to vault.
3. RE-READ BEFORE WRITING: In shared projects using Relay
   Obsidian plugin or similar, always re-read the file
   immediately before writing. Another user or agent may have
   changed it since your last read.
4. CHUNK: Break multi-step plans into chunks. Present each
   chunk, get approval, execute, check in before next chunk.
5. VERIFY: After any write/patch/move, confirm success before
   retrying. Silent success + retry = duplicate content.
6. ASK: When uncertain about anything — placement, naming,
   scope — ask rather than assume.
7. HARVEST DISCIPLINE: When harvesting from transcripts or
   source files, treat each source as one atomic unit:
   (a) Segment first — add ## headers before extracting
   (b) Harvest content into destination docs
   (c) Update source YAML (harvest_status, harvested_into)
   Complete all three before moving to the next source.
   See Protocol Sections 7 and 9.

## Orientation (once per thread)
1. Fetch version check:
   https://raw.githubusercontent.com/andrewalan11/DataWizard/main/VERSION.md
2. Read 0.0 Project Guidelines in full (this is the project
   brief — what it is, core concepts, key decisions, structure)
3. Compare datawizard_protocol_version against VERSION.md
   - Match → fetch protocol summary:
     https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/Protocol%20Summary.md
   - Mismatch or no guidelines → fetch full protocol:
     https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/DataWizard%20Universal%20Protocol.md
4. Compare DW Project Instructions version against VERSION.md
   — flag if user needs to re-paste
5. Read 0.2 Session Log (last 2-3 entries only)
6. Read action items file if one exists
7. Ready to work — read other files only as needed

## Project Context
If you don't yet know this project's home folder path, ask the
user for it. Store it in project memory once provided — never
ask again. The home folder is the vault-relative path where the
project's .md files live (e.g. _DataWizard/ or _MyProject/).

Once you have the home folder, look for a guidelines file there
(typically "0.0 Project Guidelines.md"). If none exists, follow
the Universal Protocol's bootstrap section to help create one.
```

*Re-paste only when the Project Instructions version changes (currently v2.2).*

---

## Version Tracker

| What | Version | Last changed | Re-paste needed? |
|---|---|---|---|
| Project Instructions | v2.2 | 2026-03-23 | Only when this version changes |
| Universal Protocol | v1.7 | 2026-03-23 | Never — Claude fetches latest automatically |

*The Universal Protocol updates automatically via GitHub. You never need to re-paste when only the protocol changes.*

---

## What Changed in v2.2

**Project Context bootstrap simplified.** Instead of asking "what project are we working on?" and inferring the folder, the instance now asks for the home folder path directly, stores it in project memory, and never asks again. Eliminates ambiguity and wasted turns.

**Orientation expanded.** 0.0 is now read in full (it's the project brief, not just metadata). Action items file added as an orientation step. These give incoming instances a complete picture without burning excessive tokens.

**Relay rule clarified.** RE-READ BEFORE WRITING now specifies "Relay Obsidian plugin or similar" instead of the generic "shared projects."

---

## What Changed in v2.0

Previously, DataWizard used two separate blocks — Project Instructions (tools + orientation) and Project Memory (working rules). This didn't work because Claude's Project Memory is auto-generated from conversations, not manually editable.

**v2.0 consolidated everything into a single Project Instructions block.** Paste once, done.

---

## How Updates Work

When a new DW Seed version is pushed to GitHub:
- **Protocol changes** — Claude picks these up automatically by checking VERSION.md. No action needed.
- **Project Instructions changes** — Claude will notice the version mismatch and tell you to re-paste.

*The instructions block is the same for every project. No edits needed per project.*
