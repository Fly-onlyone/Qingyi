# Module Structure - Multi-Loader Directory Organization

This guide covers detailed directory layouts, source set organization, and resource file placement for multi-loader Minecraft mod projects.

## Standard Module Layouts

### Common Module

**Purpose**: Platform-agnostic code shared across all loaders

**Structure**:
```
common/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/mod/
│   │   │       ├── items/              (Item classes)
│   │   │       ├── blocks/             (Block classes)
│   │   │       ├── entities/           (Entity classes)
│   │   │       ├── util/               (Utilities)
│   │   │       ├── platform/           (Service interfaces)
│   │   │       └── MyMod.java          (Common init)
│   │   └── resources/
│   │       ├── assets/mymod/
│   │       │   ├── models/             (Shared models)
│   │       │   ├── textures/           (Shared textures)
│   │       │   ├── lang/               (Shared lang files)
│   │       │   └── sounds.json
│   │       └── data/mymod/
│   │           ├── recipes/            (Shared recipes)
│   │           ├── loot_tables/        (Shared loot)
│   │           └── tags/               (Shared tags)
│   └── test/java/                      (Common tests)
└── build.gradle
```

**What belongs here**:
- ✅ Item/Block/Entity class definitions
- ✅ Shared game logic
- ✅ Data models (NBT structures)
- ✅ Utility/helper classes
- ✅ Service interfaces (for platform abstraction)
- ✅ Resources used by all platforms

### Forge Module

**Purpose**: Forge-specific registration and features

**Structure**:
```
forge/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/mod/forge/
│   │   │       ├── MyModForge.java          (Main @Mod class)
│   │   │       ├── ModItemsForge.java       (Item registration)
│   │   │       ├── ModBlocksForge.java      (Block registration)
│   │   │       ├── events/
│   │   │       │   ├── CommonEvents.java    (@SubscribeEvent handlers)
│   │   │       │   └── ClientEvents.java    (Client events)
│   │   │       ├── platform/
│   │   │       │   └── ForgePlatformHelper.java  (Service impl)
│   │   │       └── datagen/                 (Data generation)
│   │   └── resources/
│   │       ├── META-INF/
│   │       │   ├── mods.toml                (Forge metadata)
│   │       │   └── services/                (ServiceLoader registrations)
│   │       ├── assets/mymod/                (Forge-specific assets, if any)
│   │       └── data/mymod/                  (Forge-specific data, if any)
│   └── generated/resources/                 (Datagen output)
└── build.gradle
```

**What belongs here**:
- ✅ @Mod annotated main class
- ✅ DeferredRegister registry code
- ✅ @SubscribeEvent event handlers
- ✅ Forge-specific features (Capabilities, etc.)
- ✅ Platform service implementation
- ✅ Data generation providers

### Fabric Module

**Purpose**: Fabric-specific registration and features

**Structure**:
```
fabric/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/mod/fabric/
│   │   │       ├── MyModFabric.java         (ModInitializer)
│   │   │       ├── MyModFabricClient.java   (ClientModInitializer)
│   │   │       ├── ModItemsFabric.java      (Item registration)
│   │   │       ├── ModBlocksFabric.java     (Block registration)
│   │   │       ├── events/
│   │   │       │   └── CommonEvents.java    (Event registration)
│   │   │       ├── platform/
│   │   │       │   └── FabricPlatformHelper.java  (Service impl)
│   │   │       └── datagen/                 (Data generation)
│   │   └── resources/
│   │       ├── fabric.mod.json              (Fabric metadata)
│   │       ├── META-INF/services/           (ServiceLoader registrations)
│   │       ├── assets/mymod/                (Fabric-specific assets, if any)
│   │       └── data/mymod/                  (Fabric-specific data, if any)
│   ├── client/
│   │   └── java/                            (Client-only code)
│   └── generated/resources/                 (Datagen output)
└── build.gradle
```

**What belongs here**:
- ✅ ModInitializer implementation
- ✅ Registry.register registry code
- ✅ Fabric event registration
- ✅ Fabric-specific features (Fabric API)
- ✅ Platform service implementation
- ✅ Client-only code (in client/ source set)

## Source Set Organization

### Forge Source Sets

**Standard Forge**:
```
src/main/java/         Both client and server
src/main/resources/    Assets and data
```

**Custom source sets** (optional):
```
src/main/java/         Common code
src/client/java/       Client-only (@OnlyIn(Dist.CLIENT))
src/server/java/       Server-only (rare)
```

