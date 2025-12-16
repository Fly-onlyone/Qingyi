# Forge to NeoForge Migration

Detailed guide for migrating from Forge to NeoForge.

## Package Remapping

| Forge (Old) | NeoForge (New) |
|-------------|----------------|
| `net.minecraftforge.common.ForgeHooks` | `net.neoforged.neoforge.common.NeoForge` |
| `net.minecraftforge.event.ForgeEventFactory` | `net.neoforged.neoforge.event.EventHooks` |
| `net.minecraftforge.fml.common.Mod` | `net.neoforged.fml.common.Mod` |
| `net.minecraftforge.api.distmarker.Dist` | `net.neoforged.api.distmarker.Dist` |
| `net.minecraftforge.registries.ForgeRegistries` | `net.neoforged.neoforge.registries.NeoForgeRegistries` |

## API Equivalents

### Capabilities → Data Attachments (1.21+)

**Forge Capabilities (Pre-1.21)**:
```java
player.getCapability(MANA_CAP).ifPresent(mana -> mana.setMana(100));
```

**NeoForge Data Attachments (1.21+)**:
```java
player.setData(MANA_ATTACHMENT, 100);
```

### Configuration

**Forge**: `ForgeConfigSpec`
**NeoForge**: Same API, different package

### Networking

**Forge**: `SimpleChannel`
**NeoForge**: Simplified packet system with `PayloadContext`

## Migration Steps

1. Update `build.gradle` plugin
2. Use IntelliJ "Replace in Path" for package renames
3. Update imports
4. Test thoroughly

## See Also

- [Main Migration Guide](./SKILL.md)
