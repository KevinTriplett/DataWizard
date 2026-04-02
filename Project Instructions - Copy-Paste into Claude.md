---
title: Project Instructions - Copy-Paste into Claude
type: project-doc
status: active
created: '2026-03-12'
updated: '2026-04-02'
tags:
  - protocol
  - AI-collaboration
  - DataWizard
---

# DataWizard - Copy Into Claude Project

Paste the block below into **Settings - Project Instructions** for every Claude Project that works with your vault. Re-paste when the version changes. **Before re-pasting, archive the old version** in `xArchive DataWizard/Project Instructions Archive/`.

---

## Paste This Into Project Instructions

```
Home folder: ___________
(fill in the vault-relative path, e.g. _MyProject/)

# DW Project Instructions v3.4

## Tools
You have Obsidian MCP tools. Use them directly - never ask
the user to copy/paste vault content. Tools load lazily -
run tool_search to load any tool before first use. Use
descriptive queries (short/vague terms may miss tools).

Load all needed tools during orientation with these calls:
  tool_search "obsidian read_note write_note patch_note replace"
  tool_search "obsidian list_directory search_notes get_frontmatter"
  tool_search "obsidian update_frontmatter move_note manage_tags"

If obsidian:read_note returns "File not found" for a path
that obsidian:list_directory shows exists, fall back to
filesystem tools with the full absolute path. This is a
known intermittent MCP issue.

## Working Rules
1. WRITE TO VAULT: New content as .md - never draft markdown
   in chat. Share plan first, get approval, then write.
2. EDITS: Show specific changes in chat first. Never reprint
   the whole document. Once approved, write to vault.
3. RE-READ BEFORE WRITING: Always re-read the file immediately
   before writing. Another user or agent may have changed it.
4. CHUNK: Break multi-step plans into chunks. Present each,
   get approval, execute, check in before next.
5. VERIFY: Confirm success after any write/patch/move before
   retrying. Silent success + retry = duplicate content.
6. ASK: When uncertain about anything, ask rather than assume.
7. LARGE FILES: Files >5000 words - suggest chunking into
   shell + section folder before editing. Also when READING
   a file that's notably long or gets truncated, proactively
   suggest sectioning it. Don't just work around the size -
   flag it as a candidate for the shell + sections pattern.
8. SAFE CHARACTERS: In note titles, use plain hyphens (-)
   never em-dashes, and straight quotes never curly quotes.
   In content, avoid these in headings and text you expect
   to patch. They cause patch_note to fail on matching.

## Skills
Seed Skills (general skills applicable to all projects) live
in _DataWizard/Seed/Skills/. Project-specific skills live in
the project home folder under Skills/.
Read the full SKILL.md before using any skill. Follow it
completely. Skills apply to lifecycle transitions (session
close, project setup) not just content tasks.

Seed Skills:
  session-closer: End-of-session log entry, learnings, handoff.
  project-guidelines: Creating or updating 0.0 Project Guidelines.
  research-tracking: Tracking research to prevent duplicate work.
  tools-research: Evaluating external tools, repos, frameworks.
  design-harvest: Planting research findings into design docs.
  transcript-harvest: Harvesting transcripts into project docs.
  document-harvest: Harvesting articles/clippings into project docs.

See _DataWizard/Seed/SKILLS.md for full catalog.

## Orientation (once per thread)
1. Fetch VERSION.md from GitHub API:
   https://api.github.com/repos/andrewalan11/DataWizard/contents/VERSION.md
   The API returns JSON - decode the base64 "content" field.
   Compare against local _DataWizard/Seed/VERSION.md.
   Follow the instructions in VERSION.md for any mismatches
   (Seed version, project instructions version).
   If GitHub is unreachable, continue with local Seed.
2. Read 0.0 Project Guidelines in full (project context).
3. Read 0.2 Session Log (last 2-3 entries only). The most
   recent "What's next" section tells you where to pick up.
4. Read action items file if one exists.
5. Ready to work. Read Seed docs (protocols, taxonomy,
   skills, guides) as needed for specific tasks.
```

*Re-paste only when the Project Instructions version changes (currently v3.4).*

---

## Version Tracker

| What | Version | Last changed |
|---|---|---|
| Project Instructions | v3.4 | 2026-04-02 |
| Seed | v1.0.0 | 2026-03-25 |

---

## What Changed in v3.4

**Skills section replaces Rule 7.** The old SKILLS rule ("check if a skill exists before major tasks") is replaced by a dedicated `## Skills` section listing all Seed skills with one-line descriptions. Instances now know what skills exist from the system prompt -- no MCP scan needed for discovery. The section also explicitly includes lifecycle transitions (session close, project setup) as skill triggers, fixing the gap where instances missed skills like session-closer because closing a session didn't feel like a "major task." Project-specific skills are referenced generically (project home folder under Skills/) to keep the PI universal across projects. Working Rules renumbered: old 8 (LARGE FILES) becomes 7, old 9 (SAFE CHARACTERS) becomes 8.

**Large file vigilance on read.** Working Rule 8 expanded: instances now proactively suggest sectioning when they encounter a long or truncated file during reading, not just during editing. Prevents the pattern where instances silently work around file size instead of flagging it.

---

## What Changed in v3.2

**GitHub API for version check.** Orientation step 1 now fetches VERSION.md from the GitHub API (`api.github.com/repos/.../contents/`) instead of `raw.githubusercontent.com`. The raw CDN caches aggressively, causing instances to see stale version info even after a fresh push. The API endpoint reflects commits immediately.

---

## What Changed in v3.1

**Tool loading fix.** Replaced vague tool_search example with three explicit queries that reliably load all Obsidian MCP tools during orientation. Prevents patch_note and other tools from failing to load due to overly short search terms.

**File renamed.** `COPY INTO CLAUDE PROJECT.md` renamed to `Project Instructions - Copy-Paste into Claude.md`.

---

## What Changed in v3.0

**Local-first rewrite.** The Seed is now installed locally in every vault. Instances read protocols, skills, taxonomy, and guides from the local Seed via MCP - no more fetching from GitHub every thread. GitHub is only touched once per thread to check VERSION.md for updates.

**Orientation simplified.** From 8 steps to 5. No more protocol fetching, no protocol version comparison, no MOC read. Instances read 0.0 for project context, session log for continuity, and action items for priorities. Everything else is read on demand.

**Skills discovery from Seed.** The skills index is no longer listed in the instructions. Instances check `_DataWizard/Seed/Skills/` directly when rule 7 triggers. This means new skills are discovered automatically when the Seed is updated - no re-paste needed.

**Working rules tightened.** Each rule is 1-2 lines. Same substance, fewer tokens. Safe Characters added as rule 9.

**~40 lines down from ~80.** The behavioral contract is the same. The orientation overhead is halved.

---

## What Changed in v2.8

**Version check made actionable.** Step 4 now tells the instance how to compare versions and offer the user an easy update path.

---

## What Changed in v2.7

**Skills index added.** HARVEST rule generalized to SKILLS rule. Fallback for outdated skills list.

---

## Earlier versions

See git history or the v2.8 version of this file for full changelog.
