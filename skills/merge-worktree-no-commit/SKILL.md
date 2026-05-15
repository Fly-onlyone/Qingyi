---
name: merge-worktree-no-commit
description: >-
  This skill should be used when the user wants to land worktree changes into the main branch
  WITHOUT committing them in the worktree first. Uses git stash through the shared .git directory
  to transport uncommitted edits; existing commits on the worktree branch are still merged
  normally. The source worktree and its branch are left in place after a successful transfer.

  ACTION TRIGGERS:
  - "merge worktree without commit", "merge worktree without committing"
  - "merge worktree no commit", "merge worktree skip commit"
  - "transport worktree changes", "move worktree changes to main"
  - "merge worktree wip", "land uncommitted worktree changes"
  - "merge worktree but keep changes uncommitted"

  NATURAL LANGUAGE PATTERNS:
  - "merge" + "worktree(s)" + ("without committing" / "no commit" / "skip commit")
  - "bring" / "move" / "transfer" + worktree changes + main/master
  - "I don't want to commit in the worktree" + merge context
  - "pull" / "pick up" + worktree edits + main + uncommitted
allowed-tools: Bash, Grep, Read
---

# Merge Worktree Without Commit Workflow

Transport the **uncommitted working-directory edits** of one or more git worktrees into the main
worktree as still-uncommitted edits. Existing commits on each worktree branch are merged normally;
no commit is ever fabricated in the source worktree. The source worktrees and their branches are
preserved.

## Why git stash, not git merge

`git merge` only operates on commits, so uncommitted edits cannot be "merged" in git's sense. All
worktrees of a repository share a single `.git` directory and therefore a single stash list, so
`git stash push` in one worktree and `git stash pop` in another worktree of the same repo is a
clean, native transport. This skill leverages that.

## Step 0: Snapshot Main's WIP (if any)

Run from the project root:

```bash
git status --porcelain
```

**If the main worktree is clean**: Skip the rest of this step; proceed to Step 1.

**If the main worktree has uncommitted changes**: Stash them under a named entry so they can be
restored last, after all transported edits are in place:

```bash
cd <project_root> && \
  git stash push --include-untracked -m "merge-worktree-no-commit:MAIN-WIP"
```

Record that a `MAIN-WIP` stash exists. It will be popped back in Step 7.

Rationale: popping a transported stash onto an already-dirty main is the single most likely source
of confusion. Snapshotting main's WIP first guarantees each pop starts from a clean tree, and the
final restoration step makes any conflict between main's original WIP and the transported edits
explicit (surfaced at one well-defined point, not silently entangled).

**If main has WIP but the stash push fails** (e.g., disk full, hook rejection): Abort. No other
state has been touched yet — safe stop.

## Step 1: Discover Worktrees

```bash
git worktree list
```

**If only the main worktree exists**: Report "No additional worktrees found. Nothing to transport."
and stop.

**Otherwise**: Record each worktree path and its branch. Identify the main branch (the branch
checked out in the primary worktree — typically `master` or `main`).

## Step 2: Inspect All Worktrees (parallel)

For **each** non-main worktree, run in parallel:

```bash
cd <worktree_path> && \
  echo "=== BRANCH ===" && git branch --show-current && \
  echo "=== STATUS ===" && git status --porcelain && \
  echo "=== LOG (ahead of main) ===" && git log <main_branch>..HEAD --oneline
```

Classify each worktree:

| Working tree | Commits ahead | Action |
|--------------|---------------|--------|
| clean        | none          | skip (no-op) |
| clean        | yes           | `git merge` into main (no stash needed) |
| dirty        | none          | stash in worktree → pop in main |
| dirty        | yes           | stash in worktree → `git merge` in main → pop in main |

If every worktree is "clean + no commits", report "Nothing to do." and stop.

## Step 3: Get Diffs for Dirty Worktrees (parallel)

For each worktree with uncommitted changes, capture the diff so the final summary can describe
what was transported:

```bash
cd <worktree_path> && git diff HEAD && git status --porcelain
```

`git diff HEAD` covers both staged and unstaged tracked-file changes. The porcelain status lists
any untracked files (those will be picked up by `git stash push -u`).

Read the diff enough to write a one-line description per worktree for the final summary. **Do not
write a commit message — no commit is happening here.**

## Step 4: Stash WIP in Each Dirty Worktree (sequential)

Process dirty worktrees **one at a time** to keep the stash list ordered and unambiguous. For each
dirty worktree, with branch name `<branch>`:

```bash
cd <worktree_path> && \
  git stash push --include-untracked -m "merge-worktree-no-commit:<branch>"
```

**Key flags:**

- `--include-untracked` (`-u`): captures untracked files too, so newly-created files transport correctly.
- `-m "merge-worktree-no-commit:<branch>"`: names the stash so we can find it by message later, independent of stash index.

**Record** the stash reference for this branch (the message string is enough — we look it up by
message in Step 6, not by `stash@{N}` index).

After this step the source worktree's working directory is clean and its branch is unchanged.

## Step 5: Merge Committed Work into Main (sequential)

From the main worktree (project root), merge any branch that has commits ahead of main. Process
**one at a time** — merges change HEAD and may conflict:

```bash
cd <project_root> && git merge <branch_name> --no-edit
```

Order: merge the *cleanest* branches first (those with commits but no WIP), then branches that
also had WIP (now stashed). This keeps the stash-pop step in Step 6 applying onto already-merged
code, minimizing conflict surface.

