---
name: agent-delegation
description: Task delegation and agent selection for Minecraft mod development. Use PROACTIVELY when orchestrating workflows, routing tasks to specialist agents, planning multi-step implementations, determining which agent to use for Minecraft modding tasks. Covers agent catalog, delegation templates, validation chains, parallel delegation patterns.
allowed-tools: Task, Read, Grep, Glob
---

# Agent Delegation Guide

This skill provides comprehensive guidance on delegating tasks to specialized Qingyi agents for Minecraft mod development. Use this when you need to route tasks, orchestrate multi-agent workflows, or determine which specialist to invoke.

## Quick Reference: Task → Agent Mapping

| Task Domain | Agent | When to Use |
|-------------|-------|-------------|
| **Items, blocks, entities** | `registry-and-content-expert` | Creating/registering game content, DeferredRegister, creative tabs |
| **Events, tick handlers** | `events-and-lifecycle-expert` | Event bus, @SubscribeEvent, tick systems, mod lifecycle |
| **NBT, capabilities, persistence** | `data-and-persistence-expert` | SavedData, NBT serialization, world persistence, capability attachment |
| **GUI, rendering, audio** | `rendering-and-client-expert` | Custom screens, boss bars, HUD overlays, OpenAL audio, client-side rendering |
| **Code search & navigation** | `intellij-code-navigator` | Finding patterns, locating implementations, symbol lookup, semantic search |
| **Code validation** | `minecraft-code-validator` | IntelliJ inspections, error detection, auto-fixing issues (invoke AFTER code generation) |
| **Safe refactoring** | `intellij-refactoring-master` | Renaming items/blocks/methods, scope-aware refactoring, resource synchronization |
| **Project analysis** | `intellij-project-analyzer` | Understanding architecture, detecting multi-loader projects, analyzing structure |
| **Build & testing** | `intellij-build-and-test-runner` | Running client/server, executing tests, verifying mod loading |
| **Documentation** | `minecraft-docs-architect` | Generating API docs, architecture guides, comprehensive documentation (10-100+ pages) |
| **Tutorials** | `minecraft-tutorial-engineer` | Creating educational content, step-by-step guides, onboarding materials |
| **Code review** | `code-reviewer` | Security analysis, performance optimization, architecture review (qingyi-code-review plugin) |
| **Migration** | `legacy-modernizer` | Version upgrades (1.20→1.21), framework migration (Forge→NeoForge), technical debt (qingyi-modernizer plugin) |

For the complete catalog with detailed descriptions, see [agent-catalog.md](./agent-catalog.md).

---

## Delegation Template

When delegating to a specialist agent, use this structured format:

```markdown
Use the [agent-name] agent to [specific task].

**Context**:
- Project: [MusicMod/Apocalypse_TNT/ProjectName]
- Framework: [Forge 1.20.1 / NeoForge 1.21.3 / Fabric 1.20.x]
- Minecraft Version: [1.20.1 / 1.21.3]
- Architecture: [Single-loader / Multi-loader (common/forge/fabric)]
- Files involved: [list of key files to create/modify]
- Background: [relevant project-specific context]

**Expected Output**:
[What the agent should deliver - files created, modifications made, etc.]
```

**Example**:
```markdown
Use the registry-and-content-expert agent to create and register a custom sword item.

**Context**:
- Project: MusicMod
- Framework: Forge 1.20.1
- Minecraft Version: 1.20.1
- Architecture: Single-loader
- Files involved: ModItems.java, custom_sword.json (model), en_us.json (lang)
- Background: Project uses DeferredRegister pattern. Existing items follow standard Item.Properties pattern.

**Expected Output**:
- New RegistryObject<Item> in ModItems.java
- Item model JSON with proper texture references
- Translation entry in language file
```

---

## Context Passing Guidelines

When delegating, always provide these key pieces of information:

### 1. Project Information
- **Project name**: MusicMod, Apocalypse_TNT, etc.
- **Framework**: Forge, NeoForge, Fabric, Quilt
- **Version**: Minecraft 1.20.1, Forge 47.1.0, etc.
- **Architecture**: Single-loader or multi-loader (common/platform modules)

