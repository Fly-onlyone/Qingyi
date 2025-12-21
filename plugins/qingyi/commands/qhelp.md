---
description: Show Qingyi plugin help and available agents/skills
---

Display comprehensive help for the Qingyi Minecraft mod development plugin.

# Qingyi Plugin Help

## Overview

Qingyi is a specialized Claude Code plugin for Minecraft mod development with intelligent agents and framework-specific skills.

**Version**: 1.3.2
**Location**: C:\Users\PC\Documents\Minecraft\My Project\Qingyi
**Architecture**: Direct delegation to specialist agents (skill-based routing)

## How It Works

1. **You invoke**: `/qingyi <task>` or `/q <task>`
2. **Auto-detection**: Detect project and framework from build files
3. **Task routing**: Use Task Routing table (CLAUDE.md) to select specialist
4. **Delegation**: Invoke specialist with structured context
5. **Execution**: Agent uses framework-specific skills
6. **Post-processing**: Validate, open files, present summary

The `agent-delegation` skill provides routing logic, delegation templates, and agent catalog.

## Available Specialist Agents

### 1. registry-and-content-expert
**Items, blocks, entities registration**
- DeferredRegister patterns (Forge/NeoForge)
- Registry.register patterns (Fabric)
- Item/Block/Entity properties and builders
- Creative tabs and item groups

**Skills**: forge-registry-api, neoforge-registry-api, fabric-registry-api

### 2. events-and-lifecycle-expert
**Event systems, tick handlers, mod lifecycle**
- Forge event bus (@SubscribeEvent, MOD vs FORGE bus)
- Fabric callbacks and hooks
- Mod initialization phases
- Tick handlers (client/server/world/entity)

**Skills**: forge-event-system, fabric-event-system

### 3. data-and-persistence-expert
**NBT, capabilities, SavedData, data generation**
- NBT serialization/deserialization (CompoundTag, ListTag)
- Forge capability system (ICapabilityProvider)
- Fabric persistent state (PersistentState)
- SavedData for world-level persistence
- Data generation (recipes, loot tables, tags)

**Skills**: nbt-serialization-patterns, forge-capabilities, data-generation-guide

### 4. rendering-and-client-expert
**GUI, rendering, audio, client-side code**
- Boss bars (BossEvent, ServerBossEvent)
- Custom screens and overlays
- Toast notifications
- Sound systems (including OpenAL for custom audio)
- Advancement UI customization
- Client-only code separation (@OnlyIn)

**Skills**: rendering-patterns, gui-development, sound-system-api

### 5. intellij-code-navigator
**Code search, pattern discovery, semantic navigation**
- Finding existing implementations ("where is X?")
- Discovering registry entries
- Locating event handlers
- Symbol lookup and analysis

**Skills**: intellij-navigation-patterns

### 6. minecraft-code-validator
**Code validation, IntelliJ inspections, auto-fixing**
- Detect errors and warnings
- Auto-fix common issues (imports, annotations)
- Validate registry patterns, event handlers

**Skills**: intellij-inspection-guide, forge-event-system, forge-registry-api

### 7. intellij-refactoring-master
**Safe refactoring, symbol renaming**
- Rename items, blocks, entities (scope-aware)
- Resource file synchronization
- Breaking change detection

**Skills**: intellij-refactoring-safety, forge-registry-api

### 8. intellij-project-analyzer
**Project structure analysis**
- Detect multi-loader projects
- Analyze module architecture
- Understand dependencies

**Skills**: multi-loader-project-patterns, pattern-recognition

### 9. intellij-build-and-test-runner
**Build, test, and execution**
- Run Minecraft client/server
- Execute tests and verify mod loading
- Monitor console for errors

**Skills**: minecraft-run-configuration-guide

### 10. minecraft-docs-architect
**Comprehensive documentation generation**
- API reference documentation (10-100+ pages)
- Architecture guides
- Registry/event handler docs

**Skills**: minecraft-documentation-patterns

### 11. minecraft-tutorial-engineer
**Educational content creation**
- Step-by-step tutorials
- Onboarding guides
- Progressive difficulty learning paths

**Skills**: minecraft-tutorial-patterns

### 12. brave-search-agent
**Web research, documentation lookup**
- Find official documentation
- Discover migration guides
- Research API changes

**Skills**: pattern-recognition

### 13. github-code-search-agent
**GitHub code search, community patterns**
- Find real-world mod examples
- Discover framework implementations
- Locate migration PRs

**Skills**: pattern-recognition

### 14. code-reviewer (qingyi-code-review plugin)
**Security and performance review**
- OWASP Top 10 security analysis
- Performance optimization
- Architecture review

**Skills**: java-security-patterns, minecraft-code-review-patterns

### 15. legacy-modernizer (qingyi-modernizer plugin)
**Framework migration, version upgrades**
- Forge → NeoForge migration
- Minecraft version upgrades (1.20 → 1.21)
- Gradle build system updates

**Skills**: gradle-migration-patterns, mod-migration-guide

### 16. qingyi-plugin-manager
**Qingyi plugin development**
- Creating new agents/skills
- Updating CLAUDE.md
- Plugin maintenance

**Skills**: agent-creation-guide, pattern-recognition

## Available Skills

