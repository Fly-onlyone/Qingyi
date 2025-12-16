---
name: event-catalog
description: Complete catalog of common Forge/NeoForge events with signatures and use cases. Comprehensive event reference.
---

# Forge Event Catalog

## Event Bus Overview

**MOD Bus**: Registry events, mod lifecycle
**FORGE Bus**: Gameplay events, tick handlers

## Lifecycle Events (MOD Bus)

### FMLCommonSetupEvent
Fires after registries complete.

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.MOD)
public class ModEvents {
    @SubscribeEvent
    public static void onCommonSetup(FMLCommonSetupEvent event) {
        event.enqueueWork(() -> {
            // Safe to access registered items
        });
    }
}
```

Use cases:
- Initialize content
- Register capabilities
- Set up recipes

### FMLClientSetupEvent
Client-only setup.

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.MOD, value = Dist.CLIENT)
public class ClientEvents {
    @SubscribeEvent
    public static void onClientSetup(FMLClientSetupEvent event) {
        event.enqueueWork(() -> {
            // Register renderers, overlays
        });
    }
}
```

## Player Events (FORGE Bus)

### PlayerEvent.PlayerLoggedInEvent
Player joins world.

```java
@SubscribeEvent
public static void onPlayerLogin(PlayerEvent.PlayerLoggedInEvent event) {
    if (event.getEntity() instanceof ServerPlayer player) {
        // Player logged in
    }
}
```

Use cases:
- Initialize player data
- Send packets
- Award advancements

### PlayerEvent.PlayerLoggedOutEvent
Player leaves world.

```java
@SubscribeEvent
public static void onPlayerLogout(PlayerEvent.PlayerLoggedOutEvent event) {
    ServerPlayer player = (ServerPlayer) event.getEntity();
    // Cleanup player data
}
```

## Tick Events (FORGE Bus)

### TickEvent.ServerTickEvent
Server tick (20 TPS).

```java
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        // Runs once per tick
    }
}
```

### TickEvent.ClientTickEvent
Client tick.

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE, value = Dist.CLIENT)
public class ClientTick {
    @SubscribeEvent
    public static void onClientTick(TickEvent.ClientTickEvent event) {
        if (event.phase == TickEvent.Phase.END) {
            // Client logic
        }
    }
}
```

### TickEvent.PlayerTickEvent
Per-player tick.

```java
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        Player player = event.player;
        // Update player
    }
}
```

### TickEvent.LevelTickEvent
Per-dimension tick.

```java
@SubscribeEvent
public static void onLevelTick(TickEvent.LevelTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        Level level = event.level;
        // Update level
    }
}
```

## Block Events (FORGE Bus)

### BlockEvent.BreakEvent
Block broken.

```java
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    BlockState state = event.getState();
    Player player = event.getPlayer();
    
    if (shouldCancel(state)) {
        event.setCanceled(true);
    }
}
```

### BlockEvent.EntityPlaceEvent
Entity places block.

```java
@SubscribeEvent
public static void onBlockPlace(BlockEvent.EntityPlaceEvent event) {
    BlockState state = event.getPlacedBlock();
    Entity entity = event.getEntity();
}
```

## Item Events (FORGE Bus)

### ItemEvent.ItemStackSetCount
ItemStack count changes.

```java
@SubscribeEvent
public static void onStackCount(ItemEvent.ItemStackSetCount event) {
    ItemStack stack = event.getItemStack();
    int newCount = event.getCount();
}
```

## Entity Events (FORGE Bus)

### EntityEvent.EntityConstructing
Entity created.

```java
@SubscribeEvent
public static void onEntityConstruct(EntityEvent.EntityConstructing event) {
    Entity entity = event.getEntity();
    // Can attach capabilities
}
```

### LivingEvent.LivingTickEvent
Living entity ticks.

```java
@SubscribeEvent
public static void onLivingTick(LivingEvent.LivingTickEvent event) {
    LivingEntity entity = event.getEntity();
    if (event.isCanceled()) return;
    // Update entity
}
```

### LivingEvent.LivingDamageEvent
Entity takes damage.

```java
@SubscribeEvent
public static void onDamage(LivingEvent.LivingDamageEvent event) {
    float damage = event.getAmount();
    if (damage > 10) {
        event.setCanceled(true);
    }
}
```

## World Events (FORGE Bus)

### WorldEvent.Load
World loads.

```java
@SubscribeEvent
public static void onWorldLoad(WorldEvent.Load event) {
    Level level = event.getLevel();
    if (!level.isClientSide) {
        // Server-side
    }
}
```

### WorldEvent.Save
World saves.

```java
@SubscribeEvent
public static void onWorldSave(WorldEvent.Save event) {
    Level level = event.getLevel();
}
```

## Event Event Properties

### Cancellable Events

```java
@SubscribeEvent
public static void onCancelableEvent(BlockEvent.BreakEvent event) {
    if (event.isCanceled()) {
        return; // Other mods canceled it
    }
    
    event.setCanceled(true); // Cancel this event
}
```

### HasResult Events

```java
@SubscribeEvent
public static void onResultEvent(ItemEvent.UseItemFinishEvent event) {
    event.setResult(Event.Result.ALLOW);
    // Options: ALLOW, DENY, DEFAULT
}
```

## Real-World Examples from Apocalypse_TNT

### Server Tick Handler

```java
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        MinecraftServer server = 
            ServerLifecycleHooks.getCurrentServer();
        if (server != null) {
            ApocalypseOrchestrator.getInstance()
                .tick(server);
        }
    }
}
```

### Player Join Event

```java
@SubscribeEvent
public static void onPlayerJoin(
        PlayerEvent.PlayerLoggedInEvent event) {
    if (event.getEntity() instanceof ServerPlayer player) {
        ApocalypseOrchestrator.getInstance()
            .onPlayerLogin(player, player.server);
    }
}
```

## Event Properties Reference

| Property | Type | Use |
|----------|------|-----|
| phase | TickEvent.Phase | START or END |
| side | LogicalSide | SERVER or CLIENT |
| canceled | boolean | Cancel event |
| result | Result | Allow/Deny/Default |

## Best Practices

1. Check event.phase in tick events
2. Check event.side for client/server code
3. Check event.isCanceled() before processing
4. Use MOD bus for registry events
5. Use FORGE bus for gameplay events
6. Respect cancellation by other mods

Comprehensive Forge event reference guide.