**On merge conflict**:
1. Report the conflicting files.
2. Ask the user how to proceed (resolve, skip remaining branches, or abort).
3. Do NOT auto-resolve, do NOT `git merge --abort` without user consent.
4. If aborted: the stashes from Step 4 (and the `MAIN-WIP` stash from Step 0, if any) are still
   in the stash list — tell the user every stash message string so they can recover them manually
   with `git stash apply "stash@{/<message>}"`.

## Step 6: Pop Each Transported Stash into Main (sequential)

For each stash created in Step 4, in the **same order** they were created (FIFO from the user's
perspective):

```bash
cd <project_root> && \
  git stash pop "stash@{/merge-worktree-no-commit:<branch>}"
```

The `stash@{/<message-prefix>}` syntax looks the stash up by message, so it's robust against
other unrelated stashes existing in the list.

**On stash pop conflict**:
1. Leave the conflict markers in place — do NOT auto-resolve.
2. The stash **is NOT dropped** automatically by git when pop conflicts (this is git's default
   behavior — stash entry stays for safety).
3. Stop the workflow. Report:
   - Which file(s) conflict.
   - The exact stash reference (e.g., `stash@{0}` or by message) so the user can resolve and
     `git stash drop` themselves.
   - Remaining unpopped stashes (skill will not continue automatically).

## Step 7: Restore Main's Original WIP (if Step 0 stashed it)

**Skip this step** if Step 0 did not create a `MAIN-WIP` stash.

Otherwise, pop main's pre-existing WIP back on top of the transported edits:

```bash
cd <project_root> && \
  git stash pop "stash@{/merge-worktree-no-commit:MAIN-WIP}"
```

**Why last**: main's original WIP is the most likely to conflict with the transported edits
(both touch files the user is actively editing). Restoring last localizes any conflict to one
well-defined step, and the conflict markers will clearly distinguish "incoming from worktree" vs
"main's original" because main's WIP arrives via stash pop on top of an otherwise clean tree.

**On conflict popping `MAIN-WIP`**:
1. Leave conflict markers in place — do NOT auto-resolve.
2. The stash entry remains in the stash list (git's default).
3. Report to the user:
   - Conflicting files.
   - The stash reference: `stash@{/merge-worktree-no-commit:MAIN-WIP}`.
   - That the transported edits are already in place and only main's original WIP collides.
4. Stop the workflow. The user resolves conflicts, then `git stash drop` the entry.

## Step 8: No Cleanup

Intentionally, this skill does NOT:
- Remove any worktree.
- Delete any branch.
- Push anything.

Rationale: the user chose to keep work uncommitted, so they likely want to keep iterating in the
source worktree and decide later whether to abandon it. They can run the regular `merge-worktree`
skill once they're ready to commit and clean up.

## Step 9: Summary

```
## Summary

Transported N worktree(s) into <main_branch>. No commits were created in any worktree.

### Committed work merged
- `<branch-A>` — fast-forward / merge commit (X commits)
- `<branch-B>` — ...

### Uncommitted work transported
- `<branch-C>` — M files, +X / -Y lines, transported via stash
- `<branch-D>` — ...

### State
- Main worktree: working tree shows transported edits + main's pre-existing WIP (uncommitted)
- Source worktrees: still exist, working trees clean, branches unchanged
- Stash list: <N entries dropped; M entries remaining if any conflicts, including MAIN-WIP if applicable>
```

If Step 0 had to stash main's WIP, mention it explicitly in the summary so the user knows their
original edits were preserved across the operation.

**Per-worktree summary rules:**
- Lead with the high-level intent of the changes (inferred from the diff), not file names.
- Include file count and line delta for the transported portion.
- Mention any newly-created files explicitly — they came in via `--include-untracked`.

## Error Handling

| Condition | Response |
|-----------|----------|
| Not a git repo | "Error: Not a git repository." |
| Main worktree dirty (Step 0) | Stash as `MAIN-WIP`; restore in Step 7. Abort only if stash push itself fails |
| No additional worktrees | "No additional worktrees found. Nothing to transport." |
| All worktrees clean and even | If main also clean: "Nothing to do." If main had WIP: it was untouched, no stash created |
| Merge conflict (Step 5) | Report conflicting files; ask user; all stashes preserved (worktree + MAIN-WIP) |
| Stash pop conflict (Step 6) | Report file + stash ref; stop workflow; do NOT drop stash; MAIN-WIP remains untouched |
| Stash pop conflict (Step 7, MAIN-WIP) | Report file + stash ref; stop workflow; do NOT drop stash |
| Stash push fails | Report error; likely permissions or disk issue; do NOT continue |
| Untracked file collision | `git stash push -u` handles this; if it fails, surface git's message verbatim |

## Safety Rules

- **NEVER** commit in any worktree (including main) — that is the entire point of this skill.
- **NEVER** drop a stash that failed to pop cleanly.
- **NEVER** skip Step 0's snapshot of main's WIP when main is dirty — popping transported stashes
  onto an already-dirty main entangles edits and is recoverable only via reflog.
- **NEVER** use `git stash pop` without the `stash@{/...}` message reference. Multiple named
  stashes will exist concurrently, so positional refs like `stash@{0}` are unreliable.
- **NEVER** remove a worktree or delete a branch from this skill. That is `merge-worktree`'s job.
- If arguments mention specific worktrees, only process those (not all).
