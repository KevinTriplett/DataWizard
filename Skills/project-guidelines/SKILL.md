---
name: project-guidelines
description: >-
  Use when creating or updating a project's 0.0 Project Guidelines file.
  Triggers on: 'update our 0.0', 'bring project to DW spec', 'project
  migration', 'write project guidelines', 'set up a new project', or any mention
  of 0.0 files needing creation or updates.
---

# Project Guidelines Skill

## Overview

Creates or updates a project's 0.0 Project Guidelines file — the project brief that orients any incoming instance in one read. Covers 9 sections from project identity through Content Interests for routing agent integration.

## When to Use

- A new project needs a 0.0 file
- An existing 0.0 needs updating to current DW spec
- User says "update our 0.0" or "bring this project up to spec"
- A project migration is in progress
- Content Interests section needs writing or updating

### When NOT to Use

- Updating session logs, decision logs, or other 0.x files (those have their own formats)
- Writing project content (articles, design docs, shell files) — this skill is for infrastructure only
- Creating files in other projects' folders without being asked

## Before You Start

1. Read this skill fully
2. Read the project's existing 0.0 if one exists
3. Read the project's session log (last 3-4 entries), decision log, and action items
4. If no 0.0 exists, list the project's home folder to understand what's there

You need a full picture of the project before drafting.

## The 0.0 Sections

Adapt depth to project complexity. Lightweight projects need only 1, 2, 6, 7, 8. Aim for 800-1200 tokens — dense, scannable, cheap to read every thread.

**1. What this project is** — one paragraph. Name, purpose, scope, stage. Self-contained — someone reading only this understands the project.

**2. Current state** — pointer only. "For what's active, read the session log and action items." Don't duplicate status — the 0.0 should be stable across sessions.

**3. Core concepts** — 3-6 ideas/patterns that shape how this project works. The mental model a new instance needs.

**4. Key architecture decisions** — one-liners pointing to decision log. Only the decisions that shape everything.

**5. Stack / instance config** — hardware, models, tools, paths. Label as instance-specific.

**6. Folder structure** — table: folder → purpose.

**7. Key pointers** — canonical docs, config files, repos, URLs.

**8. Working conventions** — project-SPECIFIC rules only. Don't repeat universal protocol.

**9. Content interests** — what a routing agent should flag for this project. "Flag if you see:" list. Be specific to the project's domain — "local TTS models for podcast production" not "AI tools."

The framing varies: tech interests, narrative interests, connection interests, research interests. Whatever fits the project.

### Frontmatter

```yaml
title: Project Guidelines - [Project Name]
type: project-doc
created: YYYY-MM-DD
updated: YYYY-MM-DD
datawizard_protocol_version: "1.7"
project_instructions_version: "2.5"
status: active
```

## How to Draft

**Updating existing 0.0:** Show specific changes in chat. Don't reprint the whole document. Get approval, then write.

**Creating new 0.0:** Share your plan (which sections, rough content) in chat. Get approval, then write directly to vault.

## Common Mistakes

- **Duplicating status in section 2.** Every instance updates it, it drifts, now it contradicts the session log. Just point to the log.
- **Making it too long.** Over 1500 tokens means content belongs in other docs.
- **Including project history.** The 0.0 is "what is this now," not "how did it get here." Session log has the history.
- **Generic Content Interests.** "AI tools" doesn't help routing. "Obsidian plugins for YAML manipulation and bulk operations" does.
- **Copying universal protocol into section 8.** "Write to vault" is universal — don't repeat it here.
- **Empty placeholder sections.** If it doesn't apply, omit it.

## Reference Implementation

See `_DataWizard/0.0 Project Guidelines - DataWizard.md` for a complex project example.

## See Also

- Migration Dashboard — `_DataWizard/! Project Migration Dashboard.md`
- Routing Agent Design — `_DataWizard/Workshop/Design/Routing Agent and Dynamic Vault Map.md`
