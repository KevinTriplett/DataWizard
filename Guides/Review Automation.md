---
title: "Review Automation"
type: guide
created: 2026-08-06
updated: 2026-08-18
operator: Andrew
edit_log:
  - "DW-S250 2026-08-06 - created: pending-report model + review-cadence
    single-home (D114 relocates D88)"
  - "DW-S273 2026-08-18 - Stamping paragraph split by review type: meta-learning
    stamps reviewed-through session, not current"
---

# Review Automation

How a DW project keeps its three periodic reviews current without nagging the operator at every session close.

## The model

Three reviews run on a cadence: the **project health audit**, the **meta-learning review**, and the **Content Interests refresh**. Detecting that one is due, and running the detection scan, is the job of scheduled automation -- not the session-closer. The session-closer's only related job is to surface a report that a scan has already produced and left waiting for review (`status: pending-review`). See session-closer Step 3.10.

Two moving parts:

1. **Scheduled review-status check (automation).** A daily task reads the project's `0.0 Project Guidelines` stamp fields, computes staleness against the cadence table below, and when a review is due runs that review's scan. The scan writes a report to the project's Learning Reports folder with `status: pending-review`, and notifies the operator. It does **not** plant -- planting stays gated on human review.
2. **Session-closer surfacing (Step 3.10).** At a full close, the session-closer lists the Learning Reports folder for any `status: pending-review` report and, if found, adds one line to "What's next" naming the file. If none, it says nothing. The session-closer holds no cadence numbers and does no gap arithmetic.

This replaces the older pattern where the session-closer computed gaps and nudged at every close. When the stamps went stale -- which they do whenever a review is heavyweight enough that the operator keeps deferring it -- the "or never recorded / field absent" trigger fired on every close and became noise, which kept the stamps stale: a self-sustaining nag loop (D114).

## Cadence table (single home)

These numbers live here and nowhere else (D114, relocating D88). Every other doc -- SKILLS.md, the PI, the session-closer, the 0.0 -- describes the reviews without quoting numbers.

| Review | Stamp field (on 0.0) | Due when | Scan producer | Pending report |
|---|---|---|---|---|
| Project health audit | `last_health_audit` | 30+ sessions since, or never recorded | `dw_lint` (machine half of `project-health-audit`) | `Health Audit Report - *.md` |
| Meta-learning review | `last_meta_learning_review` | 30+ sessions since, or never recorded | `meta-learning-scan` | `Meta-Learning Report - *.md` |
| Content Interests | `last_content_interests_review` | 30+ days since, OR 10+ sessions since, OR field absent | `content-interest-scan` | `Content Interests Report - *.md` |

**Gap arithmetic** (used by the scheduled check, not the session-closer): solo-operator projects subtract session numbers; multi-operator projects count session-log files dated after the reference session; day-based checks compare calendar dates.

**Stamping.** A review is complete only when its report has been reviewed and planted. On completion, stamp the corresponding field on the 0.0 -- that is what stops the review from re-firing. Which value to stamp depends on whether the review has a scan range:

- `last_meta_learning_review` takes the reviewed report's **end-of-scan-range session** (the reviewed-through point), not the current session. The next scan starts after the stamp, so stamping the current session silently skips every session between the range end and the review session. The pending-report trigger surfaces any unreviewed report regardless of the stamp, so accurate stamping does not silence the next chunk. Review one report per session.
- `last_health_audit` and `last_content_interests_review` have no scan range; they take the current session ID (or date, for Content Interests).

A report that has been produced but not yet reviewed stays `pending-review`; the stamp advances only on completion, never at report-production time.

## Report locations

`{home}/Workshop - {ProjectName}/Learning Reports/` for full-convention projects; `{home}/Learning Reports/` for flat projects.

## Scheduled automation

The scheduled review-status check is wired per operator -- it is not shipped in the Seed, because scheduling is machine-specific. Its job is always: read stamps -> compute staleness -> on a trip, run the scan -> write a `pending-review` report -> notify. It never plants unattended.

### Substrate: prefer GitHub Actions for git-synced vaults

Which harness works depends on where git can actually push:

- **GitHub Actions cron (preferred when the vault is a git repo).** A scheduled workflow on the vault's own repo runs on GitHub's infrastructure at the cron time -- no operator machine awake, no desktop app open. It has native write access via the built-in `GITHUB_TOKEN` (no personal token to store), pulls the repo, runs the scan by calling the Claude API, writes the `pending-review` report, commits, pushes, and notifies by opening a repo issue (the report also syncs down to the vault, where the session-closer surfaces it). This sidesteps both the "wake the machine" problem and the Cowork cloud git proxy.
- **Cowork scheduled task.** A fresh Cowork session fired on a schedule. Viable only when the operator's machine is awake and the desktop app is open at fire time (so the vault bridge is live) AND the target repo is in the session's authorized sources -- the Cowork cloud routes git through a proxy that refuses pushes to repos outside that set (see the **Cowork Scheduled Tasks** guide). Both conditions are fragile for an overnight run, so prefer GitHub Actions whenever the vault is a git repo.

The scan producers are the same regardless of substrate; only the harness differs. For Cowork-scheduled-task specifics (timing, one-model-per-run, cron jitter, idempotency), see the **Cowork Scheduled Tasks** guide.

### Producer maturity

As of 2026-08: `meta-learning-scan` produces its report today. `content-interest-scan` is a draft (v0.1). `project-health-audit` is a judgment-half skill -- only its machine half (`dw_lint`) runs unattended, producing a lint-based Health Audit Report for the operator to pick up; the judgment pass and planting stay human. Until a producer is finalized into the scheduled check, the session-closer simply finds no pending report for that review and stays silent.
