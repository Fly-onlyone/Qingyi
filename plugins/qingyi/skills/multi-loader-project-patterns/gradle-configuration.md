# Gradle Configuration - Multi-Module Build Setup

This guide covers gradle build configuration for multi-loader Minecraft mod projects, including dependency management, module configuration, and publishing.

## Project Structure Overview

**Typical multi-loader gradle structure**:
```
mymod/
├── build.gradle                (Root build file - common config)
├── settings.gradle             (Module definitions)
├── gradle.properties           (Version properties)
├── common/
│   └── build.gradle            (Common module config)
├── forge/
│   └── build.gradle            (Forge module config)
└── fabric/
    └── build.gradle            (Fabric module config)
```

## settings.gradle

**Purpose**: Define which modules are part of the multi-module project

```groovy
// settings.gradle
rootProject.name = 'MyMod'

include 'common'
include 'forge'
include 'fabric'
// include 'quilt'  // Optional: Quilt support
```

**Module names** correspond to directory names.

## gradle.properties

**Purpose**: Centralize version numbers and configuration

```properties
# gradle.properties

# Minecraft and Loader Versions
minecraft_version=1.20.1

# Forge
forge_version=47.1.0

# NeoForge (if supporting)
neo_version=1.21.3

# Fabric
fabric_loader_version=0.15.0
fabric_api_version=0.92.0+1.20.1

# Quilt (if supporting)
quilt_loader_version=0.24.0
quilted_fabric_api_version=9.0.0+1.20.1

# Mod Info
mod_id=mymod
mod_name=My Mod
mod_version=1.0.0
mod_group=com.example.mymod

# Build Settings
java_version=17

# Publishing (optional)
curseforge_project_id=123456
modrinth_project_id=abcd1234
```

**Access in build files**:
```groovy
version = project.mod_version
group = project.mod_group
```

## Root build.gradle

**Purpose**: Common configuration for all modules

```groovy
// Root build.gradle
plugins {
    id 'java'
}

subprojects {
    apply plugin: 'java'
    apply plugin: 'maven-publish'

    java {
        toolchain {
            languageVersion = JavaLanguageVersion.of(Integer.parseInt(project.java_version))
        }
        withSourcesJar()
    }

    group = project.mod_group
    version = project.mod_version

    tasks.withType(JavaCompile).configureEach {
        options.encoding = 'UTF-8'
        options.release = Integer.parseInt(project.java_version)
    }

    repositories {
        mavenCentral()
        maven { url 'https://maven.minecraftforge.net/' }      // Forge
        maven { url 'https://maven.neoforged.net/releases/' }  // NeoForge
        maven { url 'https://maven.fabricmc.net/' }            // Fabric
        maven { url 'https://maven.quiltmc.org/repository/release/' }  // Quilt
    }
}
```

## Common Module build.gradle

**Purpose**: Common dependencies and configuration

```groovy
// common/build.gradle
plugins {
    id 'java-library'
}

dependencies {
    // Minecraft (compileOnly - provided by platform modules)
    compileOnly "com.mojang:minecraft:${minecraft_version}"

    // Annotations (optional but helpful)
    compileOnly 'org.jetbrains:annotations:24.0.1'
    compileOnly 'com.google.code.findbugs:jsr305:3.0.2'

    // Common dependencies available to all modules
    // (Add libraries used across all platforms)
}

publishing {
    publications {
        mavenJava(MavenPublication) {
            artifactId = "${mod_id}-common"
            from components.java
        }
    }

    repositories {
        // Add publishing repositories
    }
}
```

**Important**: Common module should NOT depend on Forge or Fabric!

## Forge Module build.gradle

**Purpose**: Forge-specific configuration and dependencies

