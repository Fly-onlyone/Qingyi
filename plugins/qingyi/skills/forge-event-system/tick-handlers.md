---
name: tick-handlers
description: Comprehensive guide to tick handlers in Forge. Covers all tick types with optimization and performance patterns.
---

# Tick Handlers Guide

## Tick Types in Forge

### Server Tick (ServerTickEvent)
Fires every server game tick (20 TPS = 50ms per tick).

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class ServerTickHandler {
    private static int tickCounter = 0;

    @SubscribeEvent
    public static void onServerTick(TickEvent.ServerTickEvent event) {
        if (event.phase != TickEvent.Phase.END) return;
        
        tickCounter++;
        MinecraftServer server = ServerLifecycleHooks.getCurrentServer();
        if (server != null) {
            // Server-side logic
            updateGameState(server);
        }
    }
}
```

Use for:
- World state updates
- Game logic
- Server-only features

### Client Tick (ClientTickEvent)
Client-side equivalent.

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE, value = Dist.CLIENT)
public class ClientTickHandler {
    @SubscribeEvent
    public static void onClientTick(TickEvent.ClientTickEvent event) {
        if (event.phase != TickEvent.Phase.END) return;
        
        Minecraft minecraft = Minecraft.getInstance();
        if (minecraft.level == null) return;
        
        // Client rendering, UI updates
    }
}
```

Use for:
- Client rendering
- UI updates
- Input handling

### Player Tick (PlayerTickEvent)
Per-player tick.

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class PlayerTickHandler {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
        if (event.phase != TickEvent.Phase.END) return;
        
        Player player = event.player;
        if (player.level().isClientSide) return; // Server only
        
        // Update player state
        updatePlayerData(player);
    }
}
```

Use for:
- Per-player logic
- Capability updates
- Cooldown counting

### Level Tick (LevelTickEvent)
Per-dimension tick.

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class LevelTickHandler {
    @SubscribeEvent
    public static void onLevelTick(TickEvent.LevelTickEvent event) {
        if (event.phase != TickEvent.Phase.END) return;
        
        Level level = event.level;
        if (level.isClientSide) return;
        
        // Per-dimension logic
        updateDimension(level);
    }
}
```

Use for:
- Dimension-specific logic
- Weather control
- Per-level updates

## Tick Phase: START vs END

### START Phase
Fires before game logic updates.

```java
if (event.phase == TickEvent.Phase.START) {
    // Before game logic
    // Useful for setup/preparation
}
```

### END Phase
Fires after game logic updates.

```java
if (event.phase == TickEvent.Phase.END) {
    // After game logic
    // Better for most use cases
}
```

**Best Practice**: Always use END phase to see game state changes.

## Throttling: Limiting Frequency

Running every tick can be expensive. Throttle where possible.

### Every N Ticks

```java
private static int tickCounter = 0;

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase != TickEvent.Phase.END) return;
    
    if (++tickCounter >= 20) { // Every 1 second
        tickCounter = 0;
        expensiveOperation();
    }
}
```

### Every Second

```java
private static int tickCounter = 0;

@SubscribeEvent
public static void onTick(TickEvent.ServerTickEvent event) {
    if (event.phase != TickEvent.Phase.END) return;
    
    if (++tickCounter >= 20) {
        tickCounter = 0;
        // Runs once per second
    }
}
```

### Random Intervals

```java
private static final Random RANDOM = new Random();

@SubscribeEvent
public static void onTick(TickEvent.ServerTickEvent event) {
    if (event.phase != TickEvent.Phase.END) return;
    
    if (RANDOM.nextDouble() < 0.05) { // 5% per tick
        rareOperation();
    }
}
```

## Real-World Example: Apocalypse_TNT

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class ApocalypseTickHandler {
    @SubscribeEvent
    public static void onServerTick(TickEvent.ServerTickEvent event) {
        if (event.phase != TickEvent.Phase.END) return;
        
        MinecraftServer server = 
            ServerLifecycleHooks.getCurrentServer();
        if (server != null) {
            // Delegate to orchestrator
            ApocalypseOrchestrator.getInstance()
                .tick(server);
        }
    }
}
```

## Performance Optimization

### Avoid Heavy Operations Every Tick

```java
// BAD - Very expensive, runs 20x/second
@SubscribeEvent
public static void badTick(TickEvent.ServerTickEvent event) {
    for (ServerLevel level : server.getAllLevels()) {
        for (ChunkPos chunk : level.getChunkSource()
                .getLoadedChunks()) {
            // Process every chunk every tick!
        }
    }
}

// GOOD - Spread over time
private static int chunkIndex = 0;
@SubscribeEvent
public static void goodTick(TickEvent.ServerTickEvent event) {
    if (event.phase != TickEvent.Phase.END) return;
    
    ServerLevel level = server.overworld();
    List<ChunkPos> chunks = 
        level.getChunkSource().getLoadedChunks();
    
    // Process one chunk per tick
    if (chunkIndex >= chunks.size()) {
        chunkIndex = 0;
    }
    
    if (chunkIndex < chunks.size()) {
        processChunk(chunks.get(chunkIndex++));
    }
}
```

### Early Exit Pattern

```java
@SubscribeEvent
public static void efficientTick(TickEvent.ServerTickEvent event) {
    if (event.phase != TickEvent.Phase.END) return;
    
    // Exit early if no work needed
    if (!ApocalypseOrchestrator.isActive()) {
        return;
    }
    
    // Only runs if active
    ApocalypseOrchestrator.tick(server);
}
```

### Use Capabilities Instead of Tick Handlers

```java
// Instead of ticking every player:
@SubscribeEvent
public static void badPlayerTick(TickEvent.PlayerTickEvent event) {
    updatePlayerCapability(event.player); // Called 20x/sec per player
}

// Use capability:
public class PlayerCapability {
    public void update() {
        // Called from capability system
    }
}
```

## Client vs Server Tick Safety

### Checking Sides

```java
@SubscribeEvent
public static void safeTick(TickEvent.PlayerTickEvent event) {
    if (event.phase != TickEvent.Phase.END) return;
    
    Player player = event.player;
    
    // Check logical side
    if (player.level().isClientSide) {
        // Client-only logic
        updateClientUI(player);
    } else {
        // Server-only logic
        updateServerData(player);
    }
}
```

### Avoid Minecraft.getInstance() on Server

```java
// WRONG - Crashes on dedicated server
@SubscribeEvent
public static void badTick(TickEvent.ServerTickEvent event) {
    Minecraft mc = Minecraft.getInstance(); // CLIENT ONLY!
}

// CORRECT
@SubscribeEvent
public static void goodTick(TickEvent.ServerTickEvent event) {
    MinecraftServer server = 
        ServerLifecycleHooks.getCurrentServer();
}
```

## Tick Event Reference

| Event | Bus | Frequency | Use |
|-------|-----|-----------|-----|
| ServerTickEvent | FORGE | 20 TPS | Server logic |
| ClientTickEvent | FORGE | Variable | Client logic |
| PlayerTickEvent | FORGE | Per player | Player updates |
| LevelTickEvent | FORGE | Per dimension | Dimension logic |

## Best Practices

1. Always check event.phase == TickEvent.Phase.END
2. Check if level.isClientSide for safety
3. Throttle heavy operations
4. Use early exits
5. Delegate to manager classes
6. Consider capabilities instead of ticks
7. Profile to find bottlenecks

Use tick handlers for continuous updates and game logic.
