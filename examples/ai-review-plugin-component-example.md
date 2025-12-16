# Example: AI-Powered Plugin Component Review

This example demonstrates how to use the `/ai-review-plugin-component` command for quality assurance.

## Example 1: Reviewing an Agent with Multiple Issues

### Component Under Review

**File**: `agents/example-agent.md`

```markdown
---
name: example_agent
description: Handles things
tools: Read Write Edit
model: sonnet
---

# Example Agent

This agent helps with stuff.

## Usage

Use this agent when you need help.

## Example

```java
public void doSomething() {
    // Code here
}
```
```

### Command

```bash
/ai-review-plugin-component agents/example-agent.md
```

### Review Output

```markdown
## 🤖 Plugin Component Review

**Component**: `agents/example-agent.md`
**Type**: Agent
**Reviewed**: 2025-12-10 14:30:00

---

### Summary

- **CRITICAL**: 1 🔴
- **HIGH**: 3 🟠
- **MEDIUM**: 2 🟡
- **LOW**: 1 ⚪
- **INFO**: 0 🔵

**Overall Grade**: D (Needs significant improvement)

---

### Issues by Category

#### 1. YAML Frontmatter (3 issues)

**[CRITICAL]** Invalid name format (line 2)
```yaml
# ❌ Current
name: example_agent      # Underscore not allowed

# ✅ Should be
name: example-agent      # Use kebab-case
```
**Auto-fixable**: Yes | **Effort**: Trivial

---

**[HIGH]** Missing required field: `permissionMode`
- YAML frontmatter must include `permissionMode`
- Choose from: `default`, `acceptEdits`, `bypassPermissions`, `plan`
- Add after `model` field

**Suggested fix**:
```yaml
---
name: example-agent
description: Handles things
tools: Read, Write, Edit
model: sonnet
permissionMode: default    # Add this
---
```
**Auto-fixable**: No | **Effort**: Trivial

---

**[MEDIUM]** Tools list formatting (line 4)
```yaml
# ❌ Current
tools: Read Write Edit    # Missing commas

# ✅ Should be
tools: Read, Write, Edit  # Comma-space separated
```
**Auto-fixable**: Yes | **Effort**: Trivial

---

#### 2. Content Structure (2 issues)

**[HIGH]** Missing "Core Responsibilities" section
- Agents should clearly list what they do
- Use bulleted list format
- Be specific about domain

**Suggested fix**:
```markdown
## Core Responsibilities

- Register items, blocks, and entities using DeferredRegister
- Configure item properties and creative tabs
- Handle RegistryObject setup for Forge/NeoForge
```
**Auto-fixable**: No | **Effort**: Easy

---

**[MEDIUM]** Missing "Behavioral Guidelines" section
- Add decision-making framework
- Clarify when to do X vs Y
- Document edge cases

**Suggested fix**:
```markdown
## Behavioral Guidelines

1. Always detect framework from build.gradle first
2. Use DeferredRegister for Forge/NeoForge (not @ObjectHolder)
3. Show framework-specific examples (Forge vs Fabric)
4. Cite source projects when showing code
```
**Auto-fixable**: No | **Effort**: Medium

---

#### 3. Code Examples (2 issues)

**[HIGH]** Pseudocode instead of real code (line 15)
```java
// ❌ Current (pseudocode)
public void doSomething() {
    // Code here
}

// ✅ Should be (real code from project)
// Example from MusicMod (Forge 1.20.1)
// Source: qingyi.thefatrat.registry.ItemRegistry:15

public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, TheFatRatMod.MOD_ID);

public static final RegistryObject<Item> MUSIC_DISC = ITEMS.register(
    "music_disc_overboard",
    () -> new RecordItem(15, ModSounds.OVERBOARD,
        new Item.Properties().stacksTo(1).rarity(Rarity.RARE), 3380)
);
```

**Impact**: Pseudocode leads to hallucinations and incorrect implementations.

**References**:
- CLAUDE.md - Convention: Real Code Examples
- examples/refactor-plugin-component-example.md

**Auto-fixable**: No | **Effort**: Medium

---

**[LOW]** Missing source citation
- Code examples should cite source project
- Format: `// Example from {Project} ({Framework} {Version})`
- Add: `// Source: {file}:{line}`

