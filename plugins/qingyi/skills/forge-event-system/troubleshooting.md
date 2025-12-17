# Troubleshooting - Common Event System Issues and Solutions

This guide provides solutions to common problems when working with the Forge/NeoForge event system.

## Overview

**Purpose**: Diagnose and fix event handler issues quickly.

**Format**: Problem ’ Diagnosis ’ Solution ’ Verification

---

## Issue 1: Event Handler Not Firing

### Problem

"My @SubscribeEvent method never executes"

### Diagnosis

**Check 1: Is the class registered?**

```java
// L Missing registration
public class MyEvents {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
        // Never fires - class not registered!
    }
}
```

**Check 2: Is the method static?**

```java
// L Non-static method (with @Mod.EventBusSubscriber)
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class MyEvents {
    @SubscribeEvent
    public void onPlayerTick(TickEvent.PlayerTickEvent event) {
        // Never fires - MUST be static!
    }
}
```

**Check 3: Is it on the correct bus?**

```java
// L Wrong bus
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.MOD)  // MOD bus
public class MyEvents {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
        // Never fires - player tick is on FORGE bus!
    }
}
```

### Solution

**Option 1: Use @Mod.EventBusSubscriber (automatic registration)**

```java
//  CORRECT
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class MyEvents {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
        // Fires correctly!
    }
}
```

**Option 2: Manual registration**

```java
// In your main mod class
@Mod(MODID)
public class MyMod {
    public MyMod(IEventBus modEventBus) {
        // Register instance (methods can be non-static)
        MinecraftForge.EVENT_BUS.register(new MyEvents());
    }
}

// Event handler class
public class MyEvents {
    @SubscribeEvent
    public void onPlayerTick(TickEvent.PlayerTickEvent event) {
        // Fires correctly!
    }
}
```

### Verification

**Add logging**:

```java
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    LOGGER.info("Player tick fired!"); // Should appear in console
}
```

**Check console**: Should see "Player tick fired!" spam (20 times per second per player)

---

## Issue 2: Event Fires on Wrong Side

### Problem

"My event runs on client when I want server-only"

### Diagnosis

**Check side in code**:

```java
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    // Fires on both sides!
    LOGGER.info("Player tick! Side: {}", event.side);
    // Output:
    // [Server thread] Player tick! Side: SERVER
    // [Render thread] Player tick! Side: CLIENT
}
```

### Solution

**Option 1: Runtime side check**

```java
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    if (event.side.isClient()) return;  // Ignore client side

    // Server-only logic here
}
```

**Option 2: Separate classes with Dist.CLIENT**

```java
// Server events (runs on both, but filtered)
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class ServerEvents {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
        if (event.side.isClient()) return;
        // Server logic
    }
}

// Client events (only loads on client)
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE, value = Dist.CLIENT)
public class ClientEvents {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
        if (!event.side.isClient()) return;
        // Client logic
    }
}
```

### Verification

```java
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    if (event.side.isClient()) return;

    // Should only see this on server thread
    LOGGER.info("Server tick! Thread: {}", Thread.currentThread().getName());
    // Expected: [Server thread] Server tick! Thread: Server thread
}
```

---

## Issue 3: NullPointerException in Event Handler

### Problem

"My event handler crashes with NullPointerException"

### Diagnosis

**Common causes**:

1. **Event data is null**
2. **World/Level is null**
3. **Player/Entity is null**
4. **Accessed field not initialized**

**Example crash**:

```java
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    Player player = event.getPlayer();
    String name = player.getName().getString();  // NPE if player is null!
}

// Console:
// java.lang.NullPointerException: Cannot invoke "getName()" because "player" is null
```

### Solution

**Use null checks**:

```java
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    Player player = event.getPlayer();
    if (player == null) return;  // Safety check

    String name = player.getName().getString();  // Now safe
}
```

**Pattern matching (modern Java)**:

```java
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    if (!(event.getLevel() instanceof ServerLevel level)) return;
    if (event.getPlayer() == null) return;

    // Both level and player guaranteed non-null here
}
```

### Verification

**Run without crash**: Event handler should no longer throw NPE.

---

## Issue 4: Event Cancelled But Still Happens

