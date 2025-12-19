---
name: mod-lifecycle-patterns
description: Mod initialization and lifecycle management across Forge, NeoForge, and Fabric. Covers constructor initialization, common setup, client setup, deferred work queue, and startup phases. Use when setting up mod entry points and initialization logic.
---

# Mod Lifecycle Patterns

> **TODO**: This is a placeholder skill. Full implementation needed.

## Overview

This skill covers mod initialization and lifecycle management patterns across different frameworks.

## Topics to Cover

### Forge/NeoForge Lifecycle

- `@Mod` class constructor
- `FMLCommonSetupEvent` - Common setup (runs on both sides)
- `FMLClientSetupEvent` - Client-only setup
- `FMLServerSetupEvent` - Server-only setup
- Deferred work queue (`event.enqueueWork()`)
- IMC (Inter-Mod Communication)

### Fabric Lifecycle

- `ModInitializer` - Common initialization
- `ClientModInitializer` - Client-only
- `DedicatedServerModInitializer` - Server-only
- Entrypoint registration

### Common Patterns

- Registry initialization timing
- Client/server separation
- Data generation setup
- Config loading
- Networking setup

## Framework Support

- Forge 1.19-1.20
- NeoForge 1.20-1.21
- Fabric 1.19-1.21

## Related Skills

- `forge-event-system` / `fabric-event-system` - Event registration timing
- `multi-loader-project-patterns` - Cross-platform initialization

## Status

**Placeholder** - Awaiting implementation with lifecycle patterns from real projects.