**Auto-fixable**: No | **Effort**: Easy

---

#### 4. Description Quality (1 issue)

**[HIGH]** Vague description lacks keywords
```yaml
# ❌ Current
description: Handles things    # Too generic

# ✅ Should be
description: Expert in item/block/entity registration using DeferredRegister. Use PROACTIVELY for RegistryObject setup, creative tab configuration, and Forge/NeoForge registry patterns.
```

**Why this matters**:
- Generic descriptions prevent auto-invocation
- Keywords enable Claude to select the right agent
- Specific descriptions set clear expectations

**Auto-fixable**: No | **Effort**: Easy

---

### AI-Enhanced Insights

**Claude 4.5 Sonnet Analysis**:

> **Effectiveness Concern**: The agent's instructions are too vague to be actionable. "This agent helps with stuff" doesn't guide Claude on HOW to help. Recommend adding specific step-by-step workflows.

> **Clarity Issue**: Missing decision framework. When should this agent be used vs other agents? What's its unique domain? Add explicit boundaries.

> **Quality Gap**: All code examples are pseudocode. This will cause hallucinations. Extract real patterns from MusicMod or Apocalypse_TNT projects.

> **Token Efficiency**: Agent is very short (50 lines), which is good. However, it lacks substance. Expanding with real examples and clear instructions is worth the token investment.

---

### Recommendations

#### Immediate Actions (Critical/High - Fix before commit)
1. ✅ **Auto-fix**: Change `example_agent` to `example-agent` (kebab-case)
2. ✅ **Auto-fix**: Format tools list with comma-space
3. ❌ **Manual**: Add `permissionMode: default` to frontmatter
4. ❌ **Manual**: Rewrite description with specific keywords
5. ❌ **Manual**: Replace pseudocode with real example from MusicMod
6. ❌ **Manual**: Add "Core Responsibilities" section
7. ❌ **Manual**: Add "Behavioral Guidelines" section

#### Medium Priority
8. Add source citations to code examples
9. Add more framework-specific examples (Forge vs Fabric)
10. Document edge cases in behavioral guidelines

#### Nice-to-Have (Low)
11. Add "Common Pitfalls" section
12. Link to related skills
13. Add more diverse examples

---

### Metrics

**Before Review**:
- Lines: 18
- Tokens: ~270
- YAML valid: ❌ (2 errors)
- Code examples: 100% pseudocode
- Clarity score: 2/10
- Quality grade: D

**After Fixes**:
- Lines: ~120 (estimated with improvements)
- Tokens: ~1,800 (includes real examples)
- YAML valid: ✅
- Code examples: 100% real code
- Clarity score: 9/10
- Quality grade: A-

**Token investment**: +1,530 tokens
**Value**: High - Real examples prevent hallucination, clear instructions improve accuracy

---

### Auto-Fix Available

2 issues can be auto-fixed:

```bash
# Run auto-fix (hypothetical)
/ai-review-plugin-component agents/example-agent.md --auto-fix

# Fixes applied:
# 1. name: example_agent → name: example-agent
# 2. tools: Read Write Edit → tools: Read, Write, Edit
```

Manual fixes required: 5 (CRITICAL: 0, HIGH: 3, MEDIUM: 2)

---

### Quality Checklist

**Agent Quality**:
- [❌] YAML frontmatter valid (2 errors)
- [❌] Description clarity (too vague)
- [⚠️] Tools list matches usage (formatting issue)
- [❌] Code examples real (100% pseudocode)
- [❌] Domain boundaries clear (not defined)
- [✅] Token efficiency (concise)

**Overall**: **2/6 passed** (33%) → Grade: **D**

