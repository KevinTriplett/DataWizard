---
name: content-interest-scan
description: >-
  Scan material pools (clippings, Recall Vault, transcripts) against a project's
  0.0 Project Guidelines to surface unrouted content matching the project's
  interests. Triggers on: 'scan for content', 'what's relevant to [project]',
  'check clippings', 'content interest scan', 'what's in clippings for
  [project]', after large imports, or as a scheduled nightly task. Two modes:
  per-project (default) and cross-project. Two scales: backlog (chunked,
  multi-session) and maintenance (incremental nightly).
type: skill
version: '0.1'
updated: '2026-06-04'
status: draft
---
# Content Interest Scan Skill

## Overview

Scan material pools (clippings, Recall Vault exports, transcripts, etc.) against a project's 0.0 Project Guidelines to surface relevant content that hasn't been routed. This is the active counterpart to Content Interests -- instead of waiting for an agent to stumble across relevant material, the scanner systematically checks pools of unsorted content against what a project cares about.

Two invocation modes: per-project (default) scans for one project's interests; cross-project scans shared pools against all active projects via the Vault Project Map.

Two operational scales: backlog mode for large unscanned pools (chunked, multi-session); maintenance mode for ongoing nightly scans of new material.

## When to Use

- User says "scan for content", "what's relevant to [project]?", "check clippings for [project]", "run a content interest scan"
- When a project is first set up or its Content Interests are updated (backlog scan to catch up)
- After a large batch of new material has accumulated in shared pools
- As a scheduled nightly task checking for new material since last scan
- When the user wants to know what's sitting unrouted in _Clippings or the Recall Vault

### When NOT to Use

- Routing individual files that just arrived (use harvest-router)
- Evaluating external tools or repos (use tools-research)
- Reviewing Content Interests themselves (use content-interests-review)
- Harvesting matched content into project documents (use transcript-harvest or document-harvest after this skill surfaces the matches)

## Before You Start

1. Read this skill fully.
2. Confirm `dw_ops.db` exists at `_DataWizard/_Infrastructure - DataWizard/dw_ops.db`. The scanner depends on the operational database for scan state tracking and research item dedup. If the DB doesn't exist, stop and tell the user it needs to be built first. See `Workshop/Design/Research Tracking Database.md`.
3. Determine the mode: per-project or cross-project.
4. Determine the scale: backlog (large unscanned pool) or maintenance (incremental new files).

## Dependencies

- **dw_ops.db**: Required. The `scan_state` table tracks what's been scanned. The `research_items` table enables dedup checks ("has this already been evaluated?"). Without the DB, the skill cannot track progress across sessions or avoid re-scanning.
- **0.0 Project Guidelines**: Required. The full 0.0 provides project context and Content Interests for matching.
- **Vault Project Map**: Required for cross-project mode only. `_DataWizard/Workshop/Vault Project Map.md`.

## Two Modes

### Per-Project Mode (Default)

Scans material pools against a single project's interests. Use this for focused scanning, multi-operator projects with privacy boundaries, or project-specific material pools.

**Input:**
- Project name (to locate its 0.0)
- Material pools to scan (one or more folder paths, e.g., `_Clippings/`, Recall Vault `_Recall Export/`)

**Context loaded:**
- The project's full 0.0 Project Guidelines (not just Content Interests -- the project description, architecture decisions, and working conventions all inform relevance judgment)

### Cross-Project Mode

Scans shared material pools against all active projects' Content Interests in a single pass. A single file can match multiple projects. Use this for solo operators managing many personal projects where cross-referencing is desirable.

**Input:**
- Material pools to scan
- (No project name needed -- scans against all active projects)

**Context loaded:**
- The Vault Project Map (contains embedded Content Interests from all active projects)

**When NOT to use cross-project mode:**
- Multi-operator projects where team members haven't consented to cross-project analysis
- Projects with confidentiality boundaries (client work, sensitive material)
- When per-project depth matters more than cross-project breadth

## Two Scales

### Backlog Mode

Large pool of unscanned files. The first scan of _Clippings (500+ files), a Recall Vault export (7,600+ files), or any pool that hasn't been scanned before.

**Approach:** Chunk the pool into batches of 50-75 files per run. Process each batch thoroughly -- title scan, YAML scan, content reads on all candidates. Write scan state after each batch. Progress survives across sessions and context windows.

