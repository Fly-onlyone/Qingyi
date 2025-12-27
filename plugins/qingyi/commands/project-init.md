---
name: project-init
description: Initialize Claude Code context structure for a new project
aliases:
  - init
  - setup
---

Initialize Claude Code context for this project: {0}

**Instructions for AI**:

## Phase 1: Project Detection

1. **Analyze project root**:
   - Check for `build.gradle` / `build.gradle.kts` (Gradle project)
   - Check for `pom.xml` (Maven project)
   - Check for `package.json` (Node.js project)
   - Check for `pyproject.toml` / `setup.py` (Python project)
   - Check for `mods.toml` or `fabric.mod.json` (Minecraft mod)

2. **Detect Minecraft mod specifics** (if applicable):
   - Framework: Forge (ForgeGradle), NeoForge (NeoGradle), Fabric (Loom)
   - Version from `gradle.properties`: `minecraft_version`, `forge_version`, `neo_version`
   - Mod ID from config files
   - Multi-loader structure (common/forge/fabric modules)

3. **Parse arguments**:
   - `--minimal`: Skip optional sections (docs/, rules/)
   - `--force`: Overwrite existing files
   - `--no-skill`: Skip skill generation
   - `--skill-name=<name>`: Custom skill name (default: `repomix-reference-<project>`)
   - `--upgrade`: Force upgrade check even if structure looks current

4. **Check for existing initialization**:
   - `.claude/CLAUDE.md` exists?
   - `.claude/rules/` exists?
   - `CLAUDE.local.md` exists?

## Phase 2: Upgrade Check

If `.claude/CLAUDE.md` already exists, check if it needs upgrading:

**Detection Logic**:
```
if .claude/CLAUDE.md exists:
    if "Context7" not in CLAUDE.md → needs upgrade
    if .claude/rules/ missing → needs upgrade
    if no skill exists for this project → needs skill generation

    if needs upgrade and not --force:
        use MERGE strategy
    elif --force:
        use REPLACE strategy
```

**Upgrade Behavior (Merge Strategy)**:
1. Read existing `.claude/CLAUDE.md`
2. Extract user-added sections (preserve customizations)
3. Add missing sections (Context7, framework detection, reference skill link)
4. Replace outdated references (docs-mcp-server → Context7)
5. Create missing `.claude/rules/` directory
6. Generate reference skill if missing

## Phase 3: Structure Creation/Update

Create or update the following structure:

```
project/
├── .claude/
│   ├── CLAUDE.md                # Project-specific instructions
│   └── rules/
│       ├── conventions.md       # Code style and naming conventions
│       └── architecture.md      # Architecture patterns and decisions
├── docs/                        # Project documentation (unless --minimal)
│   └── api-discoveries/         # API notes Claude learns over time
└── CLAUDE.local.md              # Personal preferences (auto-gitignored)
```

### File Templates

**CLAUDE.md** (Minecraft mod detected):
```markdown
# Project: {mod_name}

## Framework
- **Type**: {Forge|NeoForge|Fabric|Quilt}
- **Minecraft Version**: {version}
- **Framework Version**: {forge/neo/fabric version}
- **Mod ID**: {mod_id}

## Build Commands
- `./gradlew build` - Build the mod
- `./gradlew runClient` - Run Minecraft client with mod
- `./gradlew runServer` - Run dedicated server with mod
- `./gradlew runData` - Run data generation

## Package Structure
{auto-detected package layout}

## Key Patterns
- Registry: See rules/conventions.md
- Events: {framework}-specific patterns
- Data: NBT serialization patterns

## Documentation Lookup
Use Context7 MCP for framework documentation:
1. `resolve-library-id("Minecraft Forge")` or `("Fabric API")`
2. `get-library-docs(topic="registry", mode="code")`

## Project Reference
A comprehensive reference skill was generated at:
`.claude/skills/repomix-reference-{project}/SKILL.md`

Use this for codebase context and pattern discovery.
```

