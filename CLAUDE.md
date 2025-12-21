# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Qingyi** is a Claude Code plugin (v1.3.2) that provides specialized AI agents and reusable skills for Minecraft mod development. It supports Forge, NeoForge, Fabric, and Quilt frameworks.

**This is NOT a traditional software project** - there are no build/test commands. This is a plugin configuration project with markdown-based agents and skills that Claude Code loads to assist with Minecraft modding.

**Plugin Marketplace**: [.claude-plugin/marketplace.json](.claude-plugin/marketplace.json)

## Project Structure

```
Qingyi/                                    ← Marketplace root
├── .claude-plugin/
│   └── marketplace.json                   ← Defines 3 plugins from this repo
├── plugins/
│   ├── qingyi/                           ← Main plugin (15 agents, 5 commands, 23 skills)
│   │   ├── agents/
│   │   ├── commands/
│   │   └── skills/
│   ├── qingyi-code-review/               ← Code review plugin (1 agent, 1 command, 2 skills)
│   │   ├── agents/
│   │   ├── commands/
│   │   └── skills/
│   └── qingyi-modernizer/                ← Modernization plugin (1 agent, 4 commands, 2 skills)
│       ├── agents/
│       ├── commands/
│       └── skills/
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

**Key Design**: All 3 plugins use `"source": "./"` to copy the entire marketplace root (including `docs/`) to the plugin cache, ensuring agents can access supporting documentation.

## Plugin Architecture

The plugin uses a **Master Orchestrator + Specialist Agents + Progressive Skills** architecture:

- **Agents** (13 implemented): Specialized AI assistants with isolated contexts for specific domains
- **Skills** (8 implemented): Reusable knowledge modules that auto-load based on relevance
- **Commands**: Slash command templates for quick workflows
- **Hooks**: Event automation for validation and assistance

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

## Key Architectural Patterns

### Pattern 1: Master Orchestrator with Auto-Detection

**Agent**: [plugins/qingyi/agents/qingyi-orchestrator.md](plugins/qingyi/agents/qingyi-orchestrator.md)

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

**Example**: [plugins/qingyi/skills/forge-event-system/SKILL.md](plugins/qingyi/skills/forge-event-system/SKILL.md)
- Main file: Event bus overview, basic handler registration
- Supporting: Event priorities, tick handlers, common events

This prevents token waste - only load what's needed for the current task.

### Pattern 4: Self-Evolution System

The orchestrator has a **learning mechanism** (lines 173-221 in [plugins/qingyi/agents/qingyi-orchestrator.md](plugins/qingyi/agents/qingyi-orchestrator.md)):

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

## Task Routing (Quick Reference)

When working with Minecraft mods, **delegate tasks directly to specialist agents** using this routing guide:

| Task Domain | Agent | When to Use |
|-------------|-------|-------------|
| **Items, blocks, entities** | `registry-and-content-expert` | Creating game content, DeferredRegister, creative tabs |
| **Events, tick handlers** | `events-and-lifecycle-expert` | Event handlers, @SubscribeEvent, tick systems, mod lifecycle |
| **NBT, capabilities, persistence** | `data-and-persistence-expert` | SavedData, NBT serialization, world persistence, capabilities |
| **GUI, rendering, audio** | `rendering-and-client-expert` | Custom screens, boss bars, HUD, OpenAL audio, client rendering |
| **Code search & navigation** | `intellij-code-navigator` | Finding patterns, locating code, "where is X", "show me Y" |
| **Code validation** | `minecraft-code-validator` | Validating Java files (invoke AFTER code generation) |
| **Safe refactoring** | `intellij-refactoring-master` | Renaming items/blocks/methods, scope-aware refactoring |
| **Project analysis** | `intellij-project-analyzer` | Understanding architecture, detecting multi-loader projects |
| **Build & testing** | `intellij-build-and-test-runner` | Running client/server, testing in-game, verifying mod loads |
| **Documentation** | `minecraft-docs-architect` | Generating API docs, architecture guides (10-100+ pages) |
| **Tutorials** | `minecraft-tutorial-engineer` | Educational content, step-by-step guides, onboarding |
| **Code review** | `code-reviewer` | Security, performance, architecture review (qingyi-code-review plugin) |
| **Migration** | `legacy-modernizer` | Version upgrades, framework migration (qingyi-modernizer plugin) |
| **Web research** | `brave-search-agent` | Documentation lookup, framework comparisons, tutorials |
| **GitHub search** | `github-code-search-agent` | Community patterns, framework source, migration examples |
| **Plugin development** | `qingyi-plugin-manager` | Creating/modifying Qingyi agents, skills, CLAUDE.md updates |

### Delegation Pattern

Use this structured format when invoking agents:

```markdown
Use the [agent-name] agent to [specific task].

Context:
- Project: [ProjectName]
- Framework: [Forge 1.20.1 / NeoForge 1.21.3 / Fabric 1.20.x]
- Files: [key files to create/modify]
- Background: [relevant project context]

Expected: [deliverables]
```

**Example**:
```markdown
Use the registry-and-content-expert agent to create a custom sword item.

