---
name: intellij-navigation-patterns
description: Effective use of IntelliJ MCP navigation tools for Minecraft mods. Covers semantic search, symbol lookup, registry discovery, event handler location, resource mapping. Use when exploring codebases, finding patterns, or locating specific code elements.
allowed-tools: mcp__intellij__get_symbol_info, mcp__intellij__search_in_files_by_text, mcp__intellij__search_in_files_by_regex, mcp__intellij__find_files_by_name_keyword, mcp__intellij__find_files_by_glob
---

# IntelliJ Navigation Patterns

## What This Covers

- IntelliJ MCP navigation tool hierarchy
- Performance-optimized search strategies
- Symbol lookup and semantic navigation
- Registry and event handler discovery
- Resource file mapping

## When to Use

- Exploring unfamiliar Minecraft mod codebases
- Finding specific code elements (items, blocks, events)
- Locating registry code or event handlers
- Understanding project structure
- Discovering patterns across files

---

## Navigation Tool Performance Hierarchy

**Choose the fastest tool that can accomplish your goal**:

### Level 1: FASTEST - Indexed Search (find_files_by_name_keyword)
**Performance**: <100ms | **Token Cost**: Minimal

**Use when**:
- ✅ You know part of the filename
- ✅ Standard naming (ModItems, ModBlocks, EventHandler)

**Example**:
```
find_files_by_name_keyword("ModItems")
→ Results: ModItems.java, ModItemsClient.java
```

**Limitations**: Only searches filenames, not contents

### Level 2: FAST - Glob Pattern (find_files_by_glob)
**Performance**: <500ms | **Token Cost**: Low

**Use when**:
- ✅ Need path-based filtering
- ✅ Know directory structure
- ✅ Want specific file types

**Example**:
```
find_files_by_glob("**/events/**/*.java")
→ Results: All Java files in events directories
```

### Level 3: MODERATE - Text Search (search_in_files_by_text)
**Performance**: 1-5s | **Token Cost**: Moderate

**Use when**:
- ✅ Search for exact text/keywords
- ✅ Find method/class references
- ✅ Locate string literals

**Example**:
```
search_in_files_by_text("DeferredRegister.create", caseSensitive: false)
→ Results: All registry declarations
```

### Level 4: SLOWER - Regex Search (search_in_files_by_regex)
**Performance**: 2-10s | **Token Cost**: High

**Use when**:
- ✅ Complex pattern matching needed
- ✅ Multiple variations to find
- ✅ Text search insufficient

**Example**:
```
search_in_files_by_regex("@SubscribeEvent.*onPlayer\\w+")
→ Results: All player event handlers
```

### Level 5: DEEPEST - Symbol Info (get_symbol_info)
**Performance**: <1s | **Token Cost**: Moderate

**Use when**:
- ✅ Need type information
- ✅ Want symbol declaration
- ✅ Understanding symbol semantics

**Example**:
```
get_symbol_info("ModItems.java", line: 25, column: 30)
→ Returns: Symbol type, declaration, documentation
```

---

## Common Navigation Patterns

### Pattern 1: Find Item Registration

**Goal**: Locate where items are registered

**Strategy**:
1. `find_files_by_name_keyword("ModItems")` → Fast file discovery
2. Read `ModItems.java` → Examine registry code
3. If not found: `search_in_files_by_text("DeferredRegister<Item>")` → Broader search

### Pattern 2: Find Event Handlers

**Goal**: Locate specific event handler

**Strategy**:
1. `find_files_by_glob("**/events/**/*.java")` → Find event files
2. `search_in_files_by_text("PlayerTickEvent")` → Find specific event
3. Read matching files → Examine handler implementation

### Pattern 3: Discover Registry Pattern

**Goal**: Understand how mod registers content

**Strategy**:
1. `find_files_by_name_keyword("Mod")` → Find main mod class
2. Read mod class → Check initialization
3. `search_in_files_by_text("register(modEventBus)")` → Find all registrations
4. Read registry files → Document pattern

### Pattern 4: Locate Resource Files

**Goal**: Find models, textures, or data files

**Strategy**:
1. `find_files_by_glob("**/resources/assets/**/*.json")` → Find asset files
2. `find_files_by_glob("**/resources/data/**/*.json")` → Find data files
3. Filter by specific paths if needed

