# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Qingyi** is a Claude Code plugin (v2.0.0) that provides a comprehensive AI agent and 18 reusable skills for Minecraft mod development. It supports Forge, NeoForge, Fabric, and Quilt frameworks.

**This is NOT a traditional software project** - there are no build/test commands. This is a plugin configuration project with markdown-based agents and skills that Claude Code loads to assist with Minecraft modding.

**Plugin Marketplace**: [.claude-plugin/marketplace.json](.claude-plugin/marketplace.json)

## Project Structure

```
Qingyi/                                    ← Marketplace root
├── .claude-plugin/
│   └── marketplace.json                   ← Plugin marketplace definition
├── plugins/
│   └── qingyi/                           ← Minecraft modding plugin (1 agent, 3 commands)
│       ├── agents/
│       └── commands/
├── docs/
│   ├── agent-supporting/                 ← Supporting docs for specific agents
│   │   ├── brave-search-agent/
│   │   ├── github-code-search-agent/
│   │   ├── intellij-code-navigator/
│   │   └── ... (6 agent doc sets)
│   ├── AGENTS.md                         ← Agent creation guide
│   └── SKILLS.md                         ← Skill creation guide
├── scripts/
│   ├── install.bat                       ← Windows installation script
│   ├── install.sh                        ← Linux/macOS installation script
│   └── uninstall.bat                     ← Uninstall script
└── CLAUDE.md                             ← This file
```

**Key Design**: The plugin uses `"source": "./"` to copy the entire marketplace root (including `docs/`) to the plugin cache, ensuring agents can access supporting documentation.

## Plugin Architecture

The plugin uses a **Simplified Single-Agent Architecture with Context7 Integration**:

- **Agent** (`minecraft-modding-expert`): Comprehensive expert handling all Minecraft modding domains
- **Documentation**: Uses Context7 MCP for dynamic framework documentation (NeoForge, Forge, Fabric)
- **Commands** (`/qingyi`, `/q`): Quick access to the expert agent
- **Framework Support**: Forge 1.19-1.20, NeoForge 1.20-1.21, Fabric/Quilt 1.19-1.21

**Key Changes**:
- **v2.0.0**: Consolidated 14 specialist agents into 1 comprehensive agent
- **v2.1.0**: Removed 18 bundled skills in favor of Context7 dynamic documentation

## Development Workflow

### Creating New Agents

Create a new markdown file in `plugins/qingyi/agents/` with this structure:

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

Create a directory in `plugins/qingyi/skills/skill-name/` with this structure:

```
plugins/qingyi/skills/
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

## How to Use the Plugin

### Using the `/qingyi` or `/q` Command

Simply type `/qingyi <task>` or `/q <task>` with your Minecraft modding request:

```
/qingyi add a new sword item to my mod
/q create a boss bar countdown system
/qingyi implement NBT serialization for player data
/q add a custom GUI screen with buttons
```

The `minecraft-modding-expert` agent will:
1. **Auto-detect** your framework from build.gradle and gradle.properties
2. **Find existing patterns** in your codebase using IntelliJ semantic search
3. **Implement** the feature with correct framework-specific code
4. **Validate** all Java files for errors
5. **Open files** in your editor for review

### What the Agent Handles

The single comprehensive agent handles ALL modding domains:

**Registry**: Items, blocks, entities, creative tabs
**Events**: Tick handlers, player events, mod lifecycle
**NBT & Data**: SavedData, capabilities, persistence, CompoundTag
**GUI & Rendering**: Custom screens, boss bars, HUD overlays, rendering
**Audio**: Sound events, OpenAL custom audio playback
**Multi-Loader**: Common/platform module patterns
**Validation**: IntelliJ inspections for error detection

### Context7 Documentation Lookup

The agent uses Context7 MCP for real-time framework documentation:

- **NeoForge 1.21.1**: 7,735+ code snippets (Benchmark: 81.9)
- **Forge**: 792+ snippets per version (1.19-1.20)
- **Fabric**: 8,905+ snippets from official wiki
- **Architectury**: 828 snippets for multi-loader patterns

Context7 provides dynamic, up-to-date documentation without bundled skills, reducing maintenance and ensuring accuracy.

## Key Architectural Patterns

### Pattern 1: Auto-Detection and Framework Awareness

The agent automatically detects which framework is being used and applies correct patterns:

```java
// Forge/NeoForge pattern
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

// Fabric pattern
public static final Item CUSTOM_ITEM = Registry.register(
    Registries.ITEM, new Identifier(MODID, name), item);
```

Detection sources:
- `build.gradle` → Framework type (ForgeGradle, Loom, NeoGradle)
- `gradle.properties` → Version numbers (minecraft_version, forge_version, etc.)
- `mods.toml` → Forge/NeoForge indicator
- `fabric.mod.json` → Fabric indicator

**Real Code Examples**: The agent references actual code from:
- **MusicMod** (Forge 1.20.1): Audio playback, advancement UI, progress tracking
- **Apocalypse_TNT** (NeoForge): Entity spawning, boss bars, countdown logic

### Pattern 2: Context7 Integration

**Dynamic Documentation Strategy**:

The agent uses Context7 MCP to fetch framework-specific documentation on-demand:

1. **Auto-detection**: Identifies framework from build files
2. **Targeted queries**: Requests specific topics (e.g., "registry DeferredRegister")
3. **Code mode**: Gets API references and code examples
4. **Info mode**: Gets conceptual guides and architecture information

**Benefits**:
- Always up-to-date with latest framework changes
- Zero maintenance overhead for bundled documentation
- Reduced token usage (fetch only what's needed)
- Comprehensive coverage (7,735+ NeoForge snippets, 8,905+ Fabric snippets)

## Critical Conventions

### Naming Conventions
- **Agents**: `kebab-case.md` (e.g., `minecraft-modding-expert.md`)
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

### IntelliJ MCP Tool Usage

**See global `~/.claude/CLAUDE.md`** for IntelliJ tool preference hierarchy.

**Qingyi-specific tool assignments** (updated 2025-12-17):
- `minecraft-code-validator`: 5 IntelliJ tools (context, validation, optimization, file ops)
- `intellij-code-navigator`: 8 IntelliJ tools (full navigation suite)
- `intellij-refactoring-master`: 4 IntelliJ tools (refactoring, context, file ops)
- `intellij-project-analyzer`: 4 IntelliJ tools (project structure analysis)
- `intellij-build-and-test-runner`: 2 IntelliJ tools (run configs, execution)
- `registry-and-content-expert`: 6 IntelliJ tools (search suite + file ops)
- `events-and-lifecycle-expert`: 6 IntelliJ tools (search suite + file ops)
- `data-and-persistence-expert`: 6 IntelliJ tools (search suite + file ops)
- `rendering-and-client-expert`: 6 IntelliJ tools (search suite + file ops)

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

The agent contains **real code examples** from actual projects:

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
- [plugins/qingyi/agents/minecraft-modding-expert.md](plugins/qingyi/agents/minecraft-modding-expert.md) - The comprehensive expert agent
