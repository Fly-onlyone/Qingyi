# Analysis Examples - Real-World Project Analysis Workflows

Practical examples demonstrating the complete project analysis process for various Minecraft mod structures across different frameworks and patterns.

## Overview

This guide provides step-by-step analysis walkthroughs for real-world scenarios, showing how the Project Analyzer detects, interprets, and reports on different project types.

---

## Example 1: Standard Forge Mod Analysis

### Project Context

**User Request**: "I need to add a new sword to my mod. What's the structure?"

**Project**: TutorialMod (unknown framework, unknown structure)

### Analysis Workflow

#### Step 1: Get Project Modules

```
Tool: get_project_modules()

Result:
- Module: tutorialmod (JAVA)

Analysis:
- Single module detected
- Likely single-loader project
- Proceed to dependency check
```

#### Step 2: Get Dependencies

```
Tool: get_project_dependencies()

Result:
- net.minecraftforge:forge:1.20.1-47.1.0
- mezz.jei:jei-1.20.1-forge:15.2.0.27
- top.theillusivec4.curios:curios-forge:5.4.5+1.20.1

Analysis:
- Framework: Forge
- MC Version: 1.20.1 (from forge dependency)
- Forge Version: 47.1.0
- Optional: JEI integration, Curios API
```

#### Step 3: List Directory Structure

```
Tool: list_directory_tree(".", maxDepth=3)

Result:
tutorialmod/
├── gradle/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── example/
│   │   │           └── tutorialmod/
│   │   └── resources/
│   │       ├── META-INF/
│   │       │   └── mods.toml
│   │       └── assets/
│   └── generated/
├── build.gradle
└── gradle.properties

Analysis:
- Standard Forge structure
- Source: src/main/java
- Resources: src/main/resources
- Metadata: mods.toml confirmed
- Generated sources present (likely using data generators)
```

#### Step 4: Get Repositories

```
Tool: get_repositories()

Result:
- Repository: Git
  Path: C:/Users/Dev/TutorialMod
  Branch: main

Analysis:
- Single Git repository
- Standard version control setup
```

#### Step 5: Analyze Patterns

```
Tool: search_in_files_by_text("DeferredRegister", fileMask="*.java")

Result:
Found in: src/main/java/com/example/tutorialmod/init/ModItems.java

Code:
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, TutorialMod.MODID);

Analysis:
- Registry Pattern: DeferredRegister (confirmed Forge pattern)
- Registry Class: ModItems.java
- Mod ID: TutorialMod.MODID
```

```
Tool: search_in_files_by_text("@SubscribeEvent", fileMask="*.java")

Result:
Found in: src/main/java/com/example/tutorialmod/events/ForgeEvents.java

Analysis:
- Event System: @SubscribeEvent annotation (Forge)
- Event Class: ForgeEvents.java
```

#### Step 6: Generate Report

```markdown
## Project Analysis: TutorialMod

**Project Type**: Single-Loader (Forge)
**Framework**: Forge 47.1.0
**Minecraft Version**: 1.20.1
**Java Version**: 17

### Dependencies
- Core: Forge 47.1.0
- Integration: JEI 15.2.0.27, Curios API 5.4.5

### Structure
- Single module with standard src/main layout
- Registry class: ModItems.java
- Event class: ForgeEvents.java
- Assets: src/main/resources/assets/tutorialmod/
- Data generators: Detected (src/generated/)

### Code Conventions
- **Registry**: DeferredRegister pattern
- **Events**: @SubscribeEvent on FORGE bus
- **Mod ID**: "tutorialmod"

### Recommendation for Adding Sword

1. **Register in ModItems.java**:
   ```java
   public static final RegistryObject<Item> CUSTOM_SWORD =
       ITEMS.register("custom_sword", () -> new SwordItem(
           Tiers.IRON, 3, -2.4f,
           new Item.Properties()
       ));
   ```

2. **Create Model**: src/main/resources/assets/tutorialmod/models/item/custom_sword.json

3. **Create Texture**: src/main/resources/assets/tutorialmod/textures/item/custom_sword.png

4. **Add Translation**: Add to en_us.json:
   ```json
   "item.tutorialmod.custom_sword": "Custom Sword"
   ```

5. **Optional Recipe**: Create crafting recipe in data/tutorialmod/recipes/
```

