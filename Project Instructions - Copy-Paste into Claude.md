---
title: Project Instructions - Copy-Paste into Claude
type: project-doc
status: active
created: '2026-03-12'
updated: '2026-05-26'
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

# DW Project Instructions v4.0

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
   Never use Windows-invalid characters in filenames:
   ? | * < > " \ : tab, non-breaking space (\xa0), or
   carriage return. Collapse consecutive spaces to one.
   Strip trailing whitespace before extensions. In content,
   avoid em-dashes and curly quotes in headings and text
   you expect to patch. They cause patch_note to fail.
   See Seed/Guides/Filename Safety.md for the full map.
9. LIFECYCLE SKILLS: Before any lifecycle transition (project
   setup, session close), read and follow the governing skill
   (e.g. project-guidelines, session-closer). Do not write
   lifecycle artifacts from pattern-matching.
10. MCP WRITE VERIFICATION: At session close, verify all
   writes and patches landed using filesystem tools (Read or
   Glob on the vault path), not obsidian:read_note. If
   filesystem tools are unavailable, request vault access via
   request_cowork_directory. If context compaction is
   approaching and unverified writes risk falling out of
   context, verify those writes before compaction rather than
   waiting for session close. Flag to the user only if
   verification fails.
11. MCP CONCURRENCY: When multiple instances run on the same
   project, the session log shell (0.2 file) is a shared
   resource. Patch it only at session close, verify
   immediately, and if verification fails, retry once before
   flagging the user.
12. DOCUMENT METADATA: When writing to any file, bump the
   updated: date. When creating or substantially updating
   content documents, consider adding priority:
   (high/medium/low) and maturity:
   (draft/working/polished/canonical) to frontmatter.
   See YAML Schema (Protocol Section 4) for definitions.
13. FRONTMATTER SAFETY: Always use update_frontmatter with
   merge: true (default). merge: false deletes any omitted
   fields.
14. CHAT READABILITY: Never present draft documents (skills,
   design docs, session log entries) as markdown code blocks
   in chat. Write directly to vault for review. For small
   edits, describe changes in plain prose. Markdown in code
   blocks doesn't wrap and is unreadable in chat.
15. TERMINAL COMMANDS: When file or folder operations
   (moves, copies, deletions, renames) can't be done via
   Obsidian MCP or system tools, generate a terminal
   command for the user to run, followed by a verification
   command to confirm it worked.
16. FILESYSTEM FALLBACK: If obsidian:read_note overflows
   on a large file, or you need direct file access that
   MCP can't provide, use request_cowork_directory with
   the vault path to get filesystem access. Don't waste
   multiple attempts on MCP workarounds first.

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
  meta-learning-review: Reviewing session learnings and planting
    them into skills, design docs, and protocol.

See _DataWizard/Seed/SKILLS.md for full catalog.

## Orientation (once per thread)
1. Read local _DataWizard/Seed/VERSION.md. Compare its
   project_instructions value against the version in the
   header of these instructions (e.g. "v4.0"). Ignore any
   "-local" suffix. If local Seed has a newer version,
   tell the user: "Your PI is v[yours] but your Seed has
   v[local]. Copy the updated PI from the Seed into your
   project settings." If your running PI is newer than the
   Seed, that's normal - continue silently.
2. Read 0.0 Project Guidelines in full (project context).
3. Read 0.2 Session Log (last 2-3 entries only). The most
   recent "What's next" section tells you where to pick up.
4. Read action items file if one exists.
5. State the project abbreviation and session number
   (e.g. "DW S116").
6. Create a session log stub to claim your session number.
   List the session log section folder, determine the next
   available section number, and write a minimal stub file:
   "NN.0 Session NNN - in progress.md" with status:
   in-progress in frontmatter and a Part of breadcrumb.
   Add the embed to the session log shell. This gives
   concurrent instances (including those on other users'
   machines) immediate visibility that the number is taken.
   Once the user confirms the session's direction, patch
   the stub content with 1-2 lines describing the focus.
   The session-closer overwrites this stub with the full
   entry at session end.
7. Lifecycle transitions (project setup, session close)
   are skill-governed. Read the skill before executing.
8. Ready to work. Read Seed docs (protocols, taxonomy,
   skills, guides) as needed for specific tasks.
