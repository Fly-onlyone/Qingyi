---
name: forge-capabilities
description: Forge Capabilities system for attaching custom data to entities, items, chunks, and worlds. Covers capability definition, registration, attachment, serialization, and migration to NeoForge attachment system. Use when implementing custom data on vanilla objects.
---

# Forge Capabilities

> **TODO**: This is a placeholder skill. Full implementation needed.

## Overview

Forge Capabilities allow attaching custom data and behavior to vanilla objects (entities, items, block entities, chunks, worlds) without extending them.

## Topics to Cover

### Capability Basics

- Capability definition and registration
- `ICapabilityProvider` implementation
- `AttachCapabilitiesEvent` for attachment
- Capability invalidation and lazy optionals

### Common Use Cases

- Player data persistence
- Entity-attached inventories
- Item energy/fluid storage
- World-level data

### Serialization

- `ICapabilitySerializable` interface
- NBT read/write
- Data synchronization

### NeoForge Changes

- Migration from capabilities to attachment system
- `AttachmentType` registration
- Simplified API

## Framework Support

- Forge 1.19-1.20 (Capabilities)
- NeoForge 1.20-1.21 (Attachments replace Capabilities)

## Fabric Alternative

Fabric uses Cardinal Components API instead of capabilities.

## Related Skills

- `nbt-serialization-patterns` - Data persistence
- `data-and-persistence-expert` - Broader persistence context

## Status

**Placeholder** - Awaiting implementation with capability patterns and NeoForge migration guide.
