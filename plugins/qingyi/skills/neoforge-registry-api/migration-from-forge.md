---
name: migration-from-forge
description: Complete Forge 1.20 to NeoForge 1.20+ migration guide. Step-by-step process for updating registry code.
---

# Forge to NeoForge Migration Guide

## Step 1: Update Package Imports

REPLACE THESE:
```java
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraftforge.registries.DeferredRegister;
import net.minecraftforge.registries.RegistryObject;
```

WITH THESE:
```java
import net.minecraft.core.registries.BuiltInRegistries;
import java.util.function.Supplier;
```

## Step 2: Change Registry References

Forge 1.20:
```java
DeferredRegister.create(ForgeRegistries.ITEMS, MODID)
DeferredRegister.create(ForgeRegistries.BLOCKS, MODID)
DeferredRegister.create(ForgeRegistries.ENTITY_TYPES, MODID)
```

NeoForge 1.20+:
```java
DeferredRegister.create(BuiltInRegistries.ITEM, MODID)
DeferredRegister.create(BuiltInRegistries.BLOCK, MODID)
DeferredRegister.create(BuiltInRegistries.ENTITY_TYPE, MODID)
```

## Step 3: Update Return Types

Forge 1.20:
```java
public static final RegistryObject<Item> RUBY =
    ITEMS.register("ruby", () -> new Item(...));
```

NeoForge 1.20+:
```java
public static final Supplier<Item> RUBY =
    ITEMS.register("ruby", () -> new Item(...));
```

Access remains identical:
```java
ModItems.RUBY.get() // Works on both
```

## Step 4: Update Registry Names

Note plural vs singular changes:

| Forge | NeoForge |
|-------|----------|
| `ForgeRegistries.ITEMS` | `BuiltInRegistries.ITEM` |
| `ForgeRegistries.BLOCKS` | `BuiltInRegistries.BLOCK` |
| `ForgeRegistries.ENTITY_TYPES` | `BuiltInRegistries.ENTITY_TYPE` |
| `ForgeRegistries.ENCHANTMENTS` | `BuiltInRegistries.ENCHANTMENT` |
| `ForgeRegistries.MOB_EFFECTS` | `BuiltInRegistries.MOB_EFFECT` |

## Step 5: Update build.gradle

Forge:
```groovy
minecraft 'net.minecraftforge:forge:1.20.1-47.1.0'
```

NeoForge:
```groovy
dependencies {
    implementation "net.neoforged:neoforge:${neo_version}"
}
```

Update gradle.properties:
```properties
neo_version=1.20.1-20240408.170117
```

## Complete Migration Example

BEFORE (Forge 1.20):
```java
public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

    public static final RegistryObject<Item> RUBY =
        ITEMS.register("ruby", () -> new Item(
            new Item.Properties()
        ));

    public static final RegistryObject<SwordItem> RUBY_SWORD =
        ITEMS.register("ruby_sword", () -> new SwordItem(
            Tiers.IRON, 3, -2.4f,
            new Item.Properties()
        ));

    public static void register(IEventBus modEventBus) {
        ITEMS.register(modEventBus);
    }
}
```

AFTER (NeoForge 1.20+):
```java
public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(BuiltInRegistries.ITEM, MODID);

    public static final Supplier<Item> RUBY =
        ITEMS.register("ruby", () -> new Item(
            new Item.Properties()
        ));

    public static final Supplier<SwordItem> RUBY_SWORD =
        ITEMS.register("ruby_sword", () -> new SwordItem(
            Tiers.IRON, 3, -2.4f,
            new Item.Properties()
        ));

    public static void register(IEventBus modEventBus) {
        ITEMS.register(modEventBus);
    }
}
```

Changes:
1. Registry: `ForgeRegistries.ITEMS` → `BuiltInRegistries.ITEM`
2. Return type: `RegistryObject<Item>` → `Supplier<Item>`

## Block Migration

BEFORE (Forge 1.20):
```java
public class ModBlocks {
    public static final DeferredRegister<Block> BLOCKS =
        DeferredRegister.create(ForgeRegistries.BLOCKS, MODID);

    public static final RegistryObject<Block> RUBY_BLOCK =
        BLOCKS.register("ruby_block", () ->
            new Block(BlockBehaviour.Properties.of())
        );
}
```

AFTER (NeoForge 1.20+):
```java
public class ModBlocks {
    public static final DeferredRegister<Block> BLOCKS =
        DeferredRegister.create(BuiltInRegistries.BLOCK, MODID);

    public static final Supplier<Block> RUBY_BLOCK =
        BLOCKS.register("ruby_block", () ->
            new Block(BlockBehaviour.Properties.of())
        );
}
```

## Entity Migration

BEFORE (Forge 1.20):
```java
public class ModEntities {
    public static final DeferredRegister<EntityType<?>> ENTITIES =
        DeferredRegister.create(ForgeRegistries.ENTITY_TYPES, MODID);

    public static final RegistryObject<EntityType<CustomEntity>> CUSTOM =
        ENTITIES.register("custom", () -> EntityType.Builder
            .of(CustomEntity::new, MobCategory.CREATURE)
            .sized(0.6F, 1.8F)
            .build("custom")
        );
}
```

AFTER (NeoForge 1.20+):
```java
public class ModEntities {
    public static final DeferredRegister<EntityType<?>> ENTITIES =
        DeferredRegister.create(BuiltInRegistries.ENTITY_TYPE, MODID);

    public static final Supplier<EntityType<CustomEntity>> CUSTOM =
        ENTITIES.register("custom", () -> EntityType.Builder
            .of(CustomEntity::new, MobCategory.CREATURE)
            .sized(0.6F, 1.8F)
            .build("custom")
        );
}
```

## Migration Checklist

- [ ] Replace ForgeRegistries imports with BuiltInRegistries
- [ ] Update all registry references (ITEMS → ITEM, BLOCKS → BLOCK, etc.)
- [ ] Change RegistryObject<T> to Supplier<T>
- [ ] Update build.gradle dependencies
- [ ] Update gradle.properties with neo_version
- [ ] Replace package imports (minecraftforge → neoforged)
- [ ] Test compilation
- [ ] Test runtime

## Code Access Pattern (No Changes)

Both versions use same access:
```java
// Works identically on Forge and NeoForge
Item ruby = ModItems.RUBY.get();
Block rubyBlock = ModBlocks.RUBY_BLOCK.get();
```

The return type change is internal - usage remains the same.

Migration is straightforward registry name and type updates.
