# Event Handler Search Patterns

This document provides detailed patterns for discovering and analyzing event handlers in Minecraft mods using IntelliJ MCP navigation tools.

## Overview

**Objective**: Locate @SubscribeEvent methods, determine event bus type (MOD vs FORGE), analyze side safety (CLIENT vs SERVER), and understand event handling patterns.

**Common Use Cases**:
- "Find all PlayerTickEvent handlers"
- "Show me event handlers on the MOD bus"
- "Where is the login event handled?"
- "List all client-side event handlers"

---

## Method 1: Annotation Search (FASTEST)

**Best for**: Finding all event handlers in a project

**Search Strategy**:
```
search_in_files_by_text("@SubscribeEvent", fileMask="*.java")
```

**Example**:
```
Task: Find all event handlers

Step 1: Search for annotation
→ search_in_files_by_text("@SubscribeEvent", fileMask="*.java")

Results:
- ClientEvents.java: 5 matches
- ServerEvents.java: 3 matches
- CommonEvents.java: 2 matches

Step 2: Read each file
→ Analyze class annotations and method signatures
```

**Success Rate**: 100% for @SubscribeEvent handlers

**Limitations**:
- Won't find manually registered handlers
- Won't find Fabric event handlers (different system)

---

## Method 2: Event Type Search (SPECIFIC)

**Best for**: Finding handlers for a specific event type

**Search Strategy**:
```
search_in_files_by_text("[EventType]", fileMask="*.java")

Common event types:
- "PlayerTickEvent"
- "PlayerEvent.PlayerLoggedInEvent"
- "TickEvent.ClientTickEvent"
- "BlockEvent.BreakEvent"
- "LivingDeathEvent"
```

**Example**:
```
Task: Find all PlayerTickEvent handlers

Step 1: Search for event type
→ search_in_files_by_text("PlayerTickEvent", fileMask="*.java")

Results:
- ServerEvents.java:18 - void onPlayerTick(TickEvent.PlayerTickEvent event)
- DataSyncHandler.java:42 - void syncPlayerData(TickEvent.PlayerTickEvent event)

Step 2: Analyze each handler
→ Read methods and determine purpose
```

**Success Rate**: 95%+ for specific events

---

## Method 3: Class-Based Search (ORGANIZED)

**Best for**: Mods with organized event handler packages

**Search Strategy**:
```
find_files_by_glob("**/events/*.java")
find_files_by_glob("**/handlers/*.java")
```

**Example**:
```
Task: Explore event handling structure

Step 1: Find event packages
→ find_files_by_glob("**/events/*.java")

Results:
- src/main/java/com/mod/events/ClientEvents.java
- src/main/java/com/mod/events/ServerEvents.java
- src/main/java/com/mod/events/CommonEvents.java

Step 2: Read and categorize
→ ClientEvents: CLIENT-side only (rendering, input)
→ ServerEvents: SERVER-side logic (world, entities)
→ CommonEvents: BOTH sides (networking, lifecycle)
```

**Success Rate**: 80% for organized mods

---

## Analyzing Event Handler Details

Once you've found an event handler, extract key information:

### Class-Level Analysis

**@Mod.EventBusSubscriber annotation**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE, value = Dist.CLIENT)
public class ClientEvents {
    // Handlers
}
```

**Extract**:
1. **modid**: Which mod owns this handler
2. **bus**: MOD or FORGE (critical!)
3. **value**: Dist.CLIENT (client-only) or Dist.DEDICATED_SERVER (server-only) or omitted (both)

---

### Method-Level Analysis

**@SubscribeEvent method**:
```java
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        // Logic here
    }
}
```

**Extract**:
1. **Method name**: onPlayerTick (descriptive)
2. **static keyword**: Present (automatic registration) or absent (manual registration needed)
3. **Event type**: TickEvent.PlayerTickEvent
4. **Event subtype**: event.phase, event.side, etc.

---

### Optional Annotations

**@OnlyIn(Dist.CLIENT)**:
```java
@OnlyIn(Dist.CLIENT)
@SubscribeEvent
public static void onClientTick(TickEvent.ClientTickEvent event) {
    // Client-only code
}
```

**Priority** (rare):
```java
@SubscribeEvent(priority = EventPriority.HIGHEST)
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    // High-priority handler
}
```

---

## Bus Type Determination

**Critical distinction**: MOD bus vs FORGE bus

### MOD Bus Events

**Used for**: Mod lifecycle and registration

**Common events**:
- `FMLCommonSetupEvent` - Common setup
- `FMLClientSetupEvent` - Client setup
- `FMLDedicatedServerSetupEvent` - Server setup
- `RegisterEvent` - Registry registration (modern)
- `InterModComms` - Inter-mod communication

**Annotation**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.MOD)
```

