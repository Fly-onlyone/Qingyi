# Analysis Workflow - Complete Project Analysis Process

This guide provides the detailed 6-step workflow for analyzing Minecraft mod projects using IntelliJ's project analysis tools.

## Overview

**Goal**: Rapidly understand project architecture, detect multi-loader setups, and provide actionable context for implementation tasks.

**Time**: 2-5 seconds for complete analysis
**Tools**: MCP IntelliJ integration (get_project_modules, get_project_dependencies, list_directory_tree, get_repositories)

---

## The 6-Step Analysis Process

### Step 1: Get Project Modules

**Purpose**: Detect if project is single-loader or multi-loader

**Tool**: `mcp__intellij__get_project_modules()`

**What to Look For**:
```
Single-Loader Response:
- 1 module: "MyMod.main"

Multi-Loader Response:
- 3+ modules: "MyMod.common.main", "MyMod.forge.main", "MyMod.fabric.main"
```

**Decision Tree**:
```
Module count = 1?
  → Single-Loader Project (proceed to Step 2 for framework detection)

Module names contain "common", "forge", "fabric"?
  → Multi-Loader Project (Architectury or similar pattern)

Module names contain "main", "client", "server"?
  → Fabric with source sets (single-loader but split by side)
```

**Example Output**:
```json
{
  "modules": [
    {"name": "Apocalypse_TNT.main", "type": "JAVA"},
    {"name": "Apocalypse_TNT.test", "type": "JAVA"}
  ]
}
```
→ **Conclusion**: Single-loader project

**Common Issues**:
- No modules found → Project not properly loaded in IntelliJ
- Many test modules → Filter to only "main" modules
- Build tool modules → Ignore buildSrc, build-logic

---

### Step 2: Get Dependencies

**Purpose**: Extract framework type and version information

**Tool**: `mcp__intellij__get_project_dependencies()`

**What to Look For**:

**Forge Project**:
```
net.minecraftforge:forge:1.20.1-47.1.0
                    ↑       ↑
                    MC      Forge version
```

**NeoForge Project**:
```
net.neoforged:neoforge:20.4.60-beta
               ↑            ↑
               NeoForge     Version (for MC 1.20.4)
```

**Fabric Project**:
```
net.fabricmc:fabric-loader:0.15.0
net.fabricmc.fabric-api:fabric-api:0.92.0+1.20.1
                                          ↑
                                          MC version
```

**Multi-Loader Project**:
```
common module:
- No framework dependencies (just Minecraft)

forge module:
- net.minecraftforge:forge:1.20.1-47.1.0

fabric module:
- net.fabricmc:fabric-loader:0.15.0
- net.fabricmc.fabric-api:fabric-api:0.92.0+1.20.1
```

**Extraction Patterns**:

```python
# Pseudocode for parsing
if "minecraftforge" in dependency:
    framework = "Forge"
    parts = dependency.split(":")
    version = parts[-1]  # "1.20.1-47.1.0"
    mc_version = version.split("-")[0]  # "1.20.1"
    forge_version = version.split("-")[1]  # "47.1.0"

elif "neoforged" in dependency:
    framework = "NeoForge"
    version = parts[-1]  # "20.4.60-beta"
    # NeoForge version encodes MC version
    major = version.split(".")[0]  # "20"
    mc_version = f"1.{major}.{minor}"  # "1.20.4"

elif "fabricmc" in dependency:
    framework = "Fabric"
    if "fabric-api" in dependency:
        # Extract MC from fabric-api version
        mc_version = dependency.split("+")[1]  # "1.20.1"
```

**Example Analysis**:
```
Dependencies found:
- net.minecraftforge:forge:1.20.1-47.1.0
- org.jetbrains:annotations:24.0.0

Framework: Forge 1.20.1-47.1.0
MC Version: 1.20.1
Forge Version: 47.1.0
```

**Common Dependencies to Note**:
- `kotlin-for-forge` → Project uses Kotlin
- `mixinextras` → Advanced modding (core mods)
- `jei` / `rei` → Integration with recipe viewers
- `curios` / `trinkets` → Accessory system integration

---

### Step 3: List Directory Tree