Context:
- Project: MusicMod
- Framework: Forge 1.20.1
- Files: ModItems.java, custom_sword.json, en_us.json
- Background: Project uses DeferredRegister, existing items follow standard pattern

Expected: RegistryObject entry, item model JSON, translation
```

### Post-Delegation Workflow

After a specialist agent completes:
1. **Review results** - Check files created/modified
2. **Validate (if Java modified)** - Invoke `minecraft-code-validator` agent
3. **Open files for user** - Use `mcp__intellij__open_file_in_editor()`
4. **Present summary** - Report completion with file list and validation status

**For detailed delegation patterns, agent catalog, and workflows**, the `agent-delegation` skill auto-loads when relevant.

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

### IntelliJ MCP Tool Usage

**CRITICAL**: When working with this Qingyi plugin project, ALWAYS prefer IntelliJ MCP tools over generic tools for better performance and accuracy.

#### Tool Preference Hierarchy

**For File Operations**:
1. ✅ **PREFER**: `mcp__intellij__create_new_file` for Java files (respects project structure, sourcesets)
2. ⚠️ FALLBACK: `Write` tool for non-Java files (JSON, markdown, etc.)

**For File Reading**:
1. ✅ **PREFER**: `mcp__intellij__get_file_text_by_path` for large files (>1000 lines) with truncation
2. ⚠️ FALLBACK: `Read` tool for normal files (<1000 lines)

**For Code Search**:
1. ✅ **PREFER**: `mcp__intellij__search_in_files_by_text` (semantic, 98% accuracy, 10x faster)
2. ✅ **PREFER**: `mcp__intellij__search_in_files_by_regex` for pattern matching
3. ✅ **PREFER**: `mcp__intellij__find_files_by_name_keyword` for file discovery
4. ⚠️ FALLBACK: `Grep` only for cross-language searches or searches outside project

**For File Discovery**:
1. ✅ **PREFER**: `mcp__intellij__find_files_by_glob` for pattern-based file search
2. ⚠️ FALLBACK: `Glob` only if IntelliJ tool unavailable

**For Navigation**:
1. ✅ **ALWAYS USE**: `mcp__intellij__get_symbol_info` for understanding symbols, declarations, types
2. ✅ **ALWAYS USE**: `mcp__intellij__get_all_open_file_paths` to detect user's current workspace focus

**For Refactoring**:
1. ✅ **ALWAYS USE**: `mcp__intellij__rename_refactoring` for renaming symbols (semantic, project-wide)
2. ❌ **NEVER USE**: Text replacement for symbol renaming

**For User Experience**:
1. ✅ **ALWAYS USE**: `mcp__intellij__open_file_in_editor` after creating/modifying files
2. ✅ **ALWAYS USE**: `mcp__intellij__open_file_in_editor` when validation finds errors

#### Context-Aware Agent Behavior

**When any agent starts work**:
```markdown
1. Call get_all_open_file_paths() to detect user focus
2. Analyze open files to understand current work area
3. Tailor approach based on user's active workspace
```

**Example**:
```
User has ModItems.java open → Infer: Working on item registration
User has EventHandler.java open → Infer: Working on event systems
User has ClientMusicHandler.java open → Infer: Working on client-side rendering/audio
```

#### Agent-Specific Tool Usage

**Agents with IntelliJ MCP tools** (enhanced 2025-12-17):
- `minecraft-code-validator`: 5 IntelliJ tools (context, validation, optimization, file ops)
- `qingyi-orchestrator`: 2 IntelliJ tools (context awareness, file opening)
- `intellij-code-navigator`: 8 IntelliJ tools (full navigation suite)
- `intellij-refactoring-master`: 4 IntelliJ tools (refactoring, context, file ops)
- `intellij-project-analyzer`: 4 IntelliJ tools (project structure analysis)
- `intellij-build-and-test-runner`: 2 IntelliJ tools (run configs, execution)
- `registry-and-content-expert`: 6 IntelliJ tools (search suite + file ops)
- `events-and-lifecycle-expert`: 6 IntelliJ tools (search suite + file ops)
- `data-and-persistence-expert`: 6 IntelliJ tools (search suite + file ops)
- `rendering-and-client-expert`: 6 IntelliJ tools (search suite + file ops)

**When working on Qingyi plugin development**:
- Use IntelliJ tools for agent file discovery and modification
- Use `open_file_in_editor` to show updated agents to user
- Use `get_all_open_file_paths` to understand which agents user is editing

#### Performance Benefits

| Task | Generic Tool | IntelliJ MCP Tool | Performance Gain |
|------|--------------|-------------------|------------------|
| File search | Grep (85% accuracy) | search_in_files (98% accuracy) | **10x faster** |
| Symbol lookup | Read + manual parsing | get_symbol_info | **Instant** with type info |
| File creation | Write (no structure awareness) | create_new_file | **Proper packages** |
| Large file read | Read (2000 lines, full load) | get_file_text_by_path | **20-50% token savings** |
| Refactoring | Edit (text replacement) | rename_refactoring | **Semantic, project-wide** |

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
- [plugins/qingyi/agents/qingyi-orchestrator.md](plugins/qingyi/agents/qingyi-orchestrator.md) - Master orchestrator implementation
