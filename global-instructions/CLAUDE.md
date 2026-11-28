# User-Scope Instructions

These rules apply to ALL projects.

---

## Tool Routing

**Primary Rule:** Use IDE MCP for searching only. Use default `Read` and `Edit` for reading and editing files.

IDE tools are not called directly. Invoke them through `mcp__idea__execute_tool` with a `command` string (e.g. `search_in_files_by_text ...`) and pass `projectPath`.

```
START
  │
  ├─► IDE MCP CONNECTED + IN PROJECT?
  │     │
  │     ├─ Find files ─────────────────────────────── ► IDE: find_files_by_name_keyword, find_files_by_glob
  │     ├─ Search content ─────────────────────────── ► IDE: search_in_files_by_text, search_in_files_by_regex
  │     ├─ Explore structure ──────────────────────── ► IDE: list_directory_tree, get_all_open_file_paths, get_symbol_info
  │     ├─ READ / EDIT files ──────────────────────── ► Default `Read` / `Edit`
  │     └─ Regex with context lines / multiline ──── ► Default `Grep`
  │
  ├─► IDE NOT CONNECTED / OUTSIDE PROJECT / STALE INDEX ► Default (`Read`, `Edit`, `Grep`, `Glob`)
  │
  ├─► WEB RESEARCH (prefer MCP/skills over default WebSearch)
  │     ├─ Library/framework docs ─────────────────── ► Context7
  │     ├─ GitHub repos/dependencies ──────────────── ► GitHub MCP (`search_repositories`, `get_file_contents`)
  │     ├─ Debugging/troubleshooting issues ───────── ► `brave-search-skills:web-search` (or `brave-search-skills:bx`)
  │     ├─ Latest news/releases ───────────────────── ► `brave-search-skills:news-search`
  │     ├─ General web search ─────────────────────── ► `brave-search-skills:web-search`
  │     └─ Read a specific known URL ──────────────── ► WebFetch / `web-fetch` agent
  │
  └─► GITHUB OPERATIONS ───────────────────────────── ► GitHub MCP (fallback: `gh` CLI)
```

---

## API Research Gate

Before writing a plan or code that uses a **third-party or versioned** library, API, CLI tool, or external service, ask: "Can I verify every method name, parameter, and endpoint I'm about to use?" If not, research first. Usage already present and working in the repo counts as verified. Language standard libraries and common CLI basics (`git`, shell builtins) are exempt.

1. **Context7** → `mcp__context7__resolve-library-id`, then `mcp__context7__query-docs`
2. **Brave** → `brave-search-skills:web-search`
3. **GitHub MCP** → `search_code`, `search_repositories`, `get_file_contents`

Memory is unreliable — method names change, parameters get renamed, endpoints get deprecated. Code written from memory produces bugs that are harder to find than code written from docs.

---

## After Every Edit

After any code edit, lint and format the changed file before moving to the next task:

- **IDE MCP connected:** run `get_file_problems(filePath)` and fix all errors/warnings (except confirmed false positives), then `reformat_file(filePath)`.
- **IDE MCP not connected:** run the project's configured linter and formatter and fix all errors/warnings (except confirmed false positives). If the project has neither configured, say so and continue.

---

## Symbol Rename

Use IDE `rename_refactoring` for renaming symbols (variables, functions, classes, etc.). Never use blind find-replace.

If the IDE MCP is not connected: use the `LSP` tool's rename if available; otherwise `Grep` for every reference, edit each one, re-`Grep` to confirm none remain, and tell the user the IDE rename was unavailable.

---

## Run Configurations

When asked to add or modify IDE run configurations, ALWAYS call `get_run_configurations` first to check existing configs before making changes.

---

## Git Worktrees

- **Shared checkout check:** in a git repository, before the session's first file edit, file write, or state-changing git command, check whether another Claude Code session is working in the same checkout:

  ```powershell
  $me = git rev-parse --show-toplevel
  Get-ChildItem "$HOME/.claude/sessions/*.json" |
    ForEach-Object { Get-Content $_ -Raw | ConvertFrom-Json } |
    Where-Object { $_.sessionId -ne $env:CLAUDE_CODE_SESSION_ID -and $_.status -ne 'idle' -and (Get-Process -Id $_.pid -ErrorAction SilentlyContinue) -and (Test-Path $_.cwd) -and (git -C $_.cwd rev-parse --show-toplevel 2>$null) -eq $me } |
    Select-Object name, pid, status, cwd
  $global:LASTEXITCODE = 0
  ```

  Each row is another session that is working in this checkout right now. An idle session does not count: it waits for a prompt, or was opened and never used. If there is at least one row (2 or more sessions in total), call `EnterWorktree` before the change, without asking. Tell the user in one line which sessions you found and which worktree you entered.
- Skip the check when the session is already in a worktree (`git rev-parse --git-dir` differs from `--git-common-dir`), or when the user says to work in the main checkout.
- Stay in the checkout when the task acts on its current state: committing, pushing, or stashing its changes, or merging worktrees into it.
- **NEVER** auto-delete or remove a git worktree. Do not run `git worktree remove` unless the user **explicitly** asks for it. Worktrees may contain in-progress work — always ask before removing.

---

## System Power State

- **NEVER** shut down, restart, sleep, hibernate, or log off the user's computer unless the user **explicitly** asks for it. This covers commands such as `shutdown`, `Stop-Computer`, `Restart-Computer`, `rundll32 powrprof.dll,SetSuspendState`, `logoff`, `systemctl poweroff/reboot/suspend`, and `pmset sleepnow`, including inside scripts you write or run.

---

## Other Maintainers' Repos

In a repository that someone else maintains, contribute code only.

- **When it applies**, any of:
  - the user says the repository belongs to someone else, or that the work is a contribution to it;
  - it is a fork: it has an `upstream` remote, or `gh repo view --json isFork --jq .isFork` prints `true`;
  - the user has neither admin nor maintain permission on it: `gh api repos/{owner}/{repo} --jq '.permissions.admin or .permissions.maintain'` prints `false`. For a fork, check the parent (`gh repo view --json parent`).

  When unsure, ask once.
- **Allowed:** source code, tests, and build and CI configuration, and only what the change needs.
- **NEVER add or change anything else**, including:
  - scripts: helper, setup, or one-off;
  - docs: README, CHANGELOG, CONTRIBUTING, `docs/`;
  - wiki and notes: CodeWiki notes and `sync_wiki`, an `obsidian/` vault, a GitHub wiki;
  - agent files: CLAUDE.md, AGENTS.md, `.claude/`;
  - plans, reports, and summaries.
- Scratch output goes to the scratchpad, never into the repository.
- This overrides "Post-Feature Documentation Update" below, and any skill or hook that writes docs, notes, or agent files (`/init`, `/qingyi:project-init`, `qingyi:obsidian-init`, `codewiki:write-notes`). Do not run them there, and ignore hook messages that suggest them.
- Only the user's explicit request in the current session, naming the file, lifts this for that file.

---

## Post-Feature Documentation Update

Not in other maintainers' repositories (see above).

After completing a major feature implementation (a new user-facing capability, or new modules/files that change the project's structure or patterns), **ask the user** whether they want to update project documentation:

- **Project CLAUDE.md** — Add new patterns, key files, or conventions introduced by the feature
- **Rule files** (`.claude/rules/`) — Update architecture, code-guide, or other rules if the feature changes project patterns
- **README.md** — Update features list, architecture diagram, API reference, or other sections affected by the feature

**Do NOT auto-update docs.** Ask: "Should I update the project docs (CLAUDE.md / rules / README) to reflect this feature?"