**Purpose**: Map source set structure and resource organization

**Tool**: `mcp__intellij__list_directory_tree(path=".", maxDepth=2)`

**What to Look For**:

**Single-Loader Forge/NeoForge**:
```
.
├── src/
│   └── main/
│       ├── java/
│       │   └── com/mod/mymod/
│       │       ├── MyMod.java
│       │       ├── item/
│       │       ├── block/
│       │       └── init/
│       └── resources/
│           ├── META-INF/mods.toml
│           ├── assets/modid/
│           └── data/modid/
├── build.gradle
└── gradle.properties
```
→ **Standard Forge structure**

**Fabric with Source Sets**:
```
.
├── src/
│   ├── main/
│   │   ├── java/
│   │   └── resources/
│   ├── client/
│   │   └── java/
│   └── testmod/
│       └── java/
├── build.gradle
└── gradle.properties
```
→ **Fabric with client/main separation**

**Multi-Loader (Architectury)**:
```
.
├── common/
│   └── src/main/
│       ├── java/
│       └── resources/
├── forge/
│   └── src/main/
│       ├── java/
│       └── resources/
├── fabric/
│   └── src/main/
│       ├── java/
│       └── resources/
├── settings.gradle
└── build.gradle
```
→ **Multi-loader with platform modules**

**Key Indicators**:
- `mods.toml` → Forge/NeoForge
- `fabric.mod.json` → Fabric
- Multiple top-level directories (common/, forge/, fabric/) → Multi-loader
- src/client/ directory → Fabric with side separation

**Depth Strategy**:
- `maxDepth=2` → Quick structure overview (sufficient for detection)
- `maxDepth=3` → See package organization
- `maxDepth=4` → Full project structure (only if needed)

---

### Step 4: Get Repositories

**Purpose**: Identify VCS setup for multi-repo projects

**Tool**: `mcp__intellij__get_repositories()`

**What to Look For**:

**Single Repository**:
```json
{
  "repositories": [
    {
      "root": "C:/projects/MyMod",
      "vcs": "Git"
    }
  ]
}
```
→ Standard setup

**Multi-Repository**:
```json
{
  "repositories": [
    {
      "root": "C:/projects/MultiLoaderMod/common",
      "vcs": "Git"
    },
    {
      "root": "C:/projects/MultiLoaderMod/forge",
      "vcs": "Git"
    },
    {
      "root": "C:/projects/MultiLoaderMod/fabric",
      "vcs": "Git"
    }
  ]
}
```
→ Separate git repos for each module (advanced setup)

**Usage**:
- Single repo → Standard workflow
- Multi-repo → Need to handle git operations per module
- Submodules → Check for .gitmodules file

**Common Patterns**:
- Most projects: 1 root repository
- Large multi-loader: 1 root + submodules
- Development setup: Multiple cloned repos

---

### Step 5: Analyze Patterns

**Purpose**: Determine which conventions and patterns are used

**Tools**: Search for specific code patterns

**Registry Pattern Detection**:

```java
// Search for "DeferredRegister"
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MODID);
```
→ **Forge/NeoForge pattern detected**

```java
// Search for "Registry.register"
public static final Item RUBY = Registry.register(
    Registries.ITEM, new Identifier(MODID, "ruby"), item);
```
→ **Fabric pattern detected**

```java
// Search for "PlatformHelper" or "ServiceLoader"
private static final PlatformHelper PLATFORM =
    ServiceLoader.load(PlatformHelper.class).findFirst().orElseThrow();
```
→ **Multi-loader abstraction pattern detected**

**Event System Detection**:

```java
// Forge: @SubscribeEvent
@Mod.EventBusSubscriber(modid = MODID)
public class ForgeEvents {
    @SubscribeEvent
    public static void onServerTick(ServerTickEvent event) { }
}
```

```java
// Fabric: Direct registration
ServerTickEvents.END_SERVER_TICK.register(server -> {
    // Handle tick
});
```

**Package Organization Patterns**:
- `init/` package → Initialization/registration classes
- `registry/` package → Registry objects
- `event/` or `handler/` → Event handlers
- `client/` package → Client-side code
- `common/` package → Multi-loader shared code