**Action Required**: Cannot commit with CRITICAL issues. Fix and re-review.
```

### Fixed Version

After applying all recommendations:

```markdown
---
name: example-agent
description: Expert in item/block/entity registration using DeferredRegister. Use PROACTIVELY for RegistryObject setup, creative tab configuration, and Forge/NeoForge registry patterns. Handles items, blocks, entities across Forge, NeoForge, and Fabric frameworks.
tools: Read, Write, Edit, Grep, Glob
model: sonnet
permissionMode: default
skills: forge-registry-api, neoforge-registry-api, fabric-registry-api
---

# Example Agent - Registry Operations Expert

You are a specialized agent for handling Minecraft mod registry operations across multiple frameworks.

## Core Responsibilities

- Register items, blocks, and entities using DeferredRegister (Forge/NeoForge)
- Register using Fabric Registry API (Fabric/Quilt)
- Configure item properties (durability, stack size, rarity)
- Set up creative tabs and item groups
- Handle RegistryObject patterns correctly
- Ensure client-server compatibility

## Behavioral Guidelines

1. **Framework Detection First**: Always check `build.gradle` to detect framework
   - ForgeGradle → Forge
   - NeoGradle → NeoForge
   - Loom → Fabric/Quilt

2. **Use Correct Registry Pattern**:
   - Forge/NeoForge: DeferredRegister + RegistryObject
   - Fabric: Registry.register() with Identifier
   - Never mix patterns from different frameworks

3. **Cite Real Code**: Always show examples from MusicMod or Apocalypse_TNT with source citations

4. **Client-Server Awareness**: Remind about physical client vs logical client/server distinction

## Examples

### Forge 1.20.1 Pattern

```java
// Example from MusicMod (Forge 1.20.1)
// Source: qingyi.thefatrat.registry.ItemRegistry:15-25

package qingyi.thefatrat.registry;

import net.minecraft.world.item.Item;
import net.minecraft.world.item.RecordItem;
import net.minecraft.world.item.Rarity;
import net.minecraftforge.registries.DeferredRegister;
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraftforge.registries.RegistryObject;
import qingyi.thefatrat.TheFatRatMod;

public class ItemRegistry {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, TheFatRatMod.MOD_ID);

    public static final RegistryObject<Item> MUSIC_DISC_OVERBOARD = ITEMS.register(
        "music_disc_overboard",
        () -> new RecordItem(
            15,
            ModSounds.OVERBOARD,
            new Item.Properties().stacksTo(1).rarity(Rarity.RARE),
            3380  // Duration in ticks (169 seconds)
        )
    );

    // More items...
}

// In mod constructor:
public TheFatRatMod() {
    IEventBus modEventBus = FMLJavaModLoadingContext.get().getModEventBus();
    ItemRegistry.ITEMS.register(modEventBus);
}
```

**Key Points**:
- DeferredRegister created with ForgeRegistries.ITEMS
- Items registered as RegistryObjects with suppliers
- Registration deferred until mod initialization
- All registration in single class for organization

### Fabric 1.20.x Pattern

```java
// Fabric equivalent
package com.example.mod.registry;

import net.minecraft.item.Item;
import net.minecraft.registry.Registries;
import net.minecraft.registry.Registry;
import net.minecraft.util.Identifier;

public class ModItems {
    public static final Item CUSTOM_ITEM = Registry.register(
        Registries.ITEM,
        new Identifier("modid", "custom_item"),
        new Item(new Item.Settings())
    );

    public static void initialize() {
        // Called from mod initializer
    }
}
```

**Key Differences**:
- Direct registration (not deferred)
- Uses Identifier instead of resource location
- Called from mod initializer's onInitialize()

## Common Pitfalls

❌ **Don't**: Mix Forge and Fabric registry APIs
❌ **Don't**: Use @ObjectHolder (deprecated in 1.19+)
❌ **Don't**: Register in static initializers before mod construction
❌ **Don't**: Forget to register DeferredRegister to mod event bus

✅ **Do**: Use DeferredRegister for Forge/NeoForge
✅ **Do**: Detect framework before providing code
✅ **Do**: Organize all registrations in dedicated registry classes
✅ **Do**: Cite real working examples from user projects
```

### Re-Review Results

```markdown
## 🤖 Plugin Component Review (Re-Review)

