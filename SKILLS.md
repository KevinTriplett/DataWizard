---
title: DataWizard Skills
type: project-doc
created: '2026-03-26'
updated: '2026-08-31'
edit_log:
  - DW-S250 2026-08-06 - session-closer row + Protocol nudges paragraph updated
    for pending-report model (D114)
  - DW-S270 2026-08-15 - session-closer row bumped to v4.5.0 (stub
    overwrite+rename ceremony)
  - DW-S284 2026-08-24 - session-closer row -> v4.6.1 (row had missed the S272
    v4.6.0 bump); project-reconsolidation row -> v1.3
  - DW-S284 2026-08-24 - meta-learning-review row -> v1.5.0 (was unversioned);
    meta-learning-scan row -> v1.3.1 (was stale at v1.2)
  - DW-S284 2026-08-24 - Skill Format authoring note (0) design-blocked vs
    execution-blocked (S248); session-closer row -> v4.6.2
  - DW-S285 2026-08-24 - meta-learning-review row -> v1.5.1;
    project-reconsolidation row -> v1.4
  - DW-S285 2026-08-24 - meta-learning-review row -> v1.5.2; meta-learning-scan
    row -> v1.4.0 (pattern families)
  - DW-S285 2026-08-24 - project-health-audit row -> v2.1 (J7 pointer status,
    Manual Fallback 7 frontmatter parses)
  - "DW-S283 2026-08-24 - project-reconsolidation row -> v1.5 (Before You Start
    checklist: informal What's-next lists + FR/intake folder status-vs-shipped)"
  - "DW-S291 2026-08-26 - project-reconsolidation row -> v1.6 (Detect Now,
    Repair Later: cheap-disposition-bias guard)"
  - DW-S289 2026-08-26 - session-closer row -> v4.6.3 (Step 4 Tool inventory
    bullet)
  - "DW-S306 2026-08-30 - supervised-build row added (v1.0, new skill: Pattern 4
    codified)"
  - DW-S306 2026-08-30 - session-closer row -> v4.6.4 (row had missed the S303
    bump)
  - "DW-S312 2026-08-30 - S312 Seed review catalog sync: 5 stale version rows
    corrected (block-stamper v2.0, project-guidelines v1.5, garden-synthesis
    v1.1, content-interests-review v1.4.2, supervised-build v1.1); stub labels
    dropped from transcript-harvest + document-harvest rows; corpus-enrichment
    added to the Workshop table; two D114 trigger-language fixes"
  - DW-S309 2026-08-30 - meta-learning-scan row -> v1.4.1, meta-learning-review
    row -> v1.5.3 (synced same-session as the bumps)
  - "DW-S311 2026-08-30 - project-reconsolidation row -> v1.7 (eight-lens batch:
    five-class surface checklist, gated-skill-drafts extension,
    name-match-supersession + instance-vs-Seed fate-split guards, phase-agnostic
    cheap-disposition guard); row taxonomy synced to include 'partitioned'
    (missed at v1.4)"
  - DW-S308 2026-08-31 - session-closer row -> v4.7.0 (Step 4 Operator Gate
    Queue feeding bullet, D126); row description gains the gate-queue clause
  - DW-S313 2026-08-31 - block-stamper row -> v2.1 (manifest-as-you-cite +
    degraded path), synced same-session as the bump
  - DW-S317 2026-08-31 - supervised-build row -> v1.2 (silent-drops probe),
    synced same-session as the bump
---

# DataWizard Skills

Portable skills included in the Seed. Each skill is a folder containing a `SKILL.md` file with instructions that load when triggered. For how-to and reference guides (including the Platform and Environment Behaviors cluster), see `GUIDES.md`.

For how skills work in DW's architecture, see the [Agent and Skills Architecture](https://github.com/andrewalan11/DataWizard) design docs in `Workshop/Design/`.

## Active Skills

