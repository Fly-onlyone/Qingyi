# Refactoring Scenarios - Common Rename Scenarios and Solutions

This guide provides detailed walkthroughs of the most common refactoring scenarios in Minecraft mod development, with complete workflows and code examples.

## Overview

Each scenario includes:
- **Context**: When this scenario applies
- **Initial State**: Code before refactoring
- **Goal**: Desired outcome
- **Workflow**: Step-by-step process
- **Final State**: Code after refactoring
- **Verification**: How to confirm success

---

## Scenario 1: Rename Java Field (Safe)

### Context

Rename a Java constant/field without changing registry name. **Most common and safest** refactoring.

###Initial State

```java
// src/main/java/com/mod/init/ModItems.java
public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

    public static final RegistryObject<Item> RUBY_SWORD = ITEMS.register(
        "ruby_sword",  // Registry name (PERMANENT)
        () -> new SwordItem(ModItemTier.RUBY, 3, -2.4F, new Item.Properties())
    );
}
```

### Goal

Rename Java field `RUBY_SWORD` to `SAPPHIRE_SWORD`, but **keep registry name** as `"ruby_sword"`.

### Workflow

**Step 1: Execute IntelliJ rename**
```
rename_refactoring(
    pathInProject="src/main/java/com/mod/init/ModItems.java",
    symbolName="RUBY_SWORD",
    newName="SAPPHIRE_SWORD"
)

Result: "Renamed successfully, updated 8 occurrences"
```

### Verification

- ✅ All code references updated automatically
- ✅ Registry name unchanged
- ✅ Existing worlds still work

**Time**: ~30 seconds

---

## Scenario 2: Rename Registry String (DANGER)

### Context

Change the registry name string itself. **Highly dangerous** - breaks existing worlds.

### Initial State

```java
// src/main/java/com/mod/init/ModItems.java
public class ModItems {
    public static final RegistryObject<Item> COPPER_SWORD = ITEMS.register(
        "copper_sword",  // Registry name (PERMANENT)
        () -> new SwordItem(ModItemTier.COPPER, 3, -2.4F, new Item.Properties())
    );
}

// Player world save contains:
// - Player has 5x "modid:copper_sword" in inventory
// - Chest contains 10x "modid:copper_sword"
```

### Goal

Change registry name from `"copper_sword"` to `"bronze_sword"`, understanding this **breaks existing worlds**.

### Workflow

**Step 1: WARN USER**
```
⚠️ WARNING: Registry Name Change Detected

Changing "copper_sword" → "bronze_sword" will:
- DELETE all Copper Swords from player inventories
- REMOVE all Copper Sword blocks from worlds
- BREAK compatibility with existing saves

Are you sure? (yes/no/add-alias)
```

**Step 2: If user confirms "yes"**
```
replace_text_in_file(
    pathInProject="src/main/java/com/mod/init/ModItems.java",
    oldText='"copper_sword"',
    newText='"bronze_sword"',
    caseSensitive=true,
    replaceAll=false
)

Result: Registry string updated
```

**Step 3: Update all resources**
```
1. Rename model:
   mv assets/modid/models/item/copper_sword.json → bronze_sword.json

2. Rename texture:
   mv assets/modid/textures/item/copper_sword.png → bronze_sword.png

3. Update lang file:
   replace_text_in_file(
       pathInProject="src/main/resources/assets/modid/lang/en_us.json",
       oldText="item.modid.copper_sword",
       newText="item.modid.bronze_sword",
       replaceAll=true
   )

4. Update recipes:
   - Rename data/modid/recipes/copper_sword.json → bronze_sword.json
   - Update "result": {"item": "modid:bronze_sword"}

5. Search for remaining references:
   search_in_files_by_text("copper_sword")
   → Update any loot tables, advancements, tags
```

### Final State

```java
// Code
public static final RegistryObject<Item> COPPER_SWORD = ITEMS.register(
    "bronze_sword",  // Registry name CHANGED
    () -> new SwordItem(...)
);

// Resources all updated to bronze_sword
```

### Verification

- ✅ Registry name changed
- ✅ All resources updated
- ⚠️ **Existing worlds BROKEN** - copper swords deleted
- 📝 Document in changelog as BREAKING CHANGE

**Time**: ~5-10 minutes

**Impact**: 🔴 **WORLD-BREAKING** - Use only during development or with migration strategy

---

## Scenario 3: Rename Method (Safe)

### Context

Rename a helper method or initialization method. **Safe and fast**.

### Initial State

```java
// src/main/java/com/mod/init/ModItems.java
public class ModItems {
    public static void registerItems() {
        // Item registration logic
    }
}

// src/main/java/com/mod/ExampleMod.java
public ExampleMod() {
    ModItems.registerItems();  // Called here
}

// test/java/com/mod/test/ItemTest.java
public void testSetup() {
    ModItems.registerItems();  // Also called in tests
}
```

