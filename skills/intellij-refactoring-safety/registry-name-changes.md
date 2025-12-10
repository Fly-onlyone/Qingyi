# Registry Name Changes - Impact on World Saves and Migration

This document covers the critical topic of renaming registry names in Minecraft mods and their impact on existing world saves.

## Understanding Registry Names

### What Are Registry Names?

Registry names are **permanent identifiers** stored in world save data:

```java
// Forge/NeoForge
public static final RegistryObject<Item> COPPER_SWORD =
    ITEMS.register("copper_sword", () -> new SwordItem(...));
                    // ↑ This is the registry name (permanent identifier)

// Fabric
public static final Item COPPER_SWORD = Registry.register(
    Registries.ITEM,
    new Identifier("modid", "copper_sword"),  // ↑ Registry name
    new SwordItem(...)
);
```

**Registry names are stored in**:
- Player inventories (`modid:copper_sword` → ItemStack NBT)
- Chest contents (BlockEntity NBT)
- Item entities in the world
- Recipe unlock data
- Advancement progress
- Statistics tracking

---

## Impact of Renaming

### What Happens When You Rename?

**Before** (world contains items):
```java
ITEMS.register("copper_sword", () -> ...)
// Player has 5 copper_sword items in inventory
// Chest has 3 copper_sword items
```

**After** (registry name changed):
```java
ITEMS.register("bronze_sword", () -> ...)
// World tries to load: "modid:copper_sword"
// Registry lookup: "modid:bronze_sword" exists, "modid:copper_sword" MISSING!
// Result: Items become minecraft:air (disappear!)
```

**Result**: ❌ All existing items are lost!

### Affected Data

| Data Type | Impact | Example |
|-----------|--------|---------|
| **Player Inventory** | Items disappear | 64 copper_sword → 64 air |
| **Chests** | Contents lost | Chest contents become air |
| **Item Entities** | Despawn | Dropped items vanish |
| **Recipes** | Still work | Recipe still produces old item name |
| **Advancements** | May break | "Obtain copper_sword" advancement fails |
| **Loot Tables** | Still work | Drops reference old name |

---

## Safe vs Unsafe Renames

### ✅ Safe Renames (No World Impact)

**Variable Names**:
```java
// SAFE: Variable name not stored anywhere
public static final RegistryObject<Item> COPPER_SWORD =  // Can rename to BRONZE_SWORD
    ITEMS.register("copper_sword", () -> ...);  // Keep registry name same
```

**Method Names**:
```java
// SAFE: Method names not in world data
public void registerSwords() { ... }  // Can rename to setupSwordRegistry()
```

**Translation Keys** (Display only):
```json
// SAFE: Only affects display text, not data
"item.modid.copper_sword": "Copper Sword"  // Can change to "Bronze Sword"
```

**Model/Texture Files**:
```
assets/modid/models/item/copper_sword.json  // Can rename
assets/modid/textures/item/copper_sword.png  // Can rename
```

### ❌ Unsafe Renames (Breaks Worlds)

**Registry Names** (most critical):
```java
// UNSAFE: Breaks existing worlds
ITEMS.register("copper_sword", ...)  // → "bronze_sword" breaks worlds
```

**NBT Tags**:
```java
// UNSAFE: NBT keys stored in block entities/entities
nbt.putString("stored_item", value);  // Key stored in world
```

**SavedData Identifiers**:
```java
// UNSAFE: SavedData ID stored in level.dat
server.overworld().getDataStorage().computeIfAbsent(
    ...,
    "my_mod_data"  // ID stored permanently
);
```

**Dimension/Biome Names**:
```java
// UNSAFE: Dimension registry names in world data
DIMENSIONS.register("copper_dimension", ...)
```

---

## Migration Strategies

### Strategy 1: Aliases (Recommended)

**Keep both old and new names working** - best for backward compatibility.

#### Forge/NeoForge: MissingMappingsEvent

```java
@Mod.EventBusSubscriber(modid = MODID, bus = Mod.EventBusSubscriber.Bus.MOD)
public class RegistryEventHandler {

    @SubscribeEvent
    public static void onMissingMappings(MissingMappingsEvent event) {
        // Handle missing item mappings
        event.getMappings(ForgeRegistries.ITEMS).forEach(mapping -> {
            String key = mapping.getKey().toString();

            // Redirect old copper_sword to new bronze_sword
            if (key.equals("modid:copper_sword")) {
                mapping.remap(ModItems.BRONZE_SWORD.get());
            }

            // Can handle multiple renames
            if (key.equals("modid:old_block")) {
                mapping.remap(ModBlocks.NEW_BLOCK.get());
            }
        });

        // Handle blocks
        event.getMappings(ForgeRegistries.BLOCKS).forEach(mapping -> {
            if (mapping.getKey().toString().equals("modid:copper_block")) {
                mapping.remap(ModBlocks.BRONZE_BLOCK.get());
            }
        });

        // Handle entities
        event.getMappings(ForgeRegistries.ENTITY_TYPES).forEach(mapping -> {
            if (mapping.getKey().toString().equals("modid:copper_golem")) {
                mapping.remap(ModEntities.BRONZE_GOLEM.get());
            }
        });
    }
}
```

