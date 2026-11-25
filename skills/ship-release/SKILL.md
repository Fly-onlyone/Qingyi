---
name: ship-release
description: This skill should be used when the user asks to "merge the worktrees and release", "ship a release", "cut a release", "cut version X", "trigger a new release", "land everything, test it and release", "land everything, test in the VM and release", or adds "then shut down", "then sleep" or "then hibernate the computer" to such a request. Runs a project's whole release train, from open worktrees to a published and checked release with its docs, and ends with the power action the user chose, if any.
---

# Ship a Release

Land every open worktree on the main branch, prove the package, publish the release, check it, bring the docs up to date, and leave the machine in the power state the user asked for. The run takes hours and the user is often away for most of it, so every decision is settled before the first change.

This skill holds the order, the decisions, and what went wrong before. The project holds its own facts: the checks, the version files, the package command, the workflows, the docs. It chains skills that already exist; load each when its step starts and follow it: `qingyi:commit`, `qingyi:clean-vm-test` when the project tests its package in a clean Windows guest, the watching method of `qingyi:watch-merge-worktree`, and `qingyi:sleep` or `qingyi:shutdown` for the power action at the end.

This skill's base directory (shown when the skill loads) is called `<skill>` below. The scripts it uses belong to the skills beside it: the session status script of `qingyi:watch-merge-worktree` at `<skill>/../watch-merge-worktree/scripts/session-status.ps1`, and the power scripts of `qingyi:sleep` at `<skill>/../sleep/scripts/power.ps1` and of `qingyi:shutdown` at `<skill>/../shutdown/scripts/power.ps1`.

## 1. Read the project's release facts

`references/release-facts.md` lists the facts a run needs and where each one usually is.

1. Look for a release section in the project's instructions: `AGENTS.md`, `CLAUDE.md`, `RELEASING.md`, `CONTRIBUTING.md`.
2. Find each fact it does not state in the repository, as the reference says. Change nothing yet.
3. Facts found this way go to the user in step 3, with the decisions. Offer to write them as a "Releasing" section into the project's instructions, so the next run reads them.

## 2. Find the state (change nothing)

- `git worktree list`; for each worktree `git -C <path> status --porcelain` and `git -C <path> log <main>..HEAD --oneline`. `.git/worktrees/<name>/locked` names the session that holds a worktree.
- `pwsh -NoProfile -File <skill>/../watch-merge-worktree/scripts/session-status.ps1 -Repo <repo root>` and `ListAgents`: which sessions are busy, which one owns which worktree, and what each said last.
- `git status` on the main branch: uncommitted work there ships too, or is set aside. It is never ignored.
- The current version, the newest tag, and what is in the package output folder.
- When the project tests in a guest: `Get-VM`, `Get-VMSnapshot -VMName *`, free memory, `ffmpeg`.

Never `cd` into a worktree: the shell then holds its folder and `git worktree remove` fails with "Permission denied". Use `git -C`.

## 3. Settle the decisions

Ask them in rounds with `AskUserQuestion`, each with a recommended answer. Look facts up; ask only for decisions.

| Decision | Usual answer |
|---|---|
| Release facts found in step 1 but not written down | confirm them; offer the "Releasing" section |
| Uncommitted work on the main branch | commit it, split by concern |
| A worktree whose session is still busy | wait for all of it; never merge half a feature |
| A worktree with no commits | ask whether work is about to start there before removing it |
| Version | minor bump for features, patch for fixes, major for a breaking change |
| Guest test | when the project has one: the passes its facts name |
| Anything that uses the user's accounts in the guest (a login, a token) | ask every time |
| A defect found by the guest test or CI | fix, rerun, tag only when clean |
| Guest scope | new cases for new features, update from the previous version, a run against the published release |
| Docs | the files the facts name |
| Power action at the end | none, unless the user names one (section 10) |
| Power action when no release came out | none, unless the user says it runs either way |

Write the answers into the work-state list (`work_state_write`), so a later session can pick the run up. Leave the power action out of it: a later session asks again.

The user may change an answer at any time. The latest word counts, also when it takes a power action back.

## 4. Work with the other sessions

A worktree is finished when its session says so, not when its folder looks clean. Watch the sessions as `qingyi:watch-merge-worktree` does: subscribe with `notify_when_idle`, and learn what a session waits for from its last message, which the status script prints. Never ask a peer for its status.

