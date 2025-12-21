# Qingyi Agent Catalog

Complete reference of all specialized agents in the Qingyi plugin system. Use this catalog to select the appropriate agent for your Minecraft modding task.

---

## Registry & Content Expert

**Name**: `registry-and-content-expert`

**Domain**: Items, blocks, entities, creative tabs, game content registration

**Tools**: Read, Write, Edit, Bash, Grep, Glob, IntelliJ MCP (search, file ops, symbol info, create files, open in editor)

**Skills Loaded**: `forge-registry-api`, `neoforge-registry-api`, `fabric-registry-api`, `intellij-navigation-patterns`

**When to Use**:
- Creating new items, blocks, or entities
- Registering game content with DeferredRegister (Forge/NeoForge)
- Using Registry.register (Fabric/Quilt)
- Setting up creative tabs
- Configuring item/block properties
- Working with RegistryObject patterns

**Example Invocation**:
```markdown
Use the registry-and-content-expert agent to create a custom sword item for my Forge 1.20.1 mod.

Context:
- Project: MusicMod
- Framework: Forge 1.20.1
- Files: ModItems.java (uses DeferredRegister), existing items follow standard pattern
- Need: New sword with custom durability and enchantability

Expected: RegistryObject entry, item model JSON, translation
```

---

## Events & Lifecycle Expert

**Name**: `events-and-lifecycle-expert`

**Domain**: Event handlers, tick systems, mod initialization, lifecycle management

**Tools**: Read, Write, Edit, Bash, Grep, Glob, IntelliJ MCP (search, file ops, symbol info, create files, open in editor)

**Skills Loaded**: `forge-event-system`, `fabric-event-system`, `mod-lifecycle-patterns`, `intellij-navigation-patterns`

**When to Use**:
- Implementing @SubscribeEvent handlers (Forge/NeoForge)
- Working with Fabric callbacks and events
- Creating server/client tick handlers
- Handling player join/leave events
- Managing mod initialization (MOD vs FORGE bus)
- Event priority and cancellation logic

**Example Invocation**:
```markdown
Use the events-and-lifecycle-expert agent to create a server tick handler for countdown logic.

Context:
- Project: Apocalypse_TNT
- Framework: NeoForge 1.21.3
- Need: Tick every second, decrement counter, trigger event at zero
- Existing: ServerEvents.java with other event handlers

Expected: New @SubscribeEvent method, tick logic, proper event bus registration
```

---

## Data & Persistence Expert

**Name**: `data-and-persistence-expert`

**Domain**: NBT serialization, SavedData, capabilities, world persistence, data generation

**Tools**: Read, Write, Edit, Bash, Grep, Glob, IntelliJ MCP (search, file ops, symbol info, create files, open in editor)

**Skills Loaded**: `nbt-serialization-patterns`, `forge-capabilities`, `data-generation-guide`, `intellij-navigation-patterns`

**When to Use**:
- NBT (CompoundTag, ListTag) serialization/deserialization
- SavedData (Forge) / PersistentState (Fabric) implementation
- Forge capabilities attachment and management
- World-level data storage
- Player-specific data persistence
- Data generation (recipes, loot tables, advancements)

**Example Invocation**:
```markdown
Use the data-and-persistence-expert agent to create world-level countdown data storage.

Context:
- Project: Apocalypse_TNT
- Framework: NeoForge 1.21.3
- Need: Store countdown value, persist across server restarts, accessible globally
- Pattern: Use SavedData with NBT serialization

Expected: SavedData implementation, NBT save/load methods, global accessor
```

---

## Rendering & Client Expert

**Name**: `rendering-and-client-expert`

**Domain**: GUI development, boss bars, HUD overlays, audio playback, client-side rendering

**Tools**: Read, Write, Edit, Bash, Grep, Glob, IntelliJ MCP (search, file ops, symbol info, create files, open in editor)

**Skills Loaded**: `rendering-patterns`, `gui-development`, `sound-system-api`, `intellij-navigation-patterns`

**When to Use**:
- Creating custom screens and GUIs
- Boss bar creation and updates
- HUD overlays and toasts
- OpenAL audio playback and music systems
- Client-side rendering (entities, blocks, items)
- @OnlyIn(Dist.CLIENT) logic

**Example Invocation**:
```markdown
Use the rendering-and-client-expert agent to create a boss bar showing countdown progress.

Context:
- Project: Apocalypse_TNT
- Framework: NeoForge 1.21.3
- Need: Boss bar at top of screen, updates every second, color changes as time decreases
- Integration: Synced from server countdown data

Expected: Boss bar creation, client tick update logic, color progression
```

