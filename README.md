# Qingyi

> Claude Code plugin for project initialization, reusable skills, and Windows toast notifications.

![version](https://img.shields.io/badge/version-2.8.0-blue)
![license](https://img.shields.io/badge/license-GPL--3.0-green)

## Features

- **`/init` command** — Creates or enhances `CLAUDE.md` and `.claude/rules/` with intelligent gap analysis.
  - **CREATE mode** generates all config files from templates when none exist.
  - **ENHANCED mode** compares dependencies, structure, and patterns against existing docs and prompts before adding gaps.
  - Auto-detects project type from build files (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, etc.).
- **Reusable skills** (auto-discovered by Claude Code):
  - `commit` — Conventional commits (asks before push)
  - `commit-push` — Autonomous commit + push
  - `debug-code` — Guided debugging workflow
  - `excel-read` / `excel-edit` — Read, analyze, write, and style `.xlsx` files
  - `improve-instruction` — Audit and trim `CLAUDE.md` / rule files
  - `merge-worktree` — Merge and clean up git worktrees (auto-commits dirty WIP)
  - `merge-worktree-no-commit` — Land worktree changes via stash, leaving WIP uncommitted
  - `fetch-notion-tasks` — Notion task retrieval, description rewriting, and parallel execution across one worktree per task
  - `obsidian-init` — Scaffold an Obsidian vault that documents a codebase as atomic, graph-linked notes
  - `remove-deadcode` — Systematic dead-code detection
  - `rewrite-history` — Edit old commit messages via `git-filter-repo`
  - `sentry-deploy` — Deploy and configure Sentry error tracking
  - `setup-permission` — Generate Claude Code permission rules
- **Windows toast notifications** — Alerts when Claude finishes work (`Stop`) or needs permission (`PermissionRequest`).


## Requirements

- **Claude Code** (CLI, desktop app, or IDE extension)
- **Windows 10/11** with **PowerShell 5.1+** — required only for toast notifications. All other features are
  platform-agnostic.

## Plugin Settings

Settings live in `qingyi.local.md` (YAML frontmatter) at two levels:

| Scope       | Path                              | Precedence |
|-------------|-----------------------------------|------------|
| **Global**  | `~/.claude/qingyi.local.md`       | Fallback   |
| **Project** | `<project>/.claude/qingyi.local.md` | Overrides global |

| Setting        | Default  | Purpose                                |
|----------------|----------|----------------------------------------|
| `excel_runner` | `python` | Python command prefix for Excel skills |

See [`templates/qingyi.local.md`](templates/qingyi.local.md) for the full template.

## Documentation

- [`CLAUDE.md`](CLAUDE.md) — Full plugin architecture, command internals, template reference, and development guide.
- [`.claude-plugin/plugin.json`](.claude-plugin/plugin.json) — Plugin manifest.
- [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) — Marketplace definition.

## License

GPL-3.0 — see [LICENSE](LICENSE).
