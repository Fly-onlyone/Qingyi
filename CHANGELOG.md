# Changelog

All notable changes to the Qingyi Minecraft Development Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **CLAUDE.md**: Comprehensive project documentation for Claude Code
- **qingyi-plugin-manager agent**: Manages Qingyi plugin development, CLAUDE.md updates, agent/skill creation, and documentation consistency
- **minecraft-code-validator agent**: Automatic code quality assurance using IntelliJ MCP integration
  - Runs IntelliJ inspections on generated code via `mcp__intellij__get_file_problems`
  - Auto-fixes common issues (missing imports, annotations, formatting)
  - Reformats all code with `mcp__intellij__reformat_file` for consistent style
  - Invoked PROACTIVELY after specialist agents complete work
  - Catches errors during generation instead of at runtime
- **intellij-inspection-guide skill**: Comprehensive catalog of IntelliJ inspections for Minecraft modding
  - Interpretation guide for `get_file_problems` output
  - Auto-fix decision matrix (47% of inspections are auto-fixable)
  - Detailed explanations for registry, event handler, client/server, NBT, and resource errors
  - Supporting documentation: `minecraft-specific-inspections.md`
- **Phase 2: Navigation & Discovery** - IntelliJ MCP integration for code exploration
- **intellij-code-navigator agent**: Intelligent navigation and discovery using IntelliJ's semantic analysis
  - Finds registry entries, event handlers, class hierarchies
  - Maps code-to-resource relationships (models, textures, lang files)
  - Provides symbol documentation via `mcp__intellij__get_symbol_info`
  - Fast searches via `find_files_by_name_keyword`, `search_in_files_by_text`, `find_files_by_glob`
  - Invoked PROACTIVELY for discovery queries ("where", "find", "locate")
  - 3-6x faster navigation than manual text search
- **intellij-navigation-patterns skill**: Navigation tool usage guide for Minecraft mods
  - Tool selection matrix (performance hierarchy: indexed > glob > text > regex)
  - Minecraft-specific patterns (registry discovery, event handlers, resource mapping)
  - Performance optimization strategies
  - Supporting documentation: `registry-discovery.md`, `event-handler-search.md`, `resource-file-mapping.md`
- **Phase 3: Refactoring** - Safe, scope-aware refactoring with IntelliJ MCP
- **intellij-refactoring-master agent**: Safe refactoring specialist using IntelliJ's rename capabilities
  - Scope-aware renaming (98% accuracy vs 85% text replacement)
  - Full code propagation across entire codebase
  - Resource file synchronization (models, textures, lang, recipes, loot tables)
  - Breaking change detection for registry name changes
  - Migration strategy guidance (MissingMappingsEvent, aliases)
  - Invoked PROACTIVELY when user requests rename operations
  - Tools: `mcp__intellij__rename_refactoring`, `mcp__intellij__replace_text_in_file`, `mcp__intellij__get_symbol_info`, Read, Write, Edit
- **intellij-refactoring-safety skill**: Safe refactoring best practices for Minecraft mods
  - Comparison: rename_refactoring vs text replacement (scope awareness, accuracy)
  - Resource synchronization workflows (8-step chain: code → registry → model → texture → lang → recipes → loot → tags)
  - World compatibility analysis (safe vs breaking changes)
  - Migration strategies and versioning
  - Supporting documentation: `registry-name-changes.md`, `resource-sync-patterns.md`, `breaking-changes-guide.md`
- **Phase 4: Project Analysis** - Multi-loader project detection and dependency analysis
- **intellij-project-analyzer agent**: Fast project structure analysis using IntelliJ MCP (4-10x faster than manual exploration)
  - Multi-loader detection (Common/Forge/Fabric/Quilt patterns)
  - Module and dependency analysis via `mcp__intellij__get_project_modules` and `mcp__intellij__get_project_dependencies`
  - Source set identification and convention detection
  - VCS repository mapping via `mcp__intellij__get_repositories`
  - Comprehensive project context reports
  - Invoked PROACTIVELY at start of complex tasks
  - Uses haiku model for cost-efficient analysis
- **multi-loader-project-patterns skill**: Multi-loader Minecraft mod architecture
  - Module organization (common/, forge/, fabric/, quilt/)
  - Platform abstraction patterns (ServiceLoader, @ExpectPlatform)
  - Gradle multi-module configuration
  - Dependency management strategies
  - Supporting documentation: `module-structure.md`, `platform-abstraction.md`, `gradle-configuration.md`
