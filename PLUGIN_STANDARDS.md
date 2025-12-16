# Qingyi Plugin Quality Standards

**Version**: 1.0
**Last Updated**: 2025-12-10

This document serves as the **single source of truth** for quality standards used across all plugin commands (`/refactor-plugin-component`, `/ai-review-plugin-component`). When standards need updating, modify this file only—both commands reference these standards.

---

## 1. Claude Model Version Mappings

**Current Mappings** (as of 2025-12-10):

| Short Name | Full API Model ID | Description |
|------------|-------------------|-------------|
| `sonnet` | claude-3-5-sonnet-20241022 | Claude 3.5 Sonnet - Balanced performance |
| `opus` | claude-opus-4-5-20251101 | Claude Opus 4.5 - Most capable, best reasoning |
| `haiku` | claude-3-5-haiku-20241022 | Claude 3.5 Haiku - Fastest, cost-effective |
| `inherit` | *(uses parent/default)* | Inherits model from parent context |

### Valid Values
Agents should use **short names** in YAML frontmatter:
```yaml
model: sonnet    # ✅ Correct
model: opus      # ✅ Correct
model: haiku     # ✅ Correct
model: inherit   # ✅ Correct
```

### Deprecated Models
**Flag as MEDIUM severity** when found:
- `claude-3-sonnet-*` (e.g., claude-3-sonnet-20240229)
  - **Recommendation**: Upgrade to `sonnet` (maps to Claude 3.5 Sonnet)
  - **Reason**: Better performance and capabilities

- `claude-3-opus-*` (e.g., claude-3-opus-20240229)
  - **Recommendation**: Upgrade to `opus` (maps to Claude Opus 4.5)
  - **Reason**: Significantly improved reasoning

- `claude-2.*` (e.g., claude-2.1, claude-2.0)
  - **Recommendation**: Upgrade to `sonnet` or `opus`
  - **Reason**: Major capability upgrade, better instruction following

### Invalid Models
**Flag as CRITICAL severity** when found:
- `gpt-*` (e.g., gpt-4, gpt-3.5-turbo)
  - **Reason**: Not a Claude model, incompatible with plugin
  - **Fix**: Replace with `sonnet`

- `gemini-*` (e.g., gemini-pro, gemini-ultra)
  - **Reason**: Not a Claude model, incompatible with plugin
  - **Fix**: Replace with `sonnet`

### Migration Guide

```markdown
**From claude-3-sonnet-\*** → **To: sonnet**
- Maps to Claude 3.5 Sonnet (latest)
- Auto-updates to latest 3.5 Sonnet version
- ~30% performance improvement

**From claude-3-opus-\*** → **To: opus**
- Maps to Claude Opus 4.5 (most capable)
- 2x better reasoning on complex tasks
- Best for architectural decisions

**From claude-2.\*** → **To: sonnet or opus**
- Major capability upgrade
- Longer context window (200K tokens)
- Better instruction following

**From gpt-\* / gemini-\*** → **To: sonnet**
- This is a Claude Code plugin (Claude models only)
- Replace with appropriate Claude model
```

---

## 2. Token Efficiency Standards

### Main SKILL.md File Size Thresholds

| Lines | Status | Action Required |
|-------|--------|-----------------|
| ≤200 | **IDEAL** ✅ | Perfect - maintain this size |
| 201-300 | **ACCEPTABLE** ⚪ | Good - no action needed |
| 301-400 | **WARNING** 🟡 | Consider progressive loading |
| 401-600 | **HIGH** 🟠 | Should implement progressive loading |
| >600 | **CRITICAL** 🔴 | **Must** implement progressive loading |

### Progressive Loading Structure

When SKILL.md exceeds 300 lines, implement this structure:

```
skills/skill-name/
├── SKILL.md                 # 200-300 lines (overview + core patterns)
├── advanced-patterns.md     # 150-300 lines (loaded on-demand)
├── antipatterns.md          # 100-200 lines (loaded when debugging)
└── event-catalog.md         # 200-400 lines (loaded when searching)
```

### Token Savings Target
- **Goal**: 50-75% token reduction via progressive loading
- **Method**: Main file contains overview and most common patterns; supporting files loaded only when Claude needs specific details
- **Links**: Use relative markdown links: `[Advanced Topics](./advanced-patterns.md)`

### Example Calculation

**Before**:
- Single file: 800 lines = ~12,000 tokens (always loaded)

