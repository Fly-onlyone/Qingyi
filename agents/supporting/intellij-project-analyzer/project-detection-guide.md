# Project Detection Guide - Single vs Multi-Loader Detection Patterns

Comprehensive guide to accurately detecting Minecraft mod project types, module structures, and naming conventions across all major frameworks.

## Overview

Minecraft mods can be structured in various ways depending on whether they target a single mod loader (Forge, NeoForge, Fabric, Quilt) or multiple loaders simultaneously. This guide covers detection strategies for all common patterns.

---

## Detection Categories

### Category 1: Single-Loader Projects

Projects that target only one mod loader.

### Category 2: Multi-Loader Projects

Projects that support multiple loaders through abstraction layers (Architectury, MultiLoader, custom).

### Category 3: Ambiguous Projects

Projects that require deeper investigation to determine type.

---

## Single-Loader Detection

### Pattern 1: Standard Single-Loader (Forge/NeoForge)

#### Module Structure
```
get_project_modules() returns:
- Module: MyMod (JAVA)
```

#### Directory Structure
```
MyMod/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── mod/
│   │   │           └── MyMod.java
│   │   └── resources/
│   │       ├── META-INF/
│   │       │   └── mods.toml
│   │       └── assets/
│   └── generated/
├── build.gradle
└── gradle.properties
```

#### Build Configuration Indicators
```gradle
// build.gradle
plugins {
    id 'net.minecraftforge.gradle' version '6.0.+'  // Forge
    // OR
    id 'net.neoforged.gradle.userdev' version '7.0.+' // NeoForge
}
```

#### Metadata File
```toml
# mods.toml (Forge/NeoForge indicator)
modLoader="javafml"  # Forge
# OR
modLoader="lowcodefml"  # NeoForge
```

#### Detection Confidence: HIGH

**Checklist**:
- [x] Single module
- [x] `src/main/java` structure
- [x] `mods.toml` present
- [x] ForgeGradle or NeoGradle plugin
- [x] Forge/NeoForge dependency

---

### Pattern 2: Standard Single-Loader (Fabric)

#### Module Structure
```
get_project_modules() returns:
- Module: MyMod (JAVA)
```

#### Directory Structure
```
MyMod/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── mod/
│   │   │           └── MyMod.java
│   │   └── resources/
│   │       ├── fabric.mod.json
│   │       └── assets/
│   ├── client/  # Optional: Client-only code
│   │   └── java/
│   └── data/  # Optional: Data generation
├── build.gradle
└── gradle.properties
```

#### Build Configuration Indicators
```gradle
// build.gradle
plugins {
    id 'fabric-loom' version '1.5-SNAPSHOT'
}
```

#### Metadata File
```json
// fabric.mod.json (Fabric indicator)
{
  "schemaVersion": 1,
  "id": "mymod",
  "version": "1.0.0",
  "environment": "*"
}
```

#### Detection Confidence: HIGH

**Checklist**:
- [x] Single module
- [x] `src/main/java` structure
- [x] `fabric.mod.json` present
- [x] Fabric Loom plugin
- [x] Fabric Loader dependency

---

### Pattern 3: Single-Loader with Source Sets (Fabric)

#### Module Structure
```
get_project_modules() returns:
- Module: MyMod (JAVA)
```

#### Directory Structure
```
MyMod/
├── src/
│   ├── main/
│   │   ├── java/  # Common code
│   │   └── resources/
│   ├── client/
│   │   ├── java/  # Client-only code
│   │   └── resources/
│   └── server/  # Rare
│       └── java/
├── build.gradle
└── gradle.properties
```

#### Build Configuration
```gradle
// build.gradle
sourceSets {
    main {}
    client {
        compileClasspath += main.compileClasspath
    }
}
```

#### Detection Confidence: HIGH

**Checklist**:
- [x] Single module
- [x] `src/main/` AND `src/client/`
- [x] `fabric.mod.json` present
- [x] Fabric Loom plugin
- [ ] NOT multi-loader (no "common" or "forge" modules)

