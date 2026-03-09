---
name: commit
description: >-
  This skill should be used when the user wants to commit code changes to git and optionally push to a remote.

  ACTION TRIGGERS:
  - "commit", "git commit", "commit this", "commit my work"
  - "save changes", "create a commit", "conventional commit"

  NATURAL LANGUAGE PATTERNS:
  - "commit" + code/changes context
  - "save my changes" / "commit what I have"
  - "done, commit" / "looks good, commit"

  NOTE: For "commit and push" or "push changes", use the commit-push skill instead.
allowed-tools: Bash, Grep, AskUserQuestion
---

# Commit Workflow

Create a conventional commit and optionally push to GitHub.

## Step 1: Check Git Status

Run `git status --porcelain` to detect changes.

**If no changes**: Report "No changes to commit. Working tree is clean." and stop.

**If changes exist**: Categorize into:
- Staged (A/M in first column)
- Modified (M in second column)
- Untracked (??)

## Step 2: Stage Changes

If nothing staged but changes exist, use `AskUserQuestion` with options:
- **All** -- Stage all changes (`git add -A`)
- **Modified only** -- Stage only modified tracked files (`git add -u`)
- **Select files** -- Let user specify which files

Run the appropriate `git add` command.

## Step 3: Scope Analysis

After staging, run `git diff --cached --stat` and analyze changed files for logical groupings.

**Group changes by scope:**
- Different top-level directories (e.g., `src/` vs `docs/` vs `tests/`)
- Different concerns (feature code vs config vs documentation vs tests)
- Different features or modules within the same directory

**Single-scope** (all changes relate to one concern): proceed to Step 4 with one commit.

**Multi-scope** (2+ unrelated scopes detected): present the grouped changes using `AskUserQuestion`:
- **Split** -- Create separate commits for each scope
- **Single** -- Commit everything together

If splitting:
1. `git reset HEAD` to unstage everything
2. For each scope group:
   - Stage only that group's files (`git add <files>`)
   - Analyze the group diff and auto-commit following Step 4 format
3. After all groups are committed, skip to Step 5 (push)

## Step 4: Analyze and Auto-Commit

Run these in parallel:
- `git log --oneline -5` -- recent commit style for consistency
- `git diff --cached --stat` -- what will be committed
- `git diff --cached` -- full diff for analysis

Analyze the diff and construct a commit message following conventional commits format:

```
<type>(<scope>): <description>

<body>
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

**Auto-commit immediately** -- do NOT ask the user to confirm the message. Execute using heredoc:
```bash
git commit -m "$(cat <<'EOF'
<constructed message>
EOF
)"
```

Verify with `git log -1 --oneline`.

## Step 5: Push to Remote

Check remote: `git remote -v`

If remote exists, ask: "Push to remote?"

If yes:
- Check if branch tracks upstream: `git status -sb`
- If tracking: `git push`
- If not tracking: `git push -u origin <branch>`

Report final status with commit hash.

## Error Handling

| Condition | Response |
|-----------|----------|
| Not a git repo | "Error: Not a git repository. Run `git init` first." |
| No changes | "Nothing to commit. Working tree is clean." |
| Commit hook fails | Report hook output, suggest fixes |
| Push rejected | "Push rejected. Pull latest changes: `git pull --rebase`" |
| No upstream | Suggest `git push -u origin <branch>` |
| No remote | "No remote configured. Commit created locally." |