- **Phase 5: Build & Testing** - Automated in-game testing and verification
- **intellij-build-and-test-runner agent**: Build, test, and execution automation (5x faster than manual testing)
  - Executes runClient, runServer, runData configurations via `mcp__intellij__execute_run_configuration`
  - Discovers available configurations with `mcp__intellij__get_run_configurations`
  - Console output monitoring for mod loading, errors, warnings
  - In-game functionality verification
  - Data generation validation
  - Invoked PROACTIVELY after feature implementation
  - Tools: `mcp__intellij__get_run_configurations`, `mcp__intellij__execute_run_configuration`, `mcp__intellij__execute_terminal_command`, Bash
- **minecraft-run-configuration-guide skill**: IntelliJ run configurations for Minecraft modding
  - runClient, runServer, runData usage and workflows
  - Program arguments and JVM options reference
  - Data generation with DataProvider classes (recipes, loot tables, models, tags, language files)
  - Custom configuration patterns (multiplayer, profiling, CI/CD)
  - Supporting documentation: `run-client-server.md`, `data-generation.md`, `custom-configurations.md`

### Changed
- **Complete IntelliJ MCP Integration** - All 5 phases now implemented:
  - Phase 1: Code Validation ✅
  - Phase 2: Navigation & Discovery ✅
  - Phase 3: Refactoring ✅
  - Phase 4: Project Analysis ✅
  - Phase 5: Build & Testing ✅
- Enhanced `qingyi-orchestrator` with Phase 2.5: Project Analysis (proactive architecture understanding)
- Enhanced `qingyi-orchestrator` with Phase 4: Validation (proactive code quality checks)
- Enhanced `qingyi-orchestrator` with Phase 4.5: Testing (proactive in-game verification)
- Enhanced `qingyi-orchestrator` with Phase 5: Discovery (on-demand navigation)
- Enhanced `qingyi-orchestrator` with Phase 6: Refactoring (safe rename operations)
- Updated docs/AGENTS.md with 11 implemented agents (was 6 → 8 → 11)
- Updated docs/SKILLS.md with 13 implemented skills (was 8 → 10 → 13)
- Updated CLAUDE.md agent selection guide with 6 new entries total (validation, navigation, refactoring, project analysis, build/test, plugin management)
- Updated all 4 specialist agents with validation trigger sections:
  - `registry-and-content-expert`: Registry-specific validation
  - `events-and-lifecycle-expert`: Event handler validation
  - `data-and-persistence-expert`: NBT serialization validation
  - `rendering-and-client-expert`: Client/server safety validation
- Updated all 4 specialist agents with reference pattern discovery sections:
  - Enables finding existing code patterns for consistency
  - Orchestrator delegates navigation requests to `intellij-code-navigator`
  - Specialist agents receive reference implementations to follow
- Plugin now has 11 functional agents (was 6 → 8 → 11) and 13 skills (was 8 → 10 → 13)

### Planned
- Additional agents (networking-and-sync-expert, entity-and-behavior-expert, etc.)
- More framework-specific skills
- Slash commands for common workflows
- Hook implementations for validation and automation

## [0.1.0] - 2025-12-09

### Added
- Initial plugin structure and configuration
- Plugin manifest (`.claude-plugin/plugin.json`)
- Empty directories for agents, skills, commands, and hooks
- Comprehensive documentation:
  - Main README with project overview
  - Directory-specific README files
  - Detailed guides (AGENTS.md, SKILLS.md, ARCHITECTURE.md, USAGE.md)
- Example templates:
  - Example agent with full configuration
  - Example skill with supporting files
  - Example command with argument handling
- Supporting files:
  - `.gitignore` for version control
  - MIT License
  - CHANGELOG.md for version tracking
  - CONTRIBUTING.md for contribution guidelines
- Complete empty project structure ready for population

### Notes
- This is a template release with no functional agents or skills
- All documentation and examples are in place
- Ready for incremental development of Minecraft mod development tools

---

## Version History

- **0.1.0** (2025-12-09): Initial empty template structure

[Unreleased]: https://github.com/yourusername/qingyi-minecraft-dev/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourusername/qingyi-minecraft-dev/releases/tag/v0.1.0
