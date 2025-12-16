# Package Structure Examples

Real-world package structures from Minecraft mods.

## Example 1: MusicMod (Forge 1.20.1)

```
com.example.musicmod/
├── MusicMod.java                    # Main mod class (@Mod annotation)
├── registry/
│   ├── ModItems.java                # DeferredRegister for items
│   ├── ModSounds.java               # DeferredRegister for sounds
│   └── ModCreativeTabs.java         # Creative tab registration
├── items/
│   └── MusicDiscItem.java           # Custom music disc implementation
├── service/
│   ├── MusicService.java            # Singleton managing music playback (Facade pattern)
│   ├── AudioManager.java            # OpenAL audio backend
│   └── MusicProgressTracker.java    # O(1) HashMap tracking player progress
├── events/
│   ├── PlayerEvents.java            # Player join/leave, data loading
│   └── ClientEvents.java            # Client tick for audio updates (@OnlyIn(Dist.CLIENT))
├── data/
│   ├── PlayerMusicData.java         # NBT serialization for player progress
│   └── MusicSavedData.java          # World-level SavedData
├── client/
│   ├── gui/
│   │   ├── AdvancementScreen.java   # Custom UI for music advancement
│   │   └── MusicHudOverlay.java     # HUD overlay for now playing
│   └── audio/
│       └── OpenALHelper.java        # Client-only OpenAL wrapper
├── network/
│   ├── ModNetwork.java              # SimpleChannel registration
│   └── packets/
│       ├── MusicSyncPacket.java     # Server→Client progress sync
│       └── MusicControlPacket.java  # Client→Server playback control
└── util/
    └── MusicResourceHelper.java     # Resource location utilities
```

**Key Decisions**:
- **registry/** - Centralized registration (DDD Aggregate Root pattern)
- **service/** - Business logic layer (Singleton + Facade)
- **events/** - Separated by client/common
- **client/** - All client-only code isolated (prevents server crashes)
- **network/** - Packets organized by direction

---

## Example 2: Apocalypse_TNT (NeoForge 1.21.3)

```
com.example.apocalypse/
├── ApocalypseMod.java               # Main mod class
├── registry/
│   ├── ModEntities.java             # DeferredRegister for entities
│   └── ModSounds.java               # DeferredRegister for sounds
├── apocalypse/
│   ├── ApocalypseManager.java       # Singleton managing apocalypse state
│   ├── actions/
│   │   ├── DisasterAction.java      # Strategy pattern interface
│   │   ├── TntSpawnAction.java      # TNT rain disaster
│   │   ├── LightningAction.java     # Lightning storm disaster
│   │   └── MobSpawnAction.java      # Mob horde disaster
│   └── countdown/
│       └── CountdownTimer.java      # Boss bar countdown logic
├── events/
│   ├── ApocalypseEvents.java        # Server tick, entity spawn events
│   └── ClientEvents.java            # Boss bar rendering (@OnlyIn(Dist.CLIENT))
├── data/
│   └── ApocalypseSavedData.java     # World-level state (current wave, active status)
├── client/
│   └── renderer/
│       └── BossBarRenderer.java     # Custom boss bar rendering
└── config/
    └── ApocalypseConfig.java        # ForgeConfigSpec configuration
```

**Key Decisions**:
- **apocalypse/actions/** - Strategy pattern for extensible disasters
- **apocalypse/countdown/** - Isolated countdown logic
- **data/** - Per-world state in SavedData (not static!)
- **config/** - Centralized configuration

---

## Pattern: Feature-Based Organization (Large Mods)

For mods with many features, organize by feature:

```
com.example.largemod/
├── LargeMod.java
├── registry/
│   ├── ModItems.java                # All items
│   ├── ModBlocks.java               # All blocks
│   └── ModEntities.java             # All entities
├── features/
│   ├── magic/
│   │   ├── ManaSystem.java
│   │   ├── SpellRegistry.java
│   │   ├── items/
│   │   │   ├── WandItem.java
│   │   │   └── StaffItem.java
│   │   ├── events/
│   │   │   └── MagicEvents.java
│   │   └── gui/
│   │       └── SpellbookScreen.java
│   ├── farming/
│   │   ├── CropSystem.java
│   │   ├── blocks/
│   │   │   └── CustomCropBlock.java
│   │   └── items/
│   │       └── SeedItem.java
│   └── combat/
│       ├── WeaponSystem.java
│       └── items/
│           ├── BattleAxeItem.java
│           └── CrossbowItem.java
├── core/
│   ├── events/
│   │   └── CoreEvents.java          # Cross-feature events
│   └── util/
│       └── MathHelper.java          # Shared utilities
└── client/
    └── ClientSetup.java             # Client-only initialization
```

**Benefits**:
- Each feature is self-contained
- Easy to disable features for debugging
- Clear boundaries between systems
- Scales to hundreds of classes

---

## Pattern: Multi-Module (Multi-Loader)

For mods supporting multiple loaders:

```
mymod/
├── common/                          # Platform-agnostic
│   ├── com.example.mymod/
│   │   ├── ModContent.java          # Item/block definitions (no registration)
│   │   ├── logic/
│   │   │   └── GameLogic.java       # Game logic
│   │   ├── data/
│   │   │   └── CustomData.java      # Data models
│   │   └── platform/
│   │       └── PlatformHelper.java  # @ExpectPlatform methods
│   └── resources/
│       └── assets/mymod/            # Shared resources
├── forge/                           # Forge-specific
│   ├── com.example.mymod.forge/
│   │   ├── ModForge.java            # Forge entry point
│   │   ├── platform/
│   │   │   └── PlatformHelperImpl.java
│   │   └── registry/
│   │       └── ForgeRegistry.java   # DeferredRegister
│   └── resources/
│       └── META-INF/mods.toml
└── fabric/                          # Fabric-specific
    ├── com.example.mymod.fabric/
    │   ├── ModFabric.java           # Fabric entry point
    │   ├── platform/
    │   │   └── PlatformHelperImpl.java
    │   └── registry/
    │       └── FabricRegistry.java  # Registry.register
    └── resources/
        └── fabric.mod.json
```

**Key**: Common module has no platform dependencies, loaders implement platform-specific code.

---

## Anti-Pattern: Type-Based Organization

❌ **Don't organize purely by type**:

```
com.example.mymod/
├── items/                           # 50+ item classes
│   ├── Item1.java
│   ├── Item2.java
│   └── ... (50 more)
├── blocks/                          # 30+ block classes
│   ├── Block1.java
│   ├── Block2.java
│   └── ... (30 more)
└── events/                          # All events together
    ├── Event1.java
    ├── Event2.java
    └── ... (20 more)
```

**Problems**:
- Packages become huge
- Hard to find related code
- No clear feature boundaries
- Difficult to disable features

---

## Best Practices Summary

1. **Centralize Registration**: All DeferredRegister in `registry/` package
2. **Isolate Client Code**: All client imports in `client/` package with @OnlyIn
3. **Feature-Based for Scale**: Group by feature, not type, for large mods
4. **Services for Complexity**: Use `service/` for complex business logic
5. **Separate Events**: Split client/common/server events into different classes

---

## See Also

- [Main Architecture Patterns](./SKILL.md)
- [Client-Server Separation Guide](./client-server-separation.md)