---

## Multi-Loader Detection

### Pattern 1: Architectury Pattern

Most common multi-loader pattern.

#### Module Structure
```
get_project_modules() returns:
- Module: common (JAVA)
- Module: forge (JAVA)
- Module: fabric (JAVA)
```

#### Directory Structure
```
MyMod/
├── common/
│   └── src/
│       └── main/
│           ├── java/
│           │   └── com/mod/
│           │       └── CommonClass.java
│           └── resources/
│               └── assets/modid/
├── forge/
│   └── src/
│       └── main/
│           ├── java/
│           │   └── com/mod/forge/
│           │       └── ForgeClass.java
│           └── resources/
│               └── META-INF/mods.toml
├── fabric/
│   └── src/
│       └── main/
│           ├── java/
│           │   └── com/mod/fabric/
│           │       └── FabricClass.java
│           └── resources/
│               └── fabric.mod.json
├── build.gradle
└── settings.gradle
```

#### Settings Configuration
```gradle
// settings.gradle
rootProject.name = 'MyMod'

include 'common'
include 'forge'
include 'fabric'
```

#### Build Configuration (Root)
```gradle
// build.gradle (root)
plugins {
    id "architectury-plugin" version "3.4-SNAPSHOT"
    id "dev.architectury.loom" version "1.5-SNAPSHOT" apply false
}

subprojects {
    apply plugin: "dev.architectury.loom"
}
```

#### Detection Confidence: VERY HIGH

**Checklist**:
- [x] Three modules: common, forge, fabric
- [x] `settings.gradle` includes all three
- [x] Architectury plugin
- [x] Platform-specific metadata in each module
- [x] Common module has no loader dependency

**Module Naming Variations**:
```
Standard:
- common, forge, fabric

With Prefix:
- mymod-common, mymod-forge, mymod-fabric

PascalCase:
- Common, Forge, Fabric

With Project Name:
- MyMod-Common, MyMod-Forge, MyMod-Fabric
```

---

### Pattern 2: MultiLoader Template Pattern

Alternative multi-loader pattern without Architectury.

#### Module Structure
```
get_project_modules() returns:
- Module: Common (JAVA)
- Module: Forge (JAVA)
- Module: Fabric (JAVA)
- Module: NeoForge (JAVA)  # Optional
```

#### Directory Structure
```
MyMod/
├── Common/
│   └── src/main/java/
├── Forge/
│   ├── src/main/java/
│   └── build.gradle
├── Fabric/
│   ├── src/main/java/
│   └── build.gradle
└── NeoForge/
    ├── src/main/java/
    └── build.gradle
```

#### Build Configuration (per module)
```gradle
// Forge/build.gradle
plugins {
    id 'net.minecraftforge.gradle' version '6.0.+'
}

dependencies {
    implementation project(':Common')
}

// Fabric/build.gradle
plugins {
    id 'fabric-loom' version '1.5-SNAPSHOT'
}

dependencies {
    implementation project(':Common')
}
```

#### Detection Confidence: HIGH

**Checklist**:
- [x] Multiple modules with platform names
- [x] Common module with shared code
- [x] Each platform module has its own build.gradle
- [x] Project dependencies between modules
- [ ] NO Architectury plugin (custom setup)

---

### Pattern 3: Shared Source Pattern

Less common: Single source tree with platform-specific packages.

#### Module Structure
```
get_project_modules() returns:
- Module: MyMod (JAVA)
```

#### Directory Structure
```
MyMod/
└── src/
    └── main/
        └── java/
            └── com/mod/
                ├── common/
                │   └── CommonClass.java
                ├── forge/
                │   └── ForgeClass.java
                └── fabric/
                    └── FabricClass.java
```

#### Build Configuration
```gradle
// build.gradle
loom {
    runs {
        forge {
            // Configure Forge run
        }
        fabric {
            // Configure Fabric run
        }
    }
}
```

#### Detection Confidence: MEDIUM

