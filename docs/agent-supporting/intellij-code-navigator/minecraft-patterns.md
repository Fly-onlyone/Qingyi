# Minecraft Code Patterns - Navigation Guide

Common code patterns in Minecraft mods and how to find them efficiently using IntelliJ MCP tools.

## Registry Patterns

### Pattern 1: DeferredRegister (Forge/NeoForge)

**Signature**:
```java
public static final DeferredRegister<Type> REGISTER =
    DeferredRegister.create(ForgeRegistries.TYPE, MODID);
```

**How to Find**:
```
search_in_files_by_text("DeferredRegister.create", fileMask="*.java")
```

**Common Locations**:
- `**/init/ModItems.java`
- `**/init/ModBlocks.java`
- `**/registry/ModRegistry.java`

**What to Extract**:
- Registry type (ITEMS, BLOCKS, ENTITY_TYPES)
- Mod ID
- Registration entries

### Pattern 2: Registry.register (Fabric)

**Signature**:
```java
public static final Item ITEM = Registry.register(
    Registries.ITEM, new Identifier(MODID, "name"), item);
```

**How to Find**:
```
search_in_files_by_text("Registry.register", fileMask="*.java")
```

**Common Locations**:
- `**/ModItems.java`
- `**/init/ItemRegistry.java`

## Event Handler Patterns

### Pattern 3: @SubscribeEvent (Forge/NeoForge)

