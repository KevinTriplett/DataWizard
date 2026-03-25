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
Home folder: ___________
(fill in the vault-relative path, e.g. _DataWizard/ or
_ReWoven/ReWoven Shared/ — leave this line when re-pasting
instructions below)

# DW Project Instructions v2.8

## Tools
You have Obsidian MCP tools. Use them directly — never ask the
user to copy/paste vault content. Tools load lazily — run
tool_search to load any tool before first use (e.g.,
tool_search "obsidian patch note").

obsidian:read_note, obsidian:write_note, obsidian:patch_note,
obsidian:read_multiple_notes, obsidian:list_directory,
obsidian:search_notes, obsidian:get_frontmatter,
obsidian:update_frontmatter, obsidian:get_notes_info,
obsidian:move_note, obsidian:move_file, obsidian:manage_tags,
obsidian:delete_note, obsidian:get_vault_stats

If obsidian:read_note returns "File not found" for a path that
obsidian:list_directory shows exists, fall back to filesystem
tools with the full absolute path:
filesystem:read_text_file with
/Users/USERNAME/Vaults/Regen Vault/[path]
This is a known intermittent issue with the Obsidian MCP
plugin. Don't waste time troubleshooting — just use the
filesystem fallback and move on.

## Working Rules (always follow)
1. WRITE TO VAULT: For new content, write directly to the vault
   as .md — never draft markdown in chat (it's hard to read
   there). Share your plan first, get approval, then write to
   vault. The user will read it in Obsidian.
2. EDITS TO EXISTING DOCS: Show the specific changes in chat
   first — what's being added, removed, or reworded. Never
   reprint the whole document. Once approved, write to vault.
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
7. SKILLS: Before starting any major task, check if a DW
   skill exists for it (see Skills index below). Read the
   SKILL.md fully before starting. Follow the skill workflow
   completely. If no skill matches, proceed normally.
8. LARGE FILES: When encountering a large file (>5000 words),
   suggest chunking it into a shell + section folder for
   easier editing. Don't attempt to rewrite a large file in
   one pass.

## Orientation (once per thread)
1. Fetch version check:
   https://raw.githubusercontent.com/andrewalan11/DataWizard/main/VERSION.md
   If GitHub is unreachable, read from the local Seed instead:
   _DataWizard/Seed/VERSION.md
2. Read 0.0 Project Guidelines in full (this is the project
   brief — what it is, core concepts, key decisions, structure)
3. Compare datawizard_protocol_version against VERSION.md
   - Match → fetch protocol summary:
     https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/Protocol%20Summary.md
   - Mismatch or no guidelines → fetch full protocol:
     https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/DataWizard%20Universal%20Protocol.md
   - If GitHub is unreachable for either, read from local Seed:
     _DataWizard/Seed/Protocols/Protocol Summary.md
     _DataWizard/Seed/Protocols/DataWizard Universal Protocol.md
4. Compare your version (in the header above) against
   the project_instructions field in VERSION.md. If they
   don't match, follow the update instructions in
   VERSION.md.
5. Read 0.1 MOC if one exists (map of project content)
6. Read 0.2 Session Log (last 2-3 entries only). The most
   recent entry's "What's next" section tells you where to
   pick up if the user says "let's continue" or "start
   where we left off."
7. Read action items file if one exists
8. Ready to work — read other files only as needed

## Skills
DW skills live in _DataWizard/Seed/Skills/. Each subfolder
has a SKILL.md. Read the matching skill before starting work.

project-guidelines  — creating or updating 0.0 files
research            — systematic research from triage reviews
repo-research       — deep diving into local reference repos
transcript-harvest  — harvesting from transcripts
document-harvest    — harvesting from articles and docs
session-handoff     — writing handoff briefings for next instance

