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

## Core Knowledge

### NBT Tag Types

**Available Types**:
```java
CompoundTag      // {key: value} - Dictionary/Map
ListTag          // [item, item] - Array/List
ByteTag          // 8-bit integer (-128 to 127)
ShortTag         // 16-bit integer
IntTag           // 32-bit integer (most common for numbers)
LongTag          // 64-bit integer (timestamps, UUIDs)
FloatTag         // 32-bit floating point
DoubleTag        // 64-bit floating point
StringTag        // UTF-8 string
ByteArrayTag     // byte[] array
IntArrayTag      // int[] array
LongArrayTag     // long[] array (UUIDs)
```

### Basic CompoundTag Operations

**Writing Data**:
```java
CompoundTag tag = new CompoundTag();

// Primitives
tag.putInt("count", 10);
tag.putString("name", "example");
tag.putBoolean("active", true);
tag.putDouble("value", 3.14);
tag.putFloat("speed", 1.5F);
tag.putLong("timestamp", System.currentTimeMillis());

// Special types
tag.putUUID("playerId", uuid);

// Nested compound
CompoundTag nested = new CompoundTag();
nested.putString("key", "value");
tag.put("nested", nested);
```

**Reading Data**:
```java
// Read primitives
int count = tag.getInt("count");
String name = tag.getString("name");
boolean active = tag.getBoolean("active");
double value = tag.getDouble("value");

// Check existence
if (tag.contains("count")) {
    int count = tag.getInt("count");
}

// Check with type validation
if (tag.contains("count", Tag.TAG_INT)) {
    int count = tag.getInt("count");
}

// Get with default
int count = tag.contains("count") ? tag.getInt("count") : 0;

// UUID
UUID playerId = tag.getUUID("playerId");
```

## Patterns from User's Mods

### Pattern 1: Capability Persistence (from MusicMod)

**Capability Class with NBT Methods**:
```java
public class MusicStateCapability {
    private String soundEventKey = "";
    private int elapsedTicks = 0;
    private int songDurationTicks = 0;
    private boolean isActive = false;
    private long serverStartTime = 0L;

    public void saveNBTData(CompoundTag nbt) {
        nbt.putString("soundEventKey", soundEventKey);
        nbt.putInt("elapsedTicks", elapsedTicks);
        nbt.putInt("songDurationTicks", songDurationTicks);
        nbt.putBoolean("isActive", isActive);
        nbt.putLong("serverStartTime", serverStartTime);
    }

    public void loadNBTData(CompoundTag nbt) {
        soundEventKey = nbt.getString("soundEventKey");
        elapsedTicks = nbt.getInt("elapsedTicks");
        songDurationTicks = nbt.getInt("songDurationTicks");
        isActive = nbt.getBoolean("isActive");
        serverStartTime = nbt.getLong("serverStartTime");
    }

    // Getters and setters...
}
```

**Capability Provider with INBTSerializable**:
```java
public class MusicCapProvider implements ICapabilityProvider, INBTSerializable<CompoundTag> {
    private final MusicStateCapability capability = new MusicStateCapability();

    @Override
    public CompoundTag serializeNBT() {
        CompoundTag nbt = new CompoundTag();
        capability.saveNBTData(nbt);
        return nbt;
    }

    @Override
    public void deserializeNBT(CompoundTag nbt) {
        capability.loadNBTData(nbt);
    }

    @Override
    public <T> LazyOptional<T> getCapability(Capability<T> cap, Direction side) {
        // Capability lookup
    }
}
```

**Key Points**:
- Separate save/load methods in capability class
- Provider implements INBTSerializable
- String keys match field names for clarity
- No explicit versioning (stable schema)

### Pattern 2: SavedData Persistence (from Apocalypse_TNT)

