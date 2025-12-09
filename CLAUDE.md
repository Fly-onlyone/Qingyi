# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Qingyi** is a Claude Code plugin (v1.1.0) that provides specialized AI agents and reusable skills for Minecraft mod development. It supports Forge, NeoForge, Fabric, and Quilt frameworks.

**This is NOT a traditional software project** - there are no build/test commands. This is a plugin configuration project with markdown-based agents and skills that Claude Code loads to assist with Minecraft modding.

**Plugin Manifest**: [.claude-plugin/plugin.json](.claude-plugin/plugin.json)

## Plugin Architecture

The plugin uses a **Master Orchestrator + Specialist Agents + Progressive Skills** architecture:

- **Agents** (6 implemented): Specialized AI assistants with isolated contexts for specific domains
- **Skills** (8 implemented): Reusable knowledge modules that auto-load based on relevance
- **Commands**: Slash command templates for quick workflows
- **Hooks**: Event automation for validation and assistance

## Development Workflow

### Creating New Agents

Create a new markdown file in `agents/` with this structure:

```markdown
---
name: agent-name
description: Expert in [domain]. Use PROACTIVELY for [tasks]
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
permissionMode: acceptEdits
skills: skill1, skill2
---

# Agent Name - Title

You are [role description]

## Core Responsibilities
[What this agent does]

## Behavioral Guidelines
[How it should behave]
```

**Required YAML Frontmatter**:
- `name`: kebab-case identifier
- `description`: Clear description. Include "Use PROACTIVELY" for auto-invocation
- `tools`: Comma-separated list of allowed tools
- `model`: sonnet, opus, haiku, or inherit
- `permissionMode`: default, acceptEdits, bypassPermissions, or plan
- `skills`: Pre-loaded skills (optional)

**Testing**: Restart Claude Code, then invoke with "Use the [agent-name] agent to [task]"

### Creating New Skills

Create a directory in `skills/skill-name/` with this structure:

```
skills/
└── skill-name/
    ├── SKILL.md          # Main entry point (required)
    ├── supporting-1.md   # Optional supporting files
    └── supporting-2.md   # Loaded on-demand
```

**SKILL.md frontmatter**:
```yaml
---
name: skill-name
description: What this skill provides. Include keywords for auto-matching.
allowed-tools: Read, Grep, Glob  # Optional
---
```

**Progressive Loading Pattern**:
- Keep SKILL.md concise (~200 lines)
- Reference supporting files with markdown links: `[detailed guide](./supporting-1.md)`
- Claude loads supporting files only when needed (token efficiency)

**Testing**: Check that Claude loads the skill when working on related tasks

### Updating Documentation

When adding agents/skills:
1. Update `docs/AGENTS.md` or `docs/SKILLS.md`
2. Add examples to `examples/`
3. Update `CHANGELOG.md`
4. Consider if README.md needs updating

## Key Architectural Patterns

### Pattern 1: Master Orchestrator with Auto-Detection

**Agent**: [agents/qingyi-orchestrator.md](agents/qingyi-orchestrator.md)

The orchestrator is the entry point for all tasks. It:

1. **Auto-detects project context** by reading:
   - `build.gradle` → Framework type (ForgeGradle, Loom, NeoGradle)
   - `gradle.properties` → Version numbers (minecraft_version, forge_version, etc.)
   - `mods.toml` → Forge/NeoForge indicator
   - `fabric.mod.json` → Fabric indicator

2. **Clarifies requirements** - Only asks what it cannot detect

3. **Creates task breakdown plan** - Phased implementation plans

4. **Selects specialist agents** based on delegation guide:
   - Registry/content → `registry-and-content-expert`
   - Events/lifecycle → `events-and-lifecycle-expert`
   - NBT/persistence → `data-and-persistence-expert`
   - GUI/rendering/audio → `rendering-and-client-expert`

5. **Delegates with context** - Provides detailed background to specialists

6. **Aggregates results** - Combines outputs from multiple agents

7. **Learns and improves** - Proposes new skills/agents from project analysis

**Key Innovation**: The orchestrator doesn't just delegate - it continuously improves the plugin by recognizing patterns across projects and proposing new components.

### Pattern 2: Agent Isolation & Framework Awareness

