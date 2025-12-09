---
name: forge-registry-api
description: Forge and NeoForge registry API reference for items, blocks, and entities. Use when implementing game content registration, working with DeferredRegister, RegistryObject, or creative tabs. Covers Forge 1.19-1.20 and NeoForge 1.20-1.21 differences.
allowed-tools: Read, Grep, Glob
---

# Forge Registry API

## What This Covers

- DeferredRegister registration system
- RegistryObject pattern for type-safe references
- Creative tab organization
- Item/Block/Entity registration lifecycle
- Registry timing and MOD bus usage
- Version differences between Forge 1.19, 1.20, and NeoForge 1.21

## When to Use

- Creating new items, blocks, or entities
- Setting up mod registration infrastructure
- Migrating between Forge versions
- Understanding registry object initialization timing
- Troubleshooting "registry not found" errors

## Core Knowledge

### DeferredRegister Pattern

The DeferredRegister system defers object registration until the appropriate registry event fires, preventing timing issues.

**Basic Setup (Forge 1.20.1 - from MusicMod)**:
```java
public class ModSounds {
    public static final DeferredRegister<SoundEvent> SOUNDS =
        DeferredRegister.create(ForgeRegistries.SOUND_EVENTS, MODID);

    public static final RegistryObject<SoundEvent> CUSTOM_SOUND =
        SOUNDS.register("custom_sound", () ->
            SoundEvent.createVariableRangeEvent(new ResourceLocation(MODID, "custom_sound"))
        );
}
```

**Registration in Main Class**:
```java
@Mod(MODID)
public class MyMod {
    public MyMod(IEventBus modEventBus) {
        ModSounds.SOUNDS.register(modEventBus);
        ModItems.ITEMS.register(modEventBus);
        ModBlocks.BLOCKS.register(modEventBus);
    }
}
```

**Key Points**:
- Must register DeferredRegister to MOD event bus (not FORGE bus)
- Registration happens in mod constructor
- Use lambda supplier `() -> new Item(...)` for deferred creation
- RegistryObject provides type-safe access after registration

### RegistryObject Type Safety

**Access Pattern**:
```java
public static final RegistryObject<Item> THEFATRAT =
    ITEMS.register("thefatrat", () -> new Item(new Item.Properties()
        .stacksTo(1)
        .rarity(Rarity.RARE)));

// Later access (safe)
Item item = ModItems.THEFATRAT.get();
```

**When Objects Are Available**:
- ❌ NOT available during mod constructor
- ❌ NOT available during `@SubscribeEvent` registry events
- ✅ Available after `FMLCommonSetupEvent`
- ✅ Safe to use in gameplay code

### Item Registration Patterns

**Simple Item (MusicMod Pattern)**:
```java
public static final RegistryObject<Item> SIMPLE_ITEM =
    ITEMS.register("simple_item", () -> new Item(new Item.Properties()));
```

**Item with Properties**:
```java
public static final RegistryObject<Item> SPECIAL_ITEM =
    ITEMS.register("special_item", () -> new Item(new Item.Properties()
        .stacksTo(1)               // Stack size (1-64)
        .rarity(Rarity.EPIC)       // Color in tooltip
        .fireResistant()           // Survives fire/lava
        .tab(CreativeModeTab.TAB_MISC))); // Creative tab
```

**Custom Item Class**:
```java
public static final RegistryObject<MusicDiscItem> MUSIC_DISC =
    ITEMS.register("music_disc", () -> new MusicDiscItem(
        15,  // Comparator signal
        ModSounds.CUSTOM_SOUND,
        new Item.Properties().stacksTo(1).rarity(Rarity.RARE),
        180  // Duration in seconds
    ));
```

### Sound Event Registration (from MusicMod)

**Sound Event**:
```java
public static final RegistryObject<SoundEvent> THEFATRAT =
    SOUNDS.register("thefatrat", () ->
        SoundEvent.createVariableRangeEvent(new ResourceLocation(MODID, "thefatrat"))
    );
```

**Corresponding sounds.json**:
```json
{
  "thefatrat": {
    "subtitle": "sounds.musicmod.thefatrat",
    "sounds": [
      {
        "name": "musicmod:thefatrat",
        "stream": true
      }
    ]
  }
}
```

**Resource Location**:
- Registry name: `"thefatrat"`
- Sound file: `assets/musicmod/sounds/thefatrat.ogg`
- Full ID: `musicmod:thefatrat`

### Entity Registration (NeoForge 1.21.3 - from Apocalypse_TNT)

