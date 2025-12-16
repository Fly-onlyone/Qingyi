# Multi-Loader Conversion Guide

Converting single-loader mod to multi-loader architecture.

## Project Structure

```
mymod/
├── common/          # Platform-agnostic
│   └── src/main/java/
│       └── com.example.mymod/
│           ├── items/
│           ├── blocks/
│           └── logic/
├── forge/           # Forge-specific
│   └── src/main/java/
│       └── com.example.mymod.forge/
│           ├── ForgeModMain.java
│           └── registry/
├── fabric/          # Fabric-specific
│   └── src/main/java/
│       └── com.example.mymod.fabric/
│           ├── FabricModMain.java
│           └── registry/
```

## Gradle Setup

**settings.gradle**:
```gradle
rootProject.name = 'mymod'
include 'common', 'forge', 'fabric'
```

**common/build.gradle**: No Forge/Fabric dependencies
**forge/build.gradle**: ForgeGradle + common dependency
**fabric/build.gradle**: Fabric Loom + common dependency

## Platform Abstraction

Use `@ExpectPlatform` for platform-specific code called from common module.

## See Also

- [Main Migration Guide](./SKILL.md)
- [Multi-Loader Project Patterns](../../multi-loader-project-patterns/SKILL.md)
