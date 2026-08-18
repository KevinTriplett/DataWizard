---
title: Quest Lifecycle
type: protocol
created: '2026-05-29'
updated: '2026-08-18'
datawizard_protocol_version: '1.7'
maturity: draft
edit_log:
  - 2026-08-04 - added overtaken and needs-review statuses (8-status lifecycle,
    D113)
  - 2026-08-18 - added Task IDs (scan-max + verify-after-mint, counters retired,
    scoped definition rule, dedup taxonomy) and Assignment Conventions sections
    (D119)
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
| `needs-review` | Completion believed but unverified. Confirm done (then debrief or complete) or capture the residual and resume. |
| `overtaken` | Superseded by events or other work before completion. Terminal. Kept for record; no debrief owed. |

## Valid Transitions

```
open --> active --> ready-for-debrief --> complete
            |                |
            v                v
          paused          cancelled
            |
            v
          active  (resume)

active | paused --> needs-review --> complete  (verified, no debrief owed)
                        |      \--> ready-for-debrief  (verified, debrief owed)
                        v
                      active  (residual found; resume)

cancelled  (from any non-terminal state)
overtaken  (from any non-terminal state)
```

Normal flow: `open` to `active` to `ready-for-debrief` to `complete`.

`paused` is an optional detour from `active`. A paused quest returns to `active` when work resumes.

`needs-review` is entered from `active` or `paused` when completion is believed but unverified (typically surfaced by an audit). It exits to `complete` (or `ready-for-debrief` if a debrief is owed) once verified, or back to `active` if a residual surfaces.

`cancelled` is reachable from any non-terminal state (`open`, `active`, `paused`, `ready-for-debrief`, `needs-review`).

`overtaken` is likewise reachable from any non-terminal state -- for quests superseded rather than abandoned.

`complete`, `cancelled`, and `overtaken` are terminal -- no transitions out.

## When to Use Each Status

**open vs paused:** A quest is `open` if it has never been actively worked. It is `paused` if it was `active` but work stopped. The distinction matters because paused quests have context, partial progress, and possibly blockers worth noting -- they are closer to resumption than backlog items.

**active hygiene:** If a quest has not been touched for 20+ sessions or 2 weeks (whichever comes first), the instance should suggest pausing it. Do not transition automatically -- ask the quest owner first. If the owner is unavailable (no active session), any project user may confirm the transition. In either case, note the pause and who confirmed it in the session log so the owner has visibility. The `active` status should reflect current work, not aspirational intent.

**ready-for-debrief:** Use this when the deliverables are done but you want a review gate before closing. This is especially useful for quests with multiple phases or cross-project implications. For simple quests, going directly from `active` to `complete` is acceptable.

**needs-review vs ready-for-debrief:** `ready-for-debrief` means the work is verified done and awaiting its close-out review. `needs-review` means completion is believed but unverified -- typically discovered during a reconsolidation or health audit. The next touch verifies: confirm done (then debrief or `complete`), or capture the residual and resume.

**overtaken vs cancelled:** `cancelled` is abandonment by choice -- the quest stopped being worth doing. `overtaken` is supersession -- events or other work made the quest moot (its goal was achieved another way, or the ground shifted under it). The distinction matters for retrospectives: cancelled quests were misjudged bets; overtaken quests were casualties of a changing plan. Neither owes a debrief.

## Dashboard Conventions

Standard dashboard views and their filters:

- **Active:** `status == "active"`, `status == "ready-for-debrief"`, or `status == "needs-review"` -- things needing attention now
- **Paused:** `status == "paused"` -- parked work, periodic review
- **Open:** `status == "open"` -- backlog
- **All:** no status filter -- full inventory including complete and cancelled

## Priority Levels

| Priority | Meaning |
|---|---|
| `1` | Blocking other work or time-sensitive. Address soon. |
| `2` | Important. Work when opportunity arises. |
| `3` | Worth doing, no urgency. Pick up when the moment is right. |

Priority is independent of status. An `active` quest can be P3 (being worked but not urgent), and an `open` quest can be P1 (hasn't started but should start soon).

## Required Frontmatter

Quest files must include these fields for dashboard compatibility:

```yaml
type: quest
quest_id: XX-Q-NNN    # project prefix + sequential number
project: ProjectName
status: open           # one of the 8 lifecycle values
priority: 1            # 1 (highest) to 3 (lowest)
owner: name
assigned: YYYY-MM-DD   # date quest was created or assigned
threshold: null        # optional: condition that triggers this quest
```

## Task IDs

Task IDs are a single global sequence per project (`PREFIX-NNNNN`, 5-digit zero-padded), shared by quest tasks and standalone tasks, and referenced bare across session logs, harvest logs, and action items - so global uniqueness is relied on in practice, and a duplicate breaks every bare reference silently. `PREFIX` is the project's `task_prefix`, defined in the quest index frontmatter.

**Minting rule - scan-max with verify-after-mint.** The next ID is (highest task ID across the project's active quest files, quest archive, and quest index / action items file) + 1. After writing, re-search the same scope for the ID(s) just minted; if a concurrent session minted the same ID, take the next free number and re-verify (same shape as the session-claim ceremony). **Verify immediately after writing the defining line, before referencing the new ID anywhere else** - a reference written before the verify can be orphaned by a renumber. Never trust a stored counter: per-quest `next_task_id` fields drift the moment two quests each add a task, then mint colliding IDs (field-observed in three projects; two accumulated live duplicates).

- **Definition vs reference.** A definition is a checkbox task line in the quest layer (active quest files, quest archive, or the quest index for standalone tasks); each task ID has exactly one. Everything outside the quest layer is a reference regardless of grammar. Within the quest layer, non-definition mentions must not use checkbox grammar; migrated or superseded task lines convert to prose (tombstones), never to a second checkbox.
- **Archive, never delete.** Archived quests keep their IDs forever and the quest archive is always in scan scope; quest files are archived, never deleted - deleting one lowers the scan max and re-mints old IDs against surviving bare references.
- **Collisions are silent** - the write succeeds. Repair per the dedup taxonomy below: migration tombstones convert out of task grammar; completed-real duplicates get renumbered; independent live collisions keep the ID on the side with the heaviest reference footprint (history cannot be renumbered).
- **No counter fields.** `next_task_id` (and variants) are retired; if encountered, remove rather than update.
- **Tooling that mints IDs must implement the same scan + verify.** (The Quest Manager GUI currently mints none; this binds any future add-task feature.)

### Collision Repair (Dedup Taxonomy)

Three classes of duplicate, three handlings (field-tested, Weave, 2026-08):

1. **Migration tombstones** - the old copy of a task migrated elsewhere: convert OUT of task grammar to prose. Renumbering a tombstone preserves a phantom open task.
2. **Completed-real duplicates** - two real tasks, at least one complete: renumber the duplicate(s); completed work is safe to renumber when its reference footprint is checked first.
3. **Independent live collisions** - two live tasks independently minted onto one ID: keep the ID on the side with the heaviest *reference* footprint, not reflexively the open one (history cannot be renumbered; a live task accretes references from day one). Renumber the lighter side and repair its references.

After any repair pass: run the duplicate-definition search across the full scan scope to zero.

## Assignment Conventions

**A multi-concern item lives in the quest where the *next action* is, not where the background context is.** A person who is both a partnership lead and a research contact goes in Partnerships if the next step is outreach (the research is background), and in Research if the next step is investigation (the partnership is latent). The tie-breaker is "what happens next," never "what is this about."
