---
name: intellij-navigation-patterns
description: Effective use of IntelliJ MCP navigation tools for Minecraft mods. Covers semantic search, symbol lookup, registry discovery, event handler location, resource mapping. Use when exploring codebases, finding patterns, or locating specific code elements.
allowed-tools: mcp__intellij__get_symbol_info, mcp__intellij__search_in_files_by_text, mcp__intellij__search_in_files_by_regex, mcp__intellij__find_files_by_name_keyword, mcp__intellij__find_files_by_glob
---

# IntelliJ Navigation Patterns for Minecraft Mods

This skill teaches effective use of IntelliJ MCP navigation tools for discovering and exploring Minecraft mod codebases.

## Purpose

**Goal**: Enable fast, accurate code discovery using IntelliJ IDEA's semantic understanding through MCP integration.

**Primary Users**:
- `intellij-code-navigator` agent (pre-loaded)
- All specialist agents when reference patterns are needed
- Orchestrator for discovery delegation

## Navigation Tool Performance Hierarchy

Understanding tool performance is critical for efficient navigation:

### Level 1: FASTEST - Indexed Search

**Tool**: `mcp__intellij__find_files_by_name_keyword`

**Performance**: <100ms
**Accuracy**: High for known filenames
**Token Cost**: Minimal

**Use when**:
- ✅ You know part of the filename
- ✅ Standard Minecraft naming (ModItems, ModBlocks, EventHandler)
- ✅ Initial file discovery

**Example**:
```
Task: Find items registry
→ find_files_by_name_keyword("ModItems")
→ Results in <100ms: ModItems.java, ModItemsClient.java
```

**Limitations**:
- ❌ Only searches filenames, not contents
- ❌ No pattern matching in names
- ❌ Won't find symbol usages

---

### Level 2: FAST - Pattern Matching

**Tool**: `mcp__intellij__find_files_by_glob`

**Performance**: <200ms
**Accuracy**: Excellent for file patterns
**Token Cost**: Low

**Use when**:
- ✅ Need resource files (models, textures, lang)
- ✅ Package exploration
- ✅ File type filtering

**Common Minecraft glob patterns**:
```
Items:
- **/models/item/*.json          (item models)
- **/textures/item/*.png          (item textures)

Blocks:
- **/models/block/*.json          (block models)
- **/blockstates/*.json           (blockstate definitions)
- **/textures/block/*.png         (block textures)

Lang files:
- **/lang/en_us.json              (English translations)
- **/lang/*.json                  (all languages)

Java packages:
- src/**/items/*.java             (item classes)
- src/**/blocks/*.java            (block classes)
- src/**/events/*.java            (event handlers)
```

**Example**:
```
Task: Find all block models
→ find_files_by_glob("**/models/block/*.json")
→ Results: List of all block model JSON files
```

---

### Level 3: MEDIUM - Content Search

**Tool**: `mcp__intellij__search_in_files_by_text`

**Performance**: <500ms (medium projects)
**Accuracy**: High for exact text
**Token Cost**: Medium

**Use when**:
- ✅ Searching for specific symbols (DeferredRegister, @SubscribeEvent)
- ✅ Finding string literals
- ✅ Locating imports

**Optimization**:
```
# Filter by file type
search_in_files_by_text("DeferredRegister", fileMask="*.java")

# Limit results
search_in_files_by_text("ITEMS", maxUsageCount=20)

# Case sensitivity
search_in_files_by_text("modId", caseSensitive=true)
```

**Example**:
```
Task: Find all DeferredRegister usages
→ search_in_files_by_text("DeferredRegister", fileMask="*.java")
→ Results: ModItems.java, ModBlocks.java, ModEntities.java
```

---

**Tool**: `mcp__intellij__search_in_files_by_regex`

**Performance**: <1000ms
**Accuracy**: High for patterns
**Token Cost**: Higher

**Use when**:
- ✅ Complex pattern matching
- ✅ Finding annotations with parameters
- ✅ Multi-token searches

**Common Minecraft regex patterns**:
```java
// Event handlers
@SubscribeEvent\s+public\s+(static\s+)?void\s+\w+

// Registry entries
DeferredRegister\.create\([^)]+\)

// Annotations
@Mod\.EventBusSubscriber\([^)]*\)

// Class declarations
class\s+\w+\s+extends\s+(Item|Block|Entity)
```

**Example**:
```
Task: Find all @SubscribeEvent methods
→ search_in_files_by_regex("@SubscribeEvent\\s+public\\s+(static\\s+)?void")
→ Results: All event handler methods
```

**When NOT to use**:
- ❌ Simple text search (use `search_in_files_by_text` instead - faster)
- ❌ Filename patterns (use `find_files_by_glob` instead)

