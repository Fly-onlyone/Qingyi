# Example: Refactoring Plugin Components

This example demonstrates how to use the `/refactor-plugin-component` command.

## Example 1: Refactoring an Agent with YAML Issues

### Before

```yaml
# agents/example-agent.md
---
name: example_agent_with_underscores
description: Handles stuff
tools: Read Write Edit
model: sonnet
permissionMode: default
---

# Example Agent

Does various things.

## Example

```java
// Pseudocode
public void doSomething() {
    // Implementation
}
```
```

### Command

```bash
/refactor-plugin-component agents/example-agent.md
```

### After Refactoring

```yaml
# agents/example-agent.md
---
# CHANGED: Renamed to kebab-case for consistency
name: example-agent

# CHANGED: Added specific keywords and "Use PROACTIVELY"
description: Expert in registry operations, item/block registration. Use PROACTIVELY for DeferredRegister setup, RegistryObject creation, and Forge/NeoForge registry patterns.

# CHANGED: Formatted with comma-space separation, added Grep for searching
tools: Read, Write, Edit, Grep, Glob

# UNCHANGED: Model remains sonnet
model: sonnet

# UNCHANGED: Default permission mode
permissionMode: default

# ADDED: Relevant skills for pre-loading
skills: forge-registry-api, neoforge-registry-api
---

# Example Agent - Registry Operations Expert

You are a specialized agent for handling Minecraft mod registry operations.

## Core Responsibilities

- Register items, blocks, entities using DeferredRegister
- Set up RegistryObjects with proper naming
- Handle creative tabs and item properties
- Ensure client-server compatibility

## Behavioral Guidelines

1. Always use DeferredRegister for Forge/NeoForge (don't use @ObjectHolder)
2. Check framework from build.gradle before providing code
3. Cite source projects when showing examples
4. Verify registration happens in mod constructor

## Example

```java
// Real example from MusicMod (Forge 1.20.1)
// Source: qingyi.thefatrat.registry.ItemRegistry:15

public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, TheFatRatMod.MOD_ID);

public static final RegistryObject<Item> MUSIC_DISC_OVERBOARD = ITEMS.register(
    "music_disc_overboard",
    () -> new RecordItem(
        15,
        ModSounds.OVERBOARD,
        new Item.Properties().stacksTo(1).rarity(Rarity.RARE),
        3380  // Duration in ticks
    )
);

// In mod constructor:
public TheFatRatMod() {
    IEventBus modEventBus = FMLJavaModLoadingContext.get().getModEventBus();
    ITEMS.register(modEventBus);
}
```
```

### Issues Fixed

1. **[Critical]** YAML frontmatter: Changed underscores to kebab-case
2. **[High]** Tools list: Added proper comma-space formatting, added Grep
3. **[High]** Description: Added specific keywords for auto-invocation
4. **[High]** Code example: Replaced pseudocode with real example from MusicMod
5. **[Medium]** Added skills: Pre-loaded relevant registry skills
6. **[Medium]** Added structure: Core Responsibilities, Behavioral Guidelines sections

### Token Impact

- Before: ~150 tokens (vague, generic)
- After: ~400 tokens (specific, actionable)
- Justified increase: Real examples prevent hallucination, save debugging time

## Example 2: Converting Skill to Progressive Loading

### Before

```markdown
# skills/forge-events/SKILL.md (800 lines)
---
name: forge-events
description: Forge event system
---

# Forge Events

## Event Bus
[100 lines of content]

## Registration
[150 lines of content]

## Event Types
[400 lines with all events documented]

## Priorities
[100 lines]

## Tick Handlers
[150 lines]
```

### Command

```bash
/refactor-plugin-component skills/forge-events/SKILL.md
```

### After Refactoring

