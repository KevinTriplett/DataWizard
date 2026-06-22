---
title: Cowork Scheduled Tasks
type: guide
scope: seed
created: '2026-06-15'
updated: '2026-06-22'
operator: Andrew
edit_log:
  - DW-S185 2026-06-15 - created from S160-S171 meta-learning review (4 deferred
    scheduled-task learnings)
  - DW-S195 2026-06-22 - joined the Platform and Environment Behaviors cluster
    (pointer)
---

# Cowork Scheduled Tasks

> Part of the **Platform and Environment Behaviors** guide cluster -- see `GUIDES.md`.

Operational guidance for running DataWizard automation as Cowork scheduled tasks (the nightly meta-learning and content-interest scans, hourly enrichment batches, and similar). These are platform behaviors learned from running real scheduled tasks; design task prompts and cadences around them.

## Timezone: use the operator's actual offset

`fireAt` timestamps are interpreted against a timezone offset. A task scheduled with a PDT offset for a CET-based operator fired 9 hours off. Always set `fireAt` using the operator's actual timezone offset, and sanity-check the first computed fire time against wall clock before trusting the cadence. (S160)

## One model per run: no mid-run switching

A scheduled task runs on a single model for its entire run; it cannot switch models partway through. Mixed-model workflows (for example a Sonnet extraction pass plus an Opus review pass) must be split into a two-task architecture: one task per model, each on its own cadence. The corpus-enrichment skill's Sonnet-batch-plus-separate-Opus-review pattern is the worked example. (S160)

## Cron jitter: expect up to ~8 minutes

Tasks fire with up to roughly 8 minutes of jitter past their cron time. Hourly cadence held reliably across 7 consecutive runs. Do not design tasks that assume firing exactly on the minute, or that two tasks scheduled close together fire in a guaranteed order; space dependent tasks apart. (S165)

## Requirements for reliable unattended automation

A task that runs without a human in the loop needs all of:

- **Self-contained prompt.** Everything the run needs stated in the prompt itself: source folder, output folder, config identifiers, and the governing skill. No reliance on conversation context, which the run will not have.
- **Deterministic batch ordering.** Process items in a stable, sorted order so reruns and resumes are predictable.
- **Existing-output detection (idempotency).** Check whether an item's output already exists before producing it. This is what makes a task safe to re-fire, and it is the guard against context-compaction re-stamping: when a long run's context compacts mid-task, the instance can lose track of what it already wrote and redo or re-stamp work. An existing-output check plus post-write verification prevents duplicate or re-stamped output.
- **Persisted tool approvals.** Obsidian MCP (and any other) tool approvals must be granted on a manual first run before automated firing works; without them the task stalls waiting on an approval no one is there to give. (S165)

## Other known failure modes

- **Runtime-constructed URLs.** `web_fetch` inside a scheduled task rejects URLs constructed at runtime (discovered mid-run rather than passed in the prompt). For URLs the run discovers, route through the Chrome MCP instead.

## See also

- corpus-enrichment skill (`Workshop - DataWizard/Skills - DW Workshop/`) -- its Scheduled Task Setup section is the worked enrichment example
- meta-learning-scan skill -- the nightly report-generation task much of this guidance came from

---

*Source: DataWizard S160-S171 meta-learning review (planted DW-S185).*
