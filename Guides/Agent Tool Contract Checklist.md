---
title: Agent Tool Contract Checklist
type: guide
scope: seed
created: '2026-10-12'
updated: '2026-10-12'
operator: Andrew
status: active
origin: 'DW-S400 2026-10-12 - created'
edit_log:
  - 'DW-S400 2026-10-12 - created (agent-tool contract checklist; Agent-Facing Engineering Doctrine FR, candidate 1)'
---
# Agent Tool Contract Checklist

> Part of the **Surfaces and tools** guide group -- see `GUIDES.md`.

*A checklist for any surface an agent calls: an MCP server, tools exposed to an in-app assistant, or a script whose output an instance parses and acts on. The agent is the user of the contract, so design the contract for how a model reasons, not for how the service is built inside. Use the checklist at design time, before the schema is written. Use it again as a review lens before the surface ships.*

## When it applies

- A project is about to expose tools to an agent (MCP server, in-app agent panel, function-calling API).
- An instance will parse or act on a script's output (a lint report, an apply step, a dry-run summary).
- You are reviewing an existing agent surface: run the checklist against each tool and record which items fail.

It does not apply to human-only interfaces, or to internal functions no agent calls directly.

## The checklist

**Shape each tool around intent**

1. **Design from the user's intent, not the internal API.** A tool per service method forces the model to rebuild your architecture before it can act. Name tools for what the user is trying to get done.
2. **Specify before you write the schema.** Write down the outcome, the success criteria, failure, cancellation and retry behavior, idempotency, and undo semantics first. The schema follows from these.
3. **One tool, one coherent action.** Each call is one atomic, undoable user action. Avoid catch-all tools whose mode switch changes what the call means. Batch inputs are fine when the whole batch lands as one action and one undo, and one bad entry rejects the call with no partial state.

**Identity and stable values**

4. **Stable IDs, never positions alone.** You may return positional indexes as context, but every entity the agent may act on next needs an identity that survives a mutation. If a call does invalidate IDs, its response says so.
5. **Machine-facing values stay stable.** Enum values and protocol fields never carry display or localized labels, because those change and break callers.

**Receipts and errors**

6. **Return a structured receipt.** It lists what changed, the stable IDs touched, an explicit no-op state when nothing changed, warnings, skipped items with reasons, and errors the agent can act on. Shape the receipt in the read tool's vocabulary, so the agent can update its model without re-reading.
7. **Never return a success-shaped response for an adjusted outcome.** If the request was clamped, retargeted, reordered, substituted or partly skipped, the receipt says so. A tool adjusts silently only when its contract promises the adjustment and reports it.
8. **Write errors that let the agent finish the job.** Echo the offending value. List the valid set or range. Point at the nested field that failed (`items[2].status`). Name the tool or argument that fixes it. A refusal states its reason and any override that exists.

**Descriptions**

9. **Say when and why.** Cover the purpose in intent terms, the units and invariants, which neighboring tool to use instead and when, the failure and atomicity behavior, and what the receipt contains. Restating the parameter names is not a description.
10. **Put defaults and exclusivity in the prose.** Mark optional parameters as optional, state the default and any cap together, and state mutual exclusivity on both sides.

**Verification**

11. **Test through the boundary.** Verify a tool end to end: call it as the agent would, then read the state back independently. A success response alone is not proof (see `Working Principles`, "A completion is a disk fact, not a claim").

## Worked example

A project exposes a task store to an agent. The first draft mirrors the service layer: `update_record(table, row_index, fields)`. Run it against the checklist:

- **Items 1 and 3 fail.** The tool is a generic writer, and "close this task" needs a different field set each time. Replace it with `close_tasks(task_ids, resolution)` and `reassign_tasks(task_ids, owner)`.
- **Item 4 fails.** `row_index` shifts when a row above it is deleted, so a two-step plan acts on the wrong row. Address tasks by their minted ID.
- **Items 6 and 7.** `close_tasks` returns `{closed: [ids], already_closed: [ids], skipped: [{id, reason}], changed: true|false}`. Closing a task that is already closed is reported as a no-op, not as a success.
- **Item 8.** An unknown resolution returns: "resolution 'finished' is not valid; use one of: done, wontfix, duplicate."
- **Item 11.** The test calls `close_tasks`, then reads the store directly and checks the rows, instead of trusting `changed: true`.

The redesigned surface is smaller, and an agent can plan a whole pass from one read.

---

*Distilled at idea level from a production open-source repo's agent-tool rules and one project's agent-surface design (VibeCut, 2026-07); written fresh, no text carried over. Related: `FSAccess GUI Pattern` (the other surface-building guide in this group), `Working Principles` (the verification stance).*
