---
name: mod-migration-guide
description: Comprehensive migration strategies for Minecraft mods including version upgrades (1.19→1.20→1.21), framework migrations (Forge→NeoForge), and multi-loader conversions (monolithic→multi-loader). Covers strangler fig patterns, backward compatibility, and testing strategies.
---

# Mod Migration Guide

## Overview

This skill provides safe, incremental migration strategies for Minecraft mods using the Strangler Fig pattern to minimize risk and maintain backward compatibility.

## When to Use This Skill

- Upgrading mod to new Minecraft version (e.g., 1.20→1.21)
- Migrating framework (Forge→NeoForge)
- Converting to multi-loader architecture
- Planning safe modernization strategies

## Migration Type 1: Minecraft Version Upgrade

### Example: 1.20.1 → 1.21.3

**Phase 1: Dependency Update**
```properties
# gradle.properties
minecraft_version=1.21.3  # ← Update version
forge_version=51.0.0      # ← Compatible Forge version
```

**Phase 2: API Breaking Changes**

Common 1.20→1.21 changes:
- `CreativeModeTab` enum → `CreativeModeTabs` builder
- Capabilities → Data Attachments (NeoForge)
- Item/Block properties changes

**Strangler Fig Pattern**:
```java
// Keep old code working temporarily
@Deprecated(forRemoval = true, since = "2.0.0")
public static void registerLegacyCapabilities() {
    // Old Capability code (1.20)
}

// Add new code alongside
public static void registerDataAttachments() {
    // New Data Attachment code (1.21)
}

// Transitional: Support both
static {
    if (MC_VERSION.startsWith("1.20")) {
        registerLegacyCapabilities();
    } else {
        registerDataAttachments();
    }
}
```

**Phase 3: Resource File Updates**
- Model JSON version updates
- Texture compatibility checks
- Update lang keys if changed

**Phase 4: Testing**
- Test in-game functionality
- **Verify world loading** (backward compatibility!)
- Check multiplayer sync

**Rollback Plan**: Keep 1.20 branch, use Git tags

For detailed breaking changes, see [Minecraft Version Migrations](./minecraft-version-migrations.md)

---

## Migration Type 2: Forge → NeoForge

### Example: Forge 1.20.1 → NeoForge 1.20.4

**Phase 1: Gradle Build Migration**
```gradle
// Old: build.gradle (Forge)
plugins {
    id 'net.minecraftforge.gradle' version '[6.0,6.2)'
}

// New: build.gradle (NeoForge)
plugins {
    id 'net.neoforged.gradle.userdev' version '7.0.+'
}
```

**Phase 2: Package Renames** (Use IntelliJ Refactoring!)
```
net.minecraftforge → net.neoforged
```

**IntelliJ Refactoring**:
1. Right-click package → Refactor → Rename
2. Check "Search in comments and strings"
3. Preview changes before applying

**Phase 3: API Modernization**

**Capabilities → Components** (NeoForge 1.21+):
```java
// Old (Forge 1.20): Capabilities
player.getCapability(MANA_CAP).ifPresent(mana -> {
    mana.setMana(100);
});

// New (NeoForge 1.21): Data Attachments
int mana = player.getData(MANA_ATTACHMENT);
player.setData(MANA_ATTACHMENT, 100);
```

**Compatibility Layer** (Strangler Fig):
```java
// Wrapper for smooth transition
public class ManaHelper {
    public static int getMana(Player player) {
        if (isNeoForge1_21()) {
            return player.getData(MANA_ATTACHMENT);
        } else {
            return player.getCapability(MANA_CAP).map(IMana::getMana).orElse(0);
        }
    }
}
```

**Phase 4: Remove Forge Dependencies**
- Update imports
- Remove compatibility wrappers
- Update documentation

For detailed migration steps, see [Forge to NeoForge Migration](./forge-to-neoforge.md)

---

## Migration Type 3: Monolithic → Multi-Loader

### Goal: Support both Forge and Fabric from single codebase

**Phase 1: Project Restructure**
```
Before (Monolithic):
mymod/
└── src/main/java/

After (Multi-Loader):
mymod/
├── common/          # Platform-agnostic code
├── forge/           # Forge-specific loader
└── fabric/          # Fabric-specific loader
```

**Phase 2: Extract Common Code**

Move to `common/`:
- Items, blocks (properties only)
- NBT serialization
- Data models
- Utility classes

**Keep in platform modules**:
- Registry code (DeferredRegister vs Registry.register)
- Event handlers (@SubscribeEvent vs Callbacks)
- Platform-specific APIs

