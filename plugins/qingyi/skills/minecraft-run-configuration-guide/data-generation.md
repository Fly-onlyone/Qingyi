# Data Generation - runData Configuration for Automated Asset Creation

Detailed guide for using runData configuration to generate recipes, loot tables, models, tags, and language files from code.

## What is Data Generation?

**Data generation** (datagen) uses **DataProvider** classes to programmatically create JSON files instead of writing them manually.

**Benefits**:
- ✅ Type safety (compile-time errors instead of runtime crashes)
- ✅ Consistency (guaranteed correct format)
- ✅ Automation (generate 100+ files in seconds)
- ✅ Refactoring safety (rename items → recipes update automatically)
- ✅ Code reuse (patterns for similar items)

**Output location**: `src/generated/resources/`

**Typical workflow**:
1. Write DataProvider class (Java code)
2. Run `runData` configuration
3. Review generated JSON files
4. Copy to `src/main/resources/` (or use as-is)

---

## DataProvider Architecture

### Core Concept

**DataProvider** = Java class that implements data generation logic

**Forge/NeoForge hierarchy**:
```
DataProvider (interface)
├── RecipeProvider (recipes)
├── LootTableProvider (loot tables)
├── BlockStateProvider (blockstates, models)
├── ItemModelProvider (item models)
├── LanguageProvider (translations)
└── TagsProvider (tags)
```

**Fabric hierarchy** (similar but different APIs):
```
FabricDataGenerator.Pack
├── RecipeProvider
├── LootTableProvider
├── ModelProvider
├── TagProvider
└── LanguageProvider
```

### Registration (Forge/NeoForge)

**In your mod's main class** or dedicated datagen class:

```java
// Forge 1.20.1
@EventBusSubscriber(modid = MODID, bus = EventBusSubscriber.Bus.MOD)
public class DataGenerators {
    @SubscribeEvent
    public static void gatherData(GatherDataEvent event) {
        DataGenerator generator = event.getGenerator();
        PackOutput output = generator.getPackOutput();
        ExistingFileHelper existingFileHelper = event.getExistingFileHelper();
        CompletableFuture<HolderLookup.Provider> lookupProvider = event.getLookupProvider();

        // Register providers
        generator.addProvider(event.includeServer(), new ModRecipeProvider(output));
        generator.addProvider(event.includeServer(), new ModLootTableProvider(output));
        generator.addProvider(event.includeClient(), new ModBlockStateProvider(output, existingFileHelper));
        generator.addProvider(event.includeClient(), new ModItemModelProvider(output, existingFileHelper));
        generator.addProvider(event.includeClient(), new ModLanguageProvider(output, "en_us"));

        // Tags (both client and server)
        BlockTagsProvider blockTags = new ModBlockTagsProvider(output, lookupProvider, existingFileHelper);
        generator.addProvider(event.includeServer(), blockTags);
        generator.addProvider(event.includeServer(), new ModItemTagsProvider(output, lookupProvider, blockTags.contentsGetter(), existingFileHelper));
    }
}
```

**NeoForge 1.21.3** (similar but slightly different API):
```java
@EventBusSubscriber(modid = MODID, bus = EventBusSubscriber.Bus.MOD)
public class DataGenerators {
    @SubscribeEvent
    public static void gatherData(GatherDataEvent event) {
        DataGenerator generator = event.getGenerator();
        PackOutput output = generator.getPackOutput();

        generator.addProvider(event.includeServer(), new ModRecipeProvider(output, event.getLookupProvider()));
        // ... similar to Forge
    }
}
```

### Registration (Fabric)

**In your mod initializer**:

