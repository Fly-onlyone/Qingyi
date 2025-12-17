# Performance Optimization - Event Handler Performance Best Practices

This guide provides comprehensive performance optimization strategies for Forge/NeoForge event handlers and tick systems.

## Overview

**Problem**: Poorly optimized event handlers cause lag, low TPS (ticks per second), and poor player experience.

**Goal**: Write performant event handlers that run efficiently without impacting game performance.

**Impact**: Proper optimization maintains 20 TPS (no lag) even with complex mod logic.

---

## Table of Contents

1. [Performance Fundamentals](#performance-fundamentals)
2. [Tick Handler Optimization](#tick-handler-optimization)
3. [Event Handler Best Practices](#event-handler-best-practices)
4. [Caching and Computation](#caching-and-computation)
5. [Conditional Execution Patterns](#conditional-execution-patterns)
6. [Profiling and Measurement](#profiling-and-measurement)
7. [Common Anti-Patterns](#common-anti-patterns)

---

## Performance Fundamentals

### Understanding TPS (Ticks Per Second)

**Target**: 20 TPS (50ms per tick)

**Budget per tick**: 50 milliseconds

**Allocation**:
```
Vanilla game logic: ~30ms
Mods combined: ~20ms budget
  Your mod: Aim for <1ms per tick
```

**TPS Impact**:
```
20 TPS ’ No lag (perfect)
19 TPS ’ Slight lag (noticeable)
15 TPS ’ Moderate lag (annoying)
10 TPS ’ Severe lag (unplayable)
```

---

### Event Handler Cost Model

**Frequency matters**:

```java
// LOW cost: Fires rarely
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    // Runs once per player join
    // Can afford 10-50ms
}

// MEDIUM cost: Fires occasionally
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    // Runs per block broken
    // Budget: <1ms
}

// HIGH cost: Fires constantly
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    // Runs 20 times/second
    // CRITICAL: <0.5ms
}
```

**Rule**: The more frequent the event, the more critical the optimization.

---

## Tick Handler Optimization

### Pattern 1: Throttling (Skip Ticks)

**Problem**: Logic doesn't need to run every tick.

**Solution**: Run every N ticks.

**Example**: Apocalypse_TNT orchestrator

```java
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        MinecraftServer server = ServerLifecycleHooks.getCurrentServer();
        if (server != null) {
            // Orchestrator handles its own throttling
            ApocalypseOrchestrator.getInstance().tick(server);
        }
    }
}

// Inside ApocalypseOrchestrator.java
private int tickCounter = 0;

public void tick(MinecraftServer server) {
    tickCounter++;

    // Run countdown update every 20 ticks (1 second)
    if (tickCounter % 20 == 0) {
        updateCountdown(server);
    }

    // Run TNT wave spawn every 200 ticks (10 seconds)
    if (tickCounter % 200 == 0) {
        spawnTNTWave(server);
    }
}
```

**Performance gain**: 95% reduction (from every tick to every 20 ticks)

---

### Pattern 2: Delta Time (Track Last Execution)

**Problem**: Need precise timing intervals.

**Solution**: Track last execution timestamp.

```java
private long lastExecutionTime = 0;
private static final long INTERVAL_MS = 5000; // 5 seconds

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    long currentTime = System.currentTimeMillis();

    if (currentTime - lastExecutionTime >= INTERVAL_MS) {
        performExpensiveOperation();
        lastExecutionTime = currentTime;
    }
}
```

**Benefits**:
- Precise timing (not affected by tick rate fluctuations)
- Adaptive to server lag

---

### Pattern 3: Player-Specific Throttling

**Problem**: Need different rates per player.

**Solution**: HashMap of player UUID ’ last tick.

```java
private static final Map<UUID, Integer> playerTickTimers = new HashMap<>();

@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    if (event.side.isClient() || event.phase != TickEvent.Phase.END) return;

    UUID playerUUID = event.player.getUUID();
    int ticksSinceLastCheck = playerTickTimers.getOrDefault(playerUUID, 0);

    ticksSinceLastCheck++;

    if (ticksSinceLastCheck >= 100) { // Every 5 seconds (100 ticks)
        checkPlayerProgress(event.player);
        playerTickTimers.put(playerUUID, 0);
    } else {
        playerTickTimers.put(playerUUID, ticksSinceLastCheck);
    }
}
```

**Cleanup** (prevent memory leak):
```java
@SubscribeEvent
public static void onPlayerLogout(PlayerEvent.PlayerLoggedOutEvent event) {
    playerTickTimers.remove(event.getEntity().getUUID());
}
```

---

### Pattern 4: Staggered Execution (Spread Load)

**Problem**: Multiple expensive operations on same tick cause lag spikes.

**Solution**: Distribute operations across multiple ticks.

```java
private int tickCounter = 0;
private List<Player> players = new ArrayList<>();

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase != TickEvent.Phase.END) return;

    tickCounter++;

    // Update different players on different ticks
    int playerIndex = tickCounter % players.size();
    if (playerIndex < players.size()) {
        updatePlayerData(players.get(playerIndex));
    }
}
```

**Example**: 100 players, spread over 100 ticks = 1 player per tick instead of 100 per tick

**Performance gain**: 99% reduction in per-tick cost

---

## Event Handler Best Practices

### Best Practice 1: Early Return (Guard Clauses)

**Principle**: Exit as early as possible if conditions not met.

```java
// L BAD: Nested conditions
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    if (event.getLevel() instanceof ServerLevel level) {
        if (event.getPlayer() != null) {
            if (event.getState().is(ModBlocks.RUBY_ORE.get())) {
                // Logic here
            }
        }
    }
}

//  GOOD: Early returns
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    // Fast path: Reject early
    if (!(event.getLevel() instanceof ServerLevel level)) return;
    if (event.getPlayer() == null) return;
    if (!event.getState().is(ModBlocks.RUBY_ORE.get())) return;

    // Logic here (only when all conditions met)
}
```

**Performance gain**: Avoids unnecessary checks and memory allocations

---

### Best Practice 2: Avoid Object Creation in Hot Paths

**Problem**: Creating objects every tick generates garbage.

```java
// L BAD: Creates new objects every tick
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    BlockPos playerPos = new BlockPos(event.player.position());  // New object every tick!
    List<Entity> nearbyEntities = new ArrayList<>();  // New object every tick!

    // Do something with playerPos and nearbyEntities
}

//  GOOD: Reuse or use primitives
private static BlockPos.MutableBlockPos reusablePos = new BlockPos.MutableBlockPos();

@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    reusablePos.set(event.player.getX(), event.player.getY(), event.player.getZ());

    // Use reusablePos (no allocation)
}
```

**Performance gain**: 90% reduction in garbage collection pressure

---

### Best Practice 3: Cache Lookups

**Problem**: Repeated expensive lookups.

```java
// L BAD: Lookup every tick
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    MinecraftServer server = ServerLifecycleHooks.getCurrentServer();
    ServerLevel overworld = server.getLevel(Level.OVERWORLD);  // Lookup every tick

    // Do something with overworld
}

//  GOOD: Cache the reference
private static ServerLevel cachedOverworld = null;

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (cachedOverworld == null) {
        MinecraftServer server = ServerLifecycleHooks.getCurrentServer();
        if (server != null) {
            cachedOverworld = server.getLevel(Level.OVERWORLD);
        }
    }

    if (cachedOverworld != null) {
        // Use cachedOverworld (no lookup)
    }
}
```

**Performance gain**: 50% reduction in tick handler time

---

### Best Practice 4: Batch Operations

**Problem**: Processing items one at a time.

```java
// L BAD: Process individually
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    for (Player player : server.getPlayerList().getPlayers()) {
        processPlayer(player);  // Expensive per-player operation
    }
}

//  GOOD: Batch and amortize
private static List<Player> queuedPlayers = new ArrayList<>();

@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    // Queue players
    queuedPlayers.add(event.player);
}

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (queuedPlayers.size() >= 10 || tickCounter % 20 == 0) {
        // Process in batch
        batchProcessPlayers(queuedPlayers);
        queuedPlayers.clear();
    }
}
```

**Performance gain**: Amortizes setup/teardown cost across multiple operations

---

## Caching and Computation

### Cache Pattern 1: Lazy Initialization

**Use when**: Data is expensive to compute but may not be needed.

```java
private Map<BlockPos, Integer> cachedHeightMap = null;

public int getHeightAt(BlockPos pos) {
    if (cachedHeightMap == null) {
        cachedHeightMap = computeHeightMap();  // Only compute if needed
    }
    return cachedHeightMap.getOrDefault(pos, 0);
}
```

---

### Cache Pattern 2: Time-Based Invalidation

**Use when**: Cached data becomes stale over time.

```java
private List<Entity> cachedNearbyEntities = null;
private long cacheTimestamp = 0;
private static final long CACHE_VALIDITY_MS = 1000; // 1 second

public List<Entity> getNearbyEntities(Player player) {
    long currentTime = System.currentTimeMillis();

    if (cachedNearbyEntities == null ||
        (currentTime - cacheTimestamp) > CACHE_VALIDITY_MS) {
        // Cache expired, recompute
        cachedNearbyEntities = player.level().getEntities(player, player.getBoundingBox().inflate(10));
        cacheTimestamp = currentTime;
    }

    return cachedNearbyEntities;
}
```

---

### Cache Pattern 3: Result Memoization

**Use when**: Same inputs produce same outputs.

```java
private final Map<String, Integer> computationCache = new HashMap<>();

public int expensiveComputation(String input) {
    return computationCache.computeIfAbsent(input, key -> {
        // Expensive computation here
        int result = performComplexCalculation(key);
        return result;
    });
}
```

**With size limit** (prevent unbounded growth):
```java
private final LinkedHashMap<String, Integer> computationCache = new LinkedHashMap<>(100, 0.75f, true) {
    @Override
    protected boolean removeEldestEntry(Map.Entry<String, Integer> eldest) {
        return size() > 100;  // LRU cache with max 100 entries
    }
};
```

---

## Conditional Execution Patterns

### Pattern 1: Client-Server Separation

**Principle**: Don't run server logic on client (and vice versa).

```java
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    // L BAD: Always checks side
    if (event.side.isServer()) {
        serverLogic(event.player);
    }
    if (event.side.isClient()) {
        clientLogic(event.player);
    }
}

//  GOOD: Separate handlers
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class ServerEvents {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
        if (event.side.isClient()) return;  // Early return
        serverLogic(event.player);
    }
}

@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE, value = Dist.CLIENT)
public class ClientEvents {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
        if (!event.side.isClient()) return;  // Early return
        clientLogic(event.player);
    }
}
```

**Performance gain**: Avoids executing unnecessary code path

---

### Pattern 2: Event Phase Filtering

**Principle**: Only run on the phase you need.

```java
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    // L BAD: Runs twice per tick (START and END phases)
    updateGameState();
}

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    //  GOOD: Runs once per tick
    if (event.phase != TickEvent.Phase.END) return;
    updateGameState();
}
```

**Performance gain**: 50% reduction (runs once instead of twice)

---

### Pattern 3: Dimension Filtering

**Principle**: Only run in relevant dimensions.

```java
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    // Only care about overworld
    MinecraftServer server = ServerLifecycleHooks.getCurrentServer();
    if (server == null) return;

    ServerLevel overworld = server.getLevel(Level.OVERWORLD);
    if (overworld == null) return;

    // Process only overworld
    processOverworld(overworld);
}
```

---

## Profiling and Measurement

### Technique 1: Manual Timing

**Basic measurement**:

```java
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    long startTime = System.nanoTime();

    // Your logic here
    performExpensiveOperation();

    long endTime = System.nanoTime();
    long durationMs = (endTime - startTime) / 1_000_000;

    if (durationMs > 10) {
        LOGGER.warn("Tick handler took {}ms (target: <1ms)", durationMs);
    }
}
```

---

### Technique 2: Spark Profiler Integration

**Spark**: Minecraft profiling mod (https://spark.lucko.me/)

**Usage**:
```
1. Install Spark on server
2. Run: /spark profiler --timeout 30
3. Wait 30 seconds
4. Click link to view profiler results
5. Find your event handlers
6. Identify bottlenecks
```

**Reading results**:
```
com.mod.handler.ServerEvents.onServerTick: 15.2% (HIGH - optimize!)
com.mod.handler.PlayerEvents.onPlayerJoin: 0.1% (low - acceptable)
```

---

### Technique 3: Conditional Logging

**Development-only profiling**:

```java
private static final boolean PROFILE_MODE = false;  // Enable for profiling

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    long startTime = PROFILE_MODE ? System.nanoTime() : 0;

    // Logic here
    performExpensiveOperation();

    if (PROFILE_MODE) {
        long duration = (System.nanoTime() - startTime) / 1_000_000;
        if (duration > 1) {
            LOGGER.info("Tick: {}ms", duration);
        }
    }
}
```

**Benefits**: Zero overhead when `PROFILE_MODE = false`

---

## Common Anti-Patterns

### Anti-Pattern 1: Iterating All Entities Every Tick

**Problem**: Expensive entity lookups.

```java
// L BAD: Iterates all entities every tick
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    for (ServerLevel level : server.getAllLevels()) {
        for (Entity entity : level.getAllEntities()) {
            if (entity instanceof Monster) {
                // Process monster
            }
        }
    }
}

//  GOOD: Use entity tracking or throttle
@SubscribeEvent
public static void onEntityJoinLevel(EntityJoinLevelEvent event) {
    // Track when monsters spawn
    if (event.getEntity() instanceof Monster monster) {
        trackedMonsters.add(monster.getUUID());
    }
}

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    // Process only tracked monsters (much smaller set)
    for (UUID monsterUUID : trackedMonsters) {
        // Process
    }
}
```

---

### Anti-Pattern 2: String Operations in Hot Paths

**Problem**: String concatenation and comparisons are slow.

```java
// L BAD: String operations every tick
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    String playerName = event.player.getName().getString();
    if (playerName.toLowerCase().contains("admin")) {
        // Grant admin powers
    }
}

//  GOOD: Cache results
private static final Set<UUID> adminPlayers = new HashSet<>();

@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    String playerName = event.getEntity().getName().getString().toLowerCase();
    if (playerName.contains("admin")) {
        adminPlayers.add(event.getEntity().getUUID());
    }
}

@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    if (adminPlayers.contains(event.player.getUUID())) {
        // Grant admin powers (fast HashMap lookup)
    }
}
```

---

### Anti-Pattern 3: Synchronous I/O in Event Handlers

**Problem**: File I/O blocks game thread.

```java
// L BAD: File write every tick (blocks game thread!)
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    Files.write(Paths.get("data.txt"), data.getBytes());  // VERY BAD
}

//  GOOD: Async or batched writes
private static final ScheduledExecutorService executor = Executors.newSingleThreadScheduledExecutor();
private static final List<String> dataQueue = new CopyOnWriteArrayList<>();

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    // Queue data (fast, non-blocking)
    dataQueue.add(generateData());
}

// Flush queue every 5 seconds (async)
static {
    executor.scheduleAtFixedRate(() -> {
        if (!dataQueue.isEmpty()) {
            try {
                Files.write(Paths.get("data.txt"), dataQueue);
                dataQueue.clear();
            } catch (IOException e) {
                LOGGER.error("Failed to write data", e);
            }
        }
    }, 5, 5, TimeUnit.SECONDS);
}
```

---

## Performance Checklist

Before releasing your mod, verify:

```
 Tick handlers run in <1ms (measure with profiler)
 No entity iteration every tick (use tracking instead)
 Cached expensive lookups
 Early returns for irrelevant events
 Throttled operations where possible
 No object creation in hot paths
 No synchronous I/O in event handlers
 Client-server separation correct
 Tested with 100+ players (if multiplayer mod)
 Profiled with Spark (no >5% CPU handlers)
```

---

## Related Documentation

- [Event Catalog](./event-catalog.md) - All available events
- [Event Priorities](./event-priorities.md) - Priority system
- [Tick Handlers](./tick-handlers.md) - Tick handler patterns

Back to [SKILL.md](./SKILL.md)