**Search Strategy**:
1. Search for "DeferredRegister" → If found: Forge/NeoForge
2. Search for "Registry.register" → If found: Fabric
3. Search for "@SubscribeEvent" → Forge event system
4. Check for platform abstraction → Multi-loader

---

### Step 6: Report Context

**Purpose**: Provide actionable summary for specialist agents

**Report Format**:

```markdown
## Project Analysis: [Project Name]

**Type**: Single-Loader | Multi-Loader
**Framework**: [Forge 1.20.1 | NeoForge 1.21.3 | Fabric 1.20.1]
**MC Version**: [1.20.1]

### Structure
- **Modules**: [List of modules]
- **Source Sets**: [main, client, server, common, forge, fabric]
- **Build System**: [Gradle with ForgeGradle/Loom/NeoGradle]

### Dependencies
- Minecraft: [version]
- Framework: [Forge 47.1.0 | Fabric Loader 0.15.0 | NeoForge 21.3.0]
- Notable: [Fabric API, JEI, Curios, etc.]

### Conventions
- **Registry**: [DeferredRegister | Registry.register | Platform abstraction]
- **Events**: [Forge event bus | Fabric event API | Multi-loader wrapper]
- **Package Structure**: [Standard | Custom organization]

### VCS
- **Repositories**: [1 root repo | Multi-repo setup | Submodules]
- **VCS Type**: [Git | Mercurial | None]

### Recommendation
[Specific guidance for the current task based on analysis]

**Confidence**: High | Medium | Needs verification
```

**Example Report 1 - Single Loader**:
```markdown
## Project Analysis: Apocalypse_TNT

**Type**: Single-Loader
**Framework**: NeoForge 1.21.3
**MC Version**: 1.21.3

### Structure
- **Modules**: 1 (Apocalypse_TNT.main)
- **Source Sets**: Standard src/main layout
- **Build System**: Gradle with NeoGradle 7.x

### Dependencies
- Minecraft: 1.21.3
- NeoForge: 21.3.0-beta
- No additional mods

### Conventions
- **Registry**: DeferredRegister with BuiltInRegistries (NeoForge style)
- **Events**: Forge event bus (@SubscribeEvent on FORGE bus)
- **Package Structure**: Standard (entity/, init/)

### VCS
- **Repositories**: 1 root Git repository
- **VCS Type**: Git

### Recommendation
Use NeoForge 1.21+ patterns:
- BuiltInRegistries instead of ForgeRegistries
- DeferredRegister returns Supplier<T> not RegistryObject<T>
- Event registration on FORGE bus for gameplay events

**Confidence**: High
```

**Example Report 2 - Multi-Loader**:
```markdown
## Project Analysis: AdvancedMod

**Type**: Multi-Loader (Architectury)
**Framework**: Forge 1.20.1 + Fabric 1.20.1
**MC Version**: 1.20.1

### Structure
- **Modules**: 3 (common, forge, fabric)
- **Source Sets**: Platform-specific implementation
- **Build System**: Gradle with Architectury plugin

### Dependencies
Common:
- Minecraft: 1.20.1
- Architectury API: 9.0.8

Forge:
- Forge: 47.1.0

Fabric:
- Fabric Loader: 0.15.0
- Fabric API: 0.92.0

### Conventions
- **Registry**: Platform abstraction with ServiceLoader pattern
- **Events**: Common event interface, platform-specific implementations
- **Package Structure**: com.mod.common + com.mod.forge/fabric

### VCS
- **Repositories**: 1 root with 3 subprojects
- **VCS Type**: Git

### Recommendation
For new features:
1. Define interface/abstract class in common/
2. Implement platform-specific code in forge/ and fabric/
3. Use RegistryHelper for registration
4. Test on both platforms

**Confidence**: High
```

---

## Workflow Optimization

### Fast Track (known patterns)

If you recognize common patterns immediately:

**Quick Single-Loader Detection**:
1. Check modules → 1 module?
2. Check dependencies → Contains "minecraftforge"?
3. **Skip Steps 3-5** if confident
4. Report: "Forge 1.20.1 single-loader"

