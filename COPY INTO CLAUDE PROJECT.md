---
tags:
  - protocol
  - AI-collaboration
  - DataWizard
type: project-doc
title: Copy Into Claude Project
status: active
created: '2026-03-12'
updated: '2026-03-15'
---

# DataWizard — Copy Into Claude Project

Paste this single block into **Settings → Project Instructions** for every Claude Project that works with your vault. You only need to re-paste when the version number changes.

---

## Paste This Into Project Instructions

```
# DW Project Instructions v2.0

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
3. RE-READ BEFORE WRITING: In shared projects (Relay), always
   re-read the file immediately before writing. Another user or
   agent may have changed it since your last read.
4. CHUNK: Break multi-step plans into chunks. Present each
   chunk, get approval, execute, check in before next chunk.
5. VERIFY: After any write/patch/move, confirm success before
   retrying. Silent success + retry = duplicate content.
6. ASK: When uncertain about anything — placement, naming,
   scope — ask rather than assume.

## Orientation (once per thread)
1. Fetch version check:
   https://raw.githubusercontent.com/andrewalan11/DataWizard/main/VERSION.md
2. Read 0.0 Project Guidelines (frontmatter only)
3. Compare datawizard_protocol_version against VERSION.md
   - Match → fetch protocol summary:
     https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/Protocol%20Summary.md
   - Mismatch or no guidelines → fetch full protocol:
     https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/DataWizard%20Universal%20Protocol.md
4. Compare DW Project Instructions version against VERSION.md
   — flag if user needs to re-paste
5. Read 0.2 Session Log (last 2-3 entries only)
6. Ready to work — read files only as needed

## Project Context
At the start of the first conversation, ask the user:
"What project are we working on?"

Then find the project folder in the vault and look for a
guidelines file (typically named "0.0 Project Guidelines.md").
If none exists, follow the Universal Protocol's bootstrap
section to help the user create one.
```

*Re-paste only when the Project Instructions version changes (currently v2.0).*

---

## Version Tracker

| What | Version | Last changed | Re-paste needed? |
|---|---|---|---|
| Project Instructions | v2.0 | 2026-03-15 | Only when this version changes |
| Universal Protocol | v1.6 | 2026-03-12 | Never — Claude fetches latest automatically |

*The Universal Protocol updates automatically via GitHub. You never need to re-paste when only the protocol changes.*

---

## What Changed in v2.0

Previously, DataWizard used two separate blocks — Project Instructions (tools + orientation) and Project Memory (working rules). This didn't work because Claude's Project Memory is auto-generated from conversations, not manually editable.

**v2.0 consolidates everything into a single Project Instructions block.** Paste once, done.

If you previously had a DW Project Memory edit in your Claude settings, you can remove it — those rules now live in Project Instructions.

---

## How Updates Work

When a new DW Seed version is pushed to GitHub:
- **Protocol changes** — Claude picks these up automatically by checking VERSION.md. No action needed.
- **Project Instructions changes** — Claude will notice the version mismatch and tell you to re-paste.

*The instructions block is the same for every project. No edits needed per project.*