**How it works**:
1. World tries to load `modid:copper_sword`
2. Registry doesn't find it → fires MissingMappingsEvent
3. Your handler catches it and remaps to `BRONZE_SWORD`
4. World loads successfully with new item!

**Advantages**:
- ✅ Existing worlds keep working
- ✅ Items don't disappear
- ✅ No data loss
- ✅ Can maintain multiple old names

**Disadvantages**:
- ⚠️ Adds code complexity
- ⚠️ Must maintain compatibility code forever (or provide migration period)

#### Fabric: Registry Aliases

```java
public class ModItems {
    public static final Item BRONZE_SWORD = new SwordItem(...);

    public static void register() {
        // Register with new name
        Registry.register(Registries.ITEM,
            new Identifier(MODID, "bronze_sword"),
            BRONZE_SWORD);

        // Keep old name as alias (backward compatibility)
        Registry.register(Registries.ITEM,
            new Identifier(MODID, "copper_sword"),  // Old name
            BRONZE_SWORD);  // Points to same item
    }
}
```

**How it works**:
- Both `modid:copper_sword` and `modid:bronze_sword` point to same item
- Old worlds load `copper_sword` successfully
- New content uses `bronze_sword`

**Note**: Fabric doesn't have MissingMappingsEvent, so you must keep old registry entries active.

### Strategy 2: Version-Based Migration

**Migrate data when world loads** (for mods with versioning system).

```java
public class WorldDataMigration {

    public static void migrateIfNeeded(ServerLevel level) {
        ModSavedData data = ModSavedData.load(level);
        String worldModVersion = data.getModVersion();

        // Check if migration needed
        if (compareVersions(worldModVersion, "2.0.0") < 0) {
            migrateFrom1xTo2x(level);
            data.setModVersion("2.0.0");
            data.setDirty();
        }
    }

    private static void migrateFrom1xTo2x(ServerLevel level) {
        // Iterate all loaded chunks
        level.getAllEntities().forEach(entity -> {
            if (entity instanceof ItemEntity itemEntity) {
                ItemStack stack = itemEntity.getItem();

                // Check if item is old copper_sword
                if (isOldCopperSword(stack)) {
                    // Replace with new bronze_sword
                    itemEntity.setItem(new ItemStack(ModItems.BRONZE_SWORD.get()));
                }
            }
        });

        // Migrate player inventories
        level.players().forEach(player -> {
            migrateInventory(player.getInventory());
        });

        // Note: Can't easily migrate unloaded chunks
        // Those will still lose items unless using MissingMappingsEvent
    }
}
```

**Advantages**:
- ✅ Active migration (converts old to new)
- ✅ Eventually no compatibility code needed

**Disadvantages**:
- ❌ Complex implementation
- ❌ Can't migrate unloaded chunks
- ❌ Performance impact on world load
- ❌ Risky (bugs could delete items)

### Strategy 3: Deprecation Period

**Keep old name, add new name, phase out old** (best for released mods).

**Phase 1** (v1.0): Original name
```java
public static final RegistryObject<Item> COPPER_SWORD =
    ITEMS.register("copper_sword", () -> ...);
```

**Phase 2** (v2.0): Add new item, deprecate old
```java
// New item (preferred going forward)
public static final RegistryObject<Item> BRONZE_SWORD =
    ITEMS.register("bronze_sword", () -> ...);

// Old item (deprecated, but still works)
@Deprecated
public static final RegistryObject<Item> COPPER_SWORD =
    ITEMS.register("copper_sword", () -> ...);

// Add crafting recipe to convert old to new
// In recipe JSON:
{
  "type": "minecraft:crafting_shapeless",
  "ingredients": [{"item": "modid:copper_sword"}],
  "result": {"item": "modid:bronze_sword"}
}
```

**Phase 3** (v3.0): Remove old item, keep alias
```java
// Only new item remains
public static final RegistryObject<Item> BRONZE_SWORD =
    ITEMS.register("bronze_sword", () -> ...);

// Use MissingMappingsEvent to remap old to new
// (see Strategy 1)
```

