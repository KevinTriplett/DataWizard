---
created: 2026-08-18
edit_log:
  - "DW-S279 2026-08-18 - created (Flag Surfacing Chain B2: canary protocol,
    diagnosis tree, executor chain, first-render expectations)"
maturity: working
operator: Andrew
seed_version: 1.2.0
title: Team Attention Rollout
type: guide
updated: 2026-08-18
---
# Team Attention Rollout

*How a multi-operator project turns the flag machinery on -- and verifies, per person, that it actually delivers. The mechanism itself lives elsewhere: field definitions in the [[YAML Schema]] (Team Coordination Fields), the orientation sweep in the Project Instructions (Orientation Step 6) and [[Orientation Flag Sweep - Query Spec]], set-time anatomy and the expiry pass in the session-closer skill (Steps 3.12-3.13). This guide covers activation: what must be true before the system is live, how to test it, and how to diagnose a flag that did not arrive.*

## The reader-path principle

The design rule under this whole system, named once so it can be cited: **artifacts routed by the writer's convenience rather than the reader's path fail silently, while looking like infrastructure.** A flag nobody sweeps, a feature request filed in the origin project's folders, a banner nothing queries -- each looks done at write time and delivers nothing. The design test for any coordination feature: *who reads this, and does their path cross it?* Orientation is the one guaranteed choke point where a reader's path can be enforced -- which is why the sweep lives there. (Conventions Registry: The reader-path principle.)

The flag system's own history is the cautionary tale: the write side shipped first and was measured twice at **0% delivery** -- dozens of files carrying `flag_for`, zero dismissals, for months -- because no read side existed. Do not consider the system live until the live test below passes.

## Preconditions (all of them, before any canary)

1. **Seed 1.3.0 or later installed** on the machine hosting the project (VERSION.md's What's New states "flags deliverable as of 1.3.0"). Check the local `Seed/VERSION.md`, not your memory of pushing it.
2. **Project Instructions v4.6 or later actually loaded** on every operator's surface -- pasted into Cowork project settings, or imported via the vault-root CLAUDE.md. *Shipped is not loaded* (see branch 0 of the diagnosis tree): each operator's surface upgrades independently, and the most likely first failure is an operator whose surface still runs the previous PI.
3. **The project's 0.0 updated**: it names the project as multi-operator (the flag sweep is gated on this), names the intake folders, and states the canonical-channel rule below.
4. **A queue page exists** (optional but recommended): create it from the Seed's flag-queue template so operators can see their whole queue between sessions. The vault data is the interface -- the page is a render surface, not the mechanism.
5. **The existing working channel stays canonical** (whatever the team actually uses today -- a messaging app, email) **until each person passes the live test.** State this in the 0.0. The vault machinery must earn its way to replacing the working channel, per person, test by test.

## The delivery chain (what "delivered" means)

A flag is delivered only when every link holds:

- **Link 1 -- write side.** The flag is set with the full anatomy: `flag`, `flag_by`, `flag_for`, a `flag_note` that states the decision needed and what proceeds on silence, and (for anything time-sensitive) `flag_due` + `flag_default`.
- **Link 1.5 -- instructions loaded.** The reading operator's surface runs the PI version that contains the sweep.
- **Link 2 -- instance side.** Their instance runs the orientation sweep and surfaces the item (the compliance trace in the claim stub / log entry proves this ran).
- **Link 3 -- human side.** The person starts a session in the project and responds to what the sweep surfaced.
- **Link 4 -- write-back.** The response lands in frontmatter: act removes the name; a conscious defer keeps it with `flag_status: deferred`.

## The executor chain (who enforces `flag_default`)

Silence becomes a decision through three layers, in order of immediacy: (1) the **orientation sweep** surfaces overdue items with their default, read-only -- it never stamps status; (2) the **closer's expiry pass** (Step 3.13) is the backstop and the only automatic writer of `flag_status: expired-unread`, keyed to `flag_due` with a 21-day backstop for undated flags, scoped to flags set on/after the ship date; (3) a **scheduled review job** is the eventual executor for low-cadence projects where closes are rare -- named here so nobody assumes layer 2 suffices everywhere; build it as a sibling of the project's review automation when the need is demonstrated.

