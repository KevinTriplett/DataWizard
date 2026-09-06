---
created: 2026-08-18
edit_log:
  - DW-S273 2026-08-18 - created from the Chrome MCP Tool-Behavior Reference FR
    (behaviors from RW S11-S31 reviews); WeasyPrint item routed to the Cowork
    Build Environment guide
  - "DW-S285 2026-08-24 - Editing in Browser Code Editors section: CodeMirror
    triple-click newline + keyboard single-span edit recipe (S256; meta-learning
    review S256-S266)"
  - "DW-S290 2026-08-26 - Bridged Chrome control section: remote-devices proxy
    split-brain (navigate/list/title work; get_page_content + execute_javascript
    fail session-wide)"
  - "DW-S299 2026-08-26 - Bridged Chrome control section: the in-browser
    extension is a separate bridge that can work when the proxy is split-brained
    - check it before deferring verification to the operator"
  - "KO-S48 2026-09-06 - Claude-in-Chrome extension from a Cowork cloud session:
    site gate, javascript_tool block, dropdown harvesting, screenshot location,
    PDF viewer, Playwright egress"
operator: Andrew
scope: seed
title: Chrome MCP and Web Tool Behaviors
type: guide
updated: 2026-09-06
---
# Chrome MCP and Web Tool Behaviors

> Guide for Claude instances driving external websites and web apps through the Chrome MCP (browser automation) and web-fetch tools. Covers interaction limits, per-platform gotchas (Google Docs, Apps Script), and read recipes for client-rendered pages.
>
> **Scope.** This guide is about driving *external* sites and web tools. For the File System Access API and the runtime behavior of single-file browser tools (local GUIs), see **Browser and File System Access Behaviors**. For sandbox build-toolchain behaviors (including HTML-to-PDF rendering), see **Cowork Build Environment**.
>
> Part of the **Platform and Environment Behaviors** guide cluster -- see `GUIDES.md`.

These gotchas are the most rot-prone kind of learning: they have no design-doc home, so they get rediscovered cold session after session. New Chrome MCP / web-tool behaviors append here rather than being re-derived.

## Chrome MCP Interaction Limits

**OAuth consent popups cannot be driven -- plan a human-in-the-loop pause.** Authorizing an app (observed with Google Apps Script) triggers an OAuth consent popup window that the Chrome MCP cannot interact with; the user must click through it manually. Plan for a handoff pause at first authorization rather than discovering it mid-flow. (Source: RW S17)

**Click coordinates must be scaled by `devicePixelRatio`.** On high-DPI displays, raw coordinates land in the wrong place. (Source: RW S31)

## Reading Client-Rendered Pages

Pages that render client-side (JS apps) may expose little or nothing to a plain fetch or a naive page read. Three working recipes, in escalating order of effort:

1. **Hash-anchor + scroll-screenshots.** Navigate to a hash anchor and take scroll-screenshots section by section rather than expecting full text from a single fetch. Worked on client-rendered fundraiser/leaderboard pages. (Source: RW S28)
2. **Render-wait + `innerText` slices.** For heavily client-rendered app pages (e.g. Bubble apps) that defeat `web_fetch` entirely: Chrome `navigate`, wait ~8s for render, then pull text in slices via `javascript_tool` reading `document.body.innerText`. The tool's output truncates around ~1KB, so slice the string across multiple calls. (Source: RW S31)
3. **Know which sites fetch fine.** Not everything needs the browser: e.g. Substack subdomains fetch cleanly with `web_fetch`. Try the cheap fetch first.

## Editing in Browser Code Editors (GitHub web editor, CodeMirror)

**Triple-click selects the trailing newline.** The GitHub web editor is CodeMirror: a triple-click line-select includes the line's newline, so typing a replacement over it joins the next line up. For a small in-place edit, do not select the line. Reliable single-character (or short-span) edit via keyboard: click into the line, `cmd+Right` to end-of-line, `Left` N times to reach the span, `shift+Left` to select it, type the replacement, then read the line back before committing. Prefer this over any select-the-line approach when the edit is one token wide - it was used to fix a one-character workflow bug through the browser without a local clone. (Source: DataWizard, 2026-08)

## web_fetch Behaviors

**Token-cap overflow saves to a temp file.** When a page exceeds the token cap, `web_fetch` errors and saves the content to a temp file. In practice, search-result summaries plus one canonical readable page were decision-grade -- budget for this rather than retrying the same oversized fetch. (Source: RW S23)

- Cowork WebFetch can refuse arbitrary URLs with PROVENANCE_REQUIRED: a permission prompt goes to the human and, unanswered, the fetch fails - fatal for unattended runs. Workaround that held everywhere tested (Weave, 2026-09): run a web search naming the target first, then fetch the URLs the search returns - search-derived URLs carry provenance. Design scheduled web checks search-first, and report still-blocked sources as unverified rather than retrying.

## Google Docs via Chrome

**Heading keyboard shortcuts type literal characters on Mac.** Ctrl+Alt+N and similar heading shortcuts do not apply styles through the Chrome tools -- they insert literal characters into the document. Use the style dropdown, or write plain text with caps. (Source: RW S17)

