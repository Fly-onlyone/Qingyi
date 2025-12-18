# Changelog

All notable changes to the Qingyi Code Review plugin will be documented in this file.

## [1.0.0] - 2024-12-18

### Added
- Initial release
- **code-reviewer** agent with:
  - OWASP Top 10 security analysis
  - Performance analysis (algorithms, resources, caching, concurrency)
  - Minecraft mod context auto-detection
  - Minecraft-specific checks (client/server, registry, events, NBT)
  - Educational explanations for all issues
- **minecraft-code-review-patterns** skill:
  - Code review checklists for Minecraft mods
  - Registry validation patterns
  - Event handler safety checks
  - Supporting files: security-vulnerabilities.md, performance-antipatterns.md
- **java-security-patterns** skill:
  - OWASP Top 10 patterns
  - Input validation guidelines
  - Cryptographic best practices
- `/mod-review` command for quick code review invocation

### Features
- Severity classification (CRITICAL, HIGH, MEDIUM, LOW, INFO)
- Structured review reports with actionable fixes
- Integration guidance with minecraft-code-validator
- Auto-context detection for Forge/NeoForge/Fabric mods
