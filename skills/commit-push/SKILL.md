---
name: commit-push
description: >-
  This skill should be used when the user wants to commit AND push changes automatically without
  any confirmation prompts. Fully autonomous: stages, commits, and pushes.

  ACTION TRIGGERS:
  - "commit and push", "push changes", "save and push", "quick commit"
  - "push it", "ship it", "send it", "push everything"
  - "auto commit", "just push", "commit push"

  NATURAL LANGUAGE PATTERNS:
  - "commit and push" + code/changes context
  - "push" + all/everything/changes
  - "ship it" / "send it up" / "push it up"
  - "quick commit and push"
allowed-tools: Bash, Grep
---

# Commit & Push Workflow (Fully Automatic)

Automatically stage, commit, and push changes with no confirmation prompts.

## Step 1: Check Git Status

Run `git status --porcelain` to detect changes.

**If no changes**: Report "No changes to commit. Working tree is clean." and stop.

**If changes exist**: Categorize into:
- Staged (A/M in first column)
- Modified (M in second column)
- Untracked (??)

## Step 2: Auto-Stage

If nothing is staged, automatically stage all changes: `git add -A`.

If some files are already staged, stage remaining changes too: `git add -A`.

## Step 3: Scope Analysis

Run `git diff --cached --stat` and analyze changed files for logical groupings.

**Group changes by scope:**
- Different top-level directories (e.g., `src/` vs `docs/` vs `tests/`)
- Different concerns (feature code vs config vs documentation vs tests)
- Different features or modules within the same directory

**Single-scope** (all changes relate to one concern): proceed to Step 4 with one commit.

**Multi-scope** (2+ unrelated scopes detected): automatically split into multiple commits.
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

Execute using heredoc:
```bash
git commit -m "$(cat <<'EOF'
<constructed message>
EOF
)"
```

Verify with `git log -1 --oneline`.

## Step 5: Auto-Push

Push immediately without asking:

- Check if branch tracks upstream: `git status -sb`
- If tracking: `git push`
- If not tracking: `git push -u origin <branch>`

Report final status with commit hash(es) and push result.

## Error Handling

| Condition | Response |
|-----------|----------|
| Not a git repo | "Error: Not a git repository. Run `git init` first." |
| No changes | "Nothing to commit. Working tree is clean." |
| Commit hook fails | Report hook output, suggest fixes |
| Push rejected | "Push rejected. Pull latest changes: `git pull --rebase`" |
| No upstream | Auto-set upstream with `git push -u origin <branch>` |
| No remote | "No remote configured. Changes committed locally." |
