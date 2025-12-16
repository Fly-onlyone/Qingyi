# Tool Selection Guide - IntelliJ Code Navigator

Complete reference for selecting the optimal navigation tool for any Minecraft mod code discovery task.

## Performance Metrics

### Tool Speed Comparison

| Tool | Avg Time | Token Cost | Index | Best For |
|------|----------|------------|-------|----------|
| find_files_by_name_keyword | 50-100ms | Minimal | ✅ Yes | Known filenames |
| find_files_by_glob | 100-500ms | Low | ✅ Yes | Path patterns |
| list_directory_tree | 200-300ms | Low | ✅ Yes | Structure overview |
| search_in_files_by_text | 1-5s | Moderate | ❌ No | Exact text search |
| search_in_files_by_regex | 2-10s | High | ❌ No | Pattern matching |
| get_symbol_info | 100-500ms | Moderate | ✅ Yes | Symbol semantics |

### Real-World Benchmarks

**Test Project**: Medium mod (500 files, 50k lines)

```
find_files_by_name_keyword("ModItems") → 67ms
find_files_by_glob("**/items/*.java") → 234ms
search_in_files_by_text("DeferredRegister") → 1.8s
search_in_files_by_regex("@SubscribeEvent.*onPlayer\\w+") → 4.2s
```

**Test Project**: Large multi-loader mod (1200 files, 120k lines)

```
find_files_by_name_keyword("ModItems") → 89ms
find_files_by_glob("**/forge/items/*.java") → 456ms
search_in_files_by_text("DeferredRegister", fileMask="*.java") → 2.4s
search_in_files_by_regex("@SubscribeEvent.*onPlayer\\w+") → 8.7s
```

**Lesson**: Always start with indexed tools (file search) before content search.

---

## Tool 1: find_files_by_name_keyword

### When to Use

**✅ Perfect For**:
- Finding files by class name: `find_files_by_name_keyword("ModItems")`
- Locating specific classes: `find_files_by_name_keyword("CustomEntity")`
- Standard naming conventions: `find_files_by_name_keyword("EventHandler")`
- Quick discovery of known components

**❌ Not Good For**:
- Finding by package name (use glob instead)
- Searching file contents (use text search)
- Complex patterns (use glob or regex)

### Parameters

```typescript
find_files_by_name_keyword(
  nameKeyword: string,        // Partial filename (case-insensitive)
  projectPath?: string,       // Optional: specific project
  fileCountLimit?: number,    // Default: 100
  timeout?: number           // Default: 5000ms
)
```

### Examples

**Example 1: Find main mod class**
```
find_files_by_name_keyword("Mod")
→ Results: MyMod.java, ModItems.java, ModBlocks.java, ModConfig.java
```

**Example 2: Find registry classes**
```
find_files_by_name_keyword("Registry")
→ Results: ModRegistry.java, EntityRegistry.java, ItemRegistry.java
```

**Example 3: Find event handlers**
```
find_files_by_name_keyword("Events")
→ Results: ForgeEvents.java, ClientEvents.java, CommonEvents.java
```

### Optimization Tips

1. **Use specific keywords**: `"ModItems"` better than `"Items"`
2. **Limit results**: Set `fileCountLimit=20` for large projects
3. **Case insensitive**: Searches are case-insensitive by default
4. **Partial matching**: `"Mod"` matches `ModItems.java`, `CustomMod.java`

### Common Pitfalls

**❌ Too broad keyword**:
```
find_files_by_name_keyword("Item")
→ Returns: 47 files (ItemStack, ModItems, CustomItem, ItemHelper, etc.)
```

**✅ Specific keyword**:
```
find_files_by_name_keyword("ModItems")
→ Returns: 2 files (ModItems.java, ModItemsClient.java)
```

---

## Tool 2: find_files_by_glob

### When to Use

**✅ Perfect For**:
- Finding files by path pattern: `**/models/item/*.json`
- Resource file discovery: `**/assets/*/lang/*.json`
- Package-based searches: `**/events/**/*.java`
- File type filtering: `**/*.png`

**❌ Not Good For**:
- Searching file contents
- Finding by class name only (use name_keyword)
- Semantic searches

### Parameters

