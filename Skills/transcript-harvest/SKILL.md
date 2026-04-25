---
name: transcript-harvest
description: >-
  Use when harvesting content from transcripts into project documents. Triggers
  on: 'harvest from this transcript', 'extract from this recording', processing
  transcripts with harvest_status: pending, or any transcript with harvest_for
  YAML set. Covers video, podcast, meeting, and voice memo transcripts.
type: skill
updated: '2026-04-25'
version: '0.3'
---

# Transcript Harvest Skill

**Status:** STUB — full workflow to be written. For now, follow this sequence.

## Overview

Harvest content from transcripts (video, podcast, meeting, voice memo) into project-specific destination documents. Ensures segmentation, proper citation, and YAML state tracking.

## When to Use

- Processing a transcript that has been flagged for harvesting
- User says "harvest from this transcript" or "extract content from this recording"
- A transcript has `harvest_status: pending` or `harvest_for:` YAML fields set

### When NOT to Use

- Harvesting from articles, clippings, or non-transcript sources (use document-harvest)
- Researching external content (use research skill)
- Segmenting a transcript without harvesting (run `segment_transcript.py` directly)

## Workflow

1. **Check source YAML** — read `harvest_status`. If already `harvested`, confirm with user before re-harvesting.
2. **Check project assignment** — look for `harvest_for` in the transcript's YAML. If missing but the transcript has a `fathom_id`, look it up in `_DataWizard/Workshop/Fathom Meeting Index.md` and check the Project column. If the index has a project assignment, add `harvest_for` to the transcript's YAML before proceeding. If neither the YAML nor the index has a project, ask the user which project this transcript belongs to. Do not harvest without knowing the destination project.
3. **Check segmentation** — look for `segmented: true` in YAML. If missing, the transcript needs `##` section headers first. Either run `segment_transcript.py` or add headers manually.
4. **Read the transcript** — understand the full content before extracting anything.
5. **Harvest into destination docs** — synthesize relevant content into project documents. Use citation format: `([[NoteTitle#Section Header|YYYY-MM-DD — Section Name]])`. Don't transcribe — synthesize.
6. **Update source YAML** -- set `harvest_status`, `harvested_into` (with section-level anchors), `harvest_date`, and `harvest_notes`. For re-harvests, append to `harvested_into` and convert `harvest_date` to an array (most recent last). Or set `harvest_status: reviewed` with `harvest_notes` explaining why nothing was harvested.
7. **Update Harvest Ledger** -- add or update a row in `0.4 Harvest Ledger - [Project].md` with source, harvest date, destinations, and agent.
8. **Session log** -- add harvest details to `0.2 Session Log.md` at the end of the session as part of normal session logging -- not after each individual source.

## Common Mistakes

- Harvesting without checking segmentation first -- citations can't deep-link without `##` headers
- Transcribing instead of synthesizing -- one idea per paragraph, don't reproduce the conversation
- Flattening tensions and disagreements -- preserve nuance
- Forgetting to update source YAML -- the next agent won't know this was already processed
- Skipping `harvest_notes` -- the "commit message" is the most valuable part, especially for `reviewed` or partial harvests
- Forgetting the Harvest Ledger -- source YAML is the truth, but the ledger is how humans and agents scan routing at a glance
- Harvesting without checking project assignment -- content ends up in the wrong project docs or gets orphaned
- Processing multiple sources without completing all 8 steps per source first (session log excepted -- that waits til end)

## Principles

- Treat each source as one atomic unit -- complete steps 1-7 before the next source (step 8 waits til session end)
- Synthesize, don't transcribe. One idea per paragraph.
- Preserve tensions and disagreements — don't flatten nuance.
- Include speaker attribution where relevant.
- Extract `lexicon_candidates` if the transcript contains novel language or framings.

## See Also

- [[Harvest Workflow Guide]] -- full walkthrough with examples and edge cases
- Protocol Section 5 (YAML Schema) -- harvest field definitions
- Protocol Section 7 (Harvest Checklist) -- the 3-step post-harvest checklist
- Protocol Section 8 (Editorial Principles)
- Protocol Section 9 (Transcript Preparation)
- Protocol Section 10 (Citations and Source Tags)
