---
name: neoforge-registry-troubleshooting
description: Troubleshooting guide for NeoForge registry issues. Covers migration errors and NeoForge-specific problems.
---

# NeoForge Registry Troubleshooting

## Error 1: "cannot find symbol: ForgeRegistries"

Symptom:
```
error: cannot find symbol: variable ForgeRegistries
```

Cause: Using Forge imports in NeoForge project

Solution:
```java
// WRONG - Forge
import net.minecraftforge.registries.ForgeRegistries;

// CORRECT - NeoForge
import net.minecraft.core.registries.BuiltInRegistries;
```

Update registry reference:
```java
// WRONG
DeferredRegister.create(ForgeRegistries.ITEMS, MODID)

// CORRECT
DeferredRegister.create(BuiltInRegistries.ITEM, MODID)
```

## Error 2: "incompatible types: Supplier<Item> cannot be converted to RegistryObject"

Symptom:
```
[ERROR] incompatible types: required Supplier<Item>
        found RegistryObject<Item>
```

Cause: Mixing Forge and NeoForge return types

Solution:
```java
// WRONG - Forge return type
public static final RegistryObject<Item> RUBY =
    ITEMS.register("ruby", () -> new Item(...));

// CORRECT - NeoForge return type
public static final Supplier<Item> RUBY =
    ITEMS.register("ruby", () -> new Item(...));
```

## Error 3: build.gradle Dependency Error

Symptom:
```
Could not find net.minecraftforge:forge:1.20.1
```

Cause: Using Forge coordinates in NeoForge project

Solution:
```groovy
// WRONG
minecraft 'net.minecraftforge:forge:1.20.1-47.1.0'

// CORRECT
implementation "net.neoforged:neoforge:${neo_version}"
```

Update gradle.properties:
```properties
neo_version=1.20.1-20240408.170117
```

## Error 4: BuiltInRegistries Not Recognized

Symptom:
```
cannot find symbol: variable BuiltInRegistries
```

Cause: Missing minecraft core registry import

Solution:
```java
// Add this import
import net.minecraft.core.registries.BuiltInRegistries;
```

Also check build.gradle has neoforge dependency:
```groovy
dependencies {
    implementation "net.neoforged:neoforge:${neo_version}"
}
```

## Error 5: Registry Entry Not Present

Symptom:
```
IllegalStateException: Registry entry not filled in
```

Cause: Same as Forge - accessing .get() before registration

Solution:
```java
// WRONG
public static final Item RUBY = ModItems.RUBY.get();

// CORRECT
public static Item getRuby() {
    return ModItems.RUBY.get();
}
```

Or use in event:
```java
modEventBus.addListener(event -> {
    event.enqueueWork(() -> {
        Item ruby = ModItems.RUBY.get();
    });
});
```

## Error 6: Missing Texture/Model

Symptom:
```
Item appears as purple/black checkerboard
```

Solution: Same as Forge - create model and texture files

Check files exist:
```
src/main/resources/assets/mymod/
├── models/item/
│   └── ruby.json
└── textures/item/
    └── ruby.png
```

Create ruby.json:
```json
{
  "parent": "item/generated",
  "textures": {
    "layer0": "mymod:item/ruby"
  }
}
```

## Migration Checklist

Before migrating, backup your code.

- [ ] Check all imports use net.minecraft or net.neoforged
- [ ] Update ForgeRegistries to BuiltInRegistries
- [ ] Change RegistryObject<T> to Supplier<T>
- [ ] Update build.gradle dependencies
- [ ] Update gradle.properties with neo_version
- [ ] Compile without errors
- [ ] Test game launch
- [ ] Verify items register correctly
- [ ] Check creative tab displays items

## Common NeoForge Differences

| Aspect | Forge | NeoForge |
|--------|-------|----------|
| Registry class | ForgeRegistries | BuiltInRegistries |
| Return type | RegistryObject<T> | Supplier<T> |
| Access method | Both use .get() |
| CreativeModeTab | Builder API (same) |
| Event bus | Both use IEventBus |
| Entity registration | Same pattern |

## Quick Reference

Forge 1.20:
```java
DeferredRegister<Item> = DeferredRegister.create(ForgeRegistries.ITEMS, ID)
Return type: RegistryObject<Item>
```

NeoForge 1.20+:
```java
DeferredRegister<Item> = DeferredRegister.create(BuiltInRegistries.ITEM, ID)
Return type: Supplier<Item>
```

Use this to quickly fix migration issues.