**Pace:** Slow and thorough. Do not blast through hundreds of files per night. A 500-file backlog at 75 files/batch is ~7 runs over a week. Quality over speed -- missing a gem in a rush is worse than taking an extra day.

**Chunking logic:**
1. List all files in the target pool.
2. Query `scan_state` to filter out already-scanned files.
3. Take the first 50-75 unscanned files as this batch.
4. Process the batch (see The Scan Process below).
5. Report: "Batch complete. [N] files scanned, [N] matches. [M] files remaining in pool. Run again to continue."

The invoking agent or scheduled task calls the skill repeatedly, one batch at a time, with each run picking up where the last left off. This provides natural review checkpoints between batches.

### Maintenance Mode

Small pool of new files since last scan. The nightly scheduled task or a periodic check.

**Approach:** Process all new files with full depth. At this scale (5-15 files), every file gets title + YAML + content attention.

**Detection:** Query `scan_state` for the most recent scan date, then list files in the material pool with `created` dates (frontmatter or filesystem) after that date. Process all of them in a single run.

**The skill should detect which mode applies** based on the unscanned file count:
- 50+ unscanned files: recommend backlog mode, confirm with user
- Under 50: maintenance mode, process all in one run

## The Scan Process

For each batch of files, three passes filter from cheap to expensive.

### Pass 1: Title-Based Filtering (Fast)

List all filenames in the batch. Score each filename against the project's Content Interests (and broader 0.0 context). Most clipping filenames are descriptive enough to triage without reading content.

**Scoring:**
- **Likely relevant**: Title contains keywords, topics, or names that match Content Interests or project description. Proceed to Pass 3.
- **Possibly relevant**: Ambiguous title, could go either way. Proceed to Pass 2.
- **Likely irrelevant**: Title clearly outside the project's domain. Record in scan state as scanned with no match. Skip.

Be generous with "possibly relevant" -- it's cheaper to read a file and dismiss it than to skip something valuable based on a vague title.

### Pass 2: YAML/Frontmatter Scanning (Fast)

For files that passed title filtering (likely + possibly relevant), read frontmatter without reading full content. Check for signals:

- **`tags`**: Human or LLM-assigned tags that match project interests (e.g., `#regenerative-finance`, `#obsidian-plugin`, `#community-governance`)
- **`type`**: Content type may signal relevance (e.g., `tool-evaluation` for DataWizard, `event` for Regen Events Map)
- **`harvest_for`**: Already routed to a project? If so, note and potentially skip (already handled by harvest-router)
- **`source`** / **`author`**: Source provenance may indicate relevance
- **`triage_status`** / **`triage_relevant_to`**: Already triaged by Reddit pipeline? Use existing triage assessment as input.
- **`content_interest_match`**: Already matched by a previous scan? Check if this is a new project scan that might find additional relevance.
- **Any project-specific fields**: `meme_harvest_status`, `companion`, `processing_status`, etc. These indicate the file has been touched by DW infrastructure and may have richer metadata.

**YAML signals can promote or demote files:**
- A vaguely-titled file with `tags: [regenerative-economics, community-land-trust]` gets promoted to Pass 3 even if the title didn't match.
- A promising title with `harvest_for: [[DataWizard]]` already set might be skipped if this is a DataWizard scan (already routed).

### Pass 3: Content Reading (Expensive)

For files that survived Passes 1-2 as likely or possibly relevant, read the content. For long files (1000+ words), read the first 500-800 words -- enough to assess relevance without consuming excessive context.

**Assess:**
- Relevance level: **high** (clearly matches one or more Content Interests, would materially benefit the project) or **medium** (tangentially related, might be useful, worth flagging but not urgent)
- Which Content Interest category it matches (e.g., "production models", "community governance", "local LLM tools")
- One-line relevance note explaining why it matched

**Dedup check:** Before recording a match, query `research_items` in dw_ops.db by URL (if the file has one) or by name. If the resource has already been evaluated as a research item, note this in the scan results rather than re-flagging it.

## Recording Results

After processing each file (all three passes):

### Write to dw_ops.db

Insert or update a row in `scan_state`:

