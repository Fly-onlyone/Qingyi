# Performance Anti-Patterns for Minecraft Mods

Common performance issues in Minecraft mods and their solutions.

## Anti-Pattern 1: Every-Tick Expensive Operations

**Problem**: Running expensive logic 20 times per second

```java
// ❌ BAD: O(n²) every tick
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    for (Player player : allPlayers) {
        for (BlockEntity be : nearbyBlockEntities) {
            // Expensive calculation runs 20 times/sec!
        }
    }
}
```

**Impact**: Server TPS drops from 20 to <10, lag spikes

**Solution**: Interval gating
```java
// ✅ GOOD: Run once per second
private static int tickCounter = 0;

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase != TickEvent.Phase.END) return;

    tickCounter++;
    if (tickCounter % 20 != 0) return;  // Only run every 20 ticks

    // Now runs 1/sec instead of 20/sec
}
```

---

## Anti-Pattern 2: Linear Search Instead of HashMap

**Problem**: O(n) lookup when O(1) is available

```java
// ❌ BAD: Linear search
List<PlayerData> playerData = new ArrayList<>();

public PlayerData getPlayerData(Player player) {
    for (PlayerData data : playerData) {
        if (data.getPlayerId().equals(player.getUUID())) {
            return data;
        }
    }
    return null;  // O(n) lookup!
}
```

**Impact**: Performance degrades linearly with player count

**Solution**: Use HashMap
```java
// ✅ GOOD: O(1) lookup
Map<UUID, PlayerData> playerData = new HashMap<>();

public PlayerData getPlayerData(Player player) {
    return playerData.get(player.getUUID());  // O(1) lookup!
}
```

**Example from MusicMod**: Player music progress tracking uses HashMap for O(1) access

---

## Anti-Pattern 3: Excessive Particle Spawning

**Problem**: Spawning too many particles crashes client FPS

```java
// ❌ BAD: 100 particles every tick
for (int i = 0; i < 100; i++) {
    level.addParticle(ParticleTypes.FLAME, x, y, z, 0, 0, 0);
}
```

**Impact**: Client FPS drops from 60 to <10

**Solution**: Reduce count and add randomness
```java
// ✅ GOOD: 1 particle per tick, 10% chance
if (level.random.nextFloat() < 0.1F) {
    level.addParticle(ParticleTypes.FLAME, x, y, z, 0, 0, 0);
}
```

---

## Anti-Pattern 4: Unnecessary Object Creation in Loops

**Problem**: Creating objects in hot paths causes GC pressure

```java
// ❌ BAD: Creates new BlockPos every iteration
for (int x = 0; x < 16; x++) {
    for (int y = 0; y < 256; y++) {
        for (int z = 0; z < 16; z++) {
            BlockPos pos = new BlockPos(x, y, z);  // ← New object every iteration!
            level.getBlockState(pos);
        }
    }
}
```

**Impact**: Garbage collector pauses, stuttering

**Solution**: Reuse MutableBlockPos
```java
// ✅ GOOD: Reuse single MutableBlockPos
BlockPos.MutableBlockPos pos = new BlockPos.MutableBlockPos();
for (int x = 0; x < 16; x++) {
    for (int y = 0; y < 256; y++) {
        for (int z = 0; z < 16; z++) {
            pos.set(x, y, z);  // ← Reuses same object!
            level.getBlockState(pos);
        }
    }
}
```

---

## Anti-Pattern 5: Synchronous File I/O on Game Thread

**Problem**: Reading/writing files on tick thread freezes game

```java
// ❌ BAD: File I/O on game thread
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    PlayerData data = loadFromFile(event.getPlayer());  // ← Blocks game thread!
    // Game freezes while file loads
}
```

**Impact**: Game stutters or freezes during file operations

**Solution**: Async loading
```java
// ✅ GOOD: Load asynchronously
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    CompletableFuture.supplyAsync(() -> loadFromFile(event.getPlayer()))
        .thenAccept(data -> {
            // Apply data on game thread
            server.execute(() -> applyData(event.getPlayer(), data));
        });
}
```

---

## Anti-Pattern 6: Unbounded Collection Growth

**Problem**: Collections grow indefinitely, causing memory leaks

