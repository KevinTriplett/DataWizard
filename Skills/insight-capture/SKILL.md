---
name: insight-capture
description: >-
  Capture and plant insights from loaded context mid-session. Triggers on:
  'capture insights', 'insight capture', 'let's capture', 'capture', 'squeeze
  the juice'. Use when rich context is loaded after deep work, side quests, or
  design discussions and you want to extract patterns, plant them in the right
  permanent homes, and cross-reference for discoverability.
type: skill
created: '2026-06-04'
updated: '2026-06-04'
version: '1.0'
---

# Insight Capture Skill

## Overview

Extract, plant, and cross-reference insights from loaded context
mid-session. This is the "squeeze the juice" skill -- when rich
context is loaded after deep work, side quests, or design
discussions, this skill captures the cross-cutting patterns and
ensures they land in the right permanent homes with breadcrumbs
for future instances to find.

This skill bridges the gap between having insights (which happen
naturally when context is rich) and preserving them (which requires
deliberate routing and cross-referencing). Without it, insights
live only in chat and evaporate at session end.

## When to Use

- When the user says "capture," "capture insights," "let's
  capture," "insight capture," or "squeeze the juice"
- When you've been doing deep work and notice rich context loaded
  (proactive nudge -- see Protocol Nudge below)
- After a side quest that produced findings relevant to the main
  line of work
- After a design discussion that surfaced implications for
  multiple documents
- When the user asks "do you have any further thoughts or
  insights?" and wants to capture whatever surfaces

### When NOT to Use

- At session end for the standard knowledge transfer check --
  that's session-closer Step 3.5
- For planting research findings from a formal research note --
  that's design-harvest
- For reviewing accumulated session learnings across many
  sessions -- that's meta-learning-review

### Relationship to Other Skills

**design-harvest**: Plants research findings into design docs.
Source is always a research note with structured findings.
Insight-capture plants from loaded context -- the source is
the current session's work, not a research artifact.

**session-closer Step 3.5**: Verifies knowledge transfer at
session end. Checks whether findings got planted. Insight-capture
does the actual planting mid-session, which means Step 3.5 has
less to catch at close.

**meta-learning-review**: Reviews accumulated learnings across
many sessions and plants operational patterns into skills and
protocol. Insight-capture works within a single session on
freshly-generated insights.

## Protocol Nudge

When you notice you've been deep in a side quest, completed a
substantial chunk of work, or have particularly rich context
loaded (~50-75% through a session), offer a one-line nudge:

"Good moment for an insight capture if you want one."

Don't force it. The user may invoke it themselves, skip it, or
save it for later. The nudge is a reminder that the moment is
ripe, not a gate. If the user doesn't respond to it, move on.

Timing signals that suggest a nudge:
- You just finished a side quest and are about to return to the
  main line of work
- A design discussion produced several implications you haven't
  written down yet
- You've been building something and noticed patterns that affect
  other parts of the project
- The conversation has been going for a while and you have
  observations that exist only in chat

