---
name: side-quest
description: >-
  Use when starting or resuming a tangent from the project's current arc -- a
  multi-session stream of work unrelated to where the main sessions are heading.
  Triggers on: 'let's go on a side quest', 'this is a side quest', 'side
  quest:', or resuming with 'continue the [X] side quest'. Especially relevant
  when concurrent instances run parallel workstreams and the session log's
  'What's next' would otherwise collide. Not for normal main-arc continuation,
  quick one-off tasks, or mid-session synthesis (use insight-capture).
type: skill
created: '2026-06-15'
updated: '2026-06-15'
operator: Andrew
version: '1.0'
edit_log:
  - DW-S186 2026-06-15
---
# Side Quest Skill

## Overview

A side quest is an intentional tangent from the project's current arc -- a stream of work unrelated to the sequence the main sessions are pursuing. (This skill was itself built on a side quest while a concurrent instance advanced the main arc.)

The problem it solves lives in the session log handoff. "What's next" quietly does two jobs: it records the immediate continuation of *this* session's stream, and it carries the project's single canonical direction. With one linear stream those are identical. When two instances run in parallel -- one on the main arc, one on a side quest -- their entries interleave, and the most recent "What's next" wins the next orientation read. A side-quest entry written on top can overwrite the main arc's direction with its own, and the streams get confused.

The fix is a routing rule, not a new structure. A side quest never writes its continuation into the main "What's next." It protects the main arc's "What's next" and parks its own continuation in the session log's "Active quest threads" section, keyed by a clear name. Whoever orients next finds the right handoff: the main-arc instance reads "What's next" (still on the arc); the returning side-quest instance reads its named thread.

## When to Use

Trigger phrases:
- "let's go on a side quest"
- "this is a side quest" / "side quest: ..."
- Resuming: "let's continue the [X] side quest"

Also load this skill, even without the phrase, when you are about to start a multi-session stream of work that is unrelated to the main arc's "What's next" -- especially if another instance may be advancing that arc concurrently.

### When NOT to Use

- Normal continuation of the main arc. That is just a session; the main "What's next" is your handoff.
- A quick question or one-off task that closes within the session and needs no multi-session handoff.
- Mid-session synthesis of loaded context -- that is `insight-capture`.
- A formal, tracked deliverable that warrants a `[DW-Q-###]` quest. A side quest is the lightweight, ad-hoc cousin (see Relationship).

## At the Start of a Side Quest

1. **Acknowledge the divergence.** State that this session is a side quest and will not follow the main arc's "What's next." Orientation still happens (read 0.0, the last 2-3 session entries) -- you need to know the main arc in order to protect it -- but you are deliberately stepping off it.

2. **Name the side quest.** A short, stable name reused across sessions (e.g. "build the side-quest skill"). It becomes the thread name at close and the handle for resuming.

3. **Claim a flagged session ID.** Claim the next session ID in your project's format (solo-operator: next sequential number; multi-operator: the composite ID), then add `stream: side-quest` to the stub frontmatter and label the title so the tangent is visible at a glance (e.g. `"Session 186 (side quest) - Build the Side-Quest Skill"`). The stub file in the session log folder is the concurrency claim -- another instance listing the folder sees the ID is taken. If a main-arc instance is running concurrently, defer the shell embed to session close (the MCP concurrency rule -- the shell is a shared resource).

4. **Drop a pointer to the main arc.** In the stub, note in one line where the main arc stands and which session holds its live "What's next" (e.g. "Main arc: P3 action plan, see S184 What's next"). This keeps the canonical direction visible from inside the tangent.

## During the Side Quest

Work normally. The one ongoing discipline: do not treat the main arc's "What's next" as something to advance -- you are not on it. If rich context accumulates, `insight-capture` applies here as in any session.

## At Close (the core of this skill)

Close with the `session-closer` skill as usual, with two side-quest rules layered on top:

1. **Protect the main "What's next."** Do not overwrite it with the side quest's next step. The main arc's "What's next" is the one in the most recent *non-side-quest* session entry. Carry it forward -- restate it, or reference it explicitly ("Main arc unchanged -- see S184 What's next"). An instance picking up the main arc must read a "What's next" that still points at the arc, not at your tangent.

2. **Route the side quest's continuation into "Active quest threads."** Add or update a thread named for the side quest, in the standard quest-thread shape: bold name, session history in parentheses, 2-3 sentences of remaining work, key doc paths. This is where the returning side-quest instance picks up. If the side quest finished this session, write no thread -- note its completion in "What happened."

The `stream: side-quest` flag on the entry tells a future orienting instance that this top entry is a tangent -- so it trusts "Active quest threads" plus the carried-forward main "What's next" rather than reading this entry's "What happened" as the project's direction.

## Resuming a Side Quest

- **"Let's continue the [X] side quest"** -> read the named thread in the most recent "Active quest threads" section. That thread is the handoff.
- **Ambiguous "pick up where we left off"** -> default to the main arc's "What's next." Mention any open side-quest threads as available, but do not assume the user means the tangent.

## Relationship to Other Skills and Systems

- **session-closer** does the actual write. This skill only changes *where* the handoff is routed; session-closer Step 2.6 already maintains "Active quest threads."
- **insight-capture** is the sibling for mid-session synthesis of loaded context. A side quest routes a parallel *stream*; insight-capture harvests *insights*. They compose.
- **Formal Quest system** (`[DW-Q-###]`, `0.7 Quest Log`): heavier, tracked deliverables. A side quest is ad-hoc and lives only in the session log's quest-thread section. If a side quest grows into a tracked deliverable, promote it to a formal quest.
