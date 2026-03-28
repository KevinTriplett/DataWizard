---
name: transcript-harvest
description: >-
  Use when harvesting content from transcripts into project documents. Triggers
  on: 'harvest from this transcript', 'extract from this recording', processing
  transcripts with harvest_status: pending, or any transcript with harvest_for
  YAML set. Covers video, podcast, meeting, and voice memo transcripts.
type: skill
updated: '2026-03-28'
version: '0.1'
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
2. **Check segmentation** — look for `segmented: true` in YAML. If missing, the transcript needs `##` section headers first. Either run `segment_transcript.py` or add headers manually.
3. **Read the transcript** — understand the full content before extracting anything.
4. **Harvest into destination docs** — synthesize relevant content into project documents. Use citation format: `([[NoteTitle#Section Header|YYYY-MM-DD — Section Name]])`. Don't transcribe — synthesize.
5. **Update source YAML** — set `harvest_status: harvested`, add `harvested_into:` with `[[wikilink]]` to each destination doc, set `harvested_date:`.

## Common Mistakes

- Harvesting without checking segmentation first — citations can't deep-link without `##` headers
- Transcribing instead of synthesizing — one idea per paragraph, don't reproduce the conversation
- Flattening tensions and disagreements — preserve nuance
- Forgetting to update source YAML — the next agent won't know this was already processed
- Processing multiple sources without completing all 5 steps per source first

## Principles

- Treat each source as one atomic unit — complete all five steps before the next source
- Synthesize, don't transcribe. One idea per paragraph.
- Preserve tensions and disagreements — don't flatten nuance.
- Include speaker attribution where relevant.
- Extract `lexicon_candidates` if the transcript contains novel language or framings.

## See Also

- Protocol Section 7 (Editorial Principles)
- Protocol Section 8 (Transcript Preparation)
- Protocol Section 9 (Citations and Source Tags)