**After**:
- Main file: 200 lines = ~3,000 tokens (typical load)
- Supporting files: 3×200 lines = ~9,000 tokens (on-demand)
- **Savings**: 75% for typical usage (9,000 tokens not loaded unless needed)

---

## 3. YAML Frontmatter Standards

### Required Fields by Component Type

#### Agents (`agents/*.md`)
```yaml
---
name: kebab-case                  # REQUIRED
description: "Specific keywords" # REQUIRED
tools: Read, Write, Edit          # REQUIRED (comma-space separated)
model: sonnet                     # REQUIRED (see Model Mappings)
permissionMode: default           # REQUIRED (default|acceptEdits|bypassPermissions|plan)
skills: skill1, skill2            # OPTIONAL (comma-space separated)
---
```

#### Skills (`skills/*/SKILL.md`)
```yaml
---
name: kebab-case                  # REQUIRED
description: "Specific keywords" # REQUIRED
allowed-tools: Read, Grep         # OPTIONAL (if restricting tools)
---
```

### Formatting Rules

| Rule | Format | Example |
|------|--------|---------|
| **Name** | kebab-case only | `example-agent` ✅ `example_agent` ❌ |
| **Lists** | Comma-space separated | `Read, Write, Edit` ✅ `Read,Write,Edit` ❌ |
| **Strings** | Quote if special chars | `description: "Use PROACTIVELY"` |
| **Model** | Use short names | `model: sonnet` ✅ `model: claude-3-5-sonnet` ❌ |
| **Boolean** | true/false lowercase | `auto_invoke: true` |

### Common YAML Errors

❌ **Underscore in name**: `name: example_agent`
✅ **Correct**: `name: example-agent`

❌ **No spaces in lists**: `tools: Read,Write,Edit`
✅ **Correct**: `tools: Read, Write, Edit`

❌ **Full API model name**: `model: claude-3-5-sonnet-20241022`
✅ **Correct**: `model: sonnet`

---

## 4. Code Example Quality Standards

### Real Code vs Pseudocode

**CRITICAL RULE**: All code examples **must** come from actual user projects.

#### ❌ Pseudocode (FORBIDDEN)
```java
// Generic example
public void doSomething() {
    // Implementation here
}
```

#### ✅ Real Code (REQUIRED)
```java
// Example from MusicMod (Forge 1.20.1)
// Source: qingyi.thefatrat.registry.ItemRegistry:15-25

public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, TheFatRatMod.MOD_ID);

public static final RegistryObject<Item> MUSIC_DISC_OVERBOARD = ITEMS.register(
    "music_disc_overboard",
    () -> new RecordItem(15, ModSounds.OVERBOARD,
        new Item.Properties().stacksTo(1).rarity(Rarity.RARE), 3380)
);
```

### Required Elements

Every code example must include:

1. **Source Citation**
   - Project name (e.g., MusicMod, Apocalypse_TNT)
   - Framework and version (e.g., Forge 1.20.1, NeoForge 1.21.3)
   - File path: `qingyi.thefatrat.registry.ItemRegistry`
   - Line numbers: `:15-25`

2. **Complete Context**
   - Import statements (if relevant to understanding)
   - Class structure (not just method snippets)
   - Full implementation (not just signatures)

3. **Framework Specification**
   - Mark each example with framework: `// Forge 1.20.1`, `// Fabric 1.20.x`
   - Version compatibility: `1.19.x`, `1.20.x`, `1.21.x`
   - Multiple variants if applicable (Forge vs Fabric)

4. **Explanatory Comments**
   - Why this pattern works
   - Non-obvious implementation details
   - Common pitfalls to avoid

### Severity Classification

| Issue | Severity |
|-------|----------|
| Pseudocode instead of real code | **HIGH** 🟠 |
| Missing source citation | **MEDIUM** 🟡 |
| Incomplete context (snippets only) | **MEDIUM** 🟡 |
| No framework specification | **MEDIUM** 🟡 |
| Missing explanatory comments | **LOW** ⚪ |

---

## 5. Framework Compatibility Standards

### Supported Frameworks

| Framework | Versions | Detection Method |
|-----------|----------|------------------|
| **Forge** | 1.19.x, 1.20.x | ForgeGradle in build.gradle, mods.toml exists |
| **NeoForge** | 1.20.x, 1.21.x | NeoGradle in build.gradle, mods.toml with Neo marker |
| **Fabric** | 1.19.x, 1.20.x, 1.21.x | Loom in build.gradle, fabric.mod.json exists |
| **Quilt** | 1.19.x, 1.20.x | Loom in build.gradle, quilt.mod.json exists |

