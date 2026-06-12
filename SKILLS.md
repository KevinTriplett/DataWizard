---
title: DataWizard Skills
type: project-doc
created: '2026-03-26'
updated: '2026-06-12'
---

# DataWizard Skills

Portable skills included in the Seed. Each skill is a folder containing a `SKILL.md` file with instructions that load when triggered.

For how skills work in DW's architecture, see the [Agent and Skills Architecture](https://github.com/andrewalan11/DataWizard) design docs in `Workshop/Design/`.

## Active Skills

| Skill | Type | Description |
|---|---|---|
| **project-guidelines** (v1.4) | Technique | Creating or updating a project's 0.0 Project Guidelines file. Triggers on project setup, migration, or updating the project brief. Handles existing filename conventions gracefully. Includes `last_content_interests_review:` in new 0.0 templates. |
| **session-closer** (v3.6) | Technique | Writing the session log entry at the end of every session. Includes Learnings section and handoff-quality "What's next." The session log IS the handoff. Periodic threshold nudges for health audit, meta-learning review, and Content Interests staleness -- cadence numbers live in the skill's thresholds step (single source). Insight-capture-aware knowledge transfer check. |
| **research-tracking** | Technique | Managing research to prevent duplicate work and make past evaluations findable. Tracks evaluations in a tracking index with inline verdicts for light items and links for deeper notes. Always load before starting research. |
| **tools-research** | Technique | Evaluating external tools, repos, frameworks, papers, or flagged content. Gathering-before-judging methodology with single-target, batch triage, and deep-read modes. Batch mode includes harvest pre-filtering and two-speed processing. References research-tracking. |
| **design-harvest** | Technique | Turning research findings into design doc updates, skill refinements, roadmap additions, and guideline improvements. The interpretive bridge between research (facts) and living docs (architecture). Includes target-section overlap check before planting. Completes the research lifecycle: tools-research (evaluate) -> research-tracking (track) -> design-harvest (integrate). |
| **insight-capture** (v1.0) | Technique | Capture and plant insights from loaded context mid-session. When rich context is loaded after deep work, side quests, or design discussions, synthesizes patterns, plants them in the right permanent homes (design docs, build plans, action items, skills, protocol, MOC, decision log), and cross-references for discoverability. Includes a protocol nudge for instances to offer at the right moment. Triggers on: "capture insights," "insight capture," "let's capture," "capture," "squeeze the juice." |
| **meta-learning-review** | Technique | Review accumulated session learnings and plant them into skills, design docs, and protocol. Complements design-harvest: design-harvest plants external research findings, meta-learning-review plants operational learnings from session history. Triggered on the session-closer threshold nudge or on demand. |
| **meta-learning-scan** (v1.2) | Technique | Automated scan of session log Learnings sections that produces a structured report for human review. Generates the report; meta-learning-review handles the planting. Use for scheduled meta-learning tasks or on demand before a review. |
| **content-interests-review** (v1.4) | Technique | Reviewing and updating a project's Content Interests section in its 0.0 Project Guidelines. Detects drift between what the 0.0 says and what the project is actually doing. Includes outsider readability and consolidation passes to ensure routing-agent-friendly output. Handles shell+sections session logs for mature projects, quest-aware for trajectory signals, and young-project guidance for speculative interests. Feeds the dynamic Vault Project Map. |
| **transcript-harvest** | Technique (stub) | Harvesting content from transcripts (video, podcast, meeting, voice memo) into project documents. |
| **document-harvest** | Technique (stub) | Harvesting content from articles, clippings, and web content into project documents. |
| **content-interest-scan** (v0.1, draft) | Technique | Scan material pools (_Clippings, Recall Vault, transcripts) against a project's 0.0 to surface unrouted content matching project interests. Three-pass scan (title, YAML, content). Two modes: per-project (default) and cross-project. Two scales: backlog (chunked, multi-session) and maintenance (nightly incremental). Depends on dw_ops.db. |
| **harvest-router** | Technique | Scanning the vault for unharvested content and routing it to the right projects. Moves files to correct content folders, sets routing YAML, appends action items. The upstream skill in the harvest pipeline -- it routes, transcript-harvest and document-harvest execute. |
| **block-stamper** (v1.0) | Technique | Stamp sequential block IDs (^bN for articles, ^tN for transcripts) on source file paragraphs, making them addressable for citations, harvest provenance, and RAG indexing. Run before enrichment or harvesting; called as a prerequisite by the enrichment and harvest skills. |
| **install-wizard** | Technique | Interactive post-install setup for new DataWizard users. Picks up where the README left off: verifies MCP connection (all tools), guides Project Instructions setup, explains git as the sync/collaboration layer, offers git onboarding. Triggers on: 'set up DataWizard', 'finish DataWizard setup', 'I just installed DataWizard'. |
| **project-health-audit** | Technique | Systematic audit of a DW project against protocol conventions. Checks shell-section drift, YAML compliance, filename safety, infrastructure completeness, and protocol conformance. Tiered scopes (Quick/Standard/Full/Incremental). Triggered manually via 'DW review' or by session-closer's threshold nudge. |
| **git-onboarding** | Technique | Walking a new collaborator through git setup for a vault or DW project. Gathers variables, guides through setup interactively, sets up DW Save (Cmd+Shift+S) with backup scheduling, and generates a project-specific onboarding guide. Uses the Git Guide (`Seed/Guides/Git Guide.md`) as reference. |

