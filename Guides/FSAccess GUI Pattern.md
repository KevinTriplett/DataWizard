---
title: FSAccess GUI Pattern
type: guide
created: 2026-09-04
updated: 2026-09-04
operator: Andrew
status: draft
edit_log:
  - DW-S328 2026-09-04 - created (Chunk 1 - skeleton + Sections A-E; supervised build, S327 charter)
---

# FSAccess GUI Pattern

A team needs a shared view onto structured files that live in a git repo - task records, a status ledger, a directory of entities - and needs to make small edits to them. This guide is the canonical pattern for building that as **a single self-contained HTML file that lives inside the repo it serves**, reads and writes the files directly in the browser, and needs no server and no background process.

It is written for a builder who has a working reference, or a data format and a set of views in mind, and wants the conventions that make the surface safe to ship to several operators. Companion guide: **`Browser and File System Access Behaviors.md`** holds the browser and runtime facts this pattern stands on - the File System Access API, artifact-context limits, DOM/CSS gotchas, headless testing. This guide holds the architecture and conventions built on those facts; where a runtime fact is load-bearing it is referenced by a one-line pointer, not restated.

Throughout, "the data" means item files in a granted folder, and the actors are Operator-A, Operator-B, and so on - the pattern is independent of any particular file grammar.

## When to use this pattern

Use it when the data is a set of text files in one repo, the team already syncs that repo (git, or a sync tool over the working tree), and the edits are small and structured - toggles, status changes, short notes - not free-form authoring. The surface is one `.html` file committed alongside the data. It is versioned with the repo, so a bug fix or a new view reaches every operator through the normal pull. Porting to another repo is copy one file and edit its embedded config block; there is nothing else to install.

The reason it is one file with no server is delivery, not minimalism. A server-based surface dies of launch friction: every operator has to start a process and keep a tab pointed at it, and that cost is paid once per operator, every day - the surface stops getting opened, and the data behind it goes stale. A file that opens with a double-click and remembers its folder removes that cost.

Do not use it when the job is aggregating across several repos before even two repos carry the pattern - build the single-repo surface first and generalize once there is a second - or when the data must be reachable from a phone: the write path is desktop-Chromium only (see Boundaries and testing floor).

Two truths about deploying one, both learned the hard way:

**Never launch over data that is not yet trusted.** If the files carry wrong or stale values on the day the surface goes live, the first thing every operator sees is wrong, and the surface never recovers that first impression. Gate rollout on the *data* being trustworthy - a reconciliation done, a cleanup landed - not on the *build* being finished. The build can be ready well before it should ship.

**The surface alone is not the fix.** A view over a data layer that nobody writes to goes stale exactly like whatever it replaced - the problem was never the window, it was the writing habit behind the data. The surface is worth building only alongside the habit that keeps the data current: a close-out step, a scheduled pass, a human routine. Ship the two together, or the surface becomes another dead dashboard.

## The adapter interface

The data layer is a single pluggable adapter behind one interface; the parser and the views are adapter-agnostic and never touch the filesystem directly. This is the structural spine of the pattern - it is what lets the same parser and views run against a real local folder, an in-memory mock for tests, and later a hosted or bridged data source, by swapping only the adapter.

The canonical interface:

- `pick()` - open the folder picker and take a fresh grant; resolve and remember the handle.
- `restore()` - silently re-attach a remembered grant if one exists and its permission still holds.
- `regrant()` - upgrade or re-confirm a remembered grant that needs a permission prompt.
- `listFiles()` - return every data file as name plus mtime.
- `readFileText(name)` - return one file's text plus mtime.
- `writeFile(name, text)` - write one file's full text; return the new mtime.
- `readAux(rel)` - best-effort read of a file outside the data set (e.g. a repo's `.git/HEAD`); may return nothing.

Two rules on the contract. `listFiles()` returns name and mtime only, not text; `readFileText(name)` is the single-file re-read that the concurrency guard and the post-write verify both depend on, so it is a required method in its own right. A given implementation may prefetch text in its list call as an optimization - that is permitted, but it is not part of the interface, and a second implementer must not assume it. And mtime rides on both `listFiles()` and `readFileText()` because it is the freshness probe the whole surface reads from.

Environment detection at startup selects the adapter. The baseline implementation is the File System Access adapter - desktop Chromium, and it must work; a hosted or bridged adapter is a second slot for contexts where direct file access is unavailable. The recommended stance is to design the interface for the direct-access and hosted cases now and treat an embedded artifact context as a later concern: an artifact context cannot use the File System Access API, IndexedDB, or `localStorage` (see `Browser and File System Access Behaviors.md`), so its adapter needs a bridged data path and a non-`localStorage` source for identity. [Fold-in point: raise here if the artifact-context probe has run.]

## Permission and grant scope

Grant the narrowest folder that holds the data, not the repo root. Least exposure is the security reason; the practical reason is that a narrow, specific grant is far easier to ask another operator to give ("open this one folder") than a whole-repo grant. Resolve the folder adaptively so a root grant, a mid-level grant, or the data folder itself all work - search downward for the data files and prefer the canonical path when more than one layout is possible - so no operator is turned away for granting at the wrong level.

Persist the grant so returning operators are not re-prompted, restore it silently on load, and re-check permission rather than assuming it still holds. Upgrading a read grant to read-write is a permission prompt on the same handle, never a re-pick - the scope does not change, only the mode. (The persistence mechanism, the one-prompt upgrade, gesture safety, and the fact that a folder grant cannot read anything above it are runtime facts - see `Browser and File System Access Behaviors.md`.)

One interaction convention the runtime forces into the UI: keep **Connect** and **Reconnect** as two separate affordances. Connect always opens a fresh picker; Reconnect re-attaches or upgrades a remembered grant. Collapsing them into one button lets a stored handle hijack the primary action, so an operator who wants to point at a different folder cannot. Two buttons, two jobs. Re-read the data on window focus and offer a manual reload, so a surface left open overnight is never trusted stale.

## Operator identity and attribution

The surface holds a persisted identity - who this operator is - seeded from the team config and settled once. Keep it strictly separate from any view *filter*: "who I am" and "whose items I am looking at" are different questions, and merging them means an operator filtering to a colleague's items silently starts writing as that colleague.

Any write that attributes - a note, a decision, a sign-off - must be **refused, not silently dropped,** when no identity is set. A silent drop looks like success and loses the write; a refusal tells the operator to set their identity first. When the surface matches an operator's display name against a handle, match case-insensitively - a display name and a handle that differ only in case are the same person, and a case-sensitive compare is a quiet mismatch that drops or misfiles attribution.

Name the audit asymmetry in the surface's own terms so a team adopts it consciously: a self-asserted identity - the operator picks who they are - and an attributed identity - an authenticated sign-in - are not equal-strength trails. The direct-access surface is self-asserted; a hosted path may be authenticated. That is fine for a trusted team, but a self-asserted trail must never be read later as if it were authenticated. [Fold-in point: reconcile here if the hosted-adapter identity handling diverges.]

## The concurrency guard

Every write goes through one guarded commit loop - never a bare write - because the repo is shared and a sync tool may change a file under the surface between load and save. The loop:

1. Re-read the file from disk (`readFileText`).
2. Compare its current text against the text the surface parsed. On any difference, reload and warn - do not overwrite. mtime is a cheap fast-path hint only; sync tools touch mtimes without changing content, and content can change with a preserved mtime, so content is the authority.
3. Apply the edit to the current text - the surgical serializer (see The surgical serializer).
4. Write the new text.
5. Re-read and verify the write landed as intended; on a mismatch, reload and warn.

The compare-before-write step narrows the race window; the post-write verify is what actually closes it, catching the case where the write did not land as the surface believed. Route every kind of edit - a toggle, a field change, an inserted note - through this one loop, so there is exactly one place where a write can touch disk, and exactly one place to audit.

## The surgical serializer

_The load-bearing section: why a lossy parser rules out structure-to-text re-serialization, and the four requirements for surgical token edits that share the parser's own grammar. Written in the next pass._

## Parser certification against an oracle

_Twinning a new parser against a reference parser (0-diff over the live corpus and an all-branch fixture), keeping canon corrections in the view layer, and what to do when no reference parser exists. Next pass._

## Derived-surface rules

_Generation stamp, silent-drop counters for every class of discarded input, embed-aware parsing, and rendering untracked sources as untracked rather than absent. Next pass._

## The surface as a data-integrity check

_Validation on the surface everyone already opens - unresolved references, unknown values, missing IDs - as the same read that renders; read-only by default, writes an explicit guarded opt-in. Next pass._

## Git-awareness scope

_In: an mtime freshness banner that works at any grant scope. Optional garnish: branch display via readAux, root grant only. Out: commit and pull from the page. Next pass._

## Boundaries and testing floor

_Desktop-Chromium-only, stated not papered over; no inter-page messaging; and the testing floor a conforming surface must clear before any write path touches real files. Next pass._