**Main File (200 lines)**:
```markdown
# skills/forge-event-system/SKILL.md
---
# CHANGED: More descriptive name
name: forge-event-system

# CHANGED: Added specific keywords for auto-loading
description: Forge event bus, @SubscribeEvent handlers, event priorities, PlayerEvent, EntityEvent, BlockEvent, tick handlers (ClientTickEvent, ServerTickEvent), event cancellation. Use for event-driven logic, lifecycle hooks, and game loop integration.
---

# Forge Event System

## Overview

The Forge event system enables mods to respond to game events through a publish-subscribe pattern.

**Core Concepts**:
- Event bus (MOD bus vs FORGE bus)
- @SubscribeEvent annotation
- Event priorities
- Event cancellation

## Common Event Registration

```java
// Example from Apocalypse_TNT (NeoForge)
// Source: qingyi.apocalypse.ApocalypseMod:42

@Mod.EventBusSubscriber(modid = ApocalypseMod.MOD_ID, bus = Mod.EventBusSubscriber.Bus.FORGE)
public class ApocalypseEventHandler {

    @SubscribeEvent
    public static void onServerTick(TickEvent.ServerTickEvent event) {
        if (event.phase == TickEvent.Phase.END) {
            // Server tick logic
        }
    }
}
```

## Event Bus Types

**MOD Bus**: Mod lifecycle events
- RegisterEvent (registry)
- FMLCommonSetupEvent
- FMLClientSetupEvent

**FORGE Bus**: Game events
- PlayerEvent, EntityEvent, BlockEvent
- TickEvent (server/client)
- WorldEvent

## Most Common Events

### Player Events
```java
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    Player player = event.getEntity();
    // Welcome message, data initialization
}
```

### Tick Events
```java
@SubscribeEvent
public static void onClientTick(TickEvent.ClientTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        // Update UI, input handling
    }
}
```

## Advanced Topics

For detailed information on specific topics, see:

- **[Event Priorities](./priorities.md)** - When you need to control execution order
- **[Tick Handler Patterns](./tick-handlers.md)** - Client vs server ticks, performance
- **[Event Catalog](./event-catalog.md)** - Comprehensive list of all Forge events
- **[Anti-Patterns](./antipatterns.md)** - Common mistakes to avoid
```

**Supporting Files**:

`priorities.md` (200 lines):
```markdown
# Event Priorities

Detailed guide on:
- Priority levels (HIGHEST to LOWEST)
- When to use each priority
- Common priority conflicts
- Best practices
```

`tick-handlers.md` (150 lines):
```markdown
# Tick Handler Patterns

Detailed guide on:
- Client vs server tick distinction
- Performance optimization for tick handlers
- When to use tick handlers vs other events
- Throttling and scheduling patterns
```

`event-catalog.md` (300 lines):
```markdown
# Forge Event Catalog

Comprehensive listing of:
- All PlayerEvent types
- All EntityEvent types
- All BlockEvent types
- All WorldEvent types
- With usage examples for each
```

`antipatterns.md` (100 lines):
```markdown
# Event System Anti-Patterns

Common mistakes:
- ❌ Using MOD bus for game events
- ❌ Heavy computation in tick handlers
- ❌ Not checking world.isClientSide()
- ✓ Solutions for each
```

### Issues Fixed

1. **[Critical]** Token waste: 800-line file reduced to 200 + on-demand loading
2. **[High]** Keywords: Added specific event names for auto-loading
3. **[High]** Structure: Progressive loading with supporting files
4. **[Medium]** Examples: Real code from Apocalypse_TNT project

### Token Impact

- Before: ~800 lines (~12,000 tokens) loaded every time
- After: ~200 lines (~3,000 tokens) initially, ~150-300 per supporting file (only when needed)
- Savings: **75% token reduction** for typical usage

## Example 3: Extracting Duplicate Pattern to Skill

### Scenario

Three agents have the same DeferredRegister example:
- `registry-and-content-expert.md`
- `events-and-lifecycle-expert.md` (for registering event handlers)
- `data-and-persistence-expert.md` (for registering data serializers)

