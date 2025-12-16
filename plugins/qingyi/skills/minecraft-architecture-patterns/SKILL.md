---
name: minecraft-architecture-patterns
description: Architectural design patterns for Minecraft mods including client/server separation, registry organization, event-driven architecture, data persistence strategies, and multi-loader abstraction. Use when reviewing architecture, designing systems, or identifying architectural smells.
---

# Minecraft Architecture Patterns

## Overview

This skill provides architectural patterns and design principles specific to Minecraft mod development, covering both single-loader and multi-loader projects across Forge, NeoForge, and Fabric frameworks.

## When to Use This Skill

- Designing new mod architecture from scratch
- Reviewing existing mod structure for improvements
- Refactoring for better separation of concerns
- Implementing multi-loader support
- Identifying and fixing architectural smells

---

## Core Architectural Principles

### 1. Client/Server Separation (CRITICAL)

**Principle**: Code must be aware of whether it runs on client, server, or both.

**Why**: Minecraft has three environments:
- **Integrated Server**: Singleplayer (client + server in same JVM)
- **Dedicated Server**: Multiplayer server (no client code)
- **Client**: Client-side only (rendering, input, UI)

**Rule**: **Never use client classes in common/server code** → Crashes dedicated servers

**Architecture Pattern**:
```
src/main/java/
├── common/           ← Runs on both sides (most game logic)
├── client/           ← Client-only (rendering, GUIs, key bindings)
└── server/           ← Server-only (rare, most logic is common)
```

**For complete guide**: See [client-server-architecture.md](./client-server-architecture.md)

### 2. Registry Organization

**Centralized Registry Pattern**:
```
com.mod/
├── init/                    # Registry classes
│   ├── ModItems.java        # All items
│   ├── ModBlocks.java       # All blocks
│   ├── ModEntities.java     # All entities
│   └── ModSounds.java       # All sounds
└── content/                 # Implementations
    ├── items/
    ├── blocks/
    └── entities/
```

**For complete patterns**: See [registry-organization.md](./registry-organization.md)

### 3. Event-Driven Architecture

**Pattern**: Use events for loose coupling between systems

**Forge/NeoForge**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class GameplayEvents {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
        // React to game events
    }
}
```

**Fabric**:
```java
public class ModInitializer implements ModInitializer {
    @Override
    public void onInitialize() {
        ServerTickEvents.START_SERVER_TICK.register(server -> {
            // React to server tick
        });
    }
}
```

**For complete patterns**: See [event-architecture.md](./event-architecture.md)

### 4. Data Persistence Strategies

**Approaches**:
- **SavedData**: World-level persistence (global state)
- **Capabilities** (Forge): Attach data to entities/items/blocks
- **Components** (Fabric): Attach data to entities/items/blocks
- **NBT**: Serialize custom data structures

**For complete guide**: See [data-persistence-patterns.md](./data-persistence-patterns.md)

### 5. Multi-Loader Abstraction

**Architectury Pattern** (Common + Platform-specific):
```
common/               # Platform-agnostic code
├── src/main/java/
│   └── com.mod/
│       ├── Platform.java         # Abstract interface
│       └── CommonMod.java        # Shared logic

forge/                # Forge implementation
├── src/main/java/
│   └── com.mod/
│       ├── forge/
│       │   └── PlatformImpl.java # Forge-specific
│       └── ForgeModEntrypoint.java

fabric/               # Fabric implementation
├── src/main/java/
│   └── com.mod/
│       ├── fabric/
│       │   └── PlatformImpl.java # Fabric-specific
│       └── FabricModInitializer.java
```

**For complete guide**: See [multi-loader-architecture.md](./multi-loader-architecture.md)

---

## Common Architectural Patterns

### Pattern 1: Layered Architecture

```
Presentation Layer (Client)
├── Screens, Renderers, Input Handlers

Logic Layer (Common)
├── Game Mechanics, Business Logic, Utilities

Data Layer (Common)
├── Registry, Data Structures, Persistence

