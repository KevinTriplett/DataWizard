---
name: tools-research
description: >-
  Use when evaluating an external tool, repo, framework, paper, or any technical
  resource. Triggers on: shared URLs, 'research this', 'look into this', 'what
  can you find about', 'check out this repo', 'evaluate this tool', evaluating
  external systems against current architecture, working through a triage list
  of flagged items, or any link or resource that needs investigation. Covers
  both single-target deep dives and batch triage passes.
type: skill
updated: '2026-03-28'
version: '1.2'
---

# Tools Research

## Overview

Evaluate external tools, repos, frameworks, papers, or flagged content.
Produce structured research notes that capture how things actually work
and honestly assess relevance to the current project.

The core principle is **gathering before judging**. The most common
failure mode is forming an opinion too early and cherry-picking evidence.
This skill separates information gathering (Phase 1) from assessment
(Phase 2) to prevent that.

## When to Use

- Evaluating a tool, repo, framework, or paper
- Working through a triage list of flagged items
- User shares a URL and wants to understand what it is
- Deciding whether an external pattern applies to the current project

### When NOT to Use

- Harvesting from vault content (use harvest skills)
- Writing design proposals (research notes capture facts; design docs
  interpret them)

**REQUIRED BACKGROUND:** research-tracking (check tracking before
starting, update tracking after finishing)

## Three Modes

### Single-Target Mode

Someone shares a URL or says "look into this." Follow the full
workflow linearly: read the source, go deep, write the note.

### Batch Triage Mode

Working through a list of flagged items. The rhythm is different:

1. Scan the batch and mentally cluster related items
2. Pre-filter by harvest potential (see below)
3. Read a cluster of related items together, using two-speed
   processing (see below)
4. During reading, harvest standout details (see below)
5. Assess depth for each item in the cluster
6. After the cluster, do a batch synthesis step
7. Write outputs (notes for moderate/deep, inline verdicts for light)
8. Update tracking for the whole batch at once
9. Plant synthesis findings in target design docs (see below)

Batch mode lets you cross-reference items and spot patterns that
individual evaluation would miss.

**Pre-filtering by harvest potential.** Before reading source
material, sort each item into sweep (likely dismiss/validate) vs.
harvest (likely has transferable patterns for design docs). The key
question is "does this change how we build something?" -- not just
"is this relevant?" This reframes triage from relevance assessment
to design impact assessment. Items with harvest potential get read
carefully; sweep items get titles-and-triage-notes-only treatment.
This step saves massive context -- a 30-item cluster might have 6
harvest candidates and 24 sweep items. Ask the user which items
have harvest potential if the batch is large; their domain knowledge
is the best filter.

**Two-speed processing.** Within a cluster, switch between sweep
speed (quick verdict, inline tracking entry, move on) and harvest
speed (extract patterns, identify target design docs, preserve
specific formulations) based on what you find. A sweep item can
escalate to harvest if the source reveals unexpected depth. A
harvest candidate can downgrade to sweep if the source is thinner
than expected. The pre-filter is a starting estimate, not a
commitment.

### Deep-Read Mode

A single source that's too large for one reading pass -- a 5,000-line
guide, a full repo codebase, a long research paper. The rhythm:

1. Scope the source first (table of contents, file structure, README)
2. Identify priority sections based on current project relevance
3. Read in priority order, not linearly
4. Write findings to the research note incrementally as you read each
   section -- don't hold everything in working memory
5. After reading priority sections, write the synthesis (design mapping,
   follow-up actions) while cross-section patterns are fresh
6. Note unread sections for future passes in the research note itself

The key difference from single-target: you're managing your own context
budget across the read. If you have to choose between reading one more
section and writing the synthesis of what you've already read, write the
synthesis. Unread sections can be read later; cross-section patterns
can't be reconstructed.

## The Research Loop

### Phase 1 -- Gather (no opinions yet)

