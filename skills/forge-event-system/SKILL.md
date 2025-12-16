---
name: forge-event-system
description: Forge and NeoForge event system reference including @SubscribeEvent, MOD vs FORGE bus, event priority, cancellation, and tick handlers. Use when implementing event handlers, tick logic, player join/leave events, or mod lifecycle hooks. Covers Forge 1.19-1.20 and NeoForge 1.20-1.21.
allowed-tools: Read, Grep, Glob
---

# Forge Event System

## What This Covers

- Event bus architecture (@SubscribeEvent)
- MOD bus vs FORGE bus distinction
- Event handler registration
- Common event patterns from real mods
- Tick handlers (Client, Server, Player, Level)
- Side-specific event handling

## When to Use

- Implementing gameplay hooks (block break, player join, etc.)
- Creating tick-based logic
- Responding to mod lifecycle events
- Listening to Minecraft game events
- Synchronizing client-server state
- Troubleshooting "event not firing" issues

---

## Core Concepts (Quick Reference)

### Two Event Buses

**MOD Bus** (`IEventBus` from mod constructor):
- Mod lifecycle events (setup, config load)
- Registry events (items, blocks, entities)
- Fires during mod loading phase

**FORGE Bus** (`MinecraftForge.EVENT_BUS`):
- Game events (player tick, block break, entity spawn)
- Fires during gameplay

### Bus Selection Table

| Event Category | Bus |
|---------------|-----|
| Registry (items, blocks) | MOD |
| Mod setup (common, client) | MOD |
| Capability registration | MOD |
| Player actions (break, interact) | FORGE |
| Entity events (spawn, death) | FORGE |
| Tick handlers | FORGE |
| World events (load, save) | FORGE |

---

## Event Handler Registration

### Automatic Registration (Recommended)

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Mod.EventBusSubscriber.Bus.FORGE)
public class ForgeEvents {

    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
        // Handler logic (MUST be static)
    }
}
```

**Key Points**:
- Use `@Mod.EventBusSubscriber` annotation on class
- Specify `bus` parameter (MOD or FORGE)
- Event handler methods MUST be `static`
- Automatically registered at startup

### Manual Registration

```java
@Mod(MODID)
public class MyMod {
    public MyMod(IEventBus modEventBus) {
        // MOD bus listener
        modEventBus.addListener(this::onCommonSetup);

        // FORGE bus listener
        MinecraftForge.EVENT_BUS.register(new ForgeEventHandler());
    }
}
```

---

## Common Event Patterns

### Pattern 1: Server Tick Handler

**From Apocalypse_TNT** (NeoForge):

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Mod.EventBusSubscriber.Bus.FORGE)
public class ForgeEvents {

    @SubscribeEvent
    public static void onServerTick(TickEvent.ServerTickEvent event) {
        if (event.phase == TickEvent.Phase.END) {
            MinecraftServer server = ServerLifecycleHooks.getCurrentServer();
            if (server != null) {
                // Delegate to orchestrator
                ApocalypseOrchestrator.getInstance().tick(server);
            }
        }
    }
}
```

**Key Techniques**:
- `event.phase == TickEvent.Phase.END` - Runs after game logic updates
- Runs every server tick (20 times per second)
- Delegate heavy work to manager/orchestrator classes

### Pattern 2: Client Tick Handler

**From MusicMod** (Forge 1.20.1):

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Mod.EventBusSubscriber.Bus.FORGE, value = Dist.CLIENT)
public class ClientForgeEvents {

    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
        if (event.side.isClient() && event.phase == TickEvent.Phase.END) {
            // Check if game is paused
            if (Minecraft.getInstance().isPaused()) {
                MusicService.getInstance().pauseCustomPlayer();
            }

            // Other client-side per-tick logic
            MusicService.getInstance().tickMusicPlayback();
        }
    }
}
```

**Key Techniques**:
- `value = Dist.CLIENT` - Class only loads on client
- `event.side.isClient()` - Runtime client check
- Use for UI updates, client state management, audio control

### Pattern 3: Player Join/Leave Events

**From Apocalypse_TNT**:

```java
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    if (event.getEntity() instanceof ServerPlayer serverPlayer) {
        // Add player to boss bar
        ApocalypseOrchestrator.getInstance().onPlayerLogin(
            serverPlayer,
            serverPlayer.server
        );
    }
}

