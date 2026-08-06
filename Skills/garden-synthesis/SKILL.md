---
name: garden-synthesis
description: >-
  Use when a cluster of related seeds and seedpods is ready to be synthesized
  into a coherent project concept -- a "garden" (taxonomy type: garden).
  Triggers on: 'build a garden', 'synthesize a garden', 'let's garden these
  seeds', 'plant a garden', or resuming with 're-synthesize the [X] garden' when
  new seeds have been added. Not for capturing a single note or freshly loaded
  context (use insight-capture), and not for standing up a full project (use
  project-guidelines).
type: skill
created: '2026-08-06'
updated: '2026-08-06'
operator: Andrew
version: '1.1'
edit_log:
  - DW-S248 2026-08-06
  - DW-S249 2026-08-06 - companion-base generator shipped;
    planter/companion-base defaults point at Seed scripts; Step 8 updated
---
# Garden Synthesis Skill

## Overview

A garden is a synthesis note that clusters related seeds and seedpods into a
coherent project concept. It is the intermediate stage between raw seeds and a
fully DW-bootstrapped project: it gathers scattered ideas, synthesizes what they
are saying together, maps allies and existing efforts, and tracks maturity
toward becoming a project. (See the content taxonomy, `type: garden`.)

This skill turns that pattern into a repeatable process: identify a cluster,
read its seeds, synthesize a vision / model / offerings narrative, research
allies across the operator's knowledge layers, capture the strategic insights,
tag the constituent seeds so garden membership is queryable vault-wide, and
optionally generate a live companion view. Gardens are a *synthesis output* --
they are authored, not produced by the enrichment pipeline.

The garden's `## Constituent Seeds` link list is the source of truth for
everything downstream. Because the seeds are already backlinked from the garden,
membership tagging and any live view can be derived from that list rather than
hand-maintained.

## When to Use

Trigger phrases:
- "build a garden" / "let's build the [X] garden"
- "synthesize a garden" / "garden these seeds"
- "plant a garden"
- Resuming: "re-synthesize the [X] garden" (new seeds added since last pass)

Also load this skill, even without the phrase, when several related
seeds/seedpods have accumulated and the user wants to draw them together into a
single named concept with a vision and a sense of who else is working on it.

### When NOT to Use

- Capturing a single insight or synthesizing freshly loaded context mid-session
  -- that is `insight-capture`.
- Standing up a full project (0.0 Project Guidelines, infrastructure) -- that is
  `project-guidelines`. A garden may *mature into* a project; promoting it is a
  separate, deliberate step.
- Routing or harvesting raw source material into a project -- that is
  `harvest-router` and the harvest skills.
- A single seed that needs no synthesis. A garden clusters *several*.

## Source Resolution

This skill is portable: it names *logical roles*, never literal paths. Resolve
each role from the operator's `Vault Config.md` (`Seed/Vault Config.md`), in a
`## Garden Sources` block. Vault Config is git-ignored -- each operator
maintains their own, it is never published to GitHub with the Seed, and
`update_seed.sh` cannot overwrite it (the download does not contain it, so the
copy step leaves it untouched). That makes it both private to the operator's
vault and update-safe: the correct home for user-specific paths.

Never hardcode operator-specific paths into a shared skill or any *tracked* Seed
file. Tracked Seed content is the public, replace-on-update layer; anything
vault-specific placed there both leaks to other users and is clobbered on the
next update. Operator config belongs in `Vault Config.md`.

Roles the skill resolves:

| Role | What it points to | Default if undeclared |
|---|---|---|
| `seed-sources` | Folder(s) where seeds and seedpods live | Ask once |
| `garden-home` | Where garden notes are written | `_Gardens/` |
| `research-layers` | Ordered allies-research layers to sweep | local vault -> archive/transcript store -> web |
| `planter` | Script that stamps `gardens:` onto constituent seeds | the Seed's `Scripts/plant_garden_seeds.py` |
| `companion-base` | Generator for the per-garden live view (`.base`) | the Seed's `Scripts/generate_garden_base.py` |

If the `## Garden Sources` block is missing, ask the operator once for the roles
this run needs, proceed, and offer to record them in `Vault Config.md` so the
next garden is zero-setup. Do not hardcode what they tell you into this skill.

## The Garden Synthesis Flow

### Step 1: Identify and name the cluster
Confirm the seeds/seedpods that belong together and give the garden a short,
stable name (safe characters only -- it becomes a filename and a `gardens:`
value). The name is the handle for resuming and for tagging.