---

## Example 2: Fabric Mod with Client Split

### Project Context

**User Request**: "Analyze this Fabric mod for adding a custom block with special rendering"

**Project**: AdvancedBlocks (known Fabric, unknown structure)

### Analysis Workflow

#### Step 1: Get Project Modules

```
Tool: get_project_modules()

Result:
- Module: advancedblocks (JAVA)

Analysis:
- Single module detected
- Check for Fabric-specific source set split
```

#### Step 2: Get Dependencies

```
Tool: get_project_dependencies()

Result:
- net.fabricmc:fabric-loader:0.15.0
- net.fabricmc.fabric-api:fabric-api:0.92.0+1.20.1
- me.shedaniel:RoughlyEnoughItems:12.0.684

Analysis:
- Framework: Fabric
- MC Version: 1.20.1 (from fabric-api)
- Loader: 0.15.0
- API: 0.92.0
- Optional: REI integration
```

#### Step 3: List Directory Structure

```
Tool: list_directory_tree("src", maxDepth=4)

Result:
src/
├── main/
│   ├── java/
│   │   └── com/
│   │       └── example/
│   │           └── blocks/
│   │               ├── AdvancedBlocks.java
│   │               └── blocks/
│   └── resources/
│       ├── fabric.mod.json
│       └── assets/advancedblocks/
├── client/
│   ├── java/
│   │   └── com/
│   │       └── example/
│   │           └── blocks/
│   │               └── client/
│   │                   └── BlockRenderers.java
│   └── resources/
└── data/
    └── advancedblocks/

Analysis:
- Fabric source set split detected
- src/main/java: Common code
- src/client/java: Client-only code (rendering)
- src/data/: Data generation
- Metadata: fabric.mod.json confirmed
```

#### Step 4: Analyze Patterns

```
Tool: search_in_files_by_text("Registry.register", fileMask="*.java")

Result:
Found in: src/main/java/com/example/blocks/ModBlocks.java

Code:
public static final Block CUSTOM_BLOCK = Registry.register(
    Registries.BLOCK,
    new Identifier(MOD_ID, "custom_block"),
    new Block(FabricBlockSettings.of(Material.STONE))
);

Analysis:
- Registry Pattern: Registry.register (confirmed Fabric pattern)
- Registry Class: ModBlocks.java
```

```
Tool: search_in_files_by_text("BlockEntityRendererRegistry", fileMask="*.java", directoryToSearch="src/client")

Result:
Found in: src/client/java/com/example/blocks/client/BlockRenderers.java

Analysis:
- Client-only rendering code properly isolated in src/client/
- Renders registered via BlockEntityRendererRegistry
```

#### Step 5: Generate Report

```markdown
## Project Analysis: AdvancedBlocks

**Project Type**: Single-Loader (Fabric with Client Split)
**Framework**: Fabric Loader 0.15.0 + API 0.92.0
**Minecraft Version**: 1.20.1
**Java Version**: 17

### Structure
- Main: src/main/java (common code - client + server)
- Client: src/client/java (client-only code)
- Data: src/data/ (data generation)

### Code Organization
- **Common Code**: ModBlocks.java (src/main/)
- **Client Code**: BlockRenderers.java (src/client/)
- **Registry**: Registry.register pattern
- **Mod ID**: "advancedblocks"

### Recommendation for Adding Rendered Block

1. **Register Block (Common)** in ModBlocks.java:
   ```java
   public static final Block RENDERED_BLOCK = Registry.register(
       Registries.BLOCK,
       new Identifier(MOD_ID, "rendered_block"),
       new Block(FabricBlockSettings.of(Material.STONE))
   );
   ```

2. **Register Renderer (Client)** in BlockRenderers.java:
   ```java
   BlockEntityRendererRegistry.register(
       RENDERED_BLOCK_ENTITY,
       RenderedBlockEntityRenderer::new
   );
   ```

3. **Create Renderer Class** in src/client/java:
   ```java
   @Environment(EnvType.CLIENT)
   public class RenderedBlockEntityRenderer implements BlockEntityRenderer<RenderedBlockEntity> {
       // Rendering logic
   }
   ```

4. **Assets**: Standard Fabric structure in assets/advancedblocks/

**Note**: Client-only code MUST be in src/client/ or annotated with @Environment(EnvType.CLIENT)
```

