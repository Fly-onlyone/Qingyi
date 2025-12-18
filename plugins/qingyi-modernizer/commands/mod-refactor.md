---
name: mod-refactor
description: Modernize code with safe migrations and version upgrades
aliases:
  - mref
---

Plan and execute a safe migration or modernization of the mod.

**Instructions for the AI**:

1. **Identify migration type**:
   - Minecraft version upgrade (e.g., 1.20 → 1.21)
   - Framework migration (e.g., Forge → NeoForge)
   - Multi-loader conversion
   - General code modernization

2. **Perform pre-migration analysis**:
   - Assess current state (framework, version, dependencies)
   - Identify breaking changes
   - Estimate migration effort
   - Identify risks

3. **Create phased migration plan**:
   - Phase 1: Preparation
   - Phase 2: Core migration
   - Phase 3: Testing
   - Phase 4: Cleanup

4. **Execute with backward compatibility**:
   - Preserve registry names (or provide remapping)
   - Handle NBT version migration
   - Maintain config compatibility

Use the `legacy-modernizer` agent to perform this task.

**Expected Output**: Migration plan and execution with:
- Pre-migration analysis report
- Phased migration plan
- Breaking changes documentation
- Backward compatibility handling
- Rollback plan

**Usage Examples**:
- `/mod-refactor to Minecraft 1.21`
- `/mod-refactor Forge to NeoForge`
- `/mod-refactor convert to multi-loader`
- `/mod-refactor modernize Java patterns`