```java
// ❌ BAD: Grows forever
Map<UUID, PlayerSession> activeSessions = new HashMap<>();

public void onPlayerJoin(Player player) {
    activeSessions.put(player.getUUID(), new PlayerSession());
    // Never removed! Memory leak!
}
```

**Impact**: Out of memory crash after hours of runtime

**Solution**: Remove when done
```java
// ✅ GOOD: Clean up on logout
Map<UUID, PlayerSession> activeSessions = new HashMap<>();

public void onPlayerJoin(Player player) {
    activeSessions.put(player.getUUID(), new PlayerSession());
}

public void onPlayerLeave(Player player) {
    activeSessions.remove(player.getUUID());  // ← Clean up!
}
```

---

## Anti-Pattern 7: No Caching for Expensive Calculations

**Problem**: Recalculating same values repeatedly

```java
// ❌ BAD: Recalculates every frame
public void render() {
    double distance = calculateComplexDistance(player, target);  // ← Expensive!
    // Called 60 times per second
}
```

**Solution**: Cache calculated values
```java
// ✅ GOOD: Cache and invalidate
private double cachedDistance = -1;
private long lastCalculation = 0;

public void render() {
    long now = System.currentTimeMillis();
    if (now - lastCalculation > 50) {  // Recalculate every 50ms
        cachedDistance = calculateComplexDistance(player, target);
        lastCalculation = now;
    }
    // Use cachedDistance
}
```

---

## Anti-Pattern 8: Expensive Pathfinding Every Tick

**Problem**: Entity AI recalculates path every tick

```java
// ❌ BAD: New path every tick
public void aiTick() {
    Path path = findPath(currentPos, targetPos);  // ← Very expensive!
    followPath(path);
}
```

**Impact**: TPS drops with many entities

**Solution**: Calculate path infrequently
```java
// ✅ GOOD: Recalculate every 2 seconds
private Path cachedPath;
private int pathAge = 0;

public void aiTick() {
    pathAge++;
    if (pathAge > 40 || cachedPath == null) {  // Every 2 seconds
        cachedPath = findPath(currentPos, targetPos);
        pathAge = 0;
    }
    followPath(cachedPath);
}
```

---

## Anti-Pattern 9: Rendering Off-Screen Entities

**Problem**: Rendering entities not visible to player

```java
// ❌ BAD: Renders all entities
for (Entity entity : allEntities) {
    renderEntity(entity);  // ← Renders even if off-screen!
}
```

**Solution**: Frustum culling
```java
// ✅ GOOD: Only render visible entities
for (Entity entity : allEntities) {
    if (frustum.isVisible(entity.getBoundingBox())) {
        renderEntity(entity);
    }
}
```

---

## Anti-Pattern 10: String Concatenation in Loops

**Problem**: Creating many temporary strings

```java
// ❌ BAD: Creates n String objects
String result = "";
for (int i = 0; i < 1000; i++) {
    result += "Item " + i + ", ";  // ← New String each iteration!
}
```

**Solution**: Use StringBuilder
```java
// ✅ GOOD: Single StringBuilder
StringBuilder result = new StringBuilder();
for (int i = 0; i < 1000; i++) {
    result.append("Item ").append(i).append(", ");
}
```

---

## Profiling Tools

Use these tools to find performance issues:

1. **Spark**: Minecraft profiler mod
   - CPU profiling
   - Tick profiling
   - Entity/block entity profiling

2. **JProfiler/VisualVM**: Java profilers
   - Method hotspots
   - Memory allocation
   - Thread analysis

3. **Minecraft Debug Screen** (F3):
   - TPS (target: 20)
   - Entity count
   - Chunk updates

---

## Performance Optimization Checklist

- [ ] Tick handlers use interval gating (not every tick)
- [ ] Use HashMap for lookups, not ArrayList linear search
- [ ] Particle spawning limited and randomized
- [ ] Reuse MutableBlockPos in loops
- [ ] File I/O is asynchronous
- [ ] Collections cleaned up (no memory leaks)
- [ ] Expensive calculations cached
- [ ] Entity AI paths calculated infrequently
- [ ] Frustum culling for rendering
- [ ] StringBuilder for string concatenation in loops

---

## See Also

- [Main Code Review Patterns](./SKILL.md)
- [Security Vulnerabilities Database](./security-vulnerabilities.md)
