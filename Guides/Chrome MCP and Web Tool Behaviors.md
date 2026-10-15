---
created: 2026-08-18
edit_log:
  - 'DW-S408 2026-10-15 - sectioned into shell + sections in "Chrome MCP and Web Tool Behaviors/" (Seed/Guides); this edit_log is frozen - future edits log on the section files'
  - 'DW-S403 2026-10-13 - Scripted downloads: blocked-portal aggregator fallback, mark partial; og:image logo/stock contact-sheet check (board intake B-0074, LocationScout)'
  - 'DW-S396 2026-10-12 - Operator browser split view (Brave) section: no web API, tab menu limits, build the pane into the page'
  - 'DW-S397 2026-10-12 - web_fetch: attended PROVENANCE_REQUIRED timeout, paste-the-URL unblock (meta-learning review S363-S376)'
  - 'DW-S398 2026-10-12 - WebSearch budget, scripted-download (User-Agent identity, Wikimedia 429, captcha vs WebFetch) and Connectors sections (board intake)'
  - 'DW-S400 2026-10-12 - web_fetch: Reddit blocked at the proxy; transient fetch-cache collision (VibeCut FR intake)'
  - 'DW-S399 2026-10-12 - split view section: in-page pane recipe (sandbox, server-side framing check) + Chromium named-window capture'
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
  - 'RW_2026-09-23_AA_01 - client-rendered ladder extended: verbatim-fetch prompt, SPA path-drop + hover-only data, operator Web-Clip fallback; family named (ReWoven meta-learning review)'
  - 'DW-S381 2026-10-02 - web_fetch Behaviors: claude.ai/share links unreadable; artifact links via the Artifact tool'
operator: Andrew
scope: seed
title: Chrome MCP and Web Tool Behaviors
type: guide
updated: 2026-10-15
---
# Chrome MCP and Web Tool Behaviors

> Guide for Claude instances driving external websites and web apps through the Chrome MCP (browser automation) and web-fetch tools. Covers interaction limits, per-platform gotchas (Google Docs, Apps Script), and read recipes for client-rendered pages.
>
> **Scope.** This guide is about driving *external* sites and web tools. For the File System Access API and the runtime behavior of single-file browser tools (local GUIs), see **Browser and File System Access Behaviors**. For sandbox build-toolchain behaviors (including HTML-to-PDF rendering), see **Cowork Build Environment**.
>
> Part of the **Platform and Environment Behaviors** guide cluster -- see `GUIDES.md`.

These gotchas are the most rot-prone kind of learning: they have no design-doc home, so they get rediscovered cold session after session. New Chrome MCP / web-tool behaviors go into the matching section file (embedded below) rather than being re-derived.

![[1.0 Chrome MCP Interaction Limits]]

![[2.0 Reading Client-Rendered Pages]]

![[3.0 Editing in Browser Code Editors (GitHub web editor, CodeMirror)]]

![[4.0 web_fetch Behaviors]]

![[5.0 WebSearch Behaviors]]

![[6.0 Scripted Downloads from the Shells (Container and Device)]]

![[7.0 Google Docs via Chrome]]

![[8.0 Google Apps Script via Chrome]]

![[9.0 Bridged Chrome Control (remote-devices proxy)]]

![[10.0 Claude-in-Chrome Extension from a Cowork Cloud Session]]

![[11.0 Operator Browser Split View (Brave)]]

![[12.0 Connectors and Web Tools]]

## See Also

- **Browser and File System Access Behaviors** -- local single-file browser tools, File System Access API
- **Cowork Build Environment** -- sandbox toolchain, network/fetch workarounds (GitHub REST, rate limits), HTML-to-PDF rendering
- **MCP Reliability and Write Verification** -- Obsidian MCP failure modes and write verification