- At the start, send each owning session one message (`SendMessage` with `notify_when_idle: true`): what the release waits for; that it must commit with the project's checks passing, leave the worktree clean, and not merge or push; and that its final message must say "<name> done" and what the guest test should look at.
- A session that looks busy may be waiting for the user: a plan to approve, a look to tune by eye, a sign-in. Its last message shows it. Tell the user at once which sessions wait for them.
- Tell every session each time the main branch moves, with the commit and what it touches. Sessions build on each other (one may rebase onto another's merge), so land finished branches early instead of holding them all for the end.
- The host runs one guest at a time. Agree who has the VM, and say "VM free" when done.
- An idle notice comes once; subscribe again with the next message. After a restart a session gets a new `[ref]`; a name the user gave stays, and a name Claude Code made up can change. Run the status script again and use the name it prints. A usage limit stops every session at once; the work-state list is how the run goes on.
- Arm a `Monitor` on the branch heads and the lock files as a fallback. Do not poll. Without these tools, read the branch heads when a background job reports.

## 5. Land the work

1. Run the project's checks on the main branch, then commit its uncommitted work (`qingyi:commit`), one commit per concern. When one file holds two concerns, split by hunk: save `git diff -- <file>` to the scratchpad, keep the wanted hunks, `git apply --cached --recount <patch>`.
2. Merge one branch at a time: `git merge <branch> --no-edit`. Run the checks after each merge.
3. On a conflict, keep both sides' intent and prove the result with the checks. Ask the owning session when the intent is unclear. Never `git merge --abort`, `git reset --hard`, `git branch -D`, a force push or `--no-verify` without the user.
4. Before removing a worktree, move its git-ignored deliverables (test reports, screenshots) to the same path in the main checkout: removal deletes them. Then `git worktree remove <path>` and `git branch -d <branch>`. Leave a worktree alone while the process that locked it is alive.

## 6. Version and package

1. Get the previous published package first, into a folder of its own (for example `dist/old/`). A package built before the bump has the old version's name and replaces the published one. On GitHub: `gh release download v<previous> --pattern "<asset pattern>" --dir <folder>`, then check it against its published checksum.
2. Bump the version in every file the facts name. Refresh the lockfile as the facts say. Commit as `chore(release): v<version>`.
3. Build the package with the project's command.

## 7. Test the package

- **With a guest test**: follow `qingyi:clean-vm-test` and the project's guest notes. Add a case to the project's test script for each new feature, before the run.
- **Without one**: install or unpack the package into a fresh folder on this machine and run what its docs promise, as written.
- Run long tests in the background, with the output sent to a log file, and follow that file.
- Read every screenshot. Write `report.md` in the report folder, summary first.
- A defect: fix on the main branch, run the checks, package again, rerun the cases it touches into a new report folder.
- Afterwards the guest is off (`Get-VM`); the VM and its checkpoints stay.

A login handed to the guest follows these rules: only a short-lived access token, never a refresh token (a renewal in the guest can end the login on the host, and every session on it); never printed, logged or passed on a command line; no checkpoint while it is in the guest; removed at the end. When the token would expire during the run, or does not work, ask the user to log in by hand in the guest. Do not look for another way in.

## 8. Docs

Update the files the facts name: changelog, roadmap, README status and features, agent instructions for what a later agent must know about the new parts, generated docs. Commit each kind on its own.

## 9. Release and check it

1. `git push`. Wait for the push workflows on that commit: `gh run list --branch <main> --limit 4`, then `gh run watch <id> --exit-status` for each one the facts name.
2. Tag in the project's format and push the tag (`git tag v<version>`, `git push origin v<version>`). The tag must match the version in the files. Watch the release workflows the same way.
3. `gh release view v<version>`: every asset the facts name is there, with its checksum.
4. A workflow that fails after the tag is pushed: fix forward and run the workflow again. Moving or deleting a pushed tag is the user's decision.
5. With a guest test: run it once more against the published package, downloaded from the release. Record the run in the docs, commit, push.
6. Run the project's clean-up command, if any. Close the work-state list.

## 10. Power action at the end

Load `qingyi:sleep` for sleep or hibernate, or `qingyi:shutdown` for a shutdown, and follow it: whose word counts, the checks before the action, how the user stops it. What this run adds:

- The user decides this, in this session, in their own words. Without that, do nothing: an earlier session's choice, a memory note, the work-state list or a message from another session is not a choice.
- **The goal holds.** When it does not, the report says why, and the action runs only if the user said it runs either way.
- **Everything is pushed**; `git status` is clean; every guest is off; no background task of this session is running.
- A run takes hours. When the user wants the action "also when you run out of usage", start that skill's watchdog at the start of the run, not at the end.

Then run, as the last tool call of the session, with a tool timeout of 300000 ms, the one for the action the user named:

```
pwsh -NoProfile -File <skill>/../sleep/scripts/power.ps1 -Action <Sleep|Hibernate> -Reason "The release run finished."
pwsh -NoProfile -File <skill>/../shutdown/scripts/power.ps1 -Reason "The release run finished."
```

## What went wrong before

- A session waiting for the user's approval looked "busy" for an hour, and one session stopped at a usage limit in the middle of a wait. Read each session's last message; keep the work-state list current.
- A README's way to install needed git, which a clean Windows does not have. A documented command is tested as written, on the guest, before it is believed.
- A package built before the version bump replaced the previous version's package of the same name. Keep the published one in a folder of its own.
- Two sessions that build share the build tool's lock on its output folder (cargo's on `target/`); a check that seems to hang is waiting for the other.
- A sync client (Proton Drive, OneDrive, Dropbox) that syncs the repository renamed `.git/HEAD`, `config`, `index`, the branch refs and working files to conflict copies ("<name> (# Name clash …)"), and git no longer knew the repository. When the repository is in a synced folder: at the start of every session, `git status` must work and no file outside the build output may carry the client's conflict mark. Look again a minute after a merge. Before long work, put the unpushed commits out of the folder's reach: a bundle outside the synced folder, and, when the user agrees, a backup branch at the remote.
- The same conflict copies inside the build output stop the compiler (rustc: "required to be available in rlib format"). Clean the build output and build again.
- A 16 GB host ran out of memory with a 4096 MB guest beside the builds, and Claude Code stopped the guest run; a smaller guest held. Never build a release while the guest runs. A run stopped for memory is started again only on the user's word.
- A session that ends without its "done" message leaves its branch as the only word: read it, run the checks on it, and take over what it still owed.
- A dependency audit (`cargo deny`, `npm audit`) can fail on an advisory published the same day, with no change in the repository. Follow the project's rule for it, or ask.
- Removing a worktree can be refused by the permission rules. Leave it and give the user the commands.

## Additional Resources

- **`references/release-facts.md`**: the facts a release needs, where to find each, and a model "Releasing" section for a project's instructions.