```typescript
find_files_by_glob(
  globPattern: string,        // Glob pattern (** for recursive)
  path?: string,             // Base directory (default: project root)
  fileCountLimit?: number,   // Default: 100
  subDirectoryRelativePath?: string,
  timeout?: number
)
```

### Glob Pattern Syntax

```
*        Single directory level, any name
**       Recursive (all subdirectories)
?        Single character wildcard
[abc]    Character class
{a,b}    Alternatives

Examples:
**/models/item/*.json      All item models recursively
src/**/*.java              All Java files in src
**/assets/*/lang/en_us.json  All English lang files
```

### Examples

**Example 1: Find all item models**
```
find_files_by_glob("**/resources/assets/*/models/item/*.json")
→ Results: ruby_sword.json, diamond_staff.json, custom_block.json
```

**Example 2: Find event handler classes**
```
find_files_by_glob("**/events/**/*.java")
→ Results: ForgeEvents.java, ClientEvents.java, ServerEvents.java
```

**Example 3: Find all textures**
```
find_files_by_glob("**/resources/assets/*/textures/**/*.png")
→ Results: All PNG textures in all mods
```

**Example 4: Find Forge-specific files in multi-loader**
```
find_files_by_glob("**/forge/**/*.java")
→ Results: All Java files in Forge module
```

### Optimization Tips

1. **Be specific**: `**/models/item/*.json` better than `**/*.json`
2. **Use file masks**: `*.java` to filter by extension
3. **Limit depth**: Avoid `**/**/**` patterns
4. **Set limits**: Use `fileCountLimit` for large results

### Common Patterns for Minecraft Mods

```
# Registry files
**/init/**/*.java
**/registry/**/*.java

# Event handlers
**/events/**/*.java
**/handlers/**/*.java

# Models
**/models/block/*.json
**/models/item/*.json

# Recipes
**/data/*/recipes/*.json

# Loot tables
**/data/*/loot_tables/**/*.json

# Lang files
**/assets/*/lang/*.json

# Block states
**/blockstates/*.json
```

---

## Tool 3: search_in_files_by_text

### When to Use

**✅ Perfect For**:
- Finding exact text: `"DeferredRegister.create"`
- Locating method calls: `"Registry.register"`
- String literals: `"ruby_sword"`
- Class references: `"PlayerTickEvent"`

**❌ Not Good For**:
- Pattern matching (use regex)
- File name search (use glob)
- Partial word matching (use regex)

### Parameters

```typescript
search_in_files_by_text(
  searchText: string,         // Exact text to find
  caseSensitive?: boolean,    // Default: true
  fileMask?: string,         // Filter by file type
  directoryToSearch?: string, // Limit to directory
  maxUsageCount?: number,    // Default: 100
  timeout?: number
)
```

### Examples

**Example 1: Find all DeferredRegister declarations**
```
search_in_files_by_text("DeferredRegister.create", fileMask="*.java")
→ Results: All registry creation points
```

**Example 2: Find event subscriptions**
```
search_in_files_by_text("@SubscribeEvent")
→ Results: All event handler methods
```

**Example 3: Find specific registry name**
```
search_in_files_by_text("\"ruby_sword\"")
→ Results: Registry declaration, recipes, loot tables
```

**Example 4: Find capability usage**
```
search_in_files_by_text("getCapability(", caseSensitive=false)
→ Results: All capability access points
```

### Optimization Tips

1. **Use file masks**: `fileMask="*.java"` excludes non-code files
2. **Case sensitivity**: Set `caseSensitive=false` for broader search
3. **Directory filtering**: `directoryToSearch="src/main/java"` limits scope
4. **Limit results**: `maxUsageCount=50` for large codebases
5. **Quote strings**: Search for `"ruby_sword"` to find string literals

### Performance Tricks

**❌ Slow**: Search all files
```
search_in_files_by_text("DeferredRegister")
→ 4.2s (searches .json, .class, .md, etc.)
```

**✅ Fast**: Filter by file type
```
search_in_files_by_text("DeferredRegister", fileMask="*.java")
→ 1.8s (only Java files)
```