---

## Example 3: Multi-Loader Architectury Project

### Project Context

**User Request**: "I want to add a feature that works on both Forge and Fabric"

**Project**: UniversalMod (unknown structure)

### Analysis Workflow

#### Step 1: Get Project Modules

```
Tool: get_project_modules()

Result:
- Module: common (JAVA)
- Module: forge (JAVA)
- Module: fabric (JAVA)

Analysis:
- Three modules detected
- Module names match platform keywords
- Very high confidence: Multi-loader project
```

#### Step 2: Get Dependencies (Per Module)

```
Tool: get_project_dependencies()

Result:

Common Module:
- dev.architectury:architectury:9.1.12

Forge Module:
- net.minecraftforge:forge:1.20.1-47.1.0
- dev.architectury:architectury-forge:9.1.12
- implementation project(':common')

Fabric Module:
- net.fabricmc:fabric-loader:0.15.0
- net.fabricmc.fabric-api:fabric-api:0.92.0+1.20.1
- dev.architectury:architectury-fabric:9.1.12
- implementation project(':common')

Analysis:
- Multi-loader confirmed: Forge + Fabric
- MC Version: 1.20.1 (both platforms)
- Pattern: Architectury
- Common module shared between platforms
```

#### Step 3: List Directory Structure

```
Tool: list_directory_tree(".", maxDepth=3)

Result:
universalmod/
├── common/
│   └── src/
│       └── main/
│           ├── java/
│           │   └── com/mod/
│           └── resources/
│               └── assets/modid/
├── forge/
│   └── src/
│       └── main/
│           ├── java/
│           │   └── com/mod/forge/
│           └── resources/
│               └── META-INF/mods.toml
├── fabric/
│   └── src/
│       └── main/
│           ├── java/
│           │   └── com/mod/fabric/
│           └── resources/
│               └── fabric.mod.json
├── build.gradle
└── settings.gradle

Analysis:
- Classic Architectury structure
- Common: Shared code and assets
- Forge: Platform implementation + metadata
- Fabric: Platform implementation + metadata
```

#### Step 4: Analyze Patterns

```
Tool: search_in_files_by_text("interface", fileMask="*.java", directoryToSearch="common/src")

Result:
Found: common/src/main/java/com/mod/registry/ItemRegistry.java

Code:
public interface ItemRegistry {
    Supplier<Item> registerItem(String name, Supplier<Item> item);
}

Analysis:
- Abstraction pattern: Interfaces in common module
- Implementations expected in platform modules
```

```
Tool: search_in_files_by_text("DeferredRegister", fileMask="*.java", directoryToSearch="forge/src")

Result:
Found: forge/src/main/java/com/mod/forge/ForgeItemRegistry.java

Code:
public class ForgeItemRegistry implements ItemRegistry {
    private static final DeferredRegister<Item> ITEMS = ...

    public Supplier<Item> registerItem(String name, Supplier<Item> item) {
        RegistryObject<Item> obj = ITEMS.register(name, item);
        return obj::get;
    }
}
```