---

### Level 4: SEMANTIC - Symbol Understanding

**Tool**: `mcp__intellij__get_symbol_info`

**Performance**: <200ms
**Accuracy**: Excellent
**Token Cost**: Low

**Use when**:
- ✅ Understanding what a symbol is
- ✅ Getting documentation
- ✅ Finding declaration location
- ✅ Type information needed

**Example**:
```
After finding: ModItems.java:42 contains "RUBY_SWORD"
→ get_symbol_info(file="ModItems.java", line=42, column=30)
→ Returns: Type: RegistryObject<Item>, Declaration: line 42, Docs: "..."
```

---

## Decision Matrix: Which Tool to Use?

### Quick Reference

| Goal | Best Tool | Speed | Why |
|------|-----------|-------|-----|
| Find file by name | `find_files_by_name_keyword` | ⚡⚡⚡ | Indexed |
| Find resource files | `find_files_by_glob` | ⚡⚡ | Pattern matching |
| Find symbol usage | `search_in_files_by_text` | ⚡ | Text search |
| Find complex patterns | `search_in_files_by_regex` | 🐌 | Regex expensive |
| Understand symbol | `get_symbol_info` | ⚡⚡ | Semantic |

### Progressive Search Strategy

**Start fast, escalate only if needed**:

```
Level 1: find_files_by_name_keyword("ModItems")
  ↓ (not found or need more)
Level 2: search_in_files_by_text("ITEMS")
  ↓ (still not found or need patterns)
Level 3: find_files_by_glob("**/init/*.java")
  ↓ (need complex pattern)
Level 4: search_in_files_by_regex("DeferredRegister\\.create.*ITEMS")
```

---

## Minecraft-Specific Search Patterns

### Registry Discovery

**Objective**: Find DeferredRegister and RegistryObject entries

**Method 1: Name search** (FASTEST)
```
find_files_by_name_keyword("ModItems")
→ Directly finds ModItems.java
```

**Method 2: Symbol search** (if name unknown)
```
search_in_files_by_text("DeferredRegister<Item>")
→ Finds files with item registries
```

**Method 3: Pattern search** (comprehensive)
```
find_files_by_glob("**/init/*.java")
→ Finds all initialization classes
```

**📖 See [registry-discovery.md](./registry-discovery.md) for detailed patterns**

---

### Event Handler Location

**Objective**: Find @SubscribeEvent methods and determine bus type

**Method 1: Annotation search**
```
search_in_files_by_text("@SubscribeEvent")
→ Finds all event handlers
```

**Method 2: Pattern search** (with details)
```
search_in_files_by_regex("@Mod\\.EventBusSubscriber\\([^)]*\\)")
→ Finds class annotations with bus type
```

**Method 3: File-based** (if organized)
```
find_files_by_glob("**/events/*.java")
→ Finds event handler classes
```

**📖 See [event-handler-search.md](./event-handler-search.md) for detailed patterns**

---

### Resource File Mapping

**Objective**: Map code registry names to JSON/PNG resources

**Workflow**:
1. Find registry name in code
2. Use glob to find model: `**/models/item/{name}.json`
3. Read model to extract texture path
4. Find texture: `**/textures/item/{name}.png`
5. Find translation: Search for `item.modid.{name}`

**Example**:
```
Code: ITEMS.register("ruby_sword", ...)
→ Registry name: "ruby_sword"

Model: find_files_by_glob("**/models/item/ruby_sword.json")
→ Found: assets/modid/models/item/ruby_sword.json

Texture (from model): "modid:item/ruby_sword"
→ Expected: assets/modid/textures/item/ruby_sword.png

Lang: search_in_files_by_text("item.modid.ruby_sword")
→ Found in: assets/modid/lang/en_us.json
```

**📖 See [resource-file-mapping.md](./resource-file-mapping.md) for complete workflow**

---

## Performance Optimization Strategies

### Strategy 1: Use File Masks

**Filter by extension** to reduce search scope:
```
# Java files only
search_in_files_by_text("DeferredRegister", fileMask="*.java")

# JSON files only
search_in_files_by_text("minecraft:diamond", fileMask="*.json")
```

**Impact**: 50-70% faster searches

---

### Strategy 2: Limit Result Counts

**Set reasonable limits** to avoid token overload:
```
# Limit to 20 results (most common)
search_in_files_by_text("Item", maxUsageCount=20)

# Limit files found
find_files_by_glob("**/*.json", fileCountLimit=50)
```

**Impact**: Faster processing, reduced tokens

---

### Strategy 3: Progressive Depth

**Start narrow, expand if needed**:
```
Level 1: Search in /items/ package only
Level 2: Search in /init/ and /registry/ packages
Level 3: Search entire src/
```

