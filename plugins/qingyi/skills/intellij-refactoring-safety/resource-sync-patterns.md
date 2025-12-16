# Resource Sync Patterns - Synchronizing Code and Resource Files

When renaming registry objects (items, blocks, entities) in Minecraft mods, code and resource files must be synchronized to prevent broken references and missing assets.

## Overview

### The Resource Chain

A single registry object connects to multiple resource files:

```
Code Variable: COPPER_SWORD
    ↓
Registry Name: "copper_sword"
    ↓
Resource Files:
├─ Model: assets/modid/models/item/copper_sword.json
├─ Texture: assets/modid/textures/item/copper_sword.png
├─ Lang: assets/modid/lang/en_us.json ("item.modid.copper_sword")
└─ Data Files:
   ├─ Recipes: data/modid/recipes/copper_sword.json
   ├─ Loot Tables: data/modid/loot_tables/blocks/copper_block.json
   └─ Tags: data/minecraft/tags/items/swords.json
```

**All must be updated together** when renaming!

---

## Complete Synchronization Workflow

### Step 1: Rename Code Variable

**Use `rename_refactoring` for scope-aware renaming**:

```java
// Before
public static final RegistryObject<Item> COPPER_SWORD =
    ITEMS.register("copper_sword", () -> new SwordItem(...));

// Execute rename_refactoring
rename_refactoring("ModItems.java", "COPPER_SWORD", "BRONZE_SWORD")

// After (automatic)
public static final RegistryObject<Item> BRONZE_SWORD =
    ITEMS.register("copper_sword", () -> new SwordItem(...));
    // Note: Registry string NOT changed by rename_refactoring
```

### Step 2: Update Registry String

