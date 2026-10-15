---
title: Published Artifacts and ArtifactData Behaviors
type: guide
created: 2026-10-12
updated: 2026-10-15
operator: Andrew
scope: seed
status: active
edit_log:
  - 'DW-S398 2026-10-12 - created (board intake: eleven artifact behaviors consolidated from four projects)'
  - 'DW-S400 2026-10-12 - Publishing: data-file-only republish needs the page, self-saving page merge; new Local testing and vault copies section (viewer reset, window.claude mock, fragment skeleton) (ReWoven FR intake)'
  - 'DW-S403 2026-10-13 - Rendering constraints: no deep-link channel into a published page; Publishing: pre-publish byte check from a path read, recipe strips the trailing close tags (board intake B-0072, Holonic Canvas)'
  - 'DW-S403 2026-10-13 - Publishing: publish recipe gains a read-and-diff check against live and capabilities kept when omitted on republish (board intake B-0076 Evolutionary Media Commons)'
  - 'DW-S408 2026-10-15 - board intake plant: Publishing safety-check denial, small-merge recipe, byte-exact publish check, overlay mock-up; ArtifactData store file transfer, verified query/update/republish, cross-artifact batch move; Access admin-only root rules; new Comments from the operator section (Send to Claude channel, read all threads first); Local testing fake claude.use design (Holonic Canvas, LocationScout, Evolutionary Media Commons)'
---
# Published Artifacts and ArtifactData Behaviors

> Part of the **Platform and Environment Behaviors** guide cluster -- see `GUIDES.md`.

## Purpose

Runtime behaviors of published claude.ai artifacts (the Artifact tool: publish, read) and of an artifact's shared store (the ArtifactData tool and the page `db` capability). These are the gotchas that cost extra calls or silently lose data when an instance builds, republishes or feeds a published page. New artifact or ArtifactData behaviors append here rather than being re-derived.

**Scope.** Desktop-app Cowork artifacts (no URL, frozen data) and the chat-preview-vs-published routing rule live in **Cowork Build Environment** (Device Bridge section). Browser storage limits in embedded contexts live in **Browser and File System Access Behaviors**. Reading artifact links from a web context lives in **Chrome MCP and Web Tool Behaviors** (web_fetch Behaviors).

## Publishing

**Republishing needs a "viewed" read of the live source, and a `path` read does not count.** The live version counts as viewed when it is read in full: an `Artifact read` of the URL without `path` (brings the whole page into context), or every line of a saved copy read with the Read tool (about 25k tokens per Read call, so a 75 KB page takes two calls). Partial reads made before a refusal are not counted, and a read with `path: index.html` saves the page to a file but does not count as viewing it. A republish therefore typically costs three calls: read, read, publish for a two-part Read of a 75 KB page, or three publish attempts when nothing was viewed first (next item). (Holonic Canvas, 2026-10)

**A refused publish saves the live source; diff it before you re-publish, then resend.** The first publish without a view is refused with a line diff and the live page's full source saved to a local file (path in the error); that refusal counts as the view. Diff the saved file against your base - if the live page holds only your base plus the publish skeleton, there is nothing to merge; if it holds someone else's edits, merge them first. Sending the same file again is refused once more as "identical content resent", and the next identical send publishes (sequence seen: refused, refused as unchanged, publishes). On a large page, make the merge check before the first attempt instead: a `path: index.html` read saves the live page without counting as viewed, so strip the publish skeleton (recipe below) and compare the body byte for byte with your source copy (the page in git). Byte-equal means nothing was co-written and the refusal's diff will hold only your own lines, so the three-step can run without reading the page into context. When the change is small, merge from the saved file: take the live source from `<title>` to `</body>`, apply only the intended edit, and publish that. The live copy can differ from a fresh local build by the publish skeleton and by the key order of an embedded dict, so compare long lines by parsed JSON, not by text. (Holonic Canvas, LocationScout, 2026-10)

**Publish recipe for a hand-built full-document page.** Strip the first 5 skeleton lines, the `</head><body>` and the trailing `</body></html>` the tool adds around the page, keep the theme with a one-line script, and smoke-test the page inside a fake artifact skeleton before publishing. Rendering it once locally is the one use the cloud container's headless browser is good for (see **Chrome MCP and Web Tool Behaviors**, Claude-in-Chrome section). To confirm the stripped copy matches what is live, `read` the artifact and compare: after the transform (strip the skeleton, keep the one-line theme script) the live inner HTML between the host's `<body>` and `</body></html>` matches byte for byte except one trailing newline the host appends. Compare that way before every publish, including a republish. (Evolutionary Media Commons, 2026-10)