Platform Layer (Loader-specific)
└── Framework Integration, Platform Abstractions
```

### Pattern 2: Service Locator

```java
// Centralized access to services
public class ModServices {
    private static final MusicService MUSIC = new MusicService();
    private static final ConfigService CONFIG = new ConfigService();

    public static MusicService music() { return MUSIC; }
    public static ConfigService config() { return CONFIG; }
}

// Usage
ModServices.music().play(song);
```

### Pattern 3: Manager Classes

```java
// Coordinate related functionality
public class TNTWaveManager {
    private final List<TNTWave> activeWaves = new ArrayList<>();

    public void startWave(MinecraftServer server) { }
    public void updateWaves(MinecraftServer server) { }
    public void stopAllWaves() { }
}
```

**For more patterns**: See [design-patterns.md](./design-patterns.md)

---

## Architectural Smells

### Smell 1: God Class
**Problem**: One class doing too much
```java
// BAD: ModItems also handles registration, recipes, rendering
public class ModItems {
    // 2000+ lines mixing concerns
}
```

**Fix**: Separate concerns
```java
public class ModItems { }           // Registry only
public class ItemRecipes { }        // Recipe generation
public class ItemRenderers { }      // Client rendering
```

### Smell 2: Circular Dependencies
**Problem**: A depends on B, B depends on A
**Fix**: Extract interface or use events

### Smell 3: Client Code in Common
**Problem**: Crashes dedicated servers
**Fix**: Move to client/ package, use side checks

**For complete list**: See [architectural-smells.md](./architectural-smells.md)

---

## Framework-Specific Architectures

### Forge/NeoForge Best Practices
- DeferredRegister for all registrations
- Event bus subscribers for gameplay hooks
- Capabilities for entity/item data attachment
- Config API for mod configuration
- Sided proxies for client/server separation (legacy)

### Fabric Best Practices
- Registry.register for registrations
- Callback events for gameplay hooks
- Components for entity/item data attachment
- AutoConfig for mod configuration
- Entrypoint separation for client/server

**For detailed comparison**: See [framework-architectures.md](./framework-architectures.md)

---

## Best Practices

### Code Organization
1. **Package by feature** > Package by type
2. **Centralize registrations** in init/ package
3. **Separate client code** physically
4. **Keep classes focused** (single responsibility)
5. **Use managers** for complex systems

### Dependency Management
1. **Depend on abstractions** not implementations
2. **Minimize coupling** between modules
3. **Use events** for cross-module communication
4. **Inject dependencies** via constructors

### Performance Considerations
1. **Cache expensive operations**
2. **Use thread-safe collections** for shared data
3. **Avoid blocking main thread** (networking, I/O)
4. **Lazy-load resources** when possible

---

## Decision Framework

### When to Split a Class?
- Exceeds 500 lines
- Handles multiple unrelated responsibilities
- Has multiple reasons to change

### When to Extract an Interface?
- Multiple implementations exist/planned
- Need to break circular dependency
- Want to mock for testing

### When to Use Events?
- Loose coupling desired
- Many listeners potential
- Cross-module communication needed

**For complete decision framework**: See [architecture-decisions.md](./architecture-decisions.md)

---

## Supporting Documentation

### Detailed Guides
- [Client-Server Architecture](./client-server-architecture.md) - Complete separation patterns
- [Registry Organization](./registry-organization.md) - Organizing mod content
- [Event Architecture](./event-architecture.md) - Event-driven design patterns
- [Data Persistence Patterns](./data-persistence-patterns.md) - SavedData, Capabilities, Components
- [Multi-Loader Architecture](./multi-loader-architecture.md) - Cross-platform mod design
- [Design Patterns](./design-patterns.md) - Common patterns for Minecraft mods
- [Architectural Smells](./architectural-smells.md) - Anti-patterns and how to fix them
- [Framework Architectures](./framework-architectures.md) - Forge vs Fabric architecture comparison
- [Architecture Decisions](./architecture-decisions.md) - Decision framework for design choices

---

Use this skill when designing or reviewing mod architecture to ensure maintainable, scalable, and framework-appropriate designs.