**✅ Faster**: Limit directory
```
search_in_files_by_text("DeferredRegister",
  fileMask="*.java",
  directoryToSearch="src/main/java/com/mod/init")
→ 0.3s (specific package)
```

### Common Minecraft Patterns

```java
// Find registry declarations
search_in_files_by_text("DeferredRegister.create")
search_in_files_by_text("Registry.register")

// Find event handlers
search_in_files_by_text("@SubscribeEvent")
search_in_files_by_text("@Mod.EventBusSubscriber")

// Find capabilities
search_in_files_by_text("getCapability(")
search_in_files_by_text("AttachCapabilitiesEvent")

// Find NBT usage
search_in_files_by_text("CompoundTag")
search_in_files_by_text("tag.putInt")

// Find network packets
search_in_files_by_text("SimpleChannel")
search_in_files_by_text("MessageHandler")
```

---

## Tool 4: search_in_files_by_regex

### When to Use

**✅ Perfect For**:
- Pattern matching: `@SubscribeEvent.*onPlayer\w+`
- Multiple variations: `(Forge|Neo)Registries`
- Complex structures: `class\s+\w+\s+extends\s+Item`
- Flexible matching: `register\("[\w_]+",`

**❌ Not Good For**:
- Simple text search (use text search - faster)
- File name patterns (use glob)
- Exact matches (use text search)

### Parameters

```typescript
search_in_files_by_regex(
  regexPattern: string,       // Regular expression
  caseSensitive?: boolean,    // Default: true
  fileMask?: string,
  directoryToSearch?: string,
  maxUsageCount?: number,
  timeout?: number
)
```

### Regex Syntax Quick Reference

```
.        Any character
\w       Word character [a-zA-Z0-9_]
\s       Whitespace
\d       Digit
*        0 or more
+        1 or more
?        0 or 1
{n}      Exactly n
{n,m}    Between n and m
[]       Character class
()       Capture group
|        OR
^        Start of line
$        End of line
```

### Examples

**Example 1: Find all event handlers**
```
search_in_files_by_regex("@SubscribeEvent\\s+public\\s+static\\s+void\\s+\\w+")
→ Results: All static event handler method signatures
```

**Example 2: Find all class declarations extending Item**
```
search_in_files_by_regex("class\\s+\\w+\\s+extends\\s+Item")
→ Results: CustomSword.java, MagicWand.java, etc.
```

**Example 3: Find registry calls with different patterns**
```
search_in_files_by_regex("(ITEMS|BLOCKS)\\.register\\(\"\\w+\"")
→ Results: All item and block registrations
```

**Example 4: Find @OnlyIn annotations**
```
search_in_files_by_regex("@OnlyIn\\(Dist\\.CLIENT\\)")
→ Results: All client-only code annotations
```

**Example 5: Find tick event handlers**
```
search_in_files_by_regex("on(Server|Client|Player|Level)Tick")
→ Results: All tick handler methods
```

### Optimization Tips

1. **Escape special characters**: Use `\\` for literal periods, parentheses
2. **Use anchors sparingly**: `^` and `$` slow down searches
3. **Limit alternatives**: `(a|b|c)` is slower than three searches
4. **Use non-capturing groups**: `(?:...)` when capture not needed
5. **Set file masks**: Always use `fileMask="*.java"` for code searches

### Common Minecraft Regex Patterns

```regex
# Find all DeferredRegister declarations
DeferredRegister\.create\((Forge|BuiltIn)Registries\.\w+

# Find event handlers on specific bus
@Mod\.EventBusSubscriber\(.*bus\s*=\s*Bus\.(MOD|FORGE)

# Find all RegistryObject declarations
(public|private|protected)\s+static\s+final\s+RegistryObject<\w+>

# Find capability attachments
@SubscribeEvent.*AttachCapabilitiesEvent<\w+>

# Find client-only methods
@OnlyIn\(Dist\.CLIENT\).*\s+(public|private|protected)\s+\w+\s+\w+\(

# Find SavedData load methods
public\s+static\s+\w+\s+load\(CompoundTag

# Find entity registration
EntityType\.Builder\.<\w+>of\(\w+::new

# Find custom block properties
BlockBehaviour\.Properties\.(of|copy)\(.*strength\([\d.]+
```

### Performance Comparison