**Component**: `agents/example-agent.md`
**Type**: Agent
**Reviewed**: 2025-12-10 15:00:00

---

### Summary

- **CRITICAL**: 0 🔴
- **HIGH**: 0 🟠
- **MEDIUM**: 0 🟡
- **LOW**: 1 ⚪
- **INFO**: 2 🔵

**Overall Grade**: A- (Good quality)

---

### Issues

**[LOW]** Consider adding Quilt examples
- Currently shows Forge and Fabric
- Quilt is mentioned in description but no example
- Not required, but nice for completeness

**[INFO]** Token count increased to ~2,100
- Justified: Real examples prevent hallucination
- Progressive loading not needed (still under threshold)

**[INFO]** All major issues resolved
- YAML valid ✅
- Real code examples ✅
- Clear responsibilities ✅
- Behavioral guidelines ✅
- Framework-specific ✅

---

### Quality Checklist

**Agent Quality**:
- [✅] YAML frontmatter valid
- [✅] Description clarity (specific keywords)
- [✅] Tools list matches usage
- [✅] Code examples real (100% from projects)
- [✅] Domain boundaries clear
- [✅] Token efficiency (appropriate)

**Overall**: **6/6 passed** (100%) → Grade: **A-**

**Status**: ✅ **Ready to commit**
```

## Example 2: Reviewing a Skill with Token Efficiency Issues

### Component Under Review

**File**: `skills/large-skill/SKILL.md` (800 lines)

### Command

```bash
/ai-review-plugin-component skills/large-skill/SKILL.md
```

### Review Output (Summary)

```markdown
## 🤖 Plugin Component Review

**Component**: `skills/large-skill/SKILL.md`
**Type**: Skill
**Overall Grade**: C (Token efficiency issues)

---

### Critical Issue

**[HIGH]** SKILL.md too large: 800 lines
- Target: ≤ 300 lines (ideally ~200)
- Current: 800 lines (~12,000 tokens)
- **Impact**: All 12,000 tokens load even if only basic info needed

**Recommendation**: Implement progressive loading

**Refactoring Plan**:

1. Keep in main SKILL.md (~200 lines):
   - Overview (what and when)
   - Core patterns (most common use cases)
   - Quick reference

2. Extract to supporting files:
   - `advanced-patterns.md` (lines 200-400)
   - `event-catalog.md` (lines 400-650)
   - `antipatterns.md` (lines 650-800)

3. Link from main SKILL.md:
```markdown
## Advanced Topics
- [Advanced Patterns](./advanced-patterns.md)
- [Event Catalog](./event-catalog.md)
- [Anti-Patterns](./antipatterns.md)
```

**Estimated Impact**:
- Before: ~12,000 tokens (always loaded)
- After: ~3,000 tokens (main) + ~300-500 per supporting file (on-demand)
- **Savings**: ~75% for typical usage
```

## Example 3: Reviewing Documentation

### Component Under Review

**File**: `CLAUDE.md`

### Command

```bash
/ai-review-plugin-component CLAUDE.md
```

### Review Output (Key Findings)

```markdown
## Cross-Reference Issues

**[HIGH]** Broken link: `docs/SKILLS.md` (line 142)
- Link target does not exist
- Create file or fix link

**[MEDIUM]** Outdated agent reference (line 78)
- References `old-agent-name` which was renamed to `new-agent-name`
- Update reference for consistency

## AI Insights

> "Agent selection table at line 156 is missing 2 recently added agents: `intellij-refactoring-master` and `intellij-build-and-test-runner`. This will cause confusion about when to use these agents."

> "Terminology inconsistency: 'DeferredRegister' vs 'Deferred Register' (with space). Standardize on 'DeferredRegister' (no space) throughout."
```

## Example 4: Batch Review with GitHub Actions

### Workflow Configuration

```yaml
# .github/workflows/plugin-quality.yml
name: Plugin Quality Review