```java
// Fabric 1.20.x
public class MyModDatagen implements DataGeneratorEntrypoint {
    @Override
    public void onInitializeDataGenerator(FabricDataGenerator fabricDataGenerator) {
        FabricDataGenerator.Pack pack = fabricDataGenerator.createPack();

        pack.addProvider(ModRecipeProvider::new);
        pack.addProvider(ModLootTableProvider::new);
        pack.addProvider(ModModelProvider::new);
        pack.addProvider(ModBlockTagProvider::new);
        pack.addProvider(ModItemTagProvider::new);
        pack.addProvider(ModEnglishLanguageProvider::new);
    }
}
```

**fabric.mod.json** entry:
```json
{
  "entrypoints": {
    "fabric-datagen": [
      "com.mod.datagen.MyModDatagen"
    ]
  }
}
```

---

## Recipe Generation

### RecipeProvider Implementation (Forge/NeoForge)

```java
public class ModRecipeProvider extends RecipeProvider {
    public ModRecipeProvider(PackOutput output) {
        super(output);
    }

    @Override
    protected void buildRecipes(RecipeOutput output) {
        // Shaped crafting (3x3 grid with pattern)
        ShapedRecipeBuilder.shaped(RecipeCategory.TOOLS, ModItems.RUBY_SWORD.get())
            .pattern(" R ")
            .pattern(" R ")
            .pattern(" S ")
            .define('R', ModItems.RUBY.get())
            .define('S', Items.STICK)
            .unlockedBy("has_ruby", has(ModItems.RUBY.get()))
            .save(output);

        // Shapeless crafting (order doesn't matter)
        ShapelessRecipeBuilder.shapeless(RecipeCategory.MISC, ModItems.RUBY.get(), 9)
            .requires(ModBlocks.RUBY_BLOCK.get())
            .unlockedBy("has_ruby_block", has(ModBlocks.RUBY_BLOCK.get()))
            .save(output);

        // Smelting
        SimpleCookingRecipeBuilder.smelting(
            Ingredient.of(ModBlocks.RUBY_ORE.get()),
            RecipeCategory.MISC,
            ModItems.RUBY.get(),
            0.7f,  // XP
            200    // Cooking time (ticks)
        )
        .unlockedBy("has_ruby_ore", has(ModBlocks.RUBY_ORE.get()))
        .save(output, new ResourceLocation(MODID, "ruby_from_smelting"));

        // Blasting (faster smelting)
        SimpleCookingRecipeBuilder.blasting(
            Ingredient.of(ModBlocks.RUBY_ORE.get()),
            RecipeCategory.MISC,
            ModItems.RUBY.get(),
            0.7f,
            100    // Half the time of smelting
        )
        .unlockedBy("has_ruby_ore", has(ModBlocks.RUBY_ORE.get()))
        .save(output, new ResourceLocation(MODID, "ruby_from_blasting"));

        // Smithing (upgrade)
        SmithingTransformRecipeBuilder.smithing(
            Ingredient.of(Items.NETHERITE_UPGRADE_SMITHING_TEMPLATE),
            Ingredient.of(ModItems.RUBY_SWORD.get()),
            Ingredient.of(Items.NETHERITE_INGOT),
            RecipeCategory.TOOLS,
            ModItems.NETHERITE_RUBY_SWORD.get()
        )
        .unlocks("has_netherite_ingot", has(Items.NETHERITE_INGOT))
        .save(output, new ResourceLocation(MODID, "netherite_ruby_sword"));
    }
}
```

**Generates**: `src/generated/resources/data/modid/recipes/ruby_sword.json`

```json
{
  "type": "minecraft:crafting_shaped",
  "category": "tools",
  "pattern": [
    " R ",
    " R ",
    " S "
  ],
  "key": {
    "R": {
      "item": "modid:ruby"
    },
    "S": {
      "item": "minecraft:stick"
    }
  },
  "result": {
    "item": "modid:ruby_sword"
  }
}
```

### Recipe Patterns

**Pattern: Tool set recipes**

