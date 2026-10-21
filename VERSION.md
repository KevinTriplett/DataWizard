
seed: 1.11.8
protocol: 1.8
project_instructions: 4.9

**Canon write gate:** edits to this file come only from a claimed session of the project that owns it. An instance governed by another project's instructions files a proposal at the owning project's intake (or an exchange note in its Session Exchange) instead of editing. Reviewed exceptions are whitelisted in the lint config. (Conventions Registry: "Cross-project canon write gate"; DataWizard, 2026-09)

## NOTICE - Seed git history rewritten again 2026-10-17 (instances: read this)

On 2026-10-17 the Seed repo's git history was rewritten a second time (privacy and security hygiene). Removed from every past commit: a Telegram session file that an auto-sync had committed, a copy of the operator's private `Vault Config.md`, every committed `*.bak` rollback copy, and two `.pyc` files. Replaced in old file versions: private chat identifiers, local home-directory paths and a private event name (placeholders such as `1234567890` and `/Users/USERNAME` now stand in). Computer names in automatic commit messages now read "on Mac". Today's files did not change; every commit kept its author, date and message text.

**Every commit id changed, including the very first one.** What a clone made before 2026-10-17 sees:

- `git pull` stops with `fatal: refusing to merge unrelated histories`. Nothing is merged. Good. A plain `git push` is rejected (non-fast-forward).
- `git status` after a fetch shows `[ahead N, behind M]` with N equal to M, or one less (a clone from before the rewrite's preparatory commit).
- DW Save from before 1.10.1 (most clones) reports `ERROR: could not reach GitHub - check your connection` on every run. The message is misleading - the connection is fine, the pull refused - and nothing is pushed. DW Save 1.10.1 and later instead reports `BLOCKED: secret file(s) would be published` for the old commits. **Do not follow that message's generic fix (`git reset --soft ...`) in this case** - it would re-stage the old example ids.

**Zip installs** (no `_DataWizard/Seed/.git` folder): nothing to do; run `update_seed.sh` as usual.

**Git clones:** follow `Guides/Git Guide/7.0 Safety and Recovery.md`, section "Recovering a Seed Clone (Remote-Agnostic)". Step 4 there names this rewrite's signature and the command for it: Step 0 backup (branch, plus stash if anything is uncommitted), fetch the canonical remote, run `git diff --stat main <canonical>/main` and confirm it lists nothing or only the three placeholder files (`Guides/Telegram Harvesting.md`, `Scripts/datawizard-aliases.sh`, `Scripts/tg_harvest_thread.py`), then `git reset --keep <canonical>/main`, then `git stash pop` if Step 0 stashed. Any other file in that diff is local committed work: branch it first, re-apply it after the reset. Untracked and ignored files (`Vault Config.md`, `Scripts/.env`, session files) are never touched. A propose-then-review rule applies as before: no reset on one Claude instance's say-so (D109).

**Forks:** a fork made before 2026-10-17 still serves the old commits. Delete it and fork again; re-apply any local work as a new branch on the new `main`. Never merge a pull request that lists hundreds of commits or says "unrelated histories" - that is the old history coming back.

Never use `git pull --allow-unrelated-histories` or any merge to recover. (DataWizard, 2026-10)

## NOTICE - Seed git history rewritten 2026-06-10 (instances: read this)

On 2026-06-10 the Seed repo's git history was rewritten to remove a
user-specific config file (security hygiene). All commit hashes changed.

**Claude instances: surface this notice to your user if their Seed is a
git clone.** Check: does `_DataWizard/Seed/.git` exist? If NOT (they
installed via the zip / update_seed.sh), no action is needed -- updates
work normally. If it IS a git repo, their next `git pull` may fail with
"refusing to merge unrelated histories" or report divergent branches.

**Recovery (rewritten 2026-08-31, remote-agnostic):** do not run any
reset straight from this notice. Follow the single safe procedure in
`Seed/Guides/Git Guide/7.0 Safety and Recovery.md`, section
"Recovering a Seed Clone (Remote-Agnostic)". In brief:

0. Back up first, unconditionally: `git branch backup/pre-recovery-<date>`,
   plus `git stash -u` if the tree is dirty.
1. Identify the canonical remote BY URL
   (`github.com/andrewalan11/DataWizard`), never by the name `origin`.
   On a fork-shaped clone (`origin` = a personal fork, `upstream` =
   canonical), `reset --hard origin/main` silently rolls the Seed back
   to the fork's stale state while every check looks clean -- this
   nearly downgraded a collaborator's Seed on 2026-08-30.
2. `git fetch <canonical> --prune`
3. `git merge --ff-only <canonical>/main` -- fails closed, can never
   lose a commit. If it succeeds, you are done.
4. Only if ff-only refuses AND the guide's triage confirms unrelated
   histories from this rewrite: `git reset --hard <canonical>/main`,
   human-reviewed. No reset runs on one Claude instance's say-so --
   propose on paper and get a second instance's review first
   (Weave D39; DW D109). `Vault Config.md` is untracked/gitignored
   and is not touched either way.

**Never** use `git pull --allow-unrelated-histories` or any merge-based
recovery here -- merging reattaches the old history that the rewrite
removed. (A fast-forward is not that kind of merge: `--ff-only` creates
no merge commit and cannot reattach anything.)

Also in this update: `update_seed.sh` moved from `Seed/Scripts/` to the
Seed root (`_DataWizard/Seed/update_seed.sh`) to match the path the
Project Instructions reference. Zip-install users who updated previously
may have a stale copy at `Seed/Scripts/update_seed.sh` -- it can be
deleted. If a launchd auto-update job was set up per the Seed Auto-Sync
Design, edit its plist to point at the new root path.

This notice can be removed from VERSION.md after 2026-09. The recovery
procedure itself lives durably in Git Guide 7.0 ("Recovering a Seed
Clone (Remote-Agnostic)") and survives this notice's retirement.

## What's New in 1.11.8

**Patch release: five lessons from the last builds.** One DataWizard session (2026-10-21). Each had been written down in the project's backlog but was not yet in the Seed. Shipped in the Seed:

- `Skills/supervised-build/SKILL.md` (v1.6.1): Reviewer Steps, new paragraph "Fix text goes in the review file" - a reviewer writes the exact current text and its replacement into the review file the fixer reads, never only into its hand-back. In-thread variant, "Scratch, never the vault" - brief every `device_bash` builder to write its output to an absolute path outside the vault. `SKILLS.md`: the row is now v1.6.1.
- `Guides/Cowork Build Environment/8.2 Device Bridge - Sub-agents and Orchestration.md`: new bullet - a `device_bash` sub-agent that did `cd` into the vault and wrote a relative file name left a file in the vault root that the sub-agent could not delete; give the agent a scratch folder and full paths.
- `Protocols/Conventions Registry/26.0 Coordination board.md`: new paragraph - post claims for a step the operator runs by hand just before the run, and re-post them (old blocks `reclaimed`) if the run slips past the ttl.
- `Protocols/YAML Schema.md`, Holonic Records: new paragraph "Stored form of a key" - a key whose value has a "/" (every `github-repo` key) is stored hashed in the operational database; a consumer hashes the plain key from the core's `keys:` with the index's key function and checks the active keys, never plain text.
- `Guides/Cowork Build Environment/9.0 Verification Discipline for Builds.md`: two new bullets - an apply that says `unchanged` is expected when a fix changes only the JSON report (verify on the report); `python3 -I` drops the script folder from `sys.path`, so a test that imports a sibling script needs a run without `-I`.

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.11.7

**Patch release: 2 tool behaviors from a partner project (LocationScout).** One DataWizard session (2026-10-20). Of the 5 behaviors sent, 3 were already in the guides (translated page text in Chrome, the `[BLOCKED: Cookie/query string data]` result on link URLs, the artifact republish handshake); two of those gain one phrase each. Shipped in the Seed:

- `Guides/Chrome MCP and Web Tool Behaviors/`: 2.0 (new rung 12: a site whose robots.txt blocks `web_fetch` was read in the lead's Chrome pass, so route blocked sources back to the lead; rung 7: `innerText` is auto-translated too, so note the source language when you quote); 10.0 (the "unparseable URLs" refusal also hit a page opened from a hand-built deep URL; follow the site's own link from its home page).
- `Guides/Cowork Build Environment/9.0 Verification Discipline for Builds.md`: when the explicit-path Playwright launch also fails, match the npm version to the cached browser build (`ls /opt/pw-browsers`), then launch plainly.
- `Guides/Published Artifacts and ArtifactData Behaviors.md`, "Publishing": `Artifact list` with `scope: files` does not count as viewed either; a second sighting of the refused, refused, publishes sequence.
- `GUIDES.md`: the Chrome MCP row names the robots-blocked-source route.
- `VERSION History.md`: the What's New entries for 1.9.1 to 1.9.5 moved there word for word (size rotation, so this file stays under about 50 KB). Nothing was cut.

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.11.6

**Patch release: 9 tool behaviors from two partner projects (LocationScout, MetaMyth).** One DataWizard session (2026-10-19). Of the 12 behaviors sent, 3 were not planted: two were facts about particular public data sources (they stay in the project that found them) and one was already in the guides. Shipped in the Seed:

- `Guides/Cowork Scheduled Tasks.md`: a one-time (`run_once_at`) run can start about seven minutes late; `fire_trigger` with `text` makes the run work twice; a run started from a published page reached the artifact store every time but the vault only sometimes; in a timed run the Obsidian MCP wrote the vault while the device shell showed no folders (load the tools with an exact `select:` list); scheduled runs wrote the artifact store with no approval.
- `Guides/Published Artifacts and ArtifactData Behaviors.md`, "Page runtime calls": a page can start a scheduled task through the `mcp` capability (the task's owner only; gate the button with `user.isOwner()`); count every live subscription before checking the `db` cap (64 per view).
- `Guides/Cowork Build Environment/5.0 Network and GitHub Data.md`: the device shell failed on Overpass too (HTTP 406, then a timeout); a `fetch` POST from a Chrome tab on `overpass-turbo.eu` worked; one sub-agent got through only on two mirrors after retries. `8.2 Device Bridge - Sub-agents and Orchestration.md`: web-only research sub-agents ran in parallel without the shared-Chrome problem.
- `Guides/Chrome MCP and Web Tool Behaviors/`: 2.0 (reduce the data in the page before slicing it); 10.0 (the `[BLOCKED: Cookie/query string data]` result also fires on plain text that looks like query parameters; replace `[&=?%]` with spaces).
- `GUIDES.md`: the Cowork Scheduled Tasks and Published Artifacts rows list the new topics.

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.11.5

**Patch release: 8 tool behaviors from three partner projects (ReWoven, MetaMyth, Rootland).** One DataWizard session (2026-10-19). Shipped in the Seed:

- `Guides/Published Artifacts and ArtifactData Behaviors.md`: the side-panel window a published page opens in (about 780-900 px wide) and a fit pass for fixed-size pages; `sample` takes a size, not a model, and the viewer who clicks pays; where the platform shows comments and the two artifact link forms (a sent comment carries the uuid one); the publish result's sharing line is the live state; clearing a comment history means a new artifact. `sample` and the existing second-HTML-page bullet now sit under a new heading, "Page runtime calls".
- `Guides/Chrome MCP and Web Tool Behaviors/`: 9.0 (the built-in browser as a route when the extension is not connected; it reaches a server started on the operator's computer; its `resize_window` does change the layout); 1.0 (pointer to that resize); 2.0 (rung 11: a page that loads its screens in same-origin iframes is read through `contentDocument`); 10.0 (the "not connected" bullet points to the built-in browser).
- `Guides/Cowork Build Environment/8.0 Device Bridge.md`: the device shell held for a full session after the inode fix; a pointer to the built-in browser for operator-started localhost servers.
- `GUIDES.md`: the Published Artifacts and Chrome MCP rows list the new topics.
- `VERSION History.md`: the What's New entry for 1.9.0 moved there word for word (size rotation, so this file stays under about 50 KB). Nothing was cut.

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.11.4

**Patch release: 17 tool behaviors from five partner projects (Rootland, Kosmosis, MetaMyth, ReWoven, Community Stack).** One DataWizard session (2026-10-19). Shipped in the Seed:

- `Guides/Cowork Build Environment/`: 8.0 (adding a folder to the claude.ai Project does not connect the bridge; with no connected folder the Obsidian MCP writes notes and the Mac filesystem MCP writes other files; more wedged-shell sightings); 8.1 (macOS Terminal `tar` bundles carry AppleDouble `._*` files, use `COPYFILE_DISABLE=1`; `device_commit_files` creates missing folders; `expectedMtimeMs` as a guarded batch overwrite); 8.2 (sub-agents read the Mac through the filesystem MCP with the shell down; resume the builder by message to apply a review); 9.0 (scripted checks by cheaper tiers from a stronger tier's check plan).
- `Guides/Published Artifacts and ArtifactData Behaviors.md`: the multi-file publish root, slide speaker notes in `<aside>`, an `as_level` check of the db rules, comments not sent to Claude (read-only), comment-list paging, and the entry-page rule for capabilities (a second HTML page is untested).
- `Guides/Chrome MCP and Web Tool Behaviors/12.0`: a negative web finding needs a second check before it changes data; Claude Docs chart embeds can be hand-drawn SVG.
- `Guides/MCP Reliability and Write Verification/`: 6.0 (`filesystem__read_multiple_files` overflows); 12.0 (`filesystem:edit_file` echoes every hunk, so a small edit to a long-line file floods the context).
- `GUIDES.md`: the Published Artifacts row lists the new topics.
- `VERSION History.md`: the What's New entry for 1.8.0 moved there word for word (size rotation, so this file stays under about 50 KB). Nothing was cut.

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.11.3

**Patch release: rows that a script can close.** One DataWizard session (2026-10-19). A tracking row that waits on something written only in words keeps saying "pending" after the thing it waited on has closed somewhere else. About a third of the leaked items in two look-backs were rows of this kind. This release gives such rows an id a script can read. The scripts that read it (a board render flag and a lint check) come in a later release. Shipped in the Seed:

- `Protocols/Conventions Registry/23.0 Tracking Model.md`: new sub-rule **Dependencies name their id** - a line or gate row that waits on another tracked item writes `after: G-NNN` / `B-NNNN` / `Tnn` (comma-separated for several); where it goes; when a target counts as done; a dependency on something with no id stays in words (the check's named blind spot).
- `25.0 Operator Gate Queue.md`: two row fields - `ask` (required in the waiting-on-people class: the board ask id, or `-` when a person, not a project, is the actor) and `after`. Admission: work that waits on another project's session is a board ask, not a gate row; existing rows of that kind move to the board when next touched.
- `26.0 Coordination board.md`: a gate row that waits on an ask carries `- ask: B-NNNN`; the ask may end its summary with `[G-NNN]`.
- `30.0 Carry the probe, not the snapshot.md`: extended to tracking lines - no file size, count or version that will change; write the probe.
- `Templates/Operator Gate Queue - Template.md`: `- ask: -` on the example row; a note under the waiting-on-people class.
- `VERSION History.md`: the What's New entry for 1.7.0 moved there word for word (size rotation).
- Tool behaviors: `Guides/Cowork Scheduled Tasks.md` - a task created without `folders` gets none (pass them explicitly); test a new task with a one-time copy of its exact prompt. `Guides/MCP Reliability and Write Verification/12.0 Obsidian Behavioral Gotchas.md` - filesystem `edit_file` applies a multi-edit call all or nothing.

**Adopters:** nothing breaks - scripts ignore unknown row keys. Add `- ask:` to the rows of your waiting-on-people class when you next touch them, and move rows that wait on another project to the board.

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.11.2

**Patch release: the cause and the fix for a device shell that fails in every session.** One DataWizard session (2026-10-18 to 2026-10-19). From 2026-10-16 `device_bash` failed in every new Cowork session on one computer, in every project, for three days. The cause was not a wedged session: the desktop app keeps one Linux user and home folder per session on a fixed 10 GB session disk inside its VM and does not remove them, and that disk ran out of file entries (inodes). Shipped in the Seed:

- `Guides/Cowork Build Environment/8.0 Device Bridge.md`: the wedged-shell bullet is rewritten around the cause - the signs (only "device_bash failed in the device workspace", no `scratchFolder`, every new session in every project, a restart does not help), the confirm step (`df -i /sessions` in an older session whose shell still works), and the operator fix as observed once (quit Claude with Cmd-Q, check with `lsof`, move `sessiondata.img` aside to a backup, start Claude - the app made a new, empty disk; if it does not, move the backup back and report). The bullet is split in two: the cause and fix, and how to work without the shell until the swap.

**Adopters:** if your device shell fails in every new session, follow the 8.0 bullet. Once in a while, run `df -i /sessions` in a working device shell; when it nears 100%, plan the swap before the shell stops.

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.11.1

**Patch release: a session look-back report has a home.** One DataWizard session (2026-10-19). A look-back scan reads the session logs closed since the last look-back and reports open items that slipped (on no tracking list) or sit on an out-of-date tracking line. It is the safety net behind the 1.11.0 landing rule. Shipped in the Seed:

- `Skills/session-closer` v4.11.1: Step 3.10 also surfaces a pending `Look-Back Report - *` at a full close, the same way as the other review reports. The v4.10.1 edit_log line moved into `references/changelog.md` (rolling window).
- `Guides/Review Automation.md`: the "Backlog + FR triage" row names the session look-back scan as its between-triage producer, with `Look-Back Report - *.md` as its pending report. The full triage stays manual at its own cadence; a look-back review stamps `last_backlog_triage` only when it also covered the full triage. Producer maturity: the look-back producer runs in one project's workshop and is not yet shipped in the Seed.
- `SKILLS.md`: session-closer row synced; Workshop table gains a session-lookback row.

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. A project without a look-back scan sees no change. (DataWizard, 2026-10)

## What's New in 1.11.0

**Minor release: open items must land on a list.** One DataWizard session (2026-10-18). Two look-backs over 53 session logs found that about one open item in three was not where the next reader would look: it had faded out of "What's next", or it lived only inside a handoff or design doc, or a done parent line hid it. This release closes those gaps at moments that already exist (the close, the chunk done-mark, the moment a document is written). Shipped in the Seed:

- `Skills/session-closer` v4.11.0: Step 4's optional "Action items" bullet is now the required **landing rule**. The closer re-reads the previous "What's next"; each item ends done (struck, with where it landed), carried (it is in the new "What's next"), or landed on a tracking list (a Backlog line, gate row, board ask or ledger row), and the entry quotes that line - its file and its title, id or first few words. "Queued in X" without the quoted line is not allowed. Rulings and small tasks for the operator go to one dated `Waiting on <operator>` checklist, never to a paragraph in "What's next". The rule applies at every close tier (Step 0's lite list names it). Step 2.6: the ledger `next:` is written as the arc's owed list, current state only. Step 3.5: new **tracking-claim verification** - every "tracked in / queued in / see `<list>`" claim must resolve to a line on disk, checked like a planted learning. New Common Mistakes bullet. `references/output-format.md`: the What's next template starts with a **Landing check** line and a **Waiting on `<operator>`** pointer line. `references/changelog.md`: the v4.10.0 edit_log line moved in from the frontmatter (rolling window).
- `Protocols/Conventions Registry/23.0 Tracking Model.md`: four sub-rules - **follow-ups are born on a list** (a handoff, exchange note, pre-flight answer, build-plan limits list or design doc that names a follow-up writes its Backlog line or board ask at the same moment and keeps only a pointer); **parents do not close over open children**; **no new Unlocks in design docs** (the State Board plus a Backlog line do that job; existing lists stay as history); **rulings and small tasks for the operator** live on one dated Waiting-on checklist. One new fact-class row for that checklist.
- `Protocols/Conventions Registry/24.0 Active Threads ledger row schema.md`: `next:` is the owed list (one short line per item the arc still owes), not a narrative; the example is in list form.
- `Skills/supervised-build` v1.6.0: at each chunk's done-mark (Builder Step 5), every leftover - a deferred item, a known limit, a follow-up the chunk names - becomes its own tracking line before the chunk is marked done, and the chunk report quotes the lines; the reviewer checks they exist (Reviewer Step 2); in the in-thread variant the done-mark is the lead's.
- `Guides/Cowork Build Environment/8.1 Device Bridge - Staging, Commits and Transport.md`: an outputs file edited after the copy can commit as its pre-edit (or part-edited) copy on the FIRST commit, not only on path re-use (4 of 13 files in one run); write the final version to a fresh outputs path, commit, then compare the on-disk size or checksum with the local copy.
- `Templates/Operator Gate Queue - Template.md`: class F holds only built or decided items; rulings and small operator tasks go on the Waiting-on checklist (the Tracking Model gives the test).
- `SKILLS.md`: session-closer and supervised-build rows synced.

**Adopters:** the landing rule needs a home for the `Waiting on <operator>` checklist in each project. Pick one - typically a section of your action items or backlog - and move any "rulings waiting" paragraphs from your last "What's next" into it (one dated line per item, with its source session). If a project has none yet, the closer asks the operator where it goes at the first close that needs it (with no answer at hand, it opens one as a section at the end of the action items file and says so). An orientation sub-check that shows the checklist's count and oldest item waits for a later Project Instructions bump. Closes take one to three minutes longer; lite closes run the landing rule too.

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.10.4

**Patch release: the Conventions Registry and the session-closer skill are sectioned. No rule changed.** One DataWizard session (2026-10-18). Both files were past the ~50 KB line where vault tools turn unreliable. Text moved byte for byte; a reassembly check matched the originals exactly. Shipped in the Seed:

- `Protocols/Conventions Registry.md` is now a short shell (frontmatter, intro, a navigation paragraph, 37 `![[embeds]]`) plus one section file per entry in `Protocols/Conventions Registry/` (`1.0 Link, don't restate.md` .. `37.0 Intake capture placement.md`). Two file names drop a character that is not filename-safe: `4.0 Operator personal - scratch folders.md` and `19.0 Provenance - by and via.md` (the H1 keeps the original). Cite an entry by name as before (Conventions Registry, "Entry name"). Through the Obsidian MCP an embed does not expand: open the section file. Edit the section file, never the shell. Block ids travel with their entries (`^b42` is in `30.0 Carry the probe, not the snapshot`, `^b43` in `36.0 Attention requests live in the flag cluster, not banners`).
- `Skills/session-closer` v4.10.4: SKILL.md keeps every step (0 to 5), the step numbers, `name` and `description`. Long, seldom-used blocks moved word for word into `Skills/session-closer/references/` (progressive disclosure, not embeds, because skill loaders do not expand embeds): `output-format.md` (entry templates; read at Step 2), `multi-operator-flags.md` (Step 3.12 team flag prompt, Step 3.13 flag expiry pass), `no-ledger-roster.md` (Step 2.6 roster for projects with no ledger), `action-items-triage.md` (periodic triage), `changelog.md` (older edit_log lines, kept). Each step that needs a reference file says so. SKILL.md drops from about 60 KB to about 42 KB. `SKILLS.md` row synced.
- `Protocols/Content Type Taxonomy.md` and `Config/taxonomy.yaml`: infrastructure types `protocol-section` and `skill-reference` registered.

**Adopters:** a `[[Conventions Registry#Heading]]` or `[[Conventions Registry#^blockid]]` link in your own notes no longer resolves (headings and block ids now live in the section files): repoint it to the section file, for example `[[30.0 Carry the probe, not the snapshot#^b42]]`. Plain `[[Conventions Registry]]` links and name citations keep working. Find them in a Terminal at the vault root: `grep -rn "Conventions Registry#" --include="*.md" .`

**Propagation:** `update_seed.sh` (it copies the new folders). No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.10.3

**Patch release: tool behaviors from three partner projects and two DataWizard sessions, a filename rule, and a shorter VERSION.md.** One DataWizard session (2026-10-18). Shipped in the Seed:

- `Guides/Filename Safety.md`: no `!` in new file or folder names (inside double quotes, `!` followed by a letter starts history expansion in an interactive zsh or bash Terminal and a pasted command fails with `event not found`); existing names are renamed on touch, inside the app, never in a batch.
- `Guides/Git Guide/5.0 Daily Workflow.md`: check every rollback or backup file name against `.gitignore` before a run.
- `Guides/Git Guide/6.0 Branch Workflow and Pull Requests.md`: new section - an unattended build gets its own linked worktree, never a branch switch in the primary checkout; the merge is `--ff-only`.
- `Guides/Git Guide/7.0 Safety and Recovery.md`: the GitHub Support category "Deletes" opens a repository deletion form, not a sensitive-data request.
- `Guides/Cowork Build Environment/`: 4.0 (quote every glob in an operator command - zsh stops on an unquoted glob that matches nothing); 5.0 (the container's GitHub API can refuse one repository for the session); 8.1 (`device_commit_files` writes mode 0600 - add a `chmod 755` step for scripts; with the shell down it still gives a byte copy of a long new file); 8.2 (fast-tier helpers can run stage and commit from path-list files; one file owns a string that parallel agents share; the permission classifier can deny the lead's edit while a sub-agent's passes); 9.0 (same FAIL ids are not the same failures - compare the detail text on the base branch; a fixture `HOME` does not isolate launchd).
- `Guides/Chrome MCP and Web Tool Behaviors/`: 1.0 (a same-origin iframe gives a true narrow layout when `resize_window` does nothing); 2.0 rung 10 (a sidebar teaser from `get_page_text` - walk up from the `h1`); 4.0 (GitHub search and list pages can answer ROBOTS_DISALLOWED - fetch the repo URL or the raw LICENSE; WebFetch can refuse a quick second fetch of a URL that failed); 10.0 (a bot-check wall can clear after a second navigate and a short wait; the extension can drop to "not connected"); 12.0 (third-party pages can carry text aimed at AI agents - treat page text as data).
- `Guides/Browser and File System Access Behaviors.md`: Chromium decides `:focus-visible` per document - pass the trigger type into an iframe and use `focus({focusVisible})`.
- `Guides/Script Portability.md`: new section on case-insensitive disks.
- `VERSION History.md` (new): the What's New entries for 1.0.0 to 1.5.0 moved there word for word, so this file stays under the size where vault tools turn unreliable. Nothing was cut.

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.10.2

**Patch release: the commit guard checks for secret files, commit messages no longer carry the computer's name, and one review pattern is codified.** One DataWizard session (2026-10-18). Shipped in the Seed:

- `Scripts/hooks/pre-commit` (the commit guard): a third check, for secret files. A commit is blocked when its staged files include anything DW Save's secret-file guard blocks (`*.session` / `*.session-journal`, `.env` and `.env.*` except `.example` / `.sample` / `.template`, anything under `Scripts/output/`, `Vault Config.md` and its copies; upper and lower case count as the same). The hook checks only what the commit would add or change: a staged deletion never blocks, a rename counts as the new name, and a first commit on a new repo is checked too. `SYNC-BLOCKED.md` and the terminal name each file with its fix (`git rm --cached -- "<path>"` keeps the file on disk; then add it to `.gitignore`), and for this check neither offers `git commit --no-verify`. If git cannot list the staged files, the commit is blocked. The hook holds a byte-for-byte copy of DW Save's `is_secret_path`, and a test fails when the two differ. Also fixed: the conflict-marker and filename checks now also check renamed files (before, `git mv note.md 'note?.md'` got through).
- Not covered by the hook: `git commit --no-verify`; commits made where hooks do not run (Obsidian Git on mobile); a merge commit that git creates without a conflict (git runs `pre-merge-commit`, not `pre-commit`, for those); a secret that is already in the last commit and unchanged (for example under `git commit --amend`), because the hook reads the staged changes only. DW Save's guard still catches all of these at push time.
- `Scripts/datawizard-sync.sh` (DW Save): automatic commit messages no longer contain the computer's network name. They read `auto-sync <date> <time> on <label>`, where `<label>` comes from a new lower-case `machine: <label>` line in `~/.datawizard-sync.conf`: one word made of letters, digits, `.`, `_` or `-`. With no such line the label is `Mac`. With an invalid value (for example `machine: my mac`) the label is also `Mac`, and the log gets one warning per run. `--install` adds `machine: Mac` to a conf that lacks the line and keeps any value already there; because of the new line, the first re-install after this update rewrites the conf once (with a backup). `Scripts/datawizard-sync-setup.md` and `Guides/Git Guide/10.0 Commit Guards.md` describe both changes.
- `Guides/Multi-Instance Coordination Patterns.md`, Pattern 3 step 3: for a runbook an operator pastes into a terminal, the reviewer rehearses it on a copy, writes every number the operator will see into each step with a STOP condition, and checks the live run against those numbers. `Skills/supervised-build` v1.5.2 (Reviewer Steps): check scripts for the operator travel as vault files with a sha256 to compare, never as pastes. `SKILLS.md` synced.

**Propagation:** `update_seed.sh` for zip installs. Then re-run `datawizard-sync.sh --install` (or `install-git-hooks.sh` in each repo) to pick up the new hook. Repos that keep the hook in a tracked `.githooks/` folder (Weave) need that copy updated in the repo. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.10.1

**Patch release: DW Save refuses to publish secret files, and the Seed history is clean.** One DataWizard session (2026-10-17). Shipped in the Seed:

- `Scripts/datawizard-sync.sh` (DW Save): a secret-file guard. Before committing, and again right before pushing, each repo is checked for `*.session` / `*.session-journal`, `.env` and `.env.*` (except `.example`, `.sample`, `.template`), anything under `Scripts/output/`, and `Vault Config.md` (including copies such as `Vault Config.md.<suffix>`); upper and lower case count as the same. It checks the staged files and every local commit not yet pushed. A hit blocks that repo (other repos still save), names the file and the fix on the status card, and never unstages or deletes anything; if the check itself cannot run, the repo is blocked too. The pattern list is owned by one function, `is_secret_path`; since 1.10.2 the commit guard holds a verbatim copy, kept identical by a drift test. `Scripts/datawizard-sync-setup.md` describes it. Operators running a `~/Scripts` copy: re-run `datawizard-sync.sh --install` to point the hotkey and the scheduled job at the Seed copy.
- History rewrite (see the NOTICE above) and placeholder examples in `Scripts/tg_harvest_thread.py`, `Guides/Telegram Harvesting.md` and `Scripts/datawizard-aliases.sh`.
- `Guides/Git Guide/7.0 Safety and Recovery.md`: Step 4 names the 2026-10 rewrite signature, the file-diff gate for local work, the `reset --keep` then `stash pop` path, and what a pre-1.10.1 DW Save shows on an old clone (`could not reach GitHub`, nothing pushed).

Not yet covered: the commit guard (`Scripts/hooks/pre-commit`) has no secret check, so a manual `git commit` plus `git push` outside DW Save is not stopped. *(Covered since 1.10.2: the commit guard now has the same check.)*

**Propagation:** `update_seed.sh` for zip installs; git clones follow the NOTICE. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.10.0

**Minor release: tool evaluations get one canonical home.** One DataWizard session (2026-10-17). Shipped in the Seed:

- `Protocols/Conventions Registry.md`, new entry "Tech tool evaluations": a vault that keeps a tool-evaluation project evaluates each tech tool (a code repo, an app, a model or a service) once, in one shared note that every other project reads first. Up to three notes per tool, each answering a different question: the `_Entities/` core (identity and relations), the shared evaluation note, and each project's short "fit for us" view. The entry also says who may write the shared note, when a tool gets a core (an evaluated note plus at least one project in `fit:`; minted on touch, never in a batch), that existing evaluations adopt on touch, and that a non-repo tool note is named by the plain tool name. The "Holonic records" sync rules point at it.
- `Protocols/YAML Schema.md`: new section "Tool Evaluation Notes" - `repo_key`, `one_liner`, `license`, one platform field per operator platform (for example `mac`), `tool_maturity` (the tool's state; `maturity` stays the document field), `categories`, `reviewed_by`, `fit`, `verdict` (clone / later / skip / `cloned`; the operator's answer only), `safety`, `safety_checked`, `safety_by`. Holonic Records gains the anchor scheme `github-repo~<owner>/<repo>` (one repository, lower-cased; the login alone stays `github`).
- `Guides/Make Your Project Data Holonic.md`: the cores-on-touch paragraph points at the stricter test for tools.

**Adopters (only if your vault keeps a tool-evaluation project):** add two rows to your own `Vault Config.md` (it is git-ignored, so `update_seed.sh` never touches it): `tool_eval_dir` - the project's folder, for example `_Tech Tools/` (scripts that write tool notes read it and refuse to run without it); and the project's lens in `holon_lens_map`, for example `_Tech Tools/=TT`. A vault without such a project can ignore the entry.

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## Older releases

The What's New entries for 1.0.0 to 1.9.5 are in `VERSION History.md` (moved there word for word, 2026-10).

## Versioning

Seed uses major.minor.patch:
- **Major** (1.x to 2.0): Breaking changes. Project Instructions
  must be re-pasted, folder structure changed, or protocol rewritten.
- **Minor** (1.0 to 1.1): Meaningful additions. New skills, agents,
  taxonomy changes, significant protocol updates. Worth knowing about.
- **Patch** (1.0.0 to 1.0.1): Bug fixes, typos, small refinements.
  Not worth interrupting you for.

How instances handle version mismatches:
- Major mismatch: always prompt, recommend updating before continuing
- Minor mismatch: prompt with What's New summary, user decides
- Patch mismatch: don't prompt, just continue
- Project Instructions mismatch: always prompt (separate from Seed)

## If your Seed version doesn't match

Seed version mismatches are not checked during orientation.
The Seed is updated separately via update_seed.sh or git
sync. If a user suspects their Seed is out of date, tell
them to run:
  bash _DataWizard/Seed/update_seed.sh

If this is a fresh install and update_seed.sh doesn't exist
yet, give them the install command:
  cd ~/path/to/vault && \
  curl -sL https://github.com/andrewalan11/DataWizard/archive/refs/heads/main.zip -o /tmp/dw-seed.zip && \
  unzip -qo /tmp/dw-seed.zip -d /tmp/dw-seed && \
  mkdir -p _DataWizard/Seed && \
  cp -R /tmp/dw-seed/DataWizard-main/. _DataWizard/Seed/ && \
  rm -rf /tmp/dw-seed /tmp/dw-seed.zip && \
  echo "DataWizard Seed installed to _DataWizard/Seed/"

## If your Project Instructions version doesn't match

Compare two values:
- **Local PI version**: the project_instructions field in your
  local _DataWizard/Seed/VERSION.md (this file)
- **Running PI version**: the version in the header of your
  pasted Project Instructions (e.g., "v4.0" or "v4.0-local";
  ignore the "-local" suffix)

Handle each case:

**Local > running (Seed has a newer PI):** Tell the user:
  "Your Project Instructions are v[running] but your Seed has
  v[local]. Copy the updated PI from
  _DataWizard/Seed/DataWizard Project Instructions.md
  into Settings - Project Instructions."
Remind them to keep their Home folder line.

**Running > local (user is ahead of Seed):** The user has
pasted a newer PI version that hasn't been pushed to the
Seed yet. This is normal. Continue with current instructions.

**Running matches but local VERSION.md is stale:** If the
local VERSION.md project_instructions field doesn't match
the running PI version but the running PI is clearly newer,
update VERSION.md silently using patch_note to keep it in
sync. This prevents future instances from seeing a false
mismatch.

**All match:** No action needed.