**CLAUDE.md** (Generic project):
```markdown
# Project: {project_name}

## Project Type
- **Language**: {detected language}
- **Build System**: {Gradle|Maven|npm|pip|etc.}

## Commands
{auto-detected build/test commands}

## Documentation Lookup
Use Context7 MCP for library documentation:
1. `resolve-library-id("<library-name>")`
2. `get-library-docs(topic="<topic>", mode="code")`

## Project Reference
A comprehensive reference skill was generated at:
`.claude/skills/repomix-reference-{project}/SKILL.md`
```

**rules/conventions.md** (Minecraft):
```markdown
# Code Conventions

## Naming
- Mod ID: lowercase, underscores (`{mod_id}`)
- Registry names: lowercase, underscores (`custom_sword`)
- Class names: PascalCase (`CustomSwordItem`)

## Registry Pattern ({framework})
{framework-specific DeferredRegister or Registry.register example}

## Event Handlers
{framework-specific @SubscribeEvent or callback example}
```

**rules/conventions.md** (Generic):
```markdown
# Code Conventions

## Naming
{project-specific naming conventions}

## Code Style
{auto-detected style preferences}
```

**rules/architecture.md**:
```markdown
# Architecture Patterns

## Project Structure
{description of module organization}

## Key Design Decisions
{architectural notes as they emerge}
```

## Phase 4: Gitignore Update

Add to `.gitignore` if not present:
```
# Claude Code local files
CLAUDE.local.md
.claude/*.local.md
```

## Phase 5: Generate Reference Skill (ALWAYS unless --no-skill)

**CRITICAL**: Always run `mcp__repomix__generate_skill` unless `--no-skill` is specified.

```
mcp__repomix__generate_skill(
  directory: "<project_root>",
  skillName: "repomix-reference-<project-name>"
)
```

This creates:
```
.claude/skills/repomix-reference-<project>/
├── SKILL.md                    # Entry point
└── references/
    ├── summary.md              # Purpose and statistics
    ├── project-structure.md    # Directory tree
    ├── files.md                # File contents
    └── tech-stack.md           # Dependencies
```

**Benefit**: Provides persistent, searchable codebase context without repeated file reads.

## Phase 6: Summary Report

After initialization, report:

```markdown
## Initialization Complete

### Created
- `.claude/CLAUDE.md` - Project instructions ({framework} detected)
- `.claude/rules/conventions.md` - Code conventions
- `.claude/rules/architecture.md` - Architecture patterns
- `.claude/skills/repomix-reference-{project}/` - Reference skill
- `CLAUDE.local.md` - Personal preferences (gitignored)

### Detected
- Framework: {Forge 1.20.1 | NeoForge 1.21.3 | Fabric 1.20.4 | ...}
- Mod ID: {mod_id}
- Build System: {Gradle|Maven|npm|...}

### Next Steps
1. Edit `.claude/CLAUDE.md` to add project-specific conventions
2. Use `/qingyi <task>` for Minecraft modding assistance
3. Reference `@.claude/skills/repomix-reference-{project}` for codebase context

### Documentation
For framework docs, use Context7:
- `/qingyi help with Forge registry system`
- Claude will automatically use Context7 for documentation lookup
```

**Upgrade Report** (if upgrading):
```markdown
## Upgrade Complete

### Updated
- CLAUDE.md: Added Context7 section, preserved your customizations
- Added .claude/rules/conventions.md
- Added .claude/rules/architecture.md

### Generated
- .claude/skills/repomix-reference-{project}/

### Preserved
- Your custom sections in CLAUDE.md
- CLAUDE.local.md (unchanged)
```

---

## Usage Examples

```
/project-init
/init
/setup
/project-init --minimal
/project-init --force
/project-init --no-skill
/project-init --skill-name=my-mod-reference
/project-init --upgrade
/project-init This is a Forge 1.20.1 magic mod
```