---

## IntelliJ Code Navigator

**Name**: `intellij-code-navigator`

**Domain**: Code search, pattern discovery, symbol lookup, semantic navigation

**Tools**: IntelliJ MCP (search by text/regex, find files by name/glob, symbol info, directory tree, all open files, get file text)

**Skills Loaded**: `intellij-navigation-patterns`

**When to Use**:
- User asks "where is X?", "find all Y", "show me Z", "locate"
- Finding existing implementations to follow
- Discovering registry entries
- Locating event handlers
- Mapping code-to-resource relationships
- Understanding unfamiliar codebase structure

**Example Invocation**:
```markdown
Use the intellij-code-navigator agent to find all existing item registrations in the project.

Context:
- Project: MusicMod
- Framework: Forge 1.20.1
- Need: Reference pattern for creating new item

Expected: List of existing items, registration pattern, file locations
```

---

## Minecraft Code Validator

**Name**: `minecraft-code-validator`

**Domain**: Code validation, IntelliJ inspections, error detection, auto-fixing

**Tools**: IntelliJ MCP (get file problems, reformat file, open file, get all open paths, get file text), Read, Edit

**Skills Loaded**: `intellij-inspection-guide`, `forge-event-system`, `forge-registry-api`, `neoforge-registry-api`, `nbt-serialization-patterns`

**When to Use** (PROACTIVELY):
- After `registry-and-content-expert` creates items/blocks/entities
- After `events-and-lifecycle-expert` creates event handlers
- After `data-and-persistence-expert` creates NBT code
- After `rendering-and-client-expert` creates GUI code
- After any agent modifies Java files

**Example Invocation**:
```markdown
Use the minecraft-code-validator agent to validate the following files:
- src/main/java/com/mod/init/ModItems.java
- src/main/java/com/mod/items/CustomSword.java

Context: registry-and-content-expert just created a custom sword item.
Please validate for registry patterns, missing annotations, unused imports.
```

---

## IntelliJ Refactoring Master

**Name**: `intellij-refactoring-master`

**Domain**: Safe refactoring, symbol renaming, resource synchronization

**Tools**: IntelliJ MCP (rename refactoring, replace text, symbol info, all open files, open file), Read, Write, Edit

**Skills Loaded**: `intellij-refactoring-safety`, `forge-registry-api`, `neoforge-registry-api`

**When to Use**:
- Renaming registry objects (items, blocks, entities)
- Renaming methods, variables, classes (scope-aware)
- Large-scale refactoring operations
- Need resource file synchronization (models, lang, recipes)
- Breaking change detection

**Example Invocation**:
```markdown
Use the intellij-refactoring-master agent to safely rename COPPER_SWORD to BRONZE_SWORD.

Context:
- Project: MusicMod
- Framework: Forge 1.20.1
- Scope: Registry object (item) - affects code AND resources
- Files: ModItems.java, model JSON, lang file, recipe, loot table

Expected: All references updated, resources synchronized, breaking change warning
```

---

## IntelliJ Project Analyzer

**Name**: `intellij-project-analyzer`

**Domain**: Project structure analysis, multi-loader detection, dependency analysis

**Tools**: IntelliJ MCP (get project modules, dependencies, directory tree, repositories), Read

**Skills Loaded**: `multi-loader-project-patterns`, `pattern-recognition`

**When to Use** (PROACTIVELY at start of complex tasks):
- Unknown project structure
- Multi-loader projects (common/forge/fabric modules)
- Large codebases with multiple subsystems
- Before major architectural changes
- Detecting framework and version information

**Example Invocation**:
```markdown
Use the intellij-project-analyzer agent to analyze the project structure.

Context: User wants to add a new feature, but project architecture is unknown.
Need to determine if single-loader or multi-loader, detect modules, understand conventions.
```

---

## IntelliJ Build & Test Runner

**Name**: `intellij-build-and-test-runner`

**Domain**: Running Minecraft client/server, executing tests, verifying mod loading

**Tools**: IntelliJ MCP (get run configurations, execute run configuration, execute terminal command), Bash

**Skills Loaded**: `minecraft-run-configuration-guide`

**When to Use**:
- Testing new items/blocks/entities in-game
- Running runClient for visual features
- Running runServer for server-side features
- Running runData for data generation
- Verifying mod loads without errors

**Example Invocation**:
```markdown
Use the intellij-build-and-test-runner agent to test the new custom sword item in-game.

Context:
- Project: MusicMod
- Framework: Forge 1.20.1
- Just implemented: Custom sword item in ModItems.java
- Test type: runClient
- Expected: Mod loads, item appears in creative tab, item is functional

Please monitor console for errors and confirm successful loading.
```