**Quick Multi-Loader Detection**:
1. Check modules → Contains "common", "forge", "fabric"?
2. **Skip Step 2-4** if obvious
3. Report: "Multi-loader Architectury project"

### When to Deep Dive

Run all 6 steps when:
- Unknown project structure
- Mixed signals (unclear module names)
- User explicitly asks for detailed analysis
- First time seeing this project pattern
- Need to provide comprehensive context to specialist

### Caching Results

**Within Session**:
- Store analysis results in memory
- Reuse for subsequent tasks
- Only re-analyze if files changed

**Cache Invalidation**:
- build.gradle modified → Re-analyze dependencies
- New modules added → Re-analyze structure
- .git changes → Re-analyze repositories

---

## Common Analysis Scenarios

### Scenario 1: Unknown Project

**Context**: First time seeing this project

**Process**: Run all 6 steps

**Time**: 3-5 seconds

**Output**: Full report with high confidence


### Scenario 2: Quick Framework Check

**Context**: Just need to know "Forge or Fabric?"

**Process**: Steps 1-2 only

**Time**: <1 second

**Output**: "Forge 1.20.1" or "Fabric 1.20.1"


### Scenario 3: Multi-Loader Verification

**Context**: User says "this is multi-loader", verify structure

**Process**: Steps 1, 3, 5 (skip dependencies)

**Time**: 2-3 seconds

**Output**: Confirm multi-loader + report module organization


### Scenario 4: Migration Context

**Context**: User upgrading Forge 1.19 → 1.20

**Process**: Step 2 (dependencies) + Step 5 (patterns)

**Time**: 1-2 seconds

**Output**: Current version + patterns that need updating

---

## Integration with Specialist Agents

### Context Provision Pattern

```
Orchestrator receives task: "Add new custom item"
  ↓
Orchestrator invokes project-analyzer
  ↓
project-analyzer runs 6-step workflow
  ↓
project-analyzer reports:
  "Single-Loader Forge 1.20.1
   Uses DeferredRegister pattern
   Items registered in ModItems.java"
  ↓
Orchestrator delegates to registry-and-content-expert with context
  ↓
Specialist uses DeferredRegister (not Registry.register)
Specialist creates item in ModItems.java (not new file)
  ↓
Task completed correctly for project structure
```

**Key Insight**: Analysis provides the context that enables specialists to generate framework-appropriate code without guessing or asking the user.

---

## Troubleshooting

### Problem: No modules detected

**Cause**: Project not properly loaded in IntelliJ

**Fix**:
1. Check if IntelliJ has indexed the project
2. Verify .idea/ directory exists
3. Try refreshing Gradle project
4. Check MCP server is connected


### Problem: Dependencies list is empty

**Cause**: Gradle sync not completed

**Fix**:
1. Wait for Gradle sync to complete
2. Manually trigger gradle refresh
3. Check build.gradle is valid


### Problem: Can't determine framework

**Cause**: Custom build setup or old Minecraft version

**Fix**:
1. Read build.gradle directly
2. Search for framework imports in code
3. Check for mods.toml or fabric.mod.json
4. Ask user to confirm framework


### Problem: Multi-loader detection false positive

**Cause**: Module names contain "common" but not multi-loader

**Fix**:
1. Check for common/ directory at root
2. Verify settings.gradle includes multiple projects
3. Look for platform-specific dependencies per module
4. If uncertain, report "Possibly multi-loader (manual verification needed)"

---

## Success Checklist

After completing analysis, verify:

- ✅ Framework identified (Forge/NeoForge/Fabric/Quilt)
- ✅ Minecraft version extracted
- ✅ Framework version extracted
- ✅ Single vs multi-loader determined
- ✅ Source structure mapped
- ✅ Convention patterns detected
- ✅ Report is actionable (tells specialist what to do)
- ✅ Confidence level stated
- ✅ Analysis completed in <5 seconds

---

**Related Documentation**:
- [Project Detection Guide](./project-detection-guide.md) - Deep dive into detection patterns
- [Dependency Reference](./dependency-reference.md) - Complete dependency interpretation
- [Analysis Examples](./analysis-examples.md) - Real-world analysis walkthroughs

Back to [intellij-project-analyzer.md](../../intellij-project-analyzer.md)
