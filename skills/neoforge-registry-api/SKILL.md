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
- Entity registration patterns
- Breaking changes and compatibility

## When to Use

- Starting new NeoForge mods (1.20+)
- Migrating existing Forge mods to NeoForge
- Understanding NeoForge-specific registration patterns
- Troubleshooting "ForgeRegistries not found" errors
- Working with custom entities in NeoForge 1.21+

## Core Knowledge

### NeoForge vs Forge: Key Differences

| Aspect | Forge 1.20 | NeoForge 1.21+ |
|--------|-----------|----------------|
| Vanilla registries | `ForgeRegistries.ITEMS` | `BuiltInRegistries.ITEM` |
| Return type | `RegistryObject<T>` | `Supplier<T>` |
| Custom registries | `ForgeRegistries` | `NeoForgeRegistries` |
| Package | `net.minecraftforge` | `net.neoforged` |
| Registry events | MOD bus events | Same (MOD bus) |

### BuiltInRegistries Pattern (NeoForge 1.21.3)

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

**Key Changes from Forge**:
- ✅ `BuiltInRegistries.ENTITY_TYPE` instead of `ForgeRegistries.ENTITY_TYPES`
- ✅ `Supplier<EntityType<T>>` instead of `RegistryObject<EntityType<T>>`
- ✅ More flexible generics (can use `Supplier` interface)

### Item Registration (NeoForge)

**Basic Pattern**:
```java
public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(BuiltInRegistries.ITEM, MODID);

    public static final Supplier<Item> CUSTOM_ITEM =
        ITEMS.register("custom_item", () -> new Item(new Item.Properties()));
}
```

**With Properties**:
```java
public static final Supplier<Item> SPECIAL_ITEM =
    ITEMS.register("special_item", () -> new Item(new Item.Properties()
        .stacksTo(1)
        .rarity(Rarity.EPIC)
        .fireResistant()));
```

### Block Registration (NeoForge)

**Block + BlockItem Pattern**:
```java
public class ModBlocks {
    public static final DeferredRegister<Block> BLOCKS =
        DeferredRegister.create(BuiltInRegistries.BLOCK, MODID);

    public static final Supplier<Block> CUSTOM_BLOCK =
        BLOCKS.register("custom_block", () -> new Block(
            BlockBehaviour.Properties.of()
                .strength(3.0F)
                .requiresCorrectToolForDrops()
        ));
}

// Corresponding BlockItem
public class ModItems {
    public static final Supplier<BlockItem> CUSTOM_BLOCK_ITEM =
        ITEMS.register("custom_block", () -> new BlockItem(
            ModBlocks.CUSTOM_BLOCK.get(),
            new Item.Properties()
        ));
}
```

### Entity Registration Deep Dive (from Apocalypse_TNT)

**Complete Entity Setup**:
```java
// 1. DeferredRegister
public static final DeferredRegister<EntityType<?>> ENTITIES =
    DeferredRegister.create(BuiltInRegistries.ENTITY_TYPE, MODID);

// 2. Entity Type Registration
public static final Supplier<EntityType<GroundActivatedTnt>> GROUND_TNT =
    ENTITIES.register("ground_tnt", () -> EntityType.Builder
        .<GroundActivatedTnt>of(
            GroundActivatedTnt::new,           // Factory method reference
            MobCategory.MISC                    // Category (affects spawning)
        )
        .sized(0.98F, 0.98F)                   // Width, Height
        .clientTrackingRange(10)                // Render distance (chunks)
        .updateInterval(10)                     // Sync frequency (ticks)
        .build("ground_tnt"));                  // Build key (must match registry name)

// 3. Entity Class
public class GroundActivatedTnt extends Entity {
    public GroundActivatedTnt(EntityType<? extends GroundActivatedTnt> type, Level level) {
        super(type, level);
        this.blocksBuilding = true;  // Can't place blocks on this entity
    }

    @Override
    public void tick() {
        super.tick();
        // Custom behavior
    }

    // Additional methods...
}
```