## Knowledge Lifecycle

The knowledge-focused skills form a lifecycle chain. Each covers a different source, timing, and scope, but they all route findings to the same destination types (design docs, skills, protocol, action items):

tools-research (evaluate external things) → research-tracking (prevent duplicate work) → design-harvest (plant research into design docs) → insight-capture (plant mid-session synthesis into permanent homes) → meta-learning-review (plant accumulated operational learnings) → session-closer Step 3.5 (verify everything transferred)

content-interest-scan and harvest-router feed the upstream end by surfacing unrouted content. content-interests-review keeps the routing signals current so the whole chain stays calibrated. S149.

**Protocol nudges** are lightweight behavioral triggers embedded at specific moments in the lifecycle -- session-closer's threshold nudges for health audit, meta-learning review, and Content Interests staleness (cadence numbers live in session-closer's thresholds step, the single source). insight-capture has its own nudge for instances to offer mid-session when rich context is loaded. These nudges are not a separate skill but a pattern: a brief conditional check at a decision point that surfaces the right skill at the right time. S149, S157.

## Archived Skills

Retired skills live in the maintainer vault at `Workshop - DataWizard/xArchive - Skills/` (not shipped with the Seed). See there for superseded skill files and history.

## Workshop Skills (DW-Specific)

Skills that depend on DW infrastructure (tracking index, triage docs, two-vault architecture). Not portable to other projects. Live in `Workshop/Skills - DW Workshop/`.

| Skill | Description |
|---|---|
| **dw-research-workflow** | DW-specific research orchestration: Reddit triage campaigns, two-vault architecture, cross-project routing, git repo collection. Layers on tools-research + research-tracking + design-harvest. |
| **batch-triage** | Cluster-level triage with integrated design harvesting. Pre-filters items by harvest potential, runs two-speed evaluation (sweep for dismissals, harvest for design-relevant finds), updates all DW tracking infrastructure in one pass. Layers on tools-research + research-tracking + design-harvest. |

## Skill Format

Skills follow the SKILL.md standard: YAML frontmatter with `name` and `description`, markdown body with instructions. Description says WHAT and WHEN (trigger conditions), never HOW (workflow). Body stays under 500 lines. Reference files go in the skill folder one level deep.

See `Seed/Skills/project-guidelines/SKILL.md` for a well-structured example.
