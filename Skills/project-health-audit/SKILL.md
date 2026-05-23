---
name: project-health-audit
description: >-
  Systematic audit of a DW project against protocol conventions. Checks
  shell-section drift, YAML compliance, filename safety, infrastructure
  completeness, and protocol conformance. Triggers on: 'DW review', 'audit this
  project', 'check project health', or automatically via session-closer every
  ~10 sessions.
type: skill
version: '1.0'
created: '2026-05-23'
updated: '2026-05-23'
---

# Project Health Audit Skill

## Overview

Systematic audit of a DW project against protocol conventions. Checks shell-section drift, YAML compliance, filename safety, infrastructure completeness, and protocol conformance. Produces a structured report with prioritized action items.

This skill is the formalized version of the `DW review` command. It can be invoked manually ("run a DW review," "audit this project") or triggered automatically by the session-closer every ~10 sessions.

## When to Use

- When the session-closer prompts for a periodic audit (Step 3.11)
- When the user requests `DW review` or "audit this project"
- After a major restructure, migration, or protocol version bump
- When onboarding a new project to DW conventions

### When NOT to Use

- For mid-session spot checks on a single file (just read it)
- For content quality review (this checks structure, not substance)

## Audit Scope Tiers

Ask the user which scope they want before starting:

| Scope | What it checks | Token cost | When to use |
|---|---|---|---|
| **Quick** | Infrastructure files, folder structure, filename safety | Low | Routine periodic check |
| **Standard** | Quick + frontmatter on all files (via `get_frontmatter`), shell-section sync | Medium | Default for 10-session periodic audits |
| **Full** | Standard + content spot-checks on key files, broken embed detection | High | After major restructures or migrations |
| **Incremental** | Only files modified since the last audit | Low-Medium | Between full audits when drift is suspected |

For the automatic 10-session trigger from session-closer, default to **Standard** unless the user requests otherwise.

## Audit Categories

### Category 1: Infrastructure File Presence

Check that the project has these required files:

- `0.0 Project Guidelines - ProjectName.md` -- required
- `0.1 MOC - ProjectName.md` -- required
- `0.2 Session Log - ProjectName.md` -- required
- `0.3 Decision Log - ProjectName.md` -- required
- `0.4 Harvest Log - ProjectName.md` -- required after first harvest
- `! Action Items - ProjectName.md` -- recommended

Verify each file's frontmatter includes `updated:` and `datawizard_protocol_version:`.

### Category 2: Shell-Section Drift

For each shell file (files containing `![[...]]` embeds with a corresponding sections folder):

1. **List the sections folder** to get all files on disk
2. **Parse the shell** to extract all `![[filename]]` embed references
3. **Compare and report:**
   - **Missing embeds**: Section files in folder but NOT embedded in shell. This is the most common drift -- sections added but shell never updated.
   - **Broken embeds**: Embeds in shell that don't resolve to any file in the sections folder. Usually caused by renames or deletes.
   - **Full-path embeds**: Embeds using `![[path/to/file]]` instead of `![[filename]]`. Anti-pattern that breaks when folders move.
   - **Non-section files**: Files in the sections folder that don't follow N.N numbering (e.g., `_Harvest Log`, `0.01 Session Log`). Informational only -- these are expected auxiliary files, not drift.

**Sections folder inference:** Given a shell at `path/Shell Name.md`, check:
1. `path/Shell Name/` (sibling folder with same name)
2. `_Sections - ProjectName/Shell Name/` (protocol standard location)
3. If neither exists, the shell may not use the sections pattern -- skip it

### Category 3: YAML Compliance

Check frontmatter on project files using `get_frontmatter` (no full reads needed):

**All files:**
- `type:` present and lowercase
- `updated:` present and in YYYY-MM-DD format (not ISO datetime `T00:00:00.000Z`)
- `created:` present and in YYYY-MM-DD format

**Section files** (files with `parent:` and `section:` in frontmatter):
- `parent:` is a wikilink (`"[[Shell Name]]"`)
- `section:` matches the numeric prefix in the filename
- `edit_log:` present (required on section files per YAML Metadata Protocol)

**Infrastructure files (0.x):**
- `datawizard_protocol_version:` present
- `edit_log:` present (recommended)

**Files with harvest-related YAML:**
- `harvest_status:` uses valid values (absent, `pending`, `reviewed`, `harvested`)
- `harvest_for:` entries are wikilinks
- `harvested_into:` entries are wikilinks

### Category 4: Filename Safety

Scan filenames for violations of the cross-platform safety rules:

- Em-dashes (`--`) -- should be plain hyphens (`-`)
- Curly quotes -- should be straight quotes
- Characters forbidden on Windows: `? | * < > " \ :`
- Tab characters, non-breaking spaces, carriage returns
- Consecutive spaces
- Trailing whitespace before extension

Reference: `Seed/Guides/Filename Safety.md`

### Category 5: Protocol Conformance

Check for patterns that indicate stale or non-compliant conventions:

