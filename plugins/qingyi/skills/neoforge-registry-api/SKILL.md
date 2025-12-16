---
name: neoforge-registry-api
description: NeoForge registry API reference for items, blocks, and entities. Use when implementing game content registration in NeoForge 1.20-1.21, migrating from Forge, or working with BuiltInRegistries and modern registration patterns. Covers API changes and migration paths.
allowed-tools: Read, Grep, Glob
---

# NeoForge Registry API

## What This Covers

- NeoForge registration system (1.20.x → 1.21.3)
- Migration from Forge to NeoForge
- BuiltInRegistries vs ForgeRegistries
- DeferredRegister with Supplier return types
- Entity, Item, and Block registration

## When to Use

- Starting new NeoForge mods (1.20+)
- Migrating existing Forge mods to NeoForge
- Understanding NeoForge-specific registration patterns
- Troubleshooting "ForgeRegistries not found" errors
- Working with custom entities in NeoForge 1.21+

---

## NeoForge vs Forge: Key Differences

| Aspect | Forge 1.20 | NeoForge 1.21+ |
|--------|-----------|----------------|
| Vanilla registries | `ForgeRegistries.ITEMS` | `BuiltInRegistries.ITEM` |
| Return type | `RegistryObject<T>` | `Supplier<T>` |
| Custom registries | `ForgeRegistries` | `NeoForgeRegistries` |
| Package | `net.minecraftforge` | `net.neoforged` |
| Registry events | MOD bus events | Same (MOD bus) |

**Key Change**: NeoForge uses `BuiltInRegistries` (vanilla) and returns `Supplier<T>` instead of `RegistryObject<T>`.

---

## Registration Patterns

### Item Registration (NeoForge 1.21.3)

**Basic Pattern**:
```java
public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(BuiltInRegistries.ITEM, MODID);

    // Returns Supplier<Item>, not RegistryObject<Item>
    public static final Supplier<Item> RUBY = ITEMS.register("ruby",
        () -> new Item(new Item.Properties()));

    public static final Supplier<SwordItem> RUBY_SWORD = ITEMS.register("ruby_sword",
        () -> new SwordItem(Tiers.IRON, 3, -2.4f, new Item.Properties()));

    public static void register(IEventBus modEventBus) {
        ITEMS.register(modEventBus);
    }
}
```

**Key Points**:
- Use `BuiltInRegistries.ITEM` (not `ForgeRegistries.ITEMS`)
- Return type is `Supplier<Item>` (not `RegistryObject<Item>`)
- Access item via `.get()`: `ModItems.RUBY.get()`

### Block Registration (NeoForge 1.21.3)

**Basic Pattern**:
```java
public class ModBlocks {
    public static final DeferredRegister<Block> BLOCKS =
        DeferredRegister.create(BuiltInRegistries.BLOCK, MODID);

    public static final Supplier<Block> RUBY_BLOCK = BLOCKS.register("ruby_block",
        () -> new Block(BlockBehaviour.Properties.of()
            .strength(5.0f, 6.0f)
            .requiresCorrectToolForDrops()));

    // Block items must be registered separately
    public static void register(IEventBus modEventBus) {
        BLOCKS.register(modEventBus);
    }
}
```

**Block Items** (separate registration):
```java
public static final Supplier<BlockItem> RUBY_BLOCK_ITEM =
    ModItems.ITEMS.register("ruby_block", () ->
        new BlockItem(ModBlocks.RUBY_BLOCK.get(), new Item.Properties()));
```

### Entity Registration (NeoForge 1.21.3)

**From Apocalypse_TNT Mod**:
```java
public class ModEntities {
    public static final DeferredRegister<EntityType<?>> ENTITIES =
        DeferredRegister.create(BuiltInRegistries.ENTITY_TYPE, MODID);

    public static final Supplier<EntityType<GroundActivatedTnt>> GROUND_TNT =
        ENTITIES.register("ground_tnt", () -> EntityType.Builder
            .<GroundActivatedTnt>of(GroundActivatedTnt::new, MobCategory.MISC)
            .sized(0.98F, 0.98F)
            .clientTrackingRange(10)
            .updateInterval(10)
            .build("ground_tnt"));

    public static void register(IEventBus modEventBus) {
        ENTITIES.register(modEventBus);
    }
}
```

**Key Points**:
- Use `BuiltInRegistries.ENTITY_TYPE` (not `ForgeRegistries.ENTITY_TYPES`)
- Entity type builder specifies factory, category, size, tracking
- Return type is `Supplier<EntityType<T>>`

---

## Migration from Forge to NeoForge

### Step 1: Update Package Imports

**Replace**:
```java
// Old (Forge)
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraftforge.registries.RegistryObject;

// New (NeoForge)
import net.minecraft.core.registries.BuiltInRegistries;
import java.util.function.Supplier;
```

### Step 2: Change Registry References

**Replace ForgeRegistries with BuiltInRegistries**:
```java
// Old (Forge)
DeferredRegister.create(ForgeRegistries.ITEMS, MODID)
DeferredRegister.create(ForgeRegistries.BLOCKS, MODID)
DeferredRegister.create(ForgeRegistries.ENTITY_TYPES, MODID)

// New (NeoForge)
DeferredRegister.create(BuiltInRegistries.ITEM, MODID)
DeferredRegister.create(BuiltInRegistries.BLOCK, MODID)
DeferredRegister.create(BuiltInRegistries.ENTITY_TYPE, MODID)
```

### Step 3: Update Return Types