### Problem

"I cancel the event but the action still occurs"

### Diagnosis

**Check if event is cancellable**:

```java
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    event.setCanceled(true);  // Does this event support cancellation?
}
```

**Check event priority**:

```java
// Another mod might be running AFTER you with higher priority
@SubscribeEvent(priority = EventPriority.NORMAL)
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    event.setCanceled(true);  // Cancelled
}

// Another mod:
@SubscribeEvent(priority = EventPriority.LOWEST)  // Runs LAST
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    event.setCanceled(false);  // Un-cancels it!
}
```

### Solution

**Option 1: Use higher priority**

```java
@SubscribeEvent(priority = EventPriority.HIGHEST)  // Runs FIRST
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    event.setCanceled(true);
}
```

**Priority order**:
```
HIGHEST ’ HIGH ’ NORMAL ’ LOW ’ LOWEST
```

**Option 2: Check if already cancelled**

```java
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    if (event.isCanceled()) return;  // Don't override other mods

    // Your logic
}
```

### Verification

**Test in-game**: Action should be prevented (e.g., block doesn't break).

---

## Issue 5: Event Fires Multiple Times

### Problem

"My event handler runs twice per event"

### Diagnosis

**Cause 1: Both START and END phases**

```java
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    LOGGER.info("Tick! Phase: {}", event.phase);
    // Output:
    // Tick! Phase: START
    // Tick! Phase: END
    // (Runs TWICE per tick!)
}
```

**Cause 2: Registered multiple times**

```java
@Mod(MODID)
public class MyMod {
    public MyMod(IEventBus modEventBus) {
        MinecraftForge.EVENT_BUS.register(new MyEvents());
        MinecraftForge.EVENT_BUS.register(new MyEvents());  // DUPLICATE!
    }
}
```

**Cause 3: Both automatic and manual registration**

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)  // Automatic
public class MyEvents {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) { }
}

// In mod constructor:
MinecraftForge.EVENT_BUS.register(new MyEvents());  // ALSO manual!
// Now registered TWICE!
```

### Solution

**Filter phase**:

```java
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase != TickEvent.Phase.END) return;  // Only END phase

    // Runs ONCE per tick
}
```

**Remove duplicate registrations**:

```java
// Use EITHER automatic OR manual registration, not both

// Option A: Automatic only
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class MyEvents {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) { }
}

// Option B: Manual only
public class MyEvents {
    @SubscribeEvent
    public void onPlayerTick(TickEvent.PlayerTickEvent event) { }
}

@Mod(MODID)
public class MyMod {
    public MyMod() {
        MinecraftForge.EVENT_BUS.register(new MyEvents());
    }
}
```

### Verification

**Add counter**:

```java
private static int callCount = 0;

@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    if (event.phase != TickEvent.Phase.END) return;

    callCount++;
    LOGGER.info("Call count: {}", callCount);
    // Should increment by 1 per tick, not 2
}
```

---

## Issue 6: Can't Access Client-Only Classes on Server

### Problem

"NoClassDefFoundError when accessing Minecraft.getInstance() on server"

### Diagnosis

**Example crash**:

```java
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    Minecraft mc = Minecraft.getInstance();  // CLIENT-ONLY class!
    // Crashes on dedicated server
}

// Console (dedicated server):
// java.lang.NoClassDefFoundError: net/minecraft/client/Minecraft
```

### Solution

**Option 1: Side check**

```java
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    if (!event.side.isClient()) return;  // Safety check

    Minecraft mc = Minecraft.getInstance();  // Now safe
}
```

**Option 2: Separate class with Dist.CLIENT**

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE, value = Dist.CLIENT)
public class ClientEvents {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
        Minecraft mc = Minecraft.getInstance();  // Safe - class only loads on client
    }
}
```

**Option 3: Proxy pattern (advanced)**

```java
// Common code
public interface IProxy {
    void handleClientTick();
}

// Client proxy (only loaded on client)
public class ClientProxy implements IProxy {
    @Override
    public void handleClientTick() {
        Minecraft mc = Minecraft.getInstance();
        // Client logic
    }
}

// Server proxy (only loaded on server)
public class ServerProxy implements IProxy {
    @Override
    public void handleClientTick() {
        // Do nothing on server
    }
}
```