**Phase 3: Platform Abstraction**
```java
// common/ module
public interface PlatformHelper {
    ResourceLocation createRL(String namespace, String path);
    boolean isClientSide(Level level);
}

// forge/ module
@ExpectPlatform
public class PlatformHelperImpl implements PlatformHelper {
    public ResourceLocation createRL(String namespace, String path) {
        return new ResourceLocation(namespace, path);
    }
}

// fabric/ module
@ExpectPlatform
public class PlatformHelperImpl implements PlatformHelper {
    public ResourceLocation createRL(String namespace, String path) {
        return new Identifier(namespace, path);
    }
}
```

**Phase 4: Dual Registration**
```java
// common/ - Item definitions (no registration)
public class ModContent {
    public static Item RUBY;

    public static void register() {
        // Platform loaders call this
    }
}

// forge/ - Forge registration
public class ForgeRegistry {
    private static final DeferredRegister<Item> ITEMS = ...;

    public static void register() {
        ITEMS.register("ruby", () -> ModContent.RUBY = new Item(...));
    }
}

// fabric/ - Fabric registration
public class FabricRegistry {
    public static void register() {
        ModContent.RUBY = Registry.register(Registries.ITEM, ...);
    }
}
```

**Phase 5: Testing**
- Test Forge version independently
- Test Fabric version independently
- **Verify feature parity** between loaders

For detailed multi-loader patterns, see [Multi-Loader Conversion Guide](./multi-loader-conversion.md)

---

## Backward Compatibility Rules

### World Compatibility (CRITICAL)

✅ **Safe**:
- Adding new items/blocks
- Adding new NBT fields (with defaults)
- Adding new config options

❌ **BREAKS WORLDS**:
- Changing registry names (items turn to AIR)
- Removing NBT fields without migration
- Changing block IDs

**Migration Path for Breaking Changes**:
```java
// Use MissingMappingsEvent to remap old → new
@SubscribeEvent
public static void onMissingMappings(MissingMappingsEvent event) {
    event.getMappings(ForgeRegistries.ITEMS, MODID).forEach(mapping -> {
        if (mapping.getKey().equals(new ResourceLocation(MODID, "old_item_name"))) {
            mapping.remap(ModItems.NEW_ITEM.get());  // ← Preserve items
        }
    });
}
```

### Config Compatibility

✅ **Safe**:
- Adding new config values (with defaults)
- Deprecating old values (still read them)

❌ **BREAKS CONFIGS**:
- Removing config values without migration
- Changing config value types

**Migration Strategy**: Read old format, write new format

### API Compatibility

**For mods with public API**:
- **MAJOR version**: Breaking changes (update dependent mods)
- **MINOR version**: New features (backward compatible)
- **PATCH version**: Bug fixes (fully compatible)

---

## Strangler Fig Pattern

**Philosophy**: Gradually replace old code with new, running both simultaneously during transition

**Steps**:
1. **Add new implementation** alongside old
2. **Route traffic** to new implementation
3. **Monitor** for issues
4. **Remove old implementation** when confident

**Example**:
```java
// Step 1: Old code still works
public void processOldWay(Data data) {
    // Legacy implementation
}

// Step 2: Add new code
public void processNewWay(Data data) {
    // Modern implementation
}

// Step 3: Route based on flag
public void process(Data data) {
    if (USE_NEW_SYSTEM) {
        processNewWay(data);
    } else {
        processOldWay(data);
    }
}

// Step 4: Eventually remove processOldWay() when confident
```

---

## Testing Strategy

### Unit Tests

```java
@Test
public void testMigrationPreservesData() {
    // Given: Old format data
    OldData oldData = new OldData("value");

    // When: Migrate to new format
    NewData newData = MigrationHelper.migrate(oldData);

    // Then: Data preserved
    assertEquals("value", newData.getValue());
}
```

### Integration Tests

1. **Test old world loading**:
   - Load world created in old version
   - Verify all items/blocks present
   - Verify no data loss

2. **Test new world creation**:
   - Create world in new version
   - Verify new features work
   - Verify backward compatibility maintained

3. **Test multiplayer**:
   - Server on new version
   - Client on new version
   - Verify sync works

---

## Migration Checklist

- [ ] Gradle dependencies updated
- [ ] Code compiles without errors
- [ ] All deprecation warnings addressed
- [ ] Breaking API changes handled
- [ ] Resource files updated
- [ ] MissingMappingsEvent for renamed items
- [ ] NBT migration for changed formats
- [ ] Config migration for changed values
- [ ] Old worlds load correctly
- [ ] New worlds create correctly
- [ ] Multiplayer tested
- [ ] Rollback plan documented

---

## See Also

- [Forge to NeoForge Migration](./forge-to-neoforge.md) - Detailed package remapping
- [Minecraft Version Migrations](./minecraft-version-migrations.md) - Version-specific changes
- [Multi-Loader Conversion](./multi-loader-conversion.md) - Common/platform architecture
- [Gradle Migration Patterns](../gradle-migration-patterns/SKILL.md) - Build system updates