**Advantages**:
- ✅ Gradual migration
- ✅ Users have time to convert
- ✅ Clear deprecation warnings

**Disadvantages**:
- ⚠️ Slow process (multiple versions)
- ⚠️ Both items exist during transition

### Strategy 4: Just Change It (Development Only)

**For mods in development** (no public release yet):

```java
// Just rename and accept world breakage
ITEMS.register("bronze_sword", ...)  // Changed from copper_sword
```

**When acceptable**:
- ✅ Mod not released yet
- ✅ Only personal test worlds affected
- ✅ No users to impact

**Never do this for**:
- ❌ Released mods with users
- ❌ Server mods (would break all player data)
- ❌ Mods on public modpacks

---

## Decision Matrix

**When renaming a registry name, ask:**

| Question | Answer | Strategy |
|----------|--------|----------|
| Is mod released? | No | Just change it |
| Is mod released? | Yes → Next question | |
| Can I keep old name? | Yes | Keep old name, only rename variables |
| Must change name? | Yes → Next question | |
| Do I need backward compat? | Yes | Use aliases (Strategy 1) |
| Can I break old worlds? | Yes | Deprecation period (Strategy 3) |

---

## Real Examples

### Example 1: Forge Item Rename with Alias

**Scenario**: Rename `COPPER_INGOT` to `BRONZE_INGOT` in released mod.

```java
// ModItems.java
public static final RegistryObject<Item> BRONZE_INGOT =
    ITEMS.register("bronze_ingot", () -> new Item(new Item.Properties()));

// RegistryEventHandler.java
@SubscribeEvent
public static void onMissingMappings(MissingMappingsEvent event) {
    event.getMappings(ForgeRegistries.ITEMS).forEach(mapping -> {
        if (mapping.getKey().toString().equals("modid:copper_ingot")) {
            mapping.remap(ModItems.BRONZE_INGOT.get());
            LOGGER.info("Migrated old copper_ingot to bronze_ingot");
        }
    });
}
```

**Changelog entry**:
```
v2.0.0:
- Renamed Copper Ingot to Bronze Ingot
- Existing copper ingots will automatically convert to bronze ingots
- No action needed from players
```

### Example 2: Fabric Block Rename with Dual Registration

**Scenario**: Rename `COPPER_ORE` to `BRONZE_ORE`.

```java
public class ModBlocks {
    public static final Block BRONZE_ORE = new Block(...);

    public static void register() {
        // New name (primary)
        Registry.register(Registries.BLOCK,
            new Identifier(MODID, "bronze_ore"),
            BRONZE_ORE);

        // Old name (alias for compatibility)
        Registry.register(Registries.BLOCK,
            new Identifier(MODID, "copper_ore"),
            BRONZE_ORE);
    }
}
```

**Note**: Both names active permanently (or until you remove support).

---

## Best Practices

### DO

- ✅ Use aliases/MissingMappingsEvent for released mods
- ✅ Document breaking changes in changelog
- ✅ Provide migration period (at least 2 versions)
- ✅ Test migration with real world saves
- ✅ Warn users about potential data loss

### DON'T

- ❌ Rename registry names without migration plan
- ❌ Change names silently (always document!)
- ❌ Remove old names immediately
- ❌ Assume "it's just a name change, no big deal"
- ❌ Skip testing with existing worlds

---

## Warning Template

When renaming registry names, use this warning:

```
⚠️ WARNING: Registry Name Change Detected!

Old name: "copper_sword"
New name: "bronze_sword"

IMPACT:
- Existing copper_sword items in worlds will become AIR (disappear)
- Player inventories will lose items
- Chest contents will be lost
- This is a BREAKING CHANGE for existing worlds

RECOMMENDED ACTIONS:
1. Keep old registry name (safest)
2. Add MissingMappingsEvent handler to remap (maintains compatibility)
3. Provide conversion recipe (user-friendly migration)
4. Document breaking change in changelog

PROCEED WITH RENAME? [Y/N]
```

---

## Summary

**Key Takeaways**:
- Registry names are permanent identifiers stored in world saves
- Renaming breaks existing worlds unless you add migration
- Use aliases (MissingMappingsEvent or dual registration) for backward compatibility
- Always warn users about breaking changes
- Test migration with real world saves

**Safest Approach**:
1. Keep registry name unchanged
2. Only rename Java variables
3. Update resource files to match new theme
4. No world breakage!

**If you must rename**:
1. Add MissingMappingsEvent handler (Forge/NeoForge)
2. Or keep both names registered (Fabric)
3. Document in changelog
4. Provide migration period

For resource file synchronization patterns, see [Resource Sync Patterns](./resource-sync-patterns.md).