| Skill | Type | Description |
|---|---|---|
| **project-guidelines** (v1.5) | Technique | Creating or updating a project's 0.0 Project Guidelines file. Triggers on project setup, migration, or updating the project brief. Handles existing filename conventions gracefully. Includes `last_content_interests_review:` in new 0.0 templates. |
| **session-closer** (v4.7.0) | Technique | Writing the session log entry at the end of every session. Includes Learnings section and handoff-quality "What's next." The session log IS the handoff. Surfaces any pending-review report a scan has left waiting (health audit, meta-learning, Content Interests); it no longer computes staleness or nudges on thresholds -- detection and cadence live in the Review Automation guide. Insight-capture-aware knowledge transfer check. Feeds the project's Operator Gate Queue at close (Registry-canonical schema). |
| **side-quest** (v1.0) | Technique | Tracking a tangent from the project's current arc as a parallel stream in the session log. Routes a side quest's continuation into "Active quest threads" and protects the main arc's "What's next" from being overwritten, so parallel streams don't collide under concurrency. Triggers on: "let's go on a side quest," "continue the [X] side quest." |
| **supervised-build** (v1.2) | Technique | Running a multi-chunk build under a per-chunk review relay with a reviewer instance (Coordination Patterns, Pattern 4). Loads in either seat: the build session gets the review gate as a hard precondition (no chunk written without a `status: reviewed` note - skipping is an on-record choice), the reviewer gets on-disk verification, run-don't-read script testing, and the mandated five-field State Board write so a cold instance can answer "where are we at" from the driver doc alone. |
| **research-tracking** | Technique | Managing research to prevent duplicate work and make past evaluations findable. Tracks evaluations in a tracking index with inline verdicts for light items and links for deeper notes. Always load before starting research. |
| **tools-research** | Technique | Evaluating external tools, repos, frameworks, papers, or flagged content. Gathering-before-judging methodology with single-target, batch triage, and deep-read modes. Batch mode includes harvest pre-filtering and two-speed processing. References research-tracking. |
| **design-harvest** | Technique | Turning research findings into design doc updates, skill refinements, roadmap additions, and guideline improvements. The interpretive bridge between research (facts) and living docs (architecture). Includes target-section overlap check before planting. Completes the research lifecycle: tools-research (evaluate) -> research-tracking (track) -> design-harvest (integrate). |
| **insight-capture** (v1.0) | Technique | Capture and plant insights from loaded context mid-session. When rich context is loaded after deep work, side quests, or design discussions, synthesizes patterns, plants them in the right permanent homes (design docs, build plans, action items, skills, protocol, MOC, decision log), and cross-references for discoverability. Includes a protocol nudge for instances to offer at the right moment. Triggers on: "capture insights," "insight capture," "let's capture," "capture," "squeeze the juice." |
| **garden-synthesis** (v1.1) | Technique | Synthesizing a cluster of related seeds and seedpods into a coherent project concept -- a garden (taxonomy `type: garden`). Reads the seeds, synthesizes vision/model/offerings, researches allies across operator-configured knowledge layers, captures strategic insights (via insight-capture), and tags constituent seeds so membership is queryable vault-wide, with optional planter script and companion Base. Source locations resolve from `Vault Config.md`'s `## Garden Sources` block (git-ignored, per-operator), never hardcoded in a tracked Seed file. Triggers on: 'build a garden', 'synthesize a garden', 're-synthesize the [X] garden'. |
| **meta-learning-review** (v1.5.3) | Technique | Review accumulated session learnings and plant them into skills, design docs, and protocol. Complements design-harvest: design-harvest plants external research findings, meta-learning-review plants operational learnings from session history. Triggered when a pending report is waiting, or on demand. |
| **meta-learning-scan** (v1.4.1) | Technique | Automated scan of session log Learnings sections that produces a structured report for human review. Generates the report; meta-learning-review handles the planting. Use for scheduled meta-learning tasks or on demand before a review. |
| **content-interests-review** (v1.4.2) | Technique | Reviewing and updating a project's Content Interests section in its 0.0 Project Guidelines. Detects drift between what the 0.0 says and what the project is actually doing. Includes outsider readability and consolidation passes to ensure routing-agent-friendly output. Handles shell+sections session logs for mature projects, quest-aware for trajectory signals, and young-project guidance for speculative interests. Feeds the dynamic Vault Project Map. |
| **transcript-harvest** (v0.9) | Technique | Harvesting content from transcripts (video, podcast, meeting, voice memo) into project documents: segmentation, chunk-and-route, block citations, batch mode. |
| **document-harvest** (v0.5) | Technique | Harvesting content from articles, clippings, and web content into project documents: triage-before-fetch, block citations, synth-note fan-out. |
| **content-interest-scan** (v0.1, draft) | Technique | Scan material pools (_Clippings, Recall Vault, transcripts) against a project's 0.0 to surface unrouted content matching project interests. Three-pass scan (title, YAML, content). Two modes: per-project (default) and cross-project. Two scales: backlog (chunked, multi-session) and maintenance (nightly incremental). Depends on dw_ops.db. |
| **harvest-router** | Technique | Scanning the vault for unharvested content and routing it to the right projects. Moves files to correct content folders, sets routing YAML, appends action items. The upstream skill in the harvest pipeline -- it routes, transcript-harvest and document-harvest execute. |
| **block-stamper** (v2.1) | Technique | Stamp block IDs (^bN for documents, ^tN for transcript turns) on the paragraph or turn a citation points to - on-cite, sparse, byte-faithful; any same-vault doc is citable. Batch via stamp_blocks.py (capture the manifest as you cite); degraded path when the script can't run: queue the manifest + `citations: pending-stamp`, never hand-rolled edits or unstamped-anchor citations. Called by the enrichment, harvest, and synthesis passes at cite time. |
| **dw-intro** (v1.0) | Technique | Plain-language introduction to DataWizard: what it is, how the pieces fit together, the five essential practices (Project Instructions, orientation, session closer, DW Save, the approval model), and a skills overview. Called by install-wizard during setup. Also triggers standalone on: 'what is DataWizard?', 'what can DW do?', 'explain DataWizard', 'how does DataWizard work?', 'tell me about DataWizard'. |
| **install-wizard** (v1.3) | Technique | Interactive post-install setup for new DataWizard users. Picks up where the README left off: presents the dw-intro, verifies MCP connection (all tools), guides Project Instructions setup, explains git as the sync/collaboration layer, offers git onboarding. Triggers on: 'set up DataWizard', 'finish DataWizard setup', 'I just installed DataWizard'. |
| **project-health-audit** (v2.1) | Technique | Judgment-half audit of a DW project: consumes the dw_lint report for machine findings (filenames, YAML, sync, links, types), then checks infrastructure completeness (D84), MOC regeneration freshness (D92), shell narrative order, and routes findings. Tiered scopes (Quick/Standard/Full/Incremental); manual fallback for vaults without lint tooling. Triggered via 'DW review' or the review-automation cadence. |
| **project-reconsolidation** (v1.7) | Technique | Periodic reconciliation audit that diffs every record of open work (action items, thread roster or ledger, quest log, dashboard) against recent session-log ground truth, classifies divergences (slipped / stalled / orphaned / done-but-open / contradiction / duplication / model-gap / partitioned), and writes a reconsolidation report. The detection-and-repair complement to the structural Active Threads ledger (D105, D106); audits the tracking model, not just the data. Distinct from semantic divergence-convergence (framing drift). Triggers on 'run a reconsolidation pass', 'reconcile the open work', or a due tracking-health review. |
| **git-onboarding** | Technique | Walking a new collaborator through git setup for a vault or DW project. Gathers variables, guides through setup interactively, sets up DW Save (Cmd+Shift+S) with backup scheduling, and generates a project-specific onboarding guide. Uses the Git Guide (`Seed/Guides/Git Guide.md`) as reference. |

