---
name: mod-review
description: Comprehensive code review with security and performance analysis
aliases:
  - mrev
---

Perform a comprehensive code review on the specified code.

**Instructions for the AI**:

1. **Detect project context**:
   - Check for Minecraft mod indicators (build.gradle, mods.toml, fabric.mod.json)
   - If Minecraft mod detected, apply Minecraft-specific checks
   - Otherwise, apply general Java/code review patterns

2. **Perform systematic review**:
   - Static analysis (structure, naming, complexity)
   - Security analysis (OWASP Top 10)
   - Performance analysis (algorithms, resources, caching)
   - Minecraft-specific (if applicable): client/server, registry, events

3. **Generate comprehensive report**:
   - Summary with overall score
   - Critical issues (must fix)
   - Warnings (should fix)
   - Suggestions (nice to have)
   - Educational explanations

4. **Prioritize by severity**:
   - CRITICAL: Security vulnerabilities, crash bugs
   - HIGH: Significant bugs, performance issues
   - MEDIUM: Code smells, maintainability
   - LOW: Style issues, minor improvements

Use the `code-reviewer` agent to perform this task.

**Expected Output**: Detailed review report with:
- Severity-prioritized issues
- Code examples showing problems and fixes
- Educational explanations
- Security and performance checklists
- Actionable recommendations

**Usage Examples**:
- `/mod-review src/main/java/com/mod/EventHandler.java`
- `/mod-review this file for security`
- `/mod-review the entire init package`
