---
name: rewrite-history
description: >-
  This skill should be used when the user wants to edit, rewrite, or fix old git commit messages
  using git-filter-repo.

  ACTION TRIGGERS:
  - "rewrite history", "rewrite commit", "reword commit", "edit commit message"
  - "fix commit message", "change commit message", "rename commit"
  - "filter-repo", "bulk edit commits", "replace in commit messages"
  - "fix old commit", "update commit messages", "clean up history"

  NATURAL LANGUAGE PATTERNS:
  - "rewrite" / "reword" / "edit" / "fix" + commit message context
  - "change the message on" + commit hash/description
  - "find and replace" + commit messages
  - "bulk update" + commit messages / history
  - "typo in commit" / "wrong commit message"

  NOTE: For amending only the most recent commit message, use `git commit --amend` directly.
  This skill targets older commits that require history rewriting.
allowed-tools: Bash, AskUserQuestion
---

# Rewrite History Workflow

Edit old git commit messages using `git-filter-repo`.

## Step 1: Verify Prerequisites

Run `git filter-repo --version` to check installation.

**If not installed**: Report the error and suggest installation methods:

| Platform | Command                                        |
|----------|------------------------------------------------|
| pip      | `pip install git-filter-repo`                  |
| brew     | `brew install git-filter-repo`                 |
| scoop    | `scoop install git-filter-repo`                |
| conda    | `conda install -c conda-forge git-filter-repo` |

Stop and wait for the user to install before continuing.

**If installed**: Proceed to Step 2.

## Step 2: Verify Clean Working Tree

Run `git status --porcelain`.

**If dirty**: Report uncommitted changes and stop. Instruct the user to commit or stash changes first —
`git-filter-repo` requires a clean working tree.

**If clean**: Proceed to Step 3.

## Step 3: Show Commit Log

Run `git log --oneline -20` so the user can identify target commits.

Display the output and proceed to Step 4.

## Step 4: Determine Rewrite Mode

Ask the user via `AskUserQuestion` which mode to use:

- **Single** — Edit one commit message by hash
- **Multiple** — Edit several commit messages by hash
- **Find-replace** — Replace text or regex pattern across all commit messages
- **Range** — Scope edits to a specific ref range (e.g., `HEAD~10..HEAD`)

For **Single** and **Multiple**: ask the user for the commit hash(es) and the new message(s).

For **Find-replace**: ask for the search pattern and replacement text. Ask whether to use exact string match or regex.

For **Range**: ask for the ref range, then ask which sub-mode (single, multiple, or find-replace) to apply within that
range.

## Step 5: Create Backup Branch

**This step is mandatory.** Always create a backup before rewriting.

Run:

```bash
git branch backup/pre-rewrite-$(git rev-parse --short HEAD)-$(date +%s)
```

Report the backup branch name to the user.

## Step 6: Execute Rewrite

Resolve any short commit hashes to full hashes first using `git rev-parse <short-hash>`.

### Single / Multiple Mode

Build a `--commit-callback` that matches `commit.original_id` and replaces the message:

```bash
git filter-repo --commit-callback '
import sys
replacements = {
    b"<full-hash>": b"<new message>\n",
}
for orig_id, new_msg in replacements.items():
    if commit.original_id == orig_id:
        commit.message = new_msg
        break
' --force
```

For multiple commits, add all hash-message pairs to the `replacements` dict.

### Find-Replace Mode (Exact String)

```bash
git filter-repo --message-callback '
return message.replace(b"<search>", b"<replace>")
' --force
```

### Find-Replace Mode (Regex)

```bash
git filter-repo --message-callback '
import re
return re.sub(rb"<pattern>", rb"<replacement>", message)
' --force
```

### Range Mode

Append `--refs <range>` to any of the above commands. Example:

```bash
git filter-repo --refs HEAD~10..HEAD --message-callback '
return message.replace(b"<search>", b"<replace>")
' --force
```

**Always use `--force`** — required for non-fresh-clone repos.

## Step 7: Verify Results

Run `git log --oneline -20` and display the updated commit history.

Ask the user to confirm the results via `AskUserQuestion`:

- **Looks good** — Proceed to Step 8
- **Rollback** — Restore from backup:
  ```bash
  git reset --hard backup/pre-rewrite-<timestamp>
  ```
  Report rollback complete and stop.

## Step 8: Remote Push Warning

Run `git remote -v` to check for remotes.

**If remotes exist**: Warn the user:

> These changes rewrote commit history. To update the remote, a force push is required:
> ```
> git push --force-with-lease
> ```
> **Warning**: Force-pushing rewrites history for all collaborators. Coordinate with your team before pushing.

**Never auto-execute force push.** Only display the command for the user to run manually.

**If no remotes**: Report "No remotes configured. History rewritten locally."

## Step 9: Cleanup

Ask the user via `AskUserQuestion` whether to delete the backup branch:

- **Delete** — Run `git branch -D backup/pre-rewrite-<timestamp>` and confirm deletion
- **Keep** — Report "Backup branch retained: `backup/pre-rewrite-<timestamp>`"

## Error Handling

| Condition                       | Response                                                              |
|---------------------------------|-----------------------------------------------------------------------|
| `git-filter-repo` not installed | Show installation options (pip/brew/scoop/conda) and stop             |
| Not a git repository            | "Error: Not a git repository. Run `git init` first."                  |
| Invalid commit hash             | "Error: Commit `<hash>` not found. Check `git log` for valid hashes." |
| Dirty working tree              | "Error: Uncommitted changes detected. Commit or stash changes first." |
| `filter-repo` failure           | Display the full error output, suggest rollback via backup branch     |
| Backup branch already exists    | Append a unique suffix or use a different timestamp                   |