## Knowledge Lifecycle

The knowledge-focused skills form a lifecycle chain. Each covers a different source, timing, and scope, but they all route findings to the same destination types (design docs, skills, protocol, action items):

tools-research (evaluate external things) → research-tracking (prevent duplicate work) → design-harvest (plant research into design docs) → insight-capture (plant mid-session synthesis into permanent homes) → meta-learning-review (plant accumulated operational learnings) → session-closer Step 3.5 (verify everything transferred)

content-interest-scan and harvest-router feed the upstream end by surfacing unrouted content. content-interests-review keeps the routing signals current so the whole chain stays calibrated. S149.

**Protocol nudges** are lightweight behavioral triggers embedded at specific moments in the lifecycle. The three periodic reviews (health audit, meta-learning review, Content Interests) are no longer nudged by session-closer thresholds: scheduled automation detects staleness and produces a pending-review report, and session-closer Step 3.10 only surfaces a report already waiting -- see the Review Automation guide, where the cadence numbers now live (D114). insight-capture has its own nudge for instances to offer mid-session when rich context is loaded. These nudges are a pattern, not a separate skill: a brief conditional check at a decision point that surfaces the right thing at the right time. S149, S157, S250.

## Archived Skills

Retired skills live in the maintainer vault at `Workshop - DataWizard/xArchive - Skills/` (not shipped with the Seed). See there for superseded skill files and history.