---

## Minecraft Docs Architect

**Name**: `minecraft-docs-architect`

**Domain**: Comprehensive technical documentation, API references, architecture guides

**Tools**: Read, Write, Edit, Bash, Grep, Glob, Task

**Skills Loaded**: `minecraft-documentation-patterns`

**When to Use**:
- Generating full mod documentation (10-100+ pages)
- Creating API reference documentation
- Architectural deep-dives
- Registry system documentation
- Event handler API docs
- Mixin documentation

**Example Invocation**:
```markdown
Use the minecraft-docs-architect agent to generate comprehensive documentation for MusicMod.

Context:
- Project: MusicMod
- Framework: Forge 1.20.1
- Scope: Document all items, audio system, advancement integration, architecture
- Output: Single DOCUMENTATION.md file

Expected: Registry docs, event handlers, audio API, architecture diagrams
```

---

## Minecraft Tutorial Engineer

**Name**: `minecraft-tutorial-engineer`

**Domain**: Educational content, step-by-step tutorials, onboarding guides

**Tools**: Read, Write, Edit, Grep, Glob

**Skills Loaded**: `minecraft-tutorial-patterns`

**When to Use**:
- Creating beginner/intermediate/expert tutorials
- Onboarding new developers
- Feature implementation guides
- Educational content with hands-on exercises
- Progressive difficulty learning paths

**Example Invocation**:
```markdown
Use the minecraft-tutorial-engineer agent to create a tutorial for adding custom items.

Context:
- Target audience: Intermediate modders
- Framework: Forge 1.20.1
- Topics: DeferredRegister, item properties, models, textures
- Include: Step-by-step code, common mistakes, exercises

Expected: Tutorial markdown with progressive difficulty, hands-on examples
```

---

## Code Reviewer (qingyi-code-review plugin)

**Name**: `code-reviewer`

**Domain**: Comprehensive code review, security analysis, performance optimization, architecture review

**Tools**: All tools (Read, Write, Edit, Bash, Grep, Glob, Task)

**Skills Loaded**: `java-security-patterns`, `minecraft-code-review-patterns`

**When to Use**:
- Security vulnerability detection (OWASP Top 10)
- Performance optimization recommendations
- Architecture review and improvements
- Input validation and sanitization
- Dependency vulnerability scanning
- Production readiness assessment

**Example Invocation**:
```markdown
Use the code-reviewer agent to perform a comprehensive security and performance review.

Context:
- Project: MusicMod
- Framework: Forge 1.20.1
- Focus: Security (NBT deserialization, user input), performance (audio playback, tick handlers)

Expected: Security issues, performance bottlenecks, optimization recommendations
```

---

## Legacy Modernizer (qingyi-modernizer plugin)

**Name**: `legacy-modernizer`

**Domain**: Framework migration, version upgrades, technical debt reduction

**Tools**: All tools (Read, Write, Edit, Bash, Grep, Glob, Task)

**Skills Loaded**: `gradle-migration-patterns`, `mod-migration-guide`

**When to Use**:
- Migrating Forge → NeoForge
- Upgrading Minecraft versions (1.20 → 1.21)
- Converting single-loader → multi-loader
- Gradle build system updates (ForgeGradle, Loom, NeoGradle)
- Technical debt reduction
- Dependency updates with backward compatibility

**Example Invocation**:
```markdown
Use the legacy-modernizer agent to migrate MusicMod from Forge 1.20.1 to NeoForge 1.21.3.

Context:
- Current: Forge 1.20.1, Minecraft 1.20.1
- Target: NeoForge 1.21.3, Minecraft 1.21.3
- Scope: Update registry system, event handlers, capability system
- Strategy: Gradual migration, maintain backward compatibility where possible

Expected: Migration plan, updated code, compatibility notes, testing checklist
```

---

## Brave Search Agent

**Name**: `brave-search-agent`

**Domain**: Web research, documentation lookup, framework comparisons, tutorial discovery

**Tools**: Brave MCP (web search, local search, news, video, image, summarizer), Read, Write

**Skills Loaded**: `pattern-recognition`

**When to Use**:
- Looking up official Minecraft Forge/Fabric documentation
- Finding framework migration guides
- Researching recent API changes (2024/2025)
- Discovering community tutorials and examples
- Comparing framework features (Forge vs NeoForge vs Fabric)