### Goal

Rename method `registerItems()` to `initializeItems()` across entire project.

### Workflow

**Step 1: Execute IntelliJ rename**
```
rename_refactoring(
    pathInProject="src/main/java/com/mod/init/ModItems.java",
    symbolName="registerItems",
    newName="initializeItems"
)

Result: "Renamed successfully, updated 8 occurrences"
```

**Step 2: Verify propagation**
```
search_in_files_by_text("registerItems", caseSensitive=true)

Expected: No occurrences found
```

### Final State

```java
// ModItems.java
public static void initializeItems() { ... }

// ExampleMod.java
ModItems.initializeItems();  // Automatically updated

// ItemTest.java
ModItems.initializeItems();  // Automatically updated
```

### Verification

- ✅ Method declaration renamed
- ✅ All callers updated automatically
- ✅ No broken references
- ✅ Code compiles successfully
- ✅ No world compatibility issues

**Time**: ~10 seconds

---

## Scenario 4: Package Refactoring (Complex)

### Context

Move classes to different packages (reorganization). **Moderately complex**.

### Initial State

```java
// src/main/java/com/mod/item/ModItems.java
package com.mod.item;

public class ModItems { ... }

// src/main/java/com/mod/ExampleMod.java
package com.mod;
import com.mod.item.ModItems;  // Import from old package

public class ExampleMod {
    ModItems.COPPER_SWORD.get();
}
```

### Goal

Move `ModItems` from `com.mod.item` → `com.mod.content.item` package.

### Workflow

**Step 1: Rename package**
```
rename_refactoring(
    pathInProject="src/main/java/com/mod/item/ModItems.java",
    symbolName="com.mod.item",  // Package name
    newName="com.mod.content.item"
)

Result: IntelliJ moves class and updates all imports
```

**Step 2: Verify file moved**
```
File structure before:
src/main/java/com/mod/item/ModItems.java

File structure after:
src/main/java/com/mod/content/item/ModItems.java
```

**Step 3: Verify imports updated**
```
// ExampleMod.java (automatically updated)
import com.mod.content.item.ModItems;  // Import path updated
```

### Final State

```
Directory structure:
src/main/java/
└── com/mod/
    ├── ExampleMod.java
    └── content/
        └── item/
            └── ModItems.java  (moved here)

All imports automatically updated
```

### Verification

- ✅ Class moved to new package
- ✅ Package declaration updated
- ✅ All imports updated automatically
- ✅ No broken references
- ✅ No resource updates needed (registry names unchanged)
- ✅ Code compiles successfully

**Time**: ~1-2 minutes

---

## Scenario 5: Complete Item Rename (Registry + Resources)

### Context

Complete rename including registry name and all resources. **Most comprehensive scenario**.

### Initial State

```java
// Code
public static final RegistryObject<Item> RUBY_SWORD = ITEMS.register(
    "ruby_sword",
    () -> new SwordItem(...)
);

// Resources
assets/modid/models/item/ruby_sword.json
assets/modid/textures/item/ruby_sword.png
assets/modid/lang/en_us.json: "item.modid.ruby_sword": "Ruby Sword"
data/modid/recipes/ruby_sword.json
```

### Goal

Completely rename item from Ruby Sword to Sapphire Sword (code + registry + resources).

### Workflow

**Step 1: WARN about world impact**
```
⚠️ Complete item rename will BREAK EXISTING WORLDS
This includes registry name change.
Proceed? (yes/no)
```

**Step 2: Rename Java constant**
```
rename_refactoring(
    pathInProject="src/main/java/com/mod/init/ModItems.java",
    symbolName="RUBY_SWORD",
    newName="SAPPHIRE_SWORD"
)

Result: Java field renamed, all code references updated
```

**Step 3: Rename registry string**
```
replace_text_in_file(
    pathInProject="src/main/java/com/mod/init/ModItems.java",
    oldText='"ruby_sword"',
    newText='"sapphire_sword"'
)
```

**Step 4: Rename model file**
```
execute_terminal_command(
    command="mv src/main/resources/assets/modid/models/item/ruby_sword.json src/main/resources/assets/modid/models/item/sapphire_sword.json"
)
```

**Step 5: Rename texture file**
```
execute_terminal_command(
    command="mv src/main/resources/assets/modid/textures/item/ruby_sword.png src/main/resources/assets/modid/textures/item/sapphire_sword.png"
)
```

**Step 6: Update lang file**
```
replace_text_in_file(
    pathInProject="src/main/resources/assets/modid/lang/en_us.json",
    oldText='"item.modid.ruby_sword"',
    newText='"item.modid.sapphire_sword"',
    replaceAll=true
)

replace_text_in_file(
    pathInProject="src/main/resources/assets/modid/lang/en_us.json",
    oldText='"Ruby Sword"',
    newText='"Sapphire Sword"'
)
```

