# Build Configuration Examples

Complete build.gradle examples for different frameworks.

## Forge 1.20.1

```gradle
plugins {
    id 'net.minecraftforge.gradle' version '[6.0,6.2)'
}

version = '1.0.0'
group = 'com.example.mymod'

minecraft {
    mappings channel: 'official', version: '1.20.1'

    runs {
        client {
            workingDirectory project.file('run')
            property 'forge.logging.console.level', 'debug'
            mods {
                mymod {
                    source sourceSets.main
                }
            }
        }
        server {
            workingDirectory project.file('run')
            property 'forge.logging.console.level', 'debug'
            mods {
                mymod {
                    source sourceSets.main
                }
            }
        }
    }
}

dependencies {
    minecraft "net.minecraftforge:forge:1.20.1-47.1.0"
}
```

## NeoForge 1.21.3

```gradle
plugins {
    id 'net.neoforged.gradle.userdev' version '7.0.+'
}

version = '1.0.0'
group = 'com.example.mymod'

minecraft {
    mappings channel: 'official', version: '1.21.3'
}

dependencies {
    implementation "net.neoforged:neoforge:1.21.3"
}
```

## Fabric 1.20.1

```gradle
plugins {
    id 'fabric-loom' version '1.5-SNAPSHOT'
}

version = '1.0.0'
group = 'com.example.mymod'

dependencies {
    minecraft "com.mojang:minecraft:1.20.1"
    mappings "net.fabricmc:yarn:1.20.1+build.10:v2"
    modImplementation "net.fabricmc:fabric-loader:0.15.0"
    modImplementation "net.fabricmc.fabric-api:fabric-api:0.92.0+1.20.1"
}
```

## See Also

- [Main Gradle Migration Patterns](./SKILL.md)
