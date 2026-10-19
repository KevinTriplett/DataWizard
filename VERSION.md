
seed: 1.11.1
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

## What's New in 1.9.5

**Patch release: tool behaviors from three DataWizard sessions and two partner projects.** Three DataWizard sessions (2026-10-17). Shipped in the Seed:

- `Guides/Cowork Build Environment/8.0 Device Bridge.md`, the wedged-shell bullet: the fault is not machine-wide, and a new session is not a sure way out - one project had no working device shell in three parallel sessions for a whole day, also after an app restart, and a new session the next day started with the same failure; when the build inputs are one staged bundle, check that a container rebuild matches the staged outputs byte for byte first.
- `8.1 Device Bridge - Staging, Commits and Transport.md`: `device_stage_files` fails the whole call when one listed path does not exist; if the bridge drops mid-session, keep building in the container and commit after reconnect (no new grant needed).
- `8.2 Device Bridge - Sub-agents and Orchestration.md`: worker-tier sub-agents wrote JSON deliverables 6 of 6 times when the lead rendered and checked the notes; parallel sub-agents sharing the operator's Chrome tripped a site's bot check for everyone - throttle them or keep browser work in the lead; a worker's count check against its own selection missed a file.
- `5.0 Network and GitHub Data.md`: Overpass mirrors fail from the container too (proxy drops, 500, 504), the PDF Tools fetch gets 406; Nominatim works from the container; Chrome was the fallback when the device shell was down.
- `Guides/Chrome MCP and Web Tool Behaviors/1.0 Chrome MCP Interaction Limits.md`: `resize_window` can report success while the viewport does not change.
- `4.0 web_fetch Behaviors.md`: GitHub open items are readable, history pages answer ROBOTS_DISALLOWED; "no merge seen" is not evidence.
- `6.0 Scripted Downloads from the Shells (Container and Device).md`: Reddit refuses logged-out reads from every shell (post JSON 403, old.reddit login redirect, bot-check page); a redirect to `/login` must stop a run; the working pattern is an operator-run console script in a logged-in tab that saves one JSON file for a local script to ingest.
- `10.0 Claude-in-Chrome Extension from a Cowork Cloud Session.md`: `javascript_tool` gives up at 45 s while async page work keeps running (fire-and-forget, then poll); page data has no path to a file except through the conversation; the extension refuses some sites "due to safety restrictions" (hand the step to the operator).
- `Guides/Published Artifacts and ArtifactData Behaviors.md`: two confirmations (the read sequence on a 2.3 MB page; capabilities kept when omitted on republish).

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.9.4

**Patch release: seven field learnings from four projects.** One DataWizard session (2026-10-16). Shipped in the Seed:

- `Guides/Cowork Build Environment/8.0 Device Bridge.md`, the wedged-shell bullet: the fault is per session, not per machine, so a new session is the way out, not an app restart; check `get_device_info` for `scratchFolder`; the error text has no detail; stop after two identical failures; list uncommitted files in the handoff; how to rebuild a generated file with the file tools only.
- `Guides/Cowork Build Environment/8.2 Device Bridge - Sub-agents and Orchestration.md`: a sub-agent can write a `.md` when the file is the named deliverable (always give a fallback); new bullet - "preserved in git history" is false until the vault is saved, so move cut text into an archive note in the same step.
- `Guides/Published Artifacts and ArtifactData Behaviors.md`: for a large page, budget the lead's own full read of the live source before the first publish (a sub-agent's read does not count); running the read sequence before the first publish avoids the refusal; a page can carry its own `[hidden]` reset so local and live agree.

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.9.3

**Patch release: two holonic-records schema rulings, and four field learnings.** One DataWizard session (2026-10-16). Shipped in the Seed:

- `Protocols/YAML Schema.md`, Holonic Records: the `community` kind now carries `founded` (with `location`); `place` does not. Relation records keep their place in the list: a retracted record stays at its index, a replacement goes at the end, and no record is removed, spliced or re-ordered, because a consumer may derive an id from a record's position. `Guides/Make Your Project Data Holonic.md` says the same.
- `Guides/Published Artifacts and ArtifactData Behaviors.md`: the refusal sequence after a refused republish - an identical resend can keep being refused; a shell byte-compare or an `Artifact read` with `path` does not count as reading the saved copy; a Read-tool read of a small slice of it clears the refusal.
- `Guides/Chrome MCP and Web Tool Behaviors/2.0 Reading Client-Rendered Pages.md`: rung 9 - a fetch that comes back with only the title and meta description means "unreadable", not "no evidence".
- `Guides/Cowork Build Environment/8.0 Device Bridge.md`: a wedged `device_bash` stays wedged for the session; switch to the stage, edit in the container, commit path.

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. A vault that generates its holonic shared-facts blocks with a script should let `community` carry `founded` there too, or the next regenerate drops the line. (DataWizard, 2026-10)