**SavedData Class**:
```java
public class ApocalypseSavedData extends SavedData {
    private static final String DATA_NAME = "apocalypse_data";

    private Phase currentPhase = Phase.NONE;
    private int remainingSeconds = 0;

    // Constructor for new data
    public ApocalypseSavedData() {
        setDirty(); // Mark as needing save
    }

    // Constructor for loaded data
    public ApocalypseSavedData(CompoundTag tag) {
        load(tag);
    }

    // Serialization
    @Override
    public CompoundTag save(CompoundTag tag) {
        tag.putString("phase", currentPhase.name());
        tag.putInt("remainingSeconds", remainingSeconds);
        return tag;
    }

    // Deserialization
    private void load(CompoundTag tag) {
        String phaseName = tag.getString("phase");
        currentPhase = Phase.valueOf(phaseName);
        remainingSeconds = tag.getInt("remainingSeconds");
    }

    // Access method
    public static ApocalypseSavedData get(ServerLevel level) {
        DimensionDataStorage storage = level.getDataStorage();
        return storage.computeIfAbsent(
            ApocalypseSavedData::new,       // Factory for new data
            ApocalypseSavedData::new,       // Factory from NBT
            DATA_NAME
        );
    }

    // Modification triggers save
    public void setPhase(Phase phase) {
        this.currentPhase = phase;
        setDirty(); // CRITICAL: Mark as needing save
    }

    public void setRemainingSeconds(int seconds) {
        this.remainingSeconds = seconds;
        setDirty();
    }
}
```

**Usage**:
```java
// In server tick or event
ServerLevel overworld = server.getLevel(Level.OVERWORLD);
ApocalypseSavedData data = ApocalypseSavedData.get(overworld);

// Read
Phase currentPhase = data.getCurrentPhase();

// Modify (automatically marks dirty and saves)
data.setPhase(Phase.COUNTDOWN);
data.setRemainingSeconds(60);
```

**Key Points**:
- Extend `SavedData` class
- Override `save(CompoundTag)` method
- Call `setDirty()` after every modification
- Use `computeIfAbsent` for get-or-create pattern
- Store in world's DimensionDataStorage

## List Handling

### ListTag Pattern

**Saving List of Strings**:
```java
ListTag list = new ListTag();
for (String item : stringList) {
    list.add(StringTag.valueOf(item));
}
tag.put("stringList", list);
```

**Loading List of Strings**:
```java
List<String> stringList = new ArrayList<>();
if (tag.contains("stringList", Tag.TAG_LIST)) {
    ListTag list = tag.getList("stringList", Tag.TAG_STRING);
    for (int i = 0; i < list.size(); i++) {
        stringList.add(list.getString(i));
    }
}
```

**Saving List of Integers**:
```java
ListTag list = new ListTag();
for (int num : numbers) {
    list.add(IntTag.valueOf(num));
}
tag.put("numbers", list);
```

**Loading List of Integers**:
```java
List<Integer> numbers = new ArrayList<>();
if (tag.contains("numbers", Tag.TAG_LIST)) {
    ListTag list = tag.getList("numbers", Tag.TAG_INT);
    for (int i = 0; i < list.size(); i++) {
        numbers.add(list.getInt(i));
    }
}
```

**Saving List of Compound Tags** (Complex Objects):
```java
ListTag list = new ListTag();
for (CustomObject obj : objects) {
    CompoundTag objTag = new CompoundTag();
    objTag.putString("name", obj.getName());
    objTag.putInt("value", obj.getValue());
    list.add(objTag);
}
tag.put("objects", list);
```

**Loading List of Compound Tags**:
```java
List<CustomObject> objects = new ArrayList<>();
if (tag.contains("objects", Tag.TAG_LIST)) {
    ListTag list = tag.getList("objects", Tag.TAG_COMPOUND);
    for (int i = 0; i < list.size(); i++) {
        CompoundTag objTag = list.getCompound(i);
        String name = objTag.getString("name");
        int value = objTag.getInt("value");
        objects.add(new CustomObject(name, value));
    }
}
```

## Entity Persistence

**Entity addAdditionalSaveData**:
```java
public class CustomEntity extends LivingEntity {
    private int customValue = 0;
    private String customString = "";

    @Override
    public void addAdditionalSaveData(CompoundTag tag) {
        super.addAdditionalSaveData(tag);
        tag.putInt("customValue", customValue);
        tag.putString("customString", customString);
    }

    @Override
    public void readAdditionalSaveData(CompoundTag tag) {
        super.readAdditionalSaveData(tag);
        customValue = tag.getInt("customValue");
        customString = tag.getString("customString");
    }
}
```