### Fabric Source Sets

**Standard Fabric**:
```
src/main/java/         Common code
src/main/resources/    Assets and data
```

**Fabric with client source set** (recommended):
```
src/main/java/         Common code (both sides)
src/client/java/       Client-only code
src/main/resources/    Shared resources
src/client/resources/  Client-only resources
```

### Common Module Source Sets

**Always**:
```
src/main/java/         Platform-agnostic code
src/main/resources/    Shared resources
```

**Testing**:
```
src/test/java/         Unit tests
src/test/resources/    Test resources
```

## Resource File Organization

### Shared Resources (Common)

**Principle**: Put resources in common/ if used by ALL platforms

**Examples**:
```
common/src/main/resources/
├── assets/mymod/
│   ├── models/
│   │   ├── item/
│   │   │   └── ruby_sword.json      ✅ All platforms use same model
│   │   └── block/
│   │       └── ruby_block.json
│   ├── textures/
│   │   ├── item/
│   │   │   └── ruby_sword.png       ✅ All platforms use same texture
│   │   └── block/
│   │       └── ruby_block.png
│   └── lang/
│       └── en_us.json                ✅ All platforms use same translations
└── data/mymod/
    ├── recipes/
    │   └── ruby_sword.json           ✅ All platforms use same recipes
    └── loot_tables/
        └── blocks/ruby_block.json
```

### Platform-Specific Resources

**Principle**: Put resources in forge/fabric if platform-specific

**Forge-specific example**:
```
forge/src/main/resources/
├── META-INF/
│   └── mods.toml                     ✅ Forge metadata
└── assets/mymod/
    └── forge_specific_texture.png    ✅ Only used on Forge
```

**Fabric-specific example**:
```
fabric/src/main/resources/
├── fabric.mod.json                   ✅ Fabric metadata
└── assets/mymod/
    └── fabric_specific_model.json    ✅ Only used on Fabric
```

### Resource Override Pattern

**Common has default**, **platform overrides**:

```
common/src/main/resources/assets/mymod/models/item/custom_item.json
→ Default model (works on both)

forge/src/main/resources/assets/mymod/models/item/custom_item.json
→ Forge-specific override (used instead of common on Forge)

fabric/src/main/resources/assets/mymod/models/item/custom_item.json
→ Fabric-specific override (used instead of common on Fabric)
```

**Build system merges resources**, platform-specific takes precedence.

## Build Script Structure

### Root build.gradle

**Purpose**: Common configuration for all modules

```groovy
// root build.gradle
plugins {
    id 'java'
}

subprojects {
    apply plugin: 'java'

    java {
        toolchain.languageVersion = JavaLanguageVersion.of(17)
    }

    tasks.withType(JavaCompile).configureEach {
        options.encoding = 'UTF-8'
        options.release = 17
    }
}
```

### Common Module build.gradle

**Purpose**: Common dependencies and configuration

```groovy
// common/build.gradle
plugins {
    id 'java-library'
}

dependencies {
    // Minecraft (compileOnly, provided by platform modules)
    compileOnly "com.mojang:minecraft:${minecraft_version}"

    // Common dependencies (available to all modules)
    implementation 'com.google.code.findbugs:jsr305:3.0.2'
}
```

### Forge Module build.gradle

**Purpose**: Forge-specific build configuration

```groovy
// forge/build.gradle
plugins {
    id 'net.minecraftforge.gradle' version '6.0.+'
}

dependencies {
    // Forge
    minecraft "net.minecraftforge:forge:${minecraft_version}-${forge_version}"

    // Common module (compile against, include in JAR)
    implementation project(':common')
}

minecraft {
    mappings channel: 'official', version: minecraft_version
}
```

### Fabric Module build.gradle

**Purpose**: Fabric-specific build configuration

```groovy
// fabric/build.gradle
plugins {
    id 'fabric-loom' version '1.5-SNAPSHOT'
}

dependencies {
    // Fabric
    minecraft "com.mojang:minecraft:${minecraft_version}"
    mappings loom.officialMojangMappings()
    modImplementation "net.fabricmc:fabric-loader:${fabric_loader_version}"
    modImplementation "net.fabricmc.fabric-api:fabric-api:${fabric_api_version}"

    // Common module
    implementation project(':common')
}
```

### settings.gradle

**Purpose**: Define multi-module structure

```groovy
// settings.gradle
rootProject.name = 'MyMod'

include 'common'
include 'forge'
include 'fabric'
```

## Package Structure Conventions