### Framework Marking Requirements

**Every code example must be clearly marked:**

```java
// ✅ Good: Framework specified
**Forge 1.20.1+**:
```java
public static final DeferredRegister<Item> ITEMS = ...
```

**Fabric 1.20.x**:
```java
public static final Item ITEM = Registry.register(...);
```

// ❌ Bad: Unmarked code
```java
public static void register() {
    // Which framework? Unclear!
}
```
```

### Multi-Framework Patterns

When patterns differ between frameworks, show both:

```markdown
### Item Registration

**Forge/NeoForge**:
```java
// DeferredRegister pattern
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MODID);
```

**Fabric/Quilt**:
```java
// Direct registry pattern
public static final Item CUSTOM_ITEM = Registry.register(
    Registries.ITEM, new Identifier(MODID, "item"), new Item(...)
);
```
```

### Deprecated API Handling

Flag deprecated APIs with migration notes:

```java
// ❌ DEPRECATED (Forge 1.18): @ObjectHolder
@ObjectHolder("modid:item_name")
public static Item CUSTOM_ITEM;

// ✅ CURRENT (Forge 1.20.1+): DeferredRegister
public static final RegistryObject<Item> CUSTOM_ITEM = ITEMS.register(...);

// Migration Note: If upgrading from 1.18, replace @ObjectHolder with DeferredRegister
```

---

## 6. Keyword Optimization Standards (Skills)

### Purpose
Skill descriptions must contain **specific keywords** that trigger auto-loading when users ask related questions.

### Keyword Categories

1. **API Names** (Exact matches)
   - Example: `DeferredRegister`, `@SubscribeEvent`, `RegistryObject`
   - Why: Users often ask "how do I use DeferredRegister?"

2. **Framework Terms** (Concepts)
   - Example: `event bus`, `tick handler`, `capability system`
   - Why: Users search for concepts, not just API names

3. **Technical Concepts** (Patterns)
   - Example: `registration`, `serialization`, `rendering pipeline`
   - Why: Users may not know exact API names

4. **Common Operations** (Actions)
   - Example: `register items`, `handle events`, `save data`
   - Why: Users describe what they want to do

### Coverage Targets

| Metric | Target | Status |
|--------|--------|--------|
| Keyword-Content Match Rate | >80% | Keywords in description match actual content |
| API Coverage | >70% | % of APIs mentioned in description |
| Auto-Loading Success Prediction | >80% | Claude loads skill for relevant queries |

### Example: Good vs Bad

❌ **Bad (Vague)**:
```yaml
name: forge-events
description: Forge mod API    # Too generic!
```

✅ **Good (Specific)**:
```yaml
name: forge-event-system
description: Forge event bus, @SubscribeEvent handlers, event priorities, PlayerEvent, EntityEvent, BlockEvent, tick handlers (ClientTickEvent, ServerTickEvent), event cancellation. Use for event-driven logic, lifecycle hooks, and game loop integration.
```

**Why good works**:
- Contains specific API names (`@SubscribeEvent`, `PlayerEvent`)
- Includes framework terms (`event bus`, `tick handlers`)
- Lists concrete event types (`ClientTickEvent`, `ServerTickEvent`)
- Mentions concepts (`event-driven logic`, `lifecycle hooks`)

### Testing Auto-Loading

**Test queries** that should trigger skill loading:
- "How do I use @SubscribeEvent?"
- "What's the event bus in Forge?"
- "How to handle tick events?"
- "PlayerEvent vs EntityEvent?"

If skill doesn't load for these queries, **add missing keywords** to description.

---

## 7. Cross-Reference Validation Standards

### Link Formats

| Link Type | Format | Example |
|-----------|--------|---------|
| **Relative (Same Dir)** | `./file.md` | `[Advanced](./advanced.md)` |
| **Relative (Parent)** | `../file.md` | `[CLAUDE.md](../../CLAUDE.md)` |
| **Section Anchor** | `#section-name` | `[Model Versions](#model-versions)` |
| **External** | Full URL | `[Forge Docs](https://docs.minecraftforge.net/)` |

### Validation Rules

