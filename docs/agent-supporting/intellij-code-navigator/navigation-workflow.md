# Navigation Workflow - Detailed 6-Step Process

Complete guide to the IntelliJ Code Navigator's systematic approach to code discovery.

## The 6-Step Navigation Process

Every navigation task follows this proven workflow to ensure fast, accurate, and comprehensive results.

---

## Step 1: Understand the Query

### Query Classification

Classify the user's request into one of these five categories:

#### Type 1: Simple Lookup
**Pattern**: "Where is X?" / "Find X"
**Example**: "Where is RUBY_SWORD registered?"
**Approach**: Direct file → symbol search
**Tools**: find_files_by_name_keyword → Read file

#### Type 2: Pattern Search
**Pattern**: "Find all Y" / "Show me all Z"
**Example**: "Find all PlayerTickEvent handlers"
**Approach**: Content search for patterns
**Tools**: search_in_files_by_text or search_in_files_by_regex

#### Type 3: Hierarchy Discovery
**Pattern**: "What extends X?" / "Find implementations of Y"
**Example**: "Find all classes extending Item"
**Approach**: Regex pattern for class declarations
**Tools**: search_in_files_by_regex

#### Type 4: Resource Mapping
**Pattern**: "Map X to resources" / "Find resources for Y"
**Example**: "Find the model for CUSTOM_BLOCK"
**Approach**: Multi-step chain (code → model → texture → lang)
**Tools**: Combination of text search and glob

#### Type 5: Structure Exploration
**Pattern**: "Show me the structure" / "What's the organization?"
**Example**: "Explore the events package"
**Approach**: Directory tree + file listing
**Tools**: list_directory_tree + find_files_by_glob

### Query Analysis Checklist

- [ ] What is the user looking for? (item, event, class, resource)
- [ ] How specific is the request? (exact name vs pattern vs all)
- [ ] What framework are they using? (Forge, NeoForge, Fabric)
- [ ] What's the scope? (single file, package, entire project)
- [ ] Do they know the name? (exact, partial, unknown)

---

## Step 2: Select Optimal Tool

### Selection Algorithm

```
IF know exact filename:
    USE find_files_by_name_keyword
ELSE IF know path pattern:
    USE find_files_by_glob
ELSE IF searching for exact text:
    USE search_in_files_by_text (with fileMask)
ELSE IF need pattern matching:
    USE search_in_files_by_regex (with fileMask)
ELSE IF understanding a symbol:
    USE get_symbol_info
END IF
```

### Tool Selection Matrix

| User Query | Query Type | Primary Tool | Fallback Tool |
|------------|-----------|--------------|---------------|
| "Where is ModItems?" | Simple Lookup | find_files_by_name_keyword | search_in_files_by_text |
| "Find all event handlers" | Pattern Search | find_files_by_glob("**/events/**") | search_in_files_by_text("@SubscribeEvent") |
| "What extends Item?" | Hierarchy | search_in_files_by_regex | N/A |
| "Map RUBY to resources" | Resource Mapping | Multi-step (text → glob) | N/A |
| "Show events package" | Structure | list_directory_tree | find_files_by_glob |

### Optimization Strategy

**Rule 1**: Start with the fastest tool that CAN solve the problem.
**Rule 2**: Use file masks (`*.java`) on content searches.
**Rule 3**: Limit search scope (directory, maxUsageCount).
**Rule 4**: Escalate to slower tools only if fast tools fail.

---

## Step 3: Execute Search

### Execution Best Practices

#### For find_files_by_name_keyword

```
Parameters to set:
- nameKeyword: Specific as possible ("ModItems" not "Items")
- fileCountLimit: 20-50 for large projects
- timeout: 5000ms (default usually fine)

Example:
find_files_by_name_keyword("ModItems", fileCountLimit=20)
```

#### For find_files_by_glob

```
Parameters to set:
- pattern: Specific path (**/events/**/*.java not **/*.java)
- fileCountLimit: 100 (default usually fine)
- subDirectoryRelativePath: Narrow scope if known

Example:
find_files_by_glob("**/resources/assets/*/models/item/*.json")
```

#### For search_in_files_by_text

```
Parameters to set:
- searchText: Exact string to find
- fileMask: ALWAYS set ("*.java" for code)
- caseSensitive: false for broader search
- directoryToSearch: Narrow if possible
- maxUsageCount: 50 for large codebases

Example:
search_in_files_by_text("DeferredRegister.create",
  fileMask="*.java",
  directoryToSearch="src/main/java",
  maxUsageCount=50)
```