```groovy
// forge/build.gradle
plugins {
    id 'net.minecraftforge.gradle' version '6.0.+'  // ForgeGradle 6
    id 'org.parchmentmc.librarian.forgegradle' version '1.+' optional  // Parchment mappings
}

dependencies {
    // Forge
    minecraft "net.minecraftforge:forge:${minecraft_version}-${forge_version}"

    // Common module
    implementation project(':common')

    // Optional: Parchment mappings (better parameter names)
    // mappings loom.layered() {
    //     officialMojangMappings()
    //     parchment("org.parchmentmc.data:parchment-${minecraft_version}:${parchment_version}@zip")
    // }
}

minecraft {
    mappings channel: 'official', version: minecraft_version

    runs {
        client {
            workingDirectory project.file('run')
            property 'forge.logging.console.level', 'debug'

            mods {
                "${mod_id}" {
                    source sourceSets.main
                    source project(':common').sourceSets.main
                }
            }
        }

        server {
            workingDirectory project.file('run-server')
            property 'forge.logging.console.level', 'debug'

            mods {
                "${mod_id}" {
                    source sourceSets.main
                    source project(':common').sourceSets.main
                }
            }
        }

        data {
            workingDirectory project.file('run-data')
            args '--mod', mod_id, '--all', '--output', file('src/generated/resources/'), '--existing', file('src/main/resources/')

            mods {
                "${mod_id}" {
                    source sourceSets.main
                    source project(':common').sourceSets.main
                }
            }
        }
    }
}

// Include common classes in Forge JAR
sourceSets.main.resources {
    srcDir project(':common').file('src/main/resources')
}

// Generate sources JAR with common code
task commonSourcesJar(type: Jar) {
    archiveClassifier = 'common-sources'
    from project(':common').sourceSets.main.allSource
}

publishing {
    publications {
        mavenJava(MavenPublication) {
            artifactId = "${mod_id}-forge"
            from components.java
            artifact commonSourcesJar
        }
    }
}

// Optional: Shadow common classes into Forge JAR
// (Use if not publishing common module separately)
jar {
    from project(':common').sourceSets.main.output
}
```

## Fabric Module build.gradle

**Purpose**: Fabric-specific configuration and dependencies

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
    implementation project(path: ':common', configuration: 'namedElements')

    // Optional: Fabric language modules
    // modImplementation "net.fabricmc.fabric-api:fabric-api-base:${fabric_api_version}"
}

loom {
    runs {
        client {
            client()
            name 'Fabric Client'
            source sourceSets.main
            source project(':common').sourceSets.main
        }

        server {
            server()
            name 'Fabric Server'
            source sourceSets.main
            source project(':common').sourceSets.main
        }
    }

    // Access wideners (if needed)
    // accessWidenerPath = project(':common').file("src/main/resources/${mod_id}.accesswidener")
}

processResources {
    // Expand properties in fabric.mod.json
    inputs.property 'version', project.version
    inputs.property 'minecraft_version', project.minecraft_version

    filesMatching('fabric.mod.json') {
        expand(
            'version': project.version,
            'minecraft_version': project.minecraft_version,
            'fabric_loader_version': project.fabric_loader_version
        )
    }
}

// Include common classes in Fabric JAR
sourceSets.main.resources {
    srcDir project(':common').file('src/main/resources')
}

jar {
    from project(':common').sourceSets.main.output
    from('LICENSE') {
        rename { "${it}_${mod_id}" }
    }
}

