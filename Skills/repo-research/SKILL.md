---
name: repo-research
description: >-
  Use when evaluating a GitHub repo, external tool, framework, or research
  paper. Triggers on: shared repo URLs, 'check out this repo', 'look into this
  tool', 'what do you think of this project', evaluating external systems
  against current architecture, or any link to a specific project that needs
  depth-first investigation rather than batch triage.
---

# Repo & Tool Research

## Overview

Evaluate a GitHub repo, tool, framework, or research paper in depth. Produce a structured research note capturing architecture, capabilities, and honest relevance assessment for the current project.

This is depth-first investigation of a single target — not batch processing. The value comes from going deep enough to understand *how something actually works*, not just what it claims to do. READMEs are marketing; source code and papers are truth.

## Gathering Before Judging

The most common failure mode is forming an opinion too early and then cherry-picking evidence to support it. The skill is structured to prevent this: the entire first phase is pure information gathering with no assessment. You build the complete picture, then step back and evaluate.

This matters because relevance isn't always obvious from the surface. A tool that seems unrelated might contain a transferable design pattern. A tool that seems perfect might turn out to be architecturally incompatible. You can't know until you've actually looked under the hood.

## Workflow

### Phase 1 — Gather (no opinions yet)

**Start with the primary source.** Fetch the repo URL or project page. Read the full README — not a skim, a full read. Note what it claims to do, the tech stack, license, maturity signals (stars, commits, contributors, last activity).

**Go one level deeper.** READMEs describe intent; source code reveals reality. For code repos, read 2-3 key source files — entry points, core abstractions, the parts that do the interesting work. For papers, read the abstract and search for secondary analysis (blog posts, community discussion) that explains findings in practical terms.

**Gather context.** Search for the project name + key concepts to find blog posts, discussions, related work, author commentary. This surfaces what the README doesn't say — limitations, community reception, how it compares to alternatives.

**Check the supporting material.** Wiki pages, docs folders, example directories, config files. These reveal the real complexity and maturity of a project more honestly than the README.

The goal at the end of Phase 1: you could explain how this thing actually works to someone, not just what it says it does.

### Phase 2 — Assess

Now — and only now — form your assessment. The structure below isn't rigid, but it should cover these dimensions:

**What it is.** One paragraph. What does it actually do, concretely? Avoid repeating marketing language; describe it in your own words based on what you learned in Phase 1.

**How it works.** The architecture. Key components, how they interact, what the data flow looks like. Include specific details from source code or papers — class names, file structures, algorithms. This is what makes the research note valuable months later when someone asks "wait, how did that thing actually work?"

**Key results or capabilities.** What has it demonstrated? For research: benchmark results, claims, transfer experiments. For tools: what can it do, what are the limits, what's the UX like?

**Relevance to current project.** This is the section that earns the research note's place in the vault. Be specific and honest. Organize into:
- *Ideas worth tracking* — transferable design patterns, architectural principles, conceptual resonances. Explain *why* each idea transfers, not just that it exists.
- *Not applicable* — where the tool/approach diverges from current project needs. Be clear about why, not dismissive.
- *Related work in project context* — how does this relate to other tools or systems already being tracked?

### Phase 3 — Write Up

Write the research note directly to the vault. See `references/output-template.md` for the full structure with frontmatter and section guidance.

**Placement:** `_DataWizard/Workshop/Research/[Name] - [Short Description].md`

**Key principles for the writeup:**
- Lead with what the reader needs to understand the system, not with your opinion of it
- Include enough architectural detail that a future instance can understand the system without re-researching it
- The relevance assessment should connect to specific project patterns by name, not vague gestures at similarity
- Note what you *didn't* read (papers not fully read, docs skimmed, areas unexplored) so future researchers know where to dig deeper
- End with clear status: is this research complete, or is there more to extract?

## Calibrating Depth

Not every repo deserves the same investment. Calibrate based on signals:

**Go deep** when: the project addresses a problem the current project is actively solving, the architecture is novel or unfamiliar, the user seems excited about it, or initial signals suggest high-quality engineering.

**Stay moderate** when: the project is in an adjacent space but different paradigm, it's interesting but not actionable, or it's well-documented enough that the README + one key source file tells the story.

**Keep it light** when: the project is clearly a different domain or scale, the user is just curious, or initial investigation reveals it's unmaintained or superficial.

Even at light depth, write the research note. A brief note saying "evaluated, not relevant because X" prevents future re-investigation.

## For Repos with Multiple Interesting Directories

Large repos (like skill collections or framework repos) often have more material than a single pass can cover. When you encounter this:

1. Do a structural scan first — list directories, read the README, understand the organization
2. Identify the highest-value files based on the current research question
3. Read those thoroughly
4. Note what remains unread as "remaining material for future passes"
5. If the material is rich enough, plan the remaining reads as explicit chunks and work through them systematically

This is preferable to trying to read everything in one pass and ending up with shallow coverage across the board.

## Common Mistakes

**Stopping at the README.** READMEs are curated presentations. The source code, papers, and community discussion tell you what actually works. If you haven't read at least a few source files, you haven't researched — you've skimmed.

**Relevance assessment without specifics.** "This is interesting for our project" is useless. "The archive-over-latest pattern in their evolutionary loop mirrors our xArchive approach and validates keeping superseded designs" is useful. Name the specific patterns, decisions, or documents in your project that connect.

**Over-claiming relevance.** Not everything interesting is relevant. A research note that honestly says "fascinating engineering, not applicable to our architecture because X" is more valuable than one that stretches to find connections.

**Forgetting to note what wasn't read.** Future researchers need to know: did you read the full paper or just the abstract? Did you skim the docs or read them thoroughly? Did you check the issues and discussions? A note about coverage prevents wasted re-research *and* prevents over-confidence in incomplete findings.

## See Also

**REQUIRED DISTINCTION:** This skill is for evaluating a *single external repo or tool* in depth. The `research` skill is for *batch processing flagged content from triage reviews* (Reddit posts, clippings, links). If you're working through a triage chunk, use that skill instead.

The harvest skills (`transcript-harvest`, `document-harvest`) are for extracting content from *vault material* into project documents. If the research note itself later becomes a harvest source, use those skills for the extraction pass.
