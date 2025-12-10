# Comprehensive Skill Creation Guide

Complete guide for creating skills in the Qingyi Minecraft Development Plugin.

## Overview

Skills are model-invoked knowledge modules that Claude loads automatically when relevant to the current task.

## Key Concepts

### Skills vs Agents

- **Skills**: Knowledge modules (passive, loaded when needed)
- **Agents**: Task executors (active, delegated for workflows)

Use skills for reference information, use agents for execution.

## File Structure

```
skills/
└── skill-name/
    ├── SKILL.md                 # Required main file
    ├── reference.md             # Optional supporting files
    ├── examples/
    │   └── example.java
    └── templates/
        └── template.java
```

## SKILL.md Format

```yaml
---
name: skill-name
description: What, when, why to use this skill. Include trigger keywords.
allowed-tools: Read, Grep, Glob  # Optional
---

# Skill Display Name

## What This Covers

Brief overview...

## When to Use

Specific scenarios...

## Core Knowledge

Main content...

## See Also

[Reference docs](reference.md)
[Examples](examples/)
```

## Writing Descriptions

Include:
- **Domain keywords** (minecraft, forge, registry, items)
- **Action verbs** (implement, create, configure)
- **Use cases** (when implementing X, when working with Y)

**Example**:
```yaml
description: Implement Minecraft items, blocks, and entities using registry systems. Use when creating custom content, registering game objects, or implementing item/block behavior. Covers Forge DeferredRegister, Fabric Registry, and Quilt registries.
```

## Progressive Disclosure

Keep SKILL.md concise, use supporting files for details:

**SKILL.md**:
```markdown
## Registry System

Minecraft uses registries to track all game content.

For detailed information:
- [Forge Registries](forge-registries.md)
- [Fabric Registries](fabric-registries.md)
- [Examples](examples/registry-example.java)
```

Claude loads supporting files only when needed.

## Best Practices

1. **Specific names**: `minecraft-api-reference` not `minecraft-help`
2. **Rich descriptions**: Include many relevant keywords
3. **Organized content**: Use headers and lists
4. **Real examples**: Show actual code, not pseudocode
5. **Version awareness**: Separate content by MC version if needed

## Testing

Test by asking questions that should load the skill:

```
"How do I create a custom item in Forge?"
→ Should load minecraft-api skill
```

## Implemented Skills

The Qingyi plugin currently includes these production-ready skills:

1. **agent-creation-guide** ([skills/agent-creation-guide/](../skills/agent-creation-guide/))
   - Templates and guidelines for creating new agents and skills
   - Used by: qingyi-plugin-manager, qingyi-orchestrator

2. **code-summarizer** ([skills/code-summarizer/](../skills/code-summarizer/))
   - Token-efficient code analysis tool for large Java files
   - Used by: qingyi-orchestrator, all specialist agents

3. **forge-event-system** ([skills/forge-event-system/](../skills/forge-event-system/))
   - Event bus, @SubscribeEvent, MOD vs FORGE bus, tick handlers
   - Used by: events-and-lifecycle-expert, minecraft-code-validator

4. **forge-registry-api** ([skills/forge-registry-api/](../skills/forge-registry-api/))
   - DeferredRegister, RegistryObject, item/block/entity registration
   - Used by: registry-and-content-expert, minecraft-code-validator

5. **nbt-serialization-patterns** ([skills/nbt-serialization-patterns/](../skills/nbt-serialization-patterns/))
   - NBT serialization for SavedData, capabilities, entities, items
   - Used by: data-and-persistence-expert, minecraft-code-validator

6. **neoforge-registry-api** ([skills/neoforge-registry-api/](../skills/neoforge-registry-api/))
   - NeoForge-specific registry patterns, migration from Forge
   - Used by: registry-and-content-expert, minecraft-code-validator

7. **pattern-recognition** ([skills/pattern-recognition/](../skills/pattern-recognition/))
   - Identify reusable code patterns, architectural designs, best practices
   - Used by: qingyi-orchestrator, qingyi-plugin-manager

8. **rendering-patterns** ([skills/rendering-patterns/](../skills/rendering-patterns/))
   - Boss bars, toasts, custom screens, HUD overlays, GuiGraphics API
   - Used by: rendering-and-client-expert

9. **intellij-inspection-guide** ([skills/intellij-inspection-guide/](../skills/intellij-inspection-guide/))
   - Catalog of IntelliJ inspections relevant to Minecraft modding
   - Interpretation of get_file_problems output and fix strategies
   - Covers event handlers, registry, client/server safety, NBT, resources
   - Used by: minecraft-code-validator

10. **intellij-navigation-patterns** ([skills/intellij-navigation-patterns/](../skills/intellij-navigation-patterns/))
    - Effective use of IntelliJ MCP navigation tools for Minecraft mods
    - Tool selection guide, performance optimization strategies
    - Minecraft-specific search patterns (registry discovery, event handlers, resource mapping)
    - Supporting files: registry-discovery.md, event-handler-search.md, resource-file-mapping.md
    - Used by: intellij-code-navigator, all specialist agents

11. **intellij-refactoring-safety** ([skills/intellij-refactoring-safety/](../skills/intellij-refactoring-safety/))
    - Best practices for safe refactoring in Minecraft mods
    - Scope-aware renaming vs text replacement (rename_refactoring vs replace_text_in_file)
    - Resource file synchronization workflows (models, textures, lang, recipes, loot tables)
    - World compatibility and breaking change detection
    - Supporting files: registry-name-changes.md, resource-sync-patterns.md, breaking-changes-guide.md
    - Used by: intellij-refactoring-master

12. **multi-loader-project-patterns** ([skills/multi-loader-project-patterns/](../skills/multi-loader-project-patterns/))
    - Multi-loader Minecraft mod architecture (Common/Forge/Fabric/Quilt)
    - Module organization and platform abstraction patterns
    - ServiceLoader and @ExpectPlatform usage for platform-specific APIs
    - Gradle configuration for multi-module projects
    - Supporting files: module-structure.md, platform-abstraction.md, gradle-configuration.md
    - Used by: intellij-project-analyzer

13. **minecraft-run-configuration-guide** ([skills/minecraft-run-configuration-guide/](../skills/minecraft-run-configuration-guide/))
    - IntelliJ run configurations for Minecraft modding
    - runClient, runServer, runData execution and customization
    - Program arguments and JVM options reference
    - Data generation workflows and providers
    - Supporting files: run-client-server.md, data-generation.md, custom-configurations.md
    - Used by: intellij-build-and-test-runner

## See Also

- [skills/README.md](../skills/README.md)
- [examples/example-skill/](../examples/example-skill/)