## Rollout protocol (the live test)

1. Verify the preconditions above -- especially 1 and 2, per machine and per operator surface.
2. **Plant one canary flag per operator**: a trivial note flagged for exactly that person, `flag_note` asking only "have your Claude take your name off this," a `flag_due` about a week out, and `flag_default: recorded as chain-broken for [name]`. The dated `flag_due` is deliberate and load-bearing: live corpora run almost entirely undated flags (one team's first measurement: 1 of 88, and that one a `null` literal), so without a dated canary the due-first sort path ships untested.
3. **Tell each person through the currently-working channel** (the working channel bootstraps its successor): "sometime this week, start a session in this project and do what it tells you."
4. **Read the queue at the end of the week.** Name off = the whole chain verified for that person. Name still on = walk the diagnosis tree below and hold that specific hand.
5. **The working channel stays canonical for that person until they pass.** No instance should treat the flag system as authoritative delivery for an operator who has not passed.

## Diagnosis tree (name still on after the window)

Walk the branches in order -- each isolates one link:

- **Branch 0 -- did their surface load the new PI?** Check the sweep trace's PI version (`flag sweep [PI v4.6]: ...`) in their session logs, or ask what their project settings contain. If the surface runs an older PI, the instance and the human both behaved perfectly and the chain never had a chance: fix the paste/import, not the person. This is the most likely first failure.
- **Branch 1 -- no session started.** Nothing in the session log folder for that operator in the window. Link 3, human side: the ask never translated into a session. Re-send through the working channel; consider whether the person needs a lower-friction entry point.
- **Branch 2 -- session started, no sweep trace.** A log entry or stub exists but carries no trace line. Link 2, instance side: the sweep did not run (trace is unconditional -- a missing line is a broken sweep, never "nothing was waiting"). Check the PI text on that surface and the Query Spec's fallback notes (silent-`{}` parse failures, MCP result caps).
- **Branch 3 -- trace shows the item surfaced, name still on.** Link 3/4: the person saw it and did not respond, or responded and the write-back never landed (check for a `flag_status: deferred` -- that is a *pass*, not a failure: defer keeps the name by design). Distinguish by asking; if they acted but the name remains, it is a write-back failure -- check frontmatter merge behavior on that surface.

## First-render expectations

On a project with a pre-existing flag backlog, the first sweep and queue-page render will be **long, and the numbers will drift daily** -- treat any count as a point-in-time figure, not a target to match. One team's rollout measured 83, then 85, then 88 flagged files across three sweeps in about a day and a half, with per-person queues in the dozens; 18 of the flagged files changed within one day of a measurement. Two rules follow: (a) carry *probes, not snapshots* -- hand the next session the query to re-run, never a count to trust; (b) a long first queue is the backlog talking, not the page failing.

**The pre-existing backlog is exempt from the expiry pass** (flags set before the ship date are excluded by design -- they predate delivery, so expiring them as "unread" would falsify the record). Drain it with a dedicated triage session per project: refresh what is still live, clear what is done, and let genuinely dead items be cleared by hand -- never mass-expire.

## Scope boundaries

- **The sweep is project-scoped.** A flag in one project surfaces in that project's sessions only -- an operator's sessions in other projects will not see it. Operator-global sweeps across projects are a real future want but explicitly out of scope in v1; do not assume coverage that does not exist.
- **The sweep is read-only.** It never writes `flag_status` or clears names; act/defer are explicit operator responses, and the closer's expiry pass is the only automatic writer. (Decision record: D117.)
- **Flag budget discipline holds at rollout too:** at most 2-3 new flags per close, `flag_note` always stating the decision and the default. A canary wave is the one sanctioned exception (one per operator).
