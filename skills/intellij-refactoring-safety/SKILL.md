---
name: intellij-refactoring-safety
description: Safe refactoring for Minecraft mods. Covers rename_refactoring vs text replacement, scope awareness, resource synchronization, world compatibility. Use when renaming items, blocks, entities, or code symbols.
allowed-tools: mcp__intellij__rename_refactoring, mcp__intellij__replace_text_in_file
---

# IntelliJ Refactoring Safety

## What This Covers

- Safe refactoring with rename_refactoring tool
- Scope-aware symbol renaming
- Resource file synchronization
- World save compatibility rules
- When to use text replacement vs semantic renaming

## When to Use

- Renaming Java symbols (fields, methods, classes)
- Changing variable names
- Refactoring code structure
- Ensuring registry name compatibility
- Updating resource file references

---

## Key Principles

### Rule 1: Registry Names are Permanent
**Once released, registry names CANNOT change without migration**

Registry names identify items/blocks/entities in world saves:
```java
// ❌ NEVER change after release
ITEMS.register("ruby_sword", ...)  // Saved in world files

// ✅ Java field names CAN change safely
public static final Item RUBY_SWORD = ...
```

### Rule 2: Use rename_refactoring for Java Symbols
**Semantic refactoring is safer than text replacement**

```
✅ rename_refactoring: Scope-aware, updates all references
❌ Text replacement: Blind find-replace, risks unintended changes
```

### Rule 3: Resource Files Need Manual Updates
**IntelliJ doesn't update JSON/lang files automatically**

After renaming Java symbols, update:
- `assets/modid/models/item/*.json`
- `assets/modid/lang/en_us.json`
- `data/modid/recipes/*.json`

---

## rename_refactoring vs Text Replacement

| Feature | rename_refactoring | Text Replacement |
|---------|-------------------|------------------|
| Scope awareness | ✅ Yes (specific symbol) | ❌ No (all matches) |
| Reference updates | ✅ Automatic (project-wide) | ❌ Manual (per-file) |
| Safety | ✅ High (type-safe) | ⚠️ Medium (string-based) |
| Speed | ⚠️ Slower (semantic analysis) | ✅ Faster (text search) |
| Resource files | ❌ No (manual update) | ✅ Yes (if needed) |

**Use rename_refactoring** for Java symbols (variables, methods, classes)
**Use text replacement** for registry names, resource paths, string literals

---

## Safe Renaming Workflow

### Step 1: Identify What to Rename

**Java Symbols** (safe to rename):
- Field names: `RUBY_SWORD` → `RUBY_BLADE`
- Method names: `registerItems()` → `registerContent()`
- Class names: `ModItems` → `ModRegistry`
- Variable names: `item` → `weapon`

**Registry Names** (requires migration):
- `"ruby_sword"` → Needs data migration for world saves
- `new Identifier(MODID, "ruby_sword")` → Same

### Step 2: Use rename_refactoring

```
mcp__intellij__rename_refactoring(
  pathInProject: "src/main/java/com/mod/ModItems.java",
  symbolName: "RUBY_SWORD",
  newName: "RUBY_BLADE"
)
```

**Result**: IntelliJ updates ALL references across project

### Step 3: Update Resource Files

**Manually update**:
```json
// assets/modid/lang/en_us.json
{
  "item.modid.ruby_sword": "Ruby Blade"  // Update display name
}

// No change to registry name!
// "ruby_sword" stays as-is in registry
```

### Step 4: Verify

```
1. Compile mod → Check for errors
2. Search for old name → Ensure all updated
3. Test in-game → Verify functionality
```

---

## Common Refactoring Patterns

### Pattern 1: Rename Java Field

**Goal**: Change `RUBY` to `RUBY_GEM`

**Safe approach**:
```
rename_refactoring(
  pathInProject: "ModItems.java",
  symbolName: "RUBY",
  newName: "RUBY_GEM"
)
```

**Result**:
```java
// Before
public static final Item RUBY = ITEMS.register("ruby", ...);

// After
public static final Item RUBY_GEM = ITEMS.register("ruby", ...);
//                        ↑ Field renamed, registry name unchanged
```

