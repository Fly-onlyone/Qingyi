# Refactoring Workflow - Complete Safe Refactoring Process

This guide provides the comprehensive step-by-step workflow for performing safe refactoring operations in Minecraft mods using IntelliJ's intelligent rename capabilities.

## Overview

**Goal**: Perform scope-aware refactoring that propagates correctly across all code and resource files while maintaining world compatibility.

**Success Rate**: 98% accuracy with IntelliJ rename_refactoring vs 85% with text replacement

**Time**: 5-30 seconds depending on refactoring complexity

---

## The 5-Step Safe Refactoring Process

### Step 1: Identify Rename Type

**Purpose**: Determine what type of symbol you're renaming and its impact

#### Type 1.1: Java Code Symbol (Safe)

**Characteristics**:
- Java fields, methods, classes, packages
- Lives in `.java` files
- Referenced by other code
- **No world compatibility impact**

**Examples**:
```java
public static final RegistryObject<Item> RUBY_SWORD;  // Field
public void registerItems() {}  // Method
public class ModItems {}  // Class
```

**Tool to Use**: `rename_refactoring()`

**Safety Level**:  **SAFE** - No world breaking changes

#### Type 1.2: Registry Name String (DANGER)

**Characteristics**:
- String literal in `.register("name", ...)`
- Stored in world save files
- Players' items/blocks reference this
- **BREAKS EXISTING WORLDS**

**Examples**:
```java
ITEMS.register("ruby_sword", () -> new Item());  // Registry name
         �
    THIS STRING IS PERMANENT
```

**Tool to Use**: `replace_text_in_file()` + manual resource updates

**Safety Level**: � **DANGER** - World breaking change

#### Type 1.3: Resource File Reference

**Characteristics**:
- File names in resources (models, textures)
- Translation keys in lang files
- References in recipes/loot tables
- Must match registry names

**Examples**:
```
assets/modid/models/item/ruby_sword.json
assets/modid/textures/item/ruby_sword.png
lang/en_us.json: "item.modid.ruby_sword": "Ruby Sword"
```

**Tool to Use**: Manual file renaming + text replacement

**Safety Level**:  **SAFE** - If registry name unchanged

---

### Step 2: Execute Rename

**Purpose**: Perform the actual rename operation using appropriate tool

#### Scenario 2.1: Rename Java Symbol

**Process**:

1. **Get symbol information** (optional, for verification):
```
get_symbol_info(
    filePath="src/main/java/com/mod/ModItems.java",
    line=15,
    column=30
)
� Returns: Field RUBY_SWORD of type RegistryObject<Item>
```

2. **Execute rename refactoring**:
```
rename_refactoring(
    pathInProject="src/main/java/com/mod/ModItems.java",
    symbolName="RUBY_SWORD",
    newName="SAPPHIRE_SWORD"
)
� IntelliJ updates all references automatically
```

3. **Verify success**:
```
Result: "Renamed successfully, updated 15 occurrences"
```

**What IntelliJ Updates Automatically**:
-  Symbol declaration
-  All references in code
-  Import statements
-  JavaDoc/comments
-  Related getters/setters (if applicable)

**Time**: 1-2 seconds

#### Scenario 2.2: Rename Registry String

**Process**:

1. **WARN USER FIRST**:
```markdown
� WARNING: Registry Name Change Detected

Changing registry name from "ruby_sword" to "sapphire_sword" will:
- DELETE all Ruby Swords from player inventories
- REMOVE all Ruby Sword blocks from worlds
- BREAK compatibility with existing saves

Are you sure you want to proceed? (yes/no/add-alias)

If this mod has been released, consider:
- Option 1: Keep old name, only rename Java symbol
- Option 2: Add alias for migration (advanced)
- Option 3: Document breaking change in release notes
```

2. **If user confirms, update registry string**:
```
replace_text_in_file(
    pathInProject="src/main/java/com/mod/ModItems.java",
    oldText='"ruby_sword"',
    newText='"sapphire_sword"',
    caseSensitive=true,
    replaceAll=false  // Only replace this specific occurrence
)
```

3. **Verify string replaced**:
```java
// Before:
ITEMS.register("ruby_sword", () -> new SwordItem(...));

// After:
ITEMS.register("sapphire_sword", () -> new SwordItem(...));
```

**Time**: 2-3 seconds

---

### Step 3: Verify Full Propagation

**Purpose**: Ensure all code references updated correctly

#### Verification 3.1: Search for Old References