**Change RegistryObject to Supplier**:
```java
// Old (Forge)
public static final RegistryObject<Item> RUBY =
    ITEMS.register("ruby", () -> new Item(new Item.Properties()));

// New (NeoForge)
public static final Supplier<Item> RUBY =
    ITEMS.register("ruby", () -> new Item(new Item.Properties()));
```

**Access remains the same**: Both use `.get()` to retrieve the registered object.

### Step 4: Update build.gradle

**Change forge dependency to neoforge**:
```groovy
// Old (Forge)
minecraft 'net.minecraftforge:forge:1.20.1-47.1.0'

// New (NeoForge)
implementation "net.neoforged:neoforge:${neo_version}"
```

**For complete migration guide**: See [Forge to NeoForge Migration](./forge-to-neoforge-migration.md)

---

## Common Registration Patterns

### Pattern 1: Item with Custom Properties

```java
public static final Supplier<Item> MAGICAL_DUST = ITEMS.register("magical_dust",
    () -> new Item(new Item.Properties()
        .stacksTo(16)
        .rarity(Rarity.RARE)
        .fireResistant()));
```

### Pattern 2: Tool Item

```java
public static final Supplier<PickaxeItem> RUBY_PICKAXE =
    ITEMS.register("ruby_pickaxe", () ->
        new PickaxeItem(ModTiers.RUBY, 1, -2.8f, new Item.Properties()));
```

### Pattern 3: Block with Custom Behavior

```java
public static final Supplier<Block> SPECIAL_BLOCK = BLOCKS.register("special_block",
    () -> new SpecialBlock(BlockBehaviour.Properties.of()
        .strength(3.0f)
        .sound(SoundType.METAL)
        .lightLevel(state -> 15)));
```

### Pattern 4: Custom Entity

```java
public static final Supplier<EntityType<CustomEntity>> CUSTOM_ENTITY =
    ENTITIES.register("custom_entity", () -> EntityType.Builder
        .of(CustomEntity::new, MobCategory.CREATURE)
        .sized(0.6F, 1.8F)
        .clientTrackingRange(8)
        .build("custom_entity"));
```

---

## BuiltInRegistries Reference (Quick Lookup)

### Common Registries

```java
BuiltInRegistries.ITEM           // Items
BuiltInRegistries.BLOCK          // Blocks
BuiltInRegistries.ENTITY_TYPE    // Entity types
BuiltInRegistries.BLOCK_ENTITY_TYPE  // Block entities
BuiltInRegistries.SOUND_EVENT    // Sounds
BuiltInRegistries.MOB_EFFECT     // Potion effects
BuiltInRegistries.POTION         // Potions
BuiltInRegistries.ENCHANTMENT    // Enchantments
BuiltInRegistries.MENU           // Container menus
BuiltInRegistries.RECIPE_TYPE    // Recipe types
BuiltInRegistries.RECIPE_SERIALIZER  // Recipe serializers
```

**For complete reference**: See [BuiltInRegistries Complete Reference](./builtin-registries-reference.md)

---

## Mod Initialization Pattern

### Mod Main Class (NeoForge 1.21.3)

```java
@Mod(MODID)
public class MyMod {
    public static final String MODID = "mymod";

    public MyMod(IEventBus modEventBus) {
        // Register deferred registers
        ModItems.register(modEventBus);
        ModBlocks.register(modEventBus);
        ModEntities.register(modEventBus);

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
            EntityRenderers.register(ModEntities.CUSTOM_ENTITY.get(),
                CustomEntityRenderer::new);
        });
    }
}
```

---

## Common Issues and Solutions

### Issue 1: Cannot Find Symbol: ForgeRegistries
**Error**: `cannot find symbol: variable ForgeRegistries`

**Cause**: Using Forge imports in NeoForge project

**Solution**: Replace with `BuiltInRegistries`
```java
// Change from:
import net.minecraftforge.registries.ForgeRegistries;

// To:
import net.minecraft.core.registries.BuiltInRegistries;
```

### Issue 2: Type Mismatch with RegistryObject
**Error**: `incompatible types: Supplier<Item> cannot be converted to RegistryObject<Item>`

**Cause**: Using Forge return types in NeoForge

**Solution**: Change `RegistryObject<T>` to `Supplier<T>`

### Issue 3: Registry Not Found
**Error**: Registry name not found during initialization

**Check**:
- DeferredRegister created with correct registry
- `.register(modEventBus)` called in mod constructor
- Registry name uses lowercase snake_case

**For comprehensive troubleshooting**: See [NeoForge Registry Troubleshooting](./neoforge-registry-troubleshooting.md)

---

## Supporting Documentation

### Detailed Guides
- [BuiltInRegistries Complete Reference](./builtin-registries-reference.md) - All available registries with examples
- [Forge to NeoForge Migration](./forge-to-neoforge-migration.md) - Step-by-step migration process
- [Entity Registration Deep Dive](./entity-registration-deep-dive.md) - Advanced entity registration patterns
- [NeoForge Registry Troubleshooting](./neoforge-registry-troubleshooting.md) - Common errors and fixes

---

## Quick Migration Checklist

- [ ] Replace `net.minecraftforge` imports with `net.neoforged`
- [ ] Change `ForgeRegistries` to `BuiltInRegistries`
- [ ] Update return types: `RegistryObject<T>` → `Supplier<T>`
- [ ] Update registry names (plural → singular): `ITEMS` → `ITEM`, `BLOCKS` → `BLOCK`
- [ ] Update build.gradle dependencies
- [ ] Test compilation and runtime
- [ ] Verify all registrations work correctly

---

Use this skill when working with NeoForge 1.20+ to ensure correct registration patterns and smooth migration from Forge.
