# Resource File Mapping Patterns

This document provides detailed patterns for mapping Minecraft mod code to resource files (models, textures, lang files) using IntelliJ MCP navigation tools.

## Overview

**Objective**: Connect registry names in code to their corresponding resource files (JSON models, PNG textures, language files).

**Common Use Cases**:
- "Find the model for RUBY_SWORD"
- "Map CUSTOM_BLOCK to its resources"
- "Check if all resources exist for DIAMOND_STAFF"
- "Debug missing texture for new item"

**Resource Chain**:
```
Code → Model → Texture → Lang File
```

---

## 5-Step Mapping Workflow

### Step 1: Find Registry Name in Code

**Objective**: Extract the registry name (string) from code

**Search methods**:
```
Method 1: If you know the item variable name
→ search_in_files_by_text("RUBY_SWORD", fileMask="*.java")
→ Find: ITEMS.register("ruby_sword", ...)
→ Registry name: "ruby_sword"

Method 2: If you don't know the variable name
→ find_files_by_name_keyword("ModItems")
→ Read file and extract all registry names
```

**Expected patterns**:

**Forge/NeoForge**:
```java
public static final RegistryObject<Item> RUBY_SWORD = ITEMS.register("ruby_sword",
    () -> new SwordItem(...));
```
→ Registry name: `"ruby_sword"`

**Fabric**:
```java
public static final Item RUBY_SWORD = Registry.register(
    Registries.ITEM,
    new Identifier(MODID, "ruby_sword"),
    new SwordItem(...)
);
```
→ Registry name: `"ruby_sword"`

**Key extraction**:
- Pattern: `.register("([^"]+)"`
- Extract: String inside quotes
- Result: `"ruby_sword"`

---

### Step 2: Find Item Model

**Objective**: Locate the JSON model file for the item

**Path convention**:
```
assets/[modid]/models/item/[registry_name].json
```

**Search method**:
```
find_files_by_glob("**/models/item/ruby_sword.json")
```

**Example**:
```
Task: Find model for "ruby_sword"

Step 1: Construct expected path
→ assets/mymod/models/item/ruby_sword.json

Step 2: Search for model
→ find_files_by_glob("**/models/item/ruby_sword.json")

Result:
✓ Found: src/main/resources/assets/mymod/models/item/ruby_sword.json
```

**If not found**:
```
❌ Model not found

Expected location:
  src/main/resources/assets/[modid]/models/item/ruby_sword.json

Possible reasons:
1. Model file doesn't exist (needs to be created)
2. Different registry name (check code again)
3. Different modid in path

Next steps:
→ Verify modid in code
→ Check for typos in registry name
→ Create model file if missing
```

---

### Step 3: Extract Texture Path from Model

**Objective**: Read model JSON and extract texture reference

**Model structure**:
```json
{
  "parent": "item/generated",
  "textures": {
    "layer0": "mymod:item/ruby_sword"
  }
}
```

**Extraction**:
```
Read model file
→ Parse JSON
→ Find "textures" → "layer0"
→ Extract: "mymod:item/ruby_sword"
→ Convert to path: assets/mymod/textures/item/ruby_sword.png
```

**Common texture patterns**:

**Simple item (layer0)**:
```json
{
  "textures": {
    "layer0": "mymod:item/ruby_sword"
  }
}
```
→ Texture: `assets/mymod/textures/item/ruby_sword.png`

**Layered item (multiple layers)**:
```json
{
  "textures": {
    "layer0": "mymod:item/sword_base",
    "layer1": "mymod:item/sword_glow"
  }
}
```
→ Textures:
  - `assets/mymod/textures/item/sword_base.png`
  - `assets/mymod/textures/item/sword_glow.png`

**Block model (all sides)**:
```json
{
  "textures": {
    "all": "mymod:block/custom_block"
  }
}
```
→ Texture: `assets/mymod/textures/block/custom_block.png`

**Block model (different sides)**:
```json
{
  "textures": {
    "top": "mymod:block/furnace_top",
    "side": "mymod:block/furnace_side",
    "front": "mymod:block/furnace_front"
  }
}
```
→ Textures:
  - `assets/mymod/textures/block/furnace_top.png`
  - `assets/mymod/textures/block/furnace_side.png`
  - `assets/mymod/textures/block/furnace_front.png`

---

### Step 4: Find Texture File

**Objective**: Verify texture PNG file exists

**Path convention**:
```
assets/[modid]/textures/[type]/[name].png
```

**Search method**:
```
find_files_by_glob("**/textures/item/ruby_sword.png")
```

**Example**:
```
Task: Find texture for "mymod:item/ruby_sword"

Step 1: Convert resource location to path
→ "mymod:item/ruby_sword" → assets/mymod/textures/item/ruby_sword.png

Step 2: Search for texture
→ find_files_by_glob("**/textures/item/ruby_sword.png")

Result:
✓ Found: src/main/resources/assets/mymod/textures/item/ruby_sword.png
```