### Pattern 5: Find Symbol Definition

**Goal**: Understand what a specific symbol is

**Strategy**:
1. Locate file containing symbol
2. `get_symbol_info(file, line, column)` → Get type info and declaration
3. Navigate to declaration → Examine implementation

---

## Tool Selection Guide

### By Task Type

| Task | Best Tool | Fallback |
|------|-----------|----------|
| Find file by name | `find_files_by_name_keyword` | `find_files_by_glob` |
| Find all event handlers | `find_files_by_glob` | `search_in_files_by_text` |
| Find method usage | `search_in_files_by_text` | `search_in_files_by_regex` |
| Find pattern (complex) | `search_in_files_by_regex` | Multiple text searches |
| Understand symbol | `get_symbol_info` | Read file + context |

### By Knowledge Level

**Know exact filename?**
→ `find_files_by_name_keyword`

**Know directory structure?**
→ `find_files_by_glob`

**Know exact text to find?**
→ `search_in_files_by_text`

**Need pattern matching?**
→ `search_in_files_by_regex`

**Need semantic understanding?**
→ `get_symbol_info`

---

## Minecraft-Specific Patterns

### Finding Registry Code

**Forge/NeoForge**:
```
search_in_files_by_text("DeferredRegister.create")
→ Finds all registry declarations
```

**Fabric**:
```
search_in_files_by_text("Registry.register")
→ Finds all registrations
```

### Finding Event Handlers

**Forge/NeoForge**:
```
search_in_files_by_regex("@SubscribeEvent.*on\\w+Event")
→ Finds all event handlers
```

**Fabric**:
```
search_in_files_by_text("register(")
→ Look for event callback registrations
```

### Finding Data Generation

```
find_files_by_name_keyword("DataGen")
OR
search_in_files_by_text("GatherDataEvent")
```

---

## Performance Optimization Tips

### 1. Start with Fastest Tool
Always try faster tools first, fallback to slower ones only if needed.

### 2. Use File Masks
Limit search scope when possible:
```
search_in_files_by_text("@SubscribeEvent", fileMask: "*.java")
```

### 3. Limit Results
Use `maxUsageCount` to avoid overwhelming results:
```
search_in_files_by_text("register", maxUsageCount: 50)
```

### 4. Be Specific
More specific queries = faster results:
- ❌ search_in_files_by_text("Item")  // Too broad
- ✅ search_in_files_by_text("DeferredRegister<Item>")  // Specific

### 5. Combine Strategies
Use multiple tools in sequence:
```
1. find_files_by_name_keyword("ModItems") → Fast discovery
2. Read file → Examine structure
3. search_in_files_by_text(specific_pattern) → If needed
```

---

## Common Mistakes

### ❌ Using Regex When Text Search Suffices
```
// Overkill
search_in_files_by_regex("DeferredRegister.*create")

// Better
search_in_files_by_text("DeferredRegister.create")
```

### ❌ Not Using File Masks
```
// Slow: searches all files
search_in_files_by_text("ITEMS")

// Fast: only Java files
search_in_files_by_text("ITEMS", fileMask: "*.java")
```

### ❌ Starting with Slow Tools
```
// Bad: immediate regex search
search_in_files_by_regex("class.*Mod.*\\{")

// Good: start with fast file search
find_files_by_name_keyword("Mod")
```

---

## Supporting Documentation

### Detailed Guides
- [Tool Performance Benchmarks](./tool-performance-benchmarks.md) - Detailed performance data and optimization strategies
- [Advanced Search Patterns](./advanced-search-patterns.md) - Complex regex patterns for Minecraft code discovery
- [Symbol Navigation Guide](./symbol-navigation-guide.md) - Using get_symbol_info effectively
- [Multi-Module Navigation](./multi-module-navigation.md) - Navigating multi-loader projects

---

## Quick Decision Tree

**Starting fresh?**
→ `find_files_by_name_keyword` for main files

**Know directory structure?**
→ `find_files_by_glob` with patterns

**Looking for specific text?**
→ `search_in_files_by_text`

**Need pattern matching?**
→ `search_in_files_by_regex`

**Need to understand a symbol?**
→ `get_symbol_info`

---

Use this skill to navigate Minecraft mod codebases efficiently using IntelliJ MCP tools with optimal performance.
