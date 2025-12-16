---
name: nbt-serialization-patterns
description: NBT (Named Binary Tag) serialization patterns for Minecraft data persistence. Use when saving/loading data to disk, capabilities, SavedData, BlockEntities, or entities. Covers CompoundTag, ListTag, tag types, and proven patterns from real mods. Applies to Forge, NeoForge, and Fabric.
allowed-tools: Read, Grep, Glob
---

# NBT Serialization Patterns

## What This Covers

- NBT tag types and usage
- Serialization (writing data to NBT)
- Deserialization (reading data from NBT)
- Capability persistence patterns
- SavedData patterns
- BlockEntity and Entity persistence
- Version compatibility and data migration

## When to Use

- Saving mod data to disk
- Persisting state across sessions
- Implementing capabilities (Forge)
- Creating SavedData (world-level persistence)
- Storing custom data on entities/items/blocks
- Migrating data between mod versions

---

## NBT Tag Types (Quick Reference)

```java
CompoundTag      // {key: value} - Dictionary/Map (most common)
ListTag          // [item, item] - Array/List
IntTag           // 32-bit integer (most common for numbers)
StringTag        // UTF-8 string
LongTag          // 64-bit integer (timestamps, UUIDs)
FloatTag         // 32-bit floating point
DoubleTag        // 64-bit floating point
ByteTag          // 8-bit integer / boolean (0 or 1)
ShortTag         // 16-bit integer
ByteArrayTag     // byte[] array
IntArrayTag      // int[] array
LongArrayTag     // long[] array (UUIDs)
```

**Most Used**: CompoundTag (90% of use cases), ListTag, IntTag, StringTag

**For complete tag reference**: See [nbt-tag-types.md](./nbt-tag-types.md)

---

## Basic Patterns

### Pattern 1: Simple CompoundTag

**Write data**:
```java
CompoundTag tag = new CompoundTag();
tag.putInt("count", 10);
tag.putString("name", "example");
tag.putBoolean("active", true);
tag.putDouble("value", 3.14);
```

**Read data**:
```java
int count = tag.getInt("count");
String name = tag.getString("name");
boolean active = tag.getBoolean("active");
double value = tag.getDouble("value");
```

### Pattern 2: Lists

**Write list**:
```java
ListTag list = new ListTag();
list.add(StringTag.valueOf("item1"));
list.add(StringTag.valueOf("item2"));
tag.put("items", list);
```

**Read list**:
```java
ListTag list = tag.getList("items", Tag.TAG_STRING);
for (int i = 0; i < list.size(); i++) {
    String item = list.getString(i);
}
```

### Pattern 3: Nested CompoundTags

**Write nested data**:
```java
CompoundTag player = new CompoundTag();
player.putString("name", "Steve");
player.putInt("level", 10);

CompoundTag inventory = new CompoundTag();
inventory.putInt("slots", 36);

player.put("inventory", inventory);
tag.put("player", player);
```

**For complete patterns**: See [nbt-patterns.md](./nbt-patterns.md)

---

## Common Use Cases

### SavedData (World-Level Persistence)

**Create SavedData class**:
```java
public class ModSavedData extends SavedData {
    private int apocalypseCountdown = 60;
    private boolean apocalypseActive = false;

    @Override
    public CompoundTag save(CompoundTag tag) {
        tag.putInt("countdown", apocalypseCountdown);
        tag.putBoolean("active", apocalypseActive);
        return tag;
    }

    public static ModSavedData load(CompoundTag tag) {
        ModSavedData data = new ModSavedData();
        data.apocalypseCountdown = tag.getInt("countdown");
        data.apocalypseActive = tag.getBoolean("active");
        return data;
    }

    // Get instance
    public static ModSavedData get(MinecraftServer server) {
        return server.overworld().getDataStorage()
            .computeIfAbsent(ModSavedData::load, ModSavedData::new, "modid_data");
    }
}
```

**For complete SavedData guide**: See [saved-data-patterns.md](./saved-data-patterns.md)

### Capabilities (Forge/NeoForge)

**Attach data to player**:
```java
public class PlayerMana {
    private int mana = 100;

    public void saveNBTData(CompoundTag tag) {
        tag.putInt("mana", mana);
    }

    public void loadNBTData(CompoundTag tag) {
        mana = tag.getInt("mana");
    }
}
```

**For complete capability patterns**: See [capability-persistence.md](./capability-persistence.md)

### BlockEntity Persistence