### Pattern 2: Rename Class

**Goal**: Change `ModItems` to `ModRegistry`

**Safe approach**:
```
rename_refactoring(
  pathInProject: "ModItems.java",
  symbolName: "ModItems",
  newName: "ModRegistry"
)
```

**Updates**:
- Class name
- File name (ModItems.java → ModRegistry.java)
- All imports
- All references

### Pattern 3: Rename Method

**Goal**: Change `registerItems()` to `register()`

**Safe approach**:
```
rename_refactoring(
  pathInProject: "ModItems.java",
  symbolName: "registerItems",
  newName: "register"
)
```

**Updates** all call sites automatically

### Pattern 4: Update Registry Name (Unsafe)

**Goal**: Change registry name `"ruby"` to `"gem"`

**⚠️ Breaking Change**: Requires world migration

**Migration code**:
```java
// Add missing item handler
@SubscribeEvent
public static void onMissingMappings(MissingMappingsEvent event) {
    event.getMappings(ForgeRegistries.ITEMS, MODID).forEach(mapping -> {
        if (mapping.getKey().equals(new ResourceLocation(MODID, "ruby"))) {
            mapping.remap(ModItems.RUBY_GEM.get());
        }
    });
}
```

---

## World Compatibility Rules

### Safe Changes (No Migration Needed)
- ✅ Java field/method/class names
- ✅ Code logic and implementation
- ✅ Display names in lang files
- ✅ Model/texture file contents
- ✅ Adding new items/blocks

### Unsafe Changes (Migration Required)
- ❌ Registry names (`"ruby"` → `"gem"`)
- ❌ Removing items/blocks (leaves orphaned data)
- ❌ Changing item/block types (Item → BlockItem)

---

## Scope Awareness Example

**Problem**: Multiple symbols named `ITEM`

```java
// File 1: ModItems.java
public static final Item ITEM = ...;

// File 2: OtherItems.java
public static final Item ITEM = ...;
```

**Using rename_refactoring**:
```
rename_refactoring(
  pathInProject: "ModItems.java",
  symbolName: "ITEM",
  newName: "RUBY"
)
```

**Result**: Only renames `ITEM` in ModItems.java, not OtherItems.java ✅

**Using text replacement**:
```
replace_text_in_file(
  pathInProject: "ModItems.java",
  oldText: "ITEM",
  newText: "RUBY"
)
```

**Result**: Renames ALL occurrences of "ITEM" string, including unintended matches ❌

---

## Common Mistakes

### ❌ Changing Registry Names After Release
```java
// WRONG: Breaks existing worlds
ITEMS.register("ruby_sword_v2", ...)  // Old worlds have "ruby_sword"
```

### ❌ Using Text Replacement for Symbols
```java
// WRONG: Might rename unintended matches
replace_text("Item", "CustomItem")  // Renames "ItemStack" → "CustomItemStack"
```

### ❌ Forgetting Resource File Updates
```java
// After renaming RUBY_SWORD → RUBY_BLADE
// WRONG: Lang file still says
{
  "item.modid.ruby_sword": "Ruby Sword"  // ← Outdated
}

// RIGHT: Update lang file
{
  "item.modid.ruby_sword": "Ruby Blade"  // ← Fixed display name
}
```

---

## Quick Decision Tree

**Renaming Java symbol (field/method/class)?**
→ Use `rename_refactoring`

**Changing registry name?**
→ ⚠️ Requires migration, add MissingMappingsEvent handler

**Updating string literals or resource paths?**
→ Use `replace_text_in_file`

**Need to rename across multiple files?**
→ Use `rename_refactoring` (updates all references)

**Not sure about scope?**
→ Use `rename_refactoring` (scope-aware)

---

## Supporting Documentation

### Detailed Guides
- [World Migration Patterns](./world-migration-patterns.md) - Handling registry changes
- [Resource Synchronization](./resource-synchronization.md) - Keeping JSON/lang files updated
- [Scope Analysis Guide](./scope-analysis-guide.md) - Understanding symbol scope

---

Use this skill when refactoring Minecraft mod code to ensure safe, scope-aware changes that maintain world compatibility.
