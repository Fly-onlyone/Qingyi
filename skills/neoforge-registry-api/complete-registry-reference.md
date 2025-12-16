---
name: complete-registry-reference
description: Comprehensive reference of all BuiltInRegistries in NeoForge 1.20-1.21. Covers all registry types with code examples.
---

# Complete BuiltInRegistries Reference

## Overview

NeoForge 1.20-1.21 uses BuiltInRegistries instead of ForgeRegistries. All vanilla registries are available through this class.

## Common Registries

### Items

```java
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(BuiltInRegistries.ITEM, MODID);

public static final Supplier<Item> RUBY =
    ITEMS.register("ruby", () -> new Item(
        new Item.Properties()
    ));
```

### Blocks

```java
public static final DeferredRegister<Block> BLOCKS =
    DeferredRegister.create(BuiltInRegistries.BLOCK, MODID);

public static final Supplier<Block> RUBY_BLOCK =
    BLOCKS.register("ruby_block", () ->
        new Block(BlockBehaviour.Properties.of())
    );
```

### Entity Types

```java
public static final DeferredRegister<EntityType<?>> ENTITIES =
    DeferredRegister.create(BuiltInRegistries.ENTITY_TYPE, MODID);

public static final Supplier<EntityType<CustomEntity>> CUSTOM =
    ENTITIES.register("custom", () -> EntityType.Builder
        .of(CustomEntity::new, MobCategory.CREATURE)
        .sized(0.6F, 1.8F)
        .build("custom")
    );
```

### Block Entity Types

```java
public static final DeferredRegister<BlockEntityType<?>> BLOCK_ENTITIES =
    DeferredRegister.create(BuiltInRegistries.BLOCK_ENTITY_TYPE, MODID);

public static final Supplier<BlockEntityType<CustomBlockEntity>> CUSTOM_BE =
    BLOCK_ENTITIES.register("custom_be", () ->
        BlockEntityType.Builder.of(CustomBlockEntity::new,
            ModBlocks.RUBY_BLOCK.get())
        .build(null)
    );
```

### Sounds

```java
public static final DeferredRegister<SoundEvent> SOUNDS =
    DeferredRegister.create(BuiltInRegistries.SOUND_EVENT, MODID);

public static final Supplier<SoundEvent> MAGIC_SOUND =
    SOUNDS.register("magic", () ->
        SoundEvent.createVariableRangeEvent(
            new ResourceLocation(MODID, "magic")
        )
    );
```

### Mob Effects (Potions)

```java
public static final DeferredRegister<MobEffect> MOB_EFFECTS =
    DeferredRegister.create(BuiltInRegistries.MOB_EFFECT, MODID);

public static final Supplier<MobEffect> STRENGTH =
    MOB_EFFECTS.register("strength", () ->
        new MobEffect(MobEffectCategory.BENEFICIAL, 0xFF0000)
    );
```

### Potions

```java
public static final DeferredRegister<Potion> POTIONS =
    DeferredRegister.create(BuiltInRegistries.POTION, MODID);

public static final Supplier<Potion> MAGIC_POTION =
    POTIONS.register("magic", () ->
        new Potion("magic", 
            new MobEffectInstance(ModEffects.MAGIC.get(), 3600))
    );
```

### Enchantments

```java
public static final DeferredRegister<Enchantment> ENCHANTMENTS =
    DeferredRegister.create(BuiltInRegistries.ENCHANTMENT, MODID);

public static final Supplier<Enchantment> MAGIC =
    ENCHANTMENTS.register("magic", () ->
        new Enchantment(Enchantment.Rarity.RARE,
            EnchantmentCategory.WEAPON, null)
    );
```

### Menu Types

```java
public static final DeferredRegister<MenuType<?>> MENUS =
    DeferredRegister.create(BuiltInRegistries.MENU, MODID);

public static final Supplier<MenuType<CustomMenu>> CUSTOM_MENU =
    MENUS.register("custom_menu", () ->
        new MenuType<>(CustomMenu::new)
    );
```