on:
  pull_request:
    paths:
      - 'agents/**/*.md'
      - 'skills/**/SKILL.md'

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Review Components
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          changed_files=$(git diff --name-only origin/master...HEAD | \
            grep -E 'agents/.*\.md|skills/.*/SKILL\.md')

          for file in $changed_files; do
            python scripts/ai_review_plugin.py \
              --component "$file" \
              --output "review-${file//\//-}.json"
          done

      - name: Check Quality Gate
        run: |
          jq -s 'add' review-*.json > aggregate.json

          CRITICAL=$(jq '[.[] | select(.severity == "CRITICAL")] | length' aggregate.json)
          HIGH=$(jq '[.[] | select(.severity == "HIGH")] | length' aggregate.json)

          if [ $CRITICAL -gt 0 ]; then
            echo "❌ Cannot merge: $CRITICAL CRITICAL issues"
            exit 1
          fi

          if [ $HIGH -gt 5 ]; then
            echo "⚠️ Warning: $HIGH HIGH issues"
          fi
```

### Example PR Comment

```markdown
## 🤖 AI Review Results

**Components Reviewed**: 3
- `agents/new-feature-agent.md`
- `skills/new-pattern/SKILL.md`
- `CLAUDE.md`

---

### Summary

| Severity | Count |
|----------|-------|
| 🔴 CRITICAL | 0 |
| 🟠 HIGH | 2 |
| 🟡 MEDIUM | 4 |
| ⚪ LOW | 3 |

**Status**: ⚠️ **2 HIGH issues** - Review recommended before merge

---

### HIGH Issues

**agents/new-feature-agent.md:42**
> **Pseudocode in example**
> Replace generic code with real example from MusicMod or Apocalypse_TNT.

**skills/new-pattern/SKILL.md:frontmatter**
> **Missing keywords in description**
> Add: `DeferredRegister`, `RegistryObject`, `registration patterns`

---

[View Full Report](./review-results.json)
```

## Lessons Learned

### 1. YAML Validation is Essential

Invalid YAML prevents plugin from loading. Always run review before committing.

### 2. Real Code > Pseudocode (Always)

Every pseudocode example flagged as HIGH severity. Real code from projects is mandatory.

### 3. Token Efficiency Matters

Skills >400 lines should use progressive loading. 50-75% token savings is significant.

### 4. Keywords Enable Auto-Loading

Vague skill descriptions prevent Claude from loading the right skill. Be specific.

### 5. Cross-References Break Easily

Regular validation prevents broken links from accumulating.

### 6. AI Insights Find Context Issues

Claude 4.5 Sonnet catches domain overlap, unclear instructions, and missing sections that automated checks miss.

## Integration Patterns

### Pattern 1: Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

changed=$(git diff --cached --name-only | grep -E '\.md$')

for file in $changed; do
  /ai-review-plugin-component "$file" --fail-on-critical
done
```

### Pattern 2: CI/CD Pipeline

```yaml
steps:
  - name: Review
    run: /ai-review-plugin-component {files}
  - name: Quality Gate
    run: check_for_critical_issues()
```

### Pattern 3: Manual Review

```bash
# Before committing new component
/ai-review-plugin-component agents/new-agent.md

# Review and fix issues
# Re-review
/ai-review-plugin-component agents/new-agent.md

# Commit when grade is A or B
git add agents/new-agent.md
git commit -m "Add new-agent (Grade: A-)"
```

## Best Practices

1. **Review before commit**: Catch issues early
2. **Fix CRITICAL immediately**: Don't commit with CRITICAL issues
3. **Aim for A or B grade**: C or below needs improvement
4. **Use auto-fix when available**: Saves time on trivial formatting
5. **Re-review after fixes**: Verify improvements worked
6. **Track metrics over time**: Monitor plugin quality trends
7. **Integrate with CI/CD**: Automate quality checks

## Summary

The AI review command provides comprehensive quality assurance:
- **9 analysis layers** from YAML to AI insights
- **Severity classification** for prioritization
- **Auto-fix capability** for trivial issues
- **Token efficiency metrics** for optimization
- **AI-enhanced context analysis** with Claude 4.5 Sonnet
- **CI/CD integration** for automation

Use this to maintain high quality across all plugin components!
