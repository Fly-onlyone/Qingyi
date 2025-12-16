---
name: minecraft-documentation-patterns
description: Comprehensive documentation patterns for Minecraft mods including registry documentation, event handler API docs, mixin documentation, and multi-loader guides. Use when generating mod documentation, API references, or architectural guides for Forge, NeoForge, Fabric frameworks.
---

# Minecraft Documentation Patterns

## Overview

This skill provides structured patterns for creating comprehensive technical documentation for Minecraft mods, covering all major frameworks (Forge, NeoForge, Fabric/Quilt) and common mod components.

## When to Use This Skill

- Generating complete mod documentation (10-100+ pages)
- Creating API reference guides for other developers
- Documenting architectural decisions and patterns
- Writing migration guides between versions
- Creating developer onboarding materials

## Standard Minecraft Mod Documentation Structure

### 1. Overview & Setup (5-10 pages)

**Purpose**: Introduce the mod and help developers get started

**Sections**:
- Mod description and feature list
- Dependencies (Minecraft version, framework, required libraries)
- Build system configuration (Gradle setup, repositories)
- Development environment setup (IDE, run configurations)
- Quick start guide

**Example Structure**:
```markdown
# ModName Documentation

## Overview
[Brief description of what the mod does]

## Features
- Feature 1: [Description]
- Feature 2: [Description]

## Requirements
- Minecraft: 1.20.1
- Forge: 47.1.0+
- Java: 17+

## Getting Started
1. Clone the repository
2. Run `./gradlew build`
3. Import into IntelliJ IDEA
```

### 2. Architecture (10-15 pages)

**Purpose**: Explain the high-level design and organization

**Sections**:
- Package structure and organization
- Registry system architecture (how items/blocks/entities are organized)
- Event handler architecture (where events are processed)
- Client/server separation (what runs where)
- Data flow diagrams (how data moves through the system)
- Design patterns used (Singleton, Factory, Observer, etc.)

**Framework-Specific Patterns**:

**Forge/NeoForge Architecture**:
```markdown
## Package Structure
```
com.example.mymod/
├── MyMod.java              # Main mod class
├── registry/
│   ├── ModItems.java       # DeferredRegister for items
│   ├── ModBlocks.java      # DeferredRegister for blocks
│   └── ModEntities.java    # DeferredRegister for entities
├── events/
│   ├── ModEvents.java      # FORGE bus events
│   └── ModLifecycle.java   # MOD bus events
├── client/
│   └── ClientEvents.java   # Client-only code
└── data/
    └── ModData.java        # SavedData/persistence
```
```

**Fabric Architecture**:
```markdown
## Package Structure
```
com.example.mymod/
├── MyModInitializer.java   # ModInitializer entry point
├── MyModClient.java        # ClientModInitializer
├── registry/
│   ├── ModItems.java       # Registry.register calls
│   └── ModBlocks.java      # Registry.register calls
├── events/
│   └── EventHandlers.java  # Event callbacks
└── mixin/
    └── ExampleMixin.java   # Mixin modifications
```
```

### 3. Core Systems (20-40 pages)

**Purpose**: Deep dive into major systems and components

**Subsections**:

#### 3.1 Registry System Documentation

**Forge/NeoForge Pattern**:
```markdown
## Item Registration

All items are registered using `DeferredRegister` in the `ModItems` class:

```java
public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

    public static final RegistryObject<Item> RUBY = ITEMS.register("ruby",
        () -> new Item(new Item.Properties()));

    public static void register(IEventBus modEventBus) {
        ITEMS.register(modEventBus);
    }
}
```

**Why DeferredRegister?**
- Registers items at the correct lifecycle phase
- Provides type-safe RegistryObject references
- Handles registry name management automatically
```

**Fabric Pattern**:
```markdown
## Item Registration

All items are registered directly in the `ModItems` class:

```java
public class ModItems {
    public static final Item RUBY = Registry.register(
        Registries.ITEM,
        new Identifier(MODID, "ruby"),
        new Item(new Item.Settings())
    );

    public static void register() {
        // Items are registered inline above
    }
}
```

**Why Direct Registration?**
- Simpler than deferred systems
- Registers immediately during initialization
- Uses Identifier for namespaced registry names
```

#### 3.2 Event System Documentation

See [Event Handler Documentation](./event-handler-docs.md) for detailed event patterns.

#### 3.3 Data Persistence Documentation

**NBT Serialization**:
```markdown
## Saving Custom Data

Items can store custom data using NBT tags:

```java
public class CustomItem extends Item {
    public static void setUsageCount(ItemStack stack, int count) {
        stack.getOrCreateTag().putInt("usage_count", count);
    }

    public static int getUsageCount(ItemStack stack) {
        return stack.getOrCreateTag().getInt("usage_count");
    }
}
```
```