### 2. Task Specifics
- **Objective**: What needs to be accomplished
- **Scope**: Which files/modules are affected
- **Constraints**: Performance requirements, compatibility concerns
- **Patterns**: Existing code patterns to follow

### 3. File Paths
- Provide **absolute paths** or paths relative to project root
- List files to create vs modify
- Example: `src/main/java/com/mod/init/ModItems.java`

### 4. Expected Deliverables
- What files should be created/modified
- What validation is needed
- What output format is expected

---

## Post-Delegation Workflow

After a specialist agent completes their task, follow this workflow:

### 1. Review Results
- Examine the files created/modified
- Verify the implementation matches requirements
- Check for any warnings or issues reported

### 2. Automatic Validation (Proactive)

**When to invoke `minecraft-code-validator`**:
- ✅ After `registry-and-content-expert` creates items/blocks/entities
- ✅ After `events-and-lifecycle-expert` creates event handlers
- ✅ After `data-and-persistence-expert` creates NBT code
- ✅ After `rendering-and-client-expert` creates GUI/rendering code
- ✅ After any agent modifies Java files

**Pattern**:
```markdown
Use the minecraft-code-validator agent to validate the following files:
- [file-path-1]
- [file-path-2]

Context: [agent-name] just created/modified these files for [purpose].
Please validate for [specific concerns - e.g., registry patterns, event annotations].
```

**When NOT to validate**:
- ❌ Only JSON/resource files modified (no Java code)
- ❌ Only documentation updated
- ❌ Only gradle configuration changed

### 3. Open Files for User Review

Use `mcp__intellij__open_file_in_editor()` to open key files:

**Priority order**:
1. Main mod class (if modified)
2. New registry files (ModItems, ModBlocks, ModEntities)
3. New event handlers
4. Supporting files (models, lang files)

**Example**:
```
mcp__intellij__open_file_in_editor("src/main/java/com/mod/init/ModItems.java")
```

### 4. Present Summary to User

Provide a clear summary of what was accomplished:
```markdown
✓ Implementation completed by [agent-name]

**Files Created**:
- src/main/java/com/mod/items/CustomItem.java
- resources/assets/modid/models/item/custom_item.json

**Files Modified**:
- src/main/java/com/mod/init/ModItems.java (added RegistryObject)
- resources/assets/modid/lang/en_us.json (added translation)

**Validation**:
✓ Code validated successfully (no issues found)
or
⚠️ Code validated with 1 warning: [description]

**Next Steps**:
[Optional recommendations - testing, additional features, etc.]
```

---

## Parallel vs Sequential Delegation

### When to Parallelize (Single Message, Multiple Tool Calls)

Use parallel delegation when tasks are **independent** and can run simultaneously:

**Examples**:
- Creating multiple unrelated items
- Generating documentation + running code review
- Searching different codebases for patterns
- Analyzing multiple modules independently

**Pattern**:
```markdown
I'll delegate these tasks in parallel:

1. Use the registry-and-content-expert agent to create item A...
2. Use the registry-and-content-expert agent to create item B...
```

### When to Use Sequential Delegation

Use sequential delegation when tasks have **dependencies**:

**Examples**:
- Create code → Validate code → Test code (must be sequential)
- Analyze project → Design implementation → Execute implementation
- Find existing pattern → Follow pattern for new implementation

**Pattern**:
```markdown
Step 1: Use the intellij-project-analyzer agent to analyze architecture...
[Wait for result]
Step 2: Based on analysis, use the registry-and-content-expert agent to...
```

---

## Error Handling Patterns

### When a Delegation Fails

If an agent reports errors or cannot complete the task:

1. **Analyze the error**:
   - Read the agent's error message
   - Identify root cause (missing dependency, incorrect path, framework mismatch)

