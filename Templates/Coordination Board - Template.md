---
title: Coordination Board
type: coordination-board
created: YYYY-MM-DD
updated: 2026-10-13
next_free: B-0004
generated_by: board.py render
operator: Operator-A
edit_log:
  - '2026-10-13 - header id sentence and awareness seen sentence aligned with board.py schema 6; optional resolution line in the ask grammar (DataWizard, 2026-10)'
  - 2026-10-06 - created (Coordination Board template; DataWizard, 2026-10)
  - '2026-10-12 - awareness asks: intent field and statuses in the grammar, example block (DataWizard, 2026-10)'
---

*Starter for the vault-level coordination board. Copy it to `_Coordination/Board.md` at the vault root (or the `board_dir` set in `Vault Config.md`), replace the placeholder targets, and delete the three example blocks. Once `board.py render` runs, it owns this file: the frontmatter, the header below and every block are machine-written, and this italic paragraph is dropped. Rules: Conventions Registry, entry "Coordination board". Remove this paragraph when you copy.*

# Coordination Board

Cross-project asks and write claims for the whole vault. Each row is a pointer; the content stays where it points. Rendered by `board.py render` from the `board` table in the operational database. Rule: Conventions Registry, entry "Coordination board".

By hand (sessions that cannot write the table, e.g. Cowork): add a block at the end of `## Live` with the `next_free` id from this note's frontmatter - or, if any block in this note (the Unreconciled section included) or in the archive already carries that id or a higher one, the next id above the highest present; re-read; if another block already has that id, renumber yours to the next free one. To release a claim or pick up an ask, edit its `status` and set `updated` to now (UTC, YYYY-MM-DDTHH:MM:SSZ). To mark an awareness ask seen, set `status: seen` and `updated`. To take over an expired claim, add your own held claim and set the old one to `status: reclaimed` with `- reclaimed_by: <your id>`. Never delete a block. The next render folds hand edits into the table.

Block grammar (one block per row; statuses - asks: open, picked-up, done, declined, stale; awareness asks (`intent: awareness`): open, seen, stale; claims: held, released, expired, reclaimed):

    ### B-NNNN ask - <summary, at most 120 characters>
    - to: <ABBR[,ABBR] or all> | by: <session> | status: open | posted: <UTC time> | due: <date or ->
    - target: project:<ABBR>
    - note: <vault path of the note that holds the content>
    - intent: <action or awareness; optional, default action - awareness means nothing is asked>
    - updated: <UTC time>
    - resolution: <optional one line: how it closed>

    ### B-NNNN claim - <summary>
    - by: <session> | status: held | posted: <UTC time> | heartbeat: <UTC time> | ttl: 120
    - target: <path:, store: or hid: pointer>
    - reason: <one line>
    - token: <your session claim_id>
    - updated: <UTC time>

Well-known targets (spell exactly):
- store:<store-name> - <vault path of the shared store, or where it lives outside the vault>
- store:<another-store> - <vault path>
- <ABBR>: path:<project home>/<infrastructure folder>/0.2 Session Log - <Project>.md
- <ABBR2>: path:<project home 2>/<infrastructure folder>/0.2 Session Log - <Project 2>.md

## Live

### B-0001 ask - Pickup - example handoff note waiting in the target project's Session Exchange
- to: PROJB | by: PROJA S<NNN> | status: open | posted: 2026-01-05T09:00:00Z | due: -
- target: project:PROJB
- note: <project B home>/Session Exchange/Note from PROJA - Example pickup (2026-01-05).md
- updated: 2026-01-05T09:00:00Z

### B-0002 claim - Example apply run rewriting a shared store
- by: PROJA S<NNN> | status: held | posted: 2026-01-05T09:30:00Z | heartbeat: 2026-01-05T09:30:00Z | ttl: 120
- target: store:<store-name>
- reason: example batch apply; rollback copy taken first
- token: <claim_id of the claiming session>
- updated: 2026-01-05T09:30:00Z

### B-0003 ask - Awareness - example shared vocabulary note changed; nothing is asked
- to: PROJB,PROJC | by: PROJA S<NNN> | status: open | posted: 2026-01-06T10:00:00Z | due: -
- target: project:PROJB
- note: <project A home>/Decision Log - example entry for the changed vocabulary.md
- intent: awareness
- updated: 2026-01-06T10:00:00Z

## Recently closed

(none)
