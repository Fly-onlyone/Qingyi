---
name: forge-event-system
description: Forge and NeoForge event system reference including @SubscribeEvent, MOD vs FORGE bus, event priority, cancellation, and tick handlers. Use when implementing event handlers, tick logic, player join/leave events, or mod lifecycle hooks. Covers Forge 1.19-1.20 and NeoForge 1.20-1.21.
allowed-tools: Read, Grep, Glob
---

# Forge Event System

## What This Covers

- Event bus architecture (@SubscribeEvent)
- MOD bus vs FORGE bus distinction
- Event priority and ordering
- Event cancellation
- Tick handlers (Client, Server, Player, Level)
- Common event patterns from real mods
- Side-specific event handling

## When to Use

- Implementing gameplay hooks (block break, player join, etc.)
- Creating tick-based logic
- Responding to mod lifecycle events
- Listening to Minecraft game events
- Synchronizing client-server state
- Troubleshooting "event not firing" issues

## Core Knowledge

### Event Bus System

Forge uses two separate event buses:

**MOD Bus** (`IEventBus` from mod constructor):
- Mod lifecycle events (setup, config load)
- Registry events (items, blocks, entities)
- Fires during mod loading phase

**FORGE Bus** (`MinecraftForge.EVENT_BUS`):
- Game events (player tick, block break, entity spawn)
- Fires during gameplay

### Event Handler Registration

**Automatic Registration (Recommended)**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Mod.EventBusSubscriber.Bus.FORGE)
public class ForgeEvents {

    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
        // Handler logic
    }
}
```

**Manual Registration**:
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

## Common Event Patterns

### Player Tick Handler (from MusicMod)

**Client-Side Tick**:
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

**Key Points**:
- `event.side.isClient()` - Ensures client-only execution
- `event.phase == TickEvent.Phase.END` - Runs after game logic updates
- Use for UI updates, client state management, audio control

### Server Tick Handler (from Apocalypse_TNT)

**Server-Side Tick**:
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

**Key Points**:
- Runs every server tick (20 times per second)
- Use for world state updates, game logic
- Delegate heavy work to manager/orchestrator classes
- Check phase to avoid duplicate execution

### Player Join Event (from Apocalypse_TNT)

**Player Login Handler**:
```java
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    if (event.getEntity() instanceof ServerPlayer serverPlayer) {
        // Add player to boss bar
        ApocalypseOrchestrator.getInstance().onPlayerLogin(
            serverPlayer,
            serverPlayer.server
        );

        // Send welcome packet
        PacketHandler.sendToPlayer(new WelcomePacket(), serverPlayer);
    }
}
```

**Key Points**:
- `instanceof ServerPlayer` - Type-safe server player check
- Only fires on logical server side
- Use for initializing player state, syncing data, adding to boss bars

### Player Leave Event

**Player Logout Handler**:
```java
@SubscribeEvent
public static void onPlayerLeave(PlayerEvent.PlayerLoggedOutEvent event) {
    if (event.getEntity() instanceof ServerPlayer serverPlayer) {
        // Save player data
        // Remove from tracking lists
        BossBarHelper.removePlayer(serverPlayer);
    }
}
```

### Block Break Event (from MusicMod)

**Block Interaction Handler**:
```java
@SubscribeEvent
public static void onBreakLog(BlockEvent.BreakEvent event) {
    Player player = event.getPlayer();
    BlockState state = event.getState();
    BlockPos pos = event.getPos();

    if (!player.level().isClientSide) {
        // Server-side validation
        if (state.is(BlockTags.LOGS)) {
            // Grant advancement or trigger music
            AdvancementHelper.grantAdvancement(player, "break_log");
        }
    }
}
```

**Cancellation**:
```java
@SubscribeEvent
public static void onBreakBlock(BlockEvent.BreakEvent event) {
    if (shouldPreventBreak(event.getState())) {
        event.setCanceled(true); // Prevent block from breaking
    }
}
```

## Tick Event Types

### 1. Server Tick
**When**: Every server game tick (20 TPS)
**Use**: World state updates, game logic

```java
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        // After server logic updates
    }
}
```

### 2. Client Tick
**When**: Every client game tick (FPS dependent, but capped at 20 TPS for logic)
**Use**: Client state, UI updates, input handling

```java
@SubscribeEvent
public static void onClientTick(TickEvent.ClientTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        // After client logic updates
    }
}
```

### 3. Player Tick
**When**: For each player, every tick
**Use**: Per-player logic, capability updates

```java
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    Player player = event.player;
    if (event.side.isServer() && event.phase == TickEvent.Phase.END) {
        // Server-side per-player logic
    }
}
```

### 4. Level Tick
**When**: For each loaded level (dimension), every tick
**Use**: Per-dimension logic, weather control

```java
@SubscribeEvent
public static void onLevelTick(TickEvent.LevelTickEvent event) {
    Level level = event.level;
    if (!level.isClientSide && event.phase == TickEvent.Phase.END) {
        // Server-side level logic
    }
}
```

## Event Priority

### Priority Levels (Execution Order)

```java
EventPriority.HIGHEST  // Runs last (sees final state)
EventPriority.HIGH
EventPriority.NORMAL   // Default
EventPriority.LOW
EventPriority.LOWEST   // Runs first (can set defaults)
```

**Usage**:
```java
@SubscribeEvent(priority = EventPriority.HIGH)
public static void onEvent(SomeEvent event) {
    // Runs after NORMAL priority handlers
}
```

**When to Use**:
- `LOWEST`: Set defaults, run before other mods
- `NORMAL`: Standard handling (default)
- `HIGH`: Override other mods' behavior
- `HIGHEST`: Final modifications, logging

### Event Cancellation

**Check if Cancellable**:
```java
if (event.isCancelable()) {
    event.setCanceled(true);
}
```

**Respect Cancellation**:
```java
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    if (event.isCanceled()) {
        return; // Another mod cancelled, respect it
    }

    // Your logic here
}
```

**Common Cancellable Events**:
- `BlockEvent.BreakEvent` - Block breaking
- `LivingAttackEvent` - Entity damage
- `PlayerInteractEvent` - Player interactions
- `LivingDropsEvent` - Item drops

## MOD Bus vs FORGE Bus

### MOD Bus Events (IEventBus)

**Lifecycle Events**:
```java
@Mod(MODID)
public class MyMod {
    public MyMod(IEventBus modEventBus) {
        // Common setup
        modEventBus.addListener(this::onCommonSetup);

        // Client setup
        DistExecutor.unsafeRunWhenOn(Dist.CLIENT, () -> () -> {
            modEventBus.addListener(this::onClientSetup);
        });
    }

