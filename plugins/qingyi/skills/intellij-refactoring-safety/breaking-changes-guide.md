# Breaking Changes Guide - World Compatibility and Version Management

This guide explains what changes break existing Minecraft worlds, how to maintain compatibility, and how to document breaking changes for users.

## What Breaks Worlds

### Critical: Registry Names

**Registry names are the #1 cause of world breakage**:

```java
// Forge/NeoForge
ITEMS.register("copper_sword", () -> ...)
                // ↑ Stored in world saves

// Fabric
Registry.register(Registries.ITEM, new Identifier("modid", "copper_sword"), ...)
                                                              // ↑ Stored in world saves
```

**Impact**: Changing `"copper_sword"` to `"bronze_sword"` makes existing items disappear!

**Stored in**:
- Player inventories (ItemStack NBT)
- Chest contents (BlockEntity NBT)
- Item entities in the world
- Shulker boxes
- Bundle contents
- Armor slots, offhand slots
- Ender chests

**Example breakage**:
```
Before: Player has 64 copper_sword items
Rename: "copper_sword" → "bronze_sword"
After: Player has 64 air (items disappeared!)
```

### Critical: NBT Tag Names

**NBT tags used in block entities and entities**:

```java
// Block Entity
@Override
public void saveAdditional(CompoundTag nbt) {
    nbt.putString("stored_item", this.storedItem);
                    // ↑ Key stored in world data
    nbt.putInt("custom_energy", this.energy);
                // ↑ Key stored in world data
}

// Entity
@Override
public void addAdditionalSaveData(CompoundTag nbt) {
    nbt.putUUID("owner_uuid", this.ownerUUID);
                // ↑ Key stored in entities
}
```

**Impact**: Renaming NBT keys loses saved data!

**Example breakage**:
```java
// Before (world saved with this key)
nbt.putInt("stored_energy", 1000);

// After renaming
nbt.putInt("energy_stored", 1000);

// Result: Old "stored_energy" data is lost!
// Block entity loses its stored energy
```

### Critical: SavedData Identifiers

**SavedData IDs stored in level.dat**:

```java
public static final String DATA_NAME = "my_mod_data";

// Stored in level.dat with this name
server.overworld().getDataStorage().computeIfAbsent(
    MyData::load,
    MyData::new,
    DATA_NAME  // ↑ Stored permanently
);
```

**Impact**: Renaming loses all mod data for the world!

**Example breakage**:
```
Before: DATA_NAME = "my_mod_data" (world has saved data)
Rename: DATA_NAME = "mod_world_data"
After: Can't find "mod_world_data", creates fresh data, old data lost!
```

### Critical: Dimension/Biome Registry Names

**Custom dimensions and biomes**:

```java
// Dimension
DIMENSIONS.register("copper_dimension", () -> ...)

// Biome
BIOMES.register("copper_forest", () -> ...)
```

**Impact**: Renaming breaks world generation and player positions!

**Example breakage**:
```
Before: Player in modid:copper_dimension
Rename: "copper_dimension" → "bronze_dimension"
After: Dimension not found, player teleported to overworld or stuck!
```

---

## What's Safe to Rename

### Safe: Variable/Field Names

**Code symbols** (not stored in world data):

```java
// SAFE: Variable name not in world saves
public static final RegistryObject<Item> COPPER_SWORD =  // Can rename to BRONZE_SWORD
    ITEMS.register("copper_sword", () -> ...);  // Keep registry name same
```

**No world impact** because Java variable names aren't serialized.

### Safe: Method Names

```java
// SAFE: Method names not in world data
public void registerItems() { ... }  // Can rename to setupItemRegistry()
```

### Safe: Class Names (Usually)

```java
// SAFE: Class name not referenced in world data
public class CopperSword extends SwordItem { ... }  // Can rename to BronzeSword
```

**Exception**: If class name appears in NBT (e.g., entity type), then it's UNSAFE!

### Safe: Translation Keys

```json
// SAFE: Only affects display text
"item.modid.copper_sword": "Copper Sword"  // Can change to "Bronze Sword"
```

**Impact**: Display name changes, but item data unchanged.

### Safe: Model/Texture Files

```
assets/modid/models/item/copper_sword.json  // Can rename
assets/modid/textures/item/copper_sword.png  // Can rename
```

**Impact**: Visual only, no world data affected.