### Step 2: Read the constituent seeds
Resolve `seed-sources` and read each candidate seed/seedpod in full. Note the
through-line: what concept do they collectively point at?

### Step 3: Synthesize the narrative
Write the core synthesis: **vision** (what this wants to become), **model** (how
it works / its logic), and **offerings** (what it provides or produces). This is
the authored heart of the garden -- the part no pipeline can generate.

### Step 4: Research allies and existing efforts
Sweep the `research-layers` in order -- local vault first (what the operator
already knows), then any archive/transcript store, then the web -- for allies,
prior art, and existing efforts related to this concept. Load `research-tracking`
first so past evaluations are reused and this pass is findable later. Keep it
proportional to the garden's maturity.

### Step 5: Write the garden note
In `garden-home`, create the garden note with:
- Frontmatter: `type: garden`, `stage:` (current maturity), `gardeners:` (who is
  tending it), plus standard birth metadata.
- A `## Constituent Seeds` section listing every member as a `[[wikilink]]` --
  the source of truth.
- The synthesis body (vision / model / offerings), an allies / existing-efforts
  section, and a note on maturity and what would move it to the next stage.

### Step 6: Capture strategic insights
Hand the synthesis to `insight-capture` to route any cross-cutting patterns,
gaps, or decision signals into their permanent homes (design docs, action items,
decision log). The garden note holds the concept; insight-capture ensures the
*implications* do not evaporate.

### Step 7: Tag the constituent seeds
Stamp `gardens: [<Garden Name>]` onto every constituent seed so membership is
queryable vault-wide regardless of which folder each seed lives in. If a
`planter` is configured, run it against the garden's `## Constituent Seeds` list
-- dry-run, review the report (added / already / unresolved / ambiguous), then
apply. It must be additive and idempotent (only adds the field/value, never
reorders or removes). If no planter is configured, tag manually -- but tag *all*
members; partial tagging leaves the vault-wide query unreliable.

### Step 8: Companion live view (optional)
Run the `companion-base` generator (the Seed's `generate_garden_base.py` by
default) to create or refresh the per-garden live view -- a `.base` filtered on
`gardens.contains("<Garden Name>")`, giving a "Planted Seeds" table (name /
type / stage) that updates as seeds are tagged. It refuses to overwrite an
existing `.base` unless forced, so hand-customized views are safe. Skip cleanly
if no generator is configured.

### Step 9: Track stage and hand off
Record the garden's `stage:` and, at session close, note remaining work (seeds
still to gather, research layers not yet swept, whether it is approaching project
maturity). Close with `session-closer` as usual.

## Resuming / Re-synthesis

When new seeds have been added to an existing garden:
1. Re-read the garden note and its `## Constituent Seeds` list, plus any newly
   added members.
2. Update vision / model / offerings if the additions shift the concept.
3. Re-run the `planter` (or manually tag) -- idempotent, so it only catches the
   new members.
4. Refresh the `companion-base` if configured.
5. Update `stage:` if maturity changed.

## Common Mistakes

- **Partial seed tagging.** Tagging only a curated subset leaves `gardens:`
  incomplete and the vault-wide query unreliable. Tag every member (the planter
  makes this cheap).
- **Storing operator paths in a tracked Seed file.** Vault-specific locations go
  in `Vault Config.md`'s `## Garden Sources` (git-ignored), never hardcoded in
  this skill or any tracked Seed file.
- **Treating a garden as enriched content.** Gardens are a synthesis output;
  they are authored, not run through the enrichment pipeline.
- **Over-scoping into a project.** A garden clusters and synthesizes; it does not
  stand up project infrastructure. If it has matured, promote it via
  `project-guidelines` as a deliberate, separate step.
- **Letting the Constituent Seeds list drift from reality.** That list is the
  source of truth for tagging and the live view. Keep it complete and accurate;
  derive tagging from it rather than hand-maintaining a parallel record.
- **Skipping insight-capture.** The garden note captures the *concept*; without
  insight-capture the strategic *implications* live only in chat and evaporate.

## Relationship to Other Skills

- **insight-capture** -- routes the cross-cutting implications surfaced during
  synthesis into permanent homes. Called in Step 6.
- **research-tracking** -- loaded in Step 4 so allies research reuses past
  evaluations and stays findable.
- **project-guidelines** -- the next stage if a garden matures into a project.
  Promotion is deliberate and separate.
- **session-closer** -- writes the handoff at close, including the garden's
  remaining work.
- Content taxonomy (`type: garden`) -- the classification and YAML contract this
  skill produces against.
