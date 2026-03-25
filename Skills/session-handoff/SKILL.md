---
name: session-handoff
description: >-
  Use when wrapping up a session to write a handoff briefing for the next
  instance. Triggers on: 'prepare a handoff', 'write a handoff', 'wrap up and
  set up next session', 'let's close out', end of session when work will
  continue. Also use when switching to a different instance mid-session for a
  specific task.
---

# Session Handoff Skill

## Overview

Writes a handoff briefing at the end of a session that enables a fresh instance to start productive work immediately. The handoff captures the outgoing instance's deep context and translates it into actionable instructions for the incoming instance.

## When to Use

- End of a session when work will continue in a new thread
- User says "let's wrap up," "prepare a handoff," "write a handoff for next session"
- User says "we're done for now, set up the next instance"
- Mid-session if the user wants to switch to a different instance for a specific task

### When NOT to Use

- Updating the session log (that's a separate step — do both, but they serve different purposes)
- Writing action items (those are strategic; handoffs are tactical and session-specific)
- The user just wants to stop without continuing later

## The Difference Between Session Log and Handoff

The **session log "What's next"** is a persistent vault record written for any future instance. It's part of orientation — read every time a thread starts.

The **handoff briefing** is a chat message the user pastes into a specific new thread. It's richer, more tactical, and targeted at the exact work the next instance will do. It goes beyond "What's next" by including:

- Specific file paths to read first (not just topic names)
- Framing and context that explains WHY this work matters now
- The causal chain — what depends on what, in what order
- Task-specific instructions the session log doesn't carry

Think of it this way: the session log is the public calendar. The handoff is the pre-meeting brief.

Both should be written at end of session. They're complementary, not redundant.

## How to Write a Handoff

### Step 1: Identify the work type

The handoff format varies by what the next instance will be doing:

**Research / harvest task:**
- Specific files or repos to read, in priority order
- What to extract from each source
- Where to write the output
- How this connects to previous research (what's already been done, what's new)
- What "thorough" means for this specific task

**Migration / build task:**
- Which project or component
- What spec or skill to follow
- What the test case is and what success looks like
- What constraints or prior decisions to respect

**Design / architecture task:**
- What's being designed and why now
- What prior decisions constrain the design space
- Which design docs to read for context
- What the deliverable is

**Debugging / troubleshooting task:**
- What's broken and how it manifests
- What was already tried and what happened
- Where the error logs or evidence are
- What the user thinks might be going on

### Step 2: Write the briefing

Structure it as a message the user can paste directly into a new thread. Keep it conversational but information-dense. Include:

1. **One-sentence context** — what just happened and why we're handing off
2. **The task** — what the next instance should focus on, framed as a clear goal
3. **Specific starting points** — exact file paths, not just topic names. The instance should be able to start reading immediately without searching.
4. **Prioritization** — what's the main focus vs side tasks. Use language like "the priority is X" and "also, when you get a chance, Y"
5. **Connection to the arc** — how this session's work fits into the larger project trajectory. One sentence is enough, but it orients the instance.

### Step 3: Offer it to the user

Present the handoff in chat. The user may want to edit it, add their own intent, or adjust priorities before pasting it into the new thread.

## Template

```
Hey! [One sentence on what just happened and why we're handing off.]

**[Main task framing — what the next instance should focus on]:**
- [Specific file/path to start with] — [what to do with it and why]
- [Next file/path] — [what to extract or build]
- [Additional files if needed]

[Context sentence: how this connects to previous work or the larger arc. "We already did X, now the goal is to go deeper with Y."]

[Prioritization: "The priority is A. Also when you get a chance: B."]

[Any gotchas or things to watch for.]
```

## Common Mistakes

- **Too vague.** "Continue the skills work" doesn't help. "Read `anthropic-skills/skills/skill-creator/SKILL.md` and apply the eval methodology to our project-guidelines skill" does.
- **Missing file paths.** The #1 thing the incoming instance needs is specific paths. Every handoff should have at least 2-3 exact paths.
- **Duplicating the session log.** The handoff isn't a summary of what happened — it's instructions for what to do next. The session log covers what happened.
- **No prioritization signal.** Without it, the instance treats everything as equal priority and may spend time on the wrong thing.
- **Forgetting the "why."** A fresh instance doesn't know why this particular task matters right now. One sentence of framing prevents it from misunderstanding the intent.

## Example

Here's a real handoff that worked well (Session 24 → 25):

```
Hey! Session 24 was a huge one — the session log has the full
story but here's the key context for picking up:

We cloned 4 skills reference repos to
~/Documents/Claude/Local Git Repos/ — you have filesystem
access to read them. The most important one to study is the
skill-creator from Anthropic's official repo. Read this guide
first: Workshop/Research/Local Reference Repos - Skills and
Agents.md

The priority for this session is a deep dive into the
reference repos, specifically:
1. anthropic-skills/skills/skill-creator/SKILL.md — the
   definitive methodology for building and testing skills
2. superpowers/skills/writing-skills/SKILL.md +
   anthropic-best-practices.md — authoring guide and official
   best practices
3. agentskills/docs/specification.mdx — the formal spec

We already did a first pass from web search results (see
Workshop/Research/Skills Best Practices Deep Dive.md), and we
converted our 4 skills to the SKILL.md folder standard. But
now we have the actual source repos locally and can study them
properly. The goal is to learn what we missed and improve our
skills — especially the project-guidelines skill, which is our
first test case for the protocol-as-skills architecture (see
Workshop/Design/Protocol as Skills Architecture.md).

After the deep dive, the next concrete task is testing the
project-guidelines skill by migrating Weave's 0.0 to current
spec. That's the real-world validation.

Also: push Seed to GitHub when you get a chance — it's still
way behind.
```

Why this worked: specific file paths, clear priority ordering, "first pass vs primary sources" framing, causal chain (deep dive → improve → test on Weave), and side task clearly deprioritized.

## Relationship to Session Log

Always write BOTH at end of session:

1. **Session log "What's next"** — the persistent vault record (follows the protocol format with specific paths, framing, sequencing, and prioritization)
2. **Handoff briefing** — the chat message for the user to paste (can be even more specific and tactical than the session log)

The handoff can reference the session log: "The session log has the full story, but here's what matters for picking up..."

## See Also

- Protocol Summary — session log format and "What's next" guidance
- Research skill — for research-specific handoff patterns


---

## Discipline Upgrade Candidate

This skill is currently a **Technique** type — it describes how to write a handoff. But the "always write BOTH session log and handoff" instruction has discipline-enforcement characteristics. If instances start skipping handoff briefings (rationalizing that "the session log What's Next already covers it" or "the user didn't specifically ask"), this skill should be upgraded to **Discipline** type with:

- An Iron Law ("No session ends without both a log entry and a handoff briefing")
- A rationalization table for common skip-excuses
- A Red Flags list
- Pressure scenarios for testing

**For now:** watch for the failure in real sessions before adding enforcement. Per the TDD methodology: no discipline skill without observing the violation first.
