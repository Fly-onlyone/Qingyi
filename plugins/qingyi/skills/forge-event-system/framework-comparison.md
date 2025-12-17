# Framework Comparison - Event Systems Across Forge, NeoForge, and Fabric

This guide compares event handling approaches across major modding frameworks: Forge, NeoForge, and Fabric.

## Overview

**Purpose**: Understand differences between framework event systems for multi-loader development or migration.

**Frameworks Covered**:
- Forge 1.19-1.20
- NeoForge 1.20-1.21
- Fabric 1.19-1.21

---

## Table of Contents

1. [Architecture Comparison](#architecture-comparison)
2. [Event Registration Patterns](#event-registration-patterns)
3. [Common Events Comparison](#common-events-comparison)
4. [Migration Guide](#migration-guide)
5. [Multi-Loader Patterns](#multi-loader-patterns)

---

## Architecture Comparison

### Forge/NeoForge Architecture

**Event Bus System**:
- Annotation-based (`@SubscribeEvent`)
- Two buses: MOD and FORGE
- Priority system (HIGHEST ’ LOWEST)
- Cancellable events
- Phase-aware (START/END for tick events)

**Registration**:
```java
// Automatic
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class Events {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) { }
}

// Manual
MinecraftForge.EVENT_BUS.register(new Events());
```

---

### Fabric Architecture

**Callback System**:
- Functional interface-based
- No annotation system
- Single event registration point
- Phases (priorities) support
- No built-in cancellation (uses ActionResult)

**Registration**:
```java
ServerTickEvents.END_SERVER_TICK.register(server -> {
    // Server tick logic
});

ServerPlayConnectionEvents.JOIN.register((handler, sender, server) -> {
    // Player join logic
});
```

---

### Key Differences

| Feature | Forge/NeoForge | Fabric |
|---------|----------------|--------|
| Style | Annotation-based | Callback-based |
| Event buses | 2 (MOD, FORGE) | 1 (per event type) |
| Cancellation | `event.setCanceled(true)` | Return `ActionResult` |
| Priority | 5 levels (HIGHEST-LOWEST) | Named phases (custom) |
| Registration | Class or instance | Lambda or method reference |
| Tick events | Combined (PlayerTickEvent) | Separate (START/END) |

---

## Event Registration Patterns

### Pattern 1: Server Tick Handler

**Forge/NeoForge**:

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class ForgeEvents {
    @SubscribeEvent
    public static void onServerTick(TickEvent.ServerTickEvent event) {
        if (event.phase == TickEvent.Phase.END) {
            MinecraftServer server = ServerLifecycleHooks.getCurrentServer();
            if (server != null) {
                // Tick logic
            }
        }
    }
}
```

**Fabric**:

```java
public class FabricEvents {
    public static void register() {
        ServerTickEvents.END_SERVER_TICK.register(server -> {
            // Tick logic (runs at END phase only)
        });
    }
}
```

**Comparison**:
- Forge: Single event with START/END phases
- Fabric: Separate events for START and END

---

### Pattern 2: Player Join Event

**Forge/NeoForge**:

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class ForgeEvents {
    @SubscribeEvent
    public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
        Player player = event.getEntity();
        // Join logic
    }
}
```

**Fabric**:

```java
public class FabricEvents {
    public static void register() {
        ServerPlayConnectionEvents.JOIN.register((handler, sender, server) -> {
            ServerPlayer player = handler.getPlayer();
            // Join logic
        });
    }
}
```

**Comparison**:
- Forge: `PlayerEvent.PlayerLoggedInEvent`
- Fabric: `ServerPlayConnectionEvents.JOIN`
- Different event data access patterns

---

### Pattern 3: Block Break Event

**Forge/NeoForge**:

```java
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    if (event.isCanceled()) return;

    Player player = event.getPlayer();
    BlockState state = event.getState();
    Level level = (Level) event.getLevel();

    if (shouldPrevent) {
        event.setCanceled(true);  // Prevent break
    }
}
```

**Fabric**:

```java
PlayerBlockBreakEvents.BEFORE.register((world, player, pos, state, blockEntity) -> {
    if (shouldPrevent) {
        return false;  // Prevent break
    }
    return true;  // Allow break
});
```

**Comparison**:
- Forge: Event cancellation via `setCanceled()`
- Fabric: Boolean return value (true = allow, false = prevent)

---

### Pattern 4: Client Tick Handler

**Forge/NeoForge**:

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE, value = Dist.CLIENT)
public class ClientEvents {
    @SubscribeEvent
    public static void onClientTick(TickEvent.ClientTickEvent event) {
        if (event.phase == TickEvent.Phase.END) {
            Minecraft mc = Minecraft.getInstance();
            // Client logic
        }
    }
}
```

**Fabric**:

```java
@Environment(EnvType.CLIENT)
public class ClientEvents {
    public static void register() {
        ClientTickEvents.END_CLIENT_TICK.register(client -> {
            // Client logic
        });
    }
}
```

**Comparison**:
- Forge: `@Mod.EventBusSubscriber(value = Dist.CLIENT)`
- Fabric: `@Environment(EnvType.CLIENT)` annotation
- Both use separate classes for client-only code

---

## Common Events Comparison

### Server Tick

| Framework | Event Name | Registration |
|-----------|-----------|--------------|
| Forge/NeoForge | `TickEvent.ServerTickEvent` | `@SubscribeEvent` |
| Fabric | `ServerTickEvents.END_SERVER_TICK` | `.register(callback)` |

**Usage**:

```java
// Forge/NeoForge
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        // Logic
    }
}

// Fabric
ServerTickEvents.END_SERVER_TICK.register(server -> {
    // Logic
});
```

---

### Player Tick

| Framework | Event Name | Registration |
|-----------|-----------|--------------|
| Forge/NeoForge | `TickEvent.PlayerTickEvent` | `@SubscribeEvent` |
| Fabric | `ServerTickEvents.END_SERVER_TICK` | Manual iteration |

**Usage**:

```java
// Forge/NeoForge
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    if (event.side.isServer() && event.phase == TickEvent.Phase.END) {
        Player player = event.player;
        // Logic
    }
}

// Fabric (no dedicated player tick event)
ServerTickEvents.END_SERVER_TICK.register(server -> {
    for (ServerPlayer player : server.getPlayerList().getPlayers()) {
        // Logic per player
    }
});
```

**Note**: Fabric doesn't have a dedicated player tick event, must iterate manually.

---

### Player Join/Leave

| Framework | Join Event | Leave Event |
|-----------|-----------|-------------|
| Forge/NeoForge | `PlayerEvent.PlayerLoggedInEvent` | `PlayerEvent.PlayerLoggedOutEvent` |
| Fabric | `ServerPlayConnectionEvents.JOIN` | `ServerPlayConnectionEvents.DISCONNECT` |

**Usage**:

```java
// Forge/NeoForge - Join
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    Player player = event.getEntity();
}

