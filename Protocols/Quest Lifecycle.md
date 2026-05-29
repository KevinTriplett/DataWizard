---
title: Quest Lifecycle
type: protocol
created: '2026-05-29'
updated: '2026-05-29'
datawizard_protocol_version: '1.7'
maturity: draft
---

# Quest Lifecycle

Canonical status values and transitions for quest files across all DW-managed projects. Consistent statuses enable cross-project dashboards and reliable filtering.

## Status Definitions

| Status | Meaning |
|---|---|
| `open` | Defined and scoped, not yet started. Backlog. |
| `active` | Currently being worked on (this or recent sessions). |
| `paused` | Was active, pulled aside. Work already done, intent to resume. Different from `open` because progress exists. |
| `ready-for-debrief` | Work is complete, needs review or close-out before marking done. |
| `complete` | Reviewed and closed. Kept for record. |
| `cancelled` | Abandoned. Kept for record, not for action. |

## Valid Transitions

```
open --> active --> ready-for-debrief --> complete
            |                |
            v                v
          paused          cancelled
            |
            v
          active  (resume)
            |
            v
        cancelled  (from any non-terminal state)
```

Normal flow: `open` to `active` to `ready-for-debrief` to `complete`.

`paused` is an optional detour from `active`. A paused quest returns to `active` when work resumes.

`cancelled` is reachable from any non-terminal state (`open`, `active`, `paused`, `ready-for-debrief`).

`complete` and `cancelled` are terminal -- no transitions out.

## When to Use Each Status

**open vs paused:** A quest is `open` if it has never been actively worked. It is `paused` if it was `active` but work stopped. The distinction matters because paused quests have context, partial progress, and possibly blockers worth noting -- they are closer to resumption than backlog items.

**active hygiene:** If a quest has not been touched for 20+ sessions or 2 weeks (whichever comes first), the instance should suggest pausing it. Do not transition automatically -- ask the quest owner first. If the owner is unavailable (no active session), any project user may confirm the transition. In either case, note the pause and who confirmed it in the session log so the owner has visibility. The `active` status should reflect current work, not aspirational intent.

**ready-for-debrief:** Use this when the deliverables are done but you want a review gate before closing. This is especially useful for quests with multiple phases or cross-project implications. For simple quests, going directly from `active` to `complete` is acceptable.

## Dashboard Conventions

Standard dashboard views and their filters:

- **Active:** `status == "active"` or `status == "ready-for-debrief"` -- things needing attention now
- **Paused:** `status == "paused"` -- parked work, periodic review
- **Open:** `status == "open"` -- backlog
- **All:** no status filter -- full inventory including complete and cancelled

## Required Frontmatter

Quest files must include these fields for dashboard compatibility:

```yaml
type: quest
quest_id: XX-Q-NNN    # project prefix + sequential number
project: ProjectName
status: open           # one of the 6 lifecycle values
priority: 1            # 1 (highest) to 3 (lowest)
owner: name
assigned: YYYY-MM-DD   # date quest was created or assigned
threshold: null        # optional: condition that triggers this quest
```