### Safe: Recipe Filenames

```
data/modid/recipes/copper_sword.json  // Can rename to bronze_sword.json
```

**Important**: Recipe *filename* safe, but recipe *content* must match registry names!

---

## Version Compatibility Strategies

### Strategy 1: Never Break Compatibility

**Keep old registry names forever** (safest):

```java
// Original (v1.0)
public static final RegistryObject<Item> COPPER_SWORD =
    ITEMS.register("copper_sword", () -> ...);

// Themed update (v2.0) - ONLY rename variable
public static final RegistryObject<Item> BRONZE_SWORD =  // Variable renamed
    ITEMS.register("copper_sword", () -> ...);  // Registry name UNCHANGED
```

**Advantages**:
- ✅ Zero risk of world breakage
- ✅ No migration code needed
- ✅ Users never lose items

**Disadvantages**:
- ⚠️ Internal name doesn't match theme
- ⚠️ Confusing for developers

### Strategy 2: Deprecation Period

**Phase out old names gradually** (3+ versions):

**Phase 1** (v1.0): Original
```java
public static final RegistryObject<Item> COPPER_SWORD =
    ITEMS.register("copper_sword", () -> ...);
```

**Phase 2** (v2.0): Add new, deprecate old
```java
// New item (preferred)
public static final RegistryObject<Item> BRONZE_SWORD =
    ITEMS.register("bronze_sword", () -> ...);

// Old item (deprecated but functional)
@Deprecated
public static final RegistryObject<Item> COPPER_SWORD =
    ITEMS.register("copper_sword", () -> ...);
```

**Phase 3** (v2.1): Warn users
```
Changelog:
- copper_sword is deprecated, use bronze_sword instead
- craft bronze_sword from copper_sword (1:1 conversion recipe)
- copper_sword will be removed in v3.0
```

**Phase 4** (v3.0): Remove old, add alias
```java
// Only new item
public static final RegistryObject<Item> BRONZE_SWORD =
    ITEMS.register("bronze_sword", () -> ...);

// Migration for old items
@SubscribeEvent
public static void onMissingMappings(MissingMappingsEvent event) {
    event.getMappings(ForgeRegistries.ITEMS).forEach(mapping -> {
        if (mapping.getKey().toString().equals("modid:copper_sword")) {
            mapping.remap(ModItems.BRONZE_SWORD.get());
        }
    });
}
```

**Timeline**: 3 versions minimum, 6+ months recommended.

### Strategy 3: Semantic Versioning

**Use SemVer to communicate breaking changes**:

**Format**: MAJOR.MINOR.PATCH (e.g., 2.1.3)
- **MAJOR**: Breaking changes (world incompatibility)
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

**Examples**:
```
v1.5.2 → v1.6.0: New features, safe to update
v1.6.0 → v2.0.0: BREAKING CHANGES, read changelog carefully!
v2.0.0 → v2.0.1: Bug fixes, safe to update
```

**Changelog example**:
```markdown
## v2.0.0 - BREAKING CHANGES

### Breaking
- Renamed copper_sword registry name to bronze_sword
- Old worlds: Copper swords will convert to bronze swords automatically
- Action required: None (migration handled automatically)

### Added
- Bronze armor set
- Bronze tools

### Changed
- Copper theme replaced with bronze theme
```

### Strategy 4: Version Migration Data

**Store mod version in world data** and migrate on load:

```java
public class ModSavedData extends SavedData {
    private String modVersion = "1.0.0";

    public static ModSavedData load(ServerLevel level) {
        ModSavedData data = level.getDataStorage().computeIfAbsent(
            ModSavedData::load,
            ModSavedData::new,
            "my_mod_data"
        );

        // Check for migrations needed
        if (compareVersions(data.modVersion, "2.0.0") < 0) {
            performV2Migration(level, data);
            data.modVersion = "2.0.0";
            data.setDirty();
        }

        return data;
    }

    private static void performV2Migration(ServerLevel level, ModSavedData data) {
        // Migration logic for v1.x → v2.0
        // Note: Can only migrate loaded chunks
    }
}
```

**Advantages**:
- ✅ Automatic migration on world load
- ✅ Version tracking per-world

**Disadvantages**:
- ❌ Complex implementation
- ❌ Can't migrate unloaded chunks
- ❌ Risky (bugs could lose data)