// Fabric - Join
ServerPlayConnectionEvents.JOIN.register((handler, sender, server) -> {
    ServerPlayer player = handler.getPlayer();
});

// Forge/NeoForge - Leave
@SubscribeEvent
public static void onPlayerLeave(PlayerEvent.PlayerLoggedOutEvent event) {
    Player player = event.getEntity();
}

// Fabric - Leave
ServerPlayConnectionEvents.DISCONNECT.register((handler, server) -> {
    ServerPlayer player = handler.getPlayer();
});
```

---

### Block Break/Place

| Framework | Break Event | Place Event |
|-----------|------------|-------------|
| Forge/NeoForge | `BlockEvent.BreakEvent` | `BlockEvent.EntityPlaceEvent` |
| Fabric | `PlayerBlockBreakEvents.BEFORE` | `UseBlockCallback` |

**Usage**:

```java
// Forge/NeoForge - Break
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    if (shouldPrevent) {
        event.setCanceled(true);
    }
}

// Fabric - Break
PlayerBlockBreakEvents.BEFORE.register((world, player, pos, state, blockEntity) -> {
    if (shouldPrevent) {
        return false;  // Prevent
    }
    return true;  // Allow
});

// Forge/NeoForge - Place
@SubscribeEvent
public static void onBlockPlace(BlockEvent.EntityPlaceEvent event) {
    if (shouldPrevent) {
        event.setCanceled(true);
    }
}