### Command

```bash
/refactor-plugin-component agents/registry-and-content-expert.md
```

### Claude's Analysis

```
## Duplicate Pattern Detected

**Pattern**: Forge DeferredRegister setup
**Occurrences**: 3 agents (registry-expert, events-expert, data-expert)
**Total Duplicate Tokens**: ~500 tokens

**Recommendation**: Extract to skill `forge-registry-api`
```

### Refactoring Plan

**Phase 1**: Create new skill
```bash
# Claude creates:
skills/forge-registry-api/SKILL.md
```

**Phase 2**: Update agents to reference skill
```yaml
# agents/registry-and-content-expert.md
skills: forge-registry-api, neoforge-registry-api

# agents/events-and-lifecycle-expert.md
skills: forge-event-system, forge-registry-api

# agents/data-and-persistence-expert.md
skills: nbt-serialization-patterns, forge-registry-api
```

**Phase 3**: Remove duplicate content from agents
```markdown
# Instead of embedding full DeferredRegister example:

## Registry Setup

For DeferredRegister patterns, refer to the `forge-registry-api` skill (pre-loaded).

Quick reference:
- Create DeferredRegister in your registry class
- Use ITEMS.register() for each item
- Register the DeferredRegister in mod constructor

See skill for complete examples from MusicMod and Apocalypse_TNT.
```

### Result

- **Before**: 3 agents × ~200 tokens = 600 tokens duplicate
- **After**: 1 skill × ~200 tokens = 200 tokens (reused across agents)
- **Savings**: 400 tokens (~67% reduction) + improved consistency

## Example 4: Clarifying Agent Boundaries

### Problem

Two agents with overlapping domains:

```yaml
# agents/rendering-expert.md
description: Handles rendering

# agents/client-expert.md
description: Handles client-side logic including rendering
```

Users confused: "Which agent do I use for GUI screens?"

### Command

```bash
/refactor-plugin-component agents/rendering-expert.md
/refactor-plugin-component agents/client-expert.md
```

### Claude's Analysis

```
## Domain Overlap Detected

**Agents**: rendering-expert, client-expert
**Overlap**: Both handle rendering
**Confusion Points**:
- GUI screens (which agent?)
- Particle effects (which agent?)
- Audio (which agent?)

**Recommendation**: Merge into single agent with clear scope
```

### Refactoring Plan

**Option A**: Merge agents
```yaml
# agents/rendering-and-client-expert.md
name: rendering-and-client-expert
description: Expert in GUI screens, rendering, particles, audio, models, textures. Use PROACTIVELY for client-side visual/audio features.
```

**Option B**: Split by technical vs content
```yaml
# agents/rendering-engine-expert.md
name: rendering-engine-expert
description: Expert in low-level rendering (shaders, render types, custom rendering). Use PROACTIVELY for advanced rendering techniques.

# agents/client-content-expert.md
name: client-content-expert
description: Expert in GUI screens, particle effects, audio playback, client events. Use PROACTIVELY for user-facing client features.
```

### Updated Orchestrator Delegation Guide

```markdown
## Delegation Guide

### Rendering & Client Features
- **GUI Screens** → rendering-and-client-expert
- **Custom rendering** → rendering-and-client-expert
- **Particles** → rendering-and-client-expert
- **Audio playback** → rendering-and-client-expert
- **Client events (non-rendering)** → events-and-lifecycle-expert
  - Example: Client tick for network sync → events-expert
  - Example: Client tick for UI updates → rendering-and-client-expert
```

### Result

- Clear domain boundaries
- No more user confusion
- Orchestrator can delegate correctly
- Edge cases explicitly documented

## Example 5: Updating Outdated Code Examples

### Before

```markdown
# agents/registry-expert.md (written for Forge 1.18)

## Item Registration

```java
// Forge 1.18 pattern
@ObjectHolder("modid:custom_item")
public static Item CUSTOM_ITEM;