## What's New in 1.9.2

**Patch release: three big guides become shell + sections, and a third intake batch of field learnings lands.** One DataWizard session (2026-10-15). Shipped in the Seed:

- **Sectioned guides.** `Guides/Cowork Build Environment.md`, `Guides/MCP Reliability and Write Verification.md` and `Guides/Chrome MCP and Web Tool Behaviors.md` were each past or near the ~50 KB line where MCP reads and patches turn unreliable. Each is now a short shell (frontmatter, intro, `![[embeds]]`) plus one section file per former H2 in a folder of the same name; the text was moved byte for byte. The shells' edit_logs are frozen; new edits log on the section files. Device Bridge (Cowork Build Environment 8.0) is further split by theme: 8.0 shell and environment, 8.1 staging, commits and transport, 8.2 sub-agents and orchestration; two near-identical "device shell is GNU Linux" bullets were merged. New learnings go into the matching section file, never the shell.
- **New section** `Cowork Build Environment/10.0 Scanning Third-Party Code.md` (OSV-Scanner call analysis runs the scanned repo's build code; GuardDog can report a clean run it did not finish).
- **Platform and Environment Behaviors plants** from six projects' notes (Evolutionary Media Commons, Holonic Canvas, LocationScout, MetaMyth, Community Stack, DataWizard), about 50 learnings: background jobs in the cloud container (survival past the call is undefined; detach with `setsid nohup ... < /dev/null & disown` and check the log grows); folder grants for deep build paths; `sed -i.bak` leaves undeletable backups on a connected folder; spend-limit kills that still wrote output; the general-purpose sub-agent will not write report `.md` files; the read-only Plan agent; staging, commit and checksum refinements; Python glob order and json.dump reformatting; pipx with the newest Homebrew Python; `pdftotext` ligatures; Playwright flakes under parallel runs and Back with `history.replaceState`; reviewing animation from video; published-artifact comment rounds, overlay mock-ups, the byte-exact publish compare, admin-only root rules and ArtifactData `batch`; `visibility` vs `opacity`; Chrome page-text truncation, auto-translation and embedded state JSON; Obsidian tool flips with no reconnect notice; `git am` stopped halfway without the delete grant; `device_request_delete_permission` in scheduled tasks. Plus one tier-generic "Build rounds" sentence in the Conventions Registry, Model routing.
- **Seed hygiene.** `.gitignore` now ignores `*.bak`: rollback copies stay out of the published Seed (keep them in a backup folder outside the Seed).

**Propagation:** `update_seed.sh`. Links to these guides by name keep working; a heading link of the form `[[Guide#Heading]]` into a sectioned guide should point at the section file. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.9.1

**Patch release: the board's last interim wording goes, and a second intake batch of field learnings lands.** Two DataWizard sessions (2026-10-13). Shipped in the Seed:

- `Protocols/Conventions Registry.md`, "Coordination board": post the ask at write time, not only at close (the close-time check verifies and backfills); the interim clause about the board script refusing `intent:` / `status: seen` is gone (the script now carries both); an ask may carry an optional `resolution:` line; the hand-path id rule is "`next_free`, or the next id above the highest present (mirror incl. Unreconciled, and archive)", in the Registry, the template and the board header alike. `Templates/Coordination Board - Template.md` matches.
- `Skills/session-closer` v4.10.3 (Step 3.14 verifies that each outbound item has a board row and posts only the missing ones). `Skills/supervised-build` v1.5.1 (one worktree and one output folder per parallel builder; no `git stash` across worktrees).
- Platform and Environment Behaviors guides, from five projects' notes (Kosmosis, Holonic Canvas, LocationScout, Evolutionary Media Commons, MetaMyth): `Cowork Build Environment.md` (folder grants: ask for the exact folder, then widen; no connected folder means the Obsidian MCP is the only write path; vault-level files are invisible to the device shell when only a project folder is connected; a Mac venv does not run in the device shell; build sdists in a venv; byte-faithful sectioning; Overpass tiling and `out geom;`; `git archive` crossings miss gitignored inputs; content inventory before consolidating), `MCP Reliability and Write Verification.md` (local MCP tools time out while the computer sleeps; `write_note` append re-serialises the frontmatter; `edit_file` dryRun for files past the read ceiling), `Published Artifacts and ArtifactData Behaviors.md` (no deep-link channel into a published page; byte check before the first publish; recipe strips the trailing close tags; capabilities kept on republish), `Chrome MCP and Web Tool Behaviors.md` (aggregator fallback marked partial; `og:image` contact-sheet check), `Cowork Scheduled Tasks.md` (append-only run log: a launch can start twice), `Multi-Instance Coordination Patterns.md` (a run-card review that executes).

**Propagation:** `update_seed.sh`. No Project Instructions change and no re-paste. (DataWizard, 2026-10)

## What's New in 1.9.0

**Board intake release: five projects' field learnings land in the Seed, plus three schema and board rulings.** A DataWizard intake session triaged 25 cross-project asks (Evolutionary Media Commons, Holonic Canvas, LocationScout, Community Stack, Weave) in one pass. Shipped in the Seed:

- `Guides/Published Artifacts and ArtifactData Behaviors.md` (new, Platform and Environment Behaviors cluster; row in GUIDES.md): the publish read gate and refusal sequence, `Artifact read` URL and large-read behavior, the ArtifactData store (list/out_dir, pinned atomic batch, nested-merge update and the `__delete__` marker, body size cap), who can write to an artifact db, and the rendering constraints (image CSP, no browser automation inside the artifact frame).
- `Guides/Cowork Build Environment.md` (+20): a rejected or cancelled sub-agent launch may still have run; 529 resume by message; staging and commit paths and limits; text-only checksum rule (images change bytes in transit); container survives a restart; folder grants on the nearest parent; `tar --overwrite`; container background jobs die across a pause; per-container staging; Overpass from the device shell; `git archive` has no history (format-patch hand-off); synced-folder `<name> 2.<ext>` duplicates; `device_bash` 180 s cap; a dropped link can leave the command completed; Playwright fold click; Chromium console-error allowlist. Ruling: no git through the device shell on vault-mounted repos stands, with one narrow lead-seat exception (delete grant verified active; never a sub-agent, never unattended).
- `Guides/MCP Reliability and Write Verification.md`, `Guides/Git Guide/9.0 Troubleshooting.md` (lapsed delete grant leaves `HEAD.lock` and `maintenance.lock`; rename-aside recovery), `Guides/Browser and File System Access Behaviors.md` (a script element id that matches a library global shadows it), `Guides/Chrome MCP and Web Tool Behaviors.md` (WebSearch per-turn budget shared across sub-agents; no user identity in a User-Agent; 429 handling; captcha-vs-WebFetch; a Connectors section), `Guides/Cowork Scheduled Tasks.md` (no ask-the-human branch on an unattended skill's normal path; `requires_local_device` binding; `device_absent` and late-PENDING failure modes; launchd cannot read ~/Documents, ~/Desktop, ~/Downloads; `launchctl kickstart`).
- `Protocols/YAML Schema.md`, Holonic Records: predicate `uses` / `used_by` (not symmetric, on a core; role words `user`, `runs on`, `hosted on`, `publishes to` map to it); optional provenance fields `by` (the person the change was made for, `member:<key>`) and `via` (append-only custody hops `<kind>:<id>`); example comments are explanatory, not canonical.
- `Protocols/Conventions Registry.md`: new entry "Provenance: by and via" (rule, example, hop-kind table as the lint set); "Coordination board" gains awareness asks - an `intent: action | awareness` field on asks (default `action`; awareness statuses open -> seen | stale), not a third block kind. `Templates/Coordination Board - Template.md` carries the grammar and an example.
- `Skills/supervised-build` v1.5.0 (reviewer fixture experiments: two runs, partial apply, re-plan; force the event ordering before accepting "flake"; re-count from files; resume the plan reviewer by message; a cancelled launch may have run). `Skills/session-closer` v4.10.1 (Step 3.14 asks whether the session changed something another project depends on; if so, post an awareness ask). `SKILLS.md` synced.

**Not yet in this release:** the board script's `intent` column and `seen` status (a block carrying `intent:` is parked in Unreconciled by the render until that build lands); the holon index merge path for a core that adopts another project's hid.

**Propagation:** Seed files reach every vault through `update_seed.sh`. No Project Instructions change and no re-paste; the `K awareness` orientation trace count waits for the next PI bump. (DataWizard, 2026-10)

## What's New in 1.8.0

**Holonic records: one core per thing, one projection per project.** When several projects each keep a note about the same organization, person, tool or event, the shared facts now live once, in a core note in the vault's `_Entities/` folder. Each project keeps its own note, a projection, with a generated `## Shared facts (from core)` block plus its own view. Every core carries a permanent id, `hid`, that indexes and other tools join on, and relations between things are small records drawn from one predicate list, so `member_of` written in one project means the same thing in every other. Shipped in the Seed:

- `Protocols/YAML Schema.md`, section "Holonic Records": the core fields, twelve kinds (`org`, `network`, `fund`, `community`, `platform`, `protocol`, `tool`, `person`, `project`, `place`, `event`, `work`), keys and anchor schemes, lifecycle (`active`, `merged`, `retired`; nothing is deleted), the `relations:` record and predicate table, the person rules (three states, `team` exposure by default, a field allow-list) and the four projection fields. The "Wikilinks everywhere" rule gains one exception: `core_note` is a plain path. The section's example hids are now valid values (the earlier ones held the digits 8 and 9, outside the `a-z2-7` alphabet).
- `Protocols/Conventions Registry.md`, entry "Holonic records": the rule (consolidate the core, not the views), the shared-facts block and the shorter person block, identity, lifecycle, relations, persons, the sync rules (the core wins for shared facts, corrections flow up, sync is a diff against the live target) and the delivery classes. ID families gains three rows: `hid`, `core_id` and relation ids.
- `Protocols/Content Type Taxonomy.md`: the `entity` line points at Holonic Records. `Config/taxonomy.yaml` is unchanged.
- `Guides/Make Your Project Data Holonic.md` (new): how a project adopts the contract - when a thing needs a core, what a projection carries, writing relations, adding a kind or a predicate, person cores, what an index gives you, and giving an existing vault its hids.

The tooling stays in the maintainer's workshop until a second vault runs it with only Vault Config changes: the index that mints `hid` and answers lookups, the reconcile and backfill scripts, the federating skill and the lint checks. The guide says what each does, so a vault can adopt the contract before the tools ship.

**Coming from the organizations-only shape.** A vault that adopted the earlier, organizations-only version of this convention (it shipped without a version note): cores gain `hid`; `partners:` strings become `relations:` records, each string kept as the record's `raw`; `people:` leaves org cores, because it is relationship content, not a shared fact; each projection gains `hid` as its fourth field, and the block loses its People bullet. (DataWizard, 2026-10)

**Propagation:** the Seed files reach every vault through `update_seed.sh`. No Project Instructions change and no re-paste. Projects adopt on touch, following the guide; nothing in an existing vault changes until a session federates a note.

## What's New in 1.7.0

**Coordination board (cross-project asks and write claims).** One vault-level board says "project X, something waits for you - here is where it is" (asks) and "I am writing this store or subtree until this time" (claims). Each row is a pointer; the content stays in the note it points at. The table lives in the operational database; `_Coordination/Board.md` is the shared markdown mirror. Shipped in the Seed:

- `Templates/Coordination Board - Template.md` - depersonalized starter: header, block grammar, hand-path steps, one example ask and one example claim.
- Conventions Registry entry "Coordination board" (rule, example, and who writes the table: scripts, Claude Code and DW Save write it; a session on a mount that cannot forward SQLite locks, such as Cowork, uses the hand path on the mirror) and the `B-NNNN` row in ID families.
- `Guides/Orientation Flag Sweep - Query Spec.md` section (d): the board sweep as steps over the mirror, the trace fragment, and how to act on an ask.
- `session-closer` v4.10.0: Step 3.14 posts an ask for each outbound item and releases held claims; Step 3.13 notes that claim expiry runs in the board render.
- `Scripts/datawizard-sync.sh` (DW Save): when `board.py` exists and `python3` is on PATH, each save first runs `board.py render` and adds one `board` row to the status card (`folded`, `look at the board`, or `render error`); the save never fails because of the board.
- `Config/taxonomy.yaml`: infrastructure types `coordination-board` and `coordination-board-archive`; drive-by fix: `exchange-note` registered too (it had been unregistered while every Session Exchange note used it - 21 type-validity errors cleared in this vault).

`board.py` itself stays in the DataWizard Workshop until a second operator runs it; until then the board is read by hand from the mirror in other vaults.

**Propagation:** the Seed files reach every vault through `update_seed.sh`; the orientation sub-check reaches each project only through a per-project re-paste of the Project Instructions (required; tracked as a gate row at close).

## Older releases

The What's New entries for 1.0.0 to 1.6.2 are in `VERSION History.md` (moved there word for word, 2026-10).

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
