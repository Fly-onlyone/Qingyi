# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Qingyi** is a Claude Code plugin (v2.1.0) that provides an enhanced `/init` command for project configuration. It creates CLAUDE.md and `.claude/rules/` files with intelligent gap analysis for existing projects.

**This is NOT a traditional software project** - there are no build/test commands. This is a plugin configuration project with a markdown-based command that Claude Code loads to assist with project setup.

**Plugin Marketplace**: [.claude-plugin/marketplace.json](.claude-plugin/marketplace.json)

## Project Structure

```
Qingyi/                                    ← Marketplace root
├── .claude-plugin/
│   └── marketplace.json                   ← Plugin marketplace definition
├── plugins/
│   └── qingyi/
│       ├── commands/
│       │   └── project-init.md            ← /init command (~200 lines)
│       ├── templates/                     ← External template files
│       │   ├── CLAUDE.md
│       │   ├── architecture.md
│       │   ├── commit-messages.md
│       │   ├── conventions.md
│       │   ├── documentation-style.md
│       │   └── patterns.md
│       └── references/
│           └── project-detection.md       ← Build file → project type mapping
├── scripts/
│   ├── install.bat                        ← Windows installation script
│   ├── install.sh                         ← Linux/macOS installation script
│   └── uninstall.bat                      ← Uninstall script
└── CLAUDE.md                              ← This file
```

## The `/init` Command

### What It Does

The `/init` command creates or enhances project configuration files:

1. **CLAUDE.md** - Project overview, build commands, dependencies, structure
2. **.claude/rules/architecture.md** - System design, data flow, components
3. **.claude/rules/commit-messages.md** - Git commit format and conventions
4. **.claude/rules/conventions.md** - Naming, code style, best practices
5. **.claude/rules/documentation-style.md** - Comment standards, doc patterns
6. **.claude/rules/patterns.md** - Reusable code patterns (singleton, factory, etc.)

### Two Modes

| Mode | Trigger | Behavior |
|------|---------|----------|
| **CREATE** | No CLAUDE.md exists | Generate all 6 files from templates |
| **ENHANCED** | CLAUDE.md exists | Run gap analysis, prompt before adding |

### Gap Analysis (ENHANCED Mode)

When existing config files are found, the command:

1. **Compares dependencies** - Build file vs documented dependencies
2. **Syncs structure** - Actual directories vs documented structure
3. **Discovers patterns** - Scans for undocumented code patterns
4. **Reports gaps** - Shows what's missing with specific findings
5. **Prompts user** - Asks before adding each category of gaps

### Project Detection

Automatically detects project type from build files:

| Build File | Project Type |
|------------|--------------|
| `package.json` | JavaScript/TypeScript |
| `build.gradle` | Java/Kotlin |
| `pom.xml` | Java (Maven) |
| `requirements.txt` / `pyproject.toml` | Python |
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `composer.json` | PHP |
| `Gemfile` | Ruby |
| `*.csproj` / `*.sln` | C# / .NET |

## Installation

### Windows
```batch
cd path\to\Qingyi
scripts\install.bat
```

### Linux/macOS
```bash
cd path/to/Qingyi
chmod +x scripts/install.sh
./scripts/install.sh
```

### Manual
```bash
claude plugin marketplace add ./
claude plugin install qingyi@qingyi
```

## Usage

After installation, restart Claude Code and use:

```
/init
```

The command will:
1. Detect your project type
2. Check for existing configuration
3. Create or enhance files as needed
4. Report what was created/modified

## Development

### Command File Structure

Commands use markdown with YAML frontmatter:

```yaml
---
name: init
description: Initialize or enhance Claude Code project configuration
command-type: prompt
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

# Command content and instructions...
```

### Testing Changes

1. Edit `plugins/qingyi/commands/project-init.md`
2. Re-run installation script to update plugin cache
3. Restart Claude Code
4. Test with `/init` in a project directory

## Template Reference

Templates are stored in `plugins/qingyi/templates/` and loaded at runtime:

| Template | Purpose |
|----------|---------|
| `CLAUDE.md` | Project overview with placeholders |
| `architecture.md` | System design template |
| `commit-messages.md` | Git conventions |
| `conventions.md` | Code style rules |
| `documentation-style.md` | Comment standards |
| `patterns.md` | Code patterns guide |

Build file → project type mapping is in `plugins/qingyi/references/project-detection.md`.

## Quick Reference

**Last Synced Commit**: `77951c5` (2025-01-05)
