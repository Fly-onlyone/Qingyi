# Registry Discovery Patterns

This document provides detailed patterns for discovering registry entries in Minecraft mods using IntelliJ MCP navigation tools.

## Overview

**Objective**: Locate DeferredRegister (Forge/NeoForge) or Registry.register (Fabric) calls and extract registered content (items, blocks, entities, etc.).

**Common Use Cases**:
- "Find all items in this mod"
- "Where is RUBY_SWORD registered?"
- "Show me the block registry"
- "List all custom entities"

---

## Method 1: Name-Based Search (FASTEST)

**Best for**: Mods following standard naming conventions

**Search Strategy**:
```
find_files_by_name_keyword("[RegistryType]")

Common keywords:
- "ModItems" or "Items"
- "ModBlocks" or "Blocks"
- "ModEntities" or "Entities"
- "ModSounds", "ModEffects", "ModParticles", etc.
```

**Example**:
```
Task: Find items registry

Step 1: Search by name
→ find_files_by_name_keyword("ModItems")

Result:
- src/main/java/com/example/mymod/init/ModItems.java
- src/main/java/com/example/mymod/ModItemsClient.java (client-only items)

Step 2: Read file
→ Read("src/main/java/com/example/mymod/init/ModItems.java")

Step 3: Extract entries
→ Look for: RegistryObject<Item> ITEM_NAME = ITEMS.register(...)
```

**Success Rate**: 80-90% for well-organized mods

---

## Method 2: Symbol-Based Search (COMPREHENSIVE)

**Best for**: When registry class name is unknown or non-standard

**Search Strategy**:
```
search_in_files_by_text("DeferredRegister", fileMask="*.java")

Variations:
- "DeferredRegister<Item>" (Forge items)
- "DeferredRegister<Block>" (Forge blocks)
- "Registry.register" (Fabric)
```

**Example**:
```
Task: Find all registries (unknown structure)

Step 1: Search for DeferredRegister
→ search_in_files_by_text("DeferredRegister", fileMask="*.java")

Results:
- ModItems.java: DeferredRegister<Item>
- ModBlocks.java: DeferredRegister<Block>
- ModEntities.java: DeferredRegister<EntityType<?>>
- CustomRegistry.java: DeferredRegister<SomeCustomType>

Step 2: Analyze each
→ Read files and categorize by type
```

**Success Rate**: 95%+ for Forge/NeoForge mods

---

## Method 3: Pattern-Based Search (COMPLETE)

**Best for**: Comprehensive discovery, organized projects

**Search Strategy**:
```
find_files_by_glob("**/init/*.java")
find_files_by_glob("**/registry/*.java")
find_files_by_glob("**/*Registry.java")
```

**Example**:
```
Task: Find all initialization/registry classes

Step 1: Search common locations
→ find_files_by_glob("**/init/*.java")

Results:
- src/main/java/com/mod/init/ModItems.java
- src/main/java/com/mod/init/ModBlocks.java
- src/main/java/com/mod/init/ModEntities.java

Step 2: Search registry package
→ find_files_by_glob("**/registry/*.java")

Results:
- src/main/java/com/mod/registry/ItemRegistry.java

Step 3: Combine results
→ Total: 4 registry files found
```

**Success Rate**: 100% but may include non-registry files

---

## Analyzing Registry Contents

Once you've found a registry file, extract the content:

### Forge/NeoForge Pattern

**Expected structure**:
```java
public class ModItems {
    // DeferredRegister declaration
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

    // Registry entries
    public static final RegistryObject<Item> RUBY = ITEMS.register("ruby",
        () -> new Item(new Item.Properties()));

    public static final RegistryObject<Item> SAPPHIRE = ITEMS.register("sapphire",
        () -> new Item(new Item.Properties()));
}
```

**Extraction Pattern**:
```
1. Find DeferredRegister declaration
   → Pattern: DeferredRegister<(\w+)> (\w+) = DeferredRegister.create
   → Extract: Type (Item), Variable name (ITEMS)

2. Find registry entries
   → Pattern: RegistryObject<(\w+)> (\w+) = (\w+).register\("([^"]+)"
   → Extract: Type, Variable name, Registry name (string)

3. List all entries
   → RUBY (registry name: "ruby")
   → SAPPHIRE (registry name: "sapphire")
```

---

### Fabric Pattern

**Expected structure**:
```java
public class ModItems {
    // Direct registration
    public static final Item RUBY = Registry.register(
        Registries.ITEM,
        new Identifier(MODID, "ruby"),
        new Item(new Item.Settings())
    );

    public static final Item SAPPHIRE = Registry.register(
        Registries.ITEM,
        new Identifier(MODID, "sapphire"),
        new Item(new Item.Settings())
    );
}
```

**Extraction Pattern**:
```
1. Find Registry.register calls
   → Pattern: Registry\.register\([^,]+,\s*new Identifier\([^,]+,\s*"([^"]+)"

2. Extract registry names
   → "ruby", "sapphire"

3. Match to variable names
   → RUBY (registry name: "ruby")
   → SAPPHIRE (registry name: "sapphire")
```

---

## Verification Checks

After discovering registries, verify they're properly set up:

### Check 1: DeferredRegister Registration (Forge/NeoForge)

**What to verify**: DeferredRegister is registered to the MOD event bus

**Search for**:
```
ITEMS.register(bus)
// or
ITEMS.register(FMLJavaModLoadingContext.get().getModEventBus())
```

**Location**: Usually in main mod class constructor

**Example**:
```java
@Mod("mymod")
public class MyMod {
    public MyMod() {
        IEventBus bus = FMLJavaModLoadingContext.get().getModEventBus();

        ModItems.ITEMS.register(bus);       // ✓ Registered
        ModBlocks.BLOCKS.register(bus);     // ✓ Registered
    }
}
```

**If missing**: Registry won't work, items won't appear in-game

---

### Check 2: MODID Constant

**What to verify**: MODID constant is defined and used correctly

**Search for**:
```
public static final String MODID = "yourmodid";
// or
public static final String MOD_ID = "yourmodid";
```

**Verify**:
- DeferredRegister uses same MODID
- Registry names follow convention: `modid:itemname`

---

### Check 3: Registry Type Matching

**What to verify**: Generic types match ForgeRegistries types

**Examples**:
```java
// ✓ CORRECT
DeferredRegister<Item> ITEMS = DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

// ❌ WRONG
DeferredRegister<Block> ITEMS = DeferredRegister.create(ForgeRegistries.ITEMS, MODID);
//                ↑ Type mismatch! Should be <Item>
```

---

## Framework-Specific Patterns

### Forge 1.19.x

**Registry pattern**:
```java
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MODID);
```

**Key differences**:
- Uses `ForgeRegistries.ITEMS` (not `BuiltInRegistries`)
- Creative tabs: `new Item.Properties().tab(CreativeModeTab.TAB_COMBAT)`

---

### Forge 1.20.x / NeoForge

**Registry pattern**:
```java
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MODID);
// or (NeoForge)
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(Registries.ITEMS, MODID);
```

**Key differences**:
- NeoForge may use `Registries` instead of `ForgeRegistries`
- Creative tabs: `new Item.Properties()` (tabs handled differently)

---

### Fabric 1.19.x / 1.20.x

**Registry pattern**:
```java
public static final Item RUBY = Registry.register(
    Registries.ITEM,
    new Identifier(MODID, "ruby"),
    new Item(new FabricItemSettings())
);
```

**Key differences**:
- No DeferredRegister (direct registration)
- Uses `FabricItemSettings` instead of `Item.Properties`
- Registration in static initializer or mod initializer

---

## Common Registry Locations

**Standard Forge/NeoForge structure**:
```
src/main/java/com/modid/
├── init/
│   ├── ModItems.java           (items registry)
│   ├── ModBlocks.java          (blocks registry)
│   ├── ModEntities.java        (entities registry)
│   └── ModEffects.java         (effects registry)
├── items/
│   └── CustomItem.java         (item classes)
└── ModName.java                (main mod class)
```

**Alternative structure**:
```
src/main/java/com/modid/
├── registry/
│   ├── ItemRegistry.java
│   ├── BlockRegistry.java
│   └── EntityRegistry.java
└── content/
    ├── items/
    └── blocks/
```

**Fabric structure**:
```
src/main/java/com/modid/
├── ModItems.java               (item registration)
├── ModBlocks.java              (block registration)
├── item/
│   └── CustomItem.java
└── ModInitializer.java         (mod entry point)
```

---

## Complete Workflow Example

**Task**: Find all items in unknown mod, verify registration

**Step-by-step**:
```
Step 1: Find registry file
→ find_files_by_name_keyword("ModItems")
→ Result: src/main/java/com/example/mymod/init/ModItems.java

Step 2: Read file
→ Read("src/main/java/com/example/mymod/init/ModItems.java")

Step 3: Extract DeferredRegister
→ Found: DeferredRegister<Item> ITEMS = DeferredRegister.create(ForgeRegistries.ITEMS, "mymod")
→ Type: Item, Variable: ITEMS, MODID: "mymod"

Step 4: Extract entries
→ RUBY = ITEMS.register("ruby", ...)
→ SAPPHIRE = ITEMS.register("sapphire", ...)
→ EMERALD_SWORD = ITEMS.register("emerald_sword", ...)
→ Total: 3 items

Step 5: Verify registration
→ Search: "ITEMS.register" in main mod class
→ Found: MyMod.java:15 - ITEMS.register(bus)
→ ✓ Properly registered

Step 6: Report
→ Found 3 items in ModItems.java:
   - RUBY (registry: "mymod:ruby")
   - SAPPHIRE (registry: "mymod:sapphire")
   - EMERALD_SWORD (registry: "mymod:emerald_sword")
→ ✓ DeferredRegister properly registered to MOD bus
```

---

## Summary

**Key Takeaways**:
- 🔍 Use name search first (fastest)
- 📊 Fall back to symbol/pattern search if needed
- ✅ Verify DeferredRegister is registered to bus
- 🎯 Extract both variable names AND registry names
- 🔧 Framework differences (Forge vs NeoForge vs Fabric)

**Tool Performance**:
- Name search: <100ms
- Symbol search: <500ms
- Pattern search: <300ms
- Complete workflow: <1 second
