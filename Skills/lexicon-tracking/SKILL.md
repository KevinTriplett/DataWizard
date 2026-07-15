---
name: lexicon-tracking
description: "Use when building or maintaining a project's living
  lexicon/glossary of the team's distinctive spoken language, and when tracking
  how key terms evolve over time. Triggers on: 'do a lexicon pass', 'update the
  lexicon', 'track our language', 'build the glossary from transcripts', a
  transcript-wide language review, or a request for how a term's framing changed
  across sessions. Complements transcript-harvest (which flags
  lexicon_candidates inline); this skill is their downstream home plus the
  evolution-tracking layer."
type: skill
created: 2026-07-15
updated: 2026-07-15
operator: Andrew
generating_agent: Claude (Andrew)
version: "0.1"
status: draft
edit_log:
  - RW-S38 2026-07-15 first draft from the ReWoven transcript-wide lexicon pass;
    to be pressure-tested next session
---

# Lexicon Tracking Skill

**Status:** v0.1 DRAFT (RW-S38). First-drafted from the ReWoven transcript-wide lexicon pass; not yet pressure-tested. Review before relying on it.

## Overview

Build and maintain a project's **living lexicon**: a curated glossary of the team's distinctive spoken language - the coinages, phrases, metaphors, frames, and one-liners that emerge in the founders'/team's own speech - and track how those terms **evolve over time**. The premise: in voice-driven projects the team's spoken language is load-bearing in written copy, so real spoken phrases beat generated substitutes, and knowing a term's arc (its rough early form, the moment it was corrected or renamed, its crystallized version) keeps derived copy honest.

This skill is the downstream home for the `lexicon_candidates` that transcript-harvest flags inline, plus the evolution-tracking layer harvest doesn't cover. It does not replace harvesting; it runs alongside or after it.

## When to Use

- "Do a lexicon pass," "update the lexicon," "build the glossary from the transcripts," "track how our language is evolving."
- After a harvest, to route the transcript's `lexicon_candidates` into the living glossary.
- A retrospective transcript-wide review to build or refresh a glossary and its evolution timeline.
- When someone asks how a term's framing changed across sessions (e.g. "when did we drop 'flywheel'?").

### When NOT to Use