**Typed numbers auto-convert into nested lists.** When the cursor is inside existing list-formatted content, typing numbered text auto-nests it, and Ctrl+Z does not reliably revert large typed blocks. Workaround: paste the block via clipboard rather than typing it. (Source: RW S16)

## Google Apps Script

**First authorization needs the manual OAuth click** (see Interaction Limits above).

**Batch reads/writes; never loop `setValue()`.** Individual `setValue()` calls are extremely slow (~3 minutes for 200 cells); batch `getValues()` / `setValues()` is ~100x faster (~3 seconds). Standard Apps Script knowledge, recorded here because agent-driven spreadsheet automation hit it cold. (Source: RW S17)

## Bridged Chrome control (remote-devices proxy)

When Chrome is driven through the device bridge (a `Control_Chrome`-style proxy) rather than the in-browser extension, the toolset can go split-brained: `open_url`, `list_tabs`, and `get_current_tab` keep working (they report tabs and titles), while `get_page_content` and `execute_javascript` fail *every* call with "Google Chrome is not running" -- even though the same tabs are listable and Chrome is plainly running. Net capability in that state: navigate and read tab titles, but neither click nor scrape page content. It is session-wide, not transient, so do not burn retries. Fall back to reading tab titles only (navigate to a specific URL and read the resulting `<title>`), hand the click/verify to the operator, or switch to computer use (screenshots) if it can be enabled. (Source: DataWizard, 2026-08)

**The in-browser extension is a separate bridge -- try it before deferring.** The Claude-in-Chrome browser *extension* (its own MCP toolset, distinct from the device-bridge proxy) can be fully functional in the very session where the proxy is split-brained. Flow: `list_connected_browsers` -> `select_browser` (the user must confirm the browser choice) -> `navigate` -> `get_page_text` / `read_page` / `find` / `computer` clicks all work, giving real scrape-and-click, not just tab titles. So when the proxy goes split-brained, check whether the extension is connected before handing verification to the operator -- one dead bridge does not mean the other is down. (This is exactly the gap that left a shipped CI job unverified for hours the prior session, when only the proxy was tried and it was down.) (Source: DataWizard, 2026-08)

**GitHub token creation is automatable except the sudo gate.** Driving PAT creation through the browser extension works end to end (settings/tokens/new: fill note, expiration, scopes, submit, read the one-time token off the result page) EXCEPT GitHub's "Confirm access" sudo-mode step, which emails the operator a verification code - trigger the mailer, then hand the browser to the operator for the code and resume once verified. Credentials stay the human's step; the form work and token capture do not have to be. (Source: Weave, 2026-08)

## Claude-in-Chrome extension from a Cowork cloud session

**Per-site permission is a hard gate, and it clears mid-session.** `navigate` to a domain the operator has not allowed in the extension fails at once with "Navigation to this domain is not allowed" (the batch stops there). Ask the operator to allow the site in the extension, then retry the same navigate - two sites that failed early in a session worked on retry after approval, with no reconnect needed. Some stay blocked; move on rather than looping. (Source: Kosmos, 2026-09)

**`javascript_tool` results can be blocked wholesale.** On a site whose DOM values look like cookies or query strings (astro.com's `<select>` option values), every `javascript_tool` call returns `[BLOCKED: Cookie/query string data]`, even when the expression only reads option text. Use `find` / `read_page` on the element instead. (Source: Kosmos, 2026-09)

**Custom dropdowns populate the accessibility tree only after being opened.** `read_page` on a closed custom select shows one generic child; click it open, then `find "option items inside the X dropdown"` lists every option with its text - reliable for harvesting long option trees (74 options across 10 dropdowns in one pass). (Source: Kosmos, 2026-09)

**`computer screenshot` with `save_to_disk` writes into the cloud container**, at `/tmp/claude-chrome-screenshots-*/screenshot-<ts>-<n>.jpg`, not onto the operator's machine. Copy them with Bash and commit to the vault with `device_commit_files` from `/mnt/user-data/outputs/`. (Source: Kosmos, 2026-09)

**Chrome's built-in PDF viewer does not render in screenshots** - the main pane captures blank or black while the thumbnail rail is visible. A PDF you need to see must be fetched some other way (operator download, `fetch_pdf_from_url`); zooming the thumbnails is too low-res to read. (Source: Kosmos, 2026-09)

**Headless Playwright in the cloud container cannot replace the extension for third-party sites.** The container's egress allowlist admits package registries and GitHub but resets connections to most product sites, so "screenshot it with Playwright" fails where the extension succeeds. Use Playwright only for local files (e.g. rendering your own artifact once before publishing). (Source: Kosmos, 2026-09)

## See Also

- **Browser and File System Access Behaviors** -- local single-file browser tools, File System Access API
- **Cowork Build Environment** -- sandbox toolchain, network/fetch workarounds (GitHub REST, rate limits), HTML-to-PDF rendering
- **MCP Reliability and Write Verification** -- Obsidian MCP failure modes and write verification