---

## Deprecation Patterns

### Pattern 1: Code-Level Deprecation

**Mark old code as deprecated**:

```java
// New (preferred)
public static final RegistryObject<Item> BRONZE_SWORD =
    ITEMS.register("bronze_sword", () -> ...);

// Old (deprecated)
@Deprecated(since = "2.0.0", forRemoval = true)
public static final RegistryObject<Item> COPPER_SWORD =
    ITEMS.register("copper_sword", () -> ...);
    // Use BRONZE_SWORD instead
```

**IDE warns developers**: "COPPER_SWORD is deprecated"

### Pattern 2: In-Game Warnings

**Warn players when using deprecated items**:

```java
@Override
public InteractionResultHolder<ItemStack> use(Level level, Player player, InteractionHand hand) {
    if (!level.isClientSide) {
        player.displayClientMessage(
            Component.literal("§eThis item is deprecated! Use Bronze Sword instead."),
            true  // Action bar
        );
    }
    return super.use(level, player, hand);
}
```

### Pattern 3: Conversion Recipes

**Allow users to convert old to new**:

```json
{
  "type": "minecraft:crafting_shapeless",
  "group": "bronze_conversion",
  "ingredients": [
    {"item": "modid:copper_sword"}
  ],
  "result": {
    "item": "modid:bronze_sword"
  }
}
```

**User-friendly**: Players can convert at their own pace.

---

## Change Documentation

### Changelog Format

**Use structured changelog** (Keep a Changelog format):

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Bronze armor set
- New bronze textures

### Changed
- Copper theme replaced with bronze theme

### Deprecated
- copper_sword (use bronze_sword instead)

### Removed
- None

### Fixed
- Fixed copper sword durability

### Security
- None

## [2.0.0] - 2024-01-15

### BREAKING CHANGES
- Renamed copper_sword registry name to bronze_sword
  - Existing copper swords will automatically convert
  - No action needed from players

### Added
- bronze_sword item
- MissingMappingsEvent handler for migration

### Deprecated
- copper_sword (removed in this version, but aliased)

### Migration Guide
Old worlds from v1.x:
1. Backup your world before updating!
2. Update mod to v2.0.0
3. Load world (migration happens automatically)
4. Existing copper_sword items → bronze_sword items
5. No data loss expected, but backup recommended

```

### In-Game Version Warnings

**Warn players about mod version**:

```java
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    Player player = event.getEntity();
    String worldModVersion = getWorldModVersion(player.level());

    if (!worldModVersion.equals(MOD_VERSION)) {
        player.sendSystemMessage(Component.literal(
            "§6[MyMod] §eWorld was created with mod version " + worldModVersion +
            ", now running " + MOD_VERSION + ". Check changelog for breaking changes!"
        ));
    }
}
```

### CurseForge/Modrinth Release Notes

**Clear release notes**:

```markdown
## Important: Breaking Changes in v2.0.0

⚠️ **BACKUP YOUR WORLD BEFORE UPDATING!**

### What Changed
- Copper theme replaced with bronze theme
- Registry names renamed (copper → bronze)

### World Compatibility
- ✅ Old worlds WILL work (automatic migration)
- ✅ Copper items automatically convert to bronze items
- ⚠️ BACKUP RECOMMENDED (always)

### Migration
1. Backup world
2. Update mod to v2.0.0
3. Load world
4. Migration happens automatically

### Known Issues
- None currently

### Support
If items disappear or migration fails:
1. Restore backup
2. Report issue on GitHub with logs

---

## Installation
[Standard installation instructions...]
```

---

## User Communication Checklist

When releasing breaking changes:

### Pre-Release
```
[ ] Announce breaking changes on Discord/forum
[ ] Explain what's changing and why
[ ] Provide migration timeline
[ ] Offer beta version for testing
```

### Release
```
[ ] Version bump (MAJOR version for breaking changes)
[ ] Detailed changelog with migration guide
[ ] Clear release notes on CurseForge/Modrinth
[ ] Backup warning in release description
[ ] Known issues documented
```

### Post-Release
```
[ ] Monitor for migration issues
[ ] Respond to bug reports quickly
[ ] Provide support for users having problems
[ ] Update FAQ with common migration questions
```

---

## Example: Complete Breaking Change

**Scenario**: Renaming copper_sword to bronze_sword in released mod.

### Step 1: Planning (v1.9 release)

**Announce intention**:
```
Announcement (Discord, v1.9 release notes):

