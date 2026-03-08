# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Qingyi** is a Claude Code plugin (v2.3.0) that provides an enhanced `/init` command for project configuration, reusable skills, and Windows toast notifications. It creates CLAUDE.md and `.claude/rules/` files with intelligent gap analysis for existing projects.

**This is NOT a traditional software project** - there are no build/test commands. This is a plugin configuration project with a markdown-based command that Claude Code loads to assist with project setup.

**Plugin Marketplace**: [.claude-plugin/marketplace.json](.claude-plugin/marketplace.json)

## Project Structure

```
Qingyi/                                    ← Plugin root
├── .claude-plugin/
│   ├── marketplace.json                   ← Plugin marketplace definition
│   └── plugin.json                        ← Plugin manifest (commands, hooks)
├── commands/
│   └── project-init.md                    ← /init command (~200 lines)
├── hooks/                                 ← Event hook scripts
│   ├── hooks.json                         ← Hook definitions (Stop, PermissionRequest)
│   ├── notify.ps1                         ← Reusable toast notification script
│   ├── Qingyi02.png                       ← Toast notification icon
│   ├── on-stop.ps1                        ← Stop event handler
│   └── on-permission.ps1                  ← PermissionRequest event handler
├── templates/                             ← External template files
│   ├── CLAUDE.md
│   ├── architecture.md
│   ├── code-guide.md
│   └── documentation-style.md
├── skills/                                ← Auto-discovered skills
│   ├── commit/SKILL.md                   ← Conventional commit + push
│   ├── debug-code/SKILL.md               ← Debugging workflow
│   ├── excel-edit/SKILL.md               ← Excel write/format/style
│   ├── excel-read/SKILL.md               ← Excel read/analyze/extract
│   ├── sentry-deploy/SKILL.md            ← Sentry deployment
│   └── trim-project-instructions/SKILL.md ← Instruction file audit
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
3. **.claude/rules/code-guide.md** - Naming, patterns, code style, best practices
4. **.claude/rules/documentation-style.md** - Comment standards, doc patterns
5. **Commit skill** - Conventional commits + push (auto-triggered, not a slash command)

### Two Modes

| Mode | Trigger | Behavior |
|------|---------|----------|
| **CREATE** | No CLAUDE.md exists | Generate all 5 files from templates |
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

1. Edit `commands/project-init.md`
2. Re-run installation script to update plugin cache
3. Restart Claude Code
4. Test with `/init` in a project directory

## Template Reference

Templates are stored in `templates/` and loaded at runtime using `${CLAUDE_PLUGIN_ROOT}`:

| Template | Purpose |
|----------|---------|
| `CLAUDE.md` | Project overview with placeholders |
| `architecture.md` | System design template |
| `code-guide.md` | Naming, patterns, code style |
| `documentation-style.md` | Comment standards |

Build file → project type mapping relies on Claude's built-in knowledge (no external reference needed).

## Windows Toast Notifications

The plugin includes Windows toast notification hooks that alert you when Claude Code needs attention.

### Supported Events

| Event | Trigger | Notification |
|-------|---------|--------------|
| **Stop** | Claude finishes work | "Work completed -- check Claude Code" |
| **PermissionRequest** | Permission dialog shown | "Permission needed for {tool} -- check Claude Code" |

### How It Works

1. **`hooks.json`** — Registers `Stop` and `PermissionRequest` event handlers
2. **`on-stop.ps1`** / **`on-permission.ps1`** — Read stdin JSON from Claude, extract event data
3. **`notify.ps1`** — Reusable script that displays a Windows toast using the WinRT `ToastNotificationManager` API

### Requirements

- Windows 10 or 11
- PowerShell 5.1+ (built-in)
- No external modules or dependencies needed

### Testing Manually

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "hooks/notify.ps1" -Title "Test" -Message "Hello from Qingyi"
```

## Quick Reference

**Last Synced Commit**: `5ebe3f5` (2025-01-12)
