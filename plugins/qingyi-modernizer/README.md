# Qingyi Modernizer

A Claude Code plugin for legacy code modernization, framework migrations, and Minecraft version upgrades with backward compatibility preservation.

## Overview

Qingyi Modernizer is a companion plugin to the main [Qingyi](../qingyi/) Minecraft development plugin. It specializes in safely migrating Minecraft mods across versions and frameworks while maintaining world data compatibility.

## Features

### Legacy Modernizer Agent
- **Version Upgrades**: Minecraft 1.19 → 1.20 → 1.21
- **Framework Migrations**: Forge → NeoForge, with full API mapping
- **Multi-Loader Conversions**: Monolithic → Common/Forge/Fabric architecture
- **General Modernization**: Java patterns, API updates, deprecation fixes

### Migration Strategies
- **Strangler Fig Pattern**: Incremental, safe replacement (recommended)
- **Big Bang Migration**: Full replacement for small mods
- **Parallel Development**: Maintain multiple versions simultaneously

### Backward Compatibility
- **World Data Preservation**: Registry remapping, NBT versioning
- **Config Migration**: Preserve user settings across versions
- **Rollback Plans**: Every migration includes rollback strategy

### Skills
- **mod-migration-guide**: Version and framework migration patterns
- **gradle-migration-patterns**: Build system migration (ForgeGradle → NeoGradle)

### Commands
- `/mod-refactor` (`/mref`): Plan and execute migrations

## Installation

1. Clone or download this plugin to your Claude Code plugins directory
2. Restart Claude Code
3. The `legacy-modernizer` agent will be available

## Usage

### Direct Invocation
```
Use the legacy-modernizer agent to migrate this mod from Forge 1.20.1 to NeoForge 1.21.3
```

### Slash Command
```
/mod-refactor to Minecraft 1.21
/mod-refactor Forge to NeoForge
/mod-refactor convert to multi-loader
```

## Migration Process

### 1. Pre-Migration Analysis
- Current state assessment (framework, version, dependencies)
- Breaking changes identification
- Risk analysis with mitigation strategies
- Effort estimation

### 2. Phased Migration Plan
- **Phase 1**: Preparation (backup, branch, dependencies)
- **Phase 2**: Core migration (registries, events, capabilities)
- **Phase 3**: Testing (unit, integration, in-game, world loading)
- **Phase 4**: Cleanup (deprecated code removal, documentation)

### 3. Backward Compatibility
- Registry name preservation (or MissingMappingsEvent remapping)
- NBT version handling for data migration
- Config file compatibility

### 4. Rollback Plan
- Git-based rollback to tagged version
- Backup restoration procedures
- Issue documentation

## Common Migrations

### Minecraft Version Upgrade (1.20 → 1.21)
- Registry API changes
- Capability → Data Attachment migration
- Networking API updates
- Creative tab changes

### Forge → NeoForge
- Package import updates
- RegistryObject → DeferredHolder
- Event bus registration changes
- Capability system modernization

### Multi-Loader Conversion
- Project restructure (common/forge/fabric modules)
- ServiceLoader pattern implementation
- Platform abstraction interfaces
- Gradle multi-project configuration

## Requirements

- Claude Code 1.0.0+
- Optional: Qingyi plugin (for Minecraft-specific skills)

## License

MIT

## Related

- [Qingyi Plugin](../qingyi/) - Main Minecraft development plugin
- [Qingyi Code Review](../qingyi-code-review/) - Code review and security plugin
