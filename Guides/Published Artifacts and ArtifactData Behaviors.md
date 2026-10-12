---
title: Published Artifacts and ArtifactData Behaviors
type: guide
created: 2026-10-12
updated: 2026-10-12
operator: Andrew
scope: seed
status: active
edit_log:
  - 'DW-S398 2026-10-12 - created (board intake: eleven artifact behaviors consolidated from four projects)'
  - 'DW-S400 2026-10-12 - Publishing: data-file-only republish needs the page, self-saving page merge; new Local testing and vault copies section (viewer reset, window.claude mock, fragment skeleton) (ReWoven FR intake)'
---
# Published Artifacts and ArtifactData Behaviors

> Part of the **Platform and Environment Behaviors** guide cluster -- see `GUIDES.md`.

## Purpose

Runtime behaviors of published claude.ai artifacts (the Artifact tool: publish, read) and of an artifact's shared store (the ArtifactData tool and the page `db` capability). These are the gotchas that cost extra calls or silently lose data when an instance builds, republishes or feeds a published page. New artifact or ArtifactData behaviors append here rather than being re-derived.

**Scope.** Desktop-app Cowork artifacts (no URL, frozen data) and the chat-preview-vs-published routing rule live in **Cowork Build Environment** (Device Bridge section). Browser storage limits in embedded contexts live in **Browser and File System Access Behaviors**. Reading artifact links from a web context lives in **Chrome MCP and Web Tool Behaviors** (web_fetch Behaviors).

## Publishing

**Republishing needs a "viewed" read of the live source, and a `path` read does not count.** The live version counts as viewed when it is read in full: an `Artifact read` of the URL without `path` (brings the whole page into context), or every line of a saved copy read with the Read tool (about 25k tokens per Read call, so a 75 KB page takes two calls). Partial reads made before a refusal are not counted, and a read with `path: index.html` saves the page to a file but does not count as viewing it. A republish therefore typically costs three calls: read, read, publish for a two-part Read of a 75 KB page, or three publish attempts when nothing was viewed first (next item). (Holonic Canvas, 2026-10)

**A refused publish saves the live source; diff it before you re-publish, then resend.** The first publish without a view is refused with a line diff and the live page's full source saved to a local file (path in the error); that refusal counts as the view. Diff the saved file against your base - if the live page holds only your base plus the publish skeleton, there is nothing to merge; if it holds someone else's edits, merge them first. Sending the same file again is refused once more as "identical content resent", and the next identical send publishes (sequence seen: refused, refused as unchanged, publishes). (Holonic Canvas, 2026-10)

**Publish recipe for a hand-built full-document page.** Strip the first 5 skeleton lines and the `</head><body>` the tool adds around the page, keep the theme with a one-line script, and smoke-test the page inside a fake artifact skeleton before publishing. Rendering it once locally is the one use the cloud container's headless browser is good for (see **Chrome MCP and Web Tool Behaviors**, Claude-in-Chrome section). (Evolutionary Media Commons, 2026-10)

**A data-file-only republish still needs the page.** A `publish` with `url` and `files` alone is refused ("also pass file_path"). To change only a data file (for example a `canvas.json`), pass the unchanged page as `file_path` together with `files`; the viewed-read rule above applies to that page on the first such republish of a session. Afterwards, read `index.html` back with `path` and compare its sha256 with your pre-publish copy to confirm the page did not change. A read copy of the page carries the publish skeleton, so republish from your own source copy or strip the wrapper first (recipe above). (ReWoven, 2026-10)

**A page that saves itself rewrites its data file under you.** With the `artifact` capability in its files form, every save from the open page rewrites the data file. To merge new records in: re-read the data file right before merging, add records (never rebuild the file), check with a script that every old record is unchanged, then publish. A viewer with the page open gets a conflict on their next save and reloads - tell them to reload. (ReWoven, 2026-10)

## Reading

**`Artifact read` needs the full `https://claude.ai/artifact/<id>` URL.** A bare `claude.ai/artifact/<id>` (or a bare id) is refused as "not an artifact URL". (Evolutionary Media Commons, 2026-10)

**A large read is saved to a tool-results file; only the head shows inline.** A ~700 KB page came back head-only, with the full HTML in a tool-results file; extract what you need (e.g. a baked data constant) from that file with a script rather than re-reading. (Holonic Canvas, 2026-10)