```java
private void createToolRecipes(RecipeOutput output, Item material, Item sword, Item pickaxe, Item axe, Item shovel, Item hoe) {
    // Sword
    ShapedRecipeBuilder.shaped(RecipeCategory.TOOLS, sword)
        .pattern(" M ")
        .pattern(" M ")
        .pattern(" S ")
        .define('M', material)
        .define('S', Items.STICK)
        .unlockedBy("has_material", has(material))
        .save(output);

    // Pickaxe
    ShapedRecipeBuilder.shaped(RecipeCategory.TOOLS, pickaxe)
        .pattern("MMM")
        .pattern(" S ")
        .pattern(" S ")
        .define('M', material)
        .define('S', Items.STICK)
        .unlockedBy("has_material", has(material))
        .save(output);

    // Similar for axe, shovel, hoe...
}

// Usage
createToolRecipes(output, ModItems.RUBY.get(),
    ModItems.RUBY_SWORD.get(),
    ModItems.RUBY_PICKAXE.get(),
    ModItems.RUBY_AXE.get(),
    ModItems.RUBY_SHOVEL.get(),
    ModItems.RUBY_HOE.get()
);
```

**Pattern: Ore processing chain**

```java
private void oreProcessing(RecipeOutput output, Item ore, Item rawOre, Item ingot) {
    // Raw ore from ore block
    ShapelessRecipeBuilder.shapeless(RecipeCategory.MISC, rawOre, 9)
        .requires(ore)
        .unlockedBy("has_ore", has(ore))
        .save(output, new ResourceLocation(MODID, rawOre.toString() + "_from_ore"));

    // Ingot from raw ore (smelting)
    SimpleCookingRecipeBuilder.smelting(Ingredient.of(rawOre), RecipeCategory.MISC, ingot, 0.7f, 200)
        .unlockedBy("has_raw_ore", has(rawOre))
        .save(output);

    // Ingot from raw ore (blasting)
    SimpleCookingRecipeBuilder.blasting(Ingredient.of(rawOre), RecipeCategory.MISC, ingot, 0.7f, 100)
        .unlockedBy("has_raw_ore", has(rawOre))
        .save(output, new ResourceLocation(MODID, ingot.toString() + "_from_blasting"));
}
```

---

## Loot Table Generation

### LootTableProvider Implementation (Forge/NeoForge)

```java
public class ModLootTableProvider extends LootTableProvider {
    public ModLootTableProvider(PackOutput output) {
        super(output, Set.of(), List.of(
            new SubProviderEntry(ModBlockLootTables::new, LootContextParamSets.BLOCK)
        ));
    }
}

public class ModBlockLootTables extends BlockLootSubProvider {
    public ModBlockLootTables() {
        super(Set.of(), FeatureFlags.REGISTRY.allFlags());
    }

    @Override
    protected void generate() {
        // Standard block (drops itself)
        dropSelf(ModBlocks.RUBY_BLOCK.get());

        // Ore with fortune (drops raw ore)
        add(ModBlocks.RUBY_ORE.get(),
            block -> createOreDrop(ModBlocks.RUBY_ORE.get(), ModItems.RAW_RUBY.get()));

        // Ore with silk touch vs normal drop
        add(ModBlocks.DEEPSLATE_RUBY_ORE.get(),
            block -> createSilkTouchDispatchTable(
                block,
                applyExplosionDecay(block, LootItem.lootTableItem(ModItems.RAW_RUBY.get())
                    .apply(SetItemCountFunction.setCount(UniformGenerator.between(2.0f, 5.0f)))
                    .apply(ApplyBonusCount.addOreBonusCount(Enchantments.BLOCK_FORTUNE))
                )
            )
        );

        // Custom drop table
        add(ModBlocks.COPPER_LEAVES.get(),
            block -> createLeavesDrops(block, ModBlocks.COPPER_SAPLING.get(), NORMAL_LEAVES_SAPLING_CHANCES));
    }

    @Override
    protected Iterable<Block> getKnownBlocks() {
        return ModBlocks.BLOCKS.getEntries().stream()
            .map(RegistryObject::get)
            ::iterator;
    }
}
```