    private void onCommonSetup(FMLCommonSetupEvent event) {
        event.enqueueWork(() -> {
            // Thread-safe initialization
            PacketHandler.register();
        });
    }

    private void onClientSetup(FMLClientSetupEvent event) {
        event.enqueueWork(() -> {
            // Client-only initialization
            KeyBindings.register();
        });
    }
}
```

**Registry Events**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Mod.EventBusSubscriber.Bus.MOD)
public class ModEvents {

    @SubscribeEvent
    public static void onRegisterCapabilities(RegisterCapabilitiesEvent event) {
        event.register(MusicStateCapability.class);
    }
}
```

### FORGE Bus Events (MinecraftForge.EVENT_BUS)

**Game Events**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Mod.EventBusSubscriber.Bus.FORGE)
public class ForgeEvents {

    @SubscribeEvent
    public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
        // Player joined game
    }

    @SubscribeEvent
    public static void onBlockBreak(BlockEvent.BreakEvent event) {
        // Block broken
    }
}
```

**Quick Reference**:

| Event Category | Bus |
|---------------|-----|
| Registry (items, blocks) | MOD |
| Mod setup (common, client) | MOD |
| Capability registration | MOD |
| Player actions (break, interact) | FORGE |
| Entity events (spawn, death) | FORGE |
| Tick handlers | FORGE |
| World events (load, save) | FORGE |

## Side-Specific Event Handling

### Client-Only Events

**Method 1: Annotation**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Mod.EventBusSubscriber.Bus.FORGE, value = Dist.CLIENT)
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

**Player Type Check**:
```java
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    if (event.getEntity() instanceof ServerPlayer serverPlayer) {
        // Guaranteed server-side player
    }
}
```

## Performance Optimization

### Throttled Tick Handlers

**Problem**: Running expensive operations every tick causes lag

**Solution**: Throttle using counter

```java
private static int tickCounter = 0;

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        if (++tickCounter >= 20) { // Once per second
            tickCounter = 0;
            expensiveOperation();
        }
    }
}
```

**Adaptive Throttling**:
```java
private static int tickCounter = 0;
private static final int TICK_INTERVAL = 20; // Configurable

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        tickCounter++;
        if (tickCounter >= TICK_INTERVAL) {
            tickCounter = 0;

            // Only run if needed
            if (hasWorkToDo()) {
                doWork();
            }
        }
    }
}
```

### Early Exit Pattern

**Avoid unnecessary work**:
```java
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    // Exit early if nothing to do
    if (event.phase != TickEvent.Phase.END) return;
    if (!event.side.isClient()) return;

    Player player = event.player;
    if (player == null) return;
    if (!shouldProcess(player)) return;

    // Only process when all conditions met
    processPlayer(player);
}
```

## Best Practices

1. **Always check event phase**:
   ```java
   // ✅ Good - runs once per tick
   if (event.phase == TickEvent.Phase.END) { }

   // ❌ Bad - runs twice (START and END)
   // No phase check
   ```

2. **Check side for client/server specific code**:
   ```java
   // ✅ Good
   if (event.side.isClient()) {
       // Client rendering, sounds
   }

   // ❌ Bad - crashes dedicated server
   Minecraft.getInstance().player; // Client-only API
   ```

3. **Use static methods for @EventBusSubscriber**:
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

4. **Respect event cancellation**:
   ```java
   // ✅ Good
   if (event.isCanceled()) return;

   // ❌ Bad - ignores other mods
   // No cancellation check
   ```

5. **Use appropriate priority**:
   ```java
   // ✅ Good - explicit about ordering
   @SubscribeEvent(priority = EventPriority.HIGH)
   public static void onEvent(...) { }

   // ⚠️ Usually fine, but no control
   @SubscribeEvent
   public static void onEvent(...) { } // NORMAL priority
   ```

## Anti-Patterns

1. ❌ **Wrong bus for event type**:
   ```java
   // ❌ Player events on MOD bus (won't fire)
   @Mod.EventBusSubscriber(bus = Mod.EventBusSubscriber.Bus.MOD)
   public class Events {
       @SubscribeEvent
       public static void onPlayerTick(TickEvent.PlayerTickEvent event) { }
   }

   // ✅ Use FORGE bus
   @Mod.EventBusSubscriber(bus = Mod.EventBusSubscriber.Bus.FORGE)
   ```

2. ❌ **Client code on dedicated server**:
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

3. ❌ **Heavy operations every tick**:
   ```java
   // ❌ Lags server
   @SubscribeEvent
   public static void onServerTick(TickEvent.ServerTickEvent event) {
       scanAllChunksForBlocks(); // VERY EXPENSIVE
   }

   // ✅ Throttle
   if (++tickCounter >= 100) { // Every 5 seconds
       tickCounter = 0;
       scanNearbyChunks();
   }
   ```

4. ❌ **Modifying state on client side**:
   ```java
   // ❌ Desync with server
   @SubscribeEvent
   public static void onBlockBreak(BlockEvent.BreakEvent event) {
       if (event.getPlayer().level().isClientSide) {
           player.giveExperiencePoints(10); // Client can't modify server state
       }
   }

   // ✅ Server-side only
   if (!event.getPlayer().level().isClientSide) {
       player.giveExperiencePoints(10);
   }
   ```

5. ❌ **Not checking phase**:
   ```java
   // ❌ Runs twice per tick
   @SubscribeEvent
   public static void onServerTick(TickEvent.ServerTickEvent event) {
       counter++; // Increments 2x per tick
   }

   // ✅ Check phase
   if (event.phase == TickEvent.Phase.END) {
       counter++;
   }
   ```

## Common Event Reference

### Lifecycle Events (MOD Bus)
- `FMLCommonSetupEvent` - Common setup (client + server)
- `FMLClientSetupEvent` - Client-only setup
- `FMLDedicatedServerSetupEvent` - Server-only setup
- `RegisterCapabilitiesEvent` - Register capabilities
- `RegisterCommandsEvent` - Register commands

### Player Events (FORGE Bus)
- `PlayerEvent.PlayerLoggedInEvent` - Player joins server
- `PlayerEvent.PlayerLoggedOutEvent` - Player leaves server
- `PlayerEvent.Clone` - Player respawns/returns from End
- `PlayerInteractEvent.RightClickBlock` - Right-click block
- `PlayerInteractEvent.RightClickItem` - Right-click with item

### Block Events (FORGE Bus)
- `BlockEvent.BreakEvent` - Block broken (cancellable)
- `BlockEvent.PlaceEvent` - Block placed
- `BlockEvent.EntityPlaceEvent` - Entity places block
- `BlockEvent.NeighborNotifyEvent` - Block update

### Entity Events (FORGE Bus)
- `LivingDeathEvent` - Entity dies (cancellable)
- `LivingAttackEvent` - Entity attacked (cancellable)
- `LivingHurtEvent` - Entity hurt (cancellable)
- `EntityJoinLevelEvent` - Entity spawns/loads
- `LivingDropsEvent` - Entity drops items (cancellable)

### Tick Events (FORGE Bus)
- `TickEvent.ServerTickEvent` - Server game tick
- `TickEvent.ClientTickEvent` - Client game tick
- `TickEvent.PlayerTickEvent` - Per-player tick
- `TickEvent.LevelTickEvent` - Per-level tick

## See Also

- [fabric-event-system](../fabric-event-system/SKILL.md) - Fabric callbacks
- [mod-lifecycle-patterns](../mod-lifecycle-patterns/SKILL.md) - Initialization patterns
- Official Forge Docs: https://docs.minecraftforge.net/en/latest/events/intro/
