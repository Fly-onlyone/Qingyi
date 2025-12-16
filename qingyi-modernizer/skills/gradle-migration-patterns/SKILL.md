---
name: gradle-migration-patterns
description: Gradle build system migration patterns for Minecraft mods covering ForgeGradle updates, Loom configuration, NeoGradle adoption, and multi-module project setup. Use when modernizing build systems or troubleshooting Gradle issues.
---

# Gradle Migration Patterns

## Overview

Patterns for migrating and modernizing Gradle build configurations for Minecraft mods.

## ForgeGradle Updates

### ForgeGradle 5 → 6

**build.gradle**:
```gradle
// Old (FG5)
plugins {
    id 'net.minecraftforge.gradle' version '5.1.+'
}

// New (FG6)
plugins {
    id 'net.minecraftforge.gradle' version '[6.0,6.2)'
}
```

**Changes**:
- Mappings format updated
- Run configuration changes

## NeoGradle Adoption

### ForgeGradle → NeoGradle

**build.gradle**:
```gradle
// Old (ForgeGradle)
plugins {
    id 'net.minecraftforge.gradle' version '[6.0,6.2)'
}

minecraft {
    mappings channel: 'official', version: '1.20.1'
}

// New (NeoGradle)
plugins {
    id 'net.neoforged.gradle.userdev' version '7.0.+'
}

minecraft {
    mappings channel: 'official', version: '1.20.1'
}
```

**Dependencies**:
```gradle
// Old
dependencies {
    minecraft "net.minecraftforge:forge:${minecraft_version}-${forge_version}"
}

// New
dependencies {
    implementation "net.neoforged:neoforge:${neo_version}"
}
```

## Fabric Loom Configuration

**build.gradle**:
```gradle
plugins {
    id 'fabric-loom' version '1.5-SNAPSHOT'
}

dependencies {
    minecraft "com.mojang:minecraft:${minecraft_version}"
    mappings "net.fabricmc:yarn:${yarn_mappings}:v2"
    modImplementation "net.fabricmc:fabric-loader:${loader_version}"
    modImplementation "net.fabricmc.fabric-api:fabric-api:${fabric_version}"
}
```

## Multi-Module Setup

**settings.gradle**:
```gradle
rootProject.name = 'mymod'
include 'common', 'forge', 'fabric'
```

**common/build.gradle**:
```gradle
// No Forge/Fabric dependencies
dependencies {
    compileOnly "com.mojang:minecraft:${minecraft_version}"
}
```

**forge/build.gradle**:
```gradle
dependencies {
    implementation project(':common')
    minecraft "net.minecraftforge:forge:${forge_version}"
}
```

See [Build Configuration Examples](./build-examples.md) for complete examples.

## See Also

- [Mod Migration Guide](../mod-migration-guide/SKILL.md)
