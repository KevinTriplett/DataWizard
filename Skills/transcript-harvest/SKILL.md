---
name: transcript-harvest
description: >-
  Use when harvesting content from transcripts into project documents. Triggers
  on: 'harvest from this transcript', 'extract from this recording', processing
  transcripts with harvest_status: pending, or any transcript with harvest_for
  YAML set. Covers video, podcast, meeting, and voice memo transcripts.
type: skill
updated: '2026-06-08'
version: '0.6'
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
- Using read-write-delete to relocate a transcript instead of `move_note` -- wastes tokens sending the entire body through the tool call for no content-level reason

## Note Relocation

When a transcript needs to move (e.g., from vault root to a project folder during harvest):

1. Use `move_note` to relocate the file -- this is atomic, zero-token, and preserves wikilinks.
2. Then use `update_frontmatter` or `patch_note` to add/update harvest metadata separately.

Never read-write-delete to move a note. Transcripts can be thousands of words long and the content doesn't change during a move. This rule applies to all note relocations, not just transcripts.

## Routing Patterns

### Research brief as harvest destination

When a transcript contains a researcher's verbal walkthrough of their work -- describing what documents they found, what's in a folder, what seems high leverage -- the harvest output can be the research brief the researcher didn't have time to write. This is especially common in collaborative projects where one person does research and another does synthesis.

The brief becomes a new file (not a patch to an existing doc) with: which documents were mentioned, which ones the researcher flagged as high leverage, and enough context for the next person or agent to know where to start. Tag with `priority: high` and `type: research-brief`.

Example: Weave Session 24 harvested a Kaliya-Andrew call where Kaliya walked through her Exploring Funding research. The harvest output was `Exploring Funding - Research Brief.md` -- the brief Andrew had asked her to write, assembled from her verbal tour.

This pattern applies when: (a) the transcript is someone describing research they've done, (b) no written brief exists yet, (c) the research is in a folder or set of documents that others need to navigate. The brief is a harvest destination alongside the usual synth docs.

## Document Structure Lock

When harvest output requires creating a substantial new document (reconciliation paper, research overview, multi-section analysis, research brief), lock the file structure with the user before writing begins. Use AskUserQuestion (if available) or ask in prose. Key decisions to lock:

- **Document type and posture** -- research brief vs. synthesis doc vs. design doc? Descriptive vs. prescriptive vs. exploratory?
- **Section structure** -- what sections does the user expect? Flat or nested? How granular?
- **Audience** -- is this for the operator, the team, or external readers?
- **Scope ceiling** -- what's explicitly out of scope? Where should you stop?

This applies to new file creation only. Patching existing docs with harvest extracts doesn't need a structure lock -- the structure already exists.

Rationale: document structure, posture, and scope ceiling are expensive to reverse after writing. Locking them upfront with explicit choices prevents rework. (Source: WV-S86 via FR)

## Batch Mode

When processing large transcript batches (total word count exceeding ~50k words, typically 15+ sources), single-agent sequential processing exceeds context capacity and degrades quality. Use parallel subagent extraction instead.

**When to use batch mode:**
- Total word count of routed transcripts exceeds ~50k words
- More than ~10 transcripts need harvesting in one session
- Sources are long-form (conference panels, multi-hour meetings, lecture series)

**Setup:**
- Divide sources into subsets of ~3 files each
- Each subagent receives: its file subset, the project's Content Interests, exact citation format requirements (`[[NoteTitle#Section Header|YYYY-MM-DD -- Section Name]]`), and the list of destination documents
- Subagents run in parallel, each completing Steps 1-6 for their files

**Coordination:**
- A coordinator agent merges results across subagents and deduplicates cross-references
- Citation anchors (section headers, timestamps) must be preserved through the merge -- verify anchors resolve after merge
- The coordinator handles Steps 7-8 (Harvest Ledger, session log) for the full batch

**Validated:** WV-S91 (Katapult batch, 15 transcripts, 5 parallel agents, ~3 files each). Parallel extraction preserved citation fidelity and produced higher-quality extracts than sequential processing under context pressure.

## Principles

- Treat each source as one atomic unit -- complete steps 1-7 before the next source (step 8 waits til session end)
- Synthesize, don't transcribe. One idea per paragraph.
- Preserve tensions and disagreements -- don't flatten nuance.
- Include speaker attribution where relevant.
- Extract `lexicon_candidates` if the transcript contains novel language or framings.

## See Also

- [[Harvest Workflow Guide]] -- full walkthrough with examples and edge cases
- Protocol Section 5 (YAML Schema) -- harvest field definitions
- Protocol Section 7 (Harvest Checklist) -- the 3-step post-harvest checklist
- Protocol Section 8 (Editorial Principles)
- Protocol Section 9 (Transcript Preparation)
- Protocol Section 10 (Citations and Source Tags)