- **Stale meta-folder prefixes**: Folders using `~` prefix instead of `_` (pre-v1.1.0 convention)
- **Roman numerals in section headers**: Section files using `## III.` instead of `## 3.` (retired convention)
- **Broken L-series references**: Embeds referencing `L.00` or `L.01` files (retired LLM Collaboration Protocol)
- **Missing project name suffix**: Infrastructure files or meta-folders without `- ProjectName` suffix
- **Shell files with inline content**: Shells that contain actual content instead of only `![[embed]]` references (partial migration)

### Category 6: Date Consistency (Full scope only)

For files with both YAML `updated:` and filesystem modification dates:

- Flag files where YAML `updated` is more than 30 days older than filesystem mtime. This suggests edits happened outside a DW session (human edits, plugin changes, git operations) without updating YAML.

Note: Git operations reset filesystem timestamps, so this check is advisory, not definitive. Frontmatter dates are authoritative per protocol.

## How to Run the Audit

### Step 1: Determine scope

Ask the user for the desired scope tier (Quick, Standard, Full, or Incremental). For periodic audits triggered by session-closer, default to Standard.

For Incremental scope, check the `last_health_audit:` field in the project's 0.0 frontmatter to determine the cutoff date. Only audit files with `updated:` dates after the last audit date, plus any files flagged in the previous audit report that weren't fixed.

### Step 2: Identify project boundaries

Read the project's 0.0 to understand folder structure. Identify:
- Project root folder
- All domain folders (e.g., `Workshop/`, `Quests/`)
- Meta-folders (`_Sections - ProjectName/`, `_Archive - ProjectName/`, `_Infrastructure - ProjectName/`)
- Excluded folders (`xArchive` -- skip unless explicitly directed to audit old content)

### Step 3: Run category checks

Execute the relevant categories for the chosen scope:
- **Quick**: Categories 1, 4, 5
- **Standard**: Categories 1, 2, 3, 4, 5
- **Full**: Categories 1, 2, 3, 4, 5, 6
- **Incremental**: Categories 2, 3, 4 on modified files only

Use `get_frontmatter` and `list_directory` for most checks. Only use `read_note` when content inspection is needed (shell embed parsing, protocol conformance content checks). This keeps token cost manageable for large projects.

### Step 4: Generate report

Present the report in chat using the output format below. Group findings by category with severity indicators.

### Step 5: Propose action items

For each finding, classify as:
- **Auto-fixable**: Mechanical fixes the agent can apply (add missing YAML field, rename file, update embed). Offer to apply these with user approval.
- **Needs judgment**: Issues that require human decision (where to insert a missing embed in a shell's narrative order, whether a partial migration should be completed, etc.). Add these to the project's action items file.

### Step 6: Update audit record

After the audit completes, update the project's 0.0 frontmatter:
```yaml
last_health_audit: "ProjectAbbrev-SNN"
```

## Output Format

```
## DW Project Health Audit

**Project:** [Name]
**Scope:** [Quick | Standard | Full | Incremental]
**Date:** YYYY-MM-DD (Session ProjectAbbrev-SNN)
**Protocol target:** v1.7

### Summary

| Category | Checked | Issues | Auto-fixable |
|---|---|---|---|
| Infrastructure | Y | 0 | - |
| Shell-Section Drift | Y | 3 | 1 |
| YAML Compliance | Y | 12 | 10 |
| Filename Safety | Y | 2 | 2 |
| Protocol Conformance | Y | 1 | 0 |
| Date Consistency | - | - | - |

### Findings

#### Shell-Section Drift

**[Shell Name]** (path/to/shell.md)
- MISSING EMBED: `15.0 New Section.md` exists in folder, not embedded in shell
- BROKEN EMBED: `![[Old Section.md]]` -- file not found in sections folder
- Sections in folder: 24 | Embedded in shell: 22 | Drift: 2

#### YAML Compliance

- 8 section files missing `edit_log` field
- 3 files using ISO datetime format instead of YYYY-MM-DD
- 1 infrastructure file missing `datawizard_protocol_version`

[...additional categories...]

### Recommended Actions

**Auto-fixable (apply now?):**
1. Add `edit_log: []` to 8 section files
2. Convert 3 ISO dates to YYYY-MM-DD
3. Rename 2 files with em-dashes

**Needs judgment (added to action items):**
1. Insert `![[15.0 New Section.md]]` in [Shell] -- where in the narrative order?
2. Complete shell migration for [Doc Name] -- shell still has inline content
```

## Handling Large Projects

For projects with 50+ files, the audit may be too large for a single pass. In that case:

1. Run Category 1 (infrastructure) and Category 4 (filenames) first -- these are fast
2. Run Category 2 (drift) on shells only -- the highest-value check
3. Run Category 3 (YAML) in batches of 20 files using `get_frontmatter`
4. Present intermediate findings if context is getting long

The goal is to complete the audit in one session. If the project is genuinely too large (100+ files across many folders), suggest splitting into domain-level audits across sessions.

## Related

- **Session-closer Step 3.10**: Per-session lightweight section-shell sync check (catches drift at creation time)
- **Session-closer Step 3.11**: The periodic trigger that invokes this skill every ~10 sessions
- **Protocol Summary > DW Review**: Points to this skill
- **Feature requests resolved**: Shell-Sections Drift Detection, Protocol Transition Audit