#### For search_in_files_by_regex

```
Parameters to set:
- regexPattern: As simple as possible
- fileMask: ALWAYS set ("*.java")
- caseSensitive: Usually true for code
- directoryToSearch: Narrow scope
- maxUsageCount: 30-50 (regex is slow)

Example:
search_in_files_by_regex("class\\s+\\w+\\s+extends\\s+Item",
  fileMask="*.java",
  maxUsageCount=30)
```

#### For get_symbol_info

```
Parameters to set:
- filePath: Relative to project root
- line: 1-based line number
- column: 1-based column number

Example:
get_symbol_info("src/main/java/com/mod/ModItems.java", 25, 30)
```

### Progressive Search Depth

Start narrow, expand if no results:

```
Attempt 1: Specific package
search_in_files_by_text("RUBY_SWORD",
  directoryToSearch="src/main/java/com/mod/init")

Attempt 2: All source code
search_in_files_by_text("RUBY_SWORD",
  directoryToSearch="src/main/java")

Attempt 3: Entire project
search_in_files_by_text("RUBY_SWORD")
```

---

## Step 4: Analyze Results

### Result Filtering

**For Registry Searches**:
```
Extract from results:
- Registry name: "ruby_sword"
- Java field name: RUBY_SWORD
- Type: Item, Block, EntityType
- File location: ModItems.java:25
- Registration method: DeferredRegister or Registry.register
```

**For Event Handlers**:
```
Extract from results:
- Event type: PlayerTickEvent, ServerTickEvent, etc.
- Event bus: MOD or FORGE
- Side: CLIENT, SERVER, or both
- Handler method: onPlayerTick(...)
- File location: ForgeEvents.java:42
- Static or instance method
```

**For Resource Mapping**:
```
Build chain:
1. Code → Registry name: "custom_block"
2. Model path: assets/modid/models/block/custom_block.json
3. Texture reference: "modid:block/custom_block"
4. Texture path: assets/modid/textures/block/custom_block.png
5. Lang key: "block.modid.custom_block"
```

### Categorization

Group results by:
- **Relevance**: Primary match vs related matches
- **Type**: Item, Block, Entity, Event, etc.
- **Framework**: Forge, NeoForge, Fabric
- **Side**: Client, Server, Common
- **Status**: Found, Missing, Partial

### Result Validation

**Checklist**:
- [ ] Result matches user's request
- [ ] File paths are valid (exist)
- [ ] Line numbers are accurate (1-based)
- [ ] Code snippets show context
- [ ] No false positives included

---

## Step 5: Map Relationships (Advanced)

### Relationship Types

#### Code → Registry Name
```
Java field: RUBY_SWORD
→ Registration: ITEMS.register("ruby_sword", ...)
→ Registry name: "ruby_sword"
```

#### Registry Name → Model
```
Registry name: "ruby_sword"
→ Model path: assets/modid/models/item/ruby_sword.json
→ Check: find_files_by_glob("**/models/item/ruby_sword.json")
```

#### Model → Texture
```
Model file content:
{
  "parent": "item/handheld",
  "textures": {
    "layer0": "modid:item/ruby_sword"
  }
}
→ Texture path: assets/modid/textures/item/ruby_sword.png
→ Check: find_files_by_glob("**/textures/item/ruby_sword.png")
```

#### Registry Name → Lang Entry
```
Registry name: "ruby_sword"
Type: Item
→ Lang key: "item.modid.ruby_sword"
→ Check: search_in_files_by_text("item.modid.ruby_sword", fileMask="*.json")
```

#### Registry Name → Recipes
```
Registry name: "ruby_sword"
→ Recipe pattern: "result": { "item": "modid:ruby_sword" }
→ Check: search_in_files_by_text("modid:ruby_sword", fileMask="*.json", directoryToSearch="data")
```

### Mapping Workflows

**Complete Item Mapping**:
```
1. Find item registration
   search_in_files_by_text("RUBY_SWORD", fileMask="*.java")
   → Result: ModItems.java:25, registry name "ruby_sword"

2. Find item model
   find_files_by_glob("**/models/item/ruby_sword.json")
   → Result: ✓ Found or ❌ Missing

3. Read model to find texture reference
   Read model JSON
   → Extract: "modid:item/ruby_sword"

4. Find texture file
   find_files_by_glob("**/textures/item/ruby_sword.png")
   → Result: ✓ Found or ❌ Missing

5. Find lang entry
   search_in_files_by_text("item.modid.ruby_sword")
   → Result: en_us.json: "Ruby Sword" ✓ Found

6. Find crafting recipe (if applicable)
   search_in_files_by_text("modid:ruby_sword", directoryToSearch="data")
   → Result: ruby_sword.json ✓ Found or ❌ Not craftable
```

