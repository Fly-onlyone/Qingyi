# Event Handler Documentation Patterns

This file provides patterns for documenting event handlers in Minecraft mods.

## Forge/NeoForge Event Handler Documentation

### Event Handler Class Structure

**Pattern**: Static methods in @Mod.EventBusSubscriber class

```markdown
### Event Handler: ModEvents

**Location**: `com.example.mymod.events.ModEvents`
**Event Bus**: FORGE (gameplay events)
**Registration**: Automatic via @Mod.EventBusSubscriber

This class handles all FORGE bus events related to player interactions and entity behavior.

#### Event: Player Join

**Method**: `onPlayerJoin(PlayerEvent.PlayerLoggedInEvent)`
**Trigger**: When a player joins the server
**Side**: Server only
**Priority**: NORMAL

**Purpose**: Load player data and send welcome message

**Implementation**:
```java
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    Player player = event.getEntity();

    // Only run on server
    if (player.level().isClientSide) return;

    // Load player data
    PlayerDataService.getInstance().loadPlayerData(player);

    // Send welcome message
    player.sendSystemMessage(Component.literal("Welcome to the server!"));
}
```

**Data Flow**:
1. Player joins → Event fired on server
2. PlayerDataService loads persisted data from SavedData
3. Welcome message sent to player's chat

**Error Handling**:
- If data loading fails, creates new default data
- Message sending is safe (won't crash if player disconnects)

**Testing**:
- Join server → Check console for data load message
- Verify player data initialized correctly
- Confirm welcome message appears in chat
```

### MOD Bus vs FORGE Bus

Document which bus each event uses:

```markdown
## Event Bus Guide

### MOD Bus Events (Lifecycle)
These events fire during mod initialization and are used for registration and setup.

**Common MOD Bus Events**:
- `FMLCommonSetupEvent` - Common initialization (runs on both sides)
- `FMLClientSetupEvent` - Client-only initialization
- `FMLServerSetupEvent` - Server-only initialization
- `RegisterEvent` - Registry registration (items, blocks, etc.)

**Example**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Mod.EventBusSubscriber.Bus.MOD)
public class ModLifecycle {
    @SubscribeEvent
    public static void onCommonSetup(FMLCommonSetupEvent event) {
        // Setup that runs on both client and server
    }
}
```

### FORGE Bus Events (Gameplay)
These events fire during gameplay and are used for game logic.

**Common FORGE Bus Events**:
- `PlayerEvent.PlayerLoggedInEvent` - Player joins server
- `LivingDeathEvent` - Entity dies
- `BlockEvent.BreakEvent` - Block broken
- `TickEvent.ServerTickEvent` - Server tick
- `TickEvent.ClientTickEvent` - Client tick

**Example**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Mod.EventBusSubscriber.Bus.FORGE)
public class GameplayEvents {
    @SubscribeEvent
    public static void onPlayerDeath(LivingDeathEvent event) {
        if (event.getEntity() instanceof Player player) {
            // Handle player death
        }
    }
}
```
```

---

## Tick Handler Documentation

### Client Tick Handler Example

```markdown
### System: Audio Playback Updates

**Purpose**: Update audio playback state every tick on the client

**Tick Handler**: `ClientTickEvent`
**Frequency**: Every tick (20 times per second)
**Performance**: O(1) - Direct HashMap lookup

**Implementation**:
```java
@SubscribeEvent
public static void onClientTick(TickEvent.ClientTickEvent event) {
    // Only run at END phase (after vanilla logic)
    if (event.phase != TickEvent.Phase.END) return;

    Minecraft mc = Minecraft.getInstance();
    if (mc.level == null || mc.player == null) return;

    // Update audio playback
    MusicService.getInstance().tick();
}
```

**Why END Phase?**
- START phase: Before vanilla game logic
- END phase: After vanilla game logic (safer for most operations)

**Performance Considerations**:
- Runs 20 times per second
- Must complete in <50ms to avoid lag
- Avoid expensive operations (use interval gating if needed)

**Interval Gating Example**:
```java
private static int tickCounter = 0;

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase != TickEvent.Phase.END) return;

    tickCounter++;
    if (tickCounter % 20 != 0) return;  // Only run once per second

    // Expensive operation here (runs 1/sec instead of 20/sec)
}
```
```

---

## Event Priority Documentation

### Priority Levels

```markdown
## Event Priority System

Events can specify priority to control execution order relative to other listeners.

**Priority Levels** (execution order):
1. `HIGHEST` - Runs first
2. `HIGH`
3. `NORMAL` (default)
4. `LOW`
5. `LOWEST` - Runs last

**Syntax**:
```java
@SubscribeEvent(priority = EventPriority.HIGH)
public static void onEvent(SomeEvent event) {
    // Runs before NORMAL priority handlers
}
```

**When to Use Non-Default Priority**:

**HIGHEST/HIGH**:
- Need to run before other mods
- Setting default values that other mods might override
- Example: "Set default loot before other mods modify it"

**LOW/LOWEST**:
- Need to run after other mods
- Finalizing values after other mods have modified them
- Example: "Apply final balance adjustments after all mod modifications"

**NORMAL** (default):
- Most cases - use this unless you have a specific reason

**Example with Priority**:
```java
// This mod needs to modify loot AFTER other mods add their drops
@SubscribeEvent(priority = EventPriority.LOW)
public static void onLootTableLoad(LootTableLoadEvent event) {
    // Runs after most other mods have modified the loot table
    if (event.getName().equals(BuiltInLootTables.VILLAGE_ARMORER)) {
        // Add custom loot at the end
    }
}
```
```

