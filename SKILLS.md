---
title: DataWizard Skills
type: project-doc
created: '2026-03-26'
updated: '2026-05-26'
---

# DataWizard Skills

Portable skills included in the Seed. Each skill is a folder containing a `SKILL.md` file with instructions that load when triggered.

For how skills work in DW's architecture, see the [Agent and Skills Architecture](https://github.com/andrewalan11/DataWizard) design docs in `Workshop/Design/`.

## Active Skills

| Skill | Type | Description |
|---|---|---|
| **project-guidelines** | Technique | Creating or updating a project's 0.0 Project Guidelines file. Triggers on project setup, migration, or updating the project brief. |
| **session-closer** | Technique | Writing the session log entry at the end of every session. Includes Learnings section and handoff-quality "What's next." The session log IS the handoff. |
| **research-tracking** | Technique | Managing research to prevent duplicate work and make past evaluations findable. Tracks evaluations in a tracking index with inline verdicts for light items and links for deeper notes. Always load before starting research. |
| **tools-research** | Technique | Evaluating external tools, repos, frameworks, papers, or flagged content. Gathering-before-judging methodology with single-target, batch triage, and deep-read modes. Batch mode includes harvest pre-filtering and two-speed processing. References research-tracking. |
| **design-harvest** | Technique | Turning research findings into design doc updates, skill refinements, roadmap additions, and guideline improvements. The interpretive bridge between research (facts) and living docs (architecture). Includes target-section overlap check before planting. Completes the research lifecycle: tools-research (evaluate) -> research-tracking (track) -> design-harvest (integrate). |
| **meta-learning-review** | Technique | Review accumulated session learnings and plant them into skills, design docs, and protocol. Complements design-harvest: design-harvest plants external research findings, meta-learning-review plants operational learnings from session history. Triggered every 5-10 sessions or on demand. |
| **content-interests-review** | Technique | Reviewing and updating a project's Content Interests section in its 0.0 Project Guidelines. Detects drift between what the 0.0 says and what the project is actually doing. Feeds the dynamic Vault Project Map. |
| **transcript-harvest** | Technique (stub) | Harvesting content from transcripts (video, podcast, meeting, voice memo) into project documents. |
| **document-harvest** | Technique (stub) | Harvesting content from articles, clippings, and web content into project documents. |
| **harvest-router** | Technique | Scanning the vault for unharvested content and routing it to the right projects. Moves files to correct content folders, sets routing YAML, appends action items. The upstream skill in the harvest pipeline -- it routes, transcript-harvest and document-harvest execute. |
| **install-wizard** | Technique | Interactive post-install setup for new DataWizard users. Picks up where the README left off: verifies MCP connection (all tools), guides Project Instructions setup, explains git as the sync/collaboration layer, offers git onboarding. Triggers on: 'set up DataWizard', 'finish DataWizard setup', 'I just installed DataWizard'. |
| **project-health-audit** | Technique | Systematic audit of a DW project against protocol conventions. Checks shell-section drift, YAML compliance, filename safety, infrastructure completeness, and protocol conformance. Tiered scopes (Quick/Standard/Full/Incremental). Triggered manually via 'DW review' or automatically by session-closer every ~10 sessions. |
| **git-onboarding** | Technique | Walking a new collaborator through git setup for a vault or DW project. Gathers variables, guides through setup interactively, sets up DW Save (Cmd+Shift+S) with backup scheduling, and generates a project-specific onboarding guide. Uses the Git Guide (`Seed/Guides/Git Guide.md`) as reference. |

## Archived Skills

Retired skills live in `Workshop/_Archive - Skills/`. See there for superseded skill files and history.

## Workshop Skills (DW-Specific)

Skills that depend on DW infrastructure (tracking index, triage docs, two-vault architecture). Not portable to other projects. Live in `Workshop/Skills - DW Workshop/`.

| Skill | Description |
|---|---|
| **dw-research-workflow** | DW-specific research orchestration: Reddit triage campaigns, two-vault architecture, cross-project routing, git repo collection. Layers on tools-research + research-tracking + design-harvest. |
| **batch-triage** | Cluster-level triage with integrated design harvesting. Pre-filters items by harvest potential, runs two-speed evaluation (sweep for dismissals, harvest for design-relevant finds), updates all DW tracking infrastructure in one pass. Layers on tools-research + research-tracking + design-harvest. |

## Skill Format

Skills follow the SKILL.md standard: YAML frontmatter with `name` and `description`, markdown body with instructions. Description says WHAT and WHEN (trigger conditions), never HOW (workflow). Body stays under 500 lines. Reference files go in the skill folder one level deep.

See `Seed/Skills/project-guidelines/SKILL.md` for a well-structured example.
