# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Qingyi** is a Claude Code plugin that provides an enhanced `/qingyi:project-init` command for project configuration
and reusable skills. It creates CLAUDE.md and `.claude/rules/` files with intelligent gap
analysis for existing projects.

**This is NOT a traditional software project** - there are no build/test commands. This is a plugin configuration
project with a markdown-based command that Claude Code loads to assist with project setup.

**Plugin Marketplace**: [.claude-plugin/marketplace.json](.claude-plugin/marketplace.json)

The `/qingyi:project-init` behavior (CREATE/ENHANCED modes, gap analysis, project detection) lives in
[commands/project-init.md](commands/project-init.md). Install, update, and uninstall steps live in
[README.md](README.md#installation).

## Usage

After installation, start a new Claude Code session (or run `/reload-plugins` in an open one).
Plugin commands are namespaced under the plugin name, so the command is `/qingyi:project-init`, not `/init`.

## Development

### Testing Changes

1. Edit `commands/project-init.md`
2. In a project directory, start Claude Code with `claude --plugin-dir <path-to-Qingyi>` to load the working copy for one session
3. Test with `/qingyi:project-init`

To test the installed copy instead, run `claude plugin marketplace update qingyi` and
`claude plugin update qingyi@qingyi`, then start a new session.

## Plugin Settings

Settings are Claude Code plugin options, declared under `userConfig` in `.claude-plugin/plugin.json`. Users set them via
`/plugin` → Installed → qingyi → Configure options, `claude plugin install --config KEY=VALUE`, or
`pluginConfigs["qingyi@qingyi"].options` in `~/.claude/settings.json`. Project-level settings files are ignored for
plugin options, so there is no per-project override.

Skills read a value with `${user_config.KEY}`, which Claude Code substitutes into the skill content:

- A list option is substituted as a comma-separated string (`/a,/b`).
- An unset option stays as the literal `${user_config.KEY}` text, even when the manifest declares a `default`. Each
  skill therefore falls back to its default when the value is empty or still starts with `${`.

When adding an option, declare it in `plugin.json`, reference it in the skill, and add the same fallback.

## Quick Reference

**Last Synced Commit**: `5ebe3f5` (2025-01-12)