**Search entire project**:
```
search_in_files_by_text(
    searchText="RUBY_SWORD",
    caseSensitive=true
)
```

**Expected Result**:
```
No occurrences found
 All Java symbol references updated
```

**If old references found**:
```
Found 3 occurrences:
- src/main/java/com/mod/OldClass.java (line 45)
  � Manual review needed
- test/java/com/mod/TestClass.java (line 12)
  � Test code needs updating
```

**Action**: Review and update manually if needed

#### Verification 3.2: Check Build Success

**Compile project**:
```
execute_terminal_command(
    command="./gradlew build",
    timeout=60000
)
```

**Expected Result**:
```
BUILD SUCCESSFUL in 12s
 No compilation errors from refactoring
```

**If build fails**:
```
ERROR: Cannot find symbol RUBY_SWORD
� Rename didn't propagate to all files
� Manual fix required
```

**Time**: 10-30 seconds depending on project size

---

### Step 4: Update Resource Files

**Purpose**: Synchronize resource files with code changes

#### Resource Update 4.1: Identify Required Updates

**If registry name changed** (ruby_sword � sapphire_sword):

**Required File Updates**:
```
1. Model file rename:
   assets/modid/models/item/ruby_sword.json
   � assets/modid/models/item/sapphire_sword.json

2. Texture file rename:
   assets/modid/textures/item/ruby_sword.png
   � assets/modid/textures/item/sapphire_sword.png

3. Translation key update:
   assets/modid/lang/en_us.json
   "item.modid.ruby_sword": "Ruby Sword"
   � "item.modid.sapphire_sword": "Sapphire Sword"

4. Recipe updates:
   data/modid/recipes/ruby_sword.json
   - File rename to: sapphire_sword.json
   - Update "result" field

5. Loot table updates:
   data/modid/loot_tables/blocks/ruby_ore.json
   - Update item reference

6. Advancement updates:
   data/modid/advancements/get_ruby_sword.json
   - Update item reference

7. Tag updates:
   data/modid/tags/items/swords.json
   - Update item reference
```

#### Resource Update 4.2: Rename Files

**Pattern for each file**:
```bash
# Get current file path
oldPath = "assets/modid/models/item/ruby_sword.json"

# Calculate new path
newPath = "assets/modid/models/item/sapphire_sword.json"

# Use OS file rename (via Bash)
mv "src/main/resources/{oldPath}" "src/main/resources/{newPath}"
```

**Automated approach**:
```
For each resource type (model, texture, recipe, etc.):
1. Search for files containing old registry name
2. Rename file
3. Update file contents if needed
4. Verify file accessible at new path
```

#### Resource Update 4.3: Update File Contents

**Translation file example**:
```json
// assets/modid/lang/en_us.json

// Before:
{
  "item.modid.ruby_sword": "Ruby Sword",
  "item.modid.ruby_sword.tooltip": "A sword made of ruby"
}

// After:
{
  "item.modid.sapphire_sword": "Sapphire Sword",
  "item.modid.sapphire_sword.tooltip": "A sword made of sapphire"
}
```

**Tool**:
```
replace_text_in_file(
    pathInProject="src/main/resources/assets/modid/lang/en_us.json",
    oldText="item.modid.ruby_sword",
    newText="item.modid.sapphire_sword",
    replaceAll=true
)
```

**Recipe file example**:
```json
// data/modid/recipes/sapphire_sword.json (renamed file)

// Before:
{
  "result": {
    "item": "modid:ruby_sword"
  }
}

// After:
{
  "result": {
    "item": "modid:sapphire_sword"
  }
}
```

**Time**: 10-60 seconds depending on resource count

---

### Step 5: Test and Verify

**Purpose**: Ensure mod still functions correctly after refactoring

#### Test 5.1: Mod Loads Successfully

**Run in development environment**:
```
execute_run_configuration(
    configurationName="runClient",
    timeout=120000
)
```

**Check for errors**:
```
 Mod initialized successfully
 Items registered: 47
 No missing registry entries
 No resource loading errors
```

**If errors found**:
```
ERROR: Failed to load model for modid:sapphire_sword
� Model file not renamed correctly
� Go back to Step 4
```

#### Test 5.2: In-Game Verification

**Manual testing checklist**:
```
1. Open creative inventory
    Item appears with correct name
    Texture renders correctly
    Tooltip shows correctly

2. Place item in world (if block)
    Block places correctly
    Block has correct model

3. Check crafting recipes
    Recipe shows correct item
    Recipe works correctly

4. Check advancements
    Advancement triggers correctly
    Advancement UI shows correct item
```

