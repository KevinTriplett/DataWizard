---
title: FSAccess GUI Pattern
type: guide
created: 2026-09-04
updated: 2026-09-04
operator: Andrew
status: active
edit_log:
  - DW-S328 2026-09-04 - created (Chunk 1 - skeleton + Sections A-E; supervised build, S327 charter)
  - DW-S328 2026-09-04 - Chunk 2 - Sections F-K written; GUIDES.md Surfaces and tools entry added
  - DW-S328 2026-09-04 - fold-in markers (B/D) resolved as generic-non-blocking (operator ruling); status draft -> active
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

Environment detection at startup selects the adapter. The baseline implementation is the File System Access adapter - desktop Chromium, and it must work; a hosted or bridged adapter is a second slot for contexts where direct file access is unavailable. The recommended stance is to design the interface for the direct-access and hosted cases now and treat an embedded artifact context as a later concern: an artifact context cannot use the File System Access API, IndexedDB, or `localStorage` (see `Browser and File System Access Behaviors.md`), so its adapter needs a bridged data path and a non-`localStorage` source for identity.

## Permission and grant scope

Grant the narrowest folder that holds the data, not the repo root. Least exposure is the security reason; the practical reason is that a narrow, specific grant is far easier to ask another operator to give ("open this one folder") than a whole-repo grant. Resolve the folder adaptively so a root grant, a mid-level grant, or the data folder itself all work - search downward for the data files and prefer the canonical path when more than one layout is possible - so no operator is turned away for granting at the wrong level.

Persist the grant so returning operators are not re-prompted, restore it silently on load, and re-check permission rather than assuming it still holds. Upgrading a read grant to read-write is a permission prompt on the same handle, never a re-pick - the scope does not change, only the mode. (The persistence mechanism, the one-prompt upgrade, gesture safety, and the fact that a folder grant cannot read anything above it are runtime facts - see `Browser and File System Access Behaviors.md`.)

One interaction convention the runtime forces into the UI: keep **Connect** and **Reconnect** as two separate affordances. Connect always opens a fresh picker; Reconnect re-attaches or upgrades a remembered grant. Collapsing them into one button lets a stored handle hijack the primary action, so an operator who wants to point at a different folder cannot. Two buttons, two jobs. Re-read the data on window focus and offer a manual reload, so a surface left open overnight is never trusted stale.

## Operator identity and attribution

The surface holds a persisted identity - who this operator is - seeded from the team config and settled once. Keep it strictly separate from any view *filter*: "who I am" and "whose items I am looking at" are different questions, and merging them means an operator filtering to a colleague's items silently starts writing as that colleague.

Any write that attributes - a note, a decision, a sign-off - must be **refused, not silently dropped,** when no identity is set. A silent drop looks like success and loses the write; a refusal tells the operator to set their identity first. When the surface matches an operator's display name against a handle, match case-insensitively - a display name and a handle that differ only in case are the same person, and a case-sensitive compare is a quiet mismatch that drops or misfiles attribution.

Name the audit asymmetry in the surface's own terms so a team adopts it consciously: a self-asserted identity - the operator picks who they are - and an attributed identity - an authenticated sign-in - are not equal-strength trails. The direct-access surface is self-asserted; a hosted path may be authenticated. That is fine for a trusted team, but a self-asserted trail must never be read later as if it were authenticated.

## The concurrency guard

Every write goes through one guarded commit loop - never a bare write - because the repo is shared and a sync tool may change a file under the surface between load and save. The loop:

1. Re-read the file from disk (`readFileText`).
2. Compare its current text against the text the surface parsed. On any difference, reload and warn - do not overwrite. mtime is a cheap fast-path hint only; sync tools touch mtimes without changing content, and content can change with a preserved mtime, so content is the authority.
3. Apply the edit to the current text - the surgical serializer (see The surgical serializer).
4. Write the new text.
5. Re-read and verify the write landed as intended; on a mismatch, reload and warn.

The compare-before-write step narrows the race window; the post-write verify is what actually closes it, catching the case where the write did not land as the surface believed. Route every kind of edit - a toggle, a field change, an inserted note - through this one loop, so there is exactly one place where a write can touch disk, and exactly one place to audit.

## The surgical serializer

This is the load-bearing section: how the surface changes a file without corrupting it. The wrong approach is to parse a file to a structure, mutate the structure, and re-serialize the whole thing back to text. Two reasons rule it out. First, a re-serializer works from the parsed structure, and a parser routinely holds computed state that was never in the file - a value the surface derived at read time, such as a status the dependency resolver set to "blocked". Re-serializing emits that derived value as an authored token, writing the surface's own inference into the data. Second, a useful parser is lossy on token order and exact position - it normalizes as it reads - so byte-faithful reconstruction is impossible, and every untouched line comes back subtly reformatted. In a repo synced across a team, that turns one intended edit into a diff touching every line of the file: unreviewable, and a merge-conflict magnet.

The pattern instead makes every write a **surgical token edit that shares the parser's own regex constants**. There is one grammar, used in both directions: the parser reads the first match of a token, and the writer replaces the first match of the same token - replace-first mirrors first-match parse. Four requirements, all load-bearing:

1. **Locate the target line by trimmed equality against the real file text, and preserve its original bytes.** Match on the trimmed line, but keep the original leading indentation, trailing whitespace, and line ending (LF or CRLF) when writing the change back. Never reconstruct the line from the parsed representation - the parser trimmed it, so a reconstruction loses indentation and endings.
2. **Exactly one match, or abort.** Zero matches or more than one both throw and write nothing. Unique IDs make collisions unlikely, but stale data contains duplicates, and a blind write into an ambiguous match is how the wrong line gets edited.
3. **Never serialize computed state; flip only the token the operator edited, in isolation.** The edit changes exactly the one token the operator changed, taken from the explicit user action - never read back from the parsed structure, which may carry derived values (this requirement flows from the re-serializer problem above).
4. **Test with whole-file byte-identity round-trips, not per-line checks.** The test mutates one token and asserts that every other byte in the file is unchanged AND that re-parsing the result yields the expected structure. Per-line tests miss exactly the corruption this section exists to prevent.

One rule sits alongside requirement 3 whenever the grammar gives **parse-time precedence between two tokens that express overlapping state** - a completion mark and an inline status token, say, where the parser lets one win and ignores the other at read time. The surface writes only the winning channel and disables the edit that would emit the losing one. A token the parser ignores at read time is dead text; writing it is a silent no-op that looks to the operator like a successful edit. One channel per piece of state, and the UI does not offer the dead one.

Supporting rules for the common cases. Frontmatter edits scan only between the opening and closing `---` fences, so a body line that happens to contain `key:` can never collide; when replacing a value, preserve that line's existing quote style, and insert the key if it is absent (quoting a new date-like value). A token clear consumes exactly one adjacent space, leaving no double space and no trailing space, and gets its own round-trip case. An inserted detail line goes at the end of the item's own detail block, with an indent fallback when the item has no existing detail lines to match. And if the convention stamps modification metadata on write - bumping an `updated:` field, say - fold that into the same guarded write idempotently, and re-tighten the byte-identity assertion to allow exactly the intended line plus the stamp line to change, every other byte identical.

## Parser certification against an oracle

When the surface's parser twins an existing reference parser - a script that already reads the same files - the reference is the oracle, and the new parser must match it exactly: same files in, same structure out, zero diffs. Certify over two corpora: the live data, and a synthetic fixture that exercises every branch of the grammar (each token type, each detail kind, nesting, edge inputs). Keep canon corrections and display cleanup in the VIEW layer, never the parser, so the oracle comparison stays literal - the moment the parser "improves" on the reference, the diff stops being meaningful. Re-run the oracle diff at every parser change; a change confined to the view layer holds the property by construction and needs no re-run. Where no reference parser exists, write the fixture corpus first and treat it as the oracle - the certification target has to exist before the parser it certifies.

## Derived-surface rules

Any surface that renders a view computed from parsed files carries four obligations, because a derived view that is silently wrong is worse than no view.

- **A generation stamp:** show what was read and when. A derived surface either regenerates automatically or displays its own freshness prominently; without the stamp, a stale render is indistinguishable from a fresh one.
- **Silent-drop counters:** every class of input the parser discards gets a visible counter or warning - an unresolved embed, an unknown key, an unparseable item, a value it could not key. Skipping malformed input is usually the right behavior; the invisibility of the skip is the defect, because it turns dropped data into apparent absence.
- **Embed-aware parsing:** follow transclusion or embed references when the source files use them. Sectioning of a tracked surface is a moving front - a file that was one document last week is a shell of embeds this week - and a parser that does not follow embeds silently under-counts as soon as that happens.
- **Untracked, not absent:** a source the surface cannot yet read renders as an explicit "untracked" row, not as nothing. Absence is itself a signal the reader wants to see; a blank where a row belongs hides it.

## The surface as a data-integrity check

The validation the data needs - unresolved reference IDs, unknown status values, missing IDs, orphaned links - belongs on the surface everyone already opens, because the validation and the display are the same read: the parser already visited every file to render the view, so surfacing what it found wrong costs almost nothing and reaches the one place the team looks. Present the findings as header chips or counters. Keep the surface read-only by default; the write path is an explicit, guarded opt-in, never the resting posture - a surface people trust to look at should not also be one stray click away from changing files.

## Git-awareness scope

In scope, and load-bearing: an **mtime freshness banner** - "pull before trusting this view" when the files look older than the repo's activity would suggest. It works at any grant scope, because file mtimes are always inside the granted subtree. Optional garnish: a branch display via `readAux('.git/HEAD')`, reachable only when the repo root itself was granted, so it degrades to nothing under a narrower grant. Out of scope: committing or pulling from the page - a browser page cannot drive git without a helper process, and the repo's existing sync habit is the transport. The surface's job is to read honestly and warn when the read may be stale, not to become a git client.

## Boundaries and testing floor

State the boundaries plainly rather than papering over them. The write path is desktop-Chromium only - no other browser exposes writable folder access - and that is a design boundary, stated, not a bug to hide. There is no inter-surface messaging: two operators' open pages coordinate through the files and the repo's sync, never through each other.

The testing floor a conforming surface must clear before it moves from a read view to one that writes real files:

- the oracle diff (Parser certification) green over live data and the all-branch fixture;
- the serializer round-trip suite (requirement 4 above) green, including the clear and insert edge cases;
- a headless DOM end-to-end run - driving the real render and write code paths against injected fixture data - with zero console errors treated as a hard failure;
- hands-on validation on a scratch copy of live data before any write path touches the real files.

The headless-run mechanics (a mock adapter injected into a real DOM) and the rule that the shipped file carries no embedded data are runtime facts - see `Browser and File System Access Behaviors.md`, "Verifying a browser file-tool without a server."