**Entity Spawning**:
```java
// In-world spawning
GroundActivatedTnt entity = ModEntities.GROUND_TNT.get().create(level);
if (entity != null) {
    entity.setPos(x, y, z);
    level.addFreshEntity(entity);
}
```

### Sound Event Registration (NeoForge)

**Pattern** (similar to Forge):
```java
public class ModSounds {
    public static final DeferredRegister<SoundEvent> SOUNDS =
        DeferredRegister.create(BuiltInRegistries.SOUND_EVENT, MODID);

    public static final Supplier<SoundEvent> EXPLOSION_SOUND =
        SOUNDS.register("explosion", () ->
            SoundEvent.createVariableRangeEvent(new ResourceLocation(MODID, "explosion"))
        );
}
```

**Playing Sound**:
```java
level.playSound(null, pos, ModSounds.EXPLOSION_SOUND.get(), SoundSource.BLOCKS, 1.0F, 1.0F);
```

## Migration from Forge to NeoForge

### Step 1: Update build.gradle

**Before (Forge)**:
```gradle
plugins {
    id 'net.minecraftforge.gradle' version '5.1.+'
}
```

**After (NeoForge)**:
```gradle
plugins {
    id 'net.neoforged.gradle.userdev' version '7.0.+'
}
```

### Step 2: Update Package Imports

**Find and Replace**:
- `net.minecraftforge` → `net.neoforged.neoforge`
- `ForgeRegistries` → `BuiltInRegistries` (for vanilla registries)
- `@Mod` → `@Mod` (same, but check annotation changes)

**Example Migration**:
```java
// Forge 1.20
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraftforge.registries.RegistryObject;

DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MODID);
RegistryObject<Item> ITEM = ITEMS.register(...);

// NeoForge 1.21
import net.minecraft.core.registries.BuiltInRegistries;
import java.util.function.Supplier;

DeferredRegister<Item> ITEMS =
    DeferredRegister.create(BuiltInRegistries.ITEM, MODID);
Supplier<Item> ITEM = ITEMS.register(...);
```

### Step 3: Update Registry Types

**Forge → NeoForge Registry Mapping**:

| Forge 1.20 | NeoForge 1.21 |
|------------|---------------|
| `ForgeRegistries.ITEMS` | `BuiltInRegistries.ITEM` |
| `ForgeRegistries.BLOCKS` | `BuiltInRegistries.BLOCK` |
| `ForgeRegistries.ENTITY_TYPES` | `BuiltInRegistries.ENTITY_TYPE` |
| `ForgeRegistries.SOUND_EVENTS` | `BuiltInRegistries.SOUND_EVENT` |
| `ForgeRegistries.BLOCK_ENTITY_TYPES` | `BuiltInRegistries.BLOCK_ENTITY_TYPE` |

### Step 4: Update Return Types

**Before (Forge)**:
```java
public static final RegistryObject<Item> CUSTOM_ITEM = ...;

public void useItem() {
    Item item = ModItems.CUSTOM_ITEM.get();
}
```

**After (NeoForge)**:
```java
public static final Supplier<Item> CUSTOM_ITEM = ...;

public void useItem() {
    Item item = ModItems.CUSTOM_ITEM.get();  // Same .get() method
}
```

**Why Supplier?** More flexible, part of standard Java library, can be used with other APIs.

### Step 5: Check Mod Metadata

**Before (mods.toml)**:
```toml
modLoader="javafml"
loaderVersion="[47,)"
```

**After (neoforge.mods.toml or mods.toml)**:
```toml
modLoader="javafml"
loaderVersion="[1,)"
```

## NeoForge-Specific Features

### 1. Modern Entity Registration (from Apocalypse_TNT)