**Step 7: Rename and update recipe**
```
execute_terminal_command(
    command="mv src/main/resources/data/modid/recipes/ruby_sword.json src/main/resources/data/modid/recipes/sapphire_sword.json"
)

replace_text_in_file(
    pathInProject="src/main/resources/data/modid/recipes/sapphire_sword.json",
    oldText='"modid:ruby_sword"',
    newText='"modid:sapphire_sword"'
)
```

**Step 8: Search for any remaining references**
```
search_in_files_by_text("ruby_sword")

If found: Update loot tables, advancements, tags, etc.
```

**Step 9: Test in-game**
```
execute_run_configuration(
    configurationName="runClient",
    timeout=120000
)

Verify:
- Item appears in creative inventory
- Texture renders correctly
- Recipe works
```

### Final State

```
All files renamed and updated:
✅ Java constant: RUBY_SWORD → SAPPHIRE_SWORD
✅ Registry: "ruby_sword" → "sapphire_sword"
✅ Model: sapphire_sword.json
✅ Texture: sapphire_sword.png
✅ Lang: "item.modid.sapphire_sword": "Sapphire Sword"
✅ Recipe: sapphire_sword.json (with correct references)
```

### Verification

- ✅ Code compiles
- ✅ Mod loads in dev environment
- ✅ Item appears with correct name
- ✅ Texture renders
- ✅ Recipe works
- ⚠️ **Existing ruby swords deleted from old saves**

**Time**: ~10-15 minutes

**Impact**: 🔴 **WORLD-BREAKING**

---

## Scenario 6: Class Rename with References

### Context

Rename a Java class with many references across project.

### Initial State

```java
// src/main/java/com/mod/item/CustomSword.java
package com.mod.item;

public class CustomSword extends SwordItem {
    public CustomSword() { ... }
}

// src/main/java/com/mod/init/ModItems.java
import com.mod.item.CustomSword;

public static final RegistryObject<Item> SWORD = ITEMS.register(
    "custom_sword",
    () -> new CustomSword()  // References CustomSword class
);

// src/main/java/com/mod/handler/ItemHandler.java
import com.mod.item.CustomSword;

public void handleSword(CustomSword sword) { ... }
```

### Goal

Rename class `CustomSword` to `EnchantedSword`.

### Workflow

**Step 1: Rename class**
```
rename_refactoring(
    pathInProject="src/main/java/com/mod/item/CustomSword.java",
    symbolName="CustomSword",
    newName="EnchantedSword"
)

Result: "Renamed successfully, updated 12 occurrences"
```

**IntelliJ automatically updates**:
- ✅ Class declaration
- ✅ File name (CustomSword.java → EnchantedSword.java)
- ✅ All import statements
- ✅ All constructor calls (`new CustomSword()` → `new EnchantedSword()`)
- ✅ All type references (`CustomSword sword` → `EnchantedSword sword`)

### Final State

```java
// src/main/java/com/mod/item/EnchantedSword.java
package com.mod.item;

public class EnchantedSword extends SwordItem { ... }

// ModItems.java
import com.mod.item.EnchantedSword;
() -> new EnchantedSword()  // Updated

// ItemHandler.java
import com.mod.item.EnchantedSword;
public void handleSword(EnchantedSword sword) { ... }  // Updated
```

### Verification

- ✅ Class file renamed
- ✅ All imports updated
- ✅ All references updated
- ✅ Code compiles
- ✅ No world compatibility issues (registry name unchanged)

**Time**: ~30 seconds

---

## Scenario 7: Multi-File Batch Rename

### Context

Rename multiple related items at once (e.g., a set of tools).

### Initial State

```java
public static final RegistryObject<Item> COPPER_SWORD = ITEMS.register("copper_sword", ...);
public static final RegistryObject<Item> COPPER_PICKAXE = ITEMS.register("copper_pickaxe", ...);
public static final RegistryObject<Item> COPPER_AXE = ITEMS.register("copper_axe", ...);
public static final RegistryObject<Item> COPPER_SHOVEL = ITEMS.register("copper_shovel", ...);
```

### Goal

Rename all `COPPER_*` items to `BRONZE_*` (Java constants only, keep registry names).

### Workflow

**Approach: Sequential renames (safest)**

```
For each item:
1. rename_refactoring("ModItems.java", "COPPER_SWORD", "BRONZE_SWORD")
2. rename_refactoring("ModItems.java", "COPPER_PICKAXE", "BRONZE_PICKAXE")
3. rename_refactoring("ModItems.java", "COPPER_AXE", "BRONZE_AXE")
4. rename_refactoring("ModItems.java", "COPPER_SHOVEL", "BRONZE_SHOVEL")

Result: All Java constants renamed, registry names unchanged
```

