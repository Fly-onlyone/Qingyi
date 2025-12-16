# Dependency Reference - Framework Dependency Patterns and Version Extraction

Comprehensive reference for identifying and parsing Minecraft modding framework dependencies across Forge, NeoForge, Fabric, and Quilt.

## Overview

This guide provides detailed patterns for extracting version information from project dependencies, mapping dependency strings to framework details, and identifying optional/integration dependencies.

---

## Dependency Format Overview

### Standard Maven Coordinate Format

```
group:artifact:version
```

Example:
```
net.minecraftforge:forge:1.20.1-47.1.0
     ↑              ↑         ↑
   Group        Artifact   Version
```

### Extended Format with Classifiers

```
group:artifact:version:classifier
```

Example:
```
mezz.jei:jei-1.20.1-forge:15.2.0.27:api
                                    ↑
                                Classifier
```

---

## Forge Dependencies

### Forge Dependency Format

#### Standard Forge Dependency
```
net.minecraftforge:forge:1.20.1-47.1.0
```

**Parsing**:
```
Group: net.minecraftforge
Artifact: forge
Version: 1.20.1-47.1.0

Components:
- MC Version: 1.20.1 (before hyphen)
- Forge Version: 47.1.0 (after hyphen)
```

#### Version Extraction Algorithm
```
version_string = "1.20.1-47.1.0"
parts = version_string.split("-")

mc_version = parts[0]          # "1.20.1"
forge_version = parts[1]       # "47.1.0"
```

### Forge Version History

#### Forge 1.20.x
```
MC 1.20.1 → Forge 47.x.x
MC 1.20.2 → Forge 48.x.x
MC 1.20.4 → Forge 49.x.x
MC 1.20.6 → Forge 50.x.x

Example: net.minecraftforge:forge:1.20.1-47.1.0
```

#### Forge 1.19.x
```
MC 1.19.2 → Forge 43.x.x
MC 1.19.3 → Forge 44.x.x
MC 1.19.4 → Forge 45.x.x

Example: net.minecraftforge:forge:1.19.2-43.2.0
```

#### Forge 1.18.x
```
MC 1.18.2 → Forge 40.x.x

Example: net.minecraftforge:forge:1.18.2-40.1.0
```

### Forge-Related Dependencies

#### ForgeGradle Plugin
```gradle
// build.gradle
plugins {
    id 'net.minecraftforge.gradle' version '6.0.24'
}
```

**Version Mapping**:
```
ForgeGradle 6.x → MC 1.20.x
ForgeGradle 5.x → MC 1.18.x - 1.19.x
ForgeGradle 4.x → MC 1.16.x - 1.17.x
```

#### Minecraft Forge MDK
```
net.minecraft:joined:1.20.1
```

This is the Minecraft dependency, not the loader.

---

## NeoForge Dependencies

### NeoForge Dependency Format

#### Standard NeoForge Dependency
```
net.neoforged:neoforge:20.4.60-beta
```

**Parsing**:
```
Group: net.neoforged
Artifact: neoforge
Version: 20.4.60-beta

Components:
- Version Prefix: 20.4 → Maps to MC 1.20.4
- NeoForge Build: 60
- Stability: beta
```

#### Version Extraction Algorithm
```
version_string = "20.4.60-beta"
parts = version_string.split(".")

major = parts[0]              # "20"
minor = parts[1]              # "4"
mc_version = "1." + major + "." + minor  # "1.20.4"

build_parts = parts[2].split("-")
build = build_parts[0]        # "60"
stability = build_parts[1] if len(build_parts) > 1 else "release"  # "beta"
```

### NeoForge Version Mapping

#### MC Version from NeoForge Version
```
NeoForge 20.1.x → MC 1.20.1
NeoForge 20.2.x → MC 1.20.2
NeoForge 20.4.x → MC 1.20.4
NeoForge 20.6.x → MC 1.20.6
NeoForge 21.0.x → MC 1.21.0
NeoForge 21.1.x → MC 1.21.1
NeoForge 21.3.x → MC 1.21.3

Pattern: X.Y.z → MC 1.X.Y
```

#### NeoForge Version Stability
```
20.4.60-beta → Beta build
20.4.60 → Release build
21.1.0-snapshot → Snapshot build
```

### NeoForge-Related Dependencies

#### NeoGradle Plugin
```gradle
// build.gradle
plugins {
    id 'net.neoforged.gradle.userdev' version '7.0.142'
}
```

**Version Mapping**:
```
NeoGradle 7.x → MC 1.20.4+
NeoGradle 6.x → MC 1.20.2
```

#### NeoForm
```
net.neoforged:neoform:1.20.4
```

This provides the Minecraft mappings for NeoForge.

---

