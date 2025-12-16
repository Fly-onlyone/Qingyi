---
name: intellij-inspection-guide
description: Catalog of IntelliJ inspections relevant to Minecraft modding. Covers event handlers, registry, client/server safety, NBT, resource locations. Guides interpretation of get_file_problems output and common fix strategies.
allowed-tools: mcp__intellij__get_file_problems, Read
---

# IntelliJ Inspection Guide for Minecraft Modding

This skill provides comprehensive guidance on interpreting and fixing IntelliJ IDEA inspections specific to Minecraft mod development.

## Purpose

**What this skill provides**:
- How to interpret `get_file_problems` MCP tool output
- Catalog of common Minecraft modding inspections
- Fix strategies for each type of issue
- When to auto-fix vs report to user

**Target audience**: `minecraft-code-validator` agent and all specialist agents

---

## Understanding get_file_problems Output

### Tool Output Format

```json
{
  "problems": [
    {
      "severity": "ERROR",
      "description": "Cannot resolve symbol 'MODID'",
      "line": 10,
      "column": 45,
      "file": "src/main/java/com/mod/ModItems.java"
    },
    {
      "severity": "WARNING",
      "description": "Method annotated with @SubscribeEvent but class lacks @Mod.EventBusSubscriber",
      "line": 25,
      "column": 5,
      "file": "src/main/java/com/mod/EventHandler.java"
    },
    {
      "severity": "INFO",
      "description": "Unused import 'java.util.List'",
      "line": 3,
      "column": 1,
      "file": "src/main/java/com/mod/ModItems.java"
    }
  ]
}
```

### Severity Levels

**ERROR** (Red, must fix):
- Code will not compile or run
- Missing symbols, syntax errors, type mismatches
- Critical safety issues (client code on server)
- **Action**: Must fix before code can be used

**WARNING** (Yellow, should fix):
- Code compiles but may have runtime issues
- Missing annotations, wrong patterns
- Deprecated API usage
- **Action**: Should fix to prevent runtime bugs

**INFO** (Blue, optional):
- Code style issues
- Unused imports, redundant casts
- Optimization opportunities
- **Action**: Fix for code quality but not critical

---

## Quick Reference: Common Inspections

### Registry Issues

| Description | Severity | Fix | Auto-fixable? |
|-------------|----------|-----|---------------|
| Cannot resolve symbol 'MODID' | ERROR | Define MODID constant | ❌ No |
| Type mismatch in DeferredRegister | ERROR | Fix generic type | ❌ No |
| Unused import | INFO | Remove import | ✅ Yes (reformat) |
| Missing registry call | WARNING | Call ITEMS.register() in constructor | ❌ No |

### Event Handler Issues

| Description | Severity | Fix | Auto-fixable? |
|-------------|----------|-----|---------------|
| Missing @Mod.EventBusSubscriber | WARNING | Add annotation | ✅ Yes |
| Non-static @SubscribeEvent method | WARNING | Make static or document manual registration | ✅ Yes (make static) |
| Wrong event bus | WARNING | Change bus type (MOD/FORGE) | ❌ No (requires analysis) |
| Wrong parameter type | WARNING | Use specific event class | ❌ No |

### Client/Server Safety

| Description | Severity | Fix | Auto-fixable? |
|-------------|----------|-----|---------------|
| Missing @OnlyIn(Dist.CLIENT) | WARNING | Add annotation | ✅ Yes |
| Client import in common code | ERROR | Move to client package or add side check | ❌ No |
| Minecraft.getInstance() on server | ERROR | Wrap in side check | ❌ No |

### NBT/Data

| Description | Severity | Fix | Auto-fixable? |
|-------------|----------|-----|---------------|
| putInt called with double | ERROR | Change to putDouble | ❌ No (logic decision) |
| Missing serialization interface | WARNING | Implement INBTSerializable | ❌ No |

### Code Formatting

| Description | Severity | Fix | Auto-fixable? |
|-------------|----------|-----|---------------|
| Wrong indentation | INFO | Reformat | ✅ Yes (reformat) |
| Missing spaces | INFO | Reformat | ✅ Yes (reformat) |
| Import order wrong | INFO | Reformat | ✅ Yes (reformat) |

---

## Auto-Fix Decision Matrix

### ✅ SAFE to Auto-Fix

**Criteria**: No logic changes, purely structural/stylistic

1. **Adding missing imports**
   - Example: `import net.minecraftforge.registries.DeferredRegister;`
   - Safe because: Just adds reference, doesn't change logic

2. **Adding standard annotations**
   - `@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)`
   - `@OnlyIn(Dist.CLIENT)`
   - Safe because: Standard patterns, predictable behavior

3. **Making methods static** (event handlers only)
   - `public void method()` → `public static void method()`
   - Safe because: Event handlers are stateless
   - **Exception**: Only if @EventBusSubscriber is present

4. **Code reformatting** (always safe)
   - Spacing, indentation, import organization
   - Safe because: Doesn't change behavior at all

### ❌ NEVER Auto-Fix

**Criteria**: Requires logic decisions or could break functionality

1. **Undefined symbols**
   - Example: `MODID` not defined
   - Unsafe because: Don't know correct value

2. **Type mismatches**
   - Example: `DeferredRegister<Block>` with `ForgeRegistries.ITEMS`
   - Unsafe because: Could break registration logic

