---
title: 'Multi-Operator Flags'
type: skill-reference
parent: "[[_DataWizard/Seed/Skills/session-closer/SKILL|session-closer]]"
created: '2026-10-18'
updated: '2026-10-18'
operator: Andrew
origin: 'DW-S422 2026-10-18 - moved verbatim from session-closer SKILL.md v4.10.3'
edit_log:
  - 'DW-S422 2026-10-18 - created: moved verbatim from session-closer SKILL.md v4.10.3'
---

*Part of the [[_DataWizard/Seed/Skills/session-closer/SKILL|session-closer]] skill*

# Multi-Operator Flags

## Team flag prompt

**Team flag prompt (multi-operator projects only).** If the project has more than one operator, present the user with a list of files created or substantially updated this session. Pre-select:
- Any file created this session with `priority: high`
- New synthesis documents, analyses, or research notes
- Any file that substantially updates a shared canonical doc (design docs, strategy docs, etc.)

**In Cowork (AskUserQuestion available):** Use `AskUserQuestion` with `multiSelect: true` to present candidates as selectable options. Each option's `label` is the file's display name; `description` summarizes what changed this session. Pre-selected items should appear first in the options list with "(Recommended)" appended to the label. This lets the operator click rather than type. If the operator has indicated a preference against AskUserQuestion, fall back to the text-list approach below.

**In Chat or when AskUserQuestion is unavailable:** Ask in prose: "Which of these should be flagged for team attention -- meaning other operators should read it before their next session?" List the candidates with numbered options for easy selection.

For each file the user selects:
1. Add `flag: YYYY-MM-DD` (today's date) to its frontmatter
2. Add `flag_by: FirstName` (the operator's first name)
3. Add `flag_for:` as a YAML list of the operators who need to see it (e.g. if Operator-A flags it: `flag_for: [Operator-B, Operator-C]`) -- narrow it to the people it is actually relevant to
4. Set `flag_note:` to a one-line statement of **the decision needed and what is blocked until it is made** (the content requirement -- [[YAML Schema]] Team Coordination Fields; "please review the tiers" fails, "approve or amend the tiers -- outreach proceeds in listed order on silence" passes). Fold a long note per the same guidance so it cannot break frontmatter parsing
5. Optionally set `flag_due:` (date a response is needed by) and `flag_default:` (what happens on silence after the due date). Ask for these on anything time-sensitive -- they are what let the expiry pass (Step 3.13) turn silence into a decision

**Flag budget: at most 2-3 new flags per close.** Forcing triage keeps the queue meaningful; a flag on everything trains operators to skip the sweep. If more than three files feel flag-worthy, pick the ones that genuinely need another operator's eyes before their next session.

**Re-flagging a file that already carries an unresolved flag: merge, never overwrite.** Union the existing `flag_for` list with the new recipients (preserving names who haven't dismissed yet), keep or combine the `flag_note` so both notices survive, and update `flag`/`flag_by` to the newer flagging. `flag_for` is a shared unread-queue -- overwriting it silently erases other operators' pending notifications. (Field catch, 2026-08: a re-flag would have erased two operators' unread state on a Decision Log flag; the closing session merged instead.)

**On ungraceful session close** (context exhausted before the user can confirm): auto-flag any `priority: high` files created this session using `flag_by: "FirstName (auto)"` and `flag_for:` listing all other team operators. The human can review and remove auto-flags in a subsequent session.

**Team read dismiss (multi-operator projects only).** When the operator handles a file whose `flag_for` contains their name, update the flag by their response: **acting on it** removes their name from `flag_for` (`update_frontmatter`); a **conscious defer** keeps their name and sets `flag_status: deferred`, so the item re-surfaces due-first at their next orientation rather than vanishing (defer is not dismissal -- F3 of the Flag Surfacing Chain). When the `flag_for` list empties through handling, all operators have seen the item -- anyone can then clear the `flag`, `flag_by`, `flag_note`, `flag_for`, and any `flag_due`/`flag_default`/`flag_status` fields to remove it from the dashboard entirely.

## Flag expiry pass

> Solo projects and lite closes skip this step. **Scope: only flags set on or after the Flag Surfacing Chain ship date (Seed 1.3.0 -- see VERSION.md's What's New).** Flags that predate delivery are a pre-existing backlog handled by a dedicated triage session; never mass-expire them here (at rollout, entire per-person queues are older than any age threshold -- expiring them would stamp `expired-unread` on flags that were never deliverable).

Scan the project for live flags (`flag` present, `flag` date on/after the ship date) that are **not** already `flag_status: deferred`. A deferred flag was consciously read (F3 put that on the record) -- never overwrite it. A flag in scope is **expired** when:

- it carries a `flag_due` and today is past `flag_due` (silence became a decision at the deadline the flagger set), OR
- it has no `flag_due` and its `flag` date is more than **21 days** old (the backstop so undated flags still eventually resolve).

For each expired flag, do one of:

- **Refresh** -- if the ask is still live, re-stamp `flag` to today and set or update `flag_due` and a real `flag_note`, so it re-enters the queue with a fresh clock.
- **Expire** -- set `flag_status: expired-unread`, clear the `flag_for` names, and record in the `flag_note` that the `flag_default` (if any) is now in effect.

This pass is the **only automatic writer of `flag_status: expired-unread`** and the only automatic name-clearer -- the orientation sweep is read-only (PI Orientation Step 6 / [[Orientation Flag Sweep - Query Spec]]). It runs at close because close already patches shared surfaces. Dated flags expire on the flagger's own deadline; undated flags get the 21-day backstop; deferred flags are exempt (already read). An `expired-unread` flag is itself the record that delivery failed.

Board claims are not expired here: a held claim past heartbeat + ttl is expired by `board.py render`, which DW Save runs Mac-side at every save - never by hand from Cowork.