### Final State

```java
public static final RegistryObject<Item> BRONZE_SWORD = ITEMS.register("copper_sword", ...);
public static final RegistryObject<Item> BRONZE_PICKAXE = ITEMS.register("copper_pickaxe", ...);
public static final RegistryObject<Item> BRONZE_AXE = ITEMS.register("copper_axe", ...);
public static final RegistryObject<Item> BRONZE_SHOVEL = ITEMS.register("copper_shovel", ...);
```

### Verification

- ✅ All Java constants renamed
- ✅ All code references updated
- ✅ Registry names unchanged
- ✅ No world compatibility issues
- ✅ Code compiles

**Time**: ~2 minutes (4 renames)

---

## Scenario 8: Refactoring in Multi-Loader Projects

### Context

Rename in multi-loader architecture (Common + Forge + Fabric).

### Initial State

```java
// common/src/.../CommonItems.java
public class CommonItems {
    public static Item RUBY_SWORD;  // Common definition

    public static void registerItems() { ... }
}

// forge/src/.../ForgeItems.java
public class ForgeItems {
    public static final RegistryObject<Item> RUBY_SWORD = ITEMS.register(
        "ruby_sword",
        () -> CommonItems.RUBY_SWORD = new SwordItem(...)
    );
}

// fabric/src/.../FabricItems.java
public class FabricItems {
    public static void register() {
        CommonItems.RUBY_SWORD = Registry.register(
            Registries.ITEM,
            new Identifier("modid", "ruby_sword"),
            new SwordItem(...)
        );
    }
}
```

### Goal

Rename `RUBY_SWORD` to `SAPPHIRE_SWORD` across all loaders (Java only).

### Workflow

**Step 1: Rename in common module**
```
rename_refactoring(
    pathInProject="common/src/main/java/com/mod/init/CommonItems.java",
    symbolName="RUBY_SWORD",
    newName="SAPPHIRE_SWORD"
)

Result: Common field renamed
```

**Step 2: Rename in Forge module**
```
rename_refactoring(
    pathInProject="forge/src/main/java/com/mod/init/ForgeItems.java",
    symbolName="RUBY_SWORD",
    newName="SAPPHIRE_SWORD"
)

Result: Forge field renamed
```

**Step 3: Verify Fabric module updated**
```
search_in_files_by_text(
    searchText="CommonItems.RUBY_SWORD",
    directoryToSearch="fabric"
)

Expected: No occurrences (IntelliJ auto-updated the reference)
```

### Final State

```java
// Common
public static Item SAPPHIRE_SWORD;

// Forge
public static final RegistryObject<Item> SAPPHIRE_SWORD = ...
() -> CommonItems.SAPPHIRE_SWORD = new SwordItem(...)

// Fabric
CommonItems.SAPPHIRE_SWORD = Registry.register(...)
```

### Verification

- ✅ Renamed in all modules
- ✅ Cross-module references updated
- ✅ Registry names unchanged (no world impact)
- ✅ All loaders compile
- ✅ Test each loader in dev environment

**Time**: ~2-3 minutes

---

## Summary Table

| Scenario | Complexity | World Impact | Time | Key Tools |
|----------|-----------|--------------|------|-----------|
| 1. Java Field Rename | Low | 🟢 None | ~30s | `rename_refactoring` |
| 2. Registry String Rename | High | 🔴 BREAKING | ~5-10m | `replace_text_in_file` + resources |
| 3. Method Rename | Low | 🟢 None | ~10s | `rename_refactoring` |
| 4. Package Refactoring | Medium | 🟢 None | ~1-2m | `rename_refactoring` |
| 5. Complete Item Rename | Very High | 🔴 BREAKING | ~10-15m | All tools + testing |
| 6. Class Rename | Low | 🟢 None | ~30s | `rename_refactoring` |
| 7. Batch Rename | Medium | 🟢 None | ~2m | Multiple `rename_refactoring` |
| 8. Multi-Loader Rename | Medium | 🟢 None | ~2-3m | `rename_refactoring` + verification |

---

## Decision Matrix

**When user requests rename, ask**:

1. **What are you renaming?**
   - Java symbol (variable/method/class) → Use Scenario 1, 3, or 6
   - Registry string → Use Scenario 2 (WARN FIRST)
   - Complete item → Use Scenario 5 (WARN FIRST)

2. **Has the mod been released?**
   - No (still in development) → Safe to rename registry
   - Yes (players have worlds) → WARN about world breaking

3. **Is this a multi-loader project?**
   - Yes → Use Scenario 8 approach
   - No → Use standard scenarios

4. **How many items?**
   - Single item → Standard scenario
   - Multiple items → Use Scenario 7 (batch)

---

Back to [intellij-refactoring-master.md](../../intellij-refactoring-master.md)