**Requires deeper investigation**:
- Check for platform-specific packages
- Look for conditional compilation
- Examine run configurations

---

## Module Naming Conventions

### Convention 1: Lowercase (Most Common)
```
Modules:
- common
- forge
- fabric
- neoforge
- quilt

Example project: "awesome-mod"
```

### Convention 2: PascalCase
```
Modules:
- Common
- Forge
- Fabric
- NeoForge
- Quilt

Example project: "AwesomeMod"
```

### Convention 3: Prefixed with Project Name
```
Project: "tutorialmod"
Modules:
- tutorialmod-common
- tutorialmod-forge
- tutorialmod-fabric

Example: "com.example:tutorialmod-forge:1.0.0"
```

### Convention 4: Hyphenated
```
Modules:
- my-mod-common
- my-mod-forge
- my-mod-fabric

Example project: "my-awesome-mod"
```

### Convention 5: Custom Names
```
Modules:
- core (instead of common)
- forge-impl
- fabric-impl

Less common, requires explicit detection
```

---

## Detection Algorithm

### Step-by-Step Process

#### Step 1: Get Module Count
```
modules = get_project_modules()
count = modules.length

IF count == 1:
    → Likely single-loader
    → Proceed to Step 2
ELSE IF count >= 3:
    → Likely multi-loader
    → Proceed to Step 3
ELSE:
    → Ambiguous, needs investigation
    → Proceed to Step 4
END IF
```

#### Step 2: Single-Loader Classification
```
1. Check for metadata file:
   - Find "mods.toml" → Forge/NeoForge
   - Find "fabric.mod.json" → Fabric
   - Find "quilt.mod.json" → Quilt

2. Verify with dependency:
   - net.minecraftforge:forge → Forge
   - net.neoforged:neoforge → NeoForge
   - net.fabricmc:fabric-loader → Fabric
   - org.quiltmc:quilt-loader → Quilt

3. Check build plugin:
   - ForgeGradle → Forge
   - NeoGradle → NeoForge
   - Fabric Loom → Fabric/Quilt

Result: Single-loader [Framework] project
Confidence: HIGH
```

#### Step 3: Multi-Loader Classification
```
1. Extract module names:
   modules = ["common", "forge", "fabric"]

2. Check for platform keywords:
   keywords = ["common", "forge", "fabric", "neoforge", "quilt"]
   matches = count(module.name contains keyword for each module)

3. Classify:
   IF matches >= 2:
       → Multi-loader project
       → Identify which platforms (forge, fabric, etc.)
   ELSE:
       → Possibly feature-based modules
       → Proceed to Step 4
   END IF

4. Verify with settings.gradle:
   - Check includes
   - Confirm module structure

Result: Multi-loader [Platforms] project
Confidence: VERY HIGH
```

#### Step 4: Ambiguous Project Investigation
```
1. Check directory structure:
   - Look for src/client/ (Fabric pattern)
   - Look for platform-specific packages

2. Read build files:
   - Check for multi-loader setup
   - Look for Architectury/MultiLoader plugins

3. Search for platform indicators:
   - Search "@Mod" annotation → Forge/NeoForge
   - Search "ModInitializer" → Fabric
   - Search "QuiltMod" → Quilt

4. Determine based on findings:
   - Multiple platforms found → Multi-loader
   - One platform found → Single-loader
   - No clear platform → Unknown/Vanilla

Result: [Type] with [Confidence] confidence
```

---

## Detection Decision Tree

```
START
  │
  ├─ Get module count
  │
  ├─ Count == 1?
  │  ├─ Yes → Check metadata file
  │  │        ├─ mods.toml found → FORGE/NEOFORGE (single-loader)
  │  │        ├─ fabric.mod.json found → FABRIC (single-loader)
  │  │        ├─ quilt.mod.json found → QUILT (single-loader)
  │  │        └─ None → Check dependencies
  │  │
  │  └─ No → Count >= 3?
  │     ├─ Yes → Check module names
  │     │        ├─ Contains "common" + "forge" + "fabric" → MULTI-LOADER
  │     │        ├─ Contains "common" + platform names → MULTI-LOADER
  │     │        └─ No platform keywords → Investigate
  │     │
  │     └─ No → AMBIGUOUS
  │              └─ Deep investigation needed
  │
END
```

