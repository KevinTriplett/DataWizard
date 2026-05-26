---
name: content-interests-review
description: >-
  Use when reviewing or updating a project's Content Interests section in its
  0.0 Project Guidelines. Triggers on: 'update content interests', 'review
  routing info', 'what should we flag for this project', 'content interests are
  stale', or when a project's scope has shifted and its routing signals need
  refreshing. Also triggered by the scheduled Content Interests audit.
type: skill
version: '1.3'
updated: '2026-05-26'
---

# Content Interests Review Skill

## Overview

Reviews and updates a project's Content Interests section in its 0.0 Project Guidelines. Content Interests tell routing agents (harvest-router, intake pipeline, Reddit triage) what kind of external content is relevant to this project. When Content Interests drift from what a project is actually doing, routing quality degrades — relevant content gets missed, irrelevant content gets flagged.

This skill detects that drift by comparing the 0.0's Content Interests against recent project activity, then proposes an updated version.

## When to Use

- A project's Content Interests haven't been reviewed in 10+ sessions
- A project has no Content Interests section yet
- The project's scope or direction has shifted significantly (new collaborators, new tools, new domains)
- Before a Vault Project Map refresh
- When the scheduled Content Interests audit flags a project as stale
- User says "update content interests," "what should we be flagging for this project," "review our routing info"

### When NOT to Use

- Creating a new 0.0 from scratch -- meaning the 0.0 file itself doesn't exist yet (use project-guidelines instead, it covers Section 9). If a 0.0 exists but has no Content Interests section, this skill is the right one.
- Cross-project audit of all Content Interests (that's the scheduled task's job, not this skill)
- Updating other sections of the 0.0 (use project-guidelines for structural updates)

## Before You Start

1. Read this skill fully
2. Identify the project you're working in and locate its 0.0

## Steps

### Step 1: Read the current 0.0

Read the project's 0.0 Project Guidelines in full. Note:
- Does a Content Interests section exist?
- If yes, what does it currently say?
- What DW protocol version is the 0.0 on?
- When was the 0.0 last updated?

If the 0.0 is missing or on a very old protocol version (below 1.6), flag that to the user as a separate concern. This skill updates Content Interests only — structural 0.0 issues are project-guidelines territory.

### Step 2: Read recent activity

Read the project's recent session log to understand current activity. For projects with a shell+sections session log architecture, start with the shell file -- it gives you section titles and date ranges for the full project history. Then read the last 2-3 section files for detail. For projects with a single session log file, read the last 5-10 entries (or all entries if fewer than 5 exist). For mature projects with 50+ sessions, the shell overview is more valuable than trying to read many individual entries -- you're looking for trajectory and active domains, not exhaustive detail.

You're looking for:

- **New tools, libraries, or technologies** the project has started using or evaluating
- **New domains or topics** the project has expanded into
- **Collaborators or external projects** that have become relevant
- **Research areas** that have been active
- **Design decisions** that shifted the project's technical direction
- **Completed work** that closed off areas (no longer need to flag content for solved problems)

For projects with fewer than ~10 sessions, the session log alone may not reveal much. Lean more heavily on action items, quests, and design docs -- Content Interests may need to be more speculative, covering domains the project intends to explore but hasn't generated session activity in yet.