**Mock up a design change as an overlay on a copy of the live page.** Read the published artifact, strip the host skeleton (first line and trailing `</body></html>`), then add a small exposed hook to the page's own API and an overlay script. That gave a working design mock-up in one session with no change to the build kit - good for "try it on one chapter first" asks. (Evolutionary Media Commons, 2026-10)

**A republish with `url` that omits `capabilities` keeps the page's declared capabilities** (for example `downloads`); pass the field only to change them. (Evolutionary Media Commons, 2026-10)

**A data-file-only republish still needs the page.** A `publish` with `url` and `files` alone is refused ("also pass file_path"). To change only a data file (for example a `canvas.json`), pass the unchanged page as `file_path` together with `files`; the viewed-read rule above applies to that page on the first such republish of a session. Afterwards, read `index.html` back with `path` and compare its sha256 with your pre-publish copy to confirm the page did not change. A read copy of the page carries the publish skeleton, so republish from your own source copy or strip the wrapper first (recipe above). (ReWoven, 2026-10)

**A page that saves itself rewrites its data file under you.** With the `artifact` capability in its files form, every save from the open page rewrites the data file. To merge new records in: re-read the data file right before merging, add records (never rebuild the file), check with a script that every old record is unchanged, then publish. A viewer with the page open gets a conflict on their next save and reloads - tell them to reload. (ReWoven, 2026-10)

**The session's safety check can deny a live-store write or a publish, even after earlier approval.** An `ArtifactData batch` to a live store was denied as "Modify Shared Resources" although the operator had approved it in chat; it passed when the operator approved it again in the session right before the call. An Artifact publish of a new page version was denied as "Production Deploy" and passed after the operator wrote an explicit go-ahead naming the publish ("yes, publish version 7"). Expect it on live writes and publishes: stop and ask the operator for an explicit go-ahead naming the action, never work around it. (Holonic Canvas, 2026-10)

## Reading

**`Artifact read` needs the full `https://claude.ai/artifact/<id>` URL.** A bare `claude.ai/artifact/<id>` (or a bare id) is refused as "not an artifact URL". (Evolutionary Media Commons, 2026-10)

**A large read is saved to a tool-results file; only the head shows inline.** A ~700 KB page came back head-only, with the full HTML in a tool-results file; extract what you need (e.g. a baked data constant) from that file with a script rather than re-reading. (Holonic Canvas, 2026-10)

## ArtifactData store

**`list` with `out_dir` writes bodies only; versions live in the result text.** Large documents move as files both ways: `set` / `update` take `file_path` (a local JSON file), and `get` / `list` / `query` take `out_dir` (each document saved as `<out_dir>/<collection>/<doc_id>.json`); a 166 KB document round-tripped byte-identical, so large artifact data can enter a vault workflow without retyping. The files hold document bodies; versions appear only in the tool's result text, so a run that must pin writes captures them from there. A `~` in a document id is spelled `@` in the file name (map it back). Past 50 documents the result folds the rest into one text line (`[N more saved documents ... "<id>" <v>, ...]`), so a parser that reads only the per-line form sees a fraction of the collection; an empty collection prints `No documents matched` and makes no folder. (Holonic Canvas, Evolutionary Media Commons, 2026-10)

**Pinned writes are all-or-nothing.** A `batch` with any pinned entry is atomic: one stale pin returns `version_mismatch` naming the entry and its current version, and nothing is written. A pinned whole-document `set` (`if_version`) on a stale pin is refused the same way and lands on the current one. (Holonic Canvas, 2026-10)

**`update` merges nested objects; drop a key with the `__delete__` marker; keep bodies under ~850,000 bytes.** A key present in the store and absent from the body survives an `update`. `{"field": {"__delete__": true}}` removes it (proven live; the read-back carries neither the key nor a marker). Bodies near 1 MiB are refused - plan batches under ~850,000 bytes. (Holonic Canvas, 2026-10)

**Two-filter `query`, pinned `update` and republish survival are verified.** `query` with two `where` filters plus `order_by` works; `update` pinned with `if_version` works; the store's data survives a republish of the page. (Evolutionary Media Commons, 2026-10)

**Move shared state between two artifacts in one atomic `batch`.** Read the source page's documents (here `stars` and `data/users/me/prefs`), then write them to the new page under new keys in one `batch` (17 star documents and 1 prefs document). `collection: "data/users/me"` resolves inside a batch entry. The user id is the same across one owner's artifacts, so `by` copies as-is; keep the original `at`. After the move the two pages no longer sync - tell the operator. (LocationScout, 2026-10)

## Access and sharing

**Only the owner and Editors invited by email can write to an artifact `db`.** A Contributor, a Viewer or a public-link visitor reads only, and switching to a public link removes an outside Editor's write access - so a page that keeps shared state should tell the owner to invite collaborators by email as Editor, not share by link. `data/users/<id>/...` is private per person (good for per-person settings). (LocationScout, 2026-10)