- Harvesting substantive content from a transcript into project docs (use transcript-harvest; this skill handles only the language layer).
- Copy-editing or de-AI-ing a finished draft (use the project's editorial guidance).
- Capturing a single quote in passing - just add it to the glossary directly; a full pass is overkill.

## Two Modes

**Mode A - Inline (per transcript).** Lightweight. During or right after a harvest, take the transcript's `lexicon_candidates`, dedup them against the current glossary, and add the net-new ones. Watch for evolution signals (below) and append a trace line to any existing term that shifted. Minutes, not a session.

**Mode B - Retrospective pass (transcript-wide).** Heavier. A pass over many transcripts to build or refresh the glossary and produce/update an evolution timeline. Context-hungry; usually its own session, and usually parallel subagents (see Batch Mode). This is where evolution arcs are actually assembled, because you need the whole span in view.

## Workflow (Mode B, the full pass)

1. **Lock scope.** Decide *whose* language the lexicon captures and *which* sources are in scope before extracting. Options: the founder dyad only, the whole team, external partners included. Narrowing to the core voices (e.g. the two founders) usually sharpens the glossary - multi-party logistics calls dilute it. Confirm with the operator.
2. **Locate the two destinations.** The **living glossary** (a curated doc, often `maturity: living`, e.g. a "Lexicon, Imagery and Framing" section) and the **evolution timeline** (a companion working doc). Read the current glossary in full - you need its term list for dedup and its section structure for routing.
3. **Batch chronologically.** Group sources into time batches (early / middle / recent), ~3 files each. Chronological batching is what makes evolution legible - do not split purely by count the way a harvest batch does.
4. **Extract per batch** (parallel subagents for large spans - see Batch Mode). Each extractor gets: its file subset, the current glossary term list (for dedup), the extraction schema, and the evolution-signal heuristic. Each writes a **staging note** (one per batch) - do not write to the glossary yet.
5. **Synthesize.** Read the staging notes together. Assemble the evolution arcs across batches (this is cross-batch work the extractors cannot do alone). Draft: (a) net-new additions grouped by the glossary's existing categories, and (b) the evolution timeline entries.
6. **Review before writing.** Present the additions and arcs to the operator. The glossary is curated - confirm whether to add a curated subset or everything-for-later-pruning.
7. **Write.** Add net-new gems to the glossary (as a clearly-marked, dated additions block if adding wholesale, so pruning is easy). Write/update the evolution timeline. Keep the staging notes as the raw record - do not delete them.
8. **Metadata + provenance.** Set `updated` and append `edit_log` on every doc touched. Cite source transcript + date on gems; use block-stamper for turn-level citations when a phrase points at a specific transcript turn.

## Extraction Schema

For each item, capture:

- **Term/phrase** - verbatim; wrap spoken lines in quotes. Never paraphrase - the verbatim line is the whole point.
- **Speaker** - who said it (or "co-created" if built live between speakers).
- **Source** - transcript + date (first appearance within the batch).
- **Category** - match the target glossary's sections (e.g. Name/Heart, Problem Language, Core Frame, Pathway, Metaphor/Imagery, One-Liner, Usage Note).
- **Gloss** - 1-2 sentences of meaning/context.
- **Status vs. current glossary** - one of: NEW (not present) / ALREADY-IN-GLOSSARY / EARLIER-FORM-OF: `<term>` (a rougher precursor of an existing term) / REFINED-FORM-OF: `<term>` (a later phrasing that sharpens or replaces one).
- **Evolution note** - any in-transcript correction, coining, renaming, or retirement.

For what qualifies as a keeper phrase in the first place, use transcript-harvest's **"What Makes a Good Lexicon Candidate"** criteria - do not restate them here.

## Evolution Signals (the highest-value catch)

Terms are *born* at moments of correction and naming, not in steady use. Watch especially for:

- **Correction language:** "it's not X, it's Y," "actually it's more like...," "I heard you about the word X."
- **Coining language:** "let's call it...," "the word is...," someone supplying a missing term ("The artifact, thank you").
- **Retirement/demotion:** a term explicitly set aside ("X is an organ, but it's not the heart").
- **Renaming referenced as already underway:** "I already started saying Y instead of X on the website."
- **External feedback triggering a shift:** a collaborator flags a word; the team reframes in response.

When you catch one, record both endpoints (the before and the after phrasing, each with speaker and date) - that pair *is* the evolution arc. These moments are worth flagging even in Mode A.

## Batch Mode (large passes)

For a transcript-wide pass whose total span is large (roughly >25k words or >6 sources), use parallel subagent extraction rather than one sequential read - the mechanics mirror transcript-harvest's Batch Mode (subset ~3 files, parallel extractors, a coordinator merges), so follow that section and layer these lexicon-specific deltas:

- **Batch by chronology, not just count** - so the coordinator can see evolution across batches.
- **Give every extractor the same current-glossary term list** - consistent dedup and consistent EARLIER/REFINED-FORM-OF tagging.
- **Each extractor writes a staging note; the coordinator (you) does the cross-batch evolution synthesis** - individual extractors only see their slice and cannot assemble arcs.
- **Sonnet subagents are appropriate** for the extraction pass; the synthesis and glossary-merge judgment stays with the primary agent.

## Outputs

- **The living glossary** - stays curated. When adding wholesale for later pruning, isolate the new material in a dated, labeled additions block rather than interleaving unproven entries into the curated sections.
- **The evolution timeline** - a companion doc; one section per arc, each with dated verbatim stages (rough form -> pressure/coining moment -> crystallized form). Link it from the glossary; do not duplicate full arcs into the glossary (link, don't restate).
- **Staging notes** - the raw per-batch record. Kept, not deleted - they hold the long tail the curated glossary omits and the provenance for future prunes.

## Principles

- Verbatim over paraphrase. Capture the exact spoken line with attribution.
- Curate the glossary, hoard in staging. The glossary is a working reference, not a dump; the staging notes are the archive.
- Precursors that did not survive compression are still valuable - they often carry emotional register the final form drops. Keep them in the timeline.
- Frame toward what a term *is*, not what it opposes (a lesson the lexicon itself should model).
- Provenance always: source + date, turn-level via block-stamper when the claim is turn-specific.

## Common Mistakes

- Paraphrasing a spoken line - destroys the one asset the skill exists to preserve.
- Splitting a retrospective pass by file count instead of chronology - makes evolution arcs invisible.
- Extractors asserting evolution arcs from a single batch - arcs are cross-batch; only the coordinator has the span.
- Dumping every candidate into the curated glossary - bloats it; use a marked additions block for wholesale adds.
- Deleting staging notes after the merge - they are the raw record and the provenance for pruning.
- Forgetting to feed extractors the current glossary term list - produces duplicate entries and inconsistent dedup tags.
- Not updating `updated`/`edit_log` on the glossary and timeline after writing.

## See Also

- [[transcript-harvest]] - upstream: flags `lexicon_candidates` inline, defines candidate criteria, and the Batch Mode mechanics this skill layers on.
- [[block-stamper]] - turn-level citation IDs for provenance.
- The project's living glossary doc (e.g. a "Lexicon, Imagery and Framing" section) and its evolution timeline companion.
- [[Conventions Registry]] - citation format and source tags.