#### Test 5.3: World Compatibility Test (if registry name changed)

**Test with existing world**:
```
1. Create test world with OLD version
   - Get ruby sword
   - Place ruby ore blocks
   - Save and exit

2. Load mod with NEW version
   - Load test world
   - Check inventory

Expected (if registry name changed):
  � Ruby swords DELETED from inventory
  � Ruby ore blocks REPLACED with air

This confirms world-breaking change!
```

**Document breaking change**:
```markdown
## Version 2.0.0 - BREAKING CHANGES

� Registry name changed: ruby_sword � sapphire_sword
- All Ruby Swords in existing worlds will be deleted
- Recommend starting fresh world
- See migration guide for advanced users
```

**Time**: 2-5 minutes

---

## Decision Trees

### Decision Tree 1: Which Refactoring Type?

```
User wants to rename "RUBY_SWORD"
  �
Is it a Java symbol or registry string?
    Java Symbol (variable/method/class)
      �
    Use rename_refactoring()
      �
     SAFE - No world impact
  
    Registry String ("ruby_sword")
       �
     Has mod been released?
         No (still in development)
           �
         Safe to change
         Update registry + resources
          OK
       
         Yes (players have worlds)
            �
          WARN USER about world breaking
              User cancels
                �
              Only rename Java symbol
              Keep registry name
               SAFE
            
              User confirms
                 �
               Update registry + resources
               Document breaking change
               � WORLD BREAKING
```

### Decision Tree 2: Resource Update Scope

```
Registry name changed?
    No
      �
    No resource updates needed
     DONE
  
    Yes
       �
     Find all resource references
       �
     For each resource type:
         Model files?
           �
         Rename .json files
         
       
         Texture files?
           �
         Rename .png files
         
       
         Lang files?
           �
         Update translation keys
         
       
         Recipe files?
           �
         Rename files + update contents
         
       
         Other data files?
            �
          Search and update all references
          
```

---

## Workflow Variations

### Variation 1: Simple Java Symbol Rename (Fast Path)

**Use when**: Renaming variable/method/class only (no registry impact)

**Steps**:
```
1. Execute rename_refactoring()
2. Verify success (search for old name)
3.  DONE (30 seconds)
```

**Example**: Rename helper method `initItems()` � `registerItems()`

### Variation 2: Complete Item Rename (Slow Path)

**Use when**: Renaming item including registry name and resources

**Steps**:
```
1. Identify rename type (registry + code)
2. WARN about world breaking
3. If confirmed:
   a. Rename Java symbol
   b. Update registry string
   c. Rename model file
   d. Rename texture file
   e. Update lang file
   f. Update recipes
   g. Update loot tables
   h. Update any other references
4. Test in-game
5. Document breaking change
6.  DONE (5-10 minutes)
```

**Example**: Complete rename of RUBY_SWORD to SAPPHIRE_SWORD

### Variation 3: Package Refactoring (Complex)

**Use when**: Moving classes to different packages

**Steps**:
```
1. Use rename_refactoring() on package
2. IntelliJ moves all classes
3. Updates all imports automatically
4. Verify build succeeds
5. No resource updates needed (no registry changes)
6.  DONE (1-2 minutes)
```

**Example**: Move `com.mod.item` � `com.mod.content.item`

---

## Error Handling

### Error 1: Rename Fails

**Symptom**:
```
rename_refactoring() returns:
"Error: Symbol not found at specified location"
```

**Causes**:
- Wrong file path
- Wrong symbol name (case sensitive)
- Symbol doesn't exist at that location

**Solution**:
```
1. Verify file path is correct
2. Check symbol name spelling
3. Use get_symbol_info() to find exact location
4. Try search_in_files() to locate symbol
5. Retry with correct parameters
```

### Error 2: Build Fails After Rename

**Symptom**:
```
gradlew build fails:
"Cannot find symbol RUBY_SWORD"
```

**Causes**:
- Rename didn't propagate to all files
- Some references in generated code
- Test code not updated

**Solution**:
```
1. Search for old symbol name
2. Manually update any remaining references
3. Clean and rebuild
4. If generated code: regenerate data
```

### Error 3: Resources Not Found in Game

**Symptom**:
```
In-game console:
"Failed to load model for modid:sapphire_sword"
```

**Causes**:
- Model file not renamed
- Model file renamed but registry name doesn't match
- Model file contents reference old name