publishing {
    publications {
        mavenJava(MavenPublication) {
            artifactId = "${mod_id}-fabric"
            from components.java
        }
    }
}
```

## Dependency Management Across Modules

### Common Dependencies

**Dependencies needed by all modules** → Put in common/build.gradle

```groovy
// common/build.gradle
dependencies {
    // Example: Logging library used everywhere
    implementation 'org.apache.logging.log4j:log4j-api:2.20.0'
}
```

**Platform modules automatically inherit** via `implementation project(':common')`

### Platform-Specific Dependencies

**Dependencies only for one platform** → Put in that module's build.gradle

**Forge-only**:
```groovy
// forge/build.gradle
dependencies {
    // Forge-specific library
    implementation 'com.example:forge-only-lib:1.0.0'
}
```

**Fabric-only**:
```groovy
// fabric/build.gradle
dependencies {
    // Fabric-specific library
    modImplementation 'com.example:fabric-only-lib:1.0.0'
}
```

### Optional Dependencies (Soft Dependencies)

**Mod integration** (JEI, REI, etc.):

**Forge**:
```groovy
dependencies {
    // JEI (optional)
    compileOnly fg.deobf("mezz.jei:jei-${minecraft_version}-forge-api:${jei_version}")
    runtimeOnly fg.deobf("mezz.jei:jei-${minecraft_version}-forge:${jei_version}")
}
```

**Fabric**:
```groovy
dependencies {
    // REI (optional)
    modCompileOnly "me.shedaniel:RoughlyEnoughItems-api-fabric:${rei_version}"
    modRuntimeOnly "me.shedaniel:RoughlyEnoughItems-fabric:${rei_version}"
}
```

## JAR Merging Strategies

### Strategy 1: Separate JARs (Recommended)

**Output**:
- `mymod-common-1.0.0.jar`
- `mymod-forge-1.0.0.jar` (includes common)
- `mymod-fabric-1.0.0.jar` (includes common)

**Advantages**:
- ✅ Clear separation
- ✅ Users download only what they need
- ✅ Easier debugging

**Configuration**: Default setup (shown above)

### Strategy 2: Single JAR with Loader Detection

**Output**: `mymod-1.0.0.jar` (works on both Forge and Fabric)

**Requires**: Advanced jar merging, not recommended for beginners

### Strategy 3: Common Library + Platform JARs

**Output**:
- `mymod-common-1.0.0.jar` (library, users don't download)
- `mymod-forge-1.0.0.jar` (depends on common JAR)
- `mymod-fabric-1.0.0.jar` (depends on common JAR)

**Use case**: Very large common code, want to publish common as library

## Shadow/Relocate for Platform Libraries

**Problem**: Library version conflicts between mods

**Solution**: Shadow (include and relocate library)

```groovy
// forge/build.gradle
plugins {
    id 'com.github.johnrengelman.shadow' version '8.1.1'
}

dependencies {
    // Library to shadow
    implementation 'com.example:my-library:1.0.0'
}

shadowJar {
    configurations = [project.configurations.shadow]

    // Relocate to avoid conflicts
    relocate 'com.example.mylibrary', 'com.mod.shadow.mylibrary'

    archiveClassifier = ''
}

reobf {
    shadowJar {}
}

tasks.build.dependsOn tasks.shadowJar
```

**Result**: Library included in your JAR with relocated package names

## Publishing

### Publishing to Maven Local (Testing)

```groovy
// In any module build.gradle
publishing {
    repositories {
        mavenLocal()
    }
}
```

**Run**:
```bash
./gradlew publishToMavenLocal
```

**Result**: JAR available in `~/.m2/repository/`

### Publishing to CurseForge

```groovy
// root build.gradle
plugins {
    id 'com.matthewprenger.cursegradle' version '1.4.0'
}

curseforge {
    apiKey = project.hasProperty('curseforge_api_key') ? project.curseforge_api_key : System.getenv('CURSEFORGE_API_KEY')

    project {
        id = project.curseforge_project_id
        changelog = file('CHANGELOG.md')
        releaseType = 'release'  // or 'beta', 'alpha'

        addGameVersion project.minecraft_version
        addGameVersion 'Forge'

        mainArtifact(forge.jar) {
            displayName = "${mod_name} ${mod_version} (Forge)"
        }
    }
}
```

### Publishing to Modrinth

```groovy
plugins {
    id 'com.modrinth.minotaur' version '2.+'
}

modrinth {
    token = project.hasProperty('modrinth_token') ? project.modrinth_token : System.getenv('MODRINTH_TOKEN')
    projectId = project.modrinth_project_id
    versionNumber = project.mod_version
    versionType = 'release'
    uploadFile = forge.jar
    gameVersions = [project.minecraft_version]
    loaders = ['forge']
    changelog = file('CHANGELOG.md').text
}
```

### Multi-Platform Publishing

**Publish both Forge and Fabric**:

```groovy
// root build.gradle
task publishAll {
    dependsOn ':forge:curseforge', ':fabric:curseforge'
    dependsOn ':forge:modrinth', ':fabric:modrinth'
}
```

**Run**:
```bash
./gradlew publishAll
```

## Version Property Management

### Centralized Version File

```properties
# gradle.properties

