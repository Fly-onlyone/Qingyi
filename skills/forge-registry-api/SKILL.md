---
name: forge-registry-api
description: Forge registry API reference for items, blocks, and entities. Use when implementing game content registration, working with DeferredRegister, RegistryObject, or creative tabs. Covers Forge 1.19-1.20 patterns.
allowed-tools: Read, Grep, Glob
---

# Forge Registry API

## What This Covers

- DeferredRegister registration system
- RegistryObject for type-safe references
- Creative tab organization
- Item/Block/Entity registration patterns
- Registry timing and MOD bus usage

## When to Use

- Creating new items, blocks, or entities in Forge
- Setting up mod registration infrastructure
- Understanding registry initialization timing
- Troubleshooting "registry not found" errors
- Working with creative tabs

---

## Core Registration Pattern

### Basic Item Registration (Forge 1.20)

```java
public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

    // RegistryObject provides type-safe reference
    public static final RegistryObject<Item> RUBY =
        ITEMS.register("ruby", () -> new Item(new Item.Properties()));

    public static final RegistryObject<SwordItem> RUBY_SWORD =
        ITEMS.register("ruby_sword", () ->
            new SwordItem(Tiers.IRON, 3, -2.4f, new Item.Properties()));

    public static void register(IEventBus modEventBus) {
        ITEMS.register(modEventBus);
    }
}
```

**Key Points**:
- `DeferredRegister.create(ForgeRegistries.ITEMS, MODID)`
- Return type: `RegistryObject<Item>`
- Access via `.get()`: `ModItems.RUBY.get()`
- Register on MOD bus in mod constructor

### Block Registration

```java
public class ModBlocks {
    public static final DeferredRegister<Block> BLOCKS =
        DeferredRegister.create(ForgeRegistries.BLOCKS, MODID);

    public static final RegistryObject<Block> RUBY_BLOCK =
        BLOCKS.register("ruby_block", () ->
            new Block(BlockBehaviour.Properties.of()
                .strength(5.0f, 6.0f)
                .requiresCorrectToolForDrops()));

    public static void register(IEventBus modEventBus) {
        BLOCKS.register(modEventBus);
    }
}
```

**Block Items** (separate registration):
```java
public static final RegistryObject<BlockItem> RUBY_BLOCK_ITEM =
    ModItems.ITEMS.register("ruby_block", () ->
        new BlockItem(ModBlocks.RUBY_BLOCK.get(), new Item.Properties()));
```

### Entity Registration

```java
public class ModEntities {
    public static final DeferredRegister<EntityType<?>> ENTITIES =
        DeferredRegister.create(ForgeRegistries.ENTITY_TYPES, MODID);

    public static final RegistryObject<EntityType<CustomEntity>> CUSTOM_ENTITY =
        ENTITIES.register("custom_entity", () -> EntityType.Builder
            .of(CustomEntity::new, MobCategory.CREATURE)
            .sized(0.6F, 1.8F)
            .clientTrackingRange(8)
            .build("custom_entity"));

    public static void register(IEventBus modEventBus) {
        ENTITIES.register(modEventBus);
    }
}
```

---

## Creative Tab Registration (Forge 1.20)

### Creating Custom Tab

```java
public class ModCreativeTabs {
    public static final DeferredRegister<CreativeModeTab> TABS =
        DeferredRegister.create(Registries.CREATIVE_MODE_TAB, MODID);

    public static final RegistryObject<CreativeModeTab> MOD_TAB =
        TABS.register("mod_tab", () -> CreativeModeTab.builder()
            .title(Component.translatable("itemGroup." + MODID))
            .icon(() -> new ItemStack(ModItems.RUBY.get()))
            .displayItems((params, output) -> {
                // Add items to tab
                output.accept(ModItems.RUBY.get());
                output.accept(ModItems.RUBY_SWORD.get());
                output.accept(ModBlocks.RUBY_BLOCK.get());
            })
            .build());

    public static void register(IEventBus modEventBus) {
        TABS.register(modEventBus);
    }
}
```

---

## Mod Initialization Pattern

### Main Mod Class (Forge 1.20)