```

*Re-paste only when the Project Instructions version changes (currently v4.0).*

---

## Version Tracker

| What | Version | Last changed |
|---|---|---|
| Project Instructions | v4.0 | 2026-05-27 |
| Seed | v1.1.0 | 2026-05-02 |

---

## What Changed in v4.0

**Local-only version check (Step 1).** Orientation no longer fetches VERSION.md from GitHub. Instead, instances read the local Seed's VERSION.md and compare its `project_instructions` value against the running PI version. If the local Seed has a newer PI, the instance tells the user to re-paste. This eliminates the GitHub authorization prompt on every session start. Seed updates are handled separately via update_seed.sh or git sync.

**Simplified session greeting (Step 5).** Instances now just state the project abbreviation and session number (e.g. "DW S116") without proposing a thread name.

**Terminal command generation (Working Rule 15).** When file or folder operations can't be done via Obsidian MCP or system tools, instances generate a terminal command for the user to run plus a verification command to confirm it worked. Addresses the gap where folder renames, cross-vault moves, and deletions required manual user action with no guidance.

**Filesystem fallback (Working Rule 16).** When obsidian:read_note overflows on large files or direct file access is needed, instances should use request_cowork_directory with the vault path rather than wrestling with MCP workarounds. Pattern validated in S89 (Research Tracking Index sectioning).

---

## What Changed in v3.9

**Session log stub in orientation (Step 6).** After stating the session number, instances now create a minimal stub section file ("NN.0 Session NNN - in progress.md") in the session log folder and add its embed to the shell. This claims the session number for concurrent instances, including those running on other users' machines. Once the user confirms the session's direction, the instance patches the stub with 1-2 lines of context. The session-closer (which already handled stubs) overwrites it with the full entry at session end. Existing Steps 6-7 renumbered to 7-8.

---

## What Changed in v3.8

**Chat readability (Working Rule 14).** Instances must never present draft documents (skills, design docs, session log entries) as markdown code blocks in chat. Markdown inside code fences doesn't wrap and extends past the viewing window, making review painful. Write directly to vault for review. Describe small edits in plain prose.

**Meta-learning-review skill added to skills list.** New Seed skill for reviewing accumulated session learnings and planting them into skills, design docs, and protocol. Complements design-harvest (which plants external research findings). Triggered every 5-10 sessions via session-closer nudge or on demand. Session-closer v1.8 adds Step 3.13 for the cadence check.

---

## What Changed in v3.7

**Frontmatter safety (Working Rule 13).** Instances must use `update_frontmatter` with `merge: true` (the default). Using `merge: false` replaces the entire frontmatter, deleting any omitted fields. This caused accidental data loss in at least two sessions (S92, S95). One-line rule prevents the gotcha without requiring instances to read the MCP Reliability guide.

---

## What Changed in v3.6

**MCP write verification (Working Rule 10).** At session close, instances verify all writes and patches landed using filesystem tools (Read/Glob), not obsidian:read_note which can return phantom content from cache. If context compaction is approaching and unverified writes risk falling out of context, verify before compaction rather than waiting. Only flag the user if verification fails. Addresses ghost write incidents observed during concurrent multi-instance sessions (May 2026).

**Document metadata discipline (Working Rule 12).** Instances bump `updated:` on every file write and consider adding `priority:` and `maturity:` fields when creating or substantially updating content documents. Ensures new documents enter the vault with weighting signals for downstream content pipelines. See D76.

**MCP concurrency (Working Rule 11).** The session log shell (0.2 file) is explicitly called out as a shared resource when multiple instances run on the same project. Instances patch it only at session close, verify immediately with filesystem tools, and retry once before escalating. Prevents the pattern where concurrent patches silently fail and are not caught until the next session.

---

## What Changed in v3.5

**Lifecycle skills rule (Working Rule 9).** Agents must read the governing skill before any lifecycle transition (project setup, session close). Names the two key skills inline (project-guidelines, session-closer) so instances don't have to cross-reference. Fixes the pattern where agents skip skill-governed workflows by pattern-matching from prior session log entries instead of following the skill.

**Thread naming in orientation (step 5).** After completing orientation, the instance states the session number and proposes a provisional thread name. Format: `ProjectAbbrev SNN - expected focus` (no date). Based on "What's next" from the previous session plus any user direction. Session-closer skill handles the final rename at session end.

**Lifecycle reminder in orientation (step 6).** Explicit note that lifecycle transitions are skill-governed. Reinforces Working Rule 9 at the moment when instances are loading their session plan.

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