**Entity Type Registration**:
```java
public class ModEntities {
    public static final DeferredRegister<EntityType<?>> ENTITIES =
        DeferredRegister.create(BuiltInRegistries.ENTITY_TYPE, MODID);

    public static final Supplier<EntityType<GroundActivatedTnt>> GROUND_TNT =
        ENTITIES.register("ground_tnt", () -> EntityType.Builder
            .<GroundActivatedTnt>of(GroundActivatedTnt::new, MobCategory.MISC)
            .sized(0.98F, 0.98F)           // Hitbox size
            .clientTrackingRange(10)       // Render distance in chunks
            .updateInterval(10)            // Sync frequency in ticks
            .build("ground_tnt"));
}
```

**Entity Class**:
```java
public class GroundActivatedTnt extends Entity {
    public GroundActivatedTnt(EntityType<? extends GroundActivatedTnt> type, Level level) {
        super(type, level);
    }

    // Implementation...
}
```

### Block Registration

**Simple Block**:
```java
public static final RegistryObject<Block> CUSTOM_BLOCK =
    BLOCKS.register("custom_block", () -> new Block(
        BlockBehaviour.Properties.of()
            .strength(3.0F)        // Hardness
            .requiresCorrectToolForDrops()
            .sound(SoundType.STONE)
    ));
```

**Block + BlockItem**:
```java
// 1. Register block
public static final RegistryObject<Block> CUSTOM_BLOCK =
    BLOCKS.register("custom_block", () -> new Block(...));

// 2. Register corresponding item
public static final RegistryObject<BlockItem> CUSTOM_BLOCK_ITEM =
    ITEMS.register("custom_block", () -> new BlockItem(
        CUSTOM_BLOCK.get(),
        new Item.Properties()
    ));
```

## Version Differences

### Forge 1.19.x

**ForgeRegistries**:
```java
DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MODID);
```

**Creative Tabs**:
```java
new Item.Properties().tab(CreativeModeTab.TAB_MISC)
```

### Forge 1.20.x (MusicMod)

**ForgeRegistries (same as 1.19)**:
```java
DeferredRegister<SoundEvent> SOUNDS =
    DeferredRegister.create(ForgeRegistries.SOUND_EVENTS, MODID);
```

**Creative Tabs (changed)**:
- Now uses `CreativeModeTabRegistry` or custom tab creation
- Item properties no longer have `.tab()` method in some 1.20+ versions

### NeoForge 1.20.x → 1.21.3 (Apocalypse_TNT)

**BuiltInRegistries (NEW)**:
```java
DeferredRegister<EntityType<?>> ENTITIES =
    DeferredRegister.create(BuiltInRegistries.ENTITY_TYPE, MODID);
```

**Key Changes**:
- `ForgeRegistries` → `BuiltInRegistries` for vanilla registries
- `RegistryObject` → `Supplier` (more flexible return type)
- Some API methods renamed or moved

**Migration Example**:
```java
// Forge 1.20
DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MODID);
public static final RegistryObject<Item> MY_ITEM = ...;

// NeoForge 1.21.3
DeferredRegister<Item> ITEMS =
    DeferredRegister.create(BuiltInRegistries.ITEM, MODID);
public static final Supplier<Item> MY_ITEM = ...;
```

## Common Patterns

### Pattern 1: Centralized Registry Classes

**Use when**: Organizing multiple related objects

**Implementation**:
```
src/main/java/[package]/
├── item/
│   └── ModItems.java         // All item registrations
├── block/
│   └── ModBlocks.java        // All block registrations
├── entity/
│   └── ModEntities.java      // All entity registrations
└── sound/
    └── ModSounds.java        // All sound registrations
```

**Benefits**:
- Clear organization
- Easy to find registrations
- Single point of registration in main class

### Pattern 2: Grouped Registration (from MusicMod)

**Use when**: Many similar items (e.g., music discs, tools set)

**Example**:
```java
public class ModSounds {
    // Group 1: TheFatRat music
    public static final RegistryObject<SoundEvent> THEFATRAT =
        SOUNDS.register("thefatrat", () -> ...);
    public static final RegistryObject<SoundEvent> MONODY =
        SOUNDS.register("monody", () -> ...);

    // Group 2: NCS music
    public static final RegistryObject<SoundEvent> INVINCIBLE =
        SOUNDS.register("invincible", () -> ...);
}
```

### Pattern 3: Helper Method Pattern

**Use when**: Repeated registration logic

**Implementation**:
```java
private static RegistryObject<Item> registerSimpleItem(String name) {
    return ITEMS.register(name, () -> new Item(new Item.Properties()));
}

public static final RegistryObject<Item> ITEM1 = registerSimpleItem("item1");
public static final RegistryObject<Item> ITEM2 = registerSimpleItem("item2");
```

## Best Practices

1. **Always register to MOD bus** (not FORGE bus):
   ```java
   // ✅ Correct
   ModItems.ITEMS.register(modEventBus);

   // ❌ Wrong
   ModItems.ITEMS.register(MinecraftForge.EVENT_BUS);
   ```

