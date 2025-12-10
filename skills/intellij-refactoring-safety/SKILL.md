---
name: intellij-refactoring-safety
description: Safe refactoring for Minecraft mods. Covers rename_refactoring vs text replacement, scope awareness, resource synchronization, world compatibility, migration strategies. Use when performing rename operations on items, blocks, entities, or code symbols.
allowed-tools: mcp__intellij__rename_refactoring, mcp__intellij__replace_text_in_file
---

# IntelliJ Refactoring Safety - Best Practices for Safe Code Refactoring

This skill provides comprehensive guidance on safe refactoring operations for Minecraft mods, ensuring code changes propagate correctly while maintaining world compatibility.

## Overview

Refactoring in Minecraft mod development requires special care due to:
- **World save compatibility**: Registry names are permanent identifiers
- **Resource file dependencies**: Models, textures, lang files must stay synchronized
- **Scope complexity**: Java shadowing and multiple symbols with same names
- **Cross-module references**: Multi-loader projects with shared code

**Key Principle**: Use IntelliJ's semantic refactoring tools (`rename_refactoring`) instead of text replacement whenever possible.

---

## rename_refactoring vs Text Replacement

### Comparison Table

| Feature | rename_refactoring | Text Replacement |
|---------|-------------------|------------------|
| **Scope Awareness** | ✅ Yes (only renames specific symbol) | ❌ No (replaces all text matches) |
| **Reference Updates** | ✅ Automatic (entire project) | ❌ Manual (per-file) |
| **Shadowing Handling** | ✅ Correct (understands scopes) | ❌ Breaks (renames unrelated symbols) |
| **Collision Detection** | ✅ Yes (warns about conflicts) | ❌ No (can create duplicates) |
| **Resource Files** | ❌ Code only | ✅ Can update (but risky) |
| **String Literals** | ❌ Not changed | ✅ Changed |
| **Accuracy** | ✅ 98% | ⚠️ 85% |

### When to Use Each

**Use rename_refactoring** for:
- ✅ Java symbols (variables, fields, methods, classes)
- ✅ Registry object variable names (`COPPER_SWORD` → `BRONZE_SWORD`)
- ✅ Method names (`registerItems()` → `setupItemRegistry()`)
- ✅ Parameter and local variable names
- ✅ Class names (when not in NBT)

**Use text replacement** for:
- ✅ Registry strings (`"copper_sword"` → `"bronze_sword"`)
- ✅ JSON file content (models, lang files)
- ✅ Comments and documentation
- ✅ String literals that aren't code symbols

**Example**:
```java
// Rename variable: Use rename_refactoring
public static final RegistryObject<Item> COPPER_SWORD =
    ITEMS.register("copper_sword", () -> ...);
    // ↑ Variable name                    ↑ String literal

// Step 1: rename_refactoring for COPPER_SWORD variable
// Step 2: replace_text_in_file for "copper_sword" string
```

---

## Scope Awareness

### Understanding Scope

Scope-aware renaming only changes the specific symbol you select, not all text that matches.

**Example Problem**:
```java
public class ItemManager {
    private Item defaultItem;  // Field

    public void setItem(Item defaultItem) {  // Parameter (shadows field)
        Item defaultItem = getDefault();  // Local (shadows parameter)
        this.defaultItem = defaultItem;  // Field reference
    }
}
```

Three different `defaultItem` symbols in three different scopes!

**With text replacement** ("defaultItem" → "currentItem"):
```java
// BREAKS! All three renamed
public class ItemManager {
    private Item currentItem;  // ✅ Field renamed
    public void setItem(Item currentItem) {  // ❌ Parameter renamed (shouldn't)
        Item currentItem = getDefault();  // ❌ Local renamed (shouldn't)
        this.currentItem = currentItem;  // ❌ Broken reference!
    }
}
```

**With rename_refactoring** (select field only):
```java
// CORRECT! Only field renamed
public class ItemManager {
    private Item currentItem;  // ✅ Field renamed
    public void setItem(Item defaultItem) {  // ✅ Parameter unchanged
        Item defaultItem = getDefault();  // ✅ Local unchanged
        this.currentItem = defaultItem;  // ✅ Correct reference!
    }
}
```