**Advanced Entity Builder**:
```java
EntityType.Builder.<CustomEntity>of(CustomEntity::new, MobCategory.CREATURE)
    .sized(0.6F, 1.8F)                    // Hitbox dimensions
    .clientTrackingRange(10)               // Client render distance
    .updateInterval(3)                     // Network sync interval
    .setShouldReceiveVelocityUpdates(true) // Velocity sync
    .build("custom_entity");
```

### 2. Supplier Flexibility

**Can use method references**:
```java
public static final Supplier<Item> ITEM = ITEMS.register("item", CustomItem::new);

// Instead of lambda
public static final Supplier<Item> ITEM = ITEMS.register("item", () -> new CustomItem());
```

### 3. Registry Helper Methods

**Check if registered**:
```java
boolean isRegistered = BuiltInRegistries.ITEM.containsKey(
    new ResourceLocation(MODID, "custom_item")
);
```

**Get by ResourceLocation**:
```java
Item item = BuiltInRegistries.ITEM.get(new ResourceLocation(MODID, "custom_item"));
```

## Common Patterns

### Pattern 1: Centralized Registration (from Apocalypse_TNT)

**ModEntities.java**:
```java
public class ModEntities {
    public static final DeferredRegister<EntityType<?>> ENTITIES =
        DeferredRegister.create(BuiltInRegistries.ENTITY_TYPE, MODID);

    public static final Supplier<EntityType<GroundActivatedTnt>> GROUND_TNT =
        ENTITIES.register("ground_tnt", () -> ...);

    // More entities...

    public static void register(IEventBus modEventBus) {
        ENTITIES.register(modEventBus);
    }
}
```

**Main Mod Class**:
```java
@Mod(MODID)
public class ApocalypseTntMod {
    public ApocalypseTntMod(IEventBus modEventBus) {
        ModEntities.register(modEventBus);
        ModItems.register(modEventBus);
        ModBlocks.register(modEventBus);
    }
}
```

### Pattern 2: Grouped Entity Types

**By Category**:
```java
// Hostile entities
public static final Supplier<EntityType<CustomZombie>> CUSTOM_ZOMBIE = ...;
public static final Supplier<EntityType<CustomSkeleton>> CUSTOM_SKELETON = ...;

// Projectiles
public static final Supplier<EntityType<CustomArrow>> CUSTOM_ARROW = ...;
public static final Supplier<EntityType<CustomFireball>> CUSTOM_FIREBALL = ...;

// Misc
public static final Supplier<EntityType<GroundActivatedTnt>> GROUND_TNT = ...;
```

### Pattern 3: Entity Factory Pattern

**Reusable Builder**:
```java
private static <T extends Entity> Supplier<EntityType<T>> registerEntity(
    String name,
    EntityType.EntityFactory<T> factory,
    MobCategory category,
    float width,
    float height
) {
    return ENTITIES.register(name, () -> EntityType.Builder
        .of(factory, category)
        .sized(width, height)
        .clientTrackingRange(10)
        .updateInterval(10)
        .build(name));
}

// Usage
public static final Supplier<EntityType<CustomEntity>> CUSTOM =
    registerEntity("custom", CustomEntity::new, MobCategory.MISC, 1.0F, 1.0F);
```

## Best Practices

1. **Use BuiltInRegistries for vanilla types**:
   ```java
   // ✅ Correct
   DeferredRegister.create(BuiltInRegistries.ITEM, MODID);

   // ❌ Old Forge style (may not exist in NeoForge)
   DeferredRegister.create(ForgeRegistries.ITEMS, MODID);
   ```

2. **Match entity build key with registry name**:
   ```java
   // ✅ Good
   ENTITIES.register("ground_tnt", () -> EntityType.Builder
       ...
       .build("ground_tnt"));  // Same name

   // ❌ Mismatch can cause issues
   ENTITIES.register("ground_tnt", () -> EntityType.Builder
       ...
       .build("tnt_entity"));  // Different name
   ```