**Save/Load tile entity data**:
```java
public class CustomBlockEntity extends BlockEntity {
    private int energy = 0;
    private String owner = "";

    @Override
    protected void saveAdditional(CompoundTag tag) {
        super.saveAdditional(tag);
        tag.putInt("energy", energy);
        tag.putString("owner", owner);
    }

    @Override
    public void load(CompoundTag tag) {
        super.load(tag);
        energy = tag.getInt("energy");
        owner = tag.getString("owner");
    }
}
```

**For complete BlockEntity guide**: See [block-entity-persistence.md](./block-entity-persistence.md)

---

## Best Practices

### Data Integrity
1. **Always validate reads** - Use `tag.contains("key")` before reading
2. **Provide defaults** - Handle missing keys gracefully
3. **Version your data** - Include version number for migrations

### Performance
1. **Batch writes** - Write all data at once, not incrementally
2. **Avoid deep nesting** - Keep structure flat when possible
3. **Use appropriate types** - IntTag for numbers, not StringTag

### Compatibility
1. **Never remove keys** - Mark as deprecated, provide defaults
2. **Add version field** - `tag.putInt("dataVersion", 1)`
3. **Migrate old data** - Handle version upgrades gracefully

**For complete best practices**: See [nbt-best-practices.md](./nbt-best-practices.md)

---

## Common Patterns by Framework

### Forge/NeoForge
```java
// Capability attachment
player.getCapability(MANA_CAPABILITY).ifPresent(mana -> {
    CompoundTag tag = new CompoundTag();
    mana.saveNBTData(tag);
    // Save tag
});
```

### Fabric
```java
// Component attachment
PlayerComponent component = PLAYER_COMPONENT.get(player);
CompoundTag tag = new CompoundTag();
component.writeNbt(tag);
// Save tag
```

**For framework-specific patterns**: See [framework-nbt-patterns.md](./framework-nbt-patterns.md)

---

## Data Migration Example

**Handle version upgrades**:
```java
public static ModData load(CompoundTag tag) {
    ModData data = new ModData();
    int version = tag.getInt("dataVersion");

    if (version == 0) {
        // Old format: single "energy" field
        data.energy = tag.getInt("energy");
    } else if (version == 1) {
        // New format: separate energyStored and energyMax
        data.energyStored = tag.getInt("energyStored");
        data.energyMax = tag.getInt("energyMax");
    }

    return data;
}

@Override
public CompoundTag save(CompoundTag tag) {
    tag.putInt("dataVersion", 1);  // Current version
    tag.putInt("energyStored", energyStored);
    tag.putInt("energyMax", energyMax);
    return tag;
}
```

**For complete migration guide**: See [data-migration.md](./data-migration.md)

---

## Quick Decision Tree

**Need world-level state?**
→ Use SavedData (server-side, persistent across sessions)

**Need player-specific data?**
→ Use Capabilities (Forge) or Components (Fabric)

**Need block-specific data?**
→ Use BlockEntity (tile entity)

**Need item-specific data?**
→ Use ItemStack NBT (built-in)

**Need entity-specific data?**
→ Override entity saveAdditional/load methods

---

## Common Pitfalls

### ❌ Not Checking Key Existence
```java
// BAD: Crashes if key missing
int value = tag.getInt("key");
```

### ✅ Safe Approach
```java
// GOOD: Check first
int value = tag.contains("key") ? tag.getInt("key") : 100;
```

### ❌ Wrong Tag Type
```java
// BAD: Reading as wrong type
String value = tag.getString("count");  // Was saved as IntTag
```

### ✅ Correct Type
```java
// GOOD: Match save type
int value = tag.getInt("count");
```

**For complete troubleshooting**: See [nbt-troubleshooting.md](./nbt-troubleshooting.md)

---

## Supporting Documentation

### Detailed Guides
- [NBT Tag Types](./nbt-tag-types.md) - Complete reference for all NBT tag types
- [NBT Patterns](./nbt-patterns.md) - Common serialization patterns
- [SavedData Patterns](./saved-data-patterns.md) - World-level persistence
- [Capability Persistence](./capability-persistence.md) - Forge capability NBT patterns
- [BlockEntity Persistence](./block-entity-persistence.md) - Tile entity data storage
- [Framework NBT Patterns](./framework-nbt-patterns.md) - Forge vs Fabric differences
- [Data Migration](./data-migration.md) - Version upgrade handling
- [NBT Best Practices](./nbt-best-practices.md) - Performance and compatibility
- [NBT Troubleshooting](./nbt-troubleshooting.md) - Common issues and solutions

---

Use this skill when implementing any data persistence in Minecraft mods to ensure reliable, performant, and compatible data storage.
