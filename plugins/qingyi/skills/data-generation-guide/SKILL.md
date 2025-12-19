---
name: data-generation-guide
description: Data generation (datagen) for Minecraft mods including recipe generation, loot table generation, block/item model generation, tags, and advancements. Use when automating data pack and resource pack content generation instead of writing JSON manually.
---

# Data Generation Guide

> **TODO**: This is a placeholder skill. Full implementation needed.

## Overview

Data generation (datagen) allows programmatic creation of recipes, loot tables, models, tags, and other JSON data files, reducing manual work and errors.

## Topics to Cover

### Core Concepts

- `runData` run configuration
- Data provider registration
- Output directory structure

### Recipe Generation

- Shaped and shapeless crafting recipes
- Smelting, blasting, smoking recipes
- Recipe advancements
- Custom recipe serializers

### Loot Table Generation

- Block loot tables
- Entity loot tables
- Chest loot tables
- Loot table providers

### Model Generation

- Block state files
- Block models
- Item models
- Model providers and builders

### Tags

- Block tags
- Item tags
- Entity type tags
- Fluid tags

### Other Data

- Advancement generation
- Global loot modifiers
- Worldgen features

## Framework Support

- Forge 1.19-1.20
- NeoForge 1.20-1.21
- Fabric Data Generation

## Real Examples

Common in many mods - check user projects for specific patterns.

## Related Skills

- `forge-registry-api` / `neoforge-registry-api` - Registry integration
- `minecraft-run-configuration-guide` - Running datagen

## Status

**Placeholder** - Awaiting implementation with datagen patterns and best practices.
