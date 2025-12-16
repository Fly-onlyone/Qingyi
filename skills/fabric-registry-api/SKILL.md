---
name: fabric-registry-api
description: Fabric registry system using Registry.register with Identifiers. Covers item, block, entity registration, creative tab organization, and Fabric lifecycle. Use when implementing content registration in Fabric/Quilt mods.
---

# Fabric Registry API

## What This Covers

- Fabric direct registration with Registry.register
- Identifier (Fabric's ResourceLocation)
- Item/Block/Entity registration patterns
- Creative tab organization (Fabric API)
- Mod initialization lifecycle

## When to Use

- Registering content in Fabric/Quilt mods
- Understanding Fabric vs Forge differences
- Implementing creative tabs in Fabric
- Setting up Fabric mod initialization

---

## Core Registration Pattern

### Basic Item Registration (Fabric 1.20)

```java
public class ModItems {
    // Direct registration, no DeferredRegister
    public static final Item RUBY = Registry.register(
        Registries.ITEM,
        new Identifier(MODID, "ruby"),
        new Item(new Item.Settings())
    );

    public static final Item RUBY_SWORD = Registry.register(
        Registries.ITEM,
        new Identifier(MODID, "ruby_sword"),
        new SwordItem(ToolMaterials.IRON, 3, -2.4f, new Item.Settings())
    );

    public static void register() {
        // Items already registered inline above
    }
}
```

**Key Points**:
- `Registry.register(Registries.ITEM, id, item)`
- Uses `Identifier` (not ResourceLocation)
- Direct access (no `.get()` needed)
- Registration happens immediately (no deferred)

### Block Registration

```java
public class ModBlocks {
    public static final Block RUBY_BLOCK = Registry.register(
        Registries.BLOCK,
        new Identifier(MODID, "ruby_block"),
        new Block(AbstractBlock.Settings.create()
            .strength(5.0f, 6.0f)
            .requiresTool())
    );

    // Block item must be registered separately
    public static final BlockItem RUBY_BLOCK_ITEM = Registry.register(
        Registries.ITEM,
        new Identifier(MODID, "ruby_block"),
        new BlockItem(RUBY_BLOCK, new Item.Settings())
    );

    public static void register() {
        // Blocks already registered inline
    }
}
```

### Entity Registration

```java
public class ModEntities {
    public static final EntityType<CustomEntity> CUSTOM_ENTITY = Registry.register(
        Registries.ENTITY_TYPE,
        new Identifier(MODID, "custom_entity"),
        FabricEntityTypeBuilder.create(SpawnGroup.CREATURE, CustomEntity::new)
            .dimensions(EntityDimensions.fixed(0.6F, 1.8F))
            .trackRangeBlocks(8)
            .build()
    );

    public static void register() {
        // Entities already registered inline
    }
}
```

---

## Creative Tab Registration (Fabric API)

### Creating Custom Tab

```java
public class ModItemGroups {
    public static final ItemGroup MOD_GROUP = FabricItemGroup.builder()
        .icon(() -> new ItemStack(ModItems.RUBY))
        .displayName(Text.translatable("itemGroup." + MODID))
        .entries((context, entries) -> {
            // Add items to tab
            entries.add(ModItems.RUBY);
            entries.add(ModItems.RUBY_SWORD);
            entries.add(ModBlocks.RUBY_BLOCK);
        })
        .build();

    public static void register() {
        Registry.register(
            Registries.ITEM_GROUP,
            new Identifier(MODID, "mod_group"),
            MOD_GROUP
        );
    }
}
```

---

## Mod Initialization Pattern

### Main Mod Class (Fabric 1.20)

```java
public class MyMod implements ModInitializer {
    public static final String MODID = "mymod";

    @Override
    public void onInitialize() {
        // Register all content
        ModItems.register();
        ModBlocks.register();
        ModEntities.register();
        ModItemGroups.register();

        // Register event callbacks
        ServerTickEvents.END_SERVER_TICK.register(server -> {
            // Server tick logic
        });
    }
}
```

**Register in fabric.mod.json**:
```json
{
  "entrypoints": {
    "main": [
      "com.mymod.MyMod"
    ]
  }
}
```

### Client Initialization

```java
public class MyModClient implements ClientModInitializer {
    @Override
    public void onInitializeClient() {
        // Client-only registration
        EntityRendererRegistry.register(
            ModEntities.CUSTOM_ENTITY,
            CustomEntityRenderer::new
        );

        // Client event callbacks
        ClientTickEvents.END_CLIENT_TICK.register(client -> {
            // Client tick logic
        });
    }
}
```

**Register in fabric.mod.json**:
```json
{
  "entrypoints": {
    "client": [
      "com.mymod.MyModClient"
    ]
  }
}
```

---

## Common Registration Patterns

### Pattern 1: Item with Custom Properties

```java
public static final Item MAGICAL_DUST = Registry.register(
    Registries.ITEM,
    new Identifier(MODID, "magical_dust"),
    new Item(new Item.Settings()
        .maxCount(16)
        .rarity(Rarity.RARE)
        .fireproof())
);
```

### Pattern 2: Tool Item

```java
public static final Item RUBY_PICKAXE = Registry.register(
    Registries.ITEM,
    new Identifier(MODID, "ruby_pickaxe"),
    new PickaxeItem(ModToolMaterials.RUBY, 1, -2.8f, new Item.Settings())
);
```

### Pattern 3: Food Item

```java
public static final Item ENCHANTED_APPLE = Registry.register(
    Registries.ITEM,
    new Identifier(MODID, "enchanted_apple"),
    new Item(new Item.Settings()
        .food(FoodComponents.GOLDEN_APPLE)
        .rarity(Rarity.EPIC))
);
```

### Pattern 4: Block with Custom Behavior

```java
public static final Block SPECIAL_BLOCK = Registry.register(
    Registries.BLOCK,
    new Identifier(MODID, "special_block"),
    new SpecialBlock(AbstractBlock.Settings.create()
        .strength(3.0f)
        .sounds(BlockSoundGroup.METAL)
        .luminance(state -> 15))
);
```

---

## Fabric vs Forge Comparison

| Aspect | Fabric | Forge |
|--------|--------|-------|
| Registration | `Registry.register()` | `DeferredRegister.create()` |
| Resource location | `Identifier` | `ResourceLocation` |
| Return type | Direct reference | `RegistryObject<T>` |
| Access | Direct | Via `.get()` |
| Timing | Immediate | Deferred to event |
| Item settings | `Item.Settings` | `Item.Properties` |
| Block settings | `AbstractBlock.Settings` | `BlockBehaviour.Properties` |

---

## Fabric Registries Reference (Quick Lookup)

### Common Registries

```java
Registries.ITEM               // Items
Registries.BLOCK              // Blocks
Registries.ENTITY_TYPE        // Entity types
Registries.BLOCK_ENTITY_TYPE  // Block entities
Registries.SOUND_EVENT        // Sounds
Registries.STATUS_EFFECT      // Potion effects
Registries.POTION             // Potions
Registries.ENCHANTMENT        // Enchantments
Registries.SCREEN_HANDLER     // Container screens
Registries.RECIPE_TYPE        // Recipe types
Registries.RECIPE_SERIALIZER  // Recipe serializers
Registries.ITEM_GROUP         // Creative tabs
```

---

## Common Issues and Solutions

### Issue 1: Item Not Found
**Error**: `Unknown item` in-game

**Cause**: Registration not called in onInitialize

**Solution**:
```java
@Override
public void onInitialize() {
    ModItems.register();  // Must call this
}
```

### Issue 2: Identifier Format Error
**Error**: `Invalid identifier format`

**Cause**: Using uppercase or spaces in identifier

**Solution**: Use lowercase snake_case:
```java
// ❌ Wrong
new Identifier(MODID, "Ruby Sword")

// ✅ Correct
new Identifier(MODID, "ruby_sword")
```

### Issue 3: Item Not in Creative Tab
**Symptom**: Item registered but not visible

**Solution**: Add to item group:
```java
.entries((context, entries) -> {
    entries.add(ModItems.RUBY);
})
```

---

## Supporting Documentation

### Detailed Guides
- [Fabric Registry Deep Dive](./fabric-registry-deep-dive.md) - Complete registration patterns
- [Creative Tab Customization](./creative-tab-customization.md) - Advanced tab configuration
- [Fabric vs Forge Migration](./fabric-forge-migration.md) - Converting between frameworks

---

## Quick Checklist

- [ ] Register items/blocks with Registry.register()
- [ ] Use Identifier (not ResourceLocation)
- [ ] Call registration methods in onInitialize()
- [ ] Register block items separately
- [ ] Add items to creative tab via entries()
- [ ] Use lowercase snake_case for identifiers

---

Use this skill when working with Fabric/Quilt to ensure correct registration patterns and framework-specific implementations.