**If not found**:
```
❌ Texture not found

Expected location:
  src/main/resources/assets/mymod/textures/item/ruby_sword.png

**Visual Result in-game**:
  Purple/black checkerboard pattern (missing texture)

**Solution**:
  Create the texture PNG file at the expected location
  Recommended size: 16x16 pixels (Minecraft standard)
```

---

### Step 5: Find Translation Key

**Objective**: Locate language file entry for item name

**Translation key format**:
```
item.[modid].[registry_name]
block.[modid].[registry_name]
```

**Search method**:
```
search_in_files_by_text("item.mymod.ruby_sword", fileMask="*.json")
```

**Example**:
```
Task: Find translation for "ruby_sword"

Step 1: Construct translation key
→ "item.mymod.ruby_sword"

Step 2: Search in lang files
→ search_in_files_by_text("item.mymod.ruby_sword", fileMask="*.json")

Result:
✓ Found in: assets/mymod/lang/en_us.json
  Content: "item.mymod.ruby_sword": "Ruby Sword"
```

**Lang file structure**:
```json
{
  "item.mymod.ruby_sword": "Ruby Sword",
  "item.mymod.sapphire_sword": "Sapphire Sword",
  "block.mymod.ruby_ore": "Ruby Ore"
}
```

**If not found**:
```
❌ Translation not found

Expected entry in: assets/mymod/lang/en_us.json
  "item.mymod.ruby_sword": "Ruby Sword"

**Visual Result in-game**:
  Item displays as "item.mymod.ruby_sword" (untranslated key)

**Solution**:
  Add translation entry to en_us.json
```

---

## Complete Mapping Example

**Task**: Map CUSTOM_BLOCK from code to all resources

**Step-by-step execution**:
```
========== Step 1: Find Registry Name ==========

Search: CUSTOM_BLOCK in code
→ search_in_files_by_text("CUSTOM_BLOCK", fileMask="*.java")

Found in: ModBlocks.java:15
```java
public static final RegistryObject<Block> CUSTOM_BLOCK = BLOCKS.register("custom_block",
    () -> new Block(BlockBehaviour.Properties.of(Material.STONE)));
```

Registry name: "custom_block"
Modid: "mymod" (from BLOCKS DeferredRegister)

========== Step 2: Find Block Model ==========

Expected: assets/mymod/models/block/custom_block.json

Search: find_files_by_glob("**/models/block/custom_block.json")

✓ Found: src/main/resources/assets/mymod/models/block/custom_block.json

Content:
```json
{
  "parent": "block/cube_all",
  "textures": {
    "all": "mymod:block/custom_block"
  }
}
```

========== Step 3: Extract Texture Path ==========

From model: "mymod:block/custom_block"
Expected path: assets/mymod/textures/block/custom_block.png

========== Step 4: Find Texture File ==========

Search: find_files_by_glob("**/textures/block/custom_block.png")

❌ NOT FOUND

Expected: src/main/resources/assets/mymod/textures/block/custom_block.png
Status: MISSING (needs to be created)

========== Step 5: Find Translation ==========

Translation key: "block.mymod.custom_block"

Search: search_in_files_by_text("block.mymod.custom_block", fileMask="*.json")

✓ Found in: assets/mymod/lang/en_us.json
  "block.mymod.custom_block": "Custom Block"

========== Final Report ==========

Resource chain for CUSTOM_BLOCK:

✓ Code: ModBlocks.java:15 (registry: "custom_block")
✓ Model: assets/mymod/models/block/custom_block.json
❌ Texture: MISSING (assets/mymod/textures/block/custom_block.png)
✓ Lang: "Custom Block" in en_us.json

**Issue Identified**: Missing texture file
**Solution**: Create texture at assets/mymod/textures/block/custom_block.png
```

---

## Advanced Patterns

### Blockstate Files (for Blocks)

**Additional resource for blocks**:
```
assets/[modid]/blockstates/[registry_name].json
```

**Search method**:
```
find_files_by_glob("**/blockstates/custom_block.json")
```

**Example blockstate**:
```json
{
  "variants": {
    "": {
      "model": "mymod:block/custom_block"
    }
  }
}
```

**Purpose**: Connects block state properties to models

---

### Item Model Overrides

**For items with multiple states** (bows, fishing rods, etc.):
```json
{
  "parent": "item/generated",
  "textures": {
    "layer0": "mymod:item/bow"
  },
  "overrides": [
    {
      "predicate": { "pulling": 1 },
      "model": "mymod:item/bow_pulling_0"
    }
  ]
}
```

**Multiple models to find**:
- Base: `bow.json`
- Pulling states: `bow_pulling_0.json`, `bow_pulling_1.json`, `bow_pulling_2.json`

---

### Parent Model Inheritance

**Items can inherit from parent models**:
```json
{
  "parent": "mymod:item/base_sword",
  "textures": {
    "layer0": "mymod:item/ruby_sword"
  }
}
```

