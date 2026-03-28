---
name: research-tracking
description: >-
  Use when managing research to prevent duplicate work and make past evaluations
  findable. Triggers on: starting any research task (always check tracking
  first), 'have we looked at this before', 'check the tracking index', 'update
  research tracking', completing a batch of evaluations, noticing research notes
  accumulating without a tracking system, or any time you are about to evaluate
  a tool, repo, framework, or external resource.
type: skill
updated: '2026-03-28'
version: '1.1'
---

# Research Tracking

## Overview

Track research evaluations so they compound instead of getting lost.
A tracking index prevents duplicate work, preserves key details from
light evaluations, and makes past research findable when it becomes
relevant. This skill is about the tracking layer, not the research
methodology itself.

## When to Use

- Before starting any research (check if it's already been evaluated)
- After completing research (log what was found)
- When noticing 5+ research notes without a tracking system
- When a user asks "have we already looked at this?"

### When NOT to Use

- For the research methodology itself (how to evaluate, how deep to
  go, how to write research notes). Use tools-research for that.

## The Tracking Index

The tracking index is a single note that serves as the master lookup
for all evaluated items. See `references/tracking-index-template.md`
for the full template and column guide.

**Core columns:** Name, URL, Date, Depth (light/moderate/deep),
Relevance (high/medium/low/none), and Output.

**The Output column** holds either:
- A wiki-link to a full research note (for moderate/deep evaluations)
- An inline 1-3 sentence verdict with key details (for light evaluations)

Inline verdicts should capture both the assessment AND any standout
details -- specific phrases, formulations, or insights worth
preserving even when a full note isn't warranted. The verdict should
always answer: what was it, why didn't it warrant a full note, and
was there any standout detail worth preserving?

## Workflow

### Before Research

Check the tracking index before evaluating anything new. Look in both
the Evaluated table (don't re-research) and the Queued for Review
section (a queued item's trigger may now be active).

### After Research -- Single Target

Add one entry to the Evaluated table. Write the inline verdict or
link the research note in the Output column.

### After Research -- Batch

Hold all tracking updates until the batch is complete. This prevents
context-switching and lets you capture batch-level observations.
Commit all entries to the Evaluated table at once after the batch.

### Where Patterns Go

The tracking index stays at the item level. When a batch reveals
cross-cutting patterns (themes that emerge across multiple items),
write those patterns where they belong architecturally:
- Design docs (if the pattern has architectural implications)
- Session log learnings (if it's a process or tool insight)
- Relevant skill files (if it refines a methodology)

The tracking index can note which items were processed in the same
batch, but the pattern itself lives in a document with more context.
See design-harvest for the full integration workflow.

## When to Create a Tracking Index

You don't need one on day one. Start researching and write notes.
Create the index when you notice yourself wondering "did we already
look at this?" -- that's the signal. Usually around 5+ research notes.

See `references/tracking-index-template.md` for the template.

## Common Mistakes

- **Not checking before researching.** The whole point is preventing
  duplicate work. Always check first.
- **Empty Output for light items.** If an item doesn't warrant a full
  note, the inline verdict IS the output. Don't leave it blank --
  capture why it wasn't worth a note so nobody re-evaluates it.
- **Updating item-by-item during a batch.** Hold updates until the
  batch is done. You'll write better entries with full context.
- **Putting patterns in the tracker.** The tracker is a lookup table.
  Patterns and synthesis belong in design docs or session logs.

## See Also

- Tracking index template: `references/tracking-index-template.md`
- tools-research skill (research methodology that feeds into tracking)
- design-harvest skill (integrating tracked research findings into
  design docs and living project documents)

**REQUIRED BACKGROUND:** tools-research (for the research methodology
that produces the evaluations this skill tracks)
