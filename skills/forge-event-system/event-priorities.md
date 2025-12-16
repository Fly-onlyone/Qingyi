---
name: event-priorities
description: Event priority levels, execution order, and cancellation patterns in Forge events. Advanced event handling.
---

# Event Priorities and Cancellation

## EventPriority Levels

### Priority Order (Execution)

1. HIGHEST - Execute first
2. HIGH - Execute before normal
3. NORMAL - Default priority
4. LOW - Execute after normal
5. LOWEST - Execute last

Lower priority sees modifications from higher priority.

## Setting Event Priority

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class ForgeEvents {
    // Default NORMAL priority
    @SubscribeEvent
    public static void onBlockBreak1(BlockEvent.BreakEvent event) {
        // Runs third
    }

    // HIGH priority - runs earlier
    @SubscribeEvent(priority = EventPriority.HIGH)
    public static void onBlockBreak2(BlockEvent.BreakEvent event) {
        // Runs second
    }

    // HIGHEST priority - runs first
    @SubscribeEvent(priority = EventPriority.HIGHEST)
    public static void onBlockBreak3(BlockEvent.BreakEvent event) {
        // Runs first
    }

    // LOWEST priority - runs last
    @SubscribeEvent(priority = EventPriority.LOWEST)
    public static void onBlockBreak4(BlockEvent.BreakEvent event) {
        // Runs fourth
    }
}
```

## Cancellation Behavior

### Cancellable Events

Some events support cancellation (check documentation):
- BlockEvent.BreakEvent
- BlockEvent.EntityPlaceEvent
- Item events
- Living entity damage

### Cancel Pattern

```java
@SubscribeEvent(priority = EventPriority.HIGH)
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    if (shouldPreventBreak(event.getState())) {
        event.setCanceled(true); // Prevent breaking
    }
}
```

### Check if Already Canceled

```java
@SubscribeEvent(priority = EventPriority.LOWEST)
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    if (event.isCanceled()) {
        return; // Already canceled by another mod
    }
    
    // Process
}
```

## Execution Flow with Multiple Handlers

```
BlockEvent.BreakEvent fired

HIGHEST priority handlers
├─ Handler A (HIGHEST) - may cancel
├─ Handler B (HIGHEST)

HIGH priority handlers
├─ Handler C (HIGH) - may cancel
├─ Handler D (HIGH)

NORMAL priority handlers
├─ Handler E (NORMAL) - may cancel
└─ Handler F (NORMAL)

LOW priority handlers
├─ Handler G (LOW) - sees if canceled
└─ Handler H (LOW)

LOWEST priority handlers
└─ Handler I (LOWEST) - last to run
```

## Cancellation vs Result Events

### Cancellable (Boolean)

```java
@SubscribeEvent
public static void onCancellable(BlockEvent.BreakEvent event) {
    if (condition) {
        event.setCanceled(true); // Boolean: true/false
    }
}
```

### Result Events (Enum)

```java
@SubscribeEvent
public static void onResultEvent(Event event) {
    // Result: ALLOW, DENY, DEFAULT
    event.setResult(Event.Result.DENY);
}
```

## Priority Use Cases

### HIGHEST: Validation

Highest priority for setup or validation:

```java
@SubscribeEvent(priority = EventPriority.HIGHEST)
public static void validateBlockBreak(BlockEvent.BreakEvent event) {
    // Check preconditions
    if (!canBreak(event)) {
        event.setCanceled(true);
        return;
    }
}
```

### HIGH: Core Logic

Core mod functionality:

```java
@SubscribeEvent(priority = EventPriority.HIGH)
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    // Main logic
    applyModEffect(event);
}
```

### NORMAL: Standard Handlers

Default behavior:

```java
@SubscribeEvent // Default = NORMAL
public static void normalHandler(BlockEvent.BreakEvent event) {
    // Standard processing
}
```

### LOW: Cleanup

Low priority for cleanup/logging:

```java
@SubscribeEvent(priority = EventPriority.LOW)
public static void logBlockBreak(BlockEvent.BreakEvent event) {
    // Log after main handlers
}
```

### LOWEST: Final Checks

Last chance to process:

```java
@SubscribeEvent(priority = EventPriority.LOWEST)
public static void finalCheck(BlockEvent.BreakEvent event) {
    if (!event.isCanceled()) {
        // Block break confirmed
    }
}
```

## Real-World Example: Damage Reduction

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class LivingDamageHandler {
    // Validate damage
    @SubscribeEvent(priority = EventPriority.HIGHEST)
    public static void validateDamage(LivingEvent.LivingDamageEvent event) {
        if (event.getAmount() < 0) {
            event.setCanceled(true); // Invalid
        }
    }

    // Apply protection
    @SubscribeEvent(priority = EventPriority.HIGH)
    public static void reduceDamage(LivingEvent.LivingDamageEvent event) {
        if (hasProtection(event.getEntity())) {
            float reduced = event.getAmount() * 0.8f; // 20% reduction
            event.setAmount(reduced);
        }
    }

    // Apply immunity
    @SubscribeEvent(priority = EventPriority.NORMAL)
    public static void applyImmunity(LivingEvent.LivingDamageEvent event) {
        if (isImmune(event.getEntity())) {
            event.setCanceled(true);
        }
    }

    // Log final damage
    @SubscribeEvent(priority = EventPriority.LOWEST)
    public static void logDamage(LivingEvent.LivingDamageEvent event) {
        if (!event.isCanceled()) {
            System.out.println("Entity took " + 
                event.getAmount() + " damage");
        }
    }
}
```

## Best Practices

1. Use HIGHEST for setup/validation
2. Use HIGH for core functionality
3. Use NORMAL for standard handlers
4. Use LOW for cleanup/logging
5. Use LOWEST for final checks
6. Always check if event is canceled
7. Document priority expectations
8. Respect other mods' modifications

## Common Mistake: Ignoring Cancellation

```java
// WRONG - ignores cancellation
@SubscribeEvent
public static void badHandler(BlockEvent.BreakEvent event) {
    grantExp(event.getPlayer()); // Grants exp even if canceled!
}

// CORRECT
@SubscribeEvent
public static void goodHandler(BlockEvent.BreakEvent event) {
    if (event.isCanceled()) return;
    grantExp(event.getPlayer()); // Only if not canceled
}
```

Use appropriate priorities and always respect cancellation.