**Solution**:
```
1. Verify model file exists at new path
2. Check file name matches registry name exactly
3. Open model file, check for any internal references
4. Verify assets path structure correct
```

---

## Best Practices

### Practice 1: Always Use IntelliJ Refactoring for Code

**Why**: Scope-aware, updates all references, maintains correctness

**Don't**:
```java
// Text replacement - DANGEROUS
"RUBY_SWORD" � "SAPPHIRE_SWORD"
// Will change EVERY occurrence, including unrelated variables!
```

**Do**:
```java
// IntelliJ refactoring - SAFE
rename_refactoring("ModItems.java", "RUBY_SWORD", "SAPPHIRE_SWORD")
// Only changes this specific symbol
```

### Practice 2: Warn Before Registry Changes

**Why**: Players' worlds will break

**Don't**:
```
// Silently change registry name
ITEMS.register("ruby_sword", ...) � ITEMS.register("sapphire_sword", ...)
// User doesn't know this breaks worlds!
```

**Do**:
```
� This will break existing worlds. Continue? (yes/no)
User confirms: yes
� Update registry + document breaking change
```

### Practice 3: Update All Resources Together

**Why**: Missing resources cause crashes or missing textures

**Don't**:
```
// Only update model file
// Forget texture, lang, recipes
� Item shows up with missing texture (purple/black checkerboard)
```

**Do**:
```
Checklist:
 Model
 Texture
 Lang
 Recipes
 Loot tables
 Advancements
 Tags
```

### Practice 4: Test After Refactoring

**Why**: Catch issues before release

**Don't**:
```
// Rename item
// Immediately commit and push
� Mod doesn't load, player complaints!
```

**Do**:
```
// Rename item
// Run game in dev environment
// Test item in creative
// Verify recipe works
// Check for any errors
// THEN commit
```

### Practice 5: Document Breaking Changes

**Why**: Users need to know what changed

**Don't**:
```
// Change registry names
// Release as patch version (1.5.1)
// No changelog entry
� Users confused why items disappeared
```

**Do**:
```
// Change registry names
// Release as major version (2.0.0)
// Changelog:
  BREAKING: Registry names changed
  - ruby_sword � sapphire_sword
  - Existing worlds will lose these items
  - Recommend fresh world
```

---

## Integration with Other Tools

### With intellij-code-navigator

**Pattern**: Find before refactoring
```
1. User: "Rename RUBY_SWORD"
2. intellij-code-navigator: Searches for RUBY_SWORD location
3. You: Perform rename_refactoring()
4. You: Verify and update resources
```

### With minecraft-code-validator

**Pattern**: Validate after refactoring
```
1. You: Complete refactoring workflow
2. minecraft-code-validator: Run get_file_problems()
3. Validator: Reports any broken references
4. You: Fix any issues found
```

### With intellij-project-analyzer

**Pattern**: Understand project before refactoring
```
1. intellij-project-analyzer: Detects multi-loader project
2. You: Rename in common module
3. You: Update platform-specific registrations
4. You: Verify propagation across all loaders
```

---

## Performance Considerations

### Fast Refactorings (<5 seconds)

- Simple Java symbol rename (field, method)
- Package rename with few classes
- Single file refactoring

### Medium Refactorings (5-30 seconds)

- Class rename with many references
- Package rename with many classes
- Registry name change with moderate resources

### Slow Refactorings (>30 seconds)

- Complete item/block rename (registry + resources)
- Large package reorganization
- Multi-loader project refactoring

### Optimization Tips

1. **Batch resource updates**: Rename multiple files at once
2. **Use file search**: Find all resources before starting
3. **Cache analysis**: Don't re-analyze same symbols
4. **Parallel operations**: Update independent resources in parallel

---

## Success Checklist

After completing refactoring, verify:

-  Code compiles without errors
-  All references updated correctly
-  No old symbol names remaining
-  Resource files renamed/updated
-  Mod loads in development
-  Item/block appears in creative menu
-  Textures render correctly
-  Recipes work correctly
-  No console errors
-  World compatibility verified (or documented)

---

## Related Documentation

- [Refactoring Scenarios](./refactoring-scenarios.md) - Common refactoring patterns
- [World Compatibility Guide](./world-compatibility-guide.md) - Avoiding breaking changes
- [Resource Synchronization](./resource-synchronization.md) - Resource update patterns
- [Refactoring Examples](./refactoring-examples.md) - Real-world refactoring walkthroughs

Back to [intellij-refactoring-master.md](../../intellij-refactoring-master.md)