**Example**:
```
# Narrow first
find_files_by_glob("src/**/items/ModItems.java")

# Expand if not found
find_files_by_glob("src/**/ModItems.java")

# Widen further
find_files_by_glob("**/ModItems.java")
```

---

### Strategy 4: Prefer Indexed Search

**Use name search whenever possible**:
```
# FAST (indexed)
find_files_by_name_keyword("ModItems")

# SLOW (content search)
search_in_files_by_text("class ModItems")
```

**Impact**: 5-10x speed improvement

---

## Common Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Using Regex for Simple Text

**Bad**:
```
search_in_files_by_regex("DeferredRegister")
```

**Good**:
```
search_in_files_by_text("DeferredRegister")
```

**Why**: Regex is slower and unnecessary for simple text

---

### ❌ Anti-Pattern 2: Not Using File Masks

**Bad**:
```
search_in_files_by_text("Item")
→ Searches .java, .json, .txt, .md, .gradle, etc.
```

**Good**:
```
search_in_files_by_text("Item", fileMask="*.java")
→ Searches only Java files
```

**Why**: 50%+ performance improvement

---

### ❌ Anti-Pattern 3: Not Limiting Results

**Bad**:
```
search_in_files_by_text("public")
→ Returns 1000+ results (token overload)
```

**Good**:
```
search_in_files_by_text("public", maxUsageCount=30)
→ Returns manageable 30 results
```

**Why**: Avoids token waste and improves processing speed

---

### ❌ Anti-Pattern 4: Using Content Search for Filenames

**Bad**:
```
search_in_files_by_text("ModItems.java")
→ Searches file contents for the string "ModItems.java"
```

**Good**:
```
find_files_by_name_keyword("ModItems")
→ Searches filenames directly (10x faster)
```

**Why**: Indexed filename search is much faster

---

## Real-World Examples

### Example 1: Find All Items in MusicMod

**Objective**: Discover all custom items in MusicMod project

**Workflow**:
```
Step 1: Find registry file
→ find_files_by_name_keyword("ModItems")
→ Found: src/main/java/com/musicmod/init/ModItems.java

Step 2: Read file and extract entries
→ Read("src/main/java/com/musicmod/init/ModItems.java")
→ Extract: RegistryObject<Item> pattern

Step 3: List items
→ MUSIC_DISC_1, MUSIC_DISC_2, ..., MUSIC_PLAYER
```

---

### Example 2: Locate Boss Bar in Apocalypse_TNT

**Objective**: Find where boss bar is created

**Workflow**:
```
Step 1: Search for BossBar
→ search_in_files_by_text("BossBar", fileMask="*.java")
→ Found in: ApocalypseManager.java, ClientEvents.java

Step 2: Analyze usage
→ Read both files
→ ApocalypseManager: Creates boss bar
→ ClientEvents: Renders boss bar

Step 3: Report
→ Boss bar created in ApocalypseManager.java:45
→ Boss bar rendered in ClientEvents.java:78
```

---

## Integration with Navigator Agent

The `intellij-code-navigator` agent uses this skill for:

1. **Tool Selection**: Choosing optimal tool based on query type
2. **Performance**: Following optimization strategies
3. **Patterns**: Applying Minecraft-specific search patterns
4. **Accuracy**: Avoiding anti-patterns

**Workflow**:
```
Navigator receives: "Find all PlayerTickEvent handlers"
→ Consults this skill
→ Decides: Use search_in_files_by_text("@SubscribeEvent")
→ Applies: fileMask="*.java" optimization
→ Executes search
→ Returns results
```

---

## Supporting Documentation

For detailed patterns and workflows, see:

1. **[registry-discovery.md](./registry-discovery.md)** - Finding DeferredRegister, RegistryObject patterns
2. **[event-handler-search.md](./event-handler-search.md)** - Locating @SubscribeEvent methods, bus types
3. **[resource-file-mapping.md](./resource-file-mapping.md)** - Mapping code to models/textures/lang

These supporting files are loaded on-demand for progressive knowledge loading.

---

## Summary

**Key Takeaways**:
- 📊 Performance hierarchy: Indexed > Glob > Text > Regex
- 🎯 Use file masks and limits for optimization
- 🚀 Progressive search: Start narrow, expand if needed
- ⚠️ Avoid anti-patterns (regex for text, no masks, unlimited results)
- 🔍 Minecraft-specific patterns for common tasks

**Success Metrics**:
- ✅ 90% of searches complete in <1 second
- ✅ Accurate results with minimal false positives
- ✅ Token-efficient (use indexed search first)
- ✅ Clear, actionable output