```
Tool: search_in_files_by_text("Registry.register", fileMask="*.java", directoryToSearch="fabric/src")

Result:
Found: fabric/src/main/java/com/mod/fabric/FabricItemRegistry.java

Code:
public class FabricItemRegistry implements ItemRegistry {
    public Supplier<Item> registerItem(String name, Supplier<Item> item) {
        Item registered = Registry.register(
            Registries.ITEM,
            new Identifier(MOD_ID, name),
            item.get()
        );
        return () -> registered;
    }
}
```

#### Step 5: Generate Report

```markdown
## Project Analysis: UniversalMod

**Project Type**: Multi-Loader (Architectury)
**Frameworks**: Forge 47.1.0 + Fabric 0.15.0
**Minecraft Version**: 1.20.1 (both platforms)
**Java Version**: 17

### Module Structure

#### Common Module
- Purpose: Shared code, interfaces, and assets
- Dependencies: Architectury API 9.1.12
- Content: Platform-agnostic interfaces
- Assets: Shared models, textures, lang files

#### Forge Module
- Purpose: Forge-specific implementation
- Dependencies: Forge 47.1.0, Architectury-Forge
- Implementation: ForgeItemRegistry using DeferredRegister
- Metadata: mods.toml

#### Fabric Module
- Purpose: Fabric-specific implementation
- Dependencies: Fabric Loader 0.15.0, Fabric API 0.92.0, Architectury-Fabric
- Implementation: FabricItemRegistry using Registry.register
- Metadata: fabric.mod.json

### Code Conventions

**Abstraction Pattern**:
1. Define interfaces in common/
2. Implement in forge/ with Forge APIs
3. Implement in fabric/ with Fabric APIs
4. Use platform helpers for cross-platform access

**Example**:
```java
// common/
public interface ItemRegistry {
    Supplier<Item> registerItem(String name, Supplier<Item> item);
}

// forge/
public class ForgeItemRegistry implements ItemRegistry { ... }

// fabric/
public class FabricItemRegistry implements ItemRegistry { ... }
```

### Recommendation for Adding Cross-Platform Feature

#### Step 1: Define in Common Module

Create interface: common/src/main/java/com/mod/feature/CustomFeature.java
```java
public interface CustomFeature {
    void initialize();
}
```

#### Step 2: Implement for Forge

Create: forge/src/main/java/com/mod/forge/ForgeCustomFeature.java
```java
public class ForgeCustomFeature implements CustomFeature {
    public void initialize() {
        // Forge-specific initialization
        MinecraftForge.EVENT_BUS.register(this);
    }
}
```

#### Step 3: Implement for Fabric

Create: fabric/src/main/java/com/mod/fabric/FabricCustomFeature.java
```java
public class FabricCustomFeature implements CustomFeature {
    public void initialize() {
        // Fabric-specific initialization
        ServerLifecycleEvents.SERVER_STARTING.register(server -> { });
    }
}
```

#### Step 4: Platform Loading

Use Architectury's ExpectPlatform or service loading to instantiate correct implementation.

#### Step 5: Shared Assets

Place models, textures, and lang files in common/src/main/resources/assets/modid/
Both platforms will use these resources.
```

---

## Example 4: NeoForge Project Analysis

### Project Context

**User Request**: "Quick analysis - what framework is this?"

**Project**: ModernMod (completely unknown)

### Analysis Workflow (Fast Path)

#### Step 1: Get Dependencies

```
Tool: get_project_dependencies()

Result:
- net.neoforged:neoforge:20.4.60-beta

Analysis:
- Framework: NeoForge (detected immediately)
- Version: 20.4.60-beta
- MC Version: 1.20.4 (from version prefix 20.4.x)
- Skip module check (already know it's single-loader)
```

#### Step 2: Quick Structure Check

```
Tool: list_directory_tree(".", maxDepth=2)

Result:
modernmod/
├── src/
│   └── main/
├── build.gradle
└── gradle.properties

Analysis:
- Standard single-loader structure confirmed
- No need for deep analysis
```