Each agent runs in an **isolated context** with:
- Fresh context (no conversation history from main session)
- Restricted tools (only what's needed for their domain)
- Pre-loaded skills (framework-specific knowledge)

**Framework Detection**: Agents automatically detect which framework is being used and apply correct patterns:

```java
// Forge/NeoForge pattern
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

// Fabric pattern
public static final Item CUSTOM_ITEM = Registry.register(
    Registries.ITEM, new Identifier(MODID, name), item);
```

The same agent handles both - it detects from context which to use.

**Real Code Examples**: Agents reference actual code from:
- **MusicMod** (Forge 1.20.1): Audio playback, advancement UI, progress tracking
- **Apocalypse_TNT** (NeoForge): Entity spawning, boss bars, countdown logic

### Pattern 3: Progressive Skill Loading

**Token Optimization Strategy**:

1. **Main SKILL.md** (~200 lines):
   - Overview of the domain
   - Basic patterns and examples
   - Links to supporting files

2. **Supporting Files** (loaded on-demand):
   - Detailed guides
   - Advanced patterns
   - Anti-patterns and troubleshooting

**Example**: [skills/forge-event-system/SKILL.md](skills/forge-event-system/SKILL.md)
- Main file: Event bus overview, basic handler registration
- Supporting: Event priorities, tick handlers, common events

This prevents token waste - only load what's needed for the current task.

### Pattern 4: Self-Evolution System

The orchestrator has a **learning mechanism** (lines 173-221 in [agents/qingyi-orchestrator.md](agents/qingyi-orchestrator.md)):

**Workflow**:
1. **Analyze Current Project** → Scan structure, identify patterns
2. **Identify Opportunities** → Compare with existing agents/skills
3. **Propose to User** → "Found pattern X, should I document it?"
4. **Create Component** → Add skill/agent if approved
5. **Update CLAUDE.md** → Document for reuse (only if approved)

**Pattern Recognition Rules**:
- ✅ DO compare projects with same topic (MusicMod: TheFatRat vs MusicMod: NCS)
- ❌ DON'T compare projects with different topics (MusicMod vs Apocalypse_TNT)

**CLAUDE.md Entry Format** (proposed by orchestrator):
```markdown
### Convention: [Pattern Name]
**Learned**: [Date]
**Source Project**: [ProjectName]
**Framework**: [Forge 1.20.1/etc.]

**When to Apply**:
- Use case 1
- Use case 2

**Code Example**:
[Real code from user's project]

**Anti-Patterns to Avoid**:
- ❌ Anti-pattern 1
```

## Agent Selection Guide

### For Minecraft Mod Development

When working with Minecraft mods, use these agents:

| Task Domain | Agent | Tools | Skills Loaded |
|------------|-------|-------|---------------|
| Task planning & delegation | `qingyi-orchestrator` | All | pattern-recognition, agent-creation-guide, code-summarizer |
| Items, blocks, entities | `registry-and-content-expert` | Read, Write, Edit, Bash, Grep, Glob | forge-registry-api, neoforge-registry-api |
| Events, tick handlers | `events-and-lifecycle-expert` | Read, Write, Edit, Bash, Grep, Glob | forge-event-system |
| NBT, capabilities, persistence | `data-and-persistence-expert` | Read, Write, Edit, Bash, Grep, Glob | nbt-serialization-patterns |
| GUI, rendering, audio | `rendering-and-client-expert` | Read, Write, Edit, Bash, Grep, Glob | rendering-patterns |

### For Qingyi Plugin Development

When working on the Qingyi plugin itself, use:

| Task Domain | Agent | Tools | Skills Loaded |
|------------|-------|-------|---------------|
| Plugin development & maintenance | `qingyi-plugin-manager` | Read, Write, Edit, Grep, Glob, Bash | agent-creation-guide, pattern-recognition |

**Use this agent for**:
- Updating CLAUDE.md
- Creating or modifying agents and skills
- Maintaining documentation consistency
- Validating YAML frontmatter
- Checking cross-references
- Quality assurance

**Auto-Invocation**: Agents with "Use PROACTIVELY" in their description are automatically invoked when relevant. The orchestrator is invoked for Minecraft mod tasks, while the plugin-manager is invoked for plugin development tasks.

## Critical Conventions

### Naming Conventions
- **Agents**: `kebab-case.md` (e.g., `qingyi-orchestrator.md`)
- **Skills**: `kebab-case/SKILL.md` (e.g., `forge-event-system/SKILL.md`)
- **Projects**: `ProjectName: Variant` (e.g., `MusicMod: TheFatRat`, `Apocalypse_TNT`)

### YAML Frontmatter Structure

**Agents**:
```yaml
name: kebab-case           # Required
description: "..."         # Required, include "Use PROACTIVELY" for auto-invoke
tools: Read, Write, Edit   # Required, comma-separated
model: sonnet              # Required: sonnet, opus, haiku, inherit
permissionMode: default    # Required: default, acceptEdits, bypassPermissions, plan
skills: skill1, skill2     # Optional, comma-separated
```

**Skills**:
```yaml
name: kebab-case           # Required
description: "..."         # Required, include keywords for matching
allowed-tools: Read, Grep  # Optional, defaults to all tools
```

### Auto-Invocation Keyword

Include `"Use PROACTIVELY"` in agent descriptions to enable automatic invocation:

```yaml
description: Expert in events. Use PROACTIVELY for event handlers, tick systems.
```

### Framework-Specific Patterns

When documenting code, always specify the framework:

```markdown
**Forge 1.20.1**:
[code example]

**Fabric 1.20.x**:
[code example]
```

## Framework Support

**Supported Frameworks**:
- **Forge**: 1.19.x, 1.20.x
- **NeoForge**: 1.20.x, 1.21.x
- **Fabric**: 1.19.x, 1.20.x, 1.21.x
- **Quilt**: 1.19.x, 1.20.x

**Detection Files**:
- Forge/NeoForge: `mods.toml`, `ForgeGradle` in build.gradle
- Fabric: `fabric.mod.json`, `Loom` in build.gradle
- Quilt: Similar to Fabric with Quilt-specific metadata

**Version Detection**:
```properties
# gradle.properties
minecraft_version=1.20.1
forge_version=47.1.0
neo_version=1.21.3
```

## Real Project Integration

Agents contain **real code examples** from actual projects:

- **MusicMod** (Forge 1.20.1):
  - OpenAL audio playback with seeking
  - Custom advancement UI screens
  - O(1) progress tracking with HashMap
  - Client tick handlers for audio control

- **Apocalypse_TNT** (NeoForge):
  - Custom entity registration and spawning
  - Boss bar creation and management
  - Server tick handlers for countdown logic
  - SavedData for world state persistence

These provide accurate, tested patterns rather than pseudocode.

## Architecture References

For deeper understanding, read:
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - Component design and data flow
- [docs/AGENTS.md](docs/AGENTS.md) - Comprehensive agent creation guide
- [docs/SKILLS.md](docs/SKILLS.md) - Skill creation and best practices
- [agents/qingyi-orchestrator.md](agents/qingyi-orchestrator.md) - Master orchestrator implementation