3. **Set appropriate entity tracking ranges**:
   ```java
   // Small entities (items, particles)
   .clientTrackingRange(4)
   .updateInterval(20)

   // Regular entities (mobs, TNT)
   .clientTrackingRange(10)
   .updateInterval(10)

   // Large/important entities (bosses, structures)
   .clientTrackingRange(16)
   .updateInterval(3)
   ```

4. **Use Supplier type for flexibility**:
   ```java
   // ✅ More flexible
   public static final Supplier<Item> ITEM = ...;

   // ⚠️ Works but less flexible
   public static final RegistryObject<Item> ITEM = ...;
   ```

## Anti-Patterns

1. ❌ **Mixing Forge and NeoForge imports**:
   ```java
   // ❌ Don't mix
   import net.minecraftforge.registries.ForgeRegistries;
   import net.neoforged.neoforge.registries.DeferredRegister;
   ```

2. ❌ **Wrong entity category**:
   ```java
   // ❌ TNT is not a monster
   EntityType.Builder.of(TntEntity::new, MobCategory.MONSTER)

   // ✅ Use MISC for non-living entities
   EntityType.Builder.of(TntEntity::new, MobCategory.MISC)
   ```

3. ❌ **Forgetting to call register() method**:
   ```java
   // ❌ Static helper method never invoked
   public static void register(IEventBus modEventBus) {
       ENTITIES.register(modEventBus);
   }
   // Missing: ModEntities.register(modEventBus) in main class
   ```

4. ❌ **Null entity on spawn**:
   ```java
   // ❌ Not checking for null
   GroundActivatedTnt entity = ModEntities.GROUND_TNT.get().create(level);
   entity.setPos(x, y, z);  // NPE if create() returns null

   // ✅ Always check
   GroundActivatedTnt entity = ModEntities.GROUND_TNT.get().create(level);
   if (entity != null) {
       entity.setPos(x, y, z);
       level.addFreshEntity(entity);
   }
   ```

## Pitfalls to Avoid

### Pitfall 1: Incomplete Migration

**Symptom**: ClassNotFoundException for ForgeRegistries

**Cause**: Missed imports during migration

**Fix**: Search entire project for `net.minecraftforge` and replace

### Pitfall 2: Entity Not Rendering

**Symptom**: Entity exists but invisible

**Cause**: Missing renderer registration (client-only)

**Fix**:
```java
@SubscribeEvent
public static void onRegisterRenderers(EntityRenderersEvent.RegisterRenderers event) {
    event.registerEntityRenderer(
        ModEntities.GROUND_TNT.get(),
        TntRenderer::new  // Or custom renderer
    );
}
```

### Pitfall 3: Build Key Mismatch

**Symptom**: Entity spawns but has wrong properties

**Cause**: Build key doesn't match registry name

**Fix**: Always use same name in both places

## Verification Checklist

- [ ] All imports use `net.neoforged` package
- [ ] `BuiltInRegistries` used for vanilla types
- [ ] Return type is `Supplier<T>` (not `RegistryObject<T>`)
- [ ] DeferredRegister registered to MOD bus
- [ ] Entity build key matches registry name
- [ ] Entity tracking ranges appropriate for entity type
- [ ] Renderer registered for entities (client-side)
- [ ] Entity categories correct (MISC for non-living)

## Migration Checklist (Forge → NeoForge)

- [ ] Update build.gradle plugins
- [ ] Update gradle.properties versions
- [ ] Replace all `net.minecraftforge` imports
- [ ] Replace `ForgeRegistries` with `BuiltInRegistries`
- [ ] Change `RegistryObject` to `Supplier` where needed
- [ ] Update mods.toml metadata
- [ ] Test all registrations work
- [ ] Verify entities spawn correctly
- [ ] Check client rendering

## See Also

- [forge-registry-api](../forge-registry-api/SKILL.md) - Forge patterns
- [fabric-registry-api](../fabric-registry-api/SKILL.md) - Fabric equivalent
- Official NeoForge Docs: https://docs.neoforged.net/
