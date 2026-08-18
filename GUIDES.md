---
title: DataWizard Guides
type: project-doc
created: '2026-06-22'
updated: '2026-08-18'
operator: Andrew
edit_log:
  - DW-S195 2026-06-22 - created the guides catalog and named the Platform and
    Environment Behaviors cluster
  - DW-S242 2026-08-05 - Git Guide row now notes the commit guard
  - DW-S244 2026-08-05 - added the Browser and File System Access Behaviors
    guide to the Platform cluster
  - DW-S245 2026-08-05 - added the Git Hook and CI Behaviors guide to the
    Platform cluster
  - DW-S250 2026-08-06 - added the Review Automation guide
  - DW-S273 2026-08-18 - added Chrome MCP and Web Tool Behaviors + Cowork Build
    Environment guides to the Platform cluster
---
# DataWizard Guides

How-to and reference guides included in the Seed. Guides are operational references (how to do a thing, how a platform behaves); skills are triggered workflows (see `SKILLS.md`); protocols are the conventions that govern structure (see `Protocols/`).

## Platform and Environment Behaviors

The standing home for platform and environment gotchas - the things that trip an instance up because of how the runtime behaves (Cowork, the Obsidian MCP, the sandbox, scheduled tasks, the desktop config), as distinct from how the content or methodology works.

These learnings rot faster than any other kind because they have no design-doc home: content learnings self-plant into the relevant design doc, but platform gotchas have nowhere obvious to go and pile up in meta-learning reviews instead. This cluster is that home. When a meta-learning review surfaces a platform or environment learning, it lands here by default - extend the matching guide below, or add a new guide to the cluster if none fits (then list it here).

| Guide | Covers |
|---|---|
| **Cowork Scheduled Tasks** | Running DW automation as Cowork scheduled tasks: timezone/`fireAt`, one model per run, cron jitter, idempotency and the requirements for reliable unattended runs, runtime-URL limits. |
| **MCP Reliability and Write Verification** | Obsidian MCP failure modes (ghost writes, phantom/stale reads, frontmatter wipe), the write-verification protocol, concurrency practice, and sandbox/git gotchas. |
| **Editing the Claude Desktop Config** | Finding and safely editing `claude_desktop_config.json` to add MCP servers or grant folder access; JSON pitfalls and recovery. |
| **Browser and File System Access Behaviors** | Runtime gotchas for a single-file browser tool that reads/writes local files: File System Access API (Chromium-only, `file://`, IndexedDB handle persistence, read→readwrite upgrade, user-gesture rule, folder-scoped grants), artifact contexts blocking local storage, DOM/CSS gotchas (`hidden` vs class `display`, `color-scheme`), and headless mock-adapter verification. |
| **Git Hook and CI Behaviors** | Where guard/automation scripts run across a git-synced repo's environments: local hooks (install-per-clone, `core.hooksPath` supersedes `.git/hooks/`), mobile Obsidian Git (isomorphic-git runs no hooks - CI is the only mobile net), and awk-in-CI being mawk (interval + grouped-alternation panic; write mawk-safe). Git how-to stays in the Git Guide; this covers execution-environment facts. |
| **Chrome MCP and Web Tool Behaviors** | Driving external sites via Chrome MCP and web fetch: interaction limits (OAuth popups, devicePixelRatio), client-rendered page read recipes, web_fetch token-cap behavior, and Google Docs / Apps Script gotchas. Local single-file browser tools stay in Browser and File System Access Behaviors. |
| **Cowork Build Environment** | Building codebases from the Cowork sandbox: git-on-mount build workflow (lock cleanup, no push creds, `git add -A`), Node/npm/Electron and Python toolchain gotchas, shell/file-tool quirks, network and GitHub-data workarounds, WeasyPrint rendering, device-bridge specifics, and build-verification discipline (isolated /tmp loop, typecheck+build+smoke). |

## Other Guides

### Git and sync
| Guide | Covers |
|---|---|
| **Git Guide** | Git for the vault and DW projects: repo setup, nested vs standalone repos, push workflows, DW Save, and the commit guard (conflict-marker + Windows-unsafe-filename pre-commit hook and CI). Sectioned - see `Git Guide/`. |
| **Seed Install and Update** | Installing the Seed into a vault and updating it via `update_seed.sh`. |

### Vault structure and content
| Guide | Covers |
|---|---|
| **Vault Structure Guide** | Folder conventions, meta-folder naming, and the shell + section architecture. |
| **Filename Safety** | Cross-platform-safe filenames: the character map and replacement rules. |
| **Federation Guide** | Sharing content across vaults and projects: the full-copies-only rule and the human-duplication workflow. |
| **Harvest Workflow Guide** | The harvest pipeline end to end: routing, provenance, and execution. |
| **Obsidian Bases Reference** | Using Obsidian Bases for DW dashboards and filtered views. |
| **Working Principles** | The reasoning behind the Working Rules - the "why" under the behavioral contract. |
| **Review Automation** | The three periodic reviews (health audit, meta-learning, Content Interests): the pending-report model, the cadence table (single home), and how scheduled automation detects staleness so the session-closer only surfaces waiting reports. |

### Onboarding and integrations
| Guide | Covers |
|---|---|
| **Human Onboarding Doc Template** | Template for generating a per-project human onboarding guide. |
| **Telegram Harvesting** | Harvesting Telegram exports into the vault; credentials stay outside git-tracked folders. |

### Maintainer notes
| Guide | Covers |
|---|---|
| **Obsidian MCP Improvement Requests** | Running log of desired Obsidian MCP fixes and features (a tracking doc, not a how-to). |

Archived guides keep an `xArchive -` filename prefix in `Guides/` and are left out of this catalog.

---

*See also: `SKILLS.md` (triggered workflows) and `Protocols/` (structure and conventions). The Platform and Environment Behaviors cluster was named in DW S195.*
