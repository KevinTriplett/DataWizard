---
name: shared-layer-redaction
description: >-
  Use when moving material about people from a private layer (the vault) into a
  shared layer - a repo or folder readable by the people discussed in it.
  Covers candid retros, 1-1 debriefs, interpersonal feedback, and community
  process notes. Triggers on: 'move this into the shared repo', 'can this go in
  the repo', publishing harvests or syntheses to a shared data corpus, or
  preparing a shared edition of a sensitive note.
type: skill
version: '1.0'
created: 2026-09-04
updated: 2026-09-04
operator: Andrew
origin: 'DW-S330 2026-09-04 - created'
edit_log:
  - 'DW-S330 2026-09-04 - v1.0 created from the field-proven draft (pattern originated RG-S9 2026-09-01; requested via FR); reference section depersonalized per the Seed rule'
---

# Shared-Layer Redaction Skill

## Overview

Shared data corpora need honest accounts of what happened - including hard
truths about how named people acted. But the shared layer's readers usually
include those very people. This skill governs the boundary crossing: what
enters the shared layer, in what form, and by what process - so honesty
survives the trip and nobody gets handed material that reads as "people talked
about me behind my back."

## The two-layer model

- **Private layer**: the operator's vault. Full harvests, per-person
  attributions, verbatim quotes, recording links. Not synced to collaborators.
- **Shared layer**: a repo or shared folder. Everyone with access sees
  everything. Sensitivity labels bound how far a file may travel; they do NOT
  protect people named inside it, because the subjects are among the readers.
  The real gate is what enters at all.

Draft in the private layer; the operator clears; then move. If the shared
layer auto-syncs (DW Save auto-sync or similar), writing a draft into it IS
publishing it.

## The test (run per passage)

Not "transcript vs synthesis" - a summary can be transcript-adjacent. Two
questions:

1. Was the named person in the room when this was said?
2. Is this attributed, quote-level speech - or pattern-level recap?

Pattern-level criticism and feedback about individuals is fine. What stays out
is anything that lets a hurt reader mine who-said-what-about-me: attributed
quotes from private conversations, transcript-adjacent harvests (a 2-minute
round recapped per person), and links into recordings.

## Rules

1. **Strip ALL recording deep links and timecodes** from shared editions - all
   of them, not just those near touchy passages; selective stripping is
   conspicuous. The full link map persists in the private layer.
2. **Feeling-frame subjective claims**: "the feeling that the load fell
   unevenly," not "the load fell unevenly." It eases the reader's nervous
   system if they disagree.
3. **Neutral wording for contested characterizations.** If parties dispute
   whether a "no" was explicit, write "a strong no." Do not adjudicate the
   dispute in a shared document, and do not include the dispute's details.
4. **Soften identifiable inner states**: "pushed the facilitators well past
   capacity," not "collapsed [person]'s nervous system."
5. **No attributed quotes from private 1-1 conversations.** A subject's own
   words about the event (not aimed at a person) ARE quotable from their own
   interview - vivid self-authored images are the best material to keep.
6. **Positive attribution is usually safe, but confirm.** When unsure, de-name
   and offer the operator the option to restore.
7. **Personal life content never enters.** Conversation outside the stated
   scope of a session (someone's life situation, health, family) stays out at
   every level of abstraction - no reworded shape either.
8. **Raw recordings and raw 1-1 transcripts never enter the shared layer.** If
   a group harvest is too attribution-heavy, it stays private and a
   pattern-level distillation goes in its place.
9. **Wikilinks to private-layer notes become plain text** in the shared
   edition - they would dangle, and they name the private files.

## Workflow

1. Read the source in full; classify each passage with the test.
2. Draft the shared edition in the PRIVATE layer.
3. Show the operator the exact lines at issue with proposed rewordings -
   quoted verbatim in chat, not paraphrased.
4. Operator clears. For a 1-1 interview, offer to route the note past its
   subject too - it is their feedback.
5. Apply schema (provenance frontmatter, sensitivity, an origin field
   describing the redaction), then move into the shared layer.
6. A shared edition of a fuller private note gets: "(Shared)" in the filename
   (avoids Obsidian filename-link collisions with the full version), a
   one-line redaction notice under the title, and a Provenance section stating
   that the full material lives in the private layer.
7. Log what was removed or softened in the private layer (edit_log or session
   log), never in the shared file itself.

## When NOT to Use

- Material already public, or whose subjects are not among the shared layer's
  readers - normal harvest rules apply (see transcript-harvest).
- Content with no people in it.

## Common Mistakes

- Treating `internal` sensitivity as protection for named people - it bounds
  distribution, not who inside can read.
- Stripping only the "problematic" timecodes.
- Over-redacting until the honesty is gone. The purpose is hard truths in a
  form that lands: a design lesson ("never spring a new container over a no")
  must survive redaction.
- Drafting directly in an auto-syncing shared folder.
- Replacing a structural lesson with a generic "tensions existed" line - the
  tension's teaching is the payload; keep it, de-personalized.

## Reference Implementation

Field-proven on a community organization's shared event-retro repo (2026-09),
where candid retro and debrief material moved from an operator's private vault
into a repo readable by the people discussed in it. Four shapes the run
produced, one per pattern this skill covers:

- a **pattern-level distillation** entering the repo in place of an
  attribution-heavy group-session harvest that stayed private
- a **moved note**: timecodes stripped, attribution lines softened, Related
  wikilinks converted to a plain-text Provenance section
- a **redacted "(Shared)" edition** of a fuller private note, with one
  attribution-heavy section replaced by a pattern-level summary
- a **pattern-level synthesis written directly from a recording**, with no
  recording link or id anywhere in the repo file

The originating project's operator keeps the named examples in the private
layer; the shapes above are the portable part.

## See Also

- transcript-harvest - harvest mechanics; use this skill on top of it whenever
  the harvest destination is a shared layer