**Generates**: `src/generated/resources/data/modid/loot_tables/blocks/ruby_ore.json`

```json
{
  "type": "minecraft:block",
  "pools": [
    {
      "rolls": 1,
      "entries": [
        {
          "type": "minecraft:item",
          "name": "modid:raw_ruby",
          "functions": [
            {
              "function": "minecraft:apply_bonus",
              "enchantment": "minecraft:fortune",
              "formula": "minecraft:ore_drops"
            },
            {
              "function": "minecraft:explosion_decay"
            }
          ]
        }
      ]
    }
  ]
}
```

---

## Model and Blockstate Generation

### BlockStateProvider (Forge/NeoForge)

```java
public class ModBlockStateProvider extends BlockStateProvider {
    public ModBlockStateProvider(PackOutput output, ExistingFileHelper existingFileHelper) {
        super(output, MODID, existingFileHelper);
    }

    @Override
    protected void registerStatesAndModels() {
        // Simple block (all sides same)
        simpleBlock(ModBlocks.RUBY_BLOCK.get());

        // Block with custom model
        simpleBlock(ModBlocks.RUBY_ORE.get(),
            models().cubeAll("ruby_ore", modLoc("block/ruby_ore")));

        // Directional block (facing)
        horizontalBlock(ModBlocks.CUSTOM_FURNACE.get(),
            models().orientable("custom_furnace",
                modLoc("block/custom_furnace_side"),
                modLoc("block/custom_furnace_front"),
                modLoc("block/custom_furnace_top")
            )
        );

        // Block with item model
        simpleBlockWithItem(ModBlocks.RUBY_BLOCK.get(), cubeAll(ModBlocks.RUBY_BLOCK.get()));
    }
}
```

### ItemModelProvider (Forge/NeoForge)

```java
public class ModItemModelProvider extends ItemModelProvider {
    public ModItemModelProvider(PackOutput output, ExistingFileHelper existingFileHelper) {
        super(output, MODID, existingFileHelper);
    }

    @Override
    protected void registerModels() {
        // Simple item (uses texture directly)
        basicItem(ModItems.RUBY.get());

        // Handheld item (tools, swords)
        handheldItem(ModItems.RUBY_SWORD.get());

        // Item with custom model
        withExistingParent(ModItems.CUSTOM_ITEM.get().toString(),
            modLoc("item/custom_item_model"));

        // Block item (references block model)
        withExistingParent(ModBlocks.RUBY_BLOCK.get().asItem().toString(),
            modLoc("block/ruby_block"));
    }

    // Helper for handheld items (tools, weapons)
    private ItemModelBuilder handheldItem(Item item) {
        return withExistingParent(item.toString(),
            new ResourceLocation("item/handheld"))
            .texture("layer0", new ResourceLocation(MODID, "item/" + item.toString()));
    }
}
```

---

## Tag Generation

### BlockTagsProvider (Forge/NeoForge)

```java
public class ModBlockTagsProvider extends BlockTagsProvider {
    public ModBlockTagsProvider(PackOutput output, CompletableFuture<HolderLookup.Provider> lookupProvider, ExistingFileHelper existingFileHelper) {
        super(output, lookupProvider, MODID, existingFileHelper);
    }

    @Override
    protected void addTags(HolderLookup.Provider provider) {
        // Minecraft tags
        tag(BlockTags.MINEABLE_WITH_PICKAXE)
            .add(ModBlocks.RUBY_ORE.get())
            .add(ModBlocks.DEEPSLATE_RUBY_ORE.get())
            .add(ModBlocks.RUBY_BLOCK.get());

        tag(BlockTags.NEEDS_IRON_TOOL)
            .add(ModBlocks.RUBY_ORE.get());

        // Forge tags
        tag(Tags.Blocks.ORES)
            .add(ModBlocks.RUBY_ORE.get())
            .add(ModBlocks.DEEPSLATE_RUBY_ORE.get());

        // Custom mod tags
        tag(ModTags.Blocks.RUBY_ORES)
            .add(ModBlocks.RUBY_ORE.get())
            .add(ModBlocks.DEEPSLATE_RUBY_ORE.get());
    }
}
```