## Workshop Skills (DW-Specific)

Skills that depend on DW infrastructure (tracking index, triage docs, two-vault architecture). Not portable to other projects. Live in `Workshop/Skills - DW Workshop/`.

| Skill | Description |
|---|---|
| **dw-research-workflow** | DW-specific research orchestration: Reddit triage campaigns, two-vault architecture, cross-project routing, git repo collection. Layers on tools-research + research-tracking + design-harvest. |
| **batch-triage** | Cluster-level triage with integrated design harvesting. Pre-filters items by harvest potential, runs two-speed evaluation (sweep for dismissals, harvest for design-relevant finds), updates all DW tracking infrastructure in one pass. Layers on tools-research + research-tracking + design-harvest. |
| **corpus-enrichment** (v1.3) | Enrich corpus source articles into structured companion notes (entities, relationships, lexicon candidates, synthesis) for the Rabbit Whole RAG pipeline. The production enrichment path under the Claude-first strategy (D125). Depends on the DW corpus registry and scheduled-task setup. |

## Skill Format

Skills follow the SKILL.md standard: YAML frontmatter with `name` and `description`, markdown body with instructions. Description says WHAT and WHEN (trigger conditions), never HOW (workflow). Body stays under 500 lines. Reference files go in the skill folder one level deep.

Four authoring notes from field use: (0) design-blocked vs execution-blocked -- before deferring a skill because it "needs design", audit whether earlier feature requests, handoffs, and session notes already constitute a complete spec; if they do, the skill is execution-blocked and should be scheduled as a build, not carried as a design question (one skill waited nine weeks on a spec that already existed across four documents; DataWizard, 2026-08); (1) a skill that must work in two contexts -- called during a larger workflow vs invoked standalone -- can carry a "context-specific behavior" section with if-called-during / if-called-standalone rules, rather than duplicating content or splitting into two skills; (2) sequencing trap -- when skill A calls skill B at an early step, B executes before A's later calibration steps have run, so sequence sub-skill calls after the state they depend on (S223); (3) operator-specific paths -- a portable skill that needs vault-specific locations resolves them from a named block in `Vault Config.md` (git-ignored, per-operator), never from a tracked Seed file, which would both leak to other users and be clobbered on update. (S248)

See `Seed/Skills/project-guidelines/SKILL.md` for a well-structured example.