@SubscribeEvent
public static void onRegisterItems(RegistryEvent.Register<Item> event) {
    event.getRegistry().register(new Item(new Item.Properties())
        .setRegistryName("modid", "custom_item"));
}
```
```

### Command

```bash
/refactor-plugin-component agents/registry-expert.md
```

### Claude's Analysis

```
## Outdated Pattern Detected

**Pattern**: @ObjectHolder with RegistryEvent.Register
**Current Version**: Forge 1.18.x
**Target Version**: Forge 1.20.1+ (from user's projects)
**Status**: DEPRECATED

**Recommendation**: Update to DeferredRegister pattern
**Migration Path**: Replace @ObjectHolder + RegistryEvent with DeferredRegister
```

### After Refactoring

```markdown
# agents/registry-expert.md

## Item Registration

**Forge 1.20.1+ (Current)**:
```java
// Modern DeferredRegister pattern
// Example from MusicMod (Forge 1.20.1)
// Source: qingyi.thefatrat.registry.ItemRegistry:15

public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MOD_ID);

public static final RegistryObject<Item> CUSTOM_ITEM = ITEMS.register(
    "custom_item",
    () -> new Item(new Item.Properties())
);

// In mod constructor:
ITEMS.register(FMLJavaModLoadingContext.get().getModEventBus());
```

**Migration from Forge 1.18**:
```java
// OLD (1.18): @ObjectHolder + RegistryEvent
@ObjectHolder("modid:custom_item")
public static Item CUSTOM_ITEM;

// NEW (1.20+): DeferredRegister + RegistryObject
public static final RegistryObject<Item> CUSTOM_ITEM = ITEMS.register("custom_item", ...);
```

**Why DeferredRegister**:
- Type-safe registration
- No timing issues
- Lazy initialization
- Consistent across all registry types
```

### Result

- Updated to current Forge APIs
- Migration guide for users upgrading from 1.18
- Explanation of benefits
- Real example from user's project

## Lessons Learned

### 1. YAML Frontmatter is Critical

Invalid YAML prevents plugin loading. Always validate:
- Required fields present
- Proper formatting (comma-space for lists)
- Kebab-case naming
- No special characters unquoted

### 2. Progressive Loading Saves Tokens

For skills > 400 lines:
- Main file: Overview + common patterns (~200 lines)
- Supporting files: Advanced topics (load on-demand)
- Result: 50-75% token reduction

### 3. Real Code > Pseudocode

Pseudocode leads to hallucinations. Real code from user projects:
- Provides concrete patterns
- Shows actual imports and structure
- Prevents guessing/errors
- Builds trust

### 4. Clear Domain Boundaries Prevent Confusion

When agents overlap:
- Users don't know which to use
- Orchestrator delegates incorrectly
- Work gets duplicated

Solution: Merge or clearly differentiate with explicit edge cases.

### 5. Keywords Enable Auto-Loading

Vague descriptions prevent skill auto-loading. Include:
- API names (@SubscribeEvent, DeferredRegister)
- Event types (PlayerEvent, EntityEvent)
- Concepts (event bus, tick handlers)

Test: Ask questions using those keywords, verify skill loads.

## Next Steps

After refactoring:

1. **Test the component**
   ```bash
   # Restart Claude Code
   # Test agent invocation or skill auto-loading
   ```

2. **Update related components**
   - Orchestrator delegation guide
   - CLAUDE.md agent selection table
   - Cross-references in other agents/skills

3. **Commit changes**
   ```bash
   git add <refactored-files>
   git commit -m "Refactor: <component> - <improvements>"
   ```

4. **Document in CHANGELOG.md**
   ```markdown
   ## [Version] - Date
   ### Changed
   - Refactored <component>: <improvements>
   ```

5. **Monitor usage**
   - Test with real tasks
   - Verify auto-invocation works
   - Gather user feedback
   - Iterate if needed