### ItemTagsProvider (Forge/NeoForge)

```java
public class ModItemTagsProvider extends ItemTagsProvider {
    public ModItemTagsProvider(PackOutput output, CompletableFuture<HolderLookup.Provider> lookupProvider, CompletableFuture<TagLookup<Block>> blockTags, ExistingFileHelper existingFileHelper) {
        super(output, lookupProvider, blockTags, MODID, existingFileHelper);
    }

    @Override
    protected void addTags(HolderLookup.Provider provider) {
        // Copy block tags to item tags
        copy(ModTags.Blocks.RUBY_ORES, ModTags.Items.RUBY_ORES);

        // Item-specific tags
        tag(Tags.Items.GEMS)
            .add(ModItems.RUBY.get());

        tag(ItemTags.SWORDS)
            .add(ModItems.RUBY_SWORD.get());

        tag(ItemTags.PICKAXES)
            .add(ModItems.RUBY_PICKAXE.get());
    }
}
```

---

## Language File Generation

### LanguageProvider (Forge/NeoForge)

```java
public class ModLanguageProvider extends LanguageProvider {
    public ModLanguageProvider(PackOutput output, String locale) {
        super(output, MODID, locale);
    }

    @Override
    protected void addTranslations() {
        // Items
        add(ModItems.RUBY.get(), "Ruby");
        add(ModItems.RUBY_SWORD.get(), "Ruby Sword");
        add(ModItems.RUBY_PICKAXE.get(), "Ruby Pickaxe");

        // Blocks
        add(ModBlocks.RUBY_ORE.get(), "Ruby Ore");
        add(ModBlocks.RUBY_BLOCK.get(), "Block of Ruby");

        // Creative tabs
        add("itemGroup." + MODID, "My Mod");

        // Custom messages
        add("message.mymod.welcome", "Welcome to My Mod!");
        add("tooltip.mymod.ruby_sword", "A sword made of ruby");
    }
}
```

**Generates**: `src/generated/resources/assets/modid/lang/en_us.json`

```json
{
  "item.modid.ruby": "Ruby",
  "item.modid.ruby_sword": "Ruby Sword",
  "block.modid.ruby_ore": "Ruby Ore",
  "itemGroup.modid": "My Mod"
}
```

---

## Execution Workflow

### Step 1: Run runData Configuration

**IntelliJ**:
1. Open "Run/Debug Configurations" dropdown
2. Select "runData"
3. Click green play button

**Gradle command**:
```bash
./gradlew runData
```

**Expected console output**:
```
[main/INFO] [minecraft/Main]: Starting data generation...
[main/INFO] [DataGenerator]: Running provider: Recipes
[main/INFO] [DataGenerator]: Recipes finished after 234 ms
[main/INFO] [DataGenerator]: Running provider: Loot Tables
[main/INFO] [DataGenerator]: Loot Tables finished after 156 ms
[main/INFO] [DataGenerator]: Running provider: Block States
[main/INFO] [DataGenerator]: Block States finished after 423 ms
[main/INFO] [DataGenerator]: All providers finished after 1.2 seconds
```

### Step 2: Verify Generated Files

**Check output directory**: `src/generated/resources/`

**Expected structure**:
```
src/generated/resources/
├── data/
│   └── modid/
│       ├── recipes/
│       │   ├── ruby_sword.json
│       │   ├── ruby_from_smelting.json
│       │   └── ...
│       ├── loot_tables/
│       │   └── blocks/
│       │       ├── ruby_ore.json
│       │       └── ...
│       └── tags/
│           ├── blocks/
│           │   └── mineable/
│           │       └── pickaxe.json
│           └── items/
│               └── gems.json
└── assets/
    └── modid/
        ├── models/
        │   ├── block/
        │   │   └── ruby_block.json
        │   └── item/
        │       └── ruby.json
        ├── blockstates/
        │   └── ruby_block.json
        └── lang/
            └── en_us.json
```

