# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Qingyi** is a Claude Code plugin (v4.0.0) that provides an enhanced `/qingyi:project-init` command for project configuration
and reusable skills. It creates CLAUDE.md and `.claude/rules/` files with intelligent gap
analysis for existing projects.

**This is NOT a traditional software project** - there are no build/test commands. This is a plugin configuration
project with a markdown-based command that Claude Code loads to assist with project setup.

**Plugin Marketplace**: [.claude-plugin/marketplace.json](.claude-plugin/marketplace.json)

## Project Structure

```
Qingyi/                                    ← Plugin root
├── .claude-plugin/
│   ├── marketplace.json                   ← Plugin marketplace definition
│   └── plugin.json                        ← Plugin manifest (name, version, metadata)
├── commands/
│   └── project-init.md                    ← /qingyi:project-init command (~200 lines)
├── templates/                             ← External template files
│   ├── CLAUDE.md
│   ├── architecture.md
│   ├── code-guide.md
│   └── documentation-style.md
├── skills/                                ← Auto-discovered skills
│   ├── commit/SKILL.md                   ← Conventional commit (ask before push)
│   ├── commit-push/SKILL.md              ← Auto commit + push (no prompts)
│   ├── debug-code/SKILL.md               ← Debugging workflow
│   ├── excel-edit/SKILL.md               ← Excel write/format/style
│   ├── excel-read/SKILL.md               ← Excel read/analyze/extract
│   ├── fetch-notion-tasks/SKILL.md       ← Notion task fetcher + parallel worktree executor
│   ├── merge-worktree/SKILL.md           ← Merge worktrees (auto-commits dirty WIP)
│   ├── merge-worktree-no-commit/SKILL.md ← Merge worktrees without committing WIP (stash-based)
│   ├── obsidian-init/SKILL.md            ← Scaffold Obsidian vault from a codebase
│   ├── remove-deadcode/SKILL.md          ← Systematic dead-code detection & removal
│   ├── rewrite-history/SKILL.md          ← Git commit message rewriter
│   ├── sentry-deploy/SKILL.md            ← Sentry deployment
│   └── setup-permission/SKILL.md         ← Permission rules generator
├── scripts/
│   ├── install.bat                        ← Windows installation script
│   ├── install.sh                         ← Linux/macOS installation script
│   └── uninstall.bat                      ← Uninstall script
└── CLAUDE.md                              ← This file
```

## The `/qingyi:project-init` Command

### What It Does

The `/qingyi:project-init` command creates or enhances project configuration files:

1. **CLAUDE.md** - Project overview, build commands, dependencies, structure
2. **.claude/rules/architecture.md** - System design, data flow, components
3. **.claude/rules/code-guide.md** - Naming, patterns, code style, best practices
4. **.claude/rules/documentation-style.md** - Comment standards, doc patterns
5. **Commit skill** - Conventional commits + push (auto-triggered, not a slash command)

### Two Modes

| Mode         | Trigger             | Behavior                               |
|--------------|---------------------|----------------------------------------|
| **CREATE**   | No CLAUDE.md exists | Generate all 5 files from templates    |
| **ENHANCED** | CLAUDE.md exists    | Run gap analysis, prompt before adding |

### Gap Analysis (ENHANCED Mode)

When existing config files are found, the command:

1. **Compares dependencies** - Build file vs documented dependencies
2. **Syncs structure** - Actual directories vs documented structure
3. **Discovers patterns** - Scans for undocumented code patterns
4. **Reports gaps** - Shows what's missing with specific findings
5. **Prompts user** - Asks before adding each category of gaps

### Project Detection

Automatically detects project type from build files:

| Build File                            | Project Type          |
|---------------------------------------|-----------------------|
| `package.json`                        | JavaScript/TypeScript |
| `build.gradle`                        | Java/Kotlin           |
| `pom.xml`                             | Java (Maven)          |
| `requirements.txt` / `pyproject.toml` | Python                |
| `Cargo.toml`                          | Rust                  |
| `go.mod`                              | Go                    |
| `composer.json`                       | PHP                   |
| `Gemfile`                             | Ruby                  |
| `*.csproj` / `*.sln`                  | C# / .NET             |

## Installation

From GitHub (no clone needed):

```bash
claude plugin marketplace add Fly-onlyone/Qingyi
claude plugin install qingyi@qingyi
```

From a local clone, run `scripts/install.sh` (Linux/macOS) or `scripts\install.bat` (Windows) from the repo root,
or run the same commands manually:

```bash
claude plugin marketplace add ./
claude plugin install qingyi@qingyi
```

See [README.md](README.md#installation) for in-session install, updating, and uninstalling.

## Usage

After installation, start a new Claude Code session (or run `/reload-plugins` in an open one) and use:

```
/qingyi:project-init
```

Plugin commands are namespaced under the plugin name, so the command is `/qingyi:project-init`, not `/init`.

The command will:

1. Detect your project type
2. Check for existing configuration
3. Create or enhance files as needed
4. Report what was created/modified

## Development

### Command File Structure

Commands use markdown with YAML frontmatter. The command name comes from the file name
(`commands/project-init.md` → `/qingyi:project-init`):

```yaml
---
description: Initialize or enhance Claude Code project configuration (CLAUDE.md + .claude/rules/). Use PROACTIVELY when starting work on a new project.
allowed-tools: Read, Write, Edit, Bash(git:*, ls:*, tree:*), Glob, Grep, AskUserQuestion
---

# Command content and instructions...
```

### Testing Changes

1. Edit `commands/project-init.md`
2. In a project directory, start Claude Code with `claude --plugin-dir <path-to-Qingyi>` to load the working copy for one session
3. Test with `/qingyi:project-init`

To test the installed copy instead, run `claude plugin marketplace update qingyi` and
`claude plugin update qingyi@qingyi`, then start a new session.

## Template Reference

Templates are stored in `templates/` and loaded at runtime using `${CLAUDE_PLUGIN_ROOT}`:

| Template                 | Purpose                            |
|--------------------------|------------------------------------|
| `CLAUDE.md`              | Project overview with placeholders |
| `architecture.md`        | System design template             |
| `code-guide.md`          | Naming, patterns, code style       |
| `documentation-style.md` | Comment standards                  |

Build file → project type mapping relies on Claude's built-in knowledge (no external reference needed).

## Plugin Settings

Settings are Claude Code plugin options, declared under `userConfig` in `.claude-plugin/plugin.json`. Users set them via
`/plugin` → Installed → qingyi → Configure options, `claude plugin install --config KEY=VALUE`, or
`pluginConfigs["qingyi@qingyi"].options` in `~/.claude/settings.json`. Project-level settings files are ignored for
plugin options, so there is no per-project override.

| Option         | Type                       | Default  | Purpose                                                          |
|----------------|----------------------------|----------|------------------------------------------------------------------|
| `excel_runner` | string                     | `python` | Python command prefix for Excel skills                           |
| `log_paths`    | string, `multiple: true`   | `[]`     | Production log paths checked by `debug-code` in production scope |

Skills read a value with `${user_config.KEY}`, which Claude Code substitutes into the skill content:

- A list option is substituted as a comma-separated string (`/a,/b`).
- An unset option stays as the literal `${user_config.KEY}` text, even when the manifest declares a `default`. Each
  skill therefore falls back to its default when the value is empty or still starts with `${`.

When adding an option, declare it in `plugin.json`, reference it in the skill, and add the same fallback.

## Quick Reference

**Last Synced Commit**: `5ebe3f5` (2025-01-12)