---

## Step 6: Report Findings

### Report Structure

```markdown
## Search Results: [Query]

**Query Type**: [Simple Lookup | Pattern Search | etc.]
**Search Time**: [Duration]
**Results Found**: [Count]

### Primary Result

**File**: [Absolute path]
**Line**: [Line number]
**Type**: [Item | Block | Event | etc.]

**Code**:
```java
[Relevant code snippet with 2-3 lines context]
```

**Context**: [Brief explanation]

### Related Resources

- ✓ Model: [Path] or ❌ Not found
- ✓ Texture: [Path] or ❌ Not found
- ✓ Lang: [Path] - "[Display Name]" or ❌ Not found
- ✓ Recipe: [Path] or ❌ Not craftable

### Additional Matches

[If multiple results found, list them with brief context]

### Summary

[1-2 sentence summary of findings]

### Next Steps (if applicable)

[Suggestions for missing resources or related tasks]
```

### Report Symbols

Use these for clarity:
- ✓ Found / Present
- ❌ Not found / Missing
- ⚠️ Warning / Attention needed
- ℹ️ Information / Note

### Code Snippet Guidelines

**Good code snippet**:
```java
// Context line above
public static final RegistryObject<Item> RUBY_SWORD =
    ITEMS.register("ruby_sword", () -> new SwordItem(...));
// Context line below
```

**What to include**:
- 1-2 lines before target line
- The target line itself
- 1-2 lines after target line
- Comments if present
- Proper indentation preserved

### Path Formatting

**Always use absolute paths in reports**:
```
✅ Good: C:\...\MyProject\src\main\java\com\mod\ModItems.java
❌ Bad: src/main/java/com/mod/ModItems.java
```

For portability in documentation, use project-relative:
```
✅ Good: src/main/java/com/mod/ModItems.java (relative to project root)
```

---

## Error Handling

### No Results Found

**Report Template**:
```markdown
## No Results Found: [Query]

**Searched**:
- Tool: [find_files_by_name_keyword | search_in_files_by_text | etc.]
- Pattern: "[search pattern]"
- Scope: [directory or "entire project"]
- Results: 0

**Possible Reasons**:
1. Symbol doesn't exist yet
2. Different naming convention used
3. Located in unexpected place (check [alternative location])
4. Typo in search query

**Suggestions**:
- Try broader search: [alternative search]
- Check if [related symbol] exists instead
- Verify project structure: [expected location]
```

### Too Many Results

**Report Template**:
```markdown
## Too Many Results: [Query]

**Found**: [count] results (exceeds practical limit)

**Recommendation**:
1. Narrow search by adding context
2. Filter by directory: [suggested directory]
3. Use more specific pattern: [suggested pattern]
4. Check if you meant: [more specific query]

**Most Relevant Results** (top 5):
[List 5 most likely matches]
```

### Ambiguous Results

**Report Template**:
```markdown
## Multiple Matches Found: [Query]

**Found**: [count] matches

**Disambiguate**:

**Option 1**: [Path 1]
- [Brief description]
- Used in: [Context]

**Option 2**: [Path 2]
- [Brief description]
- Used in: [Context]

**Which did you mean?**
```

### Partial Results

**Report Template**:
```markdown
## Partial Match: [Query]

**Found**: Code registration ✓
**Missing**: Resources ⚠️

**Details**:
- ✓ Java code: [path]
- ❌ Model: Expected at [path] - NOT FOUND
- ⚠️ Texture: Depends on model
- ❌ Lang: Expected key "[key]" - NOT FOUND

**Diagnosis**: Item registered but resources not created yet

**Fix**: Create missing resources:
1. Create model: [path]
2. Create texture: [path]
3. Add lang entry: "[key]": "[display name]"
```

---

## Example Workflows

### Example 1: Simple Item Lookup

**Query**: "Where is RUBY_SWORD?"

**Step 1 - Understand**:
- Type: Simple Lookup
- Target: Java field name
- Expected: Registry declaration

**Step 2 - Select Tool**:
- Primary: find_files_by_name_keyword("ModItems")
- Fallback: search_in_files_by_text("RUBY_SWORD")