```sql
INSERT OR REPLACE INTO scan_state (file_path, scanned_date, scanned_by, matched_projects)
VALUES (?, ?, 'content-interest-scanner', ?);
```

`matched_projects` is a comma-separated list of project names, or NULL if no match.

### Write to file frontmatter (matches only)

For files that matched, write back to frontmatter:

```yaml
content_interest_match:
  - ProjectName1
  - ProjectName2
last_scanned: 2026-06-04
scan_relevance: high  # or medium
```

These fields make matches visible to Dataview queries, the Team Dashboard, the harvest-router, and project instances -- without requiring them to query the database.

**Do not modify frontmatter on files that didn't match.** The scan state DB tracks that they were scanned; no need to touch the file itself.

### Write the findings report

After completing a batch (or a full maintenance-mode run), write a findings report as a section file.

**Report location:** `_Infrastructure - ProjectName/_Sections - ProjectName/Content Interest Scans/`

**Report filename:** `YYYY-MM-DD - [Backlog Batch N | Nightly Scan].md`

**Report shell:** `_Infrastructure - ProjectName/0.9 Content Interest Scan Log - ProjectName.md` embeds the most recent 5-10 scan reports. Create the shell on first scan if it doesn't exist.

**Report format:**

```markdown
---
title: Content Interest Scan - [Project] - [Date]
type: scan-report
project: [ProjectName]
created: YYYY-MM-DD
scan_mode: backlog | maintenance
scan_scope: per-project | cross-project
material_pools:
  - _Clippings/
  - Recall Vault/_Recall Export/
files_scanned: N
matches_high: N
matches_medium: N
---

# Content Interest Scan - [Project] - [Date]

## [Content Interest Category 1]

### High Relevance

- [[Filename]] -- one-line relevance note
- [[Filename]] -- one-line relevance note

### Medium Relevance

- [[Filename]] -- one-line relevance note

## [Content Interest Category 2]

### High Relevance

- [[Filename]] -- one-line relevance note

## Scan Metadata

- **Mode:** backlog batch 3 / maintenance
- **Material pools:** _Clippings/, Recall Vault/_Recall Export/
- **Files scanned this batch:** N
- **Matches:** N high, N medium
- **Files remaining in pool:** M (backlog mode only)
- **Dedup hits:** N files already in research_items (skipped)
```

For cross-project mode, organize by project first, then by content interest category within each project.

## After the Scan

### Summarize to user

```
Scan complete (backlog batch 3 of ~7).
- Pool: _Clippings/
- Files scanned: 75
- High relevance: 8
- Medium relevance: 12
- Already evaluated (dedup): 3
- Remaining in pool: ~150

Report written to: _Infrastructure - ReWoven/...
Frontmatter updated on 20 matched files.

Run again to process next batch.
```

### Team flag integration (optional)

For high-relevance matches in multi-operator projects, consider auto-flagging via the Team Attention System frontmatter fields:

```yaml
flag: 2026-06-04
flag_by: "content-interest-scanner (auto)"
flag_note: "High-relevance match for [Content Interest Category]"
flag_for:
  - Kaliya
  - Jay
```

Only auto-flag high-relevance matches. Medium matches get the `content_interest_match` tag but not a team flag. The human reviewing the scan report can manually flag anything that deserves team attention.

### Action item (optional, backlog mode)

After a backlog batch surfaces significant matches, append a brief action item to the project's action items file:

```markdown
- [ ] **Review content interest scan results ([date])** -- [N] high-relevance items surfaced from [pool]. See scan report in _Infrastructure.
```

For maintenance mode (nightly), skip the action item -- the scan report and frontmatter tags are sufficient. The Team Dashboard will surface flagged items.

## Multi-Vault Scanning

The Regen Vault and Recall Vault are separate Obsidian vaults. The scanner needs to work across both.

- **Regen Vault** (Obsidian MCP): `_Clippings/`, `_Transcripts/`, project-internal folders
- **Recall Vault** (filesystem tools): `_Recall Export/`, `_Reddit Saves/`, `_Intake/`

Use Obsidian MCP tools (`list_directory`, `read_note`, `get_frontmatter`) for Regen Vault files. Use filesystem tools (`Read`, `Glob`) for Recall Vault files. The scanner should document which tool set to use for each pool.