## Fabric Dependencies

### Fabric Dependency Format

#### Fabric Loader
```
net.fabricmc:fabric-loader:0.15.0
```

**Parsing**:
```
Group: net.fabricmc
Artifact: fabric-loader
Version: 0.15.0

Note: Loader version does NOT indicate MC version
```

#### Fabric API
```
net.fabricmc.fabric-api:fabric-api:0.92.0+1.20.1
```

**Parsing**:
```
Group: net.fabricmc.fabric-api
Artifact: fabric-api
Version: 0.92.0+1.20.1

Components:
- API Version: 0.92.0 (before +)
- MC Version: 1.20.1 (after +)
```

#### Version Extraction Algorithm
```
# Fabric Loader
loader_version = "0.15.0"
# No MC version info, must check elsewhere

# Fabric API
api_version = "0.92.0+1.20.1"
parts = api_version.split("+")

api_ver = parts[0]            # "0.92.0"
mc_version = parts[1]         # "1.20.1"
```

### Fabric Version History

#### Fabric API Versions
```
MC 1.20.1 → Fabric API 0.83.0 - 0.92.0
MC 1.20.2 → Fabric API 0.89.0 - 0.91.0
MC 1.20.4 → Fabric API 0.95.0+
MC 1.21.1 → Fabric API 0.100.0+

Example: net.fabricmc.fabric-api:fabric-api:0.92.0+1.20.1
```

#### Fabric Loader Versions
```
Fabric Loader 0.15.x → MC 1.20.x - 1.21.x
Fabric Loader 0.14.x → MC 1.19.x - 1.20.x

Note: Fabric Loader is backward-compatible across many MC versions
```

### Fabric-Related Dependencies

#### Fabric Loom Plugin
```gradle
// build.gradle
plugins {
    id 'fabric-loom' version '1.5-SNAPSHOT'
}
```

**Version Mapping**:
```
Loom 1.5.x → MC 1.20.4+
Loom 1.4.x → MC 1.20.1 - 1.20.2
Loom 1.3.x → MC 1.19.4+
```

#### Yarn Mappings
```
net.fabricmc:yarn:1.20.1+build.10:v2
```

**Parsing**:
```
MC Version: 1.20.1
Build: 10
Mapping Version: v2
```

#### Fabric Language Kotlin
```
net.fabricmc:fabric-language-kotlin:1.10.16+kotlin.1.9.21
```

For Kotlin support in Fabric mods.

---

## Quilt Dependencies

### Quilt Dependency Format

#### Quilt Loader
```
org.quiltmc:quilt-loader:0.23.1
```

**Parsing**:
```
Group: org.quiltmc
Artifact: quilt-loader
Version: 0.23.1
```

#### Quilt Standard Libraries (QSL)
```
org.quiltmc.qsl:core:7.4.0+1.20.1
```

**Parsing**:
```
Group: org.quiltmc.qsl
Artifact: core
Version: 7.4.0+1.20.1

Components:
- QSL Version: 7.4.0
- MC Version: 1.20.1 (after +)
```

### Quilt Version Mapping

```
QSL 7.x + MC 1.20.1 → Quilt Loader 0.23.x
QSL 6.x + MC 1.19.4 → Quilt Loader 0.21.x

Note: Quilt is compatible with Fabric API
```

---

## Integration Dependencies

### JEI (Just Enough Items)

#### Forge JEI
```
mezz.jei:jei-1.20.1-forge:15.2.0.27
```

**Parsing**:
```
Group: mezz.jei
Artifact: jei-1.20.1-forge
Version: 15.2.0.27

MC Version: 1.20.1 (from artifact name)
Loader: forge
JEI Version: 15.2.0.27
```

#### Fabric JEI
```
mezz.jei:jei-1.20.1-fabric:15.2.0.27
```

**Parsing**:
```
Group: mezz.jei
Artifact: jei-1.20.1-fabric
Version: 15.2.0.27

MC Version: 1.20.1 (from artifact name)
Loader: fabric
JEI Version: 15.2.0.27
```

#### Common JEI API
```
mezz.jei:jei-1.20.1-common-api:15.2.0.27
```

Used in multi-loader projects for JEI integration.

---

### REI (Roughly Enough Items)

#### REI Dependency
```
me.shedaniel:RoughlyEnoughItems:12.0.684
```

**Parsing**:
```
Group: me.shedaniel
Artifact: RoughlyEnoughItems
Version: 12.0.684

Note: Fabric/Architectury-based
```

#### REI API
```
me.shedaniel:RoughlyEnoughItems-api:12.0.684
```

For integration without full REI dependency.

---

### EMI (Enough Mod Integration)

```
dev.emi:emi:1.1.0+1.20.1
```