**Manual update** (rename_refactoring doesn't change string literals):

```java
// Find the registration line
public static final RegistryObject<Item> BRONZE_SWORD =
    ITEMS.register("copper_sword", () -> ...);

// Update registry string
// Use replace_text_in_file or Edit tool
replace_text_in_file(
    "src/main/java/com/mod/items/ModItems.java",
    '"copper_sword"',
    '"bronze_sword"',
    replaceAll=false,  // Only first occurrence in this context
    caseSensitive=true
)

// After
public static final RegistryObject<Item> BRONZE_SWORD =
    ITEMS.register("bronze_sword", () -> ...);
```

### Step 3: Update Model File

#### 3.1 Locate Model File

```
Expected location: assets/modid/models/item/copper_sword.json
```

**Read current model**:
```json
{
  "parent": "minecraft:item/handheld",
  "textures": {
    "layer0": "modid:item/copper_sword"
  }
}
```

#### 3.2 Update Texture Reference

**Two changes needed**:
1. Filename: `copper_sword.json` → `bronze_sword.json`
2. Texture path inside: `"modid:item/copper_sword"` → `"modid:item/bronze_sword"`

```json
{
  "parent": "minecraft:item/handheld",
  "textures": {
    "layer0": "modid:item/bronze_sword"  // ← Updated
  }
}
```

#### 3.3 Rename File

**Workflow**:
```
1. Read: assets/modid/models/item/copper_sword.json
2. Update content (texture path)
3. Write: assets/modid/models/item/bronze_sword.json
4. (Optional) Delete old file
```

**Code pattern**:
```
content = Read("assets/modid/models/item/copper_sword.json")
updated = replace_in_content(content, "copper_sword", "bronze_sword")
Write("assets/modid/models/item/bronze_sword.json", updated)
```

### Step 4: Update Texture File

#### 4.1 Locate Texture

```
Expected location: assets/modid/textures/item/copper_sword.png
```

#### 4.2 Rename Texture File

**Simple rename** (PNG file, no content changes needed):
```
1. Read: assets/modid/textures/item/copper_sword.png
2. Write: assets/modid/textures/item/bronze_sword.png
3. (Optional) Delete old file
```

**Important**: Texture files are binary (PNG), just copy to new location.

### Step 5: Update Lang File

#### 5.1 Locate Lang File

```
Expected location: assets/modid/lang/en_us.json
```

**Read current content**:
```json
{
  "item.modid.copper_sword": "Copper Sword",
  "item.modid.copper_sword.desc": "A sword made of copper"
}
```

#### 5.2 Update Translation Keys

**Two changes needed**:
1. Key: `item.modid.copper_sword` → `item.modid.bronze_sword`
2. Value (optional): `"Copper Sword"` → `"Bronze Sword"`

**After**:
```json
{
  "item.modid.bronze_sword": "Bronze Sword",
  "item.modid.bronze_sword.desc": "A sword made of bronze"
}
```

**Code pattern**:
```
content = Read("assets/modid/lang/en_us.json")
updated = replace_in_content(content, "copper_sword", "bronze_sword")
updated = replace_in_content(updated, "Copper", "Bronze")
Write("assets/modid/lang/en_us.json", updated)
```

**Important**: Update ALL lang files (en_us.json, de_de.json, etc.)!

### Step 6: Update Recipes

#### 6.1 Find Recipe Files

**Search for references**:
```
search_in_files_by_text('"modid:copper_sword"')

Results:
- data/modid/recipes/copper_sword.json
- data/modid/recipes/copper_tools.json
```

#### 6.2 Update Recipe Result

**Before** (`copper_sword.json`):
```json
{
  "type": "minecraft:crafting_shaped",
  "pattern": [
    "C",
    "C",
    "S"
  ],
  "key": {
    "C": {"item": "modid:copper_ingot"},
    "S": {"item": "minecraft:stick"}
  },
  "result": {
    "item": "modid:copper_sword"  // ← Update this
  }
}
```

**After**:
```json
{
  "result": {
    "item": "modid:bronze_sword"  // ← Updated
  }
}
```

#### 6.3 Rename Recipe File

```
1. Read: data/modid/recipes/copper_sword.json
2. Update content (result item)
3. Write: data/modid/recipes/bronze_sword.json
```

**Note**: Recipe filenames can be anything, but convention is to match item name.

#### 6.4 Update Recipes That Use Item as Ingredient

**Example** (`copper_tools.json`):
```json
{
  "type": "minecraft:crafting_shapeless",
  "ingredients": [
    {"item": "modid:copper_sword"}  // ← Update if used as ingredient
  ],
  "result": {"item": "modid:recycled_copper"}
}
```

**After**:
```json
{
  "ingredients": [
    {"item": "modid:bronze_sword"}  // ← Updated
  ]
}
```

### Step 7: Update Loot Tables

#### 7.1 Find Loot Table References

**For blocks that drop the item**:
```
Expected location: data/modid/loot_tables/blocks/copper_block.json
```

**Before**:
```json
{
  "type": "minecraft:block",
  "pools": [{
    "rolls": 1,
    "entries": [{
      "type": "minecraft:item",
      "name": "modid:copper_block"  // If block, update
    }]
  }]
}
```

**For entities that drop the item**:
```
data/modid/loot_tables/entities/copper_golem.json
```

```json
{
  "pools": [{
    "entries": [{
      "type": "minecraft:item",
      "name": "modid:copper_sword"  // ← Update if entity drops it
    }]
  }]
}
```

#### 7.2 Update References

```
search_in_files_by_text('"modid:copper_sword"', directoryToSearch="data/modid/loot_tables")

For each result:
  replace "modid:copper_sword" with "modid:bronze_sword"
```

### Step 8: Update Tags

#### 8.1 Find Tag References

**Item tags**:
```
data/minecraft/tags/items/swords.json
data/modid/tags/items/copper_items.json
```

**Before**:
```json
{
  "replace": false,
  "values": [
    "modid:copper_sword",  // ← Update
    "modid:copper_pickaxe"
  ]
}
```

**After**:
```json
{
  "values": [
    "modid:bronze_sword",  // ← Updated
    "modid:copper_pickaxe"
  ]
}
```

#### 8.2 Update All Tag Files

```
search_in_files_by_text('"modid:copper_sword"', directoryToSearch="data")
fileMask="*.json"

For each tag file:
  replace "modid:copper_sword" with "modid:bronze_sword"
```

---

## Nested Model Patterns

### Parent References

Some models reference parent models:

**Block model** (references item model):
```json
{
  "parent": "modid:block/copper_sword_block"  // ← Update parent path
}
```

**When renaming**:
1. Update parent path
2. Update nested texture references
3. Ensure parent model also renamed

**Example**:
```
Models to update:
- assets/modid/models/item/copper_sword.json
- assets/modid/models/block/copper_sword_block.json
- assets/modid/models/block/copper_sword_base.json (if parent)

All must be renamed and cross-references updated!
```

### Multi-Layer Textures

**Complex model** (multiple textures):
```json
{
  "parent": "minecraft:item/handheld",
  "textures": {
    "layer0": "modid:item/copper_sword_base",
    "layer1": "modid:item/copper_sword_glow",
    "layer2": "modid:item/copper_sword_overlay"
  }
}
```

**When renaming**:
```
Update model:
- "layer0": "modid:item/bronze_sword_base"
- "layer1": "modid:item/bronze_sword_glow"
- "layer2": "modid:item/bronze_sword_overlay"

Rename textures:
- copper_sword_base.png → bronze_sword_base.png
- copper_sword_glow.png → bronze_sword_glow.png
- copper_sword_overlay.png → bronze_sword_overlay.png
```

---

## Automation Strategies

### Pattern 1: Batch Search and Replace

**For simple renames** (no complex logic):

```
1. List all files to update:
   - Code: search_in_files_by_text("COPPER_SWORD")
   - Resources: find_files_by_glob("**/*copper_sword*")

2. For each file:
   - Read content
   - Replace "copper_sword" → "bronze_sword"
   - Replace "Copper" → "Bronze" (for display text)
   - Write back

3. Rename files:
   - Find all files matching "*copper_sword*"
   - Copy to new name with "bronze_sword"
```

**Caution**: Can accidentally rename unrelated things. Better to do manually for complex cases.

### Pattern 2: Manual Checklist

**For important renames** (critical items, released mods):

```
Checklist:
[ ] Code variable renamed (rename_refactoring)
[ ] Registry string updated
[ ] Model file renamed and updated
[ ] Texture file(s) renamed
[ ] Lang file(s) updated (all languages!)
[ ] Recipe result updated
[ ] Recipe ingredients updated (if used)
[ ] Loot table drops updated
[ ] Item tags updated
[ ] Block tags updated (if block)
[ ] Advancements referencing item updated
[ ] Creative tab icon updated (if used)
[ ] JEI integration updated (if applicable)
```

---

## Special Cases

### Case 1: Block with Block Item

**Block** + **BlockItem** (two registry entries):

```java
// Both need renaming
public static final RegistryObject<Block> COPPER_BLOCK =
    BLOCKS.register("copper_block", () => new Block(...));

public static final RegistryObject<Item> COPPER_BLOCK_ITEM =
    ITEMS.register("copper_block", () => new BlockItem(COPPER_BLOCK.get(), ...));
```

**Resources needed**:
```
Models:
- assets/modid/models/block/copper_block.json (block model)
- assets/modid/models/item/copper_block.json (item model, references block model)

Textures:
- assets/modid/textures/block/copper_block.png

Blockstates:
- assets/modid/blockstates/copper_block.json

Loot tables:
- data/modid/loot_tables/blocks/copper_block.json

Lang:
- "block.modid.copper_block": "Copper Block"
```

**All must be updated**!

### Case 2: Entity with Spawn Egg

**Entity** + **Spawn Egg** (two registry entries):

```java
public static final RegistryObject<EntityType<CopperGolem>> COPPER_GOLEM =
    ENTITIES.register("copper_golem", () => ...);

public static final RegistryObject<Item> COPPER_GOLEM_SPAWN_EGG =
    ITEMS.register("copper_golem_spawn_egg", () => ...);
```

**Resources needed**:
```
Models:
- assets/modid/models/item/copper_golem_spawn_egg.json

Textures:
- assets/modid/textures/entity/copper_golem.png
- assets/modid/textures/item/copper_golem_spawn_egg.png

Lang:
- "entity.modid.copper_golem": "Copper Golem"
- "item.modid.copper_golem_spawn_egg": "Copper Golem Spawn Egg"

Loot tables:
- data/modid/loot_tables/entities/copper_golem.json
```

### Case 3: Multi-Language Support

**When mod supports multiple languages**:

```
Lang files to update:
- assets/modid/lang/en_us.json (English)
- assets/modid/lang/de_de.json (German)
- assets/modid/lang/es_es.json (Spanish)
- assets/modid/lang/fr_fr.json (French)
- ... (all supported languages)
```

**Each file needs**:
```json
{
  "item.modid.bronze_sword": "Bronze Sword",  // Translate to each language
  "item.modid.bronze_sword.desc": "..."
}
```

**Workflow**:
1. Find all lang files: `find_files_by_glob("assets/modid/lang/*.json")`
2. For each file:
   - Update key: `copper_sword` → `bronze_sword`
   - Update translation (manually translate "Bronze" to each language)

---

## Validation Checklist

After completing resource synchronization:

### File Existence Checks

```
[ ] Model file exists: assets/modid/models/item/bronze_sword.json
[ ] Texture file exists: assets/modid/textures/item/bronze_sword.png
[ ] Lang entry exists: "item.modid.bronze_sword" in en_us.json
[ ] Recipe file exists (if applicable)
[ ] Loot table references updated (if applicable)
```

### Content Validation

```
[ ] Model texture path matches texture filename
[ ] Lang key matches registry name format
[ ] Recipe result/ingredient updated
[ ] No references to old name in code (search for "copper_sword")
[ ] No old resource files left (copper_sword.json, copper_sword.png)
```

### In-Game Testing

```
[ ] Item appears in creative tab (if applicable)
[ ] Item has correct name (translation works)
[ ] Item has correct texture (model loaded)
[ ] Recipe works (if applicable)
[ ] /give command works: /give @p modid:bronze_sword
```

---

## Troubleshooting

### Problem: Item Has Missing Texture

**Symptom**: Purple/black checkered texture in-game

**Causes**:
1. Model file not renamed
2. Model texture path incorrect
3. Texture file not renamed

**Solution**:
```
1. Check model file: assets/modid/models/item/bronze_sword.json exists
2. Check texture path in model: "layer0": "modid:item/bronze_sword"
3. Check texture file: assets/modid/textures/item/bronze_sword.png exists
```

### Problem: Item Has Wrong Name

**Symptom**: Item shows as "item.modid.bronze_sword" (translation key literal)

**Causes**:
1. Lang file not updated
2. Lang key format incorrect
3. Wrong lang file (e.g., updated en_us but game set to de_de)

**Solution**:
```
1. Check lang file exists: assets/modid/lang/en_us.json
2. Check key format: "item.modid.bronze_sword" (not "bronze_sword")
3. Check all lang files updated
```

### Problem: Recipe Doesn't Work

**Symptom**: Recipe shows in JEI but doesn't craft

**Causes**:
1. Recipe result item incorrect
2. Recipe file not found (wrong location)
3. Recipe filename conflicts

**Solution**:
```
1. Check recipe result: "item": "modid:bronze_sword" (exact registry name)
2. Check recipe location: data/modid/recipes/ (not assets/)
3. Check recipe filename unique
```

---

## Summary

**Complete workflow** for renaming registry objects:

1. **Code**: rename_refactoring (variable name)
2. **Registry**: Update string literal
3. **Model**: Rename file, update texture paths
4. **Texture**: Rename file(s)
5. **Lang**: Update keys and translations (all languages)
6. **Recipes**: Update result and ingredients
7. **Loot Tables**: Update drops
8. **Tags**: Update references
9. **Validate**: File existence, content, in-game testing

**Key principles**:
- Update ALL resource files (don't miss any)
- Maintain consistency (same name everywhere)
- Validate thoroughly (file existence, content, in-game)
- Test before release

For information about world compatibility when renaming, see [Registry Name Changes](./registry-name-changes.md).

For guidance on what changes break worlds, see [Breaking Changes Guide](./breaking-changes-guide.md).