```java
@Mod(MODID)
public class MyMod {
    public static final String MODID = "mymod";

    public MyMod(IEventBus modEventBus) {
        // Register all deferred registers
        ModItems.register(modEventBus);
        ModBlocks.register(modEventBus);
        ModEntities.register(modEventBus);
        ModCreativeTabs.register(modEventBus);

        // Common setup
        modEventBus.addListener(this::commonSetup);

        // Client setup (conditional)
        DistExecutor.unsafeRunWhenOn(Dist.CLIENT,
            () -> () -> modEventBus.addListener(this::clientSetup));
    }

    private void commonSetup(FMLCommonSetupEvent event) {
        event.enqueueWork(() -> {
            // Thread-safe initialization
        });
    }

    private void clientSetup(FMLClientSetupEvent event) {
        event.enqueueWork(() -> {
            // Client-only initialization
        });
    }
}
```

---

## Common Registration Patterns

### Pattern 1: Item with Custom Properties

```java
public static final RegistryObject<Item> MAGICAL_DUST =
    ITEMS.register("magical_dust", () -> new Item(new Item.Properties()
        .stacksTo(16)
        .rarity(Rarity.RARE)
        .fireResistant()));
```

### Pattern 2: Tool Item

```java
public static final RegistryObject<PickaxeItem> RUBY_PICKAXE =
    ITEMS.register("ruby_pickaxe", () ->
        new PickaxeItem(ModTiers.RUBY, 1, -2.8f, new Item.Properties()));
```

### Pattern 3: Food Item

```java
public static final RegistryObject<Item> ENCHANTED_APPLE =
    ITEMS.register("enchanted_apple", () -> new Item(new Item.Properties()
        .food(Foods.GOLDEN_APPLE)
        .rarity(Rarity.EPIC)));
```

### Pattern 4: Block with Custom Behavior

```java
public static final RegistryObject<Block> SPECIAL_BLOCK =
    BLOCKS.register("special_block", () ->
        new SpecialBlock(BlockBehaviour.Properties.of()
            .strength(3.0f)
            .sound(SoundType.METAL)
            .lightLevel(state -> 15)));
```

---

## ForgeRegistries Reference (Quick Lookup)

### Common Registries

```java
ForgeRegistries.ITEMS               // Items
ForgeRegistries.BLOCKS              // Blocks
ForgeRegistries.ENTITY_TYPES        // Entity types
ForgeRegistries.BLOCK_ENTITY_TYPES  // Block entities
ForgeRegistries.SOUND_EVENTS        // Sounds
ForgeRegistries.MOB_EFFECTS         // Potion effects
ForgeRegistries.POTIONS             // Potions
ForgeRegistries.ENCHANTMENTS        // Enchantments
ForgeRegistries.MENU_TYPES          // Container menus
ForgeRegistries.RECIPE_TYPES        // Recipe types
ForgeRegistries.RECIPE_SERIALIZERS  // Recipe serializers
```

---

## Common Issues and Solutions

### Issue 1: Registry Not Found
**Error**: `Registry not found during initialization`

**Cause**: DeferredRegister not registered on MOD bus

**Solution**:
```java
// In mod constructor
ModItems.register(modEventBus);
```

### Issue 2: NullPointerException When Accessing Item
**Error**: NPE when calling `.get()` on RegistryObject

**Cause**: Accessing registry object before registration complete

**Solution**: Only access `.get()` after FMLCommonSetupEvent or in-game

### Issue 3: Item Not in Creative Tab
**Symptom**: Item registered but not visible in creative menu

**Solution**: Add to creative tab via displayItems:
```java
.displayItems((params, output) -> {
    output.accept(ModItems.RUBY.get());
})
```

---

## Supporting Documentation

### Detailed Guides
- [DeferredRegister Deep Dive](./deferred-register-deep-dive.md) - Complete registration lifecycle
- [Creative Tab Customization](./creative-tab-customization.md) - Advanced tab configuration
- [Registry Troubleshooting](./registry-troubleshooting.md) - Common errors and fixes

---

## Quick Checklist

- [ ] Create DeferredRegister for registry type
- [ ] Register items/blocks/entities with `.register()`
- [ ] Call `.register(modEventBus)` in mod constructor
- [ ] Register block items separately if needed
- [ ] Add items to creative tab
- [ ] Use `.get()` only after registration completes

---

Use this skill when working with Forge 1.19-1.20 to ensure correct registration patterns and avoid common pitfalls.