// Fabric - Place
UseBlockCallback.EVENT.register((player, world, hand, hitResult) -> {
    if (shouldPrevent) {
        return ActionResult.FAIL;  // Prevent
    }
    return ActionResult.PASS;  // Continue
});
```

---

## Migration Guide

### Forge ’ NeoForge

**Good news**: Almost identical!

**Changes needed** (minimal):

1. **Package changes** (1.20.2+):
```java
// Forge 1.19-1.20.1
import net.minecraftforge.event.TickEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;

// NeoForge 1.20.2+
import net.neoforged.neoforge.event.TickEvent;
import net.neoforged.bus.api.SubscribeEvent;
```

2. **Bus registration** (minor):
```java
// Forge
MinecraftForge.EVENT_BUS.register(handler);

// NeoForge
NeoForge.EVENT_BUS.register(handler);
```

3. **Event names** (mostly same):
- Most events unchanged
- Some deprecated events removed
- Check NeoForge changelog for specifics

**Example migration**:

```java
// Forge 1.20.1
import net.minecraftforge.event.TickEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.common.MinecraftForge;

@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class ForgeEvents {
    @SubscribeEvent
    public static void onServerTick(TickEvent.ServerTickEvent event) { }
}

// NeoForge 1.20.2+
import net.neoforged.neoforge.event.TickEvent;
import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.neoforge.common.NeoForge;

@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)  // Annotation unchanged
public class NeoForgeEvents {
    @SubscribeEvent
    public static void onServerTick(TickEvent.ServerTickEvent event) { }
}
```

**Time to migrate**: 10-30 minutes (mostly search-and-replace)

---

### Forge/NeoForge ’ Fabric

**More involved**: Different architecture.

**Strategy**: Common abstraction layer.

**Pattern**:

```
Project structure:
common/        (Shared logic)
forge/         (Forge-specific event registration)
fabric/        (Fabric-specific event registration)
```

**Example**:

```java
// common/CommonEvents.java
public class CommonEvents {
    public static void onServerTick(MinecraftServer server) {
        // Shared logic
    }

    public static void onPlayerJoin(ServerPlayer player) {
        // Shared logic
    }
}

// forge/ForgeEvents.java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class ForgeEvents {
    @SubscribeEvent
    public static void onServerTick(TickEvent.ServerTickEvent event) {
        if (event.phase == TickEvent.Phase.END) {
            MinecraftServer server = ServerLifecycleHooks.getCurrentServer();
            if (server != null) {
                CommonEvents.onServerTick(server);  // Delegate
            }
        }
    }

    @SubscribeEvent
    public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
        CommonEvents.onPlayerJoin((ServerPlayer) event.getEntity());
    }
}

// fabric/FabricEvents.java
public class FabricEvents {
    public static void register() {
        ServerTickEvents.END_SERVER_TICK.register(server -> {
            CommonEvents.onServerTick(server);  // Delegate
        });

        ServerPlayConnectionEvents.JOIN.register((handler, sender, server) -> {
            CommonEvents.onPlayerJoin(handler.getPlayer());
        });
    }
}
```

**Benefits**:
-  Shared logic in common module
-  Platform-specific event registration only
-  Minimal code duplication

**Time to migrate**: 1-3 days for full project

---

## Multi-Loader Patterns

### Pattern 1: Abstract Event Handler

**Common module**:

```java
// common/IEventHandler.java
public interface IEventHandler {
    void registerEvents();
    void onServerTick(MinecraftServer server);
    void onPlayerJoin(ServerPlayer player);
}

// common/GameLogic.java
public class GameLogic {
    public static void handleServerTick(MinecraftServer server) {
        // Shared logic
    }

    public static void handlePlayerJoin(ServerPlayer player) {
        // Shared logic
    }
}
```

**Forge implementation**:

```java
// forge/ForgeEventHandler.java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class ForgeEventHandler implements IEventHandler {

    @Override
    public void registerEvents() {
        // Automatic via annotation
    }

    @SubscribeEvent
    public static void onServerTick(TickEvent.ServerTickEvent event) {
        if (event.phase == TickEvent.Phase.END) {
            MinecraftServer server = ServerLifecycleHooks.getCurrentServer();
            if (server != null) {
                GameLogic.handleServerTick(server);
            }
        }
    }

    @SubscribeEvent
    public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
        GameLogic.handlePlayerJoin((ServerPlayer) event.getEntity());
    }
}
```

**Fabric implementation**:

```java
// fabric/FabricEventHandler.java
public class FabricEventHandler implements IEventHandler {