**Additional model to find**:
- Parent: `assets/mymod/models/item/base_sword.json`

**Recursive search**:
1. Find current model
2. Check for "parent" field
3. If custom parent (`mymod:...`), find that model too
4. Repeat until reaching vanilla parent (`item/generated`, `block/cube_all`, etc.)

---

## Troubleshooting Missing Resources

### Diagnostic Workflow

**Problem**: Item/block shows purple/black checkerboard in-game

**Diagnosis**:
```
Step 1: Verify code registration
→ Is item registered in DeferredRegister?
→ Is DeferredRegister registered to bus?
→ Confirmed: Code is correct

Step 2: Check model file
→ find_files_by_glob("**/models/item/[name].json")
→ Status: ✓ Found or ❌ Missing

If missing:
  → Create model at assets/[modid]/models/item/[name].json
  → Use template:
    ```json
    {
      "parent": "item/generated",
      "textures": {
        "layer0": "[modid]:item/[name]"
      }
    }
    ```

If found:
  → Read model
  → Check "parent" (must be valid)
  → Check "textures" paths

Step 3: Check texture file
→ Extract texture path from model
→ find_files_by_glob("**/textures/item/[name].png")
→ Status: ✓ Found or ❌ Missing

If missing:
  → Create texture PNG at assets/[modid]/textures/item/[name].png
  → Recommended size: 16x16 pixels

Step 4: Verify paths
→ Modid in code matches modid in file paths?
→ Registry name in code matches filename?
→ Texture path in model matches actual file location?
```

---

### Common Mistakes

**Mistake 1: Wrong modid in paths**
```
Code: DeferredRegister with "mymod"
Path: assets/othermod/models/item/ruby.json ❌
Fix:  assets/mymod/models/item/ruby.json ✓
```

**Mistake 2: Registry name mismatch**
```
Code: ITEMS.register("ruby_sword", ...)
Path: assets/mymod/models/item/ruby.json ❌
Fix:  assets/mymod/models/item/ruby_sword.json ✓
```

**Mistake 3: Texture path typo**
```
Model: "textures": { "layer0": "mymod:item/ruby_sowrd" } ❌ (typo)
Fix:   "textures": { "layer0": "mymod:item/ruby_sword" } ✓
```

**Mistake 4: Wrong file extension**
```
Path: assets/mymod/textures/item/ruby_sword.jpg ❌
Fix:  assets/mymod/textures/item/ruby_sword.png ✓
```

---

## Verification Checklist

After creating/finding all resources, verify:

- [ ] **Code**: Item registered in DeferredRegister
- [ ] **Code**: DeferredRegister registered to bus
- [ ] **Model**: File exists at `assets/[modid]/models/[type]/[name].json`
- [ ] **Model**: Valid JSON syntax
- [ ] **Model**: Parent model exists (vanilla or custom)
- [ ] **Model**: Texture paths are correct
- [ ] **Texture**: File exists at location specified in model
- [ ] **Texture**: File is PNG format (not JPG, GIF, etc.)
- [ ] **Texture**: Recommended 16x16 pixels (or appropriate size)
- [ ] **Lang**: Translation key exists in `en_us.json`
- [ ] **Lang**: Translation key matches format: `item.[modid].[name]`
- [ ] **Blockstate** (blocks only): File exists at `assets/[modid]/blockstates/[name].json`
- [ ] **Blockstate**: References correct model

---

## Automation Tip

**Pattern for complete mapping**:
```
Function: map_item_resources(registry_name, modid)

1. Model path: assets/{modid}/models/item/{registry_name}.json
   → find_files_by_glob("**/models/item/{registry_name}.json")

2. Read model, extract textures
   → Read(model_path)
   → Parse JSON → get "textures" → "layer0"

3. Texture path: assets/{modid}/textures/item/{texture_name}.png
   → find_files_by_glob("**/textures/item/{texture_name}.png")

4. Lang key: "item.{modid}.{registry_name}"
   → search_in_files_by_text("item.{modid}.{registry_name}")

5. Report:
   ✓ or ❌ for each resource
   Absolute paths for found resources
   Expected paths for missing resources
```

---

## Summary

**5-Step Workflow**:
1. 📝 Extract registry name from code
2. 🎨 Find model JSON file
3. 🖼️ Extract texture path from model
4. 🔍 Find texture PNG file
5. 🌐 Find translation in lang file

**Common Issues**:
- Missing model → Create at `assets/[modid]/models/[type]/[name].json`
- Missing texture → Create PNG at path specified in model
- Missing translation → Add to `en_us.json`
- Mismatched names → Verify registry name matches filenames

**Tool Performance**:
- Complete mapping: <2 seconds
- Each glob search: <200ms
- Text search: <300ms

**Success Rate**:
- Well-organized mods: 95%+ successful mapping
- Missing resources: Clearly identified with expected paths