# Mod versioning
mod_version_major=1
mod_version_minor=0
mod_version_patch=0
mod_version=${mod_version_major}.${mod_version_minor}.${mod_version_patch}

# Or with snapshot support
mod_version=1.0.0-SNAPSHOT
```

### Dynamic Version from Git

```groovy
// root build.gradle
def getModVersion() {
    def tag = 'git describe --tags --always'.execute().text.trim()
    return tag.startsWith('v') ? tag.substring(1) : tag
}

subprojects {
    version = getModVersion()
}
```

### Version in Code

**Access mod version** in Java:

**Forge**:
```java
ModList.get().getModContainerById(MOD_ID)
    .map(c -> c.getModInfo().getVersion().toString())
```

**Fabric**:
```java
FabricLoader.getInstance().getModContainer(MOD_ID)
    .map(c -> c.getMetadata().getVersion().getFriendlyString())
```

## Common Build Tasks

### Build All Modules

```bash
./gradlew build
```

**Output**:
- `common/build/libs/mymod-common-1.0.0.jar`
- `forge/build/libs/mymod-forge-1.0.0.jar`
- `fabric/build/libs/mymod-fabric-1.0.0.jar`

### Clean Build Artifacts

```bash
./gradlew clean
```

### Run Client (Forge)

```bash
./gradlew :forge:runClient
```

### Run Client (Fabric)

```bash
./gradlew :fabric:runClient
```

### Generate Data (Forge)

```bash
./gradlew :forge:runData
```

### Publish to Maven Local

```bash
./gradlew publishToMavenLocal
```

## Troubleshooting

### Problem: "Could not resolve project :common"

**Cause**: Module not included in settings.gradle

**Fix**:
```groovy
// settings.gradle
include 'common'
```

### Problem: Common classes not found in platform JAR

**Cause**: Common output not included in JAR

**Fix**:
```groovy
// forge/build.gradle or fabric/build.gradle
jar {
    from project(':common').sourceSets.main.output
}
```

### Problem: Version mismatch between modules

**Cause**: Modules using different version properties

**Fix**: Centralize version in root gradle.properties:
```properties
mod_version=1.0.0
```

### Problem: Dependency resolution failures

**Cause**: Missing repositories

**Fix**: Add all required repositories to root build.gradle:
```groovy
repositories {
    mavenCentral()
    maven { url 'https://maven.minecraftforge.net/' }
    maven { url 'https://maven.fabricmc.net/' }
}
```

## Best Practices

### DO

- ✅ Centralize versions in gradle.properties
- ✅ Use consistent Java version across all modules
- ✅ Include common classes in platform JARs
- ✅ Publish sources JARs for debugging
- ✅ Use clear artifact names (mymod-forge, mymod-fabric)

### DON'T

- ❌ Put Forge/Fabric dependencies in common module
- ❌ Hardcode version numbers in build files
- ❌ Forget to include common resources in platform JARs
- ❌ Mix Forge and Fabric code in same module
- ❌ Publish without testing on both platforms

## Summary

**Multi-module gradle setup** enables building multi-loader mods from shared codebase.

**Key Files**:
- **settings.gradle**: Define modules
- **gradle.properties**: Centralize versions
- **Root build.gradle**: Common configuration
- **Module build.gradle**: Platform-specific setup

**Dependency Strategy**:
- Common dependencies → common/build.gradle
- Platform-specific → platform/build.gradle
- Platform modules depend on common module

**Publishing**:
- Separate JARs recommended (forge, fabric)
- Include common classes in platform JARs
- Publish to CurseForge/Modrinth for users
- Publish to Maven for developers

For module organization, see [Module Structure](./module-structure.md).

For platform abstraction, see [Platform Abstraction](./platform-abstraction.md).