## ArtifactData store

**`list` with `out_dir` writes bodies only; versions live in the result text.** The files hold document bodies; versions appear only in the tool's result text, so a run that must pin writes captures them from there. A `~` in a document id is spelled `@` in the file name (map it back). Past 50 documents the result folds the rest into one text line (`[N more saved documents ... "<id>" <v>, ...]`), so a parser that reads only the per-line form sees a fraction of the collection; an empty collection prints `No documents matched` and makes no folder. (Holonic Canvas, 2026-10)

**Pinned writes are all-or-nothing.** A `batch` with any pinned entry is atomic: one stale pin returns `version_mismatch` naming the entry and its current version, and nothing is written. A pinned whole-document `set` (`if_version`) on a stale pin is refused the same way and lands on the current one. (Holonic Canvas, 2026-10)

**`update` merges nested objects; drop a key with the `__delete__` marker; keep bodies under ~850,000 bytes.** A key present in the store and absent from the body survives an `update`. `{"field": {"__delete__": true}}` removes it (proven live; the read-back carries neither the key nor a marker). Bodies near 1 MiB are refused - plan batches under ~850,000 bytes. (Holonic Canvas, 2026-10)

## Access and sharing

**Only the owner and Editors invited by email can write to an artifact `db`.** A Contributor, a Viewer or a public-link visitor reads only, and switching to a public link removes an outside Editor's write access - so a page that keeps shared state should tell the owner to invite collaborators by email as Editor, not share by link. `data/users/<id>/...` is private per person (good for per-person settings). (LocationScout, 2026-10)

## Rendering constraints

**The artifact CSP blocks images from any outside host, so tiled web maps go grey.** Scripts load from a few CDNs (cdnjs works), but OSM, CARTO or Esri tiles never load and show no error. The fix that worked: embed a vector basemap (an Overpass extract simplified to ~400 KB) and draw it with Leaflet on a canvas renderer with no tile layer, Leaflet CSS inlined. This extends the general CSP rule in **Cowork Build Environment** (Device Bridge: "Chat-delivered HTML previews run NO page scripts; published claude.ai artifacts run scripts but block external hosts"). (LocationScout, Rootland, 2026-10)

**Browser automation cannot act inside a published artifact's frame.** The page runs in a nested cross-origin frame; Claude in Chrome and the built-in browser pane cannot click, type, read or run script inside it. The store read-back is the only automatable evidence of what a page wrote - in-memory page state has to be read by the person or shown on the page. (Holonic Canvas, 2026-10)

## Local testing and vault copies

**A local render needs the viewer's reset, or `hidden` sections stay laid out.** A page is published without its own head; the viewer adds a reset that includes `[hidden]{display:none!important}`. Rendered bare, a hidden tab's SVG stayed in the layout and intercepted test clicks. When wrapping a page for a local render or a vault copy, include the reset: `:root{color-scheme:light}body{margin:0}img{max-width:100%}[hidden]:not([hidden=until-found i]){display:none!important}`. The rule that a class setting `display` beats `hidden` in your own CSS is in **Browser and File System Access Behaviors**. (ReWoven, 2026-10)

**Exercise `db` and `user` pages locally with a `window.claude` stand-in.** Load a small in-memory mock of `window.claude.use()` as a Playwright init script (Chromium launch: **Cowork Build Environment**, Verification Discipline for Builds) and drive the page before publishing. Keep the mock and a README beside the build. In one session it caught drop-target, undo and reorder bugs across eight publishes. (ReWoven, 2026-10)

**An artifact page saved to the vault as a standalone file is a fragment.** It has no `<!doctype html>`, `<html>`, `<head>` or `<body>` - the publisher adds them at publish time - so opened from disk it renders in quirks mode. Before shipping it as a standalone vault asset, prepend a document skeleton (doctype, `lang`, charset, viewport, plus the reset above) and wrap the body. (ReWoven, 2026-10)

## Related guides

- **Cowork Build Environment** -- device bridge, cloud container, desktop-app artifacts, the general artifact CSP rule
- **Chrome MCP and Web Tool Behaviors** -- driving web pages; reading artifact links (web_fetch Behaviors)
- **Browser and File System Access Behaviors** -- single-file browser tools, storage in embedded/artifact contexts