**Signature**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class Events {
    @SubscribeEvent
    public static void onEvent(EventType event) { }
}
```

**How to Find All Event Handlers**:
```
search_in_files_by_regex("@SubscribeEvent\\s+public\\s+static", fileMask="*.java")
```

**How to Find Specific Event**:
```
search_in_files_by_text("PlayerTickEvent", fileMask="*.java")
```

**Common Locations**:
- `**/events/ForgeEvents.java`
- `**/handlers/EventHandler.java`
- `**/client/ClientEvents.java`

### Pattern 4: Event Callbacks (Fabric)

**Signature**:
```java
PlayerTickEvents.END_TICK.register((player) -> {
    // Handler logic
});
```

**How to Find**:
```
search_in_files_by_text(".register(", fileMask="*.java")
```

## Class Hierarchy Patterns

### Pattern 5: Custom Items

**Signature**:
```java
public class CustomItem extends Item {
    public CustomItem(Properties properties) {
        super(properties);
    }
}
```

**How to Find All Custom Items**:
```
search_in_files_by_regex("class\\s+\\w+\\s+extends\\s+Item", fileMask="*.java")
```

**Common Locations**:
- `**/items/CustomItem.java`
- `**/content/items/*.java`

### Pattern 6: Custom Blocks

**How to Find**:
```
search_in_files_by_regex("class\\s+\\w+\\s+extends\\s+Block", fileMask="*.java")
```

### Pattern 7: Custom Entities

**How to Find**:
```
search_in_files_by_regex("class\\s+\\w+\\s+extends\\s+(Entity|Mob|Animal)", fileMask="*.java")
```

## NBT and Data Patterns

### Pattern 8: SavedData

**Signature**:
```java
public class ModSavedData extends SavedData {
    @Override
    public CompoundTag save(CompoundTag tag) { }

    public static ModSavedData load(CompoundTag tag) { }
}
```

**How to Find**:
```
search_in_files_by_text("extends SavedData", fileMask="*.java")
```

### Pattern 9: Capability Providers (Forge)

**Signature**:
```java
@SubscribeEvent
public static void onAttachCapabilities(AttachCapabilitiesEvent<Entity> event) {
    event.addCapability(new ResourceLocation(MODID, "capability"), provider);
}
```

**How to Find**:
```
search_in_files_by_text("AttachCapabilitiesEvent", fileMask="*.java")
```

## Client-Side Patterns

### Pattern 10: @OnlyIn(Dist.CLIENT)

**How to Find Client-Only Code**:
```
search_in_files_by_text("@OnlyIn(Dist.CLIENT)", fileMask="*.java")
```

**Common Client Classes**:
- Screen implementations
- Rendering code
- Client event handlers

### Pattern 11: Screen/GUI Classes

**Signature**:
```java
public class CustomScreen extends Screen {
    public CustomScreen(Component title) {
        super(title);
    }

    @Override
    public void render(GuiGraphics graphics, int mouseX, int mouseY, float partialTick) { }
}
```

**How to Find**:
```
search_in_files_by_regex("class\\s+\\w+\\s+extends\\s+Screen", fileMask="*.java")
```

## Resource File Patterns

### Pattern 12: Item Models

**Location Pattern**: `assets/modid/models/item/*.json`

**How to Find**:
```
find_files_by_glob("**/resources/assets/*/models/item/*.json")
```

**Standard Structure**:
```json
{
  "parent": "item/generated",
  "textures": {
    "layer0": "modid:item/item_name"
  }
}
```

### Pattern 13: Block Models

**Location Pattern**: `assets/modid/models/block/*.json`

**How to Find**:
```
find_files_by_glob("**/resources/assets/*/models/block/*.json")
```

### Pattern 14: Lang Files

**Location Pattern**: `assets/modid/lang/en_us.json`

**How to Find Specific Translation**:
```
search_in_files_by_text("item.modid.", fileMask="*.json", directoryToSearch="assets")
```

### Pattern 15: Recipes

**Location Pattern**: `data/modid/recipes/*.json`

**How to Find Recipes for Item**:
```
search_in_files_by_text("modid:item_name", directoryToSearch="data")
```

## Advanced Patterns

### Pattern 16: Tick Handlers

**Common Types**:
- ServerTickEvent
- ClientTickEvent
- PlayerTickEvent
- LevelTickEvent

**How to Find All Tick Handlers**:
```
search_in_files_by_regex("on(Server|Client|Player|Level)Tick", fileMask="*.java")
```

### Pattern 17: Network Packets (Forge)

**Signature**:
```java
private static final SimpleChannel CHANNEL = NetworkRegistry.newSimpleChannel(
    new ResourceLocation(MODID, "main"),
    () -> PROTOCOL_VERSION,
    PROTOCOL_VERSION::equals,
    PROTOCOL_VERSION::equals
);
```

**How to Find**:
```
search_in_files_by_text("SimpleChannel", fileMask="*.java")
```

### Pattern 18: Data Generators

**Signature**:
```java
@Mod.EventBusSubscriber(bus = Bus.MOD)
public class DataGenerators {
    @SubscribeEvent
    public static void gatherData(GatherDataEvent event) { }
}
```

**How to Find**:
```
search_in_files_by_text("GatherDataEvent", fileMask="*.java")
```

## Search Optimization Matrix

| Pattern | Fast Method | Slow Method | Speed Gain |
|---------|-------------|-------------|------------|
| Find ModItems | find_files_by_name_keyword | search_in_files_by_text | 20x |
| Find event handlers | find_files_by_glob + text | search_in_files_by_regex | 5x |
| Find item models | find_files_by_glob | search_in_files_by_text | 10x |
| Find capabilities | search_in_files_by_text | search_in_files_by_regex | 2x |

## Complete Navigation Examples

### Example: Map Item to All Resources

```
1. Find item registration:
   search_in_files_by_text("RUBY_SWORD", fileMask="*.java")
   → Result: ModItems.java:25, registry name "ruby_sword"

2. Find item model:
   find_files_by_glob("**/models/item/ruby_sword.json")
   → Result: ✓ Found

3. Read model to get texture reference:
   Read model JSON
   → Extract: "modid:item/ruby_sword"

4. Find texture:
   find_files_by_glob("**/textures/item/ruby_sword.png")
   → Result: ✓ Found

5. Find lang entry:
   search_in_files_by_text("item.modid.ruby_sword", fileMask="*.json")
   → Result: ✓ Found "Ruby Sword"

6. Find recipes:
   search_in_files_by_text("modid:ruby_sword", directoryToSearch="data")
   → Result: ✓ Found crafting recipe
```

Use this guide to quickly navigate Minecraft mod code patterns with optimal tool selection.