**Parsing**:
```
Group: dev.emi
Artifact: emi
Version: 1.1.0+1.20.1

EMI Version: 1.1.0
MC Version: 1.20.1
```

---

### Kotlin for Forge

```
thedarkcolour:kotlinforforge:4.7.0
```

**Parsing**:
```
Group: thedarkcolour
Artifact: kotlinforforge
Version: 4.7.0

Supports MC 1.20.1 with Forge
```

---

### Patchouli (Documentation Mod)

#### Forge Patchouli
```
vazkii.patchouli:Patchouli:1.20.1-84-FORGE
```

#### Fabric Patchouli
```
vazkii.patchouli:Patchouli:1.20.1-84-FABRIC
```

---

### Curios API (Accessory Slots)

```
top.theillusivec4.curios:curios-forge:5.4.5+1.20.1
```

**Parsing**:
```
Group: top.theillusivec4.curios
Artifact: curios-forge
Version: 5.4.5+1.20.1

Curios Version: 5.4.5
MC Version: 1.20.1
```

---

### Trinkets (Fabric Accessories)

```
dev.emi:trinkets:3.7.2
```

Fabric alternative to Curios.

---

## Mixin Dependencies

### Mixin Library

```
org.spongepowered:mixin:0.8.5
```

**Parsing**:
```
Group: org.spongepowered
Artifact: mixin
Version: 0.8.5

Used for runtime class modification
```

### Mixin Annotation Processor

```
org.spongepowered:mixin:0.8.5:processor
```

Compile-time annotation processing for Mixin.

---

## Architectury Dependencies

### Architectury API

```
dev.architectury:architectury:9.1.12
```

**Parsing**:
```
Group: dev.architectury
Artifact: architectury
Version: 9.1.12

For multi-loader projects
```

### Architectury Forge
```
dev.architectury:architectury-forge:9.1.12
```

### Architectury Fabric
```
dev.architectury:architectury-fabric:9.1.12
```

---

## Dependency Detection Algorithm

### Comprehensive Detection Process

```
function detectFramework(dependencies):
    frameworks = []

    for dep in dependencies:
        group = dep.group
        artifact = dep.artifact
        version = dep.version

        # Forge detection
        if group == "net.minecraftforge" and artifact == "forge":
            mc_ver = version.split("-")[0]
            forge_ver = version.split("-")[1]
            frameworks.append({
                "type": "Forge",
                "mc_version": mc_ver,
                "loader_version": forge_ver
            })

        # NeoForge detection
        elif group == "net.neoforged" and artifact == "neoforge":
            parts = version.split(".")
            mc_ver = "1." + parts[0] + "." + parts[1]
            neo_ver = version
            frameworks.append({
                "type": "NeoForge",
                "mc_version": mc_ver,
                "loader_version": neo_ver
            })

        # Fabric detection
        elif group == "net.fabricmc" and artifact == "fabric-loader":
            loader_ver = version
            # MC version must be extracted from fabric-api
            frameworks.append({
                "type": "Fabric",
                "loader_version": loader_ver,
                "mc_version": null  # To be filled from fabric-api
            })

        # Fabric API detection
        elif group == "net.fabricmc.fabric-api" and artifact == "fabric-api":
            parts = version.split("+")
            api_ver = parts[0]
            mc_ver = parts[1]
            # Update Fabric entry with MC version
            for fw in frameworks:
                if fw["type"] == "Fabric" and fw["mc_version"] is null:
                    fw["mc_version"] = mc_ver

        # Quilt detection
        elif group == "org.quiltmc" and artifact == "quilt-loader":
            loader_ver = version
            frameworks.append({
                "type": "Quilt",
                "loader_version": loader_ver,
                "mc_version": null  # To be filled from QSL
            })

    return frameworks
```

---

## Dependency Report Format

### Single-Loader Report

```markdown
## Dependencies: [Project Name]

**Framework**: Forge
**Minecraft Version**: 1.20.1
**Loader Version**: 47.1.0

### Core Dependencies
- net.minecraftforge:forge:1.20.1-47.1.0

### Optional Dependencies
- mezz.jei:jei-1.20.1-forge:15.2.0.27 (JEI Integration)
- top.theillusivec4.curios:curios-forge:5.4.5+1.20.1 (Curios API)

### Language Support
- None
```

### Multi-Loader Report

