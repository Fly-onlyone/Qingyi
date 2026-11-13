# Qingyi

> Claude Code plugin for project initialization and reusable skills.

![version](https://img.shields.io/badge/version-4.0.0-blue)
![license](https://img.shields.io/badge/license-GPL--3.0-green)

## Features

- **`/qingyi:project-init` command** — Creates or enhances `CLAUDE.md` and `.claude/rules/` with intelligent gap analysis.
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
  - `temp-style-editor` — Throwaway in-app controls to choose a style by eye, then bake it in and remove every trace

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
| `temp-style-editor`                       | None; uses the project's own UI stack                                                                |
| `commit`, `commit-push`, `merge-worktree`, `merge-worktree-no-commit`, `setup-permission` | Git only                                                     |

## Installation

Qingyi is distributed as a Claude Code plugin marketplace. The marketplace and the plugin are both named `qingyi`, so the plugin ID is `qingyi@qingyi`. No clone is needed.

### Option A: In a Claude Code session

Add the marketplace from GitHub:

```
/plugin marketplace add Fly-onlyone/Qingyi
```

Then open the plugin's details, review what it adds, and choose an install scope:

```
/plugin install qingyi@qingyi
```

In the desktop app's Code tab, you can instead click **+** next to the prompt box, select **Add plugins**, and pick `qingyi` after adding the marketplace.

### Option B: From your shell

```bash
claude plugin marketplace add Fly-onlyone/Qingyi
claude plugin install qingyi@qingyi
```

On Claude Code v2.1.292 or later, one command does both:

```bash
claude plugin install qingyi --marketplace Fly-onlyone/Qingyi
```

The shell install uses user scope (every project on this machine) by default. Pass `--scope project` or `--scope local` to change it.

### Option C: From a local clone (for development)

```bash
git clone https://github.com/Fly-onlyone/Qingyi.git
cd Qingyi
claude plugin marketplace add ./
claude plugin install qingyi@qingyi
```

The `scripts/install.sh` (Linux/macOS) and `scripts\install.bat` (Windows) scripts run the same commands from the repository root.

> **Note:** The install scripts also delete `~/.claude/plugins/cache`. This clears the cache for all plugins, not only Qingyi.

To try local edits for one session without installing, start Claude Code with `claude --plugin-dir ./`.

### Load and verify

A plugin installed from the shell loads the next time you start Claude Code. In a session that is already open, run `/reload-plugins`.

To confirm the install:

- Type `/qingyi:` in a session to list the plugin's command and skills.
- Or run `claude plugin list` in your shell.

Then install the tools listed under [Per-Skill Dependencies](#per-skill-dependencies) for the skills you plan to use.

### Uninstalling

```bash
claude plugin uninstall qingyi@qingyi
claude plugin marketplace remove qingyi
```

Removing the marketplace also uninstalls every plugin installed from it. On Windows, `scripts\uninstall.bat` runs both commands.

## Plugin Settings

Qingyi declares its settings as Claude Code [plugin options](https://code.claude.com/docs/en/plugins-reference#user-configuration) (`userConfig` in `.claude-plugin/plugin.json`).

| Option         | Type             | Default  | Used by                    | Purpose                                                                     |
|----------------|------------------|----------|----------------------------|-----------------------------------------------------------------------------|
| `excel_runner` | string           | `python` | `excel-read`, `excel-edit` | Command prefix for running Python scripts (e.g. `uv run python`)            |
| `log_paths`    | list of strings  | empty    | `debug-code`               | Production log directories or files, checked in production-scope debugging |

### Set the options

Any of these works:

- **In a session:** run `/plugin`, open the **Installed** tab, select `qingyi`, and choose **Configure options**. `excel_runner` also appears as a row in `/config`.
- **At install, from your shell:**

  ```bash
  claude plugin install qingyi@qingyi --config excel_runner="uv run python"
  ```

- **In `~/.claude/settings.json`:**

  ```json
  {
    "pluginConfigs": {
      "qingyi@qingyi": {
        "options": {
          "excel_runner": "uv run python",
          "log_paths": ["/var/log/myapp/"]
        }
      }
    }
  }
  ```

To see which options are set, run `claude plugin configure qingyi@qingyi`.

Options apply to every project. Claude Code reads them from user settings, a `--settings` file, or managed settings, and ignores them in a project's `.claude/settings.json`. Options left unset use the defaults above.

## Documentation

- [`CLAUDE.md`](CLAUDE.md) — Full plugin architecture, command internals, template reference, and development guide.
- [`.claude-plugin/plugin.json`](.claude-plugin/plugin.json) — Plugin manifest.
- [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) — Marketplace definition.

## License

GPL-3.0 — see [LICENSE](LICENSE).