1. **Read the primary source.** Full read, not a skim. Note what it
   claims, the tech stack, license, maturity signals (stars, commits,
   contributors, last activity).
2. **Go one level deeper.** READMEs describe intent; source code reveals
   reality. Read 2-3 key source files, entry points, core abstractions.
   For papers, read the abstract and find secondary analysis.
3. **Follow links.** Check docs, wikis, examples, community discussion.
   After 2-3 failed attempts on a link, note it as unreadable and move on.
4. **Harvest standout details.** While reading, flag specific phrases,
   formulations, failure modes, numbers, or examples that are sharper
   or more concrete than the surrounding text. These go into the
   research note or tracking entry as preserved details, separate from
   the summary. The goal is to keep the gems that would otherwise get
   flattened into a generic assessment.

### Phase 2 -- Assess (now form your opinion)

5. **Calibrate depth** (see below) and decide whether to write a full
   research note or an inline tracking verdict.
6. **Write the output.** See `references/output-template.md` for the
   research note structure. For light evaluations, write an inline
   verdict in the tracking index that captures the assessment plus
   any standout details.
7. **Batch synthesis** (batch mode only). After processing a cluster,
   step back and ask: what patterns emerged across these items? Write
   the pattern where it belongs architecturally -- a design doc, a
   session log learning, a note in a relevant skill. Not in the
   tracking index.
8. **Plant findings in target design docs** (batch mode only). After
   synthesis, identify which design docs each finding is relevant to.
   Write a short dated subsection in each target doc with the specific
   findings and pointers to tracking entries, repos, or source material.
   This is what makes batch research findable when it becomes relevant
   -- a future instance working on that system will read the design doc
   and find the findings waiting there. Without this step, synthesis
   patterns live only in research tracking (an anti-duplication tool,
   not a discovery tool) and session logs (not read during task-specific
   work). Research tracking records WHAT was evaluated. Design docs
   carry WHAT WAS LEARNED. Queued items connect specific resources to
   specific future triggers. All three layers are needed.

## Calibrating Depth

**Deep** -- High relevance or novel architecture. Read everything
including source code. Follow all promising links. If it's a goldmine,
note what remains unread for future passes.

**Moderate** -- Adjacent space, interesting but not immediately
actionable. Full post plus docs, follow 1-2 links. Write a structured
research note.

**Light** -- Different domain or clearly not applicable. 1-2 key points.
Log in tracking with an inline verdict. No full note needed.

Even at light depth, record the evaluation. A brief verdict saying
"evaluated, not relevant because X" prevents future re-investigation.

## Common Mistakes

- **Stopping at the README.** Source code and community discussion tell
  you what actually works. If you haven't gone one level deeper, you've
  skimmed, not researched.
- **Relevance without specifics.** "Interesting for our project" is
  useless. Name the specific pattern, decision, or document it connects to.
- **Over-claiming relevance.** Honest "not applicable because X" is more
  valuable than stretching to find connections.
- **Forgetting to note coverage.** What did you read vs skim vs skip?
  Future researchers need to know where to dig deeper.
- **Synthesizing in research notes.** Facts in research notes, proposals
  in design docs. Keep them separate.
- **Flattening details into patterns.** During batch synthesis, preserve
  the specific formulations and details that make insights concrete.
  "Community validates markdown-first" is less useful than the specific
  failure modes and design constraints people described.
- **Skipping the planting step.** After batch synthesis, findings must
  be planted in the design docs where future work happens. Rich
  tracking entries feel like the work is done, but no one scrolls
  through dozens of tracking rows when starting a new workstream. If a
  finding is relevant to a specific system, it belongs in that system's
  design doc. The principle: research findings should live where the
  future work happens, not where the research happened.

## See Also

- Output template: `references/output-template.md`
- research-tracking skill (tracking evaluations, preventing duplicates)
- design-harvest skill (integrating research findings into design docs,
  skills, and guidelines -- the step after research is complete)