### Recipe Types

```java
public static final DeferredRegister<RecipeType<?>> RECIPE_TYPES =
    DeferredRegister.create(BuiltInRegistries.RECIPE_TYPE, MODID);

public static final Supplier<RecipeType<CustomRecipe>> CUSTOM_RECIPE =
    RECIPE_TYPES.register("custom", () ->
        new RecipeType<CustomRecipe>() {}
    );
```

### Recipe Serializers

```java
public static final DeferredRegister<RecipeSerializer<?>> RECIPE_SERIALIZERS =
    DeferredRegister.create(BuiltInRegistries.RECIPE_SERIALIZER, MODID);

public static final Supplier<RecipeSerializer<CustomRecipe>> CUSTOM_SERIALIZER =
    RECIPE_SERIALIZERS.register("custom", () ->
        new RecipeSerializer<CustomRecipe>() { }
    );
```

## BuiltInRegistries List

All available registries:

```java
BuiltInRegistries.ITEM
BuiltInRegistries.BLOCK
BuiltInRegistries.ENTITY_TYPE
BuiltInRegistries.BLOCK_ENTITY_TYPE
BuiltInRegistries.SOUND_EVENT
BuiltInRegistries.MOB_EFFECT
BuiltInRegistries.POTION
BuiltInRegistries.ENCHANTMENT
BuiltInRegistries.MENU
BuiltInRegistries.RECIPE_TYPE
BuiltInRegistries.RECIPE_SERIALIZER
BuiltInRegistries.PARTICLE_TYPE
BuiltInRegistries.BLOCK_PREDICATE_TYPE
```

## Usage Pattern

```java
public class ModContent {
    // Items
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(BuiltInRegistries.ITEM, MODID);
    
    public static final Supplier<Item> RUBY =
        ITEMS.register("ruby", () -> new Item(new Item.Properties()));

    // Blocks
    public static final DeferredRegister<Block> BLOCKS =
        DeferredRegister.create(BuiltInRegistries.BLOCK, MODID);
    
    public static final Supplier<Block> RUBY_BLOCK =
        BLOCKS.register("ruby_block", () ->
            new Block(BlockBehaviour.Properties.of()));

    // Register all
    public static void register(IEventBus modEventBus) {
        ITEMS.register(modEventBus);
        BLOCKS.register(modEventBus);
    }
}
```

## Key Differences from Forge

| Forge | NeoForge |
|-------|----------|
| `ForgeRegistries.ITEMS` | `BuiltInRegistries.ITEM` |
| `ForgeRegistries.BLOCKS` | `BuiltInRegistries.BLOCK` |
| `ForgeRegistries.ENTITY_TYPES` | `BuiltInRegistries.ENTITY_TYPE` |
| `RegistryObject<T>` return | `Supplier<T>` return |

Access is the same:
```java
ModItems.RUBY.get() // Both Forge and NeoForge
```

## Real-World Example: Apocalypse_TNT (NeoForge)

```java
public class ModEntities {
    public static final DeferredRegister<EntityType<?>> ENTITIES =
        DeferredRegister.create(BuiltInRegistries.ENTITY_TYPE, MODID);

    public static final Supplier<EntityType<GroundActivatedTnt>> GROUND_TNT =
        ENTITIES.register("ground_tnt", () -> EntityType.Builder
            .<GroundActivatedTnt>of(GroundActivatedTnt::new, 
                MobCategory.MISC)
            .sized(0.98F, 0.98F)
            .clientTrackingRange(10)
            .updateInterval(10)
            .build("ground_tnt")
        );

    public static void register(IEventBus modEventBus) {
        ENTITIES.register(modEventBus);
    }
}
```

Use BuiltInRegistries for all content registration in NeoForge 1.20+.