1. **File Paths**
   - All relative paths must resolve (`./supporting.md` file exists)
   - No broken links (404 errors)
   - Use forward slashes `/` (not backslashes `\`)

2. **Agent-Skill References**
   - Skills listed in agent frontmatter must exist
   - `skills: forge-registry-api` → `skills/forge-registry-api/SKILL.md` exists

3. **Orchestrator Delegation**
   - Agents referenced in orchestrator's delegation guide exist
   - Delegation logic matches actual agent domains

4. **Documentation Consistency**
   - CLAUDE.md agent selection table matches actual agents
   - All agents documented in table
   - No orphaned agents (exist but not documented)

### Common Issues

❌ `[link](./non-existent.md)` → File doesn't exist
✅ `[link](./existing-file.md)` → File exists

❌ `skills: non-existent-skill` → Skill directory not found
✅ `skills: forge-registry-api` → `skills/forge-registry-api/` exists

---

## 8. Consistency Standards

### Terminology Dictionary

Use these **exact terms** consistently across all components:

| Correct | Avoid |
|---------|-------|
| DeferredRegister | Registry manager, Deferred registry |
| event bus | event system, event manager |
| progressive loading | lazy loading, on-demand loading |
| frontmatter | metadata, header, YAML header |
| kebab-case | dash-case, hyphen-case |
| auto-invocation | automatic invocation, auto-invoke |
| source citation | source reference, code citation |

### Naming Conventions

| Component | Convention | Example |
|-----------|------------|---------|
| Agents | kebab-case | `registry-and-content-expert.md` |
| Skills | kebab-case | `forge-registry-api/` |
| Supporting Files | kebab-case | `advanced-patterns.md` |
| Projects | TitleCase: Variant | `MusicMod: TheFatRat` |

### Markdown Formatting

| Element | Format |
|---------|--------|
| **Headings** | `# H1`, `## H2`, `### H3` (no skip levels) |
| **Lists** | `-` for unordered, `1.` for ordered |
| **Code Blocks** | ` ```language` with language specified |
| **Emphasis** | `**bold**`, `*italic*` (not `__bold__`, `_italic_`) |
| **Links** | `[text](url)` (not bare URLs) |

---

## 9. Quality Workflows

### Recommended Command Usage Order

#### For New Components (Creating agent/skill)

1. **Create** → Write new agent or skill
2. **Review First** → `/ai-review-plugin-component <file>`
   - Identifies CRITICAL/HIGH issues
   - Provides quality grade (A-F)
3. **Fix Critical Issues** → Manually fix CRITICAL/HIGH
4. **Refactor** → `/refactor-plugin-component <file>`
   - Structural improvements
   - Pattern extraction
   - Progressive loading conversion
5. **Re-Review** → `/ai-review-plugin-component <file>`
   - Verify Grade A or B
6. **Commit** → Only commit if Grade A or B

#### For Existing Components (Maintenance)

**Quality Check**: `/ai-review-plugin-component <file>`
- Before commits
- PR automation
- Regular audits

**Large Changes**: `/refactor-plugin-component <file>`
- Split agents
- Progressive loading
- Pattern extraction

### When to Use Each Command

| Scenario | Command | Reason |
|----------|---------|--------|
| Before commit | Review | Catch issues early |
| PR automation | Review | Automated quality gate |
| Agent too generic | Refactor | Split into specialized agents |
| Skill >400 lines | Refactor | Convert to progressive loading |
| Pseudocode found | Review → Fix → Re-review | Identify, fix, validate |
| Domain overlap | Refactor | Merge or clarify boundaries |
| Broken links | Review | Detect invalid references |
| Outdated models | Review → Refactor | Detect, update, validate |

### Quality Gates

**Do NOT commit if**:
- Grade D or F
- Any CRITICAL issues
- >5 HIGH issues
- Invalid YAML (plugin won't load)

**Safe to commit if**:
- Grade A or B
- No CRITICAL issues
- ≤2 HIGH issues
- All tests pass (if applicable)

---

## 10. Version History

### v1.0 (2025-12-10)
- Initial standards document
- Consolidated model version mappings
- Unified token efficiency thresholds
- Defined YAML validation rules
- Established code quality standards
- Created keyword optimization criteria
- Documented recommended workflows

### Future Updates

When updating standards:
1. Update this file first (single source of truth)
2. Update version number and date
3. Add changelog entry
4. Commands will automatically reference latest standards
5. No need to update command files unless structure changes

---

## Reference

This document is referenced by:
- `.claude/commands/refactor-plugin-component.md`
- `.claude/commands/ai-review-plugin-component.md`
- `.claude/commands/README.md`

**Maintenance**: When standards evolve (new Claude models, new frameworks, updated thresholds), update ONLY this file. Commands reference it dynamically.