**Vault paths:**
- Regen Vault: accessible via Obsidian MCP (paths relative to vault root)
- Recall Vault: accessible via filesystem at the mounted path (check Vault Config or use the Cowork folder mount)

## Common Mistakes

- **Reading only Content Interests, not the full 0.0.** The project description, architecture decisions, and current state all inform what's relevant. A clipping about "shell + sections patterns" won't match a Content Interest keyword but is clearly DW-relevant.
- **Blasting through a large backlog too fast.** Slow and thorough beats fast and shallow. If you're processing 200+ files in a single run, you're in backlog mode and should be chunking.
- **Skipping the YAML pass.** Frontmatter tags, type fields, and existing routing metadata are strong signals that the title alone misses.
- **Not checking dw_ops.db for dedup.** A file might already be in `research_items` because it was evaluated in a previous research session. Don't re-flag it.
- **Writing frontmatter on non-matches.** Only touch files that matched. The DB tracks everything; the file only needs to know if it matched.
- **Forgetting to update the scan shell.** After writing a new section file, add the embed to the scan log shell if it's not already there.
- **Running cross-project mode on multi-operator projects.** Per-project mode is the default for a reason. Cross-project mode is for solo operators only.

## Principles

- **Slow and thorough over fast and shallow.** A missed gem costs more than an extra scan batch. Budget for quality.
- **Three lenses, not one.** Title, YAML, and content each catch things the others miss. Don't skip passes to save tokens.
- **The 0.0 is the full routing context.** Content Interests are the primary filter, but the whole project context informs judgment.
- **DB for operations, frontmatter for visibility.** Scan state lives in SQLite; match results live in both SQLite and frontmatter. The vault ecosystem sees frontmatter; the scanner sees the DB.
- **Per-project by default, cross-project by choice.** Respect project boundaries. Cross-project scanning is powerful but not always appropriate.
- **Progress survives.** Every batch writes to the DB before finishing. A crashed session loses at most the current batch, never the whole scan.

## Open Questions (S146)

1. **Post-match workflow.** After the scanner tags a file with `content_interest_match`, what's the path to getting it into the project's hands? Options: (a) harvest-router moves matched files into project folders, (b) project instances pick up matches directly via Team Dashboard / Dataview queries without file movement, (c) different paths for backlog mode (report to human review to selective harvest-router) vs. maintenance mode (tag to dashboard to project instance). Likely resolves during first real runs.

2. **Nightly report cadence.** For maintenance mode processing 5-10 files, a full section-file report every night may produce low-signal noise. Consider: nightly scans tag files and update the DB silently, with a weekly rollup report summarizing the week's matches. Daily granularity is in the DB if anyone needs it. The right cadence will become clear once the scanner is running.

3. **YAML scanning signal quality.** Pass 2 (YAML/frontmatter scanning) is designed but untested. The web clipper adds `tags: clippings` by default -- not very useful. If most files in _Clippings have thin frontmatter, Pass 2 adds overhead without much signal. Monitor during the first real run: how often does YAML scanning promote or demote files vs. title scanning alone? If it rarely changes outcomes, simplify to title + content only.

4. **scan_state normalization.** The `matched_projects` column in `scan_state` is a comma-separated string, while `project_relevance` on research items is a properly normalized many-to-many table. If cross-project queries become important (e.g., "show me everything the scanner matched for ReWoven"), the flat string works with `LIKE '%ReWoven%'` but is fragile. Consider normalizing to a join table if the scanner's cross-project mode gets heavy use.

## See Also

- `Workshop/Feature Requests/Content Interest Scanner - Backlog Scan and Nightly Routing Agent.md` -- the feature request with design decisions (D1-D4)
- `Workshop/Design/Research Tracking Database.md` -- dw_ops.db schema, the scan_state table this skill writes to
- `Workshop/Design/Routing Agent and Dynamic Vault Map.md` -- the harvest-router design and dynamic Vault Project Map
- `Workshop/Design/Link Intake Pipeline.md` -- shares the matching logic (Stage 3 classify/route)
- harvest-router skill -- routes individual files; this skill does bulk scanning
- content-interests-review skill -- reviews/updates Content Interests; this skill consumes them
- `Workshop/Feature Requests/Team Attention System - Cross-Pollination and Unread Content Surfacing.md` -- team flags that this skill can auto-set on high-relevance matches