---

## Platform Keyword Matching

### Primary Keywords (High Confidence)
```
common, core, shared → Common module
forge → Forge platform
neoforge, neo → NeoForge platform
fabric → Fabric platform
quilt → Quilt platform
```

### Secondary Keywords (Medium Confidence)
```
api → Possibly common/shared API
impl, implementation → Platform implementation
client → Client-only module
server → Server-only module
```

### Ignore Keywords (Not Platform-Related)
```
test, tests → Test module
example, examples → Example code
datagen, data → Data generation
```

### Matching Algorithm
```
function isPlatformModule(moduleName) {
    name_lower = moduleName.toLowerCase()

    # Remove common prefixes/suffixes
    clean_name = name_lower
        .replace(projectName + "-", "")
        .replace("-impl", "")
        .replace("-mod", "")

    # Check primary keywords
    IF clean_name IN ["common", "core", "shared"]:
        RETURN "common"
    ELSE IF clean_name IN ["forge"]:
        RETURN "forge"
    ELSE IF clean_name IN ["fabric"]:
        RETURN "fabric"
    ELSE IF clean_name IN ["neoforge", "neo"]:
        RETURN "neoforge"
    ELSE IF clean_name IN ["quilt"]:
        RETURN "quilt"
    ELSE:
        RETURN "unknown"
    END IF
}
```

---

## Verification Strategies

### Strategy 1: Cross-Reference with Settings File

```gradle
// settings.gradle
rootProject.name = 'awesome-mod'

include 'common'
include 'forge'
include 'fabric'
```

**Verification**:
1. Read settings.gradle
2. Extract `include` statements
3. Match with detected modules
4. Confirm multi-loader if includes match platform names

### Strategy 2: Check Build Dependencies

```gradle
// forge/build.gradle
dependencies {
    implementation project(':common')
}

// fabric/build.gradle
dependencies {
    implementation project(':common')
}
```

**Verification**:
1. Read platform module build files
2. Look for `project(':common')` dependencies
3. Confirms multi-loader with shared common module

### Strategy 3: Search for Platform-Specific Code

```
# Search for Forge indicator
search_in_files_by_text("@Mod", fileMask="*.java")

# Search for Fabric indicator
search_in_files_by_text("implements ModInitializer", fileMask="*.java")

# If both found in different modules → Multi-loader
# If both found in same module → Custom multi-loader
# If only one found → Single-loader
```

---

## Common Ambiguous Cases

### Case 1: Feature-Based Modules

```
Modules:
- core
- api
- content
- worldgen
```

**NOT multi-loader** - These are feature-based modules.

**Detection**:
- No platform keywords
- All modules likely depend on same framework
- Check dependencies: all use Forge OR all use Fabric

### Case 2: Client/Server Split (Forge)

```
Modules:
- MyMod-Common
- MyMod-Client
- MyMod-Server
```

**NOT multi-loader** - These are side-based modules (rare pattern).

**Detection**:
- Keywords "client" and "server" instead of platform names
- All use same framework (Forge)
- Check for @OnlyIn annotations

### Case 3: Multi-Version Support

```
Modules:
- common
- forge-1.20
- forge-1.19
- fabric-1.20
```

**Multi-loader AND multi-version** - Complex setup.

**Detection**:
- Platform names with version suffixes
- Multiple modules per platform
- Requires version-aware analysis

---

## Detection Confidence Levels

### VERY HIGH (95%+ accuracy)
- Module names exactly match: common, forge, fabric
- Architectury plugin detected
- settings.gradle confirms structure
- Platform-specific metadata in correct modules

### HIGH (85-95% accuracy)
- Module names contain platform keywords
- Platform-specific dependencies match modules
- Metadata files present in expected locations
- Build configuration confirms pattern