### Shadowing Patterns in Minecraft

**Common shadowing scenario**:
```java
// Registry object field
public static final RegistryObject<Item> CUSTOM_SWORD = ...;

// Method parameter shadows field name (different context)
public void registerCustomItem(RegistryObject<Item> CUSTOM_SWORD) {
    // This CUSTOM_SWORD is the parameter, not the field!
}
```

**rename_refactoring** understands this distinction. Text replacement does not.

---

## Resource File Synchronization

### The Synchronization Problem

When renaming registry objects, **code and resources must stay aligned**:

```
Code: COPPER_SWORD
├─ Registry: "copper_sword"
├─ Model: copper_sword.json
├─ Texture: copper_sword.png
├─ Lang: "item.modid.copper_sword"
└─ Recipes: "modid:copper_sword"

All must be updated together!
```

### Synchronization Workflow

**Step 1**: Rename code symbol
```java
// Use rename_refactoring
rename_refactoring("ModItems.java", "COPPER_SWORD", "BRONZE_SWORD")

// Before:
public static final RegistryObject<Item> COPPER_SWORD = ...;

// After:
public static final RegistryObject<Item> BRONZE_SWORD = ...;
```

**Step 2**: Update registry string
```java
// Use replace_text_in_file or Edit
"copper_sword" → "bronze_sword"

// After:
ITEMS.register("bronze_sword", () => ...)
```

**Step 3**: Rename model file
```bash
# Old: assets/modid/models/item/copper_sword.json
# New: assets/modid/models/item/bronze_sword.json

1. Read old file
2. Write to new location
3. Update "parent" references if nested
```

**Step 4**: Rename texture file
```bash
# Old: assets/modid/textures/item/copper_sword.png
# New: assets/modid/textures/item/bronze_sword.png
```

**Step 5**: Update lang file
```json
// assets/modid/lang/en_us.json
{
-  "item.modid.copper_sword": "Copper Sword",
+  "item.modid.bronze_sword": "Bronze Sword",
}
```

**Step 6**: Update recipes and loot tables
```json
// Search all JSON files for "modid:copper_sword"
// Replace with "modid:bronze_sword"

// Example recipe:
{
  "result": {
-    "item": "modid:copper_sword"
+    "item": "modid:bronze_sword"
  }
}
```

### Common Mistakes

**❌ Mistake 1**: Renaming code but forgetting resources
```java
// Code renamed
public static final RegistryObject<Item> BRONZE_SWORD =
    ITEMS.register("copper_sword", ...);  // ← Forgot registry string!
```
Result: Code says `BRONZE_SWORD` but registry is still `copper_sword` (confusing)

**❌ Mistake 2**: Updating resources but code doesn't match
```json
// Lang file says bronze
"item.modid.bronze_sword": "Bronze Sword"

// But code still says copper
public static final RegistryObject<Item> COPPER_SWORD = ...;
```
Result: Translation key mismatch, item shows wrong name

**❌ Mistake 3**: Using text replacement on code
```java
// Text replacement changes ALL "sword" → "blade"
ITEMS.register("ruby_sword", () -> new SwordItem(...));
                    // ↑               ↑
                    // Changed      Changed (breaks SwordItem class!)
```
Result: Compilation error, `SwordItem` class renamed to `BladeItem`

---

## Preview and Validation

### Preview Before Applying

Always verify symbol before renaming:

**Step 1**: Use `get_symbol_info()` to preview
```
get_symbol_info("ModItems.java", 42, 30)

Returns:
- Symbol: COPPER_SWORD
- Type: static final field
- Scope: class-level
- References: 8 files
```

**Step 2**: Confirm this is the correct symbol
```
Expected: RegistryObject<Item> field
Actual: RegistryObject<Item> field ✅

Expected scope: class-level
Actual scope: class-level ✅

Proceed with rename? Yes
```

**Step 3**: Execute rename
```
rename_refactoring("ModItems.java", "COPPER_SWORD", "BRONZE_SWORD")
```

### Validation After Refactoring

**Always validate** after refactoring:

**Step 1**: Check compilation
```
get_file_problems("ModItems.java", errorsOnly=true)

→ No errors ✅
```

