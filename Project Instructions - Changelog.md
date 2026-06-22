---
title: Project Instructions - Changelog
type: project-doc
status: active
created: '2026-06-18'
updated: '2026-06-18'
operator: Andrew
tags:
  - protocol
  - DataWizard
edit_log:
  - DW-S189 2026-06-18
---
# Project Instructions - Changelog

Version history for the DataWizard Project Instructions (`DataWizard Project Instructions.md`). The live instructions stay lean and `@import`-clean; their history lives here. VERSION.md is the canonical version source.


## Version Tracker

| What | Version | Last changed |
|---|---|---|
| Project Instructions | v4.4 | 2026-06-18 |
| Seed | v1.1.1 | 2026-06-10 |

---

## What Changed in v4.4

**Multi-surface restructure.** The PI is now a single de-fenced file (`DataWizard Project Instructions.md`, renamed from `Project Instructions - Copy-Paste into Claude.md`) that serves both surfaces: Cowork users paste it into project settings, Claude Code / Sidecar users `@import` it from their vault-root `CLAUDE.md`. A shared behavioral core is followed by per-surface tool appendices (`## Cowork tools` now; `## Claude Code tools` is a placeholder filled in a later release). Each surface heeds its own appendix and ignores the other.

**Per-adopter home folder declared at the surface.** The shipped file no longer carries a fill-in blank for the vault home folder (a `git pull` would clobber it - the Vault Config.md problem). Each consumer declares `Project home folder: <path>` at its consumption surface: the Cowork settings header, or the vault-root `CLAUDE.md` above the `@import`. The Seed path `_DataWizard/Seed/` stays hardcoded.

**Rules slimmed to pointers (behavioral kernels kept inline).** Rule 7 points to the Conventions Registry for shell+section mechanics; Rule 8 points to Filename Safety for the character map (the patch-safety kernel stays inline); Rule 9 replaces the inline install command with a VERSION.md pointer; Rule 12 points to YAML Schema Section 4 for the birth-metadata field list (keeps "bump `updated:`" inline). The enumerated Skills list became a pointer to `SKILLS.md`. lint backs Rules 8 and 12.

**New Rule 16: LINK DON'T RESTATE.** Conventions with a canonical home (Conventions Registry, YAML Schema, Filename Safety, taxonomy) are linked, never restated - a rule written twice will drift. The former Rule 16 (filesystem fallback) moved to the `## Cowork tools` appendix as a Cowork-specific mechanic.

**Orientation Step 1 auto-clear.** When the running PI version already matches VERSION.md's `project_instructions` value, the instance silently resolves any open "re-paste PI" action item instead of waiting for the human to report the paste.

**Changelog extracted.** This file. The PI stub stays `@import`-clean; version history lives here.

---

## What Changed in v4.3

**Multi-operator session ID format (Steps 5-6).** Multi-operator projects now use composite session identifiers: `PROJ_YYYY-MM-DD_INITIALS_NN` (e.g., `WV_2026-06-10_AA_01`). Solo-operator projects keep sequential numbering unchanged. Steps 5 and 6 updated with conditional logic for both formats. The session-closer skill (v3.5) has the full Session Identifier Format reference section. Each multi-operator project's 0.0 Project Guidelines should include an operator registry mapping names to initials.

---

## What Changed in v4.2

**Creation-time metadata contract (Working Rule 12, Step 6).** New files must include "birth metadata" at creation time: type, created, updated, operator, and edit_log. Previously, operator and edit_log were only added during session close (session-closer Step 3.14/3.8). If a session never closed -- context exhaustion, team members skipping close -- those files had no authorship or provenance trail. Now session close verifies birth metadata rather than applying it for the first time. Step 6 (orientation stub) updated to include full birth metadata. Canonical spec: YAML Schema Section 4 "Creation-Time Metadata Contract".

---

## What Changed in v4.1

**Seed-access hard stop (Working Rule 9).** Lifecycle skills (session-closer, project-guidelines) now have a mandatory Seed-access check. If the skill file returns "File not found", the instance diagnoses whether the Seed is stale (folder exists, skill missing -- run update_seed.sh) or absent (folder missing -- install from GitHub). In neither case does the instance attempt to pattern-match a session close. This prevents the drift pattern where Seed-less sessions produce incomplete session logs missing required fields (like `operator`), which then become templates for future pattern-matching, compounding the problem.

