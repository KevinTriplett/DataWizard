---
name: design-harvest
description: >-
  Use when research findings need to flow into design docs, skills, guidelines,
  or roadmaps. Triggers on: 'act on the integration memo', 'harvest findings
  into design docs', 'what should we update based on this research', 'implement
  what we learned', completing a research deep-read or batch and needing to
  update living docs, or any time research has produced findings that should
  change how the project works.
---

# Design Harvest Skill

## Overview

Turn research findings into design doc updates, skill refinements,
roadmap additions, and guideline improvements. This is the
interpretive bridge between research (which captures facts) and
the living docs that shape how future instances work.

Research notes capture what was found. Design docs interpret it.
This skill is about the interpretation step -- deciding what goes
where, how to frame it for each target, and making sure findings
actually propagate into the documents that instances read.

## When to Use

- After completing a research deep-read or batch that produced
  actionable findings
- After batch triage synthesis -- when patterns emerged across
  multiple evaluated items that are relevant to specific design docs
- When an integration memo exists with a findings-to-design-doc
  mapping table
- When the user says "what should we update based on this"
- When a research note's "Follow-Up Actions" section has items
  tagged as design doc updates
- During a session that started with research and naturally
  transitions into implementation

Design harvest applies to any research output that produces findings
relevant to design docs -- deep-read research notes, batch triage
synthesis, or ad-hoc discoveries. The source format differs but the
five-type classification and placement logic are the same.

### When NOT to Use

- For the research itself (use tools-research)
- For tracking what's been evaluated (use research-tracking)
- For writing new design docs from scratch (that's design work,
  not harvesting)

## The Harvest Loop

### Step 1: Identify the source material

Read the research note(s) being harvested from. Look for:
- Explicit findings-to-design-doc mapping tables (integration memos
  have these)
- "Follow-Up Actions" or "Design Decision Mapping" sections
- Findings tagged with design doc names or decision numbers
- Validated patterns (things that confirm existing choices)
- Identified gaps (things the project should be doing but isn't)
- New concepts worth naming in living docs

If no mapping exists, create one before proceeding. List each
finding and propose where it belongs.

### Step 2: Read each target doc

For every target identified in Step 1, re-read the specific section
that will be updated. Don't rely on memory of the doc from earlier
in the session -- re-read immediately before proposing changes.

Note the chunk-context wrapper principle: when reading each target,
note WHY you're reading it ("Reading this section because Finding X
needs to be added here").

### Step 3: Classify each finding

For each finding, determine what kind of update it requires:

- **Validates existing choice.** Add a "validated by [source]" note
  with the specific evidence. Don't rewrite the section -- anchor
  confidence in the existing decision.
- **Identifies a gap.** Add the gap to the relevant doc with enough
  context that a future instance understands what's missing and why
  it matters. Add an action item if it's actionable.
- **Refines a pattern.** Update the existing description with the
  new nuance or specific numbers. Preserve the original framing;
  enrich it rather than replacing it.
- **Introduces a new concept.** Name it, define it, and place it
  where it will be encountered naturally during orientation or task
  execution. New concepts in design docs that nobody reads are
  wasted -- put them where instances will trip over them.
- **Creates a future action.** Add to action items or roadmap with
  enough context that the item is self-explanatory. Include the
  source research note link.

### Step 4: Draft and propose changes

For each target doc, show the specific changes in chat. Group
changes by target doc so the user can approve per-doc rather than
per-finding.

Present the full scope first: "Based on the research note, I'd
update N docs: [list]. Here are the changes for each." Then walk
through each doc's changes.

### Step 5: Write approved changes

After approval, write changes to each target doc. Re-read the
target immediately before patching (Working Rule 3). Verify success
after each write.

### Step 6: Update cross-references

After writing, check whether new cross-references are needed:
- Research note should link to updated design docs (if it doesn't
  already)
- Updated design docs should reference the research note as source
- If a skill was updated, check if SKILLS.md needs updating
- If 0.0 was updated, consider whether Project Instructions also
  need a version bump

## Target Doc Types

Different target docs have different update patterns:

**Design docs** -- The primary target. Add validated findings,
identified gaps, and new architectural patterns. Preserve existing
structure; add subsections or enrich existing ones rather than
reorganizing.

**Skills** -- Add operational guidance learned from research. New
modes, refined workflows, additional common mistakes, or
cross-references to new resources. Skills are instructions for
action, so frame findings as "when doing X, also do Y" rather than
"research shows that..."

**0.0 Project Guidelines** -- Only for findings that every instance
should encounter during orientation. High bar for additions here --
it should be something that changes how sessions are planned or
how work is approached, not just an interesting finding.

**Roadmaps** -- Add new items or update existing ones when research
reveals capabilities worth building or validates/invalidates a
planned direction.

**Action items** -- Add "Soon" items for follow-up work that the
research surfaced but that doesn't belong inline in a design doc.

## Principles

- **Research findings live where the future work happens, not where
  the research happened.** Research tracking answers "has this been
  evaluated?" The session log captures what happened chronologically.
  Neither is read when starting task-specific work. Design docs are.
  If a finding matters for retrieval, it belongs in the retrieval
  design doc. If it matters for the transcript pipeline, it belongs
  in the transcript spec. This is the core reason design harvest
  exists -- bridging the gap between where research is done and
  where research is needed.
- **Don't duplicate the research note.** The design doc should
  reference the finding and its implication, not reproduce the
  full analysis. Link back to the research note for evidence.
- **Frame for the reader.** A design doc reader wants to know
  "what does this mean for our architecture." A skill reader wants
  to know "what do I do differently." A 0.0 reader wants to know
  "how does this affect my session." Same finding, different framing.
- **Validate, don't just add.** When research confirms an existing
  choice, saying "validated by [source] with [evidence]" is more
  valuable than adding a new section. It builds confidence in
  existing decisions.
- **Preserve the existing voice.** Each target doc has its own
  tone and density. Match it. Don't inject academic language into
  a conversational skill, or casual language into a design doc.

## Common Mistakes

- **Harvesting into research notes.** Research notes capture facts;
  design docs interpret them. If you're adding proposals or
  recommendations to a research note, you're in the wrong file.
- **Updating without re-reading the target.** The target doc may
  have changed since you last read it. Always re-read immediately
  before patching.
- **Adding everything to 0.0.** Most findings belong in design
  docs or skills, not 0.0. The 0.0 is read every session -- only
  put things there that should influence every session.
- **Forgetting to update cross-references.** If a design doc now
  references a research note, the research note should link back.
  Orphaned references are hard to navigate.
- **Losing the source trail.** Every finding added to a design doc
  should be traceable back to the research that produced it.
  Include a "See also: [[Research Note]]" or inline reference.

## See Also

- tools-research skill (produces the research this skill harvests)
- research-tracking skill (tracks what's been evaluated)
- session-closer skill (captures session-level learnings; design-
  harvest captures cross-session architectural findings)