**Step 2**: Search for broken references
```
search_in_files_by_text("COPPER_SWORD")

→ No results (all renamed successfully) ✅
```

**Step 3**: Verify resource files exist
```
Check:
- assets/modid/models/item/bronze_sword.json ✅
- assets/modid/textures/item/bronze_sword.png ✅
- Lang file has bronze_sword entry ✅
```

### Rollback Strategy

If refactoring goes wrong:

**Option 1**: Git revert (recommended)
```bash
git checkout -- .
```

**Option 2**: Manual undo with inverse rename
```
rename_refactoring("ModItems.java", "BRONZE_SWORD", "COPPER_SWORD")
# Then restore resource files
```

**Option 3**: Use IDE's local history
```
IntelliJ: Right-click file → Local History → Show History
```

---

## Progressive Skill Loading

This skill uses **progressive loading** to optimize token usage. The main file (this file) provides overview and core concepts. For detailed patterns and examples, see:

### Supporting Files

1. **[Registry Name Changes](./registry-name-changes.md)** (~200 lines)
   - Impact of renaming registry names on world saves
   - MissingMappingsEvent handlers for migration
   - Alias patterns for backward compatibility
   - When to rename vs when to keep old names
   - Real examples from Forge and Fabric mods

2. **[Resource Sync Patterns](./resource-sync-patterns.md)** (~200 lines)
   - Complete workflows for synchronizing models, textures, lang files
   - Automation strategies for bulk renames
   - Nested model handling (parent references)
   - Recipe and loot table update patterns
   - Tag file synchronization

3. **[Breaking Changes Guide](./breaking-changes-guide.md)** (~200 lines)
   - What breaks worlds (registry names, NBT tags, SavedData)
   - What's safe to rename (variables, methods, translation keys)
   - Version compatibility strategies
   - Deprecation patterns
   - Change documentation for users

### When to Load Supporting Files

**Load [Registry Name Changes](./registry-name-changes.md)** when:
- Renaming items, blocks, entities (registry objects)
- User asks about world compatibility
- Need migration strategy examples

**Load [Resource Sync Patterns](./resource-sync-patterns.md)** when:
- Performing registry object renames
- Need detailed model/texture update workflow
- Batch renaming multiple items

**Load [Breaking Changes Guide](./breaking-changes-guide.md)** when:
- User asks "will this break worlds?"
- Renaming NBT tags or SavedData identifiers
- Planning version updates for released mods

---

## Quick Reference

### Renaming Checklist

When renaming a registry object:

**Code (automatic with rename_refactoring)**:
- [ ] Field/variable declaration renamed
- [ ] All code references updated
- [ ] No compilation errors

**Registry String (manual)**:
- [ ] Updated `ITEMS.register("old_name", ...)` → `"new_name"`

**Resource Files (manual)**:
- [ ] Model file renamed
- [ ] Texture file renamed
- [ ] Lang file entry updated
- [ ] Recipes updated
- [ ] Loot tables updated
- [ ] Tags updated

**Validation**:
- [ ] Code compiles
- [ ] No broken references
- [ ] Resource files exist
- [ ] Breaking change warning issued (if applicable)

### Tool Selection Guide

**For renaming:**
| Target | Tool | Notes |
|--------|------|-------|
| Variable/field | `rename_refactoring` | Scope-aware, 98% accurate |
| Method | `rename_refactoring` | Updates all callers |
| Class | `rename_refactoring` | Check NBT usage first |
| Registry string | `replace_text_in_file` | Literal string, not a symbol |
| JSON content | `replace_text_in_file` | Or use Edit tool |
| File name | Read + Write | Move to new location |

---

## Summary

Safe refactoring for Minecraft mods requires:

1. **Scope-aware renaming**: Use `rename_refactoring` for code symbols
2. **Resource synchronization**: Manually update models, textures, lang files
3. **World compatibility**: Warn about breaking changes, offer migration
4. **Validation**: Always check compilation and references after refactoring

**Key Benefits**:
- ✅ 98% accuracy vs 85% with text replacement
- ✅ Prevents scope errors and shadowing bugs
- ✅ Maintains world compatibility awareness
- ✅ Professional-grade refactoring quality

For detailed patterns and migration strategies, see the supporting files linked above.
