---
description: Quick alias for Qingyi plugin (usage: /q <task>)
---

For Minecraft mod development: {0}

Use the Task Routing guide in CLAUDE.md to delegate directly to specialist agents based on task type.

**How delegation works**:
1. Auto-detect project and framework from build files
2. Identify task domain (items, events, NBT, GUI, etc.)
3. Route to appropriate specialist agent using delegation pattern
4. Follow post-delegation workflow (validate, open files, report)

The `agent-delegation` skill provides detailed patterns and agent catalog when needed.

If no task provided, remind user: Use `/qhelp` to see available agents and examples.