If the skills list above seems outdated, list the Skills
folder to check for new additions.
```

*Re-paste only when the Project Instructions version changes (currently v2.8).*

---

## Version Tracker

| What | Version | Last changed | Re-paste needed? |
|---|---|---|---|
| Project Instructions | v2.8 | 2026-03-25 | Only when this version changes |
| Universal Protocol | v1.7 | 2026-03-23 | Never — Claude fetches latest automatically |

*The Universal Protocol updates automatically via GitHub. You never need to re-paste when only the protocol changes.*

---

## What Changed in v2.8

**Version check made actionable.** Orientation step 4 was vague ("flag if user needs to re-paste") — instances were noticing the mismatch but not acting on it. Step 4 now explicitly tells the instance how to compare versions, what to say to the user, and — if the user wants to update — to fetch and print the full paste block from GitHub so it's a one-step copy-paste. The user chooses whether to update; it's not forced.

---

## What Changed in v2.7

**Skills index added to Project Instructions.** All DW skills are now listed with their trigger descriptions directly in the instructions block, like the MCP tools list. Instances scan this during orientation and know what skills are available without needing to discover them. Update the list when skills are added.

**HARVEST rule generalized to SKILLS rule.** Rule 7 no longer hardcodes harvest skill paths. Instead it says: "check if a DW skill exists for it" and points to the skills index. This makes the instructions skill-aware by default rather than special-casing one task type.

**Fallback for outdated skills list.** If the skills index in the instructions seems stale, instances are told to list the Skills folder directly to check for new additions.

---

## What Changed in v2.6

**Filesystem fallback for Obsidian MCP.** The Obsidian MCP tools intermittently fail to resolve paths that `list_directory` shows exist. Added explicit fallback: use `filesystem:read_text_file` with the full absolute path. Don't waste context troubleshooting — just fall back and move on.

**Session log "What's next" in orientation.** Step 6 now tells the instance to look at the most recent session log entry's "What's next" section — this is how you know what to do when the user says "let's continue."

**Skill paths updated.** Harvest skill references point to SKILL.md folder paths following the Agent Skills standard.

---

## What Changed in v2.5

**Home folder as user-editable header.** The first line of the instructions block is now `Home folder: ___________` which the user fills in per project. This replaces the old "ask the user for the home folder" pattern. When re-pasting updated instructions, the user leaves this line in place and selects everything below it.

**Edit rule simplified.** Always show specific changes in chat — no more split between "small edits show specifics, large edits summarize." Never reprint the whole document.

**Harvest rule replaced with skill file references.** Instead of abbreviated harvest instructions in the project instructions, instances now read dedicated skill files (`transcript-harvest/SKILL.md`, `document-harvest/SKILL.md`) from the Seed Skills library. Skills now follow the SKILL.md folder standard with proper frontmatter for progressive disclosure.

**Large file chunking rule added.** When encountering files >5000 words, instances should suggest converting to shell + section folder before editing.

**MOC added to orientation.** Instances now read 0.1 MOC during orientation for a map of project content.

---

## What Changed in v2.4

**Local Seed fallback added.** If GitHub is unreachable during orientation (network disabled, connectivity issues), instances now fall back to reading protocol files from the local Seed at `_DataWizard/Seed/`. Fixes orientation failures when network access is unavailable.

---

## What Changed in v2.3

**Tool loading reminder added.** MCP tools load lazily — instances must run `tool_search` to load tools before first use. This was causing instances to miss `patch_note` and fall back to full-file overwrites. The Tools section now includes an explicit reminder.

---

## What Changed in v2.2

**Project Context bootstrap simplified.** Instead of asking "what project are we working on?" and inferring the folder, the instance now asks for the home folder path directly, stores it in project memory, and never asks again. Eliminates ambiguity and wasted turns.

**Orientation expanded.** 0.0 is now read in full (it's the project brief, not just metadata). Action items file added as an orientation step. These give incoming instances a complete picture without burning excessive tokens.

**Edit rule refined.** EDITS TO EXISTING DOCS now scales the level of detail shown in chat — specific changes for small edits, summaries for large edits. Avoids reprinting entire documents when only a few things changed.

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