3. **Wrong event bus** (MOD vs FORGE)
   - Unsafe because: Need to analyze event type

4. **Architectural changes**
   - Moving code to different packages
   - Refactoring class structure
   - Unsafe because: Could break dependencies

---

## Inspection Categories

### Category 1: Registry & Content

**Common inspections**:
- Cannot resolve symbol 'MODID', 'ITEMS', 'BLOCKS'
- Type mismatch in generic types
- Missing registration call
- Duplicate registry names

**See**: [minecraft-specific-inspections.md](./minecraft-specific-inspections.md#registry-errors) for detailed catalog

### Category 2: Events & Lifecycle

**Common inspections**:
- Missing @Mod.EventBusSubscriber
- Non-static event handler
- Wrong event bus (MOD vs FORGE)
- Wrong parameter type

**See**: [minecraft-specific-inspections.md](./minecraft-specific-inspections.md#event-handler-errors) for detailed catalog

### Category 3: Client/Server Safety

**Common inspections**:
- Missing @OnlyIn(Dist.CLIENT)
- Client-only imports in server code
- Minecraft.getInstance() calls
- Rendering code without side checks

**See**: [minecraft-specific-inspections.md](./minecraft-specific-inspections.md#client-server-safety-errors) for detailed catalog

### Category 4: NBT & Persistence

**Common inspections**:
- Wrong NBT tag type (putInt vs putDouble)
- Missing serialization interface
- Not calling setDirty()

**See**: [minecraft-specific-inspections.md](./minecraft-specific-inspections.md#nbt-serialization-errors) for detailed catalog

### Category 5: Resource Locations

**Common inspections**:
- Uppercase namespace
- Invalid characters
- Missing resource files

**See**: [minecraft-specific-inspections.md](./minecraft-specific-inspections.md#resource-location-errors) for detailed catalog

### Category 6: Code Style

**Common inspections**:
- Unused imports
- Wrong indentation
- Missing spaces
- Long lines without wrapping

**See**: [minecraft-specific-inspections.md](./minecraft-specific-inspections.md#code-formatting-issues) for detailed catalog

---

## Using This Skill in Code Validator

### Step 1: Run Inspections

```
Use mcp__intellij__get_file_problems to scan file
```

### Step 2: Categorize Issues

```
For each problem in results:
  - Identify category (Registry, Events, Client/Server, NBT, Resources, Style)
  - Determine Minecraft modding context
  - Look up in inspection catalog
```

### Step 3: Determine Fixes

```
For each problem:
  - Check auto-fix decision matrix
  - If auto-fixable → Apply fix
  - If not auto-fixable → Report to user with guidance
```

### Step 4: Report

```
Format output:
  - ❌ ERROR [Line X] Description
  - ⚠️ WARNING [Line Y] Description
  - ℹ️ INFO [Line Z] Description

For each:
  - Explain what it means
  - Why it's a problem
  - How to fix (if not auto-fixed)
```

---

## Example Workflows

### Workflow 1: Registry Validation

**Input**: ModItems.java with registry code

**Inspections found**:
1. ERROR: Cannot resolve symbol 'MODID'
2. INFO: Unused import 'java.util.List'

**Analysis**:
1. MODID - Cannot auto-fix (need user to define)
2. Unused import - Auto-fixable via reformat

**Actions**:
- Report ERROR to user with fix guidance
- Reformat file to remove unused import

**Output**:
```
❌ ERROR [Line 10] Cannot resolve symbol 'MODID'
   Explanation: The MODID constant is not defined.
   Fix needed: Define in main mod class:
               public static final String MODID = "yourmodid";

Auto-fixing...
✓ Removed unused import 'java.util.List' (via reformatting)
```

### Workflow 2: Event Handler Validation

**Input**: EventHandler.java with event methods

**Inspections found**:
1. WARNING: Missing @Mod.EventBusSubscriber
2. WARNING: Non-static @SubscribeEvent method

**Analysis**:
1. Missing annotation - Auto-fixable
2. Non-static method - Auto-fixable (make static)

**Actions**:
- Add @Mod.EventBusSubscriber annotation
- Make method static
- Reformat file

**Output**:
```
Auto-fixing...
✓ Added @Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE) to class
✓ Changed onPlayerLogin method to static
✓ Reformatted file

Revalidating...
✓ No errors or warnings found

EventHandler.java validated successfully!
```

---

## Best Practices

1. **Always check context** - Same inspection means different things in different code
2. **Prioritize errors** - Fix ERROR severity first, then WARNING, then INFO
3. **Batch similar fixes** - If 5 files need same annotation, mention pattern
4. **Explain educational value** - Help user understand WHY it's wrong
5. **Revalidate after fixes** - Always run inspections again after auto-fixes
6. **Format last** - Apply reformatting as final step (cleans up everything)

---

## References

- [minecraft-specific-inspections.md](./minecraft-specific-inspections.md) - Complete inspection catalog
- IntelliJ IDEA Documentation: https://www.jetbrains.com/help/idea/code-inspection.html
- Forge Documentation: https://docs.minecraftforge.net/
- Minecraft Modding Guide: https://forge.gemwire.uk/wiki/Main_Page

---

This skill enables intelligent interpretation of IntelliJ inspections for high-quality Minecraft mod code generation.