**Simple Pattern** (0.8s):
```regex
@SubscribeEvent
```

**Medium Pattern** (2.1s):
```regex
@SubscribeEvent\s+public\s+static\s+void
```

**Complex Pattern** (5.4s):
```regex
@SubscribeEvent\s+public\s+static\s+void\s+\w+\([\w.]+Event\s+\w+\)\s*\{
```

**Lesson**: Keep patterns as simple as possible.

---

## Tool 5: get_symbol_info

### When to Use

**✅ Perfect For**:
- Understanding symbol types
- Finding declarations
- Reading documentation
- Semantic navigation
- Type information

**❌ Not Good For**:
- Bulk searches (use text/regex)
- File discovery (use glob)
- Performance-critical operations

### Parameters

```typescript
get_symbol_info(
  filePath: string,           // File containing symbol
  line: number,              // 1-based line number
  column: number,            // 1-based column number
  projectPath?: string
)
```

### What It Returns

```json
{
  "symbolName": "RUBY_SWORD",
  "symbolType": "FIELD",
  "declarationType": "RegistryObject<Item>",
  "documentation": "Registry object for the Ruby Sword item...",
  "declaration": "public static final RegistryObject<Item> RUBY_SWORD = ...",
  "definedAt": {
    "file": "ModItems.java",
    "line": 25,
    "column": 45
  }
}
```

### Examples

**Example 1: Understand field type**
```
Symbol at ModItems.java:25:30 → "RUBY_SWORD"
get_symbol_info("ModItems.java", 25, 30)
→ Type: RegistryObject<Item>
→ Declaration: public static final RegistryObject<Item>
→ Documentation: "Ruby sword item registration"
```

**Example 2: Find method signature**
```
Symbol at EventHandler.java:42:15 → "onPlayerTick"
get_symbol_info("EventHandler.java", 42, 15)
→ Type: METHOD
→ Signature: void onPlayerTick(TickEvent.PlayerTickEvent)
→ Documentation: "@SubscribeEvent handler for player ticks"
```

**Example 3: Navigate to class definition**
```
Symbol at MyMod.java:10:20 → "CustomEntity"
get_symbol_info("MyMod.java", 10, 20)
→ Type: CLASS
→ Defined at: entities/CustomEntity.java:15
→ Extends: Entity
```

### Use Cases

1. **Type Discovery**: What type is this variable?
2. **Documentation Lookup**: What does this method do?
3. **Declaration Navigation**: Where is this defined?
4. **Semantic Understanding**: How is this used?

### Integration with Other Tools

**Workflow**: Find → Understand → Navigate

```
1. search_in_files_by_text("RUBY_SWORD")
   → Found in ModItems.java:25

2. get_symbol_info("ModItems.java", 25, 30)
   → Type: RegistryObject<Item>
   → Declaration location: line 25

3. Read ModItems.java
   → Examine full context
```

---

## Tool Selection Decision Tree

### Question 1: Do you know the filename?

**YES** → Use `find_files_by_name_keyword("ClassName")`
- Fast (50-100ms)
- Indexed search
- Perfect for standard naming

**NO** → Go to Question 2

### Question 2: Do you know the file path pattern?

**YES** → Use `find_files_by_glob("**/path/pattern/**/*.ext")`
- Fast (100-500ms)
- Indexed search
- Great for resource files

**NO** → Go to Question 3

### Question 3: Are you searching for exact text?

**YES** → Use `search_in_files_by_text("exact text", fileMask="*.java")`
- Moderate speed (1-5s)
- Case-sensitive option
- Add file mask for performance

**NO** → Go to Question 4

### Question 4: Do you need pattern matching?

**YES** → Use `search_in_files_by_regex("pattern.*match\w+")`
- Slower (2-10s)
- Powerful but expensive
- Use file mask and directory filtering

**NO** → Go to Question 5

### Question 5: Do you need semantic information?

**YES** → Use `get_symbol_info(file, line, column)`
- Fast (100-500ms)
- Type information
- Documentation access

**NO** → Reconsider your search strategy

---

## Performance Optimization Matrix