**When to use**:
- ✅ During mod initialization
- ✅ Registering capabilities, screens, etc.
- ✅ One-time setup tasks

---

### FORGE Bus Events

**Used for**: Gameplay events during runtime

**Common events**:
- `PlayerEvent.*` - Player actions (login, respawn, clone, etc.)
- `TickEvent.*` - Tick events (server, client, player, world, etc.)
- `LivingEvent.*` - Entity lifecycle (spawn, death, hurt, etc.)
- `BlockEvent.*` - Block interactions (break, place, neighbor change, etc.)
- `ServerChatEvent` - Chat messages
- `ItemEvent` - Item interactions

**Annotation**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
```

**When to use**:
- ✅ During gameplay
- ✅ Handling player/entity/world actions
- ✅ Continuous event monitoring

---

### Quick Determination

**If event type contains**:
- `FML*` → MOD bus
- `Register*` → MOD bus
- `Player*`, `Living*`, `Block*`, `Tick*` → FORGE bus
- `Item*`, `Entity*`, `World*` → FORGE bus

---

## Side Safety Analysis

**Critical for avoiding crashes**: Determine if handler is safe on both sides

### Client-Only Handlers

**Indicators**:
```java
@Mod.EventBusSubscriber(value = Dist.CLIENT)  // Class annotation
@OnlyIn(Dist.CLIENT)                          // Method annotation
```

**Event types that are client-only**:
- `TickEvent.ClientTickEvent`
- `TickEvent.RenderTickEvent`
- `InputEvent.*`
- `RenderLevelStageEvent`
- `ClientChatEvent`

**Client-only code**:
- `Minecraft.getInstance()`
- `LocalPlayer`
- Any rendering code
- Client-side GUIs

**Example**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE, value = Dist.CLIENT)
public class ClientEvents {
    @SubscribeEvent
    public static void onClientTick(TickEvent.ClientTickEvent event) {
        Minecraft mc = Minecraft.getInstance();  // ✓ Safe (client-only class)
        // Client logic
    }
}
```

---

### Server-Only Handlers

**Indicators**:
```java
@Mod.EventBusSubscriber(value = Dist.DEDICATED_SERVER)
```

**Event types that are server-only**:
- `ServerStartingEvent`
- `ServerStoppingEvent`
- `CommandEvent`

**Server-only code**:
- `MinecraftServer` operations
- World modification
- Player data persistence

---

### Both-Sides Handlers

**No Dist annotation** = runs on both CLIENT and SERVER

**Example**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)  // No value = both sides
public class CommonEvents {
    @SubscribeEvent
    public static void onPlayerLogin(PlayerEvent.PlayerLoggedInEvent event) {
        // Runs on both sides
        if (!event.getEntity().level().isClientSide) {
            // Server-side logic
        }
    }
}
```

**Safe patterns for both-sides handlers**:
```java
// Check side before using side-specific code
if (!level.isClientSide) {
    // Server-side only
}

if (level.isClientSide) {
    // Client-side only (but safer to use @OnlyIn)
}
```

---

## Performance Analysis

**Objective**: Find all handlers for performance-critical events (tick events)

### Finding Tick Handlers

**Search**:
```
search_in_files_by_text("TickEvent", fileMask="*.java")
```

**Analyze**:
1. How many tick handlers exist?
2. What do they do?
3. Are they optimized?

**Example analysis**:
```
Found 5 tick handlers:
1. ClientEvents.onClientTick - Renders HUD overlay (client-only) ✓
2. ServerEvents.onPlayerTick - Updates player state (server-only) ✓
3. DataSync.onServerTick - Syncs data every 20 ticks (optimized) ✓
4. DebugHandler.onClientTick - Logs every tick (⚠️ PERFORMANCE ISSUE)
5. EntityTracker.onWorldTick - Tracks 1000+ entities (⚠️ NEEDS OPTIMIZATION)

Recommendations:
- Remove/disable DebugHandler in production
- Optimize EntityTracker (use spatial partitioning)
```

---

## Common Event Handler Patterns

### Pattern 1: Client Tick Monitoring

**Purpose**: Update client-side state every tick

**Example**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE, value = Dist.CLIENT)
public class ClientEvents {
    @SubscribeEvent
    public static void onClientTick(TickEvent.ClientTickEvent event) {
        if (event.phase == TickEvent.Phase.END) {
            Minecraft mc = Minecraft.getInstance();
            if (mc.player != null) {
                // Update client state
            }
        }
    }
}
```

**Key features**:
- CLIENT-only annotation
- Phase check (usually END)
- Null check for player

---

### Pattern 2: Player Action Handling

