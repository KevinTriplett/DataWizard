---
title: Harvest Workflow Guide
type: guide
created: '2026-04-25'
updated: '2026-04-25'
status: active
tags:
  - protocol
  - harvesting
  - DataWizard
---

# Harvest Workflow Guide

*A practical walkthrough of harvesting content from source material into project documents. For the full design rationale, see [[Harvest Provenance Architecture]].*

## What Harvesting Is

Harvesting means reading a source file (transcript, article, clipping, contributor document) and synthesizing relevant content from it into project documents. The source is the origin; the project document section is the destination. "Synthesize" is the key word -- don't transcribe or copy, extract the ideas and restate them in the voice of the destination document.

Enrichment (creating companion notes via the pipeline) is also a form of harvesting. Both pipeline enrichment and manual harvest use the same YAML tracking. The `c_` prefix on companion links distinguishes pipeline output from manual harvest in the `harvested_into` array.

## The Three Provenance Layers

Harvest provenance lives in three places, each at a different zoom level:

| Layer | Where | What it records | Analogy |
|---|---|---|---|
| **Source YAML** | Frontmatter on each source file | Machine-queryable state and routing | The database |
| **Harvest Ledger (0.4)** | One file per project | Scannable routing index | `git log --oneline` |
| **Session Log** | Session log entries | Full narrative with editorial context | `git log -p` |

The source YAML is the single source of truth. The ledger is a convenience view. The session log is the full story. If the ledger disappeared, nothing would be lost.

## Before You Harvest

### 1. Check source status

Read the source file's YAML frontmatter. Look at `harvest_status`:

- **Field absent:** Untouched. Proceed.
- **`pending`:** Flagged for harvest. Proceed.
- **`harvested`:** Already processed. Check `harvested_into` to see where content went. Confirm with the user before re-harvesting.
- **`reviewed`:** Read but nothing was worth harvesting. Check `harvest_notes` for the reason. Confirm before re-opening.
- **`superseded`:** Replaced by a newer version. Find the newer version instead.

### 2. Check project assignment

Look for `harvest_for` in the source YAML. This tells you which project(s) the content belongs to.

- If `harvest_for` is set, you know the destination project.
- If missing but the source has a `fathom_id`, look it up in the Fathom Meeting Index and check the Project column.
- If neither exists and the source is in a project folder, the project is implicit.
- If none of the above, ask the user which project this source belongs to. Do not harvest without a destination.

### 3. Check segmentation (transcripts only)

For transcripts, look for `segmented: true` in YAML. If missing, the transcript needs `##` section headers before harvesting -- these are citation anchor points. Either run `segment_transcript.py` or add headers manually.

## During the Harvest

### Read first, then synthesize

Read the entire source before extracting anything. Understand the full context, then synthesize -- one idea per paragraph, in the voice of the destination document.

### Citation format

Use wikilink citations with section anchors: `([[Source Title#Section Header|YYYY-MM-DD]])`. This creates a clickable trail from idea back to source.

### Editorial principles

- Synthesize, don't transcribe. Restate ideas; don't reproduce the conversation.
- Preserve tensions and disagreements. Don't flatten nuance.
- Include speaker attribution where relevant.
- Extract `lexicon_candidates` if the source contains novel language or framings.
- For sources with `highlighted_by_hand: true`, focus on highlighted passages first.

## After the Harvest -- The 3-Step Checklist

A harvest is not complete until all three steps are done for each source. Treat each source as one atomic unit -- complete all steps before moving to the next source.

### Step 1: Update Source YAML

Set the four harvest fields on the source file:

**Before:**
```yaml
type: meeting-transcript
harvest_for: Weave
segmented: true
```

**After (first harvest):**
```yaml
type: meeting-transcript
harvest_for: Weave
segmented: true
harvest_status: harvested
harvested_into:
  - "[[c_2026-03-31 Kevin-Andrew-Jay]]"
  - "[[Codex#Section XIV]]"
  - "[[Story Bible#4.0 Bonding Curves]]"
harvest_date: 2026-04-25
harvest_notes: "Initial harvest. Extracted ARG tech stack framing and bonding curves discussion. Filtered interpersonal sidebar."
```