### Verification

**Test on dedicated server**: Mod should load without crashing.

---

## Issue 7: Event Not Available in Framework Version

### Problem

"Event class doesn't exist in my Minecraft version"

### Diagnosis

**Example**:

```java
// In 1.19.2
@SubscribeEvent
public static void onSomething(SomeEvent event) {
    // Compile error: SomeEvent doesn't exist in 1.19.2
}
```

**Check Forge/NeoForge version**:

```gradle
// build.gradle
minecraft_version=1.20.1
forge_version=47.1.0

// Some events only exist in newer versions
```

### Solution

**Option 1: Upgrade Minecraft/Forge version**

```gradle
// build.gradle
minecraft_version=1.20.1  // Upgrade from 1.19.2
forge_version=47.1.0
```

**Option 2: Use equivalent event**

```java
// 1.19.2 doesn't have XYZ event
// Use ABC event instead (check Forge changelog)
```

**Option 3: Implement alternative approach**

```java
// If event doesn't exist, use tick handler to poll
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    // Manually check condition every tick
}
```

### Verification

**Code compiles**: No compile errors about missing event classes.

---

## Issue 8: Performance Issues / Lag

### Problem

"My event handler causes lag/low TPS"

### Diagnosis

**Profile with Spark**:

```
/spark profiler --timeout 30
```

**Check TPS**:

```
/forge tps
// or
/spark tps
```

**Add timing logs**:

```java
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    long start = System.nanoTime();

    // Your logic
    expensiveOperation();

    long duration = (System.nanoTime() - start) / 1_000_000;
    if (duration > 10) {
        LOGGER.warn("Tick took {}ms! (target: <1ms)", duration);
    }
}
```

### Solution

See [Performance Optimization](./performance-optimization.md) for detailed strategies:

**Quick fixes**:

1. **Throttle tick handlers**:
```java
private static int tickCounter = 0;

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    tickCounter++;
    if (tickCounter % 20 != 0) return;  // Run every 20 ticks (1 second)

    // Less frequent operation
}
```

2. **Add early returns**:
```java
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    // Fast path: reject early
    if (!(event.getLevel() instanceof ServerLevel)) return;
    if (!event.getState().is(ModBlocks.SPECIAL_BLOCK.get())) return;

    // Expensive logic only for special blocks
}
```

3. **Cache expensive lookups**:
```java
private static ServerLevel cachedOverworld = null;

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (cachedOverworld == null) {
        cachedOverworld = server.getLevel(Level.OVERWORLD);
    }
    // Use cachedOverworld (no lookup cost)
}
```

### Verification

**TPS should improve**: From <20 TPS back to 20 TPS.

**Profiler shows lower percentage**: From 15% ’ <5% CPU time.

---

## Diagnostic Checklist

When event handler isn't working:

```
 Class has @Mod.EventBusSubscriber annotation OR is manually registered
 Method has @SubscribeEvent annotation
 Method is static (if using @Mod.EventBusSubscriber)
 Correct bus specified (MOD vs FORGE)
 Correct side (CLIENT vs SERVER vs both)
 Event exists in your Minecraft version
 Event isn't cancelled by higher priority handler
 Null checks for event data
 Phase filter (START vs END) if needed
 No client-only code on server
```

---

## Quick Reference

### Event Bus Selection

| Event | Bus |
|-------|-----|
| Registry events | MOD |
| Mod setup | MOD |
| Player actions | FORGE |
| Entity events | FORGE |
| Tick handlers | FORGE |
| Block events | FORGE |

### Priority Order

```
HIGHEST ’ HIGH ’ NORMAL ’ LOW ’ LOWEST
(First)                           (Last)
```

**Use HIGHEST** to cancel before other mods.

**Use LOWEST** to run after other mods.

---

## Related Documentation

- [Event Catalog](./event-catalog.md) - All available events
- [Event Priorities](./event-priorities.md) - Priority system details
- [Performance Optimization](./performance-optimization.md) - Performance best practices

Back to [SKILL.md](./SKILL.md)