---

## What Changed in v4.0

**Local-only version check (Step 1).** Orientation no longer fetches VERSION.md from GitHub. Instead, instances read the local Seed's VERSION.md and compare its `project_instructions` value against the running PI version. If the local Seed has a newer PI, the instance tells the user to re-paste. This eliminates the GitHub authorization prompt on every session start. Seed updates are handled separately via update_seed.sh or git sync.

**Simplified session greeting (Step 5).** Instances now just state the project abbreviation and session number (e.g. "DW S116") without proposing a thread name.

**Terminal command generation (Working Rule 15).** When file or folder operations can't be done via Obsidian MCP or system tools, instances generate a terminal command for the user to run plus a verification command to confirm it worked. Addresses the gap where folder renames, cross-vault moves, and deletions required manual user action with no guidance.

**Filesystem fallback (Working Rule 16).** When obsidian:read_note overflows on large files or direct file access is needed, instances should use request_cowork_directory with the vault path rather than wrestling with MCP workarounds. Pattern validated in S89 (Research Tracking Index sectioning). *(v4.4: this moved to the Cowork tools appendix.)*

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

**Thread naming in orientation (step 5).** After completing orientation, the instance states the session number and proposes a provisional thread name. Format: `ProjectAbbrev SNN - expected focus` (no date). Based on "What's next" from the previous session plus any user direction. Session-closer skill handles the final rename at session end. *(Superseded by v4.0 Step 5.)*

**Lifecycle reminder in orientation (step 6).** Explicit note that lifecycle transitions are skill-governed. Reinforces Working Rule 9 at the moment when instances are loading their session plan.

---

## What Changed in v3.4

**Skills section replaces Rule 7.** The old SKILLS rule ("check if a skill exists before major tasks") is replaced by a dedicated `## Skills` section listing all Seed skills with one-line descriptions. Instances now know what skills exist from the system prompt -- no MCP scan needed for discovery. The section also explicitly includes lifecycle transitions (session close, project setup) as skill triggers, fixing the gap where instances missed skills like session-closer because closing a session didn't feel like a "major task." Project-specific skills are referenced generically (project home folder under Skills/) to keep the PI universal across projects. Working Rules renumbered: old 8 (LARGE FILES) becomes 7, old 9 (SAFE CHARACTERS) becomes 8.

**Large file vigilance on read.** Working Rule 8 expanded: instances now proactively suggest sectioning when they encounter a long or truncated file during reading, not just during editing. Prevents the pattern where instances silently work around file size instead of flagging it.

---

## What Changed in v3.2

**GitHub API for version check.** Orientation step 1 now fetches VERSION.md from the GitHub API (`api.github.com/repos/.../contents/`) instead of `raw.githubusercontent.com`. The raw CDN caches aggressively, causing instances to see stale version info even after a fresh push. The API endpoint reflects commits immediately. *(Superseded by v4.0 local-only check.)*

---

## What Changed in v3.1

**Tool loading fix.** Replaced vague tool_search example with three explicit queries that reliably load all Obsidian MCP tools during orientation. Prevents patch_note and other tools from failing to load due to overly short search terms.

**File renamed.** `COPY INTO CLAUDE PROJECT.md` renamed to `Project Instructions - Copy-Paste into Claude.md`. *(v4.4: renamed again to `DataWizard Project Instructions.md`.)*

---

## What Changed in v3.0

**Local-first rewrite.** The Seed is now installed locally in every vault. Instances read protocols, skills, taxonomy, and guides from the local Seed via MCP - no more fetching from GitHub every thread. GitHub is only touched once per thread to check VERSION.md for updates.

**Orientation simplified.** From 8 steps to 5. No more protocol fetching, no protocol version comparison, no MOC read. Instances read 0.0 for project context, session log for continuity, and action items for priorities. Everything else is read on demand.

**Skills discovery from Seed.** The skills index is no longer listed in the instructions. Instances check `_DataWizard/Seed/Skills/` directly when rule 7 triggers. This means new skills are discovered automatically when the Seed is updated - no re-paste needed. *(Superseded by v3.4 inline Skills section, then v4.4 pointer.)*

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
