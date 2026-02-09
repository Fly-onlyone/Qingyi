# CLAUDE.md

This file provides guidance to Claude Code when working with this project.

## Build Commands

| Task | Command |
|------|---------|
| Install dependencies | `{{install_command}}` |
| Build | `{{build_command}}` |
| Test | `{{test_command}}` |
| Lint | `{{lint_command}}` |
| Run dev server | `{{dev_command}}` |

## Project Overview

**{{project_name}}** is a {{project_type}} project.

- **Language**: {{language}} {{version}}
- **Framework**: {{framework}} {{framework_version}}
- **Package Manager**: {{package_manager}}

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `{{dep_name}}` | {{dep_purpose}} |

## Project Rules

See `.claude/rules/` for detailed conventions:
- [Code Guide](/.claude/rules/code-guide.md) - Naming, patterns, package structure, code style
- [Architecture](/.claude/rules/architecture.md) - System design and data flow
- [Documentation](/.claude/rules/documentation-style.md) - Comment standards

## Commands

- [Commit](/.claude/commands/commit.md) - Use `/commit` for conventional commits + push

## Quick Reference

**Last Synced Commit**: `{{commit_hash}}` ({{sync_date}})

<!-- TODO: Add project-specific quick reference items -->
