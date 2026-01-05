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

## Project Structure

```
{{project_root}}/
├── src/                    # Source code
├── tests/                  # Test files
├── docs/                   # Documentation
└── ...
```

## Project Rules

See `.claude/rules/` for detailed conventions:
- [Architecture](/.claude/rules/architecture.md) - System design and data flow
- [Commit Messages](/.claude/rules/commit-messages.md) - Git commit format
- [Conventions](/.claude/rules/conventions.md) - Naming and code style
- [Documentation](/.claude/rules/documentation-style.md) - Comment standards
- [Patterns](/.claude/rules/patterns.md) - Reusable code patterns

## Quick Reference

**Last Synced Commit**: `{{commit_hash}}` ({{sync_date}})

<!-- TODO: Add project-specific quick reference items -->
