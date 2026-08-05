---
title: Browser and File System Access Behaviors
type: guide
created: 2026-08-05
updated: 2026-08-05
operator: Andrew
status: active
edit_log:
  - DW-S244 2026-08-05 - created; File System Access API + artifact-context + DOM/CSS gotchas from building a single-file repo-resident HTML tool
---

# Browser and File System Access Behaviors

Runtime gotchas for a **single self-contained HTML tool** that reads and writes local files directly from the browser (no server) — the pattern where one `.html` file lives inside the repo it operates on and the team opens it in a browser. Part of the Platform and Environment Behaviors cluster (see `GUIDES.md`). These are browser/runtime facts, distinct from MCP behavior (see `MCP Reliability and Write Verification`) and from how the content methodology works.

## File System Access API (the read/write path)

- **Chromium only.** `showDirectoryPicker()` and writable folder handles exist in Chrome/Edge, not Safari or Firefox. A tool that must write files is Chromium-only by design; say so rather than papering over it.
- **It works from a `file://` page.** The directory picker and read/write work when the HTML file is opened directly from disk — no web server needed.
- **Persist the grant across reloads with IndexedDB.** Store the returned `FileSystemDirectoryHandle` in IndexedDB; on next load, retrieve it and re-verify permission instead of re-prompting. The handle survives reloads; the *permission* may need re-confirming (next point).
- **Read → read-write upgrades with one prompt.** A handle granted read-only upgrades via a single `requestPermission({ mode: 'readwrite' })` on the *existing* handle — no need to make the user re-pick the folder.
- **Permission calls must be the first `await` in the gesture handler.** `showDirectoryPicker()` and `requestPermission()` require a live user gesture. If either is called *after* another `await` in the same handler, it throws "must be handling a user gesture." Structure connect/reconnect flows so the picker or permission request is the first thing the click handler awaits; do any async prep after the grant, not before.
- **Folder-scoped grants can't walk upward.** If the user grants a subfolder, anything above it is unreachable — e.g. a repo's `.git/HEAD` is not readable when only a data subfolder was granted. Design features to degrade: things that need the parent (branch display, sibling files) become optional; anything computable from the granted subtree (file mtimes, the files themselves) is the reliable signal.

## Artifact / embedded contexts block local persistence

- A page running as a **Cowork/Claude artifact** (or otherwise sandboxed/embedded) **cannot use the File System Access API, IndexedDB, or `localStorage`.** Any feature built on those — folder access, remembered handles, a persisted user identity or preference — silently has no backing store there.
- Consequence: a tool meant to run *both* directly-in-browser *and* in an artifact needs a **pluggable data adapter** with a second implementation for the embedded context (e.g. an MCP bridge for data, and a non-`localStorage` source for any per-user setting). Detect the environment at startup and pick the adapter. Don't assume browser storage exists.

## DOM / CSS gotchas

- **The `hidden` attribute loses to a class that sets `display`.** The user-agent rule `[hidden] { display: none }` is a plain element selector; any class rule that sets `display` on the same element overrides it, so the element stays visible despite `hidden`. Fix: add an explicit `.yourclass[hidden] { display: none }` rule for any element you toggle with `hidden` that also carries a `display`-setting class.
- **`color-scheme` makes native form controls legible in dark mode.** Set `color-scheme: light` / `color-scheme: dark` (per theme) so native `<input type="date">`, `<select>`, and scrollbars follow the theme. Without it, native controls render light-on-light (or dark-on-dark) and become unreadable when the surrounding UI is themed.

## Verifying a browser file-tool without a server

- The real folder picker can't be automated (it needs a user gesture), so **make the data layer a pluggable adapter and inject a mock adapter for tests.** With a headless browser (e.g. Playwright), inject in-memory fixture data via an init script, then drive the *real* DOM and assert against both the DOM and the mock's in-memory files. This exercises the actual render + write code paths end-to-end with zero server and zero real filesystem, and catches console errors as a hard failure.
- Keep the shipped file data-free (the deliverable that lands in the repo); build any embedded-demo variant separately so fixtures never ship.
