---
description: Minecraft mod development assistant (usage: /qingyi <task>)
---

For Minecraft mod development: {0}

**Direct delegation workflow**:
1. **Auto-detect** project and framework from build files (gradle.properties, build.gradle, mods.toml)
2. **Identify task domain** based on request keywords
3. **Select specialist agent** using Task Routing table in CLAUDE.md
4. **Delegate with context**:
   ```
   Use the [agent-name] agent to [task].

   Context:
   - Project: [ProjectName]
   - Framework: [Forge/NeoForge/Fabric + version]
   - Files: [key files]
   - Background: [relevant context]

   Expected: [deliverables]
   ```
5. **Post-delegation**: Validate (if Java), open files, present summary

The `agent-delegation` skill provides detailed patterns, agent catalog, and error handling guidance.

---

If no task is provided, show usage guide:

## Qingyi Plugin Usage

**Basic syntax**: `/qingyi <task description>` or `/q <task>`

**Examples**:
- `/qingyi add a new enchanted sword item to my mod`
- `/qingyi create a boss bar countdown system`
- `/qingyi help me fix NBT serialization in my capability`
- `/qingyi register a new entity type`

**Supported frameworks**:
- Forge (1.19.x - 1.20.x)
- NeoForge (1.20.x - 1.21.x)
- Fabric (1.19.x - 1.21.x)

**Help**: Use `/qhelp` to see all available specialist agents

The system auto-detects your framework and delegates to the correct specialist with framework-specific patterns!
