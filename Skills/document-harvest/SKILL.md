---
name: document-harvest
description: >-
  Use when harvesting content from articles, clippings, research docs, or web
  content into project documents. Triggers on: 'harvest from this article',
  'extract insights from this doc', processing sources with harvest_status:
  pending, or hand-highlighted documents. NOT for transcripts - use
  transcript-harvest instead.
type: skill
updated: '2026-03-28'
version: '0.1'
---

# Document Harvest Skill

**Status:** STUB — full workflow to be written.

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

*(To be designed — follow the general harvest pattern from transcript-harvest for now, minus the segmentation check)*

1. Check source YAML for harvest status
2. Read the source fully
3. If `highlighted_by_hand: true`, focus on highlighted passages
4. Harvest into destination docs with proper citations
5. Update source YAML

## See Also

- transcript-harvest skill — parallel skill for transcript sources
- Protocol Section 7 (Editorial Principles)