### 4. Content Reference (15-30 pages)

**Purpose**: Catalog of all registered content with properties

**Format**: Table or detailed list

**Example**:
```markdown
## Items

| Registry Name | Class | Max Stack Size | Creative Tab | Notes |
|---------------|-------|----------------|--------------|-------|
| ruby | Item | 64 | Materials | Basic gem item |
| ruby_sword | SwordItem | 1 | Combat | Durability: 500 |
| music_disc_custom | RecordItem | 1 | Music | Plays custom.ogg |

## Blocks

| Registry Name | Class | Hardness | Requires Tool | Drops |
|---------------|-------|----------|---------------|-------|
| ruby_block | Block | 5.0 | Pickaxe | Self |
| ruby_ore | Block | 3.0 | Iron Pickaxe | 1-2 ruby |
```

### 5. Resource Files (5-10 pages)

**Purpose**: Document resource file structure and requirements

**Sections**:
- models/item/ - Item model JSON structure
- models/block/ - Block model JSON structure
- blockstates/ - Blockstate definitions
- textures/ - Texture atlas organization
- lang/ - Translation key reference
- recipes/ - Recipe JSON documentation
- loot_tables/ - Loot table definitions
- advancements/ - Advancement criteria

For detailed examples, see [Registry Documentation Examples](./registry-docs-examples.md)

### 6. API Documentation (10-20 pages)

**Purpose**: Document public APIs for other mods/developers

**Sections**:
- Public classes and interfaces
- Hook points for integration
- Custom events that can be listened to
- Data providers for data generation
- Example integration code

**Example**:
```markdown
## Public API: Music Playback

Other mods can integrate with the music system:

```java
// Play a custom music track
MusicAPI.playMusic(player, new ResourceLocation("mymod", "custom_track"));

// Stop current music
MusicAPI.stopMusic(player);

// Check if music is playing
boolean playing = MusicAPI.isPlaying(player);
```

**Events**: Listen to `MusicStartEvent` and `MusicStopEvent` on the FORGE bus.
```

### 7. Integration & Compatibility (5-10 pages)

**Purpose**: Document mod compatibility and integration points

**Sections**:
- Known compatible mods
- Known incompatible mods (with reasons)
- Configuration options for compatibility
- Common conflicts and solutions
- JEI/REI integration (if applicable)
- Mixin conflicts and resolutions

### 8. Performance Considerations (3-5 pages)

**Purpose**: Document performance-sensitive code and optimization strategies

**Topics**:
- Tick handler intervals (avoid every-tick operations)
- Rendering optimizations (caching, batching)
- Memory management (collection sizes, object pooling)
- Network packet efficiency
- Profiling guidance (how to profile the mod)

### 9. Appendices

**Sections**:
- Changelog (version history with breaking changes)
- Migration guides (e.g., "Migrating from 1.0 to 2.0")
- Troubleshooting common issues
- Glossary of terms
- Credits and licenses

## Framework-Specific Documentation Notes

### Forge Documentation Specifics

**Emphasize**:
- DeferredRegister pattern for all registries
- @Mod.EventBusSubscriber for events
- Capabilities for entity/item data (pre-1.21)
- ForgeConfigSpec for configuration
- Network channel setup for packets

### NeoForge Documentation Specifics

**Highlight Differences from Forge**:
- Package changes (net.minecraftforge → net.neoforged)
- Components replacing Capabilities (1.21+)
- Simplified registry APIs
- Modern data attachment system

### Fabric Documentation Specifics

**Emphasize**:
- Fabric API dependency (required for most features)
- Mixin system for vanilla modifications
- Entrypoints (ModInitializer, ClientModInitializer)
- Registry.register pattern for content
- Fabric events vs Forge event bus

## Documentation Best Practices

1. **Use Real Code Examples**: Always show actual working code, not pseudocode
2. **Specify Minecraft Versions**: Tag examples with version (e.g., "Forge 1.20.1:")
3. **Explain the Why**: Don't just show code, explain design decisions
4. **Cross-Reference**: Link related sections together
5. **Keep Updated**: Mark deprecated features, document breaking changes
6. **Show Both Approaches**: For multi-loader projects, show Forge and Fabric side-by-side

## See Also

- [Registry Documentation Examples](./registry-docs-examples.md) - Real examples from MusicMod and Apocalypse_TNT
- [Event Handler Documentation](./event-handler-docs.md) - Detailed event system patterns
- [Mixin Documentation Guide](./mixin-documentation.md) - How to document Mixin modifications

## Common Documentation Mistakes to Avoid

- ❌ Using outdated API examples (always verify current version)
- ❌ Mixing Forge and Fabric code without labeling
- ❌ Forgetting to document client/server separation
- ❌ Omitting resource file requirements
- ❌ Not explaining breaking changes in updates
- ❌ Using placeholder code instead of real implementations
