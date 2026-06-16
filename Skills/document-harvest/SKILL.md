---
name: document-harvest
description: >-
  Use when harvesting content from articles, clippings, research docs, or web
  content into project documents. Triggers on: 'harvest from this article',
  'extract insights from this doc', processing sources with harvest_status:
  pending, or hand-highlighted documents. NOT for transcripts - use
  transcript-harvest instead.
type: skill
updated: '2026-06-13'
version: '0.4'
edit_log:
  - >-
    MMM meta-learning plant 2026-06-09: added Step 3 (triage before fetching),
    renumbered
  - 'DW-S182 2026-06-13: repointed See Also to post-demolition homes (D94)'
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
3. **Triage before fetching** -- when processing a batch of links or sources, do a quick triage pass before committing to full harvest. For each source, check: (a) is it accessible? (paywalled, offline, or auth-gated sources waste context if you try to fetch them), (b) is it already in the vault? (search `_Clippings/` and project folders for existing copies), (c) what format is it? (video, PDF, article, thread -- each requires different handling). This pass takes minutes but can save significant context. In MMM S07, several of Michael Garfield's 8 post-meeting links turned out to be paywalled, already harvested, or video content -- a triage pass would have immediately clarified which sources were actionable.
4. **Read the source fully** -- understand the complete content before extracting anything.
5. **Harvest into destination docs** -- synthesize relevant content into project documents. Use citation format: `([[Source Title#Section|YYYY-MM-DD]])`. If `highlighted_by_hand: true`, focus on highlighted passages first. Synthesize, don't copy -- restate ideas in the voice of the destination document.
6. **Update source YAML** -- set `harvest_status`, `harvested_into` (with section-level anchors), `harvest_date`, and `harvest_notes`. For re-harvests, append to `harvested_into` and convert `harvest_date` to an array (most recent last). Or set `harvest_status: reviewed` with `harvest_notes` explaining why nothing was harvested.
7. **Update Harvest Ledger** -- add or update a row in `0.4 Harvest Ledger - [Project].md` with source, harvest date, destinations, and agent.
8. **Session log** -- add harvest details to `0.2 Session Log.md` at the end of the session as part of normal session logging -- not after each individual source.

## Common Mistakes

- Forgetting to check `harvest_status` before starting -- risks duplicating work or overwriting provenance
- Copying instead of synthesizing -- restate ideas, don't reproduce the source text
- Skipping `harvest_notes` -- the "commit message" is the most valuable part
- Forgetting the Harvest Ledger -- source YAML is the truth, but the ledger is how humans and agents scan routing
- Processing multiple sources without completing steps 1-7 per source first (session log waits til end)
- Skipping the triage pass on link batches -- fetching paywalled or already-harvested sources wastes context and time

## Principles

- Treat each source as one atomic unit -- complete steps 1-7 before the next source (step 8 waits til session end)
- Synthesize, don't copy. One idea per paragraph.
- Preserve tensions and disagreements -- don't flatten nuance.
- Extract `lexicon_candidates` if the source contains novel language or framings.

## Three-Tier Pattern for Complex Web Resources

When documenting a substantial external web resource -- a platform, community archive, toolkit, or any source complex enough that a single note can't capture it -- use a three-tier structure instead of one monolithic doc:

1. **Overview doc** -- what it is, why it matters, who's behind it. The elevator pitch. Stable over time, rarely needs updating.
2. **Catalog doc** -- full inventory of contents (sections, resources, tools available). Factual and comprehensive. Changes when the resource updates.
3. **Mapping doc** -- how the resource connects to our specific project context. This is the analytical layer: what's relevant, what aligns, what diverges. Project-specific, highest editorial effort, and the most valuable of the three.

The mapping doc answers "so what?" for the project. The overview and catalog are reference material; the mapping is working material.

**When to use this pattern:** Not every external link needs three docs. Use it when the resource is complex enough that "what is it," "what does it contain," and "how does it relate to us" are each substantial enough to warrant their own note. A single blog post doesn't qualify; a multi-section platform with dozens of resources does.

**Naming convention:** Use a shared prefix so the three docs cluster together (e.g., `ToGather - Overview.md`, `ToGather - Resource Catalog.md`, `ToGather - ReWoven Mapping.md`).

This pattern emerged from RW S11 (documenting the ToGather platform) and was filed as a DW feature request. (S142)

## See Also

- [[Harvest Workflow Guide]] -- full walkthrough, edge cases, and the 3-step end-of-harvest checklist
- transcript-harvest skill -- parallel skill for transcript sources
- [[YAML Schema]] -- harvest field definitions
- [[Editorial Principles]] -- synthesis guidance
- [[Conventions Registry]] -- citation format
