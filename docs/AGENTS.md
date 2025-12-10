# Comprehensive Agent Creation Guide

This guide provides in-depth information about creating custom agents for the Qingyi Minecraft Development Plugin.

## Table of Contents

1. [What Are Agents?](#what-are-agents)
2. [File Structure](#file-structure)
3. [Configuration Fields](#configuration-fields)
4. [Writing System Prompts](#writing-system-prompts)
5. [Tool Access Patterns](#tool-access-patterns)
6. [Model Selection](#model-selection)
7. [Permission Modes](#permission-modes)
8. [Proactive Invocation](#proactive-invocation)
9. [Best Practices](#best-practices)
10. [Testing](#testing)
11. [Examples](#examples)

## What Are Agents?

Agents are specialized AI assistants that:

- **Execute specific tasks** in isolated contexts
- **Have focused expertise** defined by system prompts
- **Use designated tools** to accomplish objectives
- **Return results** to the main conversation
- **Operate independently** with fresh context

### Agent vs Main Conversation

| Aspect | Agent | Main Conversation |
|--------|-------|-------------------|
| Context | Clean, isolated | Accumulated history |
| Purpose | Specific task | General assistance |
| Invocation | Delegated | Direct interaction |
| Tools | Restricted subset | All tools |
| Duration | Single task | Ongoing session |

## File Structure

### Location

```
agents/
└── your-agent-name.md
```

### Format

Markdown file with YAML frontmatter:

```markdown
---
name: agent-name
description: Description with trigger keywords
tools: Tool1, Tool2
model: sonnet
permissionMode: default
skills: skill1, skill2
---

# Agent Display Name

System prompt content...
```

## Configuration Fields

### Required Fields

#### name
- **Type**: `string`
- **Format**: Lowercase with hyphens
- **Max length**: 64 characters
- **Example**: `minecraft-architect`, `code-reviewer`

```yaml
name: minecraft-mod-architect
```

#### description
- **Type**: `string`
- **Purpose**: When/why to invoke this agent
- **Should include**:
  - Trigger keywords
  - Use cases
  - "Use PROACTIVELY" for automatic invocation

```yaml
description: Software architect specializing in Minecraft mod architecture. Use PROACTIVELY for architectural decisions, design patterns, and system planning for Forge, Fabric, and Quilt frameworks.
```

### Optional Fields

#### tools
- **Type**: `string` (comma-separated)
- **Default**: Inherits all tools
- **Purpose**: Restrict tool access

```yaml
# Read-only agent
tools: Read, Grep, Glob

# Implementation agent
tools: Read, Write, Edit, Bash

# Research agent
tools: Read, Grep, Glob, WebFetch, WebSearch
```

#### model
- **Type**: `string`
- **Options**: `sonnet`, `opus`, `haiku`, `inherit`
- **Default**: `inherit` (uses parent model)
- **Guidelines**:
  - `haiku`: Fast, simple tasks
  - `sonnet`: Balanced (recommended default)
  - `opus`: Complex reasoning, critical tasks

```yaml
model: sonnet
```

#### permissionMode
- **Type**: `string`
- **Options**:
  - `default`: Asks for permission normally
  - `acceptEdits`: Auto-accept file edits
  - `bypassPermissions`: Skip all permission requests
  - `plan`: Planning mode (read-only)

```yaml
permissionMode: acceptEdits
```

#### skills
- **Type**: `string` (comma-separated)
- **Purpose**: Auto-load skills for this agent

```yaml
skills: minecraft-api, gradle-configuration, forge-setup
```

## Writing System Prompts

The system prompt defines your agent's:
- Role and expertise
- Responsibilities
- Methodology
- Output format
- Constraints

### Structure Template

```markdown
# Agent Name

You are a [role] specializing in [domain].

## Core Expertise

- Expertise area 1
- Expertise area 2
- Expertise area 3

## Responsibilities

When invoked, you will:

1. **Primary task** - Description
2. **Secondary task** - Description
3. **Quality check** - Description

## Methodology

1. Understand the request
2. Analyze current state
3. Execute solution
4. Verify results
5. Report findings

## Output Format

Your response should include:
- Section 1
- Section 2
- Recommendations

## Constraints

- Do NOT: [prohibited actions]
- ALWAYS: [required actions]
- PREFER: [recommended approaches]

## Specific Instructions

[Detailed guidance for the agent]
```

### Example: Minecraft Architect

```markdown
# Minecraft Mod Architect

You are an expert software architect specializing in Minecraft modding.

## Core Expertise

### Architecture Patterns
- Event-driven architecture
- Registry patterns for items, blocks, entities
- Client-server communication
- Data persistence strategies

### Framework Knowledge
- **Forge**: Capabilities, events, registries
- **NeoForge**: Modern API patterns
- **Fabric**: Mixins, hooks, entrypoints

## Responsibilities

When invoked, you will:

1. **Analyze requirements** - Understand mod scope and constraints
2. **Design architecture** - Propose structure and patterns
3. **Plan implementation** - Break down into phases
4. **Document decisions** - Explain trade-offs

## Methodology

1. Ask clarifying questions about:
   - Target Minecraft version
   - Mod framework (Forge/Fabric/Quilt)
   - Feature requirements
   - Performance constraints

2. Review existing code if present

3. Design system architecture:
   - Package structure
   - Class responsibilities
   - Data flow
   - Event handling

4. Document design decisions

## Output Format

Provide:

### Architecture Overview
- High-level component diagram (text)
- Key design patterns used
- Rationale for choices

### Package Structure
```
mod.example/
├── core/
├── items/
├── blocks/
└── ...
```

### Implementation Phases
1. Phase 1: Foundation
2. Phase 2: Core features
3. Phase 3: Polish

### Next Steps
- Specific files to create
- Order of implementation

## Constraints

- Do NOT write implementation code
- Do NOT make assumptions about features not specified
- ALWAYS consider framework best practices
- PREFER simpler designs over complex ones
```

## Tool Access Patterns

### Read-Only Agent

Perfect for analysis, planning, code review:

```yaml
tools: Read, Grep, Glob
```

### Implementation Agent

Can modify code and run commands:

```yaml
tools: Read, Write, Edit, Bash, Grep, Glob
```

### Research Agent

Can fetch external information:

```yaml
tools: Read, Grep, Glob, WebFetch, WebSearch
```

### Full Access Agent

For complex workflows:

```yaml
# Omit tools field to inherit all
```

## Model Selection

### When to Use Each Model

**Haiku** (Fast, cost-effective):
- Simple code generation
- Template filling
- Quick analysis
- Routine tasks

**Sonnet** (Balanced - recommended):
- Code review
- Architecture design
- Implementation
- Most tasks

**Opus** (Powerful reasoning):
- Complex system design
- Critical debugging
- Performance optimization
- High-stakes decisions

## Permission Modes

### default
- Normal permission requests
- User approves file edits
- Best for learning/safety

### acceptEdits
- Auto-approve file edits
- Still asks for dangerous operations
- Good for trusted implementation agents

### bypassPermissions
- Skip all permission requests
- Use with caution
- Only for fully automated workflows

### plan
- Read-only mode
- Cannot execute changes
- Perfect for planning agents

## Proactive Invocation

To encourage automatic invocation, include keywords and phrases in your description:

### Trigger Phrases

```yaml
description: Use PROACTIVELY for [scenarios]
```

### Trigger Keywords

Include domain-specific terms:

```yaml
description: Expert in Minecraft items, blocks, entities, registries, events, mixins, and data generation. Use PROACTIVELY when implementing game content.
```

### Negative Triggers

Specify when NOT to use:

```yaml
description: ... Do NOT use for simple refactoring or documentation tasks.
```

## Best Practices

### 1. Single Responsibility

Each agent should have ONE clear purpose:

**Bad**: General helper agent

**Good**: Specific agents for architecture, implementation, review, testing

### 2. Clear Descriptions

Write descriptions that help Claude match tasks:

**Bad**:
```yaml
description: Helps with Minecraft mods
```

**Good**:
```yaml
description: Implement Minecraft mod features using Forge, Fabric, or Quilt APIs. Use PROACTIVELY for creating items, blocks, entities, and event handlers. Follows framework conventions and best practices.
```

### 3. Appropriate Tool Restrictions

Only grant necessary tools:

```yaml
# Architect doesn't need to edit files
tools: Read, Grep, Glob

# Developer needs full access
tools: Read, Write, Edit, Bash
```

### 4. Load Relevant Skills

Pre-load skills the agent commonly uses:

```yaml
skills: minecraft-api, gradle-configuration
```

### 5. Specify Output Format

Tell the agent how to structure responses:

```markdown
## Output Format

Your response must include:

1. **Summary** - 2-3 sentences
2. **Analysis** - Detailed findings
3. **Recommendations** - Actionable steps
4. **Files Modified** - List of changes
```

### 6. Version Control Awareness

For implementation agents:

```markdown
## Before Starting

1. Check current state with git status
2. Verify you're on correct branch
3. Confirm no uncommitted changes

## After Completion

1. List all modified files
2. Suggest commit message
3. Recommend testing steps
```

## Testing

### 1. Create Test Cases

Define scenarios that should trigger your agent:

```markdown
Test: "Design architecture for magic mod"
Expected: minecraft-architect agent invoked

Test: "Implement fire spell item"
Expected: mod-developer agent invoked

Test: "Review this event handler code"
Expected: code-reviewer agent invoked
```

### 2. Test Invocation

Try explicit invocation:

```
Use the minecraft-architect agent to design a boss mob system
```

### 3. Test Tool Access

Verify the agent can/cannot use specific tools:

```
# Should work if tools include Write
Agent creates new file

# Should fail if tools exclude Write
Agent blocked from creating file
```

### 4. Test Skill Loading

Confirm skills are loaded:

```
# Agent should reference minecraft-api skill
Agent uses registry pattern from skill
```

### 5. Verify Output Quality

Check if agent follows prompt instructions:

- [ ] Uses specified output format
- [ ] Stays within scope
- [ ] Provides actionable results
- [ ] Respects constraints

## Examples

See [examples/example-agent.md](../examples/example-agent.md) for complete templates.

### Implemented Agents

The Qingyi plugin currently includes these production-ready agents:

1. **qingyi-orchestrator** ([agents/qingyi-orchestrator.md](../agents/qingyi-orchestrator.md))
   - Master orchestrator for Minecraft mod development
   - Auto-detects project context (framework, versions)
   - Delegates to specialized Minecraft agents
   - Learns patterns and proposes plugin improvements
   - Tools: Read, Write, Edit, Grep, Glob, Task, Bash
   - Model: sonnet
   - Skills: pattern-recognition, agent-creation-guide, code-summarizer

2. **events-and-lifecycle-expert** ([agents/events-and-lifecycle-expert.md](../agents/events-and-lifecycle-expert.md))
   - Event systems and mod lifecycle specialist
   - Handles @SubscribeEvent, tick handlers, MOD vs FORGE bus
   - Framework-aware (Forge, NeoForge, Fabric)
   - Tools: Read, Write, Edit, Bash, Grep, Glob
   - Model: sonnet
   - Skills: forge-event-system

3. **registry-and-content-expert** ([agents/registry-and-content-expert.md](../agents/registry-and-content-expert.md))
   - Items, blocks, entities registration specialist
   - DeferredRegister (Forge/NeoForge), Registry.register (Fabric)
   - Creates resource files and models
   - Tools: Read, Write, Edit, Bash, Grep, Glob
   - Model: sonnet
   - Skills: forge-registry-api, neoforge-registry-api

4. **data-and-persistence-expert** ([agents/data-and-persistence-expert.md](../agents/data-and-persistence-expert.md))
   - NBT serialization and data storage specialist
   - Capability system, SavedData, PersistentState
   - Network sync for data
   - Tools: Read, Write, Edit, Bash, Grep, Glob
   - Model: sonnet
   - Skills: nbt-serialization-patterns

5. **rendering-and-client-expert** ([agents/rendering-and-client-expert.md](../agents/rendering-and-client-expert.md))
   - Client-side systems specialist
   - Screens, overlays, HUD, boss bars, audio, OpenAL
   - Framework-specific rendering patterns
   - Tools: Read, Write, Edit, Bash, Grep, Glob
   - Model: sonnet
   - Skills: rendering-patterns

6. **qingyi-plugin-manager** ([agents/qingyi-plugin-manager.md](../agents/qingyi-plugin-manager.md))
   - Manages Qingyi plugin development itself
   - Updates CLAUDE.md when architecture changes
   - Creates/validates new agents and skills
   - Maintains documentation consistency
   - Tools: Read, Write, Edit, Grep, Glob, Bash
   - Model: sonnet
   - Skills: agent-creation-guide, pattern-recognition

7. **minecraft-code-validator** ([agents/minecraft-code-validator.md](../agents/minecraft-code-validator.md))
   - Code quality assurance specialist using IntelliJ MCP
   - Runs IntelliJ inspections on generated code
   - Auto-fixes common issues (imports, annotations, formatting)
   - Ensures consistent code style across all files
   - Invoked PROACTIVELY after specialist agents complete work
   - Tools: mcp__intellij__get_file_problems, mcp__intellij__reformat_file, Read, Edit
   - Model: sonnet
   - Skills: forge-event-system, forge-registry-api, neoforge-registry-api, nbt-serialization-patterns, intellij-inspection-guide

8. **intellij-code-navigator** ([agents/intellij-code-navigator.md](../agents/intellij-code-navigator.md))
   - Code navigation and discovery specialist using IntelliJ MCP
   - Finds registry entries, event handlers, class hierarchies
   - Maps code-to-resource relationships (models, textures, lang files)
   - Provides symbol documentation and usage tracking
   - Invoked PROACTIVELY when user asks "where", "find", "locate", "show"
   - Tools: IntelliJ MCP navigation tools (find, search, symbol info) + Read
   - Model: sonnet
   - Skills: intellij-navigation-patterns

9. **intellij-refactoring-master** ([agents/intellij-refactoring-master.md](../agents/intellij-refactoring-master.md))
   - Safe, scope-aware refactoring specialist using IntelliJ MCP
   - Renames items, blocks, entities, methods, variables (98% accuracy)
   - Synchronizes resource files (models, textures, lang, recipes, loot tables)
   - Detects breaking changes and provides migration strategies
   - Invoked PROACTIVELY when user requests rename operations
   - Tools: mcp__intellij__rename_refactoring, mcp__intellij__replace_text_in_file, mcp__intellij__get_symbol_info, Read, Write, Edit
   - Model: sonnet
   - Permission mode: acceptEdits
   - Skills: intellij-refactoring-safety, forge-registry-api, neoforge-registry-api

10. **intellij-project-analyzer** ([agents/intellij-project-analyzer.md](../agents/intellij-project-analyzer.md))
    - Project structure and dependency analysis specialist using IntelliJ MCP
    - Detects multi-loader projects (Common/Forge/Fabric/Quilt patterns)
    - Analyzes dependencies, modules, source sets, and conventions
    - Provides comprehensive project context (4-10x faster than manual exploration)
    - Invoked PROACTIVELY at start of complex tasks to understand architecture
    - Tools: mcp__intellij__get_project_modules, mcp__intellij__get_project_dependencies, mcp__intellij__list_directory_tree, mcp__intellij__get_repositories, Read
    - Model: haiku (cost-efficient for analysis tasks)
    - Skills: multi-loader-project-patterns, pattern-recognition

11. **intellij-build-and-test-runner** ([agents/intellij-build-and-test-runner.md](../agents/intellij-build-and-test-runner.md))
    - Build, test, and execution automation specialist using IntelliJ MCP
    - Executes runClient, runServer, runData configurations
    - Monitors console output for mod loading, errors, warnings
    - Verifies in-game functionality (5x faster than manual testing)
    - Invoked PROACTIVELY after implementing features to verify functionality
    - Tools: mcp__intellij__get_run_configurations, mcp__intellij__execute_run_configuration, mcp__intellij__execute_terminal_command, Bash
    - Model: sonnet
    - Skills: minecraft-run-configuration-guide

### Suggested Future Agents

Additional agents that could be added:

1. **networking-and-sync-expert**
   - Packet handling and client-server sync
   - Network channels and message protocols
   - Framework-specific networking APIs

2. **entity-and-behavior-expert**
   - Custom entity creation
   - AI goals and behaviors
   - Entity spawning and management

3. **commands-and-config-expert**
   - Command registration and execution
   - Configuration file management
   - Permission handling

4. **gradle-and-build-expert**
   - Build system configuration
   - Dependency management
   - Development environment setup

5. **mixin-and-compat-expert**
   - Mixin development and debugging
   - Mod compatibility handling
   - Core mod features

---

For more examples and templates, see the [examples/](../examples/) directory.
