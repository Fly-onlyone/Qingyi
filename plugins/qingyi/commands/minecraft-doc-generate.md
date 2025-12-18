---
name: minecraft-doc-generate
description: Generate comprehensive documentation for a Minecraft mod
aliases:
  - mdoc
---

Generate comprehensive technical documentation for this Minecraft mod.

**Instructions for the AI**:

1. **Detect the framework** (Forge/NeoForge/Fabric) by scanning:
   - `build.gradle` for ForgeGradle/Loom/NeoGradle
   - `gradle.properties` for version numbers
   - `mods.toml` or `fabric.mod.json` for mod metadata

2. **Analyze the entire project**:
   - Scan all Java files for registries, events, capabilities
   - Map the package structure
   - Identify design patterns used
   - Catalog all resource files

3. **Generate documentation** following the standard structure:
   - Overview and features
   - Architecture diagram
   - Registry documentation (items, blocks, entities)
   - Event system documentation
   - Data persistence patterns
   - Client-side systems
   - Resource documentation
   - API reference

4. **Output as DOCUMENTATION.md** (or /docs folder for complex mods)

Use the `minecraft-docs-architect` agent to perform this task with full context.

**Expected Output**: Comprehensive DOCUMENTATION.md file with:
- Table of contents
- Real code examples from the actual project
- Framework-specific patterns
- Cross-references between sections
- Architecture diagrams