**Step 3 - Execute**:
```
find_files_by_name_keyword("ModItems")
→ Found: ModItems.java, ModItemsClient.java
```

**Step 4 - Analyze**:
```
Read ModItems.java
→ Found at line 25:
public static final RegistryObject<Item> RUBY_SWORD =
    ITEMS.register("ruby_sword", () -> new SwordItem(...));
```

**Step 5 - Map**:
```
Registry name: "ruby_sword"
→ Check model: find_files_by_glob("**/models/item/ruby_sword.json") ✓
→ Check texture: find_files_by_glob("**/textures/item/ruby_sword.png") ✓
→ Check lang: search_in_files_by_text("item.modid.ruby_sword") ✓
```

**Step 6 - Report**:
```markdown
## Search Results: RUBY_SWORD

**Found**: ModItems.java:25
**Registry Name**: "ruby_sword"

**Code**:
```java
public static final RegistryObject<Item> RUBY_SWORD =
    ITEMS.register("ruby_sword", () -> new SwordItem(Tiers.IRON, 3, -2.4f, ...));
```

**Resources**:
- ✓ Model: assets/modid/models/item/ruby_sword.json
- ✓ Texture: assets/modid/textures/item/ruby_sword.png
- ✓ Lang: "Ruby Sword"

**Summary**: RUBY_SWORD is fully registered with all resources present.
```

### Example 2: Event Handler Search

**Query**: "Find all PlayerTickEvent handlers"

**Step 1 - Understand**:
- Type: Pattern Search
- Target: Event handler methods
- Framework: Forge (based on PlayerTickEvent name)

**Step 2 - Select Tool**:
- Primary: find_files_by_glob("**/events/**/*.java")
- Secondary: search_in_files_by_text("PlayerTickEvent")

**Step 3 - Execute**:
```
search_in_files_by_text("PlayerTickEvent", fileMask="*.java")
→ Found: 3 matches
```

**Step 4 - Analyze**:
```
Match 1: ForgeEvents.java:42
- Handler: onPlayerTick(TickEvent.PlayerTickEvent)
- Bus: FORGE
- Side: Both (no side check)

Match 2: ClientEvents.java:18
- Handler: onClientPlayerTick(TickEvent.PlayerTickEvent)
- Bus: FORGE
- Side: CLIENT (value = Dist.CLIENT)

Match 3: PlayerTickHandler.java:25
- Handler: handleTick(TickEvent.PlayerTickEvent)
- Bus: FORGE
- Side: Server (checks !level.isClientSide)
```

**Step 5 - Map** (not applicable for events)

**Step 6 - Report**:
```markdown
## Search Results: PlayerTickEvent Handlers

**Found**: 3 handlers

### Handler 1: ForgeEvents.java:42
**Side**: Both (no restriction)
**Code**:
```java
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        // Common tick logic
    }
}
```

### Handler 2: ClientEvents.java:18
**Side**: CLIENT only
**Code**:
```java
@SubscribeEvent
public static void onClientPlayerTick(TickEvent.PlayerTickEvent event) {
    if (event.side.isClient()) {
        // Client-specific tick logic
    }
}
```

### Handler 3: PlayerTickHandler.java:25
**Side**: Server only (runtime check)
**Code**:
```java
@SubscribeEvent
public static void handleTick(TickEvent.PlayerTickEvent event) {
    if (!event.player.level().isClientSide) {
        // Server-side tick logic
    }
}
```

**Summary**: 3 PlayerTickEvent handlers found - 1 common, 1 client-only, 1 server-only.
```

---

## Performance Tracking

### Search Metrics to Track

**For each search, note**:
- Tool used
- Parameters set
- Time taken
- Results found
- Token cost (estimated)

**Example Log**:
```
Query: "Find RUBY_SWORD"
Tool: find_files_by_name_keyword("ModItems")
Time: 78ms
Results: 2 files
Tokens: ~50

Follow-up: Read ModItems.java
Time: 120ms (file read)
Tokens: ~800 (file content)

Total Time: 198ms
Total Tokens: ~850
```

### Optimization Opportunities

**If search >5s**:
- Consider narrowing scope
- Use file masks
- Split into multiple targeted searches

**If search returns >100 results**:
- Search too broad
- Add filters (directory, file type)
- Use more specific pattern

---

Use this detailed workflow to ensure consistent, fast, and accurate code navigation for every task.