"Upcoming in v2.0: Copper theme will be replaced with bronze theme.
This is a BREAKING CHANGE that will require migration.

Timeline:
- v1.9 (current): No changes, copper_sword works normally
- v1.10 (next release): Add bronze_sword, deprecate copper_sword
- v2.0 (3 months): Remove copper_sword registration, add migration

We recommend:
- Try v1.10 beta and test migration
- Backup worlds before updating to v2.0
- Report any issues during beta period"
```

### Step 2: Deprecation (v1.10 release)

**Code**:
```java
// New item
public static final RegistryObject<Item> BRONZE_SWORD =
    ITEMS.register("bronze_sword", () -> ...);

// Old item (deprecated)
@Deprecated(since = "1.10.0", forRemoval = true)
public static final RegistryObject<Item> COPPER_SWORD =
    ITEMS.register("copper_sword", () -> ...);
```

**Changelog**:
```markdown
## [1.10.0] - 2024-10-01

### Added
- bronze_sword (new, preferred item)
- Conversion recipe: copper_sword → bronze_sword

### Deprecated
- copper_sword will be removed in v2.0.0 (use bronze_sword instead)

### Notice
Prepare for v2.0: copper_sword will convert to bronze_sword automatically.
Test migration in creative world before updating main world.
```

### Step 3: Migration (v2.0 release)

**Code**:
```java
// Only new item
public static final RegistryObject<Item> BRONZE_SWORD =
    ITEMS.register("bronze_sword", () -> ...);

// Migration handler
@SubscribeEvent
public static void onMissingMappings(MissingMappingsEvent event) {
    event.getMappings(ForgeRegistries.ITEMS).forEach(mapping -> {
        if (mapping.getKey().toString().equals("modid:copper_sword")) {
            mapping.remap(ModItems.BRONZE_SWORD.get());
            LOGGER.info("Migrated copper_sword to bronze_sword");
        }
    });
}
```

**Changelog**:
```markdown
## [2.0.0] - 2025-01-01 - BREAKING CHANGES

### BREAKING
- Removed copper_sword registration (automatic migration to bronze_sword)
- copper_sword items automatically convert to bronze_sword on world load

### Migration Guide
1. **BACKUP YOUR WORLD**
2. Update to v2.0.0
3. Load world (migration automatic)
4. Existing copper_sword → bronze_sword
5. No data loss expected

### Changed
- All copper textures replaced with bronze theme
- All copper names changed to bronze

### Fixed
- None

### Known Issues
- None

### Tested
- Migration tested with 50+ worlds
- No reported data loss in beta period
```

**Release Notes** (CurseForge/Modrinth):
```markdown
# v2.0.0 - Copper → Bronze Theme Update

⚠️ **IMPORTANT: BACKUP YOUR WORLD BEFORE UPDATING!**

## Changes
Complete theme overhaul from copper to bronze.

## World Compatibility
✅ **Old worlds WILL work** with automatic migration
✅ Copper items convert to bronze items automatically
⚠️ **BACKUP STILL STRONGLY RECOMMENDED**

## How to Update
1. Backup world
2. Update mod
3. Load world
4. Migration happens automatically

## Need Help?
Report issues on GitHub with:
- Mod version
- Minecraft version
- Latest.log file
- World backup (if possible)

---

[Rest of release notes...]
```

---

## Summary

**What breaks worlds**:
- ❌ Registry names (items, blocks, entities, dimensions, biomes)
- ❌ NBT tag names (block entities, entities)
- ❌ SavedData identifiers
- ❌ Any data stored in world files

**What's safe**:
- ✅ Variable/field names
- ✅ Method names
- ✅ Class names (usually)
- ✅ Translation keys (display only)
- ✅ Model/texture files

**Best practices**:
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Provide deprecation period (3+ versions)
- Implement migration (MissingMappingsEvent)
- Document changes clearly (changelog + release notes)
- Warn users to backup
- Test migration thoroughly

**Golden rule**: When in doubt, DON'T rename registry names. Only rename Java variables.

For migration implementation details, see [Registry Name Changes](./registry-name-changes.md).

For resource file updates, see [Resource Sync Patterns](./resource-sync-patterns.md).
