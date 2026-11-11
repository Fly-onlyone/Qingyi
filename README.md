# Qingyi

> Claude Code plugin for project initialization and reusable skills.

![version](https://img.shields.io/badge/version-3.0.0-blue)
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
  - `merge-worktree` — Merge and clean up git worktrees (auto-commits dirty WIP)
  - `merge-worktree-no-commit` — Land worktree changes via stash, leaving WIP uncommitted
  - `fetch-notion-tasks` — Notion task retrieval, description rewriting, and parallel execution across one worktree per task
  - `obsidian-init` — Scaffold an Obsidian vault that documents a codebase as atomic, graph-linked notes
  - `remove-deadcode` — Systematic dead-code detection
  - `rewrite-history` — Edit old commit messages via `git-filter-repo`
  - `sentry-deploy` — Deploy and configure Sentry error tracking
  - `setup-permission` — Generate Claude Code permission rules

## Requirements

### Core

- **Claude Code** (CLI, desktop app, or IDE extension)
- **Git** — used by the commit, worktree, and history skills

All features are platform-agnostic.

### Per-Skill Dependencies

Install only what the skills you use need.

| Skill                                     | Requires                                                                                             |
|-------------------------------------------|------------------------------------------------------------------------------------------------------|
| `excel-read` / `excel-edit`               | Python 3 + `openpyxl` (`pip install openpyxl`); runner set by `excel_runner`                         |
| `obsidian-init`                           | Python 3 (Layer 1 integrity script). Optional: Obsidian 1.12+ with CLI enabled, for graph verification |
| `rewrite-history`                         | `git-filter-repo` (`pip install git-filter-repo`)                                                    |
| `fetch-notion-tasks`                      | Notion MCP server                                                                                    |
| `sentry-deploy`                           | Sentry MCP server; Context7 MCP (SDK docs lookup)                                                    |
| `debug-code`                              | Optional: Sentry MCP (production errors), Context7 MCP (library docs)                               |
| `remove-deadcode`                         | Optional per language: `vulture` (Python), `knip` (TypeScript/JS)                                    |
| `commit`, `commit-push`, `merge-worktree`, `merge-worktree-no-commit`, `setup-permission` | Git only                                                     |

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
