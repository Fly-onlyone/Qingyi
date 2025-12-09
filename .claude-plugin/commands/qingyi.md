---
description: Minecraft mod development assistant (usage: /qingyi <task>)
---

Use the qingyi-orchestrator agent to help with Minecraft mod development.

Task request: {0}

The orchestrator will:
1. Auto-detect your current project and framework from build files
2. Clarify any requirements needed through targeted questions
3. Create a detailed task breakdown plan
4. Delegate to the appropriate specialized agents
5. Report results and update CLAUDE.md if new patterns are found

If no task is provided, show a brief usage guide with examples:

## Qingyi Plugin Usage

**Basic syntax**: `/qingyi <your task description>`

**Examples**:
- `/qingyi add a new enchanted sword item to my mod`
- `/qingyi create a boss bar countdown system`
- `/qingyi help me fix NBT serialization in my capability`
- `/qingyi register a new entity type`
- `/qingyi improve the plugin based on my current project`

**Quick alias**: Use `/q` for shorter commands
**Help**: Use `/qhelp` to see all available agents and skills

**Supported frameworks**:
- Forge (1.19.x - 1.20.x)
- NeoForge (1.20.x - 1.21.x)
- Fabric (1.19.x - 1.21.x) - Partial support

The orchestrator will auto-detect which framework you're using and provide the correct patterns!