**Admin-only root rules leave the owner's ArtifactData writes unrestricted.** Under root rules `read: admin, write: admin` the owner's ArtifactData writes are unrestricted while `as_level: interact` and `view` see nothing. (Evolutionary Media Commons, 2026-10)

## Comments from the operator

**Comment mode works as a feedback channel into a remote session.** When the operator comments on an artifact and uses "Send to Claude", each comment arrives in the session as a turn (with thread id and anchor), even though `ArtifactComments watch` reports "not supported yet from remote sessions". `read` lists threads with anchors (CSS path plus location label), `reply` posts as Claude labelled "via the user", `resolve` closes. Plain comments (not sent to Claude) do not arrive, so the operator says "check comments". Seven threads were built, answered and resolved in one round this way. (Evolutionary Media Commons, 2026-10)

**Read every open sent-to-Claude thread before acting on one.** Two comments on one paragraph arrived as separate threads ("remove" on the first sentence, "larger font" on the rest); acting on the first alone removed the whole paragraph, and the second thread showed the intent. Read every open thread on the artifact first, then act. (Evolutionary Media Commons, 2026-10)

## Rendering constraints

**The artifact CSP blocks images from any outside host, so tiled web maps go grey.** Scripts load from a few CDNs (cdnjs works), but OSM, CARTO or Esri tiles never load and show no error. The fix that worked: embed a vector basemap (an Overpass extract simplified to ~400 KB) and draw it with Leaflet on a canvas renderer with no tile layer, Leaflet CSS inlined. This extends the general CSP rule in **Cowork Build Environment** (Device Bridge: "Chat-delivered HTML previews run NO page scripts; published claude.ai artifacts run scripts but block external hosts"). (LocationScout, Rootland, 2026-10)

**Browser automation cannot act inside a published artifact's frame.** The page runs in a nested cross-origin frame; Claude in Chrome and the built-in browser pane cannot click, type, read or run script inside it. The store read-back is the only automatable evidence of what a page wrote - in-memory page state has to be read by the person or shown on the page. (Holonic Canvas, 2026-10)

**Nothing in an artifact link reaches the page, so a published page has no deep links.** The page runs in a frame on its own host whose URL carries no query or fragment: opened at `https://claude.ai/artifact/<id>?x=1#y=2`, a probe page saw empty `location.search`, `location.hash` and `document.referrer`, and the host's `postMessage` traffic to the frame carried theme, viewport and capability settings but no route. No runtime capability offers a link channel either (checked against runtime contract 0.2.75). A `#route=` scheme in a published page can never be hit from a link: route through a channel the page owns (a paste field, a `db` document another page writes, a sync), and probe with a scratch page that prints what it sees before building any routing. (Holonic Canvas, 2026-10)

## Local testing and vault copies

**A local render needs the viewer's reset, or `hidden` sections stay laid out.** A page is published without its own head; the viewer adds a reset that includes `[hidden]{display:none!important}`. Rendered bare, a hidden tab's SVG stayed in the layout and intercepted test clicks. When wrapping a page for a local render or a vault copy, include the reset: `:root{color-scheme:light}body{margin:0}img{max-width:100%}[hidden]:not([hidden=until-found i]){display:none!important}`. The rule that a class setting `display` beats `hidden` in your own CSS is in **Browser and File System Access Behaviors**. (ReWoven, 2026-10)

**Exercise `db` and `user` pages locally with a `window.claude` stand-in.** Load a small in-memory mock of `window.claude.use()` as a Playwright init script (Chromium launch: **Cowork Build Environment**, Verification Discipline for Builds) and drive the page before publishing. Keep the mock and a README beside the build. In one session it caught drop-target, undo and reorder bugs across eight publishes. A contract-faithful stand-in worked well with this design: inject it with `addInitScript`; resolve after the page's first script run, with a frozen namespace; fail loudly on methods the code does not use; keep the store in Node with `exposeBinding`, so reloads and a second page share it; support failure injection (null, `unavailable` once, `quota_exceeded`, `revoked`). (ReWoven, Evolutionary Media Commons, 2026-10)

**An artifact page saved to the vault as a standalone file is a fragment.** It has no `<!doctype html>`, `<html>`, `<head>` or `<body>` - the publisher adds them at publish time - so opened from disk it renders in quirks mode. Before shipping it as a standalone vault asset, prepend a document skeleton (doctype, `lang`, charset, viewport, plus the reset above) and wrap the body. (ReWoven, 2026-10)

## Related guides

- **Cowork Build Environment** -- device bridge, cloud container, desktop-app artifacts, the general artifact CSP rule
- **Chrome MCP and Web Tool Behaviors** -- driving web pages; reading artifact links (web_fetch Behaviors)
- **Browser and File System Access Behaviors** -- single-file browser tools, storage in embedded/artifact contexts
