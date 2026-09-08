---
name: model-casting
description: >-
  Use when planning a research or writing arc that involves more than one
  Claude session or subagent, when deciding which model should do a piece of
  work, or when setting up an automated research pipeline. Triggers on: 'which
  model should do this', 'set up a research batch', 'cast the models', queuing
  work for a later instance where the model choice matters, or any arc that
  ends in a reader-facing document. Complements the Conventions Registry's
  Model routing entry (tier heuristic for queued work); this skill adds role
  casting and execution mechanics.
type: skill
version: '1.0'
created: '2026-09-08'
updated: '2026-09-08'
operator: Andrew
edit_log:
  - "DW-S349 2026-09-08 - v1.0: created from field finding that frontier
    synthesis models write dense, hard-to-read-aloud prose; roles, casting
    table, three execution paths, writer prose-guide mandate"
---

# Model Casting

Different Claude models are good at different things, and the differences do not track "newest is best" for every task. The field finding behind this skill: a frontier-tier model produced an accurate, well-structured research resource that was nearly unreadable when read aloud, while older Opus-line models write noticeably more human prose. Synthesis strength and prose quality are separate axes. So cast models by role, the way a production casts actors, instead of sending one model through the whole pipeline.

This skill defines the roles, holds the current casting in one dated table, and gives three ways to execute the routing. The Conventions Registry's **Model routing** entry stays canonical for the tier heuristic on queued session work (gate rows, What's-next tags stay tier-generic there); this skill is the single home for the version-specific casting, so the Registry's never-pin rule and this table do not fight - queued work names the role or tier, and this table resolves it at execution time.

## The three roles

**Orchestrator-synthesizer.** Plans the arc, decomposes research into subtasks, reviews worker output, does cross-item synthesis, audits, and canon writes. This is where the highest-capability model earns its cost. The orchestrator does NOT draft the reader-facing deliverable.

**Researcher.** The worker-bee seat. Deep reads, source evaluation, evidence gathering, per-item write-ups. Output is a findings note per item: facts, quotes with sources, numbers, open questions. Structured and complete beats polished - no one reads a findings note aloud.

**Writer.** Turns findings notes into the reader-facing deliverable. The writer MUST load `Seed/Guides/Reader-Facing Prose Style.md` before drafting and run its verification pass before shipping. This mandate follows the seat, not the model: if the orchestrator has to write because no writer is available, the guide and its verification pass still apply.

## Current casting

Update the date whenever the table changes; a stale date is the signal to re-check the casting.

| Role | Cast (as of 2026-09) | Why |
|---|---|---|
| Orchestrator-synthesizer | Fable-tier (Claude Fable 5) | Strongest synthesis, review, and multi-perspective judgment |
| Researcher | Claude Opus 4.8 | Strong deep-read and evidence work at lower cost than frontier |
| Writer | Claude Opus 4.6 | Writes the most human reader-facing prose of the current lineup |

Casting is per-vault judgment, not doctrine. Another operator may cast differently; the roles and the mechanics below are the portable part.

## Three execution paths

**Path 1 - same-session subagents (Cowork or any surface with an agent tool).** The orchestrator session spawns subagents for research legs and drafting. Limitation: subagent model choice is family-level only (e.g. "opus", no version pinning), so the writer seat gets whatever the current Opus default is. Acceptable for medium batches where the prose guide plus verification pass carries the writing quality; not the path when exact casting matters.

**Path 2 - Claude Code pipeline (version-exact, automatable).** Claude Code subagent definitions accept exact model IDs in their `model:` frontmatter, and headless calls (`claude -p --model <exact-id>`) pin versions too. Define a researcher agent and a writer agent with their exact casts, run the orchestrator as the main session, and fan researcher subagents out in parallel over a research queue. This is the path for chunking through large research batches unattended. The pipeline design (agent definitions, queue format, runbook) lives in the consuming vault's Workshop as a build charter; this skill owns only the casting contract the pipeline implements.

**Path 3 - manual session relay (any surface, no tooling).** One session per role, model picked by hand in the app's model picker, work handed off through vault notes. Slowest, fully version-exact, and the only path that needs nothing but the app. Use the project's Session Exchange conventions for the handoff notes where they exist.

## Handoffs between roles

The seams are where multi-model work degrades, so keep the interfaces explicit:

- Orchestrator to researcher: a brief per item - the question, why it matters, depth wanted, where the findings note goes.
- Researcher to writer: findings notes plus a one-paragraph writer brief - audience, register, length target, what the document is for. The writer gets facts and framing, never a half-drafted document to polish (rewriting existing prose anchors the writer to its phrasing and the tells survive).
- Writer to orchestrator: the drafted deliverable plus the verification-pass counts from the prose guide. The orchestrator reviews substance against the findings notes before ship.

## When not to use this

A single-session task with no reader-facing deliverable needs no casting - the Registry's tier heuristic answers it in one line. Casting earns its overhead when an arc spans multiple items or sessions, ends in a document a person will read, or runs unattended.

Related: `Seed/Protocols/Conventions Registry.md` (Model routing entry), `Seed/Guides/Reader-Facing Prose Style.md` (the writer mandate), `Seed/Guides/Multi-Instance Coordination Patterns.md` (session-relay transport).