2. **Use constants for registry names**:
   ```java
   // ✅ Good
   public static final String CUSTOM_ITEM_NAME = "custom_item";
   ITEMS.register(CUSTOM_ITEM_NAME, () -> ...);

   // ❌ Bad (typo-prone)
   ITEMS.register("custm_item", () -> ...);
   ```

3. **Match registry name with field name**:
   ```java
   // ✅ Good (easy to find)
   public static final RegistryObject<Item> RUBY_SWORD =
       ITEMS.register("ruby_sword", () -> ...);

   // ❌ Confusing
   public static final RegistryObject<Item> SWORD1 =
       ITEMS.register("ruby_sword", () -> ...);
   ```

4. **Group related registrations**:
   ```java
   // Tools
   public static final RegistryObject<Item> RUBY_PICKAXE = ...;
   public static final RegistryObject<Item> RUBY_AXE = ...;

   // Combat
   public static final RegistryObject<Item> RUBY_SWORD = ...;
   public static final RegistryObject<Item> RUBY_BOW = ...;
   ```

## Anti-Patterns

1. ❌ **Registering too late**:
   ```java
   // ❌ Wrong - registration must happen in mod constructor
   @SubscribeEvent
   public void onCommonSetup(FMLCommonSetupEvent event) {
       ModItems.ITEMS.register(modEventBus); // TOO LATE!
   }
   ```

2. ❌ **Accessing RegistryObject.get() too early**:
   ```java
   // ❌ Crash - object not registered yet
   public MyMod() {
       Item item = ModItems.CUSTOM_ITEM.get(); // NULL or crash
   }

   // ✅ Safe
   public void onCommonSetup(FMLCommonSetupEvent event) {
       Item item = ModItems.CUSTOM_ITEM.get(); // OK
   }
   ```

3. ❌ **Duplicate registry names**:
   ```java
   // ❌ Second registration overwrites first
   ITEMS.register("custom_item", () -> new Item(...));
   ITEMS.register("custom_item", () -> new Item(...)); // ERROR
   ```

4. ❌ **Wrong registry type**:
   ```java
   // ❌ Type mismatch
   DeferredRegister<Item> ITEMS = ...;
   ITEMS.register("block", () -> new Block(...)); // Wrong type!
   ```

5. ❌ **Not creating BlockItem for blocks**:
   ```java
   // ❌ Block exists but not obtainable
   BLOCKS.register("custom_block", () -> new Block(...));
   // Missing: BlockItem registration
   ```

## Pitfalls to Avoid

### Pitfall 1: Null Pointer in Static Initialization
```java
// ❌ Crashes during class loading
public class ModItems {
    private static final Item DEPENDENCY = ModItems.OTHER_ITEM.get(); // NULL

    public static final RegistryObject<Item> CUSTOM_ITEM =
        ITEMS.register("custom_item", () -> new Item(
            new Item.Properties().food(new FoodProperties.Builder()
                .effect(() -> new MobEffectInstance(MobEffects.REGENERATION, 200), 1.0F)
                .build())
        ));
}

// ✅ Use supplier to defer access
() -> new Item(new Item.Properties()
    .food(createFoodProperties())) // Method call, evaluated later
```

### Pitfall 2: Forgetting to Register DeferredRegister
```java
// ❌ Objects never registered
public static final DeferredRegister<Item> ITEMS = ...;
// Missing: ITEMS.register(modEventBus);

// ✅ Always register in mod constructor
public MyMod(IEventBus modEventBus) {
    ModItems.ITEMS.register(modEventBus);
}
```

### Pitfall 3: Client-Only Registry Access on Server
```java
// ❌ Crashes dedicated server
@OnlyIn(Dist.CLIENT)
public class ClientItems {
    public static final DeferredRegister<Item> ITEMS = ...; // Server can't see this
}

// ✅ Register in common code, use client-only properties if needed
public class ModItems {
    public static final DeferredRegister<Item> ITEMS = ...; // Accessible everywhere
}
```

## Verification Checklist

- [ ] DeferredRegister created with correct registry type
- [ ] Registered to MOD event bus in mod constructor
- [ ] Registry names follow snake_case convention
- [ ] Field names follow UPPER_SNAKE_CASE convention
- [ ] No duplicate registry names
- [ ] RegistryObject.get() not called during static initialization
- [ ] Blocks have corresponding BlockItems (if obtainable)
- [ ] Items appear in creative tab (if desired)
- [ ] Translation keys exist in lang file
- [ ] Models/textures created for items/blocks

## See Also

- [neoforge-registry-api](../neoforge-registry-api/SKILL.md) - NeoForge migration guide
- [fabric-registry-api](../fabric-registry-api/SKILL.md) - Fabric equivalent
- Official Forge Docs: https://docs.minecraftforge.net/en/latest/concepts/registries/
