---
name: document-harvest
description: >-
  Use when harvesting content from articles, clippings, research docs, or web
  content into project documents. Triggers on: 'harvest from this article',
  'extract insights from this doc', processing sources with harvest_status:
  pending, or hand-highlighted documents. NOT for transcripts - use
  transcript-harvest instead.
type: skill
updated: '2026-04-25'
version: '0.2'
---

# Document Harvest Skill

**Status:** Active

## Overview

Harvest content from non-transcript sources — articles, clippings, research docs, web content — into project-specific destination documents. Handles multi-source harvesting, citation tracking, and YAML state management.

## When to Use

- Processing an article, clipping, or document flagged for harvesting
- User says "harvest from this article" or "extract insights from this doc"
- A source has `harvest_status: pending` or `harvest_for:` YAML fields set
- Hand-highlighted sources (`highlighted_by_hand: true`) need processing

### When NOT to Use

- Harvesting from transcripts (use transcript-harvest)
- Researching external content via web (use research skill)
- Classifying or routing content (use classify.py)

## Workflow

1. **Check source YAML** -- read `harvest_status`. If already `harvested`, confirm with user before re-harvesting. If `reviewed`, check `harvest_notes` for the reason before re-opening.
2. **Check project assignment** -- look for `harvest_for` in the source YAML. If missing and the source is not inside a project folder, ask the user which project this belongs to. Do not harvest without a destination.
3. **Read the source fully** -- understand the complete content before extracting anything.
4. **Harvest into destination docs** -- synthesize relevant content into project documents. Use citation format: `([[Source Title#Section|YYYY-MM-DD]])`. If `highlighted_by_hand: true`, focus on highlighted passages first. Synthesize, don't copy -- restate ideas in the voice of the destination document.
5. **Update source YAML** -- set `harvest_status`, `harvested_into` (with section-level anchors), `harvest_date`, and `harvest_notes`. For re-harvests, append to `harvested_into` and convert `harvest_date` to an array (most recent last). Or set `harvest_status: reviewed` with `harvest_notes` explaining why nothing was harvested.
6. **Update Harvest Ledger** -- add or update a row in `0.4 Harvest Ledger - [Project].md` with source, harvest date, destinations, and agent.
7. **Session log** -- add harvest details to `0.2 Session Log.md` at the end of the session as part of normal session logging -- not after each individual source.

## Common Mistakes

- Forgetting to check `harvest_status` before starting -- risks duplicating work or overwriting provenance
- Copying instead of synthesizing -- restate ideas, don't reproduce the source text
- Skipping `harvest_notes` -- the "commit message" is the most valuable part
- Forgetting the Harvest Ledger -- source YAML is the truth, but the ledger is how humans and agents scan routing
- Processing multiple sources without completing steps 1-6 per source first (session log waits til end)

## Principles

- Treat each source as one atomic unit -- complete steps 1-6 before the next source (step 7 waits til session end)
- Synthesize, don't copy. One idea per paragraph.
- Preserve tensions and disagreements -- don't flatten nuance.
- Extract `lexicon_candidates` if the source contains novel language or framings.

## See Also

- [[Harvest Workflow Guide]] -- full walkthrough with examples and edge cases
- transcript-harvest skill -- parallel skill for transcript sources
- Protocol Section 5 (YAML Schema) -- harvest field definitions
- Protocol Section 7 (Harvest Checklist) -- the 3-step post-harvest checklist
- Protocol Section 8 (Editorial Principles)
