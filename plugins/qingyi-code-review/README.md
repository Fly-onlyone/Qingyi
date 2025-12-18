# Qingyi Code Review

A Claude Code plugin providing AI-powered code review with security scanning, performance analysis, and Minecraft mod pattern validation.

## Overview

Qingyi Code Review is a companion plugin to the main [Qingyi](../qingyi/) Minecraft development plugin. It provides deep, educational code reviews with a focus on security (OWASP Top 10), performance optimization, and Minecraft-specific patterns.

## Features

### Code Review Agent
- **Security Analysis**: OWASP Top 10 vulnerability detection (injection, authentication, XSS, deserialization, etc.)
- **Performance Analysis**: Algorithm efficiency, resource management, caching opportunities, concurrency issues
- **Minecraft-Specific Checks** (auto-detected):
  - Client/Server separation validation (CRITICAL)
  - Registry pattern validation
  - Event handler safety
  - NBT security
- **Educational Approach**: Every issue includes explanations and learning resources

### Skills
- **minecraft-code-review-patterns**: Minecraft-specific code review checklists
- **java-security-patterns**: Java security best practices (OWASP Top 10)

### Commands
- `/mod-review` (`/mrev`): Comprehensive code review with severity-prioritized issues

## Installation

1. Clone or download this plugin to your Claude Code plugins directory
2. Restart Claude Code
3. The `code-reviewer` agent will be available

## Usage

### Direct Invocation
```
Use the code-reviewer agent to review this event handler for security and performance
```

### Slash Command
```
/mod-review src/main/java/com/mod/EventHandler.java
```

### Automatic Context Detection
The agent automatically detects Minecraft mod context and applies appropriate checks:
- Forge mods (build.gradle with ForgeGradle, mods.toml)
- NeoForge mods (build.gradle with NeoGradle, neoforge.mods.toml)
- Fabric mods (build.gradle with Loom, fabric.mod.json)

## Review Report Format

Reports include:
- **Summary**: Overall score (A-F), issue counts
- **Critical Issues**: Must fix (security vulnerabilities, crash bugs)
- **Warnings**: Should fix (significant bugs, performance issues)
- **Suggestions**: Nice to have (style, readability)
- **Checklists**: Security, Performance, Minecraft-specific

## Relationship with minecraft-code-validator

| Aspect | code-reviewer | minecraft-code-validator |
|--------|---------------|--------------------------|
| Focus | Deep analysis, education | Fast automated checks |
| Invocation | On-demand | Auto after code gen |
| Time | Minutes | Seconds |
| Learning | High (explanations) | Low (just fixes) |

Use **code-reviewer** for thorough reviews and learning.
Use **minecraft-code-validator** for quick validation during development.

## Requirements

- Claude Code 1.0.0+
- Optional: Qingyi plugin (for Minecraft-specific skills)

## License

MIT

## Related

- [Qingyi Plugin](../qingyi/) - Main Minecraft development plugin
- [Qingyi Modernizer](../qingyi-modernizer/) - Migration and modernization plugin