Also read:
- Action items file (open items reveal where the project is heading)
- Quest log and active quests, if the project uses the quest system (quests show where the project is heading, not just where it's been -- often a better trajectory signal than the session log, especially for young projects)
- Key design docs if they exist (especially recent additions or heavily-edited sections)
- Decision log (last 3-5 entries) if one exists

### Step 3: Compare and identify drift

Compare the current Content Interests (or absence) against what you learned in Step 2. Identify:

- **Missing interests**: Things the project is actively working on that aren't in the Content Interests
- **Stale interests**: Things listed that are no longer relevant (completed, abandoned, or moved to another project)
- **Vague interests**: Terms that are too broad to be useful for routing ("AI tools" instead of "local TTS models for podcast production")
- **New domains**: Entirely new areas the project has moved into since the last update

### Step 4: Draft the updated Content Interests

Write the updated section following the format in the Output Format section below. Don't present this draft to the user yet -- run the quality passes in Step 5 first.

For updates to an existing section, track what was added, removed, or sharpened so you can explain the changes when presenting.

### Step 5: Readability and consolidation passes

Before presenting the draft for approval, run two quality passes:

**Outsider readability pass.** For each specific name, acronym, or shorthand in the draft, ask: "Would a routing agent with no prior project context understand what this refers to?" If not, either wrap it in a concept-level phrase (e.g., "DERR" becomes "decentralized reputation protocols") or replace it entirely. Project-internal shorthand that only makes sense after reading the project's docs is invisible to a routing agent scanning across projects.

**Consolidation pass.** Look for terms that can be grouped under a single concept-level phrase without losing routing precision. Three specific crypto techniques can become "privacy-preserving cryptography"; two related use cases can share a line. The goal is tighter text with the same routing coverage.

Present the cleaned draft to the user with a brief explanation of what changed and why. If the project had no Content Interests section before, note that this is a first draft. For updates to an existing section, show the diff -- what was added, removed, or sharpened. If the readability or consolidation passes made significant changes, note what you collapsed or clarified. Don't reprint the whole 0.0.

### Step 6: Get approval and write

Once the user approves (with any edits), patch the Content Interests section into the 0.0.

- If a Content Interests section already exists, use patch_note to replace it
- If no section exists, use patch_note to append it after the last existing section. Look for the last `## ` heading in the 0.0 and its content, or a version/footer line, and patch after that block. Use the final paragraph of the last section as your anchor -- a long, unique string unlikely to appear elsewhere in the file.
- Bump the `updated:` date in the 0.0's frontmatter

### Step 7: Confirm and note

After writing, verify the patch landed (re-read the relevant section). Note in the session log that Content Interests were reviewed and updated.

If this project's Content Interests feed into the Vault Project Map via embed, the map will auto-update. No separate map update needed.

## Output Format

The Content Interests section uses this structure:

```markdown
## Content Interests

Flag for [Project Name] if you see: [comma-separated list of specific, 
domain-relevant terms and patterns]. [Additional sentences grouping 
related interests or adding context where helpful.]
```

For projects with multiple distinct domains, organize Content Interests into short thematic paragraphs (2-4 sentences each) rather than a single run-on list. Use the first sentence of each paragraph as a category label (e.g., "Funding and organizational models:"). This helps routing agents match on domain clusters, not just individual terms. Single-domain projects should stick with the single-paragraph format above.

### Writing good Content Interests

**Be specific to the project's domain.** "Obsidian plugins for YAML manipulation and bulk operations" routes content accurately. "Obsidian plugins" is too broad — every project could claim that.

**Use concrete nouns and tool names.** "LanceDB, semantic search, RAPTOR chunking strategies" is greppable. "Vector database stuff" isn't.

**Match the project's framing.** Tech projects use tech interests. Creative projects might flag narrative patterns, aesthetic references, or methodology frameworks. Collaboration projects flag governance models, communication tools, or community patterns. Use whatever framing fits.

**Include adjacent domains that feed the project.** A video editing project should flag not just editing tools but also transcription services, asset management, and rendering pipelines — the upstream and downstream of its core work.

**Remove solved problems.** If the project evaluated and chose a transcription service, stop flagging "transcription service comparisons." Flag the next frontier instead.

**Keep it scannable.** Aim for 50-150 words for focused, single-domain projects. For projects that span multiple distinct domains (technical + funding + creative, for example), up to 250 words organized in thematic paragraphs is acceptable. The test is scannability, not word count -- a routing agent should be able to parse it in one pass. If you're in the 150-200 range and every line earns its keep, you're fine -- don't trim for the sake of hitting a number.

### Examples

**Tech-heavy project (DataWizard):**
> Flag if you see: Obsidian plugins (especially vault management, YAML manipulation, Dataview alternatives, bulk operations), local LLM tools and benchmarks (Ollama, Qwen, Llama, Mistral — especially structured output, JSON mode, speed benchmarks on Apple Silicon), MCP servers (new servers, patterns for building them, multi-agent coordination)...

**Creative/media project (VibeCut):**
> Flag for VibeCut if you see: text-based video editing tools, EDL formats and parsers, transcript-to-edit pipelines, AI video understanding (without frame dumping), media asset management with AI (face recognition, visual search, semantic tagging), ffmpeg automation patterns...

**Travel/logistics project (Summer 2026):**
> Flag if you see: European ecovillage networks and gatherings, commons-based governance experiments (especially Valley of the Commons, Commons Hub, P2P Foundation), solarpunk and regenerative nomad communities, retreat centers and co-living spaces in the Alps/Dolomites/Trieste corridor...

## Common Mistakes

- **Copying Content Interests from another project.** Each project's interests should be distinct. If two projects share an interest, one of them probably owns it more — route there.
- **Listing every technology the project uses.** Content Interests is about what external content to flag, not an inventory of the tech stack. Only list technologies where new developments, comparisons, or alternatives would be valuable.
- **Writing interests as tasks.** "Build a transcript parser" is an action item. "Transcript parsing libraries and word-level timestamp formats" is a Content Interest.
- **Using project-internal shorthand.** Acronyms and names that only make sense after reading the project's docs (e.g., "DERR," "BFF," "Sabot") are invisible to routing agents. Wrap insider terms in concept-level descriptions or replace them entirely. If it's not greppable across the internet, it needs context.
- **Forgetting to remove stale items.** Content Interests that reference completed work or abandoned directions create false-positive routing. Prune actively.
- **Making it too long.** Over 150 words for a single-domain project (or over 250 for a multi-domain project) means you're probably including items that belong in action items or design docs, not in a routing signal.

## Relationship to Other Skills and Infrastructure

- **project-guidelines**: Defines the Content Interests format (Section 9). Use project-guidelines for creating a 0.0 from scratch; use this skill for reviewing and refreshing an existing Content Interests section.
- **harvest-router**: Reads Content Interests to decide where flagged content goes. Accurate Content Interests directly improve routing quality.
- **Vault Project Map**: The dynamic map embeds each project's Content Interests section. When you update Content Interests via this skill, the map auto-updates.
- **session-closer**: A future version may include a periodic nudge for Content Interests review (similar to the health audit and meta-learning review nudges).
- **Scheduled Content Interests audit** (planned): Will scan all projects and flag which ones need this skill run. This skill is the per-project executor; the scheduled task is the cross-project scanner.