**Framework-Specific Skills**:
- **forge-registry-api** - Forge registration patterns
- **neoforge-registry-api** - NeoForge registration + migration
- **fabric-registry-api** - Fabric Registry.register patterns
- **forge-event-system** - Forge event bus patterns
- **fabric-event-system** - Fabric callbacks and hooks
- **nbt-serialization-patterns** - NBT handling
- **rendering-patterns** - Client-side rendering, GUI, boss bars
- **gui-development** - Custom screens and UI
- **sound-system-api** - OpenAL audio playback

**Architecture Skills**:
- **multi-loader-project-patterns** - Common/platform module architecture
- **mod-lifecycle-patterns** - Mod initialization phases
- **forge-capabilities** - Capability system
- **data-generation-guide** - Datagen for recipes, loot tables

**IntelliJ Integration Skills**:
- **intellij-navigation-patterns** - Semantic code search
- **intellij-refactoring-safety** - Safe refactoring patterns
- **intellij-inspection-guide** - IntelliJ inspection catalog
- **minecraft-run-configuration-guide** - runClient, runServer, runData

**Plugin Development Skills**:
- **agent-creation-guide** - Creating new agents/skills
- **pattern-recognition** - Identifying reusable patterns
- **code-summarizer** - Token-efficient code analysis
- **agent-delegation** - Task routing and delegation patterns (NEW)

## Framework Support

- ✅ **Forge** (1.19.x - 1.20.x)
- ✅ **NeoForge** (1.20.x - 1.21.x)
- ✅ **Fabric** (1.19.x - 1.21.x)
- ⚠️ **Quilt** - Limited support (similar to Fabric)

The system auto-detects your framework and uses appropriate patterns!

## Usage Examples

### Basic Commands

```
/qingyi add a new enchanted sword item to my mod
/qingyi create a boss bar countdown system
/qingyi help me fix NBT serialization in my capability
/qingyi register a new entity type with custom AI
```

### Using Short Alias

```
/q add a music disc item
/q fix the boss bar rendering
/q create a custom screen
```

### Direct Agent Invocation

You can also invoke agents directly:

```
Use the registry-and-content-expert agent to create a custom sword.

Context:
- Project: MusicMod
- Framework: Forge 1.20.1
- Files: ModItems.java
- Background: Uses DeferredRegister pattern

Expected: RegistryObject entry, model JSON, translation
```

## Task Routing Quick Reference

| Task Type | Specialist Agent |
|-----------|------------------|
| Items, blocks, entities | registry-and-content-expert |
| Events, tick handlers | events-and-lifecycle-expert |
| NBT, capabilities, persistence | data-and-persistence-expert |
| GUI, rendering, audio | rendering-and-client-expert |
| Code search | intellij-code-navigator |
| Code validation | minecraft-code-validator |
| Refactoring | intellij-refactoring-master |
| Documentation | minecraft-docs-architect |

For complete routing table, see CLAUDE.md Task Routing section.

## Getting Started

1. Navigate to your Minecraft mod project directory
2. Type `/qingyi` or `/q` followed by your task
3. System auto-detects project/framework
4. Routes to appropriate specialist agent
5. Get accurate, framework-specific implementation

## Plugin Structure

```
Qingyi/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── qingyi/
│   │   ├── commands/
│   │   │   ├── qingyi.md  (main command)
│   │   │   ├── q.md       (short alias)
│   │   │   └── qhelp.md   (this help)
│   │   ├── agents/
│   │   │   ├── registry-and-content-expert.md
│   │   │   ├── events-and-lifecycle-expert.md
│   │   │   ├── data-and-persistence-expert.md
│   │   │   ├── rendering-and-client-expert.md
│   │   │   ├── intellij-code-navigator.md
│   │   │   ├── minecraft-code-validator.md
│   │   │   ├── intellij-refactoring-master.md
│   │   │   ├── intellij-project-analyzer.md
│   │   │   ├── intellij-build-and-test-runner.md
│   │   │   ├── minecraft-docs-architect.md
│   │   │   ├── minecraft-tutorial-engineer.md
│   │   │   ├── brave-search-agent.md
│   │   │   ├── github-code-search-agent.md
│   │   │   └── qingyi-plugin-manager.md
│   │   └── skills/
│   │       ├── agent-delegation/         (NEW)
│   │       ├── forge-registry-api/
│   │       ├── neoforge-registry-api/
│   │       ├── fabric-registry-api/
│   │       ├── forge-event-system/
│   │       ├── fabric-event-system/
│   │       ├── nbt-serialization-patterns/
│   │       ├── rendering-patterns/
│   │       ├── ... (23 skills total)
│   ├── qingyi-code-review/
│   └── qingyi-modernizer/
```

## Command Reference

| Command | Purpose |
|---------|---------|
| `/qingyi <task>` | Main command - delegate to specialists |
| `/q <task>` | Quick alias - same as /qingyi |
| `/qhelp` | Show this help |

## New in v1.3.2

- ✨ **Direct delegation** - No orchestrator middleman
- ✨ **agent-delegation skill** - Routing patterns and agent catalog
- ✨ **Task Routing in CLAUDE.md** - Always-available quick reference
- ✅ Removed orchestrator agent (simplified architecture)
- ✅ More efficient token usage

**Need more details?** Check CLAUDE.md for Task Routing table and delegation patterns, or browse the agents/ and skills/ directories.
