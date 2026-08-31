---
created: 2026-08-31
edit_log:
  - 2026-08-31 - created (Operator Gate Queue codification; DataWizard)
status: active
title: Operator Gate Queue - Template
type: template
updated: 2026-08-31
---
*The single cross-project queue of deployment gates - things that are built (or decided) and waiting on a specific actor to bring them live. One file per deployment (the primary project hosts it; it covers all projects). Schema, lifecycle vocabulary (`designed -> built -> installed -> verified-live`), feeding rule, and exit ceremony are canonical in the Conventions Registry's **Operator Gate Queue** entry - read that entry before working this file.*

*Read this when you have native bandwidth and want to unblock things. Rows are grouped by class: A time-sensitive, B quick unlocks, C native batch, D setup and installs, E waiting on people, F stale micro-items. A row leaves this file only through the exit ceremony (verified-live -> Deployed section -> infrastructure registry) or an explicit Parked entry. Two rules at point of use: verify a gate's live state before working its row; a park reason names which is dormant (project vs thread).*

Wire this file as the third layer of the project's 0.5 action-items shell (embed below the backlog) and add a 0.0 Key Pointer.

## A - Time-sensitive

### G-001 Example gate (replace me)
- who: Operator-A | project: ProjectName | arc: T1 | state: installed | est: 15 min
- action: relaunch the app so the edited config loads; confirm the new behavior once
- unblocks: the nightly job runs on the new schedule
- clock: config drift accumulates until relaunch
- source: [[Build Plan or Design Doc]] | added: S-NNN

## B - Quick unlocks

## C - Native batch

## D - Setup and installs

## E - Waiting on people

## F - Stale micro-items

## Parked

## Deployed