**Purpose**: Handle player events (login, death, etc.)

**Example**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class ServerEvents {
    @SubscribeEvent
    public static void onPlayerLogin(PlayerEvent.PlayerLoggedInEvent event) {
        Player player = event.getEntity();
        if (!player.level().isClientSide) {
            // Server-side logic: Load player data, send welcome message, etc.
        }
    }
}
```

**Key features**:
- FORGE bus (gameplay event)
- Side check (server-side only logic)
- Static method (automatic registration)

---

### Pattern 3: Block Interaction

**Purpose**: Handle block break/place events

**Example**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class BlockEvents {
    @SubscribeEvent
    public static void onBlockBreak(BlockEvent.BreakEvent event) {
        if (event.getState().is(Blocks.DIAMOND_ORE)) {
            event.setCanceled(true);  // Prevent breaking diamond ore
        }
    }
}
```

**Key features**:
- Cancelable event
- Block state checking
- Common for custom mechanics

---

### Pattern 4: Entity Lifecycle

**Purpose**: Handle entity spawn/death/hurt events

**Example**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class EntityEvents {
    @SubscribeEvent
    public static void onLivingDeath(LivingDeathEvent event) {
        if (event.getEntity() instanceof Player player) {
            if (!player.level().isClientSide) {
                // Handle player death (drop custom items, etc.)
            }
        }
    }
}
```

**Key features**:
- Type checking with instanceof
- Side check
- Common for custom drops/mechanics

---

## Integration with events-and-lifecycle-expert

The `events-and-lifecycle-expert` agent uses event handler search to:

1. **Find reference patterns**:
   - "Show me existing PlayerTickEvent handlers"
   - Navigator provides examples
   - Expert follows pattern

2. **Verify existing handlers**:
   - Expert creates new handler
   - Navigator finds similar handlers
   - Compare for consistency

3. **Identify conflicts**:
   - Navigator finds all handlers for event type
   - Expert checks if new handler conflicts

---

## Complete Workflow Example

**Task**: Find all event handlers, categorize by bus and side

**Step-by-step**:
```
Step 1: Find all handlers
→ search_in_files_by_text("@SubscribeEvent", fileMask="*.java")
→ Found in: ClientEvents.java, ServerEvents.java, CommonEvents.java

Step 2: Analyze ClientEvents.java
→ Read file
→ Class annotation: @Mod.EventBusSubscriber(bus = FORGE, value = CLIENT)
→ Handlers:
   - onClientTick(ClientTickEvent) - Updates HUD
   - onRenderTick(RenderTickEvent) - Custom rendering
   - onInput(InputEvent.Key) - Key bindings
→ Bus: FORGE, Side: CLIENT-only

Step 3: Analyze ServerEvents.java
→ Read file
→ Class annotation: @Mod.EventBusSubscriber(bus = FORGE)
→ Handlers:
   - onPlayerLogin(PlayerLoggedInEvent) - Welcome message
   - onPlayerTick(PlayerTickEvent) - State updates
→ Bus: FORGE, Side: BOTH (with server-side checks)

Step 4: Analyze CommonEvents.java
→ Read file
→ Class annotation: @Mod.EventBusSubscriber(modid = MODID, bus = MOD)
→ Handlers:
   - onCommonSetup(FMLCommonSetupEvent) - Initialization
   - onClientSetup(FMLClientSetupEvent) - Client init
→ Bus: MOD, Side: Setup phase

Step 5: Report
→ Found 8 event handlers across 3 files:

**MOD Bus** (Lifecycle):
- CommonEvents.onCommonSetup (both sides)
- CommonEvents.onClientSetup (client-only)

**FORGE Bus - Client** (Gameplay):
- ClientEvents.onClientTick
- ClientEvents.onRenderTick
- ClientEvents.onInput

**FORGE Bus - Common** (Gameplay):
- ServerEvents.onPlayerLogin (server checks)
- ServerEvents.onPlayerTick (server checks)

All handlers follow proper patterns with side safety.
```

---

## Summary

**Key Takeaways**:
- 🔍 Use @SubscribeEvent annotation search for discovery
- 📊 Bus type determines when handler runs (MOD vs FORGE)
- 🖥️ Side annotations critical for crash prevention
- ✅ Static methods = automatic registration
- 🎯 Event type determines appropriate bus

**Tool Performance**:
- Annotation search: <300ms
- Event type search: <400ms
- Complete analysis: <1 second

**Common Pitfalls**:
- ❌ Wrong bus type (MOD event on FORGE bus or vice versa)
- ❌ Client code without @OnlyIn annotation
- ❌ Non-static handler without manual registration
- ❌ Missing phase/side checks in event logic