Do NOT nudge:
- During the first quarter of a session (not enough context yet)
- When the user is in flow on a specific task (don't interrupt)
- More than once per session unless the user invoked it and then
  did another large chunk of work

## The Insight Capture Flow

### Step 1: Synthesize

Review the loaded context for cross-cutting patterns. Look for:

- **Patterns discovered**: Recurring themes, structural
  similarities, or principles that emerged from the work
- **Design implications**: How the current work affects design
  docs, build plans, or architectural decisions
- **Gaps identified**: Things the project should be doing or
  tracking but isn't
- **Connections to existing work**: Links between the current
  side quest and the main line, or between this session's work
  and prior sessions
- **Open questions**: Questions that surfaced but weren't
  answered, worth capturing for future sessions
- **Decision validations or invalidations**: Evidence that
  confirms or challenges existing design decisions

Present the insights as a structured list. Each insight gets:
- A category tag (pattern-discovered, design-implication,
  gap-identified, connection, open-question, decision-signal)
- A 1-2 sentence description
- A proposed destination (where it should be planted)

### Step 2: Classify and Map

For each insight, propose where it belongs. Use this routing
guide:

| Destination | When to route here |
|---|---|
| **Design doc** | Technical finding that affects architecture, pipeline design, or system behavior |
| **Build plan** | Finding that affects an upcoming build -- adds a consideration, validates an approach, or flags a risk |
| **Action items** | Follow-up work that surfaced -- specific enough to be actionable |
| **Skill** | Process improvement that should change how a skill works |
| **Protocol** | Convention change that affects all projects |
| **MOC** | New topic or subtopic introduced that needs a map entry |
| **Decision log** | Decision validated, invalidated, or newly made |
| **Session log learnings** | Worth recording as a session learning for future meta-learning review passes |

Some insights route to multiple destinations. That's expected --
the same finding might update a design doc AND create an action
item AND deserve a session log learning entry.

Present the full mapping to the user before proceeding.

### Step 3: Approve

Lightweight checkpoint. Present the synthesis and mapping, then
ask: "These look right? Anything to add, cut, or reroute?"

This is not a detailed review -- it's a quick confirmation that
the destinations make sense and nothing was missed. If the user
says "looks good" or equivalent, proceed. If they adjust, update
the mapping and proceed.

### Step 4: Plant

Write each approved insight to its target. For each target:

1. Re-read the target document's relevant section immediately
   before writing (Working Rule 3)
2. Check for existing related content -- integrate rather than
   duplicate if prior findings overlap
3. Write the insight with a source reference: session number
   and brief context (e.g., "Discovered during S149 insight
   capture while working on dw_ops.db design")
4. Frame for the reader of that specific document (design doc
   readers want architectural implications; skill readers want
   "what do I do differently"; action item readers want
   actionable next steps)
5. Verify each write landed before moving to the next

### Step 5: Cross-Reference

After planting, run this checklist to ensure discoverability:

1. **Bidirectional links**: Every planted insight should link
   back to the current session, and the session log should note
   where insights were planted. Future instances reading either
   document can find the other.

2. **MOC entries**: If an insight introduced a new topic or
   subtopic, check the project's MOC (0.1) for a relevant
   section. Add an entry if the topic is significant enough
   to warrant discovery via the MOC.

3. **Build plan annotations**: If insights affect an upcoming
   build, check whether the build plan document has a "Related
   findings" or "Considerations" section. Add a note with the
   insight and source reference.

4. **Prior session backlinks**: If an insight connects to
   specific past session work, add a cross-reference in the
   planted content (e.g., "See also S136 which discovered a
   related pattern in NextGraph"). Don't add backlinks to the
   old session files -- they're historical records.

5. **Decision log**: If an insight validates, invalidates, or
   creates a design decision, check the decision log. For
   validations, a note in the planted content referencing the
   decision number is sufficient. For new decisions or
   invalidations, flag to the user that a decision log entry
   may be warranted.

6. **Skill updates**: If an insight should change how a skill
   works, either patch the skill now (if the change is small
   and clear) or add a specific action item naming the skill
   and what to change.

7. **Quest connections**: If the session is part of an active
   quest, check whether the insight should be noted in the
   quest file as progress or a discovery.

### Step 6: Report

Brief summary of what was planted where. Format:

"Planted N insights across M documents:
- [Insight summary] -> [target doc] (section)
- [Insight summary] -> [target doc] (section)
Cross-references added: [list any MOC updates, build plan
annotations, or decision log references]"

This report becomes part of the session log's "What happened"
section at session close. The session-closer can reference it
rather than reconstructing the planting from scratch.

## Common Mistakes

- **Planting everything in the session log.** The session log
  is a handoff document, not a knowledge store. Insights that
  only live in the session log will be missed by future
  instances doing task-specific work. The session log should
  note WHERE things were planted, not BE the destination.

- **Skipping the approval step.** Even a quick "looks good?"
  prevents planting insights the user would redirect. The
  checkpoint is lightweight but important.

- **Planting without re-reading the target.** The target doc
  may have changed since you last read it. Always re-read the
  specific section immediately before patching.

- **Missing the cross-reference pass.** Planting without
  cross-referencing is half the job. The insight exists in the
  right place but nobody can find it from adjacent documents.
  The cross-reference checklist is what makes side-quest
  treasure discoverable from the main quest.

- **Over-planting.** Not every observation deserves a permanent
  home. Routine or one-off findings ("tool X was slow today")
  belong in the session log learnings, not in design docs. Use
  judgment about what's worth the permanence and the reader's
  attention.

- **Forgetting to frame for the reader.** The same insight
  reads differently in a design doc vs. an action item vs. a
  skill. Don't copy-paste the same sentence everywhere --
  adapt the framing to what each document's reader needs.

## See Also

- design-harvest skill (plants research findings into design
  docs -- the formal-research counterpart to this skill)
- session-closer Step 3.5 (end-of-session knowledge transfer
  verification -- catches anything insight-capture missed)
- meta-learning-review skill (reviews accumulated learnings
  across many sessions -- the long-arc counterpart)
- 0.0 Session Planning > "Synthesize while hot" (timing
  guidance for when context is at risk)