---

## Cancellable Event Documentation

### Pattern for Cancellable Events

```markdown
### Event: Block Break Prevention

**Event**: `BlockEvent.BreakEvent`
**Cancellable**: Yes
**Result**: If cancelled, block doesn't break

**Purpose**: Prevent breaking protected blocks

**Implementation**:
```java
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    BlockPos pos = event.getPos();
    Level level = (Level) event.getLevel();

    // Check if block is protected
    if (ProtectionService.isProtected(level, pos)) {
        // Cancel the event
        event.setCanceled(true);

        // Notify player
        if (event.getPlayer() instanceof ServerPlayer player) {
            player.sendSystemMessage(
                Component.literal("This block is protected!")
            );
        }
    }
}
```

**Important**: Always check `isCancelable()` before calling `setCanceled(true)`

**Testing**:
- Place protected block
- Try to break it → Should be prevented
- Message should appear in chat
- Block should remain intact
```

---

## Client/Server Event Documentation

### Client-Only Events

```markdown
## Client-Only Event: Rendering

**Event**: `RenderLevelStageEvent`
**Side**: Client ONLY
**Purpose**: Render custom overlays or HUD elements

**CRITICAL**: This event ONLY exists on the client. Never import or reference in common code!

**Implementation**:
```java
// In client/ package ONLY
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE, value = Dist.CLIENT)
public class ClientRenderEvents {
    @SubscribeEvent
    public static void onRenderLevel(RenderLevelStageEvent event) {
        if (event.getStage() == RenderLevelStageEvent.Stage.AFTER_WEATHER) {
            // Custom rendering here
        }
    }
}
```

**Client/Server Separation**:
- Class annotated with `value = Dist.CLIENT`
- Must be in `client/` package
- Never called on dedicated servers
```

### Server-Only Events

```markdown
## Server-Only Event: World Data Saving

**Event**: `LevelEvent.Save`
**Side**: Server ONLY
**Purpose**: Save custom world data

**Implementation**:
```java
@SubscribeEvent
public static void onWorldSave(LevelEvent.Save event) {
    LevelAccessor level = event.getLevel();

    // Only run on server
    if (level.isClientSide()) return;

    if (level instanceof ServerLevel serverLevel) {
        // Save custom data
        CustomSavedData data = CustomSavedData.get(serverLevel);
        data.setDirty();  // Mark for saving
    }
}
```

**Note**: Even though this is server-only, always check `isClientSide()` defensively
```

---

## Fabric Event Handler Documentation

### Fabric Event Pattern

Fabric uses callbacks instead of @SubscribeEvent annotations.

```markdown
### Event Handler: Player Join (Fabric)

**Location**: `com.example.mymod.events.EventHandlers`
**Event**: `ServerPlayConnectionEvents.JOIN`
**Registration**: Manual in ModInitializer

**Setup**:
```java
public class MyModInitializer implements ModInitializer {
    @Override
    public void onInitialize() {
        // Register event handlers
        ServerPlayConnectionEvents.JOIN.register(EventHandlers::onPlayerJoin);
    }
}
```

**Handler Implementation**:
```java
public class EventHandlers {
    public static void onPlayerJoin(ServerPlayNetworkHandler handler,
                                      PacketSender sender,
                                      MinecraftServer server) {
        ServerPlayerEntity player = handler.getPlayer();

        // Load player data
        PlayerDataService.loadPlayerData(player);

        // Send welcome message
        player.sendMessage(Text.literal("Welcome!"), false);
    }
}
```

**Key Differences from Forge**:
- No @SubscribeEvent annotation
- Explicit registration required
- Different method signatures
- Text instead of Component
```

---

## Event Documentation Template

Use this template when documenting event handlers:

```markdown
### Event: [Event Name]

**Class**: `package.EventClass`
**Event**: `EventName`
**Bus**: MOD / FORGE / Fabric Callback
**Cancellable**: Yes / No
**Side**: Client / Server / Both
**Priority**: HIGHEST / HIGH / NORMAL / LOW / LOWEST

**Purpose**: [What this event handler does]

**Implementation**:
```java
[Full code example]
```

**Trigger Conditions**:
- Condition 1: When X happens
- Condition 2: If Y is true

**Data Flow**:
1. Step 1: [What happens first]
2. Step 2: [What happens next]
3. Step 3: [Final result]

**Edge Cases**:
- Edge case 1: [How it's handled]
- Edge case 2: [How it's handled]

**Performance**:
- Frequency: [How often this runs]
- Complexity: O(1) / O(n) / etc.
- Optimization notes: [Any performance considerations]

**Testing**:
- Test 1: [How to verify this works]
- Test 2: [Expected behavior]

**See Also**:
- [Related event 1]
- [Related system]
```

---

## Common Event Documentation Mistakes

- ❌ Not specifying which bus (MOD vs FORGE)
- ❌ Forgetting to document client/server separation
- ❌ Not mentioning if event is cancellable
- ❌ Omitting performance implications for tick handlers
- ❌ Missing error handling documentation
- ❌ Not showing both Forge and Fabric patterns for multi-loader projects

---

## See Also

- [Main Documentation Patterns](./SKILL.md)
- [Registry Documentation Examples](./registry-docs-examples.md)
- [Mixin Documentation Guide](./mixin-documentation.md)