### MEDIUM (70-85% accuracy)
- Single module with platform-specific packages
- Custom module naming convention
- Mixed indicators (some match, some don't)
- Requires additional verification

### LOW (<70% accuracy)
- No clear platform indicators
- Ambiguous module names
- Non-standard structure
- Manual investigation required

---

## Edge Cases and Special Patterns

### Edge Case 1: Quilt-Only Project

```
Module: mymod
Metadata: quilt.mod.json
Dependencies: org.quiltmc:quilt-loader
```

**Detection**: Similar to Fabric, check for Quilt-specific files.

### Edge Case 2: NeoForge + Forge Multi-Loader

```
Modules:
- common
- forge (Forge 1.20.1)
- neoforge (NeoForge 1.20.4)
```

**Detection**: Both are Forge-like, distinguish by dependency version.

### Edge Case 3: Custom Multi-Loader Framework

```
Modules:
- shared
- loader-forge
- loader-fabric
```

**Detection**: Non-standard names, check for "loader" keyword and dependencies.

### Edge Case 4: Mono-Repo with Multiple Mods

```
Modules:
- mod1-common
- mod1-forge
- mod1-fabric
- mod2-common
- mod2-forge
```

**Detection**: Multiple sets of platform modules, group by prefix.

---

## Practical Detection Examples

### Example 1: Detect Standard Architectury Project

**Input**:
```
get_project_modules() →
- common (JAVA)
- forge (JAVA)
- fabric (JAVA)
```

**Analysis**:
```
Step 1: Module count = 3 → Multi-loader likely
Step 2: Module names = ["common", "forge", "fabric"]
Step 3: All match primary keywords → VERY HIGH confidence
Step 4: Verify settings.gradle → Confirms includes

Result: Multi-loader (Forge + Fabric) project
Confidence: VERY HIGH
```

### Example 2: Detect Fabric with Client Split

**Input**:
```
get_project_modules() →
- mymod (JAVA)

list_directory_tree("src", maxDepth=2) →
src/
├── main/
│   ├── java/
│   └── resources/
│       └── fabric.mod.json
└── client/
    └── java/
```

**Analysis**:
```
Step 1: Module count = 1 → Single-loader likely
Step 2: Check metadata → fabric.mod.json found
Step 3: Check directory structure → src/client/ present
Step 4: Verify dependency → net.fabricmc:fabric-loader found

Result: Single-loader Fabric with client source set
Confidence: HIGH
```

### Example 3: Detect Custom Multi-Loader

**Input**:
```
get_project_modules() →
- core (JAVA)
- platform-forge (JAVA)
- platform-fabric (JAVA)
```

**Analysis**:
```
Step 1: Module count = 3 → Multi-loader likely
Step 2: Module names = ["core", "platform-forge", "platform-fabric"]
Step 3: Contains "forge" and "fabric" → Multi-loader indicators
Step 4: "core" instead of "common" → Custom naming
Step 5: Check dependencies per module → Confirms platforms

Result: Multi-loader (Forge + Fabric) with custom naming
Confidence: HIGH
```

---

## Recommendations for Reporting

### For Single-Loader Projects
```markdown
**Project Type**: Single-Loader
**Framework**: [Forge/NeoForge/Fabric/Quilt]
**Structure**: Standard src/main layout

**Implementation Approach**:
- Use [framework]-specific APIs directly
- No abstraction layer needed
- Register in standard [framework] pattern
```

### For Multi-Loader Projects
```markdown
**Project Type**: Multi-Loader
**Frameworks**: [List of platforms]
**Pattern**: [Architectury/MultiLoader/Custom]

**Module Breakdown**:
- common: Shared code and interfaces
- [platform1]: [Platform1] implementation
- [platform2]: [Platform2] implementation

**Implementation Approach**:
- Define interfaces in common module
- Implement for each platform separately
- Use platform helpers for registration
- Share assets when possible
```

---

Use this guide to achieve accurate, fast project type detection for any Minecraft mod structure.