```markdown
## Dependencies: [Project Name]

**Project Type**: Multi-Loader
**Minecraft Version**: 1.20.1

### Common Module
- dev.architectury:architectury:9.1.12 (Architectury API)

### Forge Module
- net.minecraftforge:forge:1.20.1-47.1.0
- dev.architectury:architectury-forge:9.1.12

### Fabric Module
- net.fabricmc:fabric-loader:0.15.0
- net.fabricmc.fabric-api:fabric-api:0.92.0+1.20.1
- dev.architectury:architectury-fabric:9.1.12

### Integration Dependencies
- mezz.jei:jei-1.20.1-common-api:15.2.0.27 (JEI - Common)
- mezz.jei:jei-1.20.1-forge:15.2.0.27 (JEI - Forge)
- mezz.jei:jei-1.20.1-fabric:15.2.0.27 (JEI - Fabric)
```

---

## Version Compatibility Matrix

### Forge Compatibility
```
MC Version | Forge Version Range | Java Version
-----------|--------------------|--------------
1.20.1     | 47.x.x            | Java 17
1.20.2     | 48.x.x            | Java 17
1.20.4     | 49.x.x            | Java 17
1.20.6     | 50.x.x            | Java 21
1.21.1     | 52.x.x            | Java 21
```

### NeoForge Compatibility
```
MC Version | NeoForge Version Range | Java Version
-----------|----------------------|-------------
1.20.1     | 20.1.x              | Java 17
1.20.4     | 20.4.x              | Java 17
1.21.1     | 21.1.x              | Java 21
```

### Fabric Compatibility
```
MC Version | Fabric Loader | Fabric API    | Java Version
-----------|--------------|---------------|-------------
1.20.1     | 0.14.x+      | 0.83.0+       | Java 17
1.20.4     | 0.15.x+      | 0.95.0+       | Java 17
1.21.1     | 0.15.x+      | 0.100.0+      | Java 21
```

---

## Dependency Extraction Examples

### Example 1: Extract Forge Information

**Input**:
```
dependencies {
    minecraft 'net.minecraftforge:forge:1.20.1-47.1.0'
}
```

**Extraction**:
```
Dependency: net.minecraftforge:forge:1.20.1-47.1.0

Framework: Forge
MC Version: 1.20.1
Forge Version: 47.1.0
Java: 17 (from MC version mapping)
```

### Example 2: Extract Fabric Information

**Input**:
```
dependencies {
    minecraft "com.mojang:minecraft:1.20.1"
    mappings "net.fabricmc:yarn:1.20.1+build.10:v2"
    modImplementation "net.fabricmc:fabric-loader:0.15.0"
    modImplementation "net.fabricmc.fabric-api:fabric-api:0.92.0+1.20.1"
}
```

**Extraction**:
```
Dependency 1: net.fabricmc:fabric-loader:0.15.0
Framework: Fabric
Loader Version: 0.15.0

Dependency 2: net.fabricmc.fabric-api:fabric-api:0.92.0+1.20.1
Fabric API Version: 0.92.0
MC Version: 1.20.1

Combined:
Framework: Fabric
MC Version: 1.20.1
Loader: 0.15.0
API: 0.92.0
Java: 17
```

### Example 3: Extract Multi-Loader Information

**Input (Forge module)**:
```
dependencies {
    minecraft 'net.minecraftforge:forge:1.20.1-47.1.0'
    implementation project(':common')
}
```

**Input (Fabric module)**:
```
dependencies {
    minecraft "com.mojang:minecraft:1.20.1"
    modImplementation "net.fabricmc:fabric-loader:0.15.0"
    modImplementation "net.fabricmc.fabric-api:fabric-api:0.92.0+1.20.1"
    implementation project(':common')
}
```

**Extraction**:
```
Project Type: Multi-Loader

Common Module: No framework dependencies

Forge Module:
- Framework: Forge
- MC: 1.20.1
- Loader: 47.1.0

Fabric Module:
- Framework: Fabric
- MC: 1.20.1
- Loader: 0.15.0
- API: 0.92.0

Summary: Multi-loader project supporting Forge 47.1.0 + Fabric 0.15.0 on MC 1.20.1
```

---

## Troubleshooting Dependency Detection

### Issue 1: No MC Version from Fabric Loader

**Problem**: Fabric Loader version doesn't indicate MC version.

**Solution**: Always check Fabric API dependency for MC version.

### Issue 2: NeoForge Version Mapping Ambiguity

**Problem**: NeoForge 20.1.x could be MC 1.20.1, but what about edge cases?

**Solution**: Cross-reference with minecraft dependency or gradle.properties.

### Issue 3: Multiple Framework Dependencies

**Problem**: Project has both Forge and Fabric dependencies.

**Solution**: Check module structure - likely multi-loader with platform-specific modules.

### Issue 4: Custom/Modified Dependency Coordinates

**Problem**: Local or modified dependencies with non-standard coordinates.

**Solution**: Fall back to metadata file detection (mods.toml, fabric.mod.json).

---

Use this reference to accurately extract framework and version information from any Minecraft mod project.
