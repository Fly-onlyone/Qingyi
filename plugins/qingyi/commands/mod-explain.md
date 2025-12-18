---
name: mod-explain
description: Explain mod code with educational context and tutorials
aliases:
  - mex
---

Explain the specified code or concept with educational context.

**Instructions for the AI**:

1. **Determine the explanation scope**:
   - Single file explanation
   - Concept explanation (e.g., "how events work")
   - Feature walkthrough (e.g., "how items are registered")
   - Framework comparison (e.g., "Forge vs Fabric")

2. **Detect the framework** if not specified:
   - Check `build.gradle`, `gradle.properties`
   - Check `mods.toml` or `fabric.mod.json`

3. **Create educational content**:
   - Start with clear learning objectives
   - Explain concepts before code
   - Show framework variants where relevant
   - Include common mistakes to avoid
   - Provide hands-on exercises

4. **Adjust difficulty level**:
   - Beginner: Basic concepts, simple explanations
   - Intermediate: Events, NBT, entity patterns
   - Advanced: Networking, capabilities, datagen
   - Expert: Mixins, multi-loader, optimization

Use the `minecraft-tutorial-engineer` agent to perform this task.

**Expected Output**: Clear educational explanation with:
- Learning objectives
- Step-by-step concept breakdown
- Real code examples with annotations
- Common mistakes section
- Practice exercises (where applicable)
- Links to further learning

**Usage Examples**:
- `/mod-explain how item registration works`
- `/mod-explain this event handler`
- `/mod-explain NBT serialization patterns`
- `/mod-explain Forge vs Fabric differences`
