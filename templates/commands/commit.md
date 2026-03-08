---
name: commit
description: Create a conventional commit and push to GitHub
disable-model-invocation: true
allowed-tools: Bash, Grep, AskUserQuestion
---

# Commit Command

Create a conventional commit and optionally push to GitHub.

## Workflow

### Step 1: Check Git Status

Run `git status --porcelain` to detect changes.

**If no changes**: Report "No changes to commit. Working tree is clean." and stop.

**If changes exist**: Categorize into:
- Staged (A/M in first column)
- Modified (M in second column)
- Untracked (??)

### Step 2: Stage Changes

If nothing staged but changes exist, use `AskUserQuestion` with options:
- **All** -- Stage all changes (`git add -A`)
- **Modified only** -- Stage only modified tracked files (`git add -u`)
- **Select files** -- Let user specify which files

Run the appropriate `git add` command.

### Step 3: Analyze and Propose

Run these in parallel:
- `git log --oneline -5` -- recent commit style for consistency
- `git diff --cached --stat` -- what will be committed
- `git diff --cached` -- full diff for analysis

Analyze the diff and propose a complete commit message following conventional commits format:

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

### Step 4: Confirm with User

Present the proposed commit message using `AskUserQuestion`:
- **Accept** -- Use as-is
- **Edit** -- Let user modify the message
- **Cancel** -- Abort commit

### Step 5: Create Commit

Execute using heredoc for proper formatting:
```bash
git commit -m "$(cat <<'EOF'
<constructed message>
EOF
)"
```

Verify with `git log -1 --oneline`.

### Step 6: Push to Remote

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
