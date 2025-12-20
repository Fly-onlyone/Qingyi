# World Compatibility Guide - Avoiding Save-Breaking Changes

This guide explains how registry names affect world saves, when changes break compatibility, and strategies for safe refactoring in released mods.

## Overview

**Core Principle**: Once a mod is released to players, **registry names are permanent**.

**Why?**: Minecraft worlds store items, blocks, and entities by their registry names. Changing these names makes saved data unloadable.

**Impact**: Players lose items from inventories, blocks are replaced with air, entities disappear.

---

## Table of Contents

1. [How Minecraft Stores Data](#how-minecraft-stores-data)
2. [What Changes Break Worlds](#what-changes-break-worlds)
3. [What Changes Are Safe](#what-changes-are-safe)
4. [Migration Strategies](#migration-strategies)
5. [Testing World Compatibility](#testing-world-compatibility)
6. [Documenting Breaking Changes](#documenting-breaking-changes)
7. [Advanced: Alias Systems](#advanced-alias-systems)

---

## How Minecraft Stores Data

### Registry Name Storage

**When a player saves**:
```
Player inventory:
- Slot 0: "modid:ruby_sword" (x5)
- Slot 1: "modid:copper_pickaxe" (x1)

Chunk data:
- Block at (100, 64, 200): "modid:ruby_ore"
- Block at (101, 64, 200): "modid:copper_block"

Entity data:
- UUID xyz: "modid:custom_zombie" at (150, 65, 250)
```

**These strings are saved to disk**:
```
save/level.dat
save/playerdata/[uuid].dat
save/region/r.0.0.mca
```

### Registry Name Lookup

**When world loads**:
```
1. Minecraft reads "modid:ruby_sword" from save file
2. Looks up "modid:ruby_sword" in current registry
3. If found: Load item into inventory
4. If NOT found: Delete entry (item disappears!)
```

**Example of broken compatibility**:
```java
// Version 1.0 (released to players)
ITEMS.register("ruby_sword", () -> new SwordItem(...))
// Players get ruby swords, save world

// Version 2.0 (registry name changed)
ITEMS.register("sapphire_sword", () -> new SwordItem(...))
// World loads, looks for "ruby_sword", not found � DELETED
```

---

## What Changes Break Worlds

### 1. Registry Name Changes

**BREAKS WORLDS** =4

```java
// Before (v1.0)
ITEMS.register("copper_sword", () -> new SwordItem(...))

// After (v2.0)
ITEMS.register("bronze_sword", () -> new SwordItem(...))
```

**Impact**:
- All copper swords deleted from player inventories
- All copper sword blocks removed from world
- All copper sword entities despawn

**Severity**: Critical - Data loss

---

### 2. Registry Removal

**BREAKS WORLDS** =4

```java
// Before (v1.0)
ITEMS.register("copper_sword", () -> new SwordItem(...))
ITEMS.register("bronze_sword", () -> new SwordItem(...))

// After (v2.0)
// Removed copper_sword registration entirely
ITEMS.register("bronze_sword", () -> new SwordItem(...))
```

**Impact**:
- All copper swords deleted
- No replacement, just gone

**Severity**: Critical - Data loss

---

### 3. Mod ID Changes

**BREAKS WORLDS** =4

```java
// Before (v1.0)
public static final String MODID = "examplemod";
ITEMS.register("ruby_sword", ...)  // Becomes "examplemod:ruby_sword"

// After (v2.0)
public static final String MODID = "awesomemod";
ITEMS.register("ruby_sword", ...)  // Becomes "awesomemod:ruby_sword"
```

**Impact**:
- ALL items/blocks/entities deleted (different mod ID)
- World sees "examplemod:ruby_sword" as unknown

**Severity**: Catastrophic - Complete data loss

---

### 4. Registry Type Changes

**BREAKS WORLDS** =4

```java
// Before (v1.0)
ITEMS.register("copper_block", () -> new BlockItem(...))
// Registered as ITEM

// After (v2.0)
BLOCKS.register("copper_block", () -> new Block(...))
// Registered as BLOCK (different registry)
```

**Impact**:
- Item version deleted from inventories
- Block version won't load from old saves (wrong registry type)

**Severity**: Critical - Data loss

---

## What Changes Are Safe

### 1. Java Symbol Names

**SAFE** 

```java
// Before
public static final RegistryObject<Item> COPPER_SWORD = ITEMS.register(
    "copper_sword",  // Registry name (UNCHANGED)
    () -> new SwordItem(...)
);

// After
public static final RegistryObject<Item> BRONZE_SWORD = ITEMS.register(
    "copper_sword",  // Registry name (UNCHANGED)
    () -> new SwordItem(...)
);
```

**Why safe**: Registry name `"copper_sword"` unchanged, world saves still work.

**Use case**: Refactor code names without breaking saves.

---

### 2. Class Name Changes

**SAFE** 

```java
// Before
public class CopperSword extends SwordItem { ... }
ITEMS.register("copper_sword", () -> new CopperSword())

// After
public class BronzeSword extends SwordItem { ... }
ITEMS.register("copper_sword", () -> new BronzeSword())
```

**Why safe**: Registry name unchanged, just different class implementing it.

---

### 3. Implementation Changes

**SAFE** 

```java
// Before
ITEMS.register("copper_sword", () -> new SwordItem(Tiers.IRON, 3, -2.4F, ...))

// After
ITEMS.register("copper_sword", () -> new SwordItem(Tiers.DIAMOND, 5, -2.4F, ...))
```

**Why safe**: Same registry name, different properties. Existing items get new properties.

**Note**: This can surprise players if damage changes dramatically!

---

### 4. Resource File Names (if registry unchanged)

**SAFE** 

```
// Before
assets/modid/models/item/copper_sword.json
assets/modid/textures/item/copper_sword.png

// After
assets/modid/models/item/bronze_sword.json
assets/modid/textures/item/bronze_sword.png

// BUT registry name still "copper_sword"
ITEMS.register("copper_sword", ...)
```

**Why safe**: Registry name unchanged, just cosmetic resource renaming.

**Note**: Model references must be updated to use new names!

---

### 5. Method/Field Renames

**SAFE** 

```java
// Before
public static void registerItems() { ... }

// After
public static void initializeItems() { ... }
```

**Why safe**: No registry impact, pure code refactoring.

---

## Migration Strategies

### Strategy 1: Never Change (Recommended for Released Mods)

**Approach**: Keep registry name forever, only rename Java symbols.

```java
// Initial release
public static final RegistryObject<Item> COPPER_SWORD = ITEMS.register(
    "copper_sword",  // PERMANENT
    () -> new SwordItem(...)
);

// Future refactoring (SAFE)
public static final RegistryObject<Item> BRONZE_THEMED_SWORD = ITEMS.register(
    "copper_sword",  // Keep original name
    () -> new SwordItem(...)
);
```

**Pros**:
-  No world breaking
-  No migration needed
-  Simple

**Cons**:
- L Registry name doesn't match code (minor confusion)

**Best for**: Most mods, especially popular ones.

---

### Strategy 2: Add Alias (Advanced)

**Approach**: Register new name, but keep old name as alias.

**Forge 1.20+**:
```java
// New registration
ITEMS.register("bronze_sword", () -> new SwordItem(...))

// Alias old name to new
@SubscribeEvent
public static void registerAliases(MissingMappings event) {
    for (MissingMappings.Mapping mapping : event.getMappings(ForgeRegistries.ITEMS)) {
        if (mapping.getKey().toString().equals("modid:copper_sword")) {
            mapping.remap(ModItems.BRONZE_SWORD.get());
        }
    }
}
```

**How it works**:
1. World loads, looks for "modid:copper_sword"
2. Not found in registry
3. Alias system remaps to "modid:bronze_sword"
4. Item loads successfully, saves as new name

**Pros**:
-  Graceful migration
-  Old saves work
-  Eventually standardizes to new name

**Cons**:
- L Complex to implement
- L Must maintain alias forever (or for several versions)
- L Risk of bugs

**Best for**: Major refactors, professional mods.

---

### Strategy 3: Document Breaking Change (For Major Versions)

**Approach**: Change registry name, document clearly, release as major version.

```java
// Version 1.x.x
ITEMS.register("copper_sword", ...)

// Version 2.0.0 (BREAKING)
ITEMS.register("bronze_sword", ...)
```

**Documentation**:
```markdown
## Version 2.0.0 - BREAKING CHANGES

� Registry Names Changed �

The following items have been renamed:
- `copper_sword` � `bronze_sword`
- `copper_pickaxe` � `bronze_pickaxe`

**Impact**:
- Existing worlds will LOSE these items from inventories
- Blocks will be REMOVED from the world

**Recommendation**:
- Start a fresh world with version 2.0.0
- OR use the migration command: `/modid migrate`

**For Advanced Users**:
- Use NBT editor to rename items in save files
- See migration guide: https://example.com/migration
```

**Pros**:
-  Clean break, fresh start
-  Simplifies codebase
-  Clear version boundary

**Cons**:
- L Players lose data
- L Negative community reaction possible
- L May split community (some stay on 1.x)

**Best for**: Complete rewrites, alpha/beta mods, pre-1.0 versions.

---

### Strategy 4: Parallel Registration (Temporary)

**Approach**: Register both old and new, deprecate old.

```java
// Version 1.5.0 (transition)
public static final RegistryObject<Item> COPPER_SWORD = ITEMS.register(
    "copper_sword",
    () -> new SwordItem(...)  // Old name, still works
);

public static final RegistryObject<Item> BRONZE_SWORD = ITEMS.register(
    "bronze_sword",
    () -> new SwordItem(...)  // New name, functionally same
);

// Display warning tooltip on copper_sword
@Override
public void appendHoverText(ItemStack stack, Level level, List<Component> tooltip, TooltipFlag flag) {
    tooltip.add(Component.literal("� Deprecated! Use Bronze Sword instead").withStyle(ChatFormatting.RED));
}

// Version 2.0.0 (remove old)
// Remove COPPER_SWORD registration
```

**Pros**:
-  Gradual migration
-  Players have time to switch
-  Old saves still work

**Cons**:
- L Duplicate items in creative menu
- L Confusing for new players
- L Eventually still breaks old worlds

**Best for**: Popular mods with advance notice.

---

## Testing World Compatibility

### Test Procedure

**Purpose**: Verify that refactoring doesn't break existing saves.

**Setup**:
```
1. Build mod version 1.0 (before refactoring)
2. Create test world
3. Get test items/blocks
4. Save and exit
5. Build mod version 2.0 (after refactoring)
6. Load test world
7. Verify items/blocks still exist
```

### Detailed Steps

**Step 1: Create Test World (v1.0)**
```
1. gradlew build
2. Launch game (runClient)
3. Create new world: "Refactoring_Test"
4. Open creative inventory
5. Get items to test:
   - Ruby Sword x64
   - Ruby Pickaxe x64
   - Ruby Block x64
6. Place some blocks in world
7. Save and exit
```

**Step 2: Perform Refactoring**
```
Execute planned refactoring:
- Rename Java symbols
- Update registry names (if needed)
- Update resource files
- Build mod
```

**Step 3: Load Test World (v2.0)**
```
1. gradlew build
2. Launch game (runClient)
3. Load "Refactoring_Test" world
4. Open inventory
5. Check items:
    Expected: Items still present (if registry name unchanged)
   L Expected: Items deleted (if registry name changed)
```

**Step 4: Check Console Logs**
```
Look for warnings:
- "Missing registry entries for modid:ruby_sword"
  � Registry name changed or removed
- "Successfully remapped modid:ruby_sword to modid:sapphire_sword"
  � Alias working correctly
```

### Automated Test Script

```bash
#!/bin/bash
# test-world-compatibility.sh

echo "=== World Compatibility Test ==="

# Build v1.0
echo "Building version 1.0..."
git checkout v1.0
./gradlew build

# Create test world (manual step)
echo "1. Launch game with: ./gradlew runClient"
echo "2. Create world 'Compatibility_Test'"
echo "3. Get test items and save"
echo "Press Enter when done..."
read

# Build v2.0
echo "Building version 2.0..."
git checkout v2.0
./gradlew build

# Load test world (manual step)
echo "1. Launch game with: ./gradlew runClient"
echo "2. Load world 'Compatibility_Test'"
echo "3. Verify items still exist"
echo "Press Enter when done..."
read

echo "Test complete. Check results above."
```

---

## Documenting Breaking Changes

### Changelog Entry Template

```markdown
## [2.0.0] - 2024-XX-XX

### � BREAKING CHANGES

#### Registry Name Changes

The following registry names have been changed:

| Old Name | New Name | Impact |
|----------|----------|--------|
| `copper_sword` | `bronze_sword` | Items deleted from inventories |
| `copper_block` | `bronze_block` | Blocks replaced with air |
| `copper_ore` | `bronze_ore` | Ore blocks replaced with air |

**What This Means**:
- L Existing worlds will LOSE these items/blocks
- � Recommend starting a fresh world with 2.0.0
- 9 Worlds from 1.x will still load, but items will be gone

**Migration Guide**:
For advanced users who want to migrate existing worlds, see:
https://example.com/docs/migration-2.0.0

### Added
- New Bronze item tier with improved stats
- New textures and models for all bronze items

### Changed
- Improved performance of item registration
- Refactored item class hierarchy

### Removed
- Copper items (replaced by Bronze)
```

### In-Game Warning

**Add warning on first load**:
```java
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    Player player = event.getEntity();
    ServerLevel level = (ServerLevel) player.level();

    // Check if world was created with old version
    if (isOldWorldVersion(level)) {
        player.sendSystemMessage(
            Component.literal("� Warning: This world was created with an older version of ExampleMod.")
                .withStyle(ChatFormatting.RED)
        );
        player.sendSystemMessage(
            Component.literal("Some items may be missing due to registry changes.")
                .withStyle(ChatFormatting.YELLOW)
        );
        player.sendSystemMessage(
            Component.literal("See changelog for details: https://example.com/changelog")
                .withStyle(ChatFormatting.BLUE)
        );
    }
}
```

---

## Advanced: Alias Systems

### Forge Missing Mappings

**Purpose**: Remap old registry names to new ones.

**Implementation**:

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Mod.EventBusSubscriber.Bus.MOD)
public class RegistryMigration {

    @SubscribeEvent
    public static void onMissingMappingsItem(MissingMappings<Item> event) {
        for (MissingMappings.Mapping<Item> mapping : event.getMappings()) {
            String key = mapping.getKey().toString();

            // Remap copper to bronze
            if (key.equals("modid:copper_sword")) {
                mapping.remap(ModItems.BRONZE_SWORD.get());
                LOGGER.info("Remapped {} to bronze_sword", key);
            }
            else if (key.equals("modid:copper_pickaxe")) {
                mapping.remap(ModItems.BRONZE_PICKAXE.get());
                LOGGER.info("Remapped {} to bronze_pickaxe", key);
            }
            // Add more mappings as needed
        }
    }

    @SubscribeEvent
    public static void onMissingMappingsBlock(MissingMappings<Block> event) {
        for (MissingMappings.Mapping<Block> mapping : event.getMappings()) {
            String key = mapping.getKey().toString();

            if (key.equals("modid:copper_block")) {
                mapping.remap(ModBlocks.BRONZE_BLOCK.get());
                LOGGER.info("Remapped {} to bronze_block", key);
            }
        }
    }
}
```

**How It Works**:
1. World loads, Minecraft tries to find "modid:copper_sword"
2. Not found in current registry
3. Fires `MissingMappings` event
4. Your handler remaps to new item
5. World saves with new name on next save

**Lifecycle**:
```
Version 1.0:   copper_sword registered
Version 2.0:   bronze_sword registered + alias copper � bronze
Version 3.0:   bronze_sword registered (alias can be removed)
```

---

### NeoForge Alias System

**NeoForge 1.20+**:

Similar to Forge, use `MissingMappings` event.

```java
@SubscribeEvent
public static void onMissingMappings(MissingMappings event) {
    event.getAllMappings(BuiltInRegistries.ITEM).forEach(mapping -> {
        if (mapping.getKey().location().toString().equals("modid:copper_sword")) {
            mapping.remap(ModItems.BRONZE_SWORD.get());
        }
    });
}
```

---

### Fabric Registry Sync

**Fabric approach**:

Fabric doesn't have built-in alias system. Workarounds:

**Option 1: Keep old registration**
```java
// Keep both registered
public static final Item COPPER_SWORD = Registry.register(
    Registries.ITEM,
    new Identifier(MODID, "copper_sword"),
    new SwordItem(...)
);

public static final Item BRONZE_SWORD = Registry.register(
    Registries.ITEM,
    new Identifier(MODID, "bronze_sword"),
    new SwordItem(...)
);
```

**Option 2: Manual NBT migration**
```java
// On world load, scan player inventories and replace old items
// (Complex, not recommended)
```

---

## Best Practices Summary

### DO 

1. **Use rename_refactoring for Java symbols**
   - Safe, scope-aware, no world impact

2. **Keep registry names permanent after release**
   - Prevents data loss
   - Maintains world compatibility

3. **Test with existing saves before releasing**
   - Create test world
   - Verify items persist

4. **Document breaking changes clearly**
   - Changelog entry
   - Version number (major version bump)
   - In-game warnings

5. **Use alias systems for critical migrations**
   - Graceful transition
   - Maintain compatibility

### DON'T L

1. **Don't change registry names in minor versions**
   - Use major version (2.0.0) for breaking changes

2. **Don't silently remove registry entries**
   - Always warn users
   - Provide migration path

3. **Don't change mod ID**
   - Catastrophic data loss
   - Never worth it

4. **Don't test only in fresh worlds**
   - Must test with existing saves

5. **Don't assume players read changelogs**
   - Add in-game warnings
   - Make impact obvious

---

## Quick Reference

### Safe Changes Checklist

-  Rename Java field/method/class
-  Move class to different package
-  Change item implementation details
-  Update resource file names (if model refs updated)
-  Refactor code structure

### Dangerous Changes Checklist

- =4 Rename registry string
- =4 Remove registry entry
- =4 Change mod ID
- =4 Change registry type (ITEM � BLOCK)

### Decision Tree

```
User wants to rename item
  �
Has mod been released?
    No (alpha/dev) � Safe to change registry
    Yes (released)
      �
    Is Java symbol or registry name?
        Java symbol � SAFE, use rename_refactoring
        Registry name
          �
        Critical rename?
            No � Keep old name, rename Java only
            Yes
              �
            Choose strategy:
                Add alias (graceful migration)
                Document breaking change (major version)
                Parallel registration (gradual deprecation)
```

---

## Related Documentation

- [Refactoring Workflow](./refactoring-workflow.md) - Complete refactoring process
- [Refactoring Scenarios](./refactoring-scenarios.md) - Common rename scenarios
- [Resource Synchronization](./resource-synchronization.md) - Keeping resources in sync
- [Refactoring Examples](./refactoring-examples.md) - Real-world examples

Back to [intellij-refactoring-master.md](../../intellij-refactoring-master.md)