**After (re-harvest):**
```yaml
harvest_status: harvested
harvested_into:
  - "[[c_2026-03-31 Kevin-Andrew-Jay]]"
  - "[[Codex#Section XIV]]"
  - "[[Story Bible#4.0 Bonding Curves]]"
  - "[[ReWoven Vision#3.0 Governance]]"
harvest_date:
  - 2026-04-25
  - 2026-05-10
harvest_notes: "Supplemental harvest for ReWoven. Original harvest was Weave-focused."
```

When re-harvesting, append to `harvested_into` rather than replacing it. Convert `harvest_date` to an array with the new date appended (most recent last). This preserves the full trail of when the source was touched.

For sources with nothing to harvest:
```yaml
harvest_status: reviewed
harvest_date: 2026-04-25
harvest_notes: "Read in full. Content is operational planning with no harvestable material for project docs."
```

### Step 2: Update the Harvest Ledger

Add a row to `0.4 Harvest Ledger - [Project].md` in the appropriate source type section:

```markdown
## Transcripts

| Source | Harvest Date | Destinations | Agent |
|---|---|---|---|
| 2026-03-31 Kevin-Andrew-Jay | 2026-04-25 | Codex XIV; Story Bible 4.0 | Claude |
```

If the ledger doesn't exist yet, create it using the template from the Harvest Provenance Architecture design doc. Group by source type from day one: Transcripts, Articles and Clippings, Contributor Documents, Pending.

The Pending section doubles as a lightweight harvest queue:

```markdown
## Pending

| Source | Type | Likely Destinations | Notes |
|---|---|---|---|
| 2026-04-10 Design Review | transcript | Codex, Story Bible | Has harvest_for: Weave |
```

### Step 3: Session Log

Add harvest details to `0.2 Session Log.md` at the end of the session as part of normal session logging -- not after each individual source. The harvest narrative is part of the session entry, not a separate log.

## Edge Cases

### Re-harvesting a source

When returning to a previously harvested source (e.g., a supplemental pass or new project assignment), append to `harvested_into` rather than replacing it. Convert `harvest_date` to an array with the new date appended (most recent last). Add context in `harvest_notes` explaining why the source was revisited.

### Multi-project sources

Sources with `harvest_for: [ProjectA, ProjectB]` need harvest into each project's documents. A source is only fully harvested when `harvested_into` covers all projects listed in `harvest_for`. Update the ledger in each project.

### Companion-only enrichment

A companion note (`c_` prefix) is a separate AI-generated note containing enrichment output -- summaries, tags, themes, lexicon candidates -- for a source file. Companions live in `_Companions/` with mirrored subfolder structure and are created by the enrichment pipeline. Source files are never modified except for YAML updates and transcript section headers; all synthesis goes in the companion. See the Companion Notes section of your project's 0.0 Guidelines or Protocol Section 5 (YAML Schema) for the full companion note architecture.

When the pipeline creates a companion note but no manual harvest into project docs happens, the source YAML still gets updated (`harvested_into` includes the `c_` link, `harvest_status: harvested`). But the ledger does NOT get a row -- the ledger tracks project-document routing, not companion creation.

### The companion: field

The `companion:` field on source files and the `c_` entry in `harvested_into` are partially redundant. Both are valid. `harvested_into` is the canonical routing record; `companion:` is a convenience for pipeline scripts that need quick companion lookup.

## Related Documents

- [[Harvest Provenance Architecture]] -- full design rationale
- Protocol Section 5 (YAML Schema) -- field definitions
- Protocol Section 6 (Log Discipline) -- ledger rules
- Protocol Section 7 (Harvest Checklist) -- the 3-step checklist
- Protocol Section 8 (Editorial Principles) -- synthesis guidance
- transcript-harvest skill -- workflow for transcript sources
- document-harvest skill -- workflow for non-transcript sources