| Goal | Fast Approach | Slow Approach | Speed Gain |
|------|---------------|---------------|------------|
| Find ModItems.java | `find_files_by_name_keyword` | `search_in_files_by_text` | 20x faster |
| Find event handlers | `find_files_by_glob("**/events/**")` | `search_in_files_by_regex` | 10x faster |
| Find exact text | `search_in_files_by_text` with mask | `search_in_files_by_regex` | 2x faster |
| Find all models | `find_files_by_glob("**/models/**")` | `search_in_files_by_text` | 15x faster |

---

## Real-World Workflow Examples

### Workflow 1: "Where is RUBY_SWORD registered?"

**Optimal Strategy**:
```
1. find_files_by_name_keyword("ModItems") → 80ms
2. Read ModItems.java → Examine code
3. If not found: search_in_files_by_text("RUBY_SWORD", fileMask="*.java") → 1.2s
4. get_symbol_info(file, line, column) → Understand type
```

**Why This Works**:
- Start with fastest tool (indexed file search)
- Escalate to content search only if needed
- Use semantic tool for deep understanding

### Workflow 2: "Find all PlayerTickEvent handlers"

**Optimal Strategy**:
```
1. find_files_by_glob("**/events/**/*.java") → 200ms
2. search_in_files_by_text("PlayerTickEvent", fileMask="*.java") → 1.5s
3. Read matching files → Analyze handlers
```

**Why This Works**:
- Narrow search scope with glob first
- Then search content in limited files
- Avoid searching entire project

### Workflow 3: "Map CUSTOM_BLOCK to its resources"

**Optimal Strategy**:
```
1. search_in_files_by_text("CUSTOM_BLOCK", fileMask="*.java") → 1.0s
   → Find registration: "custom_block"

2. find_files_by_glob("**/models/block/custom_block.json") → 100ms
   → Find model

3. Read model JSON → Extract texture reference

4. find_files_by_glob("**/textures/block/custom_block.png") → 120ms
   → Find texture

5. search_in_files_by_text("block.modid.custom_block") → 800ms
   → Find lang entry
```

**Why This Works**:
- Use targeted searches for each resource type
- Glob patterns for known file paths
- Text search for lang file lookups

---

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Regex When Text Suffices

**BAD**:
```
search_in_files_by_regex("DeferredRegister\\.create")
→ 3.2s
```

**GOOD**:
```
search_in_files_by_text("DeferredRegister.create")
→ 1.4s (2.3x faster)
```

### ❌ Anti-Pattern 2: Content Search for Filenames

**BAD**:
```
search_in_files_by_text("class ModItems")
→ 2.8s
```

**GOOD**:
```
find_files_by_name_keyword("ModItems")
→ 70ms (40x faster)
```

### ❌ Anti-Pattern 3: No File Mask on Content Search

**BAD**:
```
search_in_files_by_text("@SubscribeEvent")
→ 4.5s (searches .json, .class, .md)
```

**GOOD**:
```
search_in_files_by_text("@SubscribeEvent", fileMask="*.java")
→ 1.8s (2.5x faster)
```

### ❌ Anti-Pattern 4: Overly Complex Regex

**BAD**:
```
search_in_files_by_regex("@SubscribeEvent\\s+public\\s+static\\s+void\\s+\\w+\\(.*Event\\s+\\w+\\)\\s*\\{")
→ 8.1s
```

**GOOD** (two simpler searches):
```
search_in_files_by_text("@SubscribeEvent")
→ 1.2s
Then filter results by reading files
```

---

## Summary: The Performance Hierarchy

```
TIER 1: INDEXED SEARCHES (50-500ms)
├── find_files_by_name_keyword    ← Start here for filenames
├── find_files_by_glob            ← Start here for paths
└── list_directory_tree           ← Start here for structure

TIER 2: CONTENT SEARCHES (1-10s)
├── search_in_files_by_text       ← Use with file masks
└── search_in_files_by_regex      ← Last resort, optimize carefully

TIER 3: SEMANTIC ANALYSIS (100-500ms)
└── get_symbol_info               ← Use after locating symbol
```

**Golden Rule**: Always try Tier 1 before Tier 2. Use Tier 3 for understanding, not discovery.

---

Use this guide to select the optimal tool for every navigation task, minimizing search time and token cost while maximizing accuracy.
