---
name: merge-worktree
description: >-
  This skill should be used when the user wants to commit, merge, and clean up git worktrees back
  into the main branch. Handles uncommitted worktree changes, merges all branches, removes
  worktrees, deletes feature branches, optionally pushes, and summarizes all changes.

  ACTION TRIGGERS:
  - "merge worktrees", "merge worktree", "merge all worktrees"
  - "commit worktrees and merge", "finish worktrees", "land worktrees"
  - "clean up worktrees", "merge branches back", "consolidate worktrees"
  - "merge worktree changes", "close worktrees", "wrap up worktrees"

  NATURAL LANGUAGE PATTERNS:
  - "merge" + "worktree(s)" / "branch(es)" + optional "push"
  - "finish" / "land" / "close" / "wrap up" + "worktree(s)"
  - "commit all worktrees and merge into master/main"
  - "clean up worktrees and push"
allowed-tools: Bash, Grep, Read
---

# Merge Worktree Workflow

Commit all worktree changes, merge every feature branch into the main branch, clean up worktrees
and branches, optionally push, and produce a summary.

## Step 1: Discover Worktrees

Run `git worktree list` from the project root.

**If only the main worktree exists**: Report "No additional worktrees found. Nothing to merge." and stop.

**If worktrees exist**: Record each worktree path and its branch name. Identify the main branch
(the branch checked out in the primary worktree — typically `master` or `main`).

## Step 2: Inspect All Worktrees (parallel)

For **each** worktree (excluding the main one), run these in parallel:

```bash
cd <worktree_path> && \
  echo "=== BRANCH ===" && git branch --show-current && \
  echo "=== STATUS ===" && git status --porcelain && \
  echo "=== LOG (ahead of main) ===" && git log <main_branch>..HEAD --oneline
```

Categorize each worktree into:
- **Has uncommitted changes** — needs commit first
- **Has commits ahead of main** — ready to merge
- **Both** — needs commit, then merge
- **Clean and even** — nothing to do (skip it)

**If all worktrees are clean and even**: Report "All worktrees are already merged. Nothing to do."
and proceed to Step 6 (cleanup only).

## Step 3: Get Diffs for Uncommitted Worktrees (parallel)

For each worktree that has uncommitted changes, run in parallel:

```bash
cd <worktree_path> && git diff && git diff --cached
```

Also check for untracked files that need to be added.

Read the full diff to understand the changes — this is needed for accurate commit messages.

## Step 4: Commit All Dirty Worktrees (parallel)

For each worktree with uncommitted changes, run in parallel:

1. Stage all changes: `git add -A`
2. Write a conventional commit message based on the diff analysis from Step 3

**Commit message format:**

```
<type>(<scope>): <short description>

<body — what and why, not how>
```

**Commit types:**

| Type | When to Use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code change that neither fixes nor adds |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `chore` | Build process, dependencies |

**Rules:**
1. Subject line under 72 characters (target under 50)
2. Use imperative mood ("add" not "added")
3. No period at end of subject
4. Body explains what and why, not how
5. Scope should reflect the feature/area (e.g., `agent`, `admin`, `knowledge`)

Execute using heredoc:
```bash
cd <worktree_path> && git add -A && git commit -m "$(cat <<'EOF'
<constructed message>
EOF
)"
```

## Step 5: Merge All Branches into Main (sequential)

Switch to the main worktree (project root) and merge each feature branch **one at a time**:

```bash
cd <project_root> && git merge <branch_name> --no-edit
```

**Why sequential**: Merges may conflict, and each merge changes HEAD, so they cannot be parallelized.

**If a merge conflict occurs**:
1. Report the conflict to the user with the conflicting files
2. Ask how to proceed (resolve, skip, or abort)
3. Do NOT force-resolve or drop changes automatically

**Track results**: Record for each branch whether it was a fast-forward or a merge commit.

## Step 6: Clean Up Worktrees and Branches

After all merges succeed:

1. **Remove worktrees** (sequential, since git locks the worktree list):
   ```bash
   git worktree remove <worktree_path>
   ```
   Do this for every worktree that was merged.

2. **Delete merged feature branches**:
   ```bash
   git branch -d <branch1> <branch2> ...
   ```
   Use `-d` (not `-D`) so git refuses to delete unmerged branches as a safety check.

## Step 7: Push (if requested)

If the user asked to push (or the invocation arguments mention "push"):

- Check tracking: `git status -sb`
- If tracking upstream: `git push`
- If not tracking: `git push -u origin <main_branch>`

If push was not requested, skip this step and note that changes are local only.

## Step 8: Summary

Produce a structured summary of everything that happened:

```
## Summary

Merged N worktree(s) into <main_branch> (<old_hash>..<new_hash>).

### 1. `<branch-name>` -- <short title>
- <bullet points describing what changed>
- **N files**, +X / -Y lines

### 2. `<branch-name>` -- <short title>
- ...

### Cleanup
- Removed N worktree(s)
- Deleted N feature branch(es)
- Pushed to origin/master (if applicable)
```

**Per-branch summary rules:**
- Lead with the feature/fix, not file names
- Include file count and line delta
- Mention new files created, if any
- Keep each branch summary to 2-4 bullet points

## Error Handling

| Condition | Response |
|-----------|----------|
| Not a git repo | "Error: Not a git repository." |
| No worktrees | "No additional worktrees found. Nothing to merge." |
| All worktrees clean | "All worktrees are already merged." then proceed to cleanup |
| Merge conflict | Report conflicting files, ask user how to proceed |
| Branch delete fails (`-d`) | Branch has unmerged commits — warn user, do NOT use `-D` |
| Push rejected | "Push rejected. Pull latest changes: `git pull --rebase`" |
| Worktree remove fails | Report the error; may need manual cleanup |
| No remote configured | "No remote configured. Changes committed and merged locally." |

## Safety Rules

- **NEVER** use `git merge --abort` or `git reset --hard` without user confirmation
- **NEVER** use `git branch -D` (force delete) — always use `-d` (safe delete)
- **NEVER** force-push (`git push --force`)
- **NEVER** skip pre-commit hooks (`--no-verify`)
- If a worktree has no changes and no commits ahead, skip it silently
- If arguments mention specific worktrees, only process those (not all)
