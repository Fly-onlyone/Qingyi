---
description: Show Qingyi plugin help and available agents/skills
---

Display comprehensive help for the Qingyi Minecraft mod development plugin.

# Qingyi Plugin Help

## Overview

Qingyi is a specialized Claude Code plugin for Minecraft mod development with intelligent agents and framework-specific skills.

**Version**: 1.3.2
**Location**: C:\Users\PC\Documents\Minecraft\My Project\Qingyi
**Supported Projects**: MusicMod1_TheFatRat, Apocalypse_TNT, and other Minecraft mods

## Available Agents

### 1. qingyi-orchestrator
**Master task manager and intelligent router**
- Auto-detects project context (project name, framework, version)
- Asks clarifying questions to understand requirements
- Creates detailed task breakdown plans
- Delegates to specialized agents
- Updates CLAUDE.md with learned patterns
- Self-improvement capability

### 2. registry-and-content-expert
**Items, blocks, entities registration**
- DeferredRegister patterns (Forge/NeoForge)
- Registry.register patterns (Fabric)
- Item/Block/Entity properties and builders
- Creative tabs and item groups
- Version-specific registration differences

**Skills**: forge-registry-api, neoforge-registry-api

### 3. events-and-lifecycle-expert
**Event systems, tick handlers, mod lifecycle**
- Forge event bus (@SubscribeEvent, MOD vs FORGE bus)
- Fabric callbacks and hooks
- Mod initialization phases
- Tick handlers (client/server/world/entity)
- Event priority and cancellation
- Client/server separation

**Skills**: forge-event-system

### 4. data-and-persistence-expert
**NBT, capabilities, SavedData, data generation**
- NBT serialization/deserialization (CompoundTag, ListTag)
- Forge capability system (ICapabilityProvider, AttachCapabilitiesEvent)
- Fabric persistent state (PersistentState)
- SavedData for world-level persistence
- Data generation (recipes, loot tables, tags)

**Skills**: nbt-serialization-patterns

### 5. rendering-and-client-expert
**GUI, rendering, audio, client-side code**
- Boss bars (BossEvent, ServerBossEvent)
- Custom screens and overlays
- Toast notifications
- Sound systems (including OpenAL for custom audio)
- Advancement UI customization
- Client-only code separation (@OnlyIn)

**Skills**: rendering-patterns

## Available Skills

**Framework-Specific Skills**:
- **forge-registry-api** - Forge registration patterns with real examples from MusicMod
- **neoforge-registry-api** - NeoForge registration + migration guide from Apocalypse_TNT
- **forge-event-system** - Event system patterns from both user mods
- **nbt-serialization-patterns** - NBT handling patterns
- **rendering-patterns** - Client-side rendering, GUI, boss bars, audio

**Helper Skills**:
- **pattern-recognition** - Identify reusable patterns across projects
- **agent-creation-guide** - Self-improvement system for creating new agents/skills
- **code-summarizer** - Token-efficient code analysis with JSON output

## Framework Support

- ✅ **Forge** (1.19.x - 1.20.x)
- ✅ **NeoForge** (1.20.x - 1.21.x)
- ✅ **Fabric** (1.19.x - 1.21.x) - Partial support
- ❌ **Quilt** - Not supported

The orchestrator auto-detects your framework and uses the appropriate skills!

## Usage Examples

### Basic Commands

```
/qingyi add a new enchanted sword item to my mod
/qingyi create a boss bar countdown system
/qingyi help me fix NBT serialization in my capability
/qingyi register a new entity type with custom AI
/qingyi improve the plugin based on my current project
```

### Using Short Alias

```
/q add a music disc item
/q fix the boss bar rendering
/q create a custom screen
```

### Self-Improvement

```
/qingyi improve the plugin based on my current project
```
This analyzes your current mod, identifies new patterns, and proposes creating new agents/skills.

## CLAUDE.md Learning System

The plugin automatically learns from your code:
- **MusicMod/CLAUDE.md** - Pre-seeded with 7 patterns (Singleton, OpenAL audio, custom UI, etc.)
- **Apocalypse_TNT/CLAUDE.md** - Pre-seeded with 7 patterns (Orchestrator, Boss bars, SavedData, etc.)

When orchestrator finds genuinely new patterns, it proposes updating CLAUDE.md with your approval.

## How It Works

1. **You invoke**: `/qingyi <task>` or `/q <task>`
2. **Auto-detection**: Orchestrator detects your project and framework from build files
3. **Clarification**: Asks targeted questions about details it can't determine
4. **Planning**: Creates a detailed task breakdown plan
5. **Delegation**: Routes to the appropriate specialized agent(s)
6. **Execution**: Agent uses framework-specific skills to complete the task
7. **Learning**: Updates CLAUDE.md if new patterns discovered

## Getting Started

1. Navigate to your Minecraft mod project directory
2. Type `/qingyi` or `/q` followed by what you want to do
3. Answer any clarifying questions
4. Review the task plan
5. Get accurate, framework-specific implementation

## Plugin Structure

```
Qingyi/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── qingyi/
│   │   ├── commands/
│   │   │   ├── qingyi.md  (this command)
│   │   │   ├── q.md       (short alias)
│   │   │   └── qhelp.md   (this help)
│   │   ├── agents/
│   │   │   ├── qingyi-orchestrator.md
│   │   │   ├── registry-and-content-expert.md
│   │   │   ├── events-and-lifecycle-expert.md
│   │   │   ├── data-and-persistence-expert.md
│   │   │   └── rendering-and-client-expert.md
│   │   └── skills/
│   │       ├── forge-registry-api/
│   │       ├── neoforge-registry-api/
│   │       ├── fabric-registry-api/
│   │       ├── forge-event-system/
│   │       ├── fabric-event-system/
│   │       ├── gui-development/
│   │       ├── sound-system-api/
│   │       ├── mod-lifecycle-patterns/
│   │       ├── forge-capabilities/
│   │       ├── data-generation-guide/
│   │       ├── nbt-serialization-patterns/
│   │       └── rendering-patterns/
│   ├── qingyi-code-review/
│   └── qingyi-modernizer/
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `/qingyi <task>` | Main command - invoke orchestrator with task |
| `/q <task>` | Quick alias - same as /qingyi |
| `/qhelp` | Show this help |

**Need more help?** Check the agents/ and skills/ directories in the plugin folder for detailed documentation.