### Recommended Package Layout

```
com.mod/
├── MyMod.java                  (Main common class)
├── items/
│   ├── ModItems.java           (Item holder class)
│   ├── RubySword.java          (Custom item class)
│   └── custom/                 (Custom item types)
├── blocks/
│   ├── ModBlocks.java          (Block holder class)
│   └── RubyBlock.java          (Custom block class)
├── entities/
│   └── RubyGolemEntity.java    (Entity classes)
├── blockentities/
│   └── RubyFurnaceBlockEntity.java
├── platform/
│   └── PlatformHelper.java     (Service interface)
├── util/
│   └── Helper.java             (Utilities)
└── network/                    (Networking, if needed)
```

### Platform Module Packages

**Forge**:
```
com.mod.forge/
├── MyModForge.java             (Main @Mod class)
├── ModItemsForge.java          (Registry)
├── ModBlocksForge.java         (Registry)
├── events/
│   ├── CommonEvents.java       (@SubscribeEvent)
│   └── ClientEvents.java
├── platform/
│   └── ForgePlatformHelper.java
└── datagen/                    (Data generation)
```

**Fabric**:
```
com.mod.fabric/
├── MyModFabric.java            (ModInitializer)
├── MyModFabricClient.java      (ClientModInitializer)
├── ModItemsFabric.java         (Registry)
├── ModBlocksFabric.java        (Registry)
├── events/
│   └── CommonEvents.java       (Event registration)
└── platform/
    └── FabricPlatformHelper.java
```

## Real-World Example: Complete Structure

**Example Mod**: "RubyMod" (adds ruby ore, ingot, tools)

```
RubyMod/
├── common/
│   ├── src/main/java/com/rubymod/
│   │   ├── RubyMod.java
│   │   ├── items/
│   │   │   ├── ModItems.java           (References to items)
│   │   │   └── RubySword.java          (Item class)
│   │   ├── blocks/
│   │   │   ├── ModBlocks.java          (References to blocks)
│   │   │   └── RubyBlock.java          (Block class)
│   │   └── platform/
│   │       └── PlatformHelper.java     (Service interface)
│   ├── src/main/resources/
│   │   ├── assets/rubymod/
│   │   │   ├── models/item/ruby_sword.json
│   │   │   ├── textures/item/ruby_sword.png
│   │   │   └── lang/en_us.json
│   │   └── data/rubymod/
│   │       └── recipes/ruby_sword.json
│   └── build.gradle
│
├── forge/
│   ├── src/main/java/com/rubymod/forge/
│   │   ├── RubyModForge.java
│   │   ├── ModItemsForge.java          (DeferredRegister)
│   │   ├── ModBlocksForge.java
│   │   └── platform/
│   │       └── ForgePlatformHelper.java
│   ├── src/main/resources/
│   │   └── META-INF/
│   │       ├── mods.toml
│   │       └── services/
│   │           └── com.rubymod.platform.PlatformHelper
│   └── build.gradle
│
├── fabric/
│   ├── src/main/java/com/rubymod/fabric/
│   │   ├── RubyModFabric.java
│   │   ├── ModItemsFabric.java         (Registry.register)
│   │   ├── ModBlocksFabric.java
│   │   └── platform/
│   │       └── FabricPlatformHelper.java
│   ├── src/main/resources/
│   │   ├── fabric.mod.json
│   │   └── META-INF/services/
│   │       └── com.rubymod.platform.PlatformHelper
│   └── build.gradle
│
├── build.gradle                        (Root build file)
├── settings.gradle                     (include 'common', 'forge', 'fabric')
└── gradle.properties                   (Versions)
```

## Summary

**Module Purposes**:
- **common/**: Shared code and resources (platform-agnostic)
- **forge/**: Forge registration, events, platform impl
- **fabric/**: Fabric registration, events, platform impl

**Resource Placement**:
- Shared: common/src/main/resources/
- Platform-specific: forge/ or fabric/ resources/
- Platform can override common resources

**Build Structure**:
- Root build.gradle: Common configuration
- Module build.gradle: Platform-specific setup
- settings.gradle: Define modules

**Package Convention**:
- Common: com.mod.items/, com.mod.blocks/, com.mod.platform/
- Forge: com.mod.forge/ (registration + events)
- Fabric: com.mod.fabric/ (registration + events)

For platform abstraction patterns, see [Platform Abstraction](./platform-abstraction.md).

For build configuration details, see [Gradle Configuration](./gradle-configuration.md).
