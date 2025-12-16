# Navigation Examples - Real-World Scenarios

Practical examples of using IntelliJ Code Navigator tools to solve common Minecraft mod navigation tasks.

## Example 1: Find Item Registration

**Scenario**: User asks "Where is DIAMOND_STAFF registered?"

**Solution**:
```
Step 1: Search for the item name
→ search_in_files_by_text("DIAMOND_STAFF", fileMask="*.java")
→ Result: ModItems.java:32

Step 2: Read the file
→ Read ModItems.java
→ Found:
  public static final RegistryObject<Item> DIAMOND_STAFF =
      ITEMS.register("diamond_staff", () -> new Item(new Item.Properties()));

Step 3: Report
→ Registry name: "diamond_staff"
→ Location: ModItems.java:32
→ Type: Item
```

**Time**: ~2 seconds

## Example 2: Find All Event Handlers

**Scenario**: "Show me all event handlers in this mod"

**Solution**:
```
Step 1: Find event handler files
→ find_files_by_glob("**/events/**/*.java")
→ Result: ForgeEvents.java, ClientEvents.java

Step 2: Search for @SubscribeEvent
→ search_in_files_by_text("@SubscribeEvent", fileMask="*.java")
→ Result: 8 handlers across 3 files

Step 3: Categorize by event type
→ Read each file
→ Extract: 3 tick handlers, 2 player events, 3 world events
```

**Time**: ~5 seconds

## Example 3: Debug Missing Texture

**Scenario**: "CUSTOM_BLOCK has no texture in game"

**Solution**:
```
Step 1: Find block registration
→ search_in_files_by_text("CUSTOM_BLOCK", fileMask="*.java")
→ Result: Registry name "custom_block"

Step 2: Check block model
→ find_files_by_glob("**/models/block/custom_block.json")
→ Result: ✓ Found

Step 3: Read model to find texture reference
→ Read model JSON
→ Extract: "textures": { "all": "modid:block/custom_block" }

Step 4: Check texture file
→ find_files_by_glob("**/textures/block/custom_block.png")
→ Result: ❌ NOT FOUND

Step 5: Report diagnosis
→ ROOT CAUSE: Texture file missing
→ FIX: Create textures/block/custom_block.png
```

**Time**: ~3 seconds

## Example 4: Find Multi-Loader Registry Pattern

**Scenario**: "How does this multi-loader project register items?"

**Solution**:
```
Step 1: Detect project structure
→ list_directory_tree(".", maxDepth=2)
→ Result: common/, forge/, fabric/ modules detected

Step 2: Find common item class
→ find_files_by_glob("**/common/**/items/**/*.java")
→ Result: common/items/RubyItem.java

Step 3: Find Forge registration
→ find_files_by_glob("**/forge/**/init/**/*.java")
→ Result: forge/init/ModItemsForge.java uses DeferredRegister

Step 4: Find Fabric registration
→ find_files_by_glob("**/fabric/**/init/**/*.java")
→ Result: fabric/init/ModItemsFabric.java uses Registry.register

Step 5: Report pattern
→ Pattern: Item classes in common/, registration in platform modules
```

**Time**: ~4 seconds

## Example 5: Locate Client-Only Code

**Scenario**: "Find all client-only rendering code"

**Solution**:
```
Step 1: Search for client annotation
→ search_in_files_by_text("@OnlyIn(Dist.CLIENT)", fileMask="*.java")
→ Result: 12 classes

Step 2: Find rendering classes
→ search_in_files_by_regex("class\\s+\\w+\\s+extends\\s+.*Renderer", fileMask="*.java")
→ Result: CustomEntityRenderer.java, CustomBlockRenderer.java

Step 3: Categorize
→ Entity renderers: 2
→ Screen classes: 5
→ Overlay renderers: 3
→ Client event handlers: 2
```

**Time**: ~6 seconds

## Example 6: Trace Event Handler Chain

**Scenario**: "Why is my PlayerTickEvent handler not firing?"

**Solution**:
```
Step 1: Find handler
→ search_in_files_by_text("onPlayerTick", fileMask="*.java")
→ Result: ForgeEvents.java:42

Step 2: Check registration
→ Read ForgeEvents.java
→ Verify: @Mod.EventBusSubscriber annotation present
→ Check: bus = Bus.FORGE (correct)
→ Check: Method is static (correct)

Step 3: Check event phase
→ Code: if (event.phase == TickEvent.Phase.END)
→ Issue: Missing @SubscribeEvent annotation!

Step 4: Report diagnosis
→ ROOT CAUSE: @SubscribeEvent annotation missing
→ FIX: Add @SubscribeEvent above method
```

**Time**: ~2 seconds

## Example 7: Find Recipe for Item

**Scenario**: "How is RUBY_SWORD crafted?"

**Solution**:
```
Step 1: Find registry name
→ search_in_files_by_text("RUBY_SWORD", fileMask="*.java")
→ Result: Registry name "ruby_sword"

Step 2: Search recipes
→ search_in_files_by_text("ruby_sword", directoryToSearch="data", fileMask="*.json")
→ Result: data/modid/recipes/ruby_sword.json

Step 3: Read recipe
→ Read recipe JSON
→ Extract: Shaped recipe, requires 2 rubies + 1 stick
```

**Time**: ~2 seconds

## Example 8: Map Block to Blockstate

**Scenario**: "Find blockstate definition for CUSTOM_MACHINE"

**Solution**:
```
Step 1: Find registration
→ search_in_files_by_text("CUSTOM_MACHINE", fileMask="*.java")
→ Result: Registry name "custom_machine"

Step 2: Find blockstate file
→ find_files_by_glob("**/blockstates/custom_machine.json")
→ Result: ✓ Found

Step 3: Read blockstate
→ Read JSON
→ Extract: Variants with "facing" property

Step 4: Find models referenced
→ Extract model paths from JSON
→ Check each model exists
```

**Time**: ~3 seconds

These examples demonstrate efficient navigation using the right tool for each task.