### Step 3: Review and Commit

**Review generated files**:
- Open generated JSON files
- Verify structure matches expectations
- Check for errors or missing entries

**Option A: Use generated files directly**

Add to `build.gradle`:
```groovy
sourceSets.main.resources {
    srcDir 'src/generated/resources'
}
```

**Option B: Copy to main resources**

```bash
# Copy all generated files
cp -r src/generated/resources/* src/main/resources/

# Or selectively copy
cp src/generated/resources/data/modid/recipes/* src/main/resources/data/modid/recipes/
```

**Commit to git**:
```bash
git add src/generated/resources/
git commit -m "Add generated data files"
```

---

## Troubleshooting

### Problem: "No data providers registered"

**Cause**: GatherDataEvent not registered or providers not added

**Fix**:
```java
@EventBusSubscriber(modid = MODID, bus = EventBusSubscriber.Bus.MOD)
public class DataGenerators {
    @SubscribeEvent
    public static void gatherData(GatherDataEvent event) {
        // Add at least one provider
        event.getGenerator().addProvider(event.includeServer(), new ModRecipeProvider(event.getGenerator().getPackOutput()));
    }
}
```

### Problem: "FileNotFoundException: textures/..."

**Cause**: ExistingFileHelper checking for textures that don't exist yet

**Fix**: Create placeholder textures first, or disable validation:
```java
// Option 1: Create textures before running datagen
// src/main/resources/assets/modid/textures/item/ruby.png

// Option 2: Disable validation (not recommended)
new ModBlockStateProvider(output, new ExistingFileHelper(..., false))
```

### Problem: Generated files missing

**Cause**: Provider not returning data or crash during generation

**Fix**: Check console for errors:
```
[ERROR] [DataGenerator]: Failed to save recipe ruby_sword
java.lang.NullPointerException: Cannot invoke "Item.toString()" because "item" is null
```

Fix the null reference in your provider code.

### Problem: Recipe not working in-game

**Cause**: Recipe file not in correct location or wrong format

**Fix**:
1. Verify file path: `data/modid/recipes/recipe_name.json` (not `recipes/modid/...`)
2. Validate JSON structure (use online JSON validator)
3. Check console for recipe loading errors:
   ```
   [WARN] [RecipeManager]: Parsing error loading recipe modid:ruby_sword
   ```

---

## Best Practices

### DO

- ✅ Use data generation for all recipes, loot tables, tags
- ✅ Commit generated files to version control
- ✅ Review generated files before using
- ✅ Create helper methods for common patterns (tool sets, ore processing)
- ✅ Use meaningful unlock criteria (`has_ruby`, not `has_item`)

### DON'T

- ❌ Manually write recipes when datagen can do it
- ❌ Ignore console errors during generation
- ❌ Generate files for textures that don't exist
- ❌ Mix manual JSON and generated JSON (choose one approach)
- ❌ Commit broken generated files

---

## Summary

**runData** automates creation of game data files from Java code.

**Providers**:
- **RecipeProvider**: Crafting, smelting, blasting, smithing
- **LootTableProvider**: Block drops, chest loot
- **BlockStateProvider**: Block models and states
- **ItemModelProvider**: Item models
- **TagsProvider**: Block/item tags
- **LanguageProvider**: Translation files

**Workflow**: Write provider → Run runData → Review JSON → Commit

**Benefits**: Type safety, consistency, automation, refactoring safety

For run configurations, see [Run Client & Server](./run-client-server.md).

For custom configurations, see [Custom Configurations](./custom-configurations.md).
