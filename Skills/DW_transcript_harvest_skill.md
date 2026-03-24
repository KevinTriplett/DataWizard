---
title: Transcript Harvest Skill
type: project-doc
status: stub
created: '2026-03-24'
updated: '2026-03-24'
datawizard_protocol_version: '1.7'
---

# Transcript Harvest Skill

*Skill file for DW agents harvesting from transcripts.*

**Status:** STUB — full workflow to be written. For now, follow this sequence:

## Workflow

1. **Check source YAML** — read `harvest_status`. If already `harvested`, confirm with user before re-harvesting.
2. **Check segmentation** — look for `segmented: true` in YAML. If missing, the transcript needs `##` section headers first. Either run `segment_transcript.py` or add headers manually before harvesting.
3. **Read the transcript** — understand the full content before extracting anything.
4. **Harvest into destination docs** — synthesize relevant content into project documents. Use citation format: `([[NoteTitle#Section Header|YYYY-MM-DD — Section Name]])`. Don't transcribe — synthesize.
5. **Update source YAML** — set `harvest_status: harvested`, add `harvested_into:` with `[[wikilink]]` to each destination doc, set `harvested_date:`.

## Principles

- Treat each source as one atomic unit — complete all five steps before moving to the next source.
- Synthesize, don't transcribe. One idea per paragraph.
- Preserve tensions and disagreements — don't flatten nuance.
- Include speaker attribution where relevant.
- Extract `lexicon_candidates` if the transcript contains novel language or framings.

## See Also

- Protocol Section 7 (Editorial Principles)
- Protocol Section 8 (Transcript Preparation)
- Protocol Section 9 (Citations and Source Tags)