@SubscribeEvent
public static void onPlayerLeave(PlayerEvent.PlayerLoggedOutEvent event) {
    if (event.getEntity() instanceof ServerPlayer serverPlayer) {
        // Remove from tracking lists
        BossBarHelper.removePlayer(serverPlayer);
    }
}
```

**Key Techniques**:
- `instanceof ServerPlayer` - Type-safe server player check
- Only fires on logical server side
- Use for initializing/cleaning up player state

### Pattern 4: Block Break Event

**From MusicMod**:

```java
@SubscribeEvent
public static void onBreakLog(BlockEvent.BreakEvent event) {
    Player player = event.getPlayer();
    BlockState state = event.getState();

    if (!player.level().isClientSide) {
        // Server-side validation
        if (state.is(BlockTags.LOGS)) {
            // Grant advancement or trigger music
            AdvancementHelper.grantAdvancement(player, "break_log");
        }
    }
}
```

**Cancellation Example**:
```java
@SubscribeEvent
public static void onBreakBlock(BlockEvent.BreakEvent event) {
    if (shouldPreventBreak(event.getState())) {
        event.setCanceled(true); // Prevent block from breaking
    }
}
```

---

## Tick Event Types (Quick Reference)

### Server Tick
- **When**: Every server game tick (20 TPS)
- **Use**: World state updates, game logic
- **Event**: `TickEvent.ServerTickEvent`

### Client Tick
- **When**: Every client game tick
- **Use**: Client state, UI updates, input handling
- **Event**: `TickEvent.ClientTickEvent`

### Player Tick
- **When**: For each player, every tick
- **Use**: Per-player logic, capability updates
- **Event**: `TickEvent.PlayerTickEvent`

### Level Tick
- **When**: For each loaded level (dimension), every tick
- **Use**: Per-dimension logic, weather control
- **Event**: `TickEvent.LevelTickEvent`

**For complete tick patterns**: See [tick-handlers-guide.md](./tick-handlers-guide.md)

---

## Side-Specific Event Handling

### Client-Only Events

**Method 1: Annotation** (Recommended):
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE, value = Dist.CLIENT)
public class ClientEvents {
    @SubscribeEvent
    public static void onRenderOverlay(RenderGuiOverlayEvent.Pre event) {
        // Client-only rendering
    }
}
```

**Method 2: Runtime Check**:
```java
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    if (event.side.isClient()) {
        // Client-side logic
    }
}
```

### Server-Only Events

**Runtime Check**:
```java
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    if (!event.getPlayer().level().isClientSide) {
        // Server-side logic only
    }
}
```

---

## Best Practices

### 1. Always Check Event Phase
```java
// ✅ Good - runs once per tick
if (event.phase == TickEvent.Phase.END) { }

// ❌ Bad - runs twice (START and END)
// No phase check
```

### 2. Check Side for Client/Server Code
```java
// ✅ Good
if (event.side.isClient()) {
    // Client rendering, sounds
}

// ❌ Bad - crashes dedicated server
Minecraft.getInstance().player; // Client-only API
```

### 3. Use Static Methods for @EventBusSubscriber
```java
// ✅ Good
@Mod.EventBusSubscriber(...)
public class Events {
    @SubscribeEvent
    public static void onEvent(...) { }
}

// ❌ Bad - requires instance registration
@SubscribeEvent
public void onEvent(...) { } // Non-static
```

### 4. Respect Event Cancellation
```java
// ✅ Good
if (event.isCanceled()) return;

// ❌ Bad - ignores other mods
// No cancellation check
```

---

## Common Pitfalls

### ❌ Wrong Bus for Event Type
```java
// ❌ Player events on MOD bus (won't fire)
@Mod.EventBusSubscriber(bus = Bus.MOD)
public class Events {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) { }
}

// ✅ Use FORGE bus
@Mod.EventBusSubscriber(bus = Bus.FORGE)
```

### ❌ Client Code on Dedicated Server
```java
// ❌ Crashes dedicated server
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    Minecraft mc = Minecraft.getInstance(); // CLIENT-ONLY
}

// ✅ Check side first
if (event.side.isClient()) {
    Minecraft mc = Minecraft.getInstance();
}
```

### ❌ Heavy Operations Every Tick
```java
// ❌ Lags server
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    scanAllChunksForBlocks(); // VERY EXPENSIVE
}

// ✅ Throttle
private static int tickCounter = 0;

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        if (++tickCounter >= 20) { // Once per second
            tickCounter = 0;
            scanNearbyChunks();
        }
    }
}
```

---

## Supporting Documentation

### Detailed Guides
- [Event Catalog](./event-catalog.md) - Complete list of common Forge/NeoForge events
- [Event Priorities and Cancellation](./event-priorities-and-cancellation.md) - Priority levels, execution order, cancellation patterns
- [Tick Handlers Guide](./tick-handlers-guide.md) - All tick types with optimization strategies
- [Performance Optimization](./performance-optimization.md) - Throttling, early exit patterns, profiling
- [Troubleshooting Guide](./troubleshooting.md) - Anti-patterns, "event not firing" issues, debugging
- [Framework Comparison](./framework-comparison.md) - Forge vs NeoForge event system differences

---

## Quick Decision Tree

**Need to run code every tick?**
→ Use Tick Events (Server/Client/Player/Level)

**Need to react to player actions?**
→ Use Player Events (FORGE bus)

**Need to modify block/entity behavior?**
→ Use Block/Entity Events (FORGE bus, check if cancellable)

**Need to register capabilities/commands?**
→ Use MOD bus lifecycle events

**Need mod initialization?**
→ Use FMLCommonSetupEvent / FMLClientSetupEvent (MOD bus)

---

Use this skill when implementing any event-driven functionality in Forge or NeoForge mods to ensure correct bus selection, proper side handling, and performance-optimized patterns.