**Key Points**:
- Always call `super.addAdditionalSaveData(tag)` first
- Always call `super.readAdditionalSaveData(tag)` first
- Use clear key names (not "cv" or "cs")

## BlockEntity Persistence

**BlockEntity save/load**:
```java
public class CustomBlockEntity extends BlockEntity {
    private int energy = 0;
    private ItemStack storedItem = ItemStack.EMPTY;

    @Override
    protected void saveAdditional(CompoundTag tag) {
        super.saveAdditional(tag);
        tag.putInt("energy", energy);
        tag.put("storedItem", storedItem.save(new CompoundTag()));
    }

    @Override
    public void load(CompoundTag tag) {
        super.load(tag);
        energy = tag.getInt("energy");
        if (tag.contains("storedItem")) {
            storedItem = ItemStack.of(tag.getCompound("storedItem"));
        }
    }

    // For synchronization (optional)
    @Override
    public CompoundTag getUpdateTag() {
        CompoundTag tag = super.getUpdateTag();
        saveAdditional(tag);
        return tag;
    }
}
```

## ItemStack NBT

**Item NBT (Custom Data on Items)**:
```java
public class CustomItem extends Item {
    @Override
    public void inventoryTick(ItemStack stack, Level level, Entity entity, int slot, boolean selected) {
        if (!level.isClientSide) {
            CompoundTag tag = stack.getOrCreateTag();

            // Read
            int uses = tag.getInt("uses");

            // Modify
            uses++;
            tag.putInt("uses", uses);

            // Automatic save (ItemStack handles it)
        }
    }

    @Override
    public void appendHoverText(ItemStack stack, Level level, List<Component> tooltipComponents, TooltipFlag isAdvanced) {
        CompoundTag tag = stack.getTag();
        if (tag != null && tag.contains("uses")) {
            int uses = tag.getInt("uses");
            tooltipComponents.add(Component.literal("Uses: " + uses));
        }
    }
}
```

**Key Points**:
- `stack.getOrCreateTag()` - Creates tag if missing
- `stack.getTag()` - Returns null if no tag
- ItemStack automatically saves NBT
- No need to call setDirty()

## Best Practices

### 1. Use Descriptive Keys

**Bad**:
```java
tag.putInt("e", elapsed);
tag.putString("n", name);
tag.putBoolean("a", active);
```

**Good**:
```java
private static final String KEY_ELAPSED = "elapsedTicks";
private static final String KEY_NAME = "name";
private static final String KEY_ACTIVE = "isActive";

tag.putInt(KEY_ELAPSED, elapsed);
tag.putString(KEY_NAME, name);
tag.putBoolean(KEY_ACTIVE, active);
```

### 2. Handle Missing Keys

**Bad** (Ambiguous):
```java
int value = tag.getInt("key"); // Returns 0 if missing
// 0 could be actual value or missing data
```

**Good** (Explicit):
```java
int value;
if (tag.contains("key")) {
    value = tag.getInt("key");
} else {
    value = DEFAULT_VALUE; // Clear intent
}

// Or with default
int value = tag.contains("key") ? tag.getInt("key") : DEFAULT_VALUE;
```

### 3. Always Call setDirty()

**Bad**:
```java
public void setCounter(int value) {
    this.counter = value;
    // Missing setDirty() - won't save!
}
```

**Good**:
```java
public void setCounter(int value) {
    this.counter = value;
    setDirty(); // Triggers save
}
```

### 4. Use Type Checking

**Good**:
```java
if (tag.contains("count", Tag.TAG_INT)) {
    int count = tag.getInt("count");
} else {
    // Handle wrong type or missing
}
```

### 5. Version Your Data

**For Complex Schemas**:
```java
private static final int DATA_VERSION = 2;

@Override
public CompoundTag save(CompoundTag tag) {
    tag.putInt("dataVersion", DATA_VERSION);
    tag.putString("phase", currentPhase.name());
    tag.putInt("remainingSeconds", remainingSeconds);
    return tag;
}

private void load(CompoundTag tag) {
    int version = tag.getInt("dataVersion");

    if (version == 0) {
        // Migrate from old format
        migrateFromV0(tag);
    } else if (version == 1) {
        // Migrate from v1
        migrateFromV1(tag);
    } else {
        // Current version
        currentPhase = Phase.valueOf(tag.getString("phase"));
        remainingSeconds = tag.getInt("remainingSeconds");
    }
}
```