    @Override
    public void registerEvents() {
        ServerTickEvents.END_SERVER_TICK.register(server -> {
            GameLogic.handleServerTick(server);
        });

        ServerPlayConnectionEvents.JOIN.register((handler, sender, server) -> {
            GameLogic.handlePlayerJoin(handler.getPlayer());
        });
    }
}
```

---

### Pattern 2: Service Loader Pattern

**Use when**: Multiple platforms with different implementations.

**Common module**:

```java
// common/IPlatformEventService.java
public interface IPlatformEventService {
    void registerServerTickHandler(Consumer<MinecraftServer> handler);
    void registerPlayerJoinHandler(Consumer<ServerPlayer> handler);
}

// common/EventRegistry.java
public class EventRegistry {
    private static IPlatformEventService service;

    public static void init(IPlatformEventService platformService) {
        service = platformService;

        service.registerServerTickHandler(GameLogic::handleServerTick);
        service.registerPlayerJoinHandler(GameLogic::handlePlayerJoin);
    }
}
```

**Forge implementation**:

```java
// forge/ForgePlatformEventService.java
public class ForgePlatformEventService implements IPlatformEventService {

    @Override
    public void registerServerTickHandler(Consumer<MinecraftServer> handler) {
        MinecraftForge.EVENT_BUS.addListener((TickEvent.ServerTickEvent event) -> {
            if (event.phase == TickEvent.Phase.END) {
                MinecraftServer server = ServerLifecycleHooks.getCurrentServer();
                if (server != null) {
                    handler.accept(server);
                }
            }
        });
    }

    @Override
    public void registerPlayerJoinHandler(Consumer<ServerPlayer> handler) {
        MinecraftForge.EVENT_BUS.addListener((PlayerEvent.PlayerLoggedInEvent event) -> {
            handler.accept((ServerPlayer) event.getEntity());
        });
    }
}

// forge/ForgeModInitializer.java
@Mod(MODID)
public class ForgeModInitializer {
    public ForgeModInitializer() {
        EventRegistry.init(new ForgePlatformEventService());
    }
}
```

**Fabric implementation**:

```java
// fabric/FabricPlatformEventService.java
public class FabricPlatformEventService implements IPlatformEventService {

    @Override
    public void registerServerTickHandler(Consumer<MinecraftServer> handler) {
        ServerTickEvents.END_SERVER_TICK.register(handler::accept);
    }

    @Override
    public void registerPlayerJoinHandler(Consumer<ServerPlayer> handler) {
        ServerPlayConnectionEvents.JOIN.register((h, sender, server) -> {
            handler.accept(h.getPlayer());
        });
    }
}

// fabric/FabricModInitializer.java
public class FabricModInitializer implements ModInitializer {
    @Override
    public void onInitialize() {
        EventRegistry.init(new FabricPlatformEventService());
    }
}
```

**Benefits**:
-  Clean separation of concerns
-  Platform-agnostic common code
-  Easy to add more platforms
-  Type-safe event registration

---

## Quick Reference

### Event Name Mapping

| Forge/NeoForge | Fabric | Description |
|----------------|--------|-------------|
| `TickEvent.ServerTickEvent` | `ServerTickEvents.END_SERVER_TICK` | Server tick |
| `TickEvent.ClientTickEvent` | `ClientTickEvents.END_CLIENT_TICK` | Client tick |
| `PlayerEvent.PlayerLoggedInEvent` | `ServerPlayConnectionEvents.JOIN` | Player join |
| `PlayerEvent.PlayerLoggedOutEvent` | `ServerPlayConnectionEvents.DISCONNECT` | Player leave |
| `BlockEvent.BreakEvent` | `PlayerBlockBreakEvents.BEFORE` | Block break |
| `BlockEvent.EntityPlaceEvent` | `UseBlockCallback.EVENT` | Block place |
| `LivingDeathEvent` | `ServerLivingEntityEvents.AFTER_DEATH` | Entity death |
| `AttackEntityEvent` | `AttackEntityCallback.EVENT` | Entity attack |

---

## Related Documentation

- [Event Catalog](./event-catalog.md) - All Forge events
- [Performance Optimization](./performance-optimization.md) - Performance tips
- [Troubleshooting](./troubleshooting.md) - Common issues

Back to [SKILL.md](./SKILL.md)