#### Step 3: Find Registry Pattern

```
Tool: search_in_files_by_text("DeferredRegister.create", fileMask="*.java")

Result:
Found in: src/main/java/com/modern/init/ModRegistry.java

Analysis:
- Uses DeferredRegister (NeoForge pattern same as Forge)
- Registry class: ModRegistry.java
```

#### Step 4: Generate Quick Report

```markdown
## Project Analysis: ModernMod

**Framework**: NeoForge 20.4.60-beta
**Minecraft Version**: 1.20.4
**Java Version**: 17

### Quick Summary
- Single-loader NeoForge project
- Standard structure
- Registry: DeferredRegister in ModRegistry.java

### Usage
Use NeoForge APIs (similar to Forge but with "net.neoforged" package)
Registry pattern identical to Forge.
```

---

## Example 5: Complex Multi-Loader with NeoForge

### Project Context

**User Request**: "Help me understand this complex mod structure"

**Project**: UltimateMod (3+ platforms)

### Analysis Workflow

#### Step 1: Get Project Modules

```
Tool: get_project_modules()

Result:
- Module: ultimatemod-common (JAVA)
- Module: ultimatemod-forge (JAVA)
- Module: ultimatemod-neoforge (JAVA)
- Module: ultimatemod-fabric (JAVA)

Analysis:
- Four modules detected
- Naming convention: projectname-platform
- Multi-loader with THREE platforms: Forge, NeoForge, Fabric
```

#### Step 2: Get Dependencies Per Module

```
Tool: get_project_dependencies()

Common Module:
- dev.architectury:architectury:9.1.12

Forge Module:
- net.minecraftforge:forge:1.20.1-47.1.0

NeoForge Module:
- net.neoforged:neoforge:20.4.60-beta

Fabric Module:
- net.fabricmc:fabric-loader:0.15.0
- net.fabricmc.fabric-api:fabric-api:0.95.0+1.20.4

Analysis:
- Supports Forge 1.20.1, NeoForge 1.20.4, Fabric 1.20.4
- DIFFERENT MC versions per platform!
- Complex version management required
```

#### Step 3: Generate Report

```markdown
## Project Analysis: UltimateMod

**Project Type**: Multi-Loader (Multi-Version)
**Platforms**: Forge + NeoForge + Fabric

### Version Matrix

| Platform  | MC Version | Loader Version |
|-----------|-----------|----------------|
| Forge     | 1.20.1    | 47.1.0         |
| NeoForge  | 1.20.4    | 20.4.60-beta   |
| Fabric    | 1.20.4    | 0.15.0         |

**Note**: Different MC versions per platform!

### Module Structure
- **common**: Shared interfaces (version-agnostic)
- **forge**: Forge 1.20.1 implementation
- **neoforge**: NeoForge 1.20.4 implementation
- **fabric**: Fabric 1.20.4 implementation

### Recommendation

When adding features:
1. Keep common/ truly version-agnostic (no MC version-specific code)
2. Handle version differences in platform modules
3. Test on ALL platforms
4. Be aware of API differences between MC 1.20.1 and 1.20.4
```

---

## Summary of Key Detection Patterns

### Pattern Recognition Table

| Indicator | Single-Loader | Multi-Loader | Confidence |
|-----------|--------------|--------------|------------|
| Module count = 1 | ✓ | ✗ | High |
| Modules: common, forge, fabric | ✗ | ✓ | Very High |
| mods.toml only | ✓ (Forge) | ✗ | High |
| fabric.mod.json only | ✓ (Fabric) | ✗ | High |
| Both metadata files in different modules | ✗ | ✓ | Very High |
| DeferredRegister + Registry.register in same file | ✗ | Possibly | Medium |
| Architectury dependency | ✗ | ✓ | High |
| project(':common') dependencies | ✗ | ✓ | Very High |

---

These examples demonstrate the complete analysis process for various real-world Minecraft mod structures.