**Example Invocation**:
```markdown
Use the brave-search-agent agent to find the official NeoForge 1.21.3 registry documentation.

Context: Need to understand API changes from Forge 1.20.1 to NeoForge 1.21.3 for registry system.

Expected: Official docs links, migration guides, API change notes
```

**Note**: Uses ~5k tokens per search (4.5x more than WebSearch) due to extra_snippets feature.

---

## GitHub Code Search Agent

**Name**: `github-code-search-agent`

**Domain**: GitHub repository search, community patterns, framework source code, migration examples

**Tools**: GitHub MCP (search code/repos/issues/PRs, get file contents, commits, releases), Read, Write

**Skills Loaded**: `pattern-recognition`

**When to Use**:
- Finding real-world mod examples
- Discovering framework implementation patterns
- Locating migration pull requests (Forge → NeoForge)
- Researching version compatibility
- Finding community solutions to problems
- Examining framework source code

**Example Invocation**:
```markdown
Use the github-code-search-agent agent to find examples of boss bar implementation in NeoForge 1.21 mods.

Context: Need reference patterns for creating and updating boss bars in NeoForge.

Expected: GitHub repo links, code examples, implementation patterns
```

**Note**: Token-efficient (~2.5k/search) for finding real code patterns.

---

## Qingyi Plugin Manager

**Name**: `qingyi-plugin-manager`

**Domain**: Qingyi plugin development, maintaining agents/skills, CLAUDE.md updates

**Tools**: Read, Write, Edit, Grep, Glob, Bash

**Skills Loaded**: `agent-creation-guide`, `pattern-recognition`

**When to Use** (for Qingyi plugin itself):
- Creating new agents or skills
- Updating CLAUDE.md
- Maintaining documentation consistency
- Validating YAML frontmatter
- Checking cross-references
- Quality assurance for plugin components

**Example Invocation**:
```markdown
Use the qingyi-plugin-manager agent to create a new skill for OpenAL audio playback patterns.

Context:
- Skill name: openal-audio-playback
- Purpose: Document advanced audio control patterns from MusicMod
- Include: Buffer management, seeking, pause/resume state

Expected: New skill directory, SKILL.md, supporting files, updated documentation
```

---

## Agent Selection Decision Tree

```
Task Type:
├─ Game Content (items, blocks, entities) → registry-and-content-expert
├─ Events (tick, player, world) → events-and-lifecycle-expert
├─ Data (NBT, SavedData, capabilities) → data-and-persistence-expert
├─ Client (GUI, rendering, audio) → rendering-and-client-expert
├─ Code Search ("where is", "find") → intellij-code-navigator
├─ Validation (after code generation) → minecraft-code-validator
├─ Refactoring (rename operations) → intellij-refactoring-master
├─ Project Analysis (complex tasks) → intellij-project-analyzer
├─ Testing (runClient, runServer) → intellij-build-and-test-runner
├─ Documentation (API docs, guides) → minecraft-docs-architect
├─ Tutorials (educational content) → minecraft-tutorial-engineer
├─ Code Review (security, performance) → code-reviewer
├─ Migration (version, framework) → legacy-modernizer
├─ Web Research (docs, tutorials) → brave-search-agent
├─ GitHub Search (community patterns) → github-code-search-agent
└─ Plugin Development (Qingyi itself) → qingyi-plugin-manager
```

---

## Framework-Specific Notes

### Forge 1.19-1.20.x Agents
- **Registry**: `registry-and-content-expert` with `forge-registry-api` skill
- **Events**: `events-and-lifecycle-expert` with `forge-event-system` skill
- **Capabilities**: `data-and-persistence-expert` with `forge-capabilities` skill

### NeoForge 1.20-1.21.x Agents
- **Registry**: `registry-and-content-expert` with `neoforge-registry-api` skill
- **Events**: `events-and-lifecycle-expert` with `forge-event-system` skill (similar)
- **Attachments**: `data-and-persistence-expert` (NeoForge uses attachment system, not capabilities)

### Fabric/Quilt 1.19-1.21.x Agents
- **Registry**: `registry-and-content-expert` with `fabric-registry-api` skill
- **Events**: `events-and-lifecycle-expert` with `fabric-event-system` skill
- **Persistence**: `data-and-persistence-expert` (uses PersistentState)

### Multi-Loader Projects
- **Analysis**: Start with `intellij-project-analyzer` to detect architecture
- **Common Module**: Most agents work in common module (cross-platform code)
- **Platform Modules**: Use framework-specific agents for platform code

---

**For delegation patterns, templates, and workflows, see [SKILL.md](./SKILL.md).**
