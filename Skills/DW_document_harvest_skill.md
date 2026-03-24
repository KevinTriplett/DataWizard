---
title: Document Harvest Skill
type: project-doc
status: stub
created: '2026-03-24'
updated: '2026-03-24'
datawizard_protocol_version: '1.7'
---

# Document Harvest Skill

*Skill file for DW agents harvesting from articles, clippings, and other documents.*

**Status:** STUB — full workflow to be written. For now, follow this sequence:

## Workflow

1. **Check source YAML** — read `harvest_status`. If already `harvested`, confirm with user before re-harvesting.
2. **Read the document** — understand the full content before extracting anything.
3. **Identify relevant projects** — check `harvest_for:` in YAML. If absent, assess which projects the content is relevant to and confirm with the user.
4. **Harvest into destination docs** — synthesize relevant content into project documents. Use citation format with wikilinks back to source. Don't copy — synthesize.
5. **Update source YAML** — set `harvest_status: harvested`, add `harvested_into:` with `[[wikilink]]` to each destination doc, set `harvested_date:`.

## Principles

- Treat each source as one atomic unit — complete all five steps before moving to the next source.
- Synthesize, don't copy. Reframe content in the language and context of the destination project.
- One source may produce harvests for multiple projects — that's expected.
- Extract `lexicon_candidates` if the document contains novel language or framings.
- For `resource` and `resource-list` types, also extract URLs for the scrape queue.

## See Also

- Protocol Section 7 (Editorial Principles)
- Protocol Section 9 (Citations and Source Tags)