## Anti-Patterns

### 1. ❌ Forgetting setDirty()

```java
// ❌ Data won't save
public class MySavedData extends SavedData {
    public void setValue(int value) {
        this.value = value;
        // Missing setDirty()!
    }
}

// ✅ Correct
public void setValue(int value) {
    this.value = value;
    setDirty();
}
```

### 2. ❌ Not Handling Missing Keys

```java
// ❌ Assumes key exists
String name = tag.getString("name");
// Returns "" if missing, ambiguous

// ✅ Check first
if (tag.contains("name")) {
    String name = tag.getString("name");
} else {
    // Handle missing data
}
```

### 3. ❌ Wrong Tag Type

```java
// ❌ Storing UUID as string (inefficient)
tag.putString("uuid", uuid.toString());

// ✅ Use dedicated method
tag.putUUID("uuid", uuid);
```

### 4. ❌ Non-Serializable Objects

```java
// ❌ Can't serialize lambdas, threads, etc.
tag.put("runnable", runnable); // ERROR

// ✅ Serialize state, reconstruct object
tag.putInt("taskId", taskId);
// On load: reconstruct runnable from taskId
```

### 5. ❌ Storing Temporary State

```java
// ❌ Don't save client-side rendering state
tag.putFloat("particleAlpha", particleAlpha);

// ✅ Only save persistent game state
tag.putInt("health", health);
tag.putBoolean("isActive", isActive);
```

## Common Pitfalls

### Pitfall 1: Null Pointer on getTag()

```java
// ❌ NPE if no tag
CompoundTag tag = stack.getTag();
int uses = tag.getInt("uses"); // NPE

// ✅ Check for null
CompoundTag tag = stack.getTag();
if (tag != null) {
    int uses = tag.getInt("uses");
}

// ✅ Or use getOrCreateTag()
CompoundTag tag = stack.getOrCreateTag();
int uses = tag.getInt("uses"); // Safe
```

### Pitfall 2: Not Calling Super

```java
// ❌ Missing super call
@Override
public void addAdditionalSaveData(CompoundTag tag) {
    tag.putInt("customValue", customValue);
    // Missing: super.addAdditionalSaveData(tag);
}

// ✅ Always call super
@Override
public void addAdditionalSaveData(CompoundTag tag) {
    super.addAdditionalSaveData(tag);
    tag.putInt("customValue", customValue);
}
```

### Pitfall 3: Enum Serialization

```java
// ❌ Enum ordinal (breaks if order changes)
tag.putInt("phase", phase.ordinal());

// ✅ Enum name (stable)
tag.putString("phase", phase.name());

// On load
Phase phase = Phase.valueOf(tag.getString("phase"));
```

### Pitfall 4: Large Collections

```java
// ❌ Storing thousands of items (slow)
for (int i = 0; i < 10000; i++) {
    list.add(IntTag.valueOf(i));
}

// ✅ Limit collection size or use efficient storage
IntArrayTag array = new IntArrayTag(limitedArray);
tag.put("data", array);
```

## Verification Checklist

- [ ] All modified data calls `setDirty()` in SavedData
- [ ] Keys are descriptive and documented
- [ ] Missing keys handled gracefully
- [ ] No NPE on ItemStack.getTag()
- [ ] Super methods called (Entity, BlockEntity)
- [ ] Enums serialized by name, not ordinal
- [ ] UUIDs use putUUID(), not putString()
- [ ] Collections bounded (not unbounded growth)
- [ ] No client-only data in persistence
- [ ] Data version included if schema may change

## See Also

- [forge-capabilities](../forge-capabilities/SKILL.md) - Capability attachment
- [data-generation-guide](../data-generation-guide/SKILL.md) - Data generation
- Official NBT Format: https://minecraft.fandom.com/wiki/NBT_format
