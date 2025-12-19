---
name: fabric-event-system
description: Fabric API event system including callbacks, event phases, custom events, and lifecycle hooks. Use when implementing Fabric event handlers, tick logic, player events, or mod initialization for Fabric/Quilt mods.
---

# Fabric Event System

> **TODO**: This is a placeholder skill. Full implementation needed.

## Overview

This skill provides patterns for the Fabric API event system, which differs significantly from Forge's `@SubscribeEvent` approach.

## Topics to Cover

- Fabric API callbacks vs Forge events
- Event registration pattern
- Common events (ServerTickEvents, PlayerEvents, etc.)
- Event phases and priorities
- Custom event creation
- Lifecycle hooks (onInitialize, onInitializeClient, etc.)
- Mixins for events not covered by Fabric API

## Framework Support

- Fabric 1.19-1.21
- Quilt 1.19-1.21

## Comparison with Forge

Unlike Forge's centralized event bus, Fabric uses callback interfaces:

```java
// Forge pattern
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) { }

// Fabric pattern
ServerTickEvents.END_SERVER_TICK.register(server -> { });
```

## Related Skills

- `forge-event-system` - For comparison and migration
- `mod-lifecycle-patterns` - Initialization and lifecycle

## Status

**Placeholder** - Awaiting implementation with Fabric-specific patterns and examples.