2. **Provide additional context**:
   ```markdown
   Use the [agent-name] agent to [retry task].

   Additional context:
   - Previous error: [error message]
   - Correction: [what needs to change]
   - Relevant files: [additional files to consider]
   ```

3. **Try alternative approach**:
   - If one agent fails, consider delegating to a different specialist
   - Example: Navigator can't find pattern → Manually search with Grep

4. **Escalate to user**:
   - If repeated attempts fail, report to user with diagnosis
   - Suggest manual intervention or alternative approaches

---

## Agent Collaboration Patterns

### Horizontal Collaboration (Peer-to-Peer)

Some agents collaborate with each other:

**Navigator Pattern**:
Specialist agents can request help from `intellij-code-navigator`:

```markdown
Use the intellij-code-navigator agent to find existing item registration patterns.

Context: Need reference implementation for DeferredRegister pattern.
```

Then use the found pattern to guide implementation.

### Validation Chain (Post-Processing)

Automatic validation after code generation:

```
registry-and-content-expert (creates code)
    ↓
minecraft-code-validator (validates code)
    ↓
Report to user
```

### Testing Chain (Optional)

For complex features:

```
Specialist implements feature
    ↓
minecraft-code-validator validates
    ↓
intellij-build-and-test-runner tests in-game
    ↓
Report to user
```

---

## Framework-Specific Delegation

### Forge/NeoForge Projects

When delegating for Forge/NeoForge:
- Mention `DeferredRegister`, `RegistryObject` patterns
- Specify Forge version (1.20.1, 47.1.0, etc.)
- Note if NeoForge (different package names)

### Fabric Projects

When delegating for Fabric:
- Mention `Registry.register` pattern
- Specify Fabric API version
- Note Quilt compatibility if relevant

### Multi-Loader Projects

When delegating for multi-loader:
- Specify which module (common, forge, fabric)
- Note abstraction patterns (ServiceLoader, platform modules)
- Mention code placement rules (common vs platform-specific)

---

## Quick Decision Tree

```
User asks about Minecraft modding task
    ↓
Is it about creating game content? → registry-and-content-expert
Is it about events/ticks? → events-and-lifecycle-expert
Is it about data persistence? → data-and-persistence-expert
Is it about GUI/rendering/audio? → rendering-and-client-expert
    ↓
Need to find existing code first? → intellij-code-navigator (THEN specialist)
    ↓
After specialist completes:
    ↓
Did they modify Java files? → minecraft-code-validator
    ↓
User wants testing? → intellij-build-and-test-runner
    ↓
Present results to user
```

---

## Common Workflows

### Workflow 1: Create New Item

```markdown
1. Use registry-and-content-expert to create item
2. Validate with minecraft-code-validator
3. Open ModItems.java for user review
4. Report completion
```

### Workflow 2: Complex Feature (Boss Bar Countdown)

```markdown
1. Use intellij-project-analyzer to understand architecture
2. Use events-and-lifecycle-expert for tick handler
3. Use rendering-and-client-expert for boss bar display
4. Use data-and-persistence-expert for state persistence
5. Validate all Java files with minecraft-code-validator
6. Use intellij-build-and-test-runner to test in-game
7. Report comprehensive results
```

### Workflow 3: Find and Modify Pattern

```markdown
1. Use intellij-code-navigator to find existing pattern
2. Use specialist agent to create similar implementation
3. Validate with minecraft-code-validator
4. Present results
```

---

## Best Practices

### ✅ Do

- Provide detailed context (project, framework, version)
- Specify exact file paths
- Invoke validator after Java code generation
- Open files for user review
- Present clear summaries
- Use parallel delegation for independent tasks
- Follow framework conventions (Forge vs Fabric patterns)

### ❌ Don't

- Delegate without context
- Skip validation for Java code
- Assume frameworks (always detect/specify)
- Ignore agent error messages
- Parallelize dependent tasks
- Mix framework patterns (Forge code in Fabric project)

---

**For the full agent catalog with detailed capabilities, invocation examples, and framework-specific notes, see [agent-catalog.md](./agent-catalog.md).**
