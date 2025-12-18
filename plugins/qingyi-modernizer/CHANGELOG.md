# Changelog

All notable changes to the Qingyi Modernizer plugin will be documented in this file.

## [1.0.0] - 2024-12-18

### Added
- Initial release
- **legacy-modernizer** agent with:
  - Minecraft version upgrade support (1.19 → 1.20 → 1.21)
  - Framework migration (Forge → NeoForge)
  - Multi-loader conversion (monolithic → common/forge/fabric)
  - Strangler Fig Pattern implementation
  - Pre-migration analysis and risk assessment
  - Phased migration plans
  - Backward compatibility preservation
  - Rollback strategies
- **mod-migration-guide** skill:
  - Version upgrade patterns
  - Framework migration guides
  - Multi-loader conversion strategies
  - Supporting files: forge-to-neoforge.md, minecraft-version-migrations.md, multi-loader-conversion.md
- **gradle-migration-patterns** skill:
  - Build system migration patterns
  - ForgeGradle → NeoGradle migration
  - Multi-project configuration
  - Supporting files: build-examples.md
- `/mod-refactor` command for quick migration invocation

### Features
- Migration type auto-detection (version, framework, multi-loader)
- Impact analysis with effort estimation
- Breaking changes documentation
- World data compatibility preservation
- Registry remapping guidance (MissingMappingsEvent)
- NBT version migration support
- Config file compatibility
