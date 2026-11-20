# Session States and Traps

Real last messages from watched sessions, what they meant, and the traps met while watching.
Quotes are shortened.

## Last Messages by State

### Done

> "Your usage limit has been reached, but the feature is built and checked against the real
> API server. It is on branch `feat/proxy-provider` in its own worktree: 8 commits, not pushed and not
> merged into `main`. ... **Left for you:** review the branch, then tell me to merge it."

> "Both asks are done on branch `feat/settings-dropdown`. Tests pass ... The report,
> screenshots and recording are in `report\...` inside the worktree. That folder is git-ignored, so
> I'll move it to the main checkout's `report\` before the worktree is removed."

Done, ready to merge. The second message names a git-ignored folder to keep: move it before the
worktree is removed (SKILL.md, Step 6).

### Merged Itself

> "The fixes are merged into `main` and pushed (`1a2b3c4..5d6e7f8`). ... The worktree and its
> branch are removed."

Its worktree is gone from `git worktree list`. Mark it done; there is nothing to merge.

### Merging Itself

> "The merged-tree checks are running. When they pass: merge into `main` through a temporary
> worktree, push, then remove both worktrees and the branch."

Wait. Merging the same branch from the watching session at the same time races with it.

### Waiting on a Job

> "Tests still running. Waiting for completion notification."

> "Diff reviewed: 20 files changed plus a new module. Waiting for the release package build,
> which runs in the background and notifies on completion. Next come the symbol upload, then
> the VM run."

Idle but not done. Arm the transcript watcher.

### Waiting on the User

> "The sign-in page is open in the Chrome tab "Sign in". Please sign in there yourself; I can't
> enter credentials. ... run `! gh secret set DEPLOY_TOKEN` yourself."

> "The sign-in callback listens on port 54545. Waiting for your approval in the browser."

> "The parser fix is committed on branch `fix/parser-edges`, but it is not merged or pushed
> yet. The permission check blocked merging into `main` and
> pushing, so I need your go-ahead for that."

Relay the ask to the user in one or two lines. The third one also left the main checkout on a side
branch. Its merge into `main` needs the user's OK, not the watcher's: doing it for the peer would
get around the user's permission decision.

### Usage Limit

> "You've hit your 5-hour limit · resets 12:30pm"

The message before it tells how far the session got, for example "All five tasks are in the
ledger. Waiting on the reviewer." That session had finished its tasks, but its final review had
not. After the reset it resumed under the same name and finished.

## Traps

### Same-Turn Idle Notices

Subscribing to a session that is already idle fires a notice at once, with the same "finished a
turn at HH:MM" time as the notice before. Subscribing again in reply loops. Compare the turn time
with the previous notice for that session; when it repeats, arm `wait-for-change.sh` on the
transcript and subscribe only after it exits.

### Idle Is Not Done

"Idle" covers a finished session, one waiting on a background job, one waiting on the user, and
one stopped by a usage limit. Only the last message tells them apart.

### Helper Sessions

Sessions named like `3302-28`, `3305-d8`, `observer-sessions-f6` or `work-view-e9` appear and go
idle within a minute or two. They belong to other tools (memory observers, viewers) and have no
transcript in the repository. Ignore them.

### Renamed Sessions

`ListAgents` showed "remove-account-settings · says it was proxy-provider-writer until
4m ago". The session had reported its branch done, then got new work in the same worktree:
13 uncommitted files appeared on a branch already marked done. Classify again after every rename.

### Resumed and Restarted Sessions

After a restart, a session keeps its transcript file and gets a new `[ref]` in `ListAgents`. A
name the user gave stays. A name Claude Code made up (`<folder>-<2 hex digits>`, such as
`myrepo-3f`) can come back as another one. Run the status script: it prints the current name of
each running session. Subscribe again under that name.

### Sessions That Work by Path

A session whose working folder stays the main checkout can work in a worktree through
`git -C <path>` and absolute paths. Its transcript entries then carry the main checkout's folder
and branch. The status script lists the worktrees its transcript names, as a hint. Confirm from
the last message: sessions also name worktrees they only listed.

### Main Checkout on a Side Branch

A session switched the main checkout to `fix/parser-edges` and left it there, waiting
for the user's go-ahead. `qingyi:merge-worktree` merges into the branch checked out in the main
checkout, so it has to be back on the main branch first.

### Memory Reaping

The harness stopped a background watcher with "stopped because the system is running low on
memory" while several sessions built code. Do not restart it on your own. Tell the user which
session is no longer watched, and keep the watching session free of builds and tests.

### Branches Behind the Main Branch

When one session merges into the main branch, the others fall behind it. That is normal:
`qingyi:merge-worktree` merges them, and reports conflicts instead of resolving them.
