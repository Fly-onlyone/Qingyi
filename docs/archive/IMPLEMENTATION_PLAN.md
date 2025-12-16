# Implementation Plan: Customizing wshobson/agents for Qingyi

## Executive Summary

This plan details the customization of 5 agents from the wshobson/agents repository (docs-architect, tutorial-engineer, code-reviewer, legacy-modernizer, architect-review) for integration with the Qingyi Minecraft mod development plugin.

**Strategy**: Hybrid integration approach
- **3 agents** integrated into Qingyi (minecraft-docs-architect, minecraft-tutorial-engineer, minecraft-architect-reviewer)
- **2 agents** as separate plugins (code-reviewer in qingyi-code-review, legacy-modernizer in qingyi-modernizer)

**Version Target**: Qingyi v1.2.0
**Total New Components**: 5 agents, 8 skills, 4 commands
**Framework Support**: Forge 1.19-1.20.x, NeoForge 1.20-1.21.x, Fabric 1.19-1.21.x (auto-detection)
**Estimated Effort**: 5 weeks (120-150 hours)

---

## 1. Integration Decision Matrix

| Agent | Integration Type | Rationale | Plugin Location |
|-------|------------------|-----------|-----------------|
| **docs-architect** | **Qingyi Integration** | High Minecraft-specificity: mods.toml, registry systems, event handlers require deep domain knowledge | `agents/minecraft-docs-architect.md` |
| **tutorial-engineer** | **Qingyi Integration** | Tutorial content heavily Minecraft-focused: item creation, event handlers, GUI screens are mod-specific | `agents/minecraft-tutorial-engineer.md` |
| **architect-review** | **Qingyi Integration** | Architecture review needs Minecraft patterns: client/server separation, registry organization, event bus design | `agents/minecraft-architect-reviewer.md` |
| **code-reviewer** | **Separate Plugin** | General-purpose with Minecraft enhancement: can review any code, but knows Minecraft patterns | New plugin: `qingyi-code-review/` |
| **legacy-modernizer** | **Separate Plugin** | Reusable migration framework: applies to version migrations but not exclusively Minecraft | New plugin: `qingyi-modernizer/` |

**Naming Conventions**:
- Integrated agents get `minecraft-` prefix to indicate specialization
- Separate plugins retain original agent names (plugin-scoped)

---

## 2. Agent Customization Specifications

### 2.1 minecraft-docs-architect (Integrated into Qingyi)

**File**: `agents/minecraft-docs-architect.md`

**YAML Frontmatter**:
```yaml
name: minecraft-docs-architect
description: Creates comprehensive technical documentation (10-100+ pages) for Minecraft mods including architecture overview, registry systems, event handlers, mixin documentation, and API references. Use PROACTIVELY when generating mod documentation, API guides, or architectural deep-dives. Handles Forge, NeoForge, Fabric frameworks with auto-detection.
tools: Read, Write, Edit, Bash, Grep, Glob, Task
model: sonnet
permissionMode: acceptEdits
skills: minecraft-documentation-patterns, forge-registry-api, neoforge-registry-api, forge-event-system, nbt-serialization-patterns, pattern-recognition, multi-loader-project-patterns
```

**Key Minecraft Customizations**:
1. **Framework Detection**: Auto-detect via build.gradle, gradle.properties, mods.toml, fabric.mod.json
2. **Documentation Structure**: Standard Minecraft mod sections (Overview, Architecture, Registry, Events, Data Persistence, Rendering, Resources, API, Performance)
3. **Real Code Examples**: Use actual code from MusicMod (Forge 1.20.1) and Apocalypse_TNT (NeoForge)
4. **Framework Variants**: Document Forge vs Fabric approaches side-by-side

**Auto-Invocation Triggers**: "generate documentation", "create docs", "document the mod", "API reference"

---

### 2.2 minecraft-tutorial-engineer (Integrated into Qingyi)

**File**: `agents/minecraft-tutorial-engineer.md`

**YAML Frontmatter**:
```yaml
name: minecraft-tutorial-engineer
description: Creates step-by-step tutorials for Minecraft mod development covering item creation, event handlers, GUI screens, NBT data, custom entities, and mixins. Use PROACTIVELY when creating educational content, onboarding materials, or feature implementation guides. Handles Forge, NeoForge, Fabric with progressive difficulty and hands-on exercises.
tools: Read, Write, Edit, Grep, Glob
model: haiku
permissionMode: acceptEdits
skills: minecraft-tutorial-patterns, forge-registry-api, neoforge-registry-api, forge-event-system, rendering-patterns, code-summarizer
```

**Key Minecraft Customizations**:
1. **Progressive Difficulty**: Beginner (item registration) → Intermediate (events, NBT) → Advanced (entities, packets) → Expert (multi-loader, optimization)
2. **Hands-On Exercises**: Starter code with TODOs, step-by-step guides, common mistakes, challenge extensions
3. **Framework Comparisons**: Side-by-side Forge vs Fabric examples with "why this pattern?" explanations
4. **Real Examples**: Reference MusicMod patterns (audio, advancement UI) and Apocalypse_TNT patterns (entity spawning, boss bars)

**Auto-Invocation Triggers**: "create tutorial", "how do I", "explain", "learn", "step-by-step"

---

### 2.3 minecraft-architect-reviewer (Integrated into Qingyi)

**File**: `agents/minecraft-architect-reviewer.md`

**YAML Frontmatter**:
```yaml
name: minecraft-architect-reviewer
description: Reviews Minecraft mod architecture for design patterns, client/server separation, registry organization, event bus design, data persistence strategies, and multi-loader compatibility. Use PROACTIVELY for architectural decisions, system design validation, and identifying architectural smells in Forge, NeoForge, and Fabric mods.
tools: Read, Edit, Grep, Glob, Task
model: sonnet
permissionMode: default
skills: minecraft-architecture-patterns, pattern-recognition, multi-loader-project-patterns, forge-registry-api, neoforge-registry-api, forge-event-system, nbt-serialization-patterns
```

**Key Minecraft Customizations**:
1. **Architecture Review Checklist**: Package structure, client/server separation (CRITICAL), registry organization, event handler architecture, data persistence, multi-loader (if applicable)
2. **Pattern Recognition**: Singleton for services, Registry pattern (DDD), Strategy for behaviors, Facade for complexity, Observer (event-driven)
3. **Architectural Smells**: God Class, client-server violations (Minecraft.getInstance() in common code), registry leakage
4. **Report Format**: Executive summary, strengths, critical issues, architectural smells, recommended patterns, performance considerations, next steps

**Auto-Invocation Triggers**: "review architecture", "architectural review", "design review"

---

### 2.4 code-reviewer (Separate Plugin: qingyi-code-review)

**Plugin**: `qingyi-code-review/`
**File**: `qingyi-code-review/agents/code-reviewer.md`

**YAML Frontmatter**:
```yaml
name: code-reviewer
description: Elite code review specialist with AI-powered analysis for Java, Minecraft mods, security vulnerabilities (OWASP Top 10), performance optimization, and code quality. Use PROACTIVELY for reviewing implementations, pull requests, and critical code sections. Understands Minecraft-specific patterns (registry validation, event handler safety, client/server separation) when reviewing mods.
tools: Read, Edit, Grep, Glob, Task
model: sonnet
permissionMode: default
skills: minecraft-code-review-patterns, java-security-patterns, pattern-recognition
```

**Key Minecraft Enhancements**:
1. **Auto-Detection**: Detects Minecraft mod context (build.gradle with ForgeGradle/Loom, mods.toml, fabric.mod.json) and applies Minecraft-specific checks
2. **Minecraft Review Checklist**: Registry validation, event handler safety, client/server separation (CRITICAL - crashes on dedicated server), NBT security, resource file validation, performance patterns
3. **Integration with minecraft-code-validator**: Complements existing validator - code-reviewer is deep/educational, validator is fast/automated
4. **General-Purpose**: Can review non-Minecraft Java code independently

**Relationship with minecraft-code-validator**:
- **validator**: Fast, IntelliJ-based, auto-invoked after code generation
- **code-reviewer**: Deep, AI-powered, educational, invoked on-demand

---

### 2.5 legacy-modernizer (Separate Plugin: qingyi-modernizer)

**Plugin**: `qingyi-modernizer/`
**File**: `qingyi-modernizer/agents/legacy-modernizer.md`

**YAML Frontmatter**:
```yaml
name: legacy-modernizer
description: Refactors legacy code and migrates frameworks safely using incremental approaches. Use PROACTIVELY for Minecraft version migrations (1.19→1.20→1.21), framework migrations (Forge→NeoForge, monolithic→multi-loader), and general codebase modernization. Employs strangler fig pattern with backward compatibility.
tools: Read, Write, Edit, Bash, Grep, Glob
model: haiku
permissionMode: acceptEdits
skills: mod-migration-guide, gradle-migration-patterns, pattern-recognition
```

**Key Minecraft Enhancements**:
1. **Migration Types**:
   - Minecraft version upgrade (e.g., 1.19→1.20): API breaking changes, resource file updates
   - Framework migration (Forge→NeoForge): Package renames, API modernization, Capabilities→Components
   - Multi-loader conversion (monolithic→common/forge/fabric): Project restructure, platform abstraction
2. **Strangler Fig Pattern**: Incremental replacement, compatibility layers, phased migration
3. **Backward Compatibility**: World save compatibility (CRITICAL), config compatibility, API compatibility
4. **Testing Strategy**: Test in-game functionality, verify world loading, check multiplayer sync, rollback plans

---

## 3. New Skills to Create

### 3.1 minecraft-documentation-patterns
**Location**: `skills/minecraft-documentation-patterns/`
**Purpose**: Documentation patterns for Minecraft mods
**Supporting Files**: registry-docs-examples.md, event-handler-docs.md, mixin-documentation.md
**Used By**: minecraft-docs-architect

### 3.2 minecraft-tutorial-patterns
**Location**: `skills/minecraft-tutorial-patterns/`
**Purpose**: Educational tutorial patterns with progressive difficulty
**Supporting Files**: exercise-templates.md, common-mistakes.md, framework-comparisons.md
**Used By**: minecraft-tutorial-engineer

### 3.3 minecraft-architecture-patterns
**Location**: `skills/minecraft-architecture-patterns/`
**Purpose**: Architectural design patterns for Minecraft mods
**Supporting Files**: package-structures.md, client-server-separation.md
**Used By**: minecraft-architect-reviewer

### 3.4 minecraft-code-review-patterns
**Location**: `qingyi-code-review/skills/minecraft-code-review-patterns/`
**Purpose**: Code review checklists for Minecraft mods
**Supporting Files**: security-vulnerabilities.md, performance-antipatterns.md
**Used By**: code-reviewer

### 3.5 java-security-patterns
**Location**: `qingyi-code-review/skills/java-security-patterns/`
**Purpose**: Java security best practices (OWASP Top 10, cryptography)
**Used By**: code-reviewer
**Note**: Copy from wshobson/agents original content

### 3.6 mod-migration-guide
**Location**: `qingyi-modernizer/skills/mod-migration-guide/`
**Purpose**: Migration strategies for Minecraft mods
**Supporting Files**: forge-to-neoforge.md, minecraft-version-migrations.md, multi-loader-conversion.md
**Used By**: legacy-modernizer

### 3.7 gradle-migration-patterns
**Location**: `qingyi-modernizer/skills/gradle-migration-patterns/`
**Purpose**: Gradle build system migration for Minecraft mods
**Supporting Files**: build-examples.md
**Used By**: legacy-modernizer

### 3.8 fabric-registry-api
**Location**: `skills/fabric-registry-api/`
**Purpose**: Fabric registry system patterns
**Note**: Currently missing from Qingyi, needs to be created
**Used By**: registry-and-content-expert, minecraft-tutorial-engineer

---

## 4. Commands to Create

### 4.1 minecraft-doc-generate (Qingyi)
**Location**: `.claude-plugin/commands/minecraft-doc-generate.md`
**Slash Command**: `/minecraft-doc-generate` or `/mdoc`
**Purpose**: Generate comprehensive mod documentation
**Invokes**: minecraft-docs-architect

### 4.2 mod-explain (Qingyi)
**Location**: `.claude-plugin/commands/mod-explain.md`
**Slash Command**: `/mod-explain` or `/mex`
**Purpose**: Explain mod code with educational context
**Invokes**: minecraft-tutorial-engineer

### 4.3 mod-refactor (qingyi-modernizer)
**Location**: `qingyi-modernizer/commands/mod-refactor.md`
**Slash Command**: `/mod-refactor` or `/mref`
**Purpose**: Modernize code with safe migrations
**Invokes**: legacy-modernizer

### 4.4 mod-review (qingyi-code-review)
**Location**: `qingyi-code-review/commands/mod-review.md`
**Slash Command**: `/mod-review` or `/mrev`
**Purpose**: Comprehensive code review
**Invokes**: code-reviewer

**Additional Commands** (qingyi-modernizer, from wshobson/agents):
- `refactor-clean.md`: Original refactoring command (copy from wshobson/agents)
- `tech-debt.md`: Technical debt management (copy from wshobson/agents)
- `context-restore.md`: Context restoration (copy from wshobson/agents)

---

## 5. Orchestrator Integration

### 5.1 Updated Delegation Guide

**Add to qingyi-orchestrator.md** (around line 174):

```markdown
**For documentation generation**:
→ Use `minecraft-docs-architect`

**For tutorial creation & code explanation**:
→ Use `minecraft-tutorial-engineer`

**For architectural review**:
→ Use `minecraft-architect-reviewer`

**For comprehensive code review** (security, performance, quality):
→ Use `code-reviewer` (from qingyi-code-review plugin)

**For version/framework migration**:
→ Use `legacy-modernizer` (from qingyi-modernizer plugin)
```

### 5.2 Auto-Invocation Logic

**Add to "Proactive Invocation" section**:

- **Documentation Agent**: Triggered by "generate documentation", "create docs", "document the mod"
- **Tutorial Agent**: Triggered by "create tutorial", "how do I", "explain", "learn"
- **Architect Review Agent**: Triggered by "review architecture", "architectural review"
- **Code Review Agent**: NOT triggered automatically (deliberate - user must request)
- **Modernizer Agent**: Triggered by "migrate", "upgrade version", "modernize", version numbers (1.19→1.20)

### 5.3 New Workflow Phase

**Add Phase 6: Documentation** (after Phase 4.5: Testing):

When user requests documentation OR after major feature completion:
1. Determine documentation type (full mod docs, tutorial, architecture)
2. Invoke appropriate agent with context
3. Review and refine generated documentation
4. Report file locations and suggest next steps

---

## 6. Documentation Updates

### 6.1 CLAUDE.md
- Add 5 new agents to Agent Selection Guide table
- Add section for separate plugins (qingyi-code-review, qingyi-modernizer)
- Update conventions and framework support

### 6.2 docs/AGENTS.md
- Add entries for all 5 new agents with descriptions, tools, models, skills
- Add section for separate plugin agents

### 6.3 docs/SKILLS.md
- Add entries for all 8 new skills with locations and usage

### 6.4 README.md
- Add "New in v1.2.0" section highlighting documentation & modernization agents
- Add "Companion Plugins" section for qingyi-code-review and qingyi-modernizer

### 6.5 CHANGELOG.md
- Add v1.2.0 entry with all additions, changes, and migration notes

### 6.6 Plugin-Specific Documentation
- Create README.md for qingyi-code-review
- Create README.md for qingyi-modernizer
- Create docs/AGENTS.md and docs/SKILLS.md for both plugins
- Create CHANGELOG.md for both plugins

---

## 7. File Structure

### 7.1 Qingyi Plugin (Updated)

```
Qingyi/
├── .claude-plugin/
│   ├── plugin.json                      # v1.1.0 → v1.2.0
│   └── commands/
│       ├── minecraft-doc-generate.md    # NEW
│       └── mod-explain.md               # NEW
├── agents/
│   ├── qingyi-orchestrator.md           # UPDATED
│   ├── minecraft-docs-architect.md      # NEW
│   ├── minecraft-tutorial-engineer.md   # NEW
│   └── minecraft-architect-reviewer.md  # NEW
├── skills/
│   ├── fabric-registry-api/             # NEW (missing)
│   ├── minecraft-documentation-patterns/ # NEW
│   ├── minecraft-tutorial-patterns/      # NEW
│   └── minecraft-architecture-patterns/  # NEW
├── docs/
│   ├── AGENTS.md                        # UPDATED
│   └── SKILLS.md                        # UPDATED
├── CLAUDE.md                             # UPDATED
├── CHANGELOG.md                          # UPDATED
└── README.md                             # UPDATED
```

### 7.2 qingyi-code-review Plugin (New)

```
qingyi-code-review/
├── .claude-plugin/
│   └── plugin.json                      # v1.0.0
├── agents/
│   └── code-reviewer.md                 # Customized
├── skills/
│   ├── minecraft-code-review-patterns/  # NEW
│   ├── java-security-patterns/          # NEW
│   └── pattern-recognition/             # COPIED from Qingyi
├── commands/
│   └── mod-review.md                    # NEW
├── docs/
│   ├── AGENTS.md                        # NEW
│   └── SKILLS.md                        # NEW
├── README.md                             # NEW
├── CHANGELOG.md                          # NEW
└── LICENSE                               # NEW
```

### 7.3 qingyi-modernizer Plugin (New)

```
qingyi-modernizer/
├── .claude-plugin/
│   └── plugin.json                      # v1.0.0
├── agents/
│   └── legacy-modernizer.md             # Customized
├── skills/
│   ├── mod-migration-guide/             # NEW
│   ├── gradle-migration-patterns/       # NEW
│   └── pattern-recognition/             # COPIED from Qingyi
├── commands/
│   ├── mod-refactor.md                  # NEW
│   ├── refactor-clean.md                # From wshobson/agents
│   ├── tech-debt.md                     # From wshobson/agents
│   └── context-restore.md               # From wshobson/agents
├── docs/
│   ├── AGENTS.md                        # NEW
│   └── SKILLS.md                        # NEW
├── README.md                             # NEW
├── CHANGELOG.md                          # NEW
└── LICENSE                               # NEW
```

---

## 8. Testing Strategy

### 8.1 Agent Functionality Tests

**Test 1: minecraft-docs-architect**
- Input: "Generate comprehensive documentation for this mod"
- Expected: Detects framework, creates 50-80 page DOCUMENTATION.md with architecture, registry, events, resources
- Validation: Framework detected, structure matches template, real code examples used

**Test 2: minecraft-tutorial-engineer**
- Input: "Create a beginner tutorial for making a custom item"
- Expected: Progressive structure, framework variants, common mistakes, hands-on exercises
- Validation: Learning objectives present, code executable, challenge exercises included

**Test 3: minecraft-architect-reviewer**
- Input: "Review the architecture of this mod"
- Expected: Analyzes structure, validates client/server separation, reviews events, provides report
- Validation: Identifies architectural issues, suggests improvements with examples

**Test 4: code-reviewer**
- Input: "Review this event handler for security and performance"
- Expected: Detects Minecraft context, applies Minecraft checks, provides structured report
- Validation: Minecraft checks applied, client/server violations detected, priority rankings present

**Test 5: legacy-modernizer**
- Input: "Migrate this mod from Minecraft 1.20.1 to 1.21.3"
- Expected: Analyzes dependencies, creates phased plan, identifies breaking changes, provides compatibility layers
- Validation: Migration plan has phases, backward compatibility addressed, rollback plan provided

### 8.2 Integration Tests

**Test 6: Orchestrator Delegation**
- Scenario: User requests "Generate docs and create a tutorial for my mod"
- Expected: Orchestrator delegates to both minecraft-docs-architect and minecraft-tutorial-engineer, aggregates results
- Validation: Both agents invoked, no context leakage, results aggregated

**Test 7: Validation After Documentation**
- Scenario: minecraft-docs-architect generates docs, user requests validation
- Expected: Orchestrator invokes minecraft-code-validator on referenced code
- Validation: Validator checks documentation code snippets, reports issues

### 8.3 Skill Loading Tests

**Test 8: Skill Pre-loading**
- Verify all agents pre-load their specified skills correctly
- Check SKILL.md files load (progressive loading pattern)
- Verify supporting files load on-demand

### 8.4 Command Tests

**Test 9: Slash Commands**
- `/minecraft-doc-generate`: Invokes minecraft-docs-architect, creates DOCUMENTATION.md
- `/mod-explain`: Invokes minecraft-tutorial-engineer, provides explanation
- `/mod-refactor`: Invokes legacy-modernizer, creates migration plan
- `/mod-review`: Invokes code-reviewer, generates report

### 8.5 Framework Detection Tests

**Test 10: Framework Detection**
- Test with Forge 1.19.4, Forge 1.20.1, NeoForge 1.21.3, Fabric 1.20.1 projects
- Verify correct framework identification in each case
- Verify correct API patterns used in examples

---

## 9. Phased Implementation Roadmap

### Phase 1: Foundation (Week 1)

**Goals**: Create 8 new skills, update plugin manifest, update documentation

**Tasks**:
1. Create skills/minecraft-documentation-patterns/ (SKILL.md + 3 supporting files)
2. Create skills/minecraft-tutorial-patterns/ (SKILL.md + 3 supporting files)
3. Create skills/minecraft-architecture-patterns/ (SKILL.md + 2 supporting files)
4. Create skills/fabric-registry-api/ (SKILL.md only)
5. Create qingyi-code-review/skills/minecraft-code-review-patterns/ (SKILL.md + 2 supporting files)
6. Create qingyi-code-review/skills/java-security-patterns/ (SKILL.md, copy from wshobson/agents)
7. Create qingyi-modernizer/skills/mod-migration-guide/ (SKILL.md + 3 supporting files)
8. Create qingyi-modernizer/skills/gradle-migration-patterns/ (SKILL.md + 1 supporting file)
9. Update .claude-plugin/plugin.json (version 1.1.0 → 1.2.0)
10. Update CLAUDE.md with new agents/skills tables
11. Update CHANGELOG.md with v1.2.0 entry

**Validation Checklist**:
- [ ] All 8 skills have valid YAML frontmatter
- [ ] SKILL.md files are <200 lines (progressive loading)
- [ ] Supporting files linked correctly in SKILL.md
- [ ] plugin.json version updated to 1.2.0
- [ ] CLAUDE.md tables updated
- [ ] CHANGELOG.md entry complete

---

### Phase 2: Integrated Agents (Week 2)

**Goals**: Create 3 agents in Qingyi, create 2 commands, update orchestrator

**Tasks**:
1. Create agents/minecraft-docs-architect.md
   - Customize from wshobson/agents docs-architect.md
   - Add YAML frontmatter with Qingyi conventions
   - Add framework detection, Minecraft documentation structure
   - Add real code examples from MusicMod/Apocalypse_TNT
   - Reference minecraft-documentation-patterns skill

2. Create agents/minecraft-tutorial-engineer.md
   - Customize from wshobson/agents tutorial-engineer.md
   - Add YAML frontmatter with Qingyi conventions
   - Add progressive difficulty levels (Minecraft-specific)
   - Add hands-on exercise templates, framework comparisons
   - Reference minecraft-tutorial-patterns skill

3. Create agents/minecraft-architect-reviewer.md
   - Customize from wshobson/agents architect-review.md
   - Add YAML frontmatter with Qingyi conventions
   - Add Minecraft architecture review checklist
   - Add client/server separation validation
   - Reference minecraft-architecture-patterns skill

4. Create .claude-plugin/commands/minecraft-doc-generate.md
5. Create .claude-plugin/commands/mod-explain.md

6. Update agents/qingyi-orchestrator.md:
   - Add new agents to delegation guide (around line 174)
   - Add auto-invocation triggers
   - Add documentation workflow phase (after Phase 4.5)

**Validation Checklist**:
- [ ] 3 agents created with valid YAML frontmatter
- [ ] Agent descriptions include "Use PROACTIVELY"
- [ ] Skills pre-load correctly (test by invoking agent)
- [ ] 2 commands work: /minecraft-doc-generate, /mod-explain
- [ ] Orchestrator delegation guide updated
- [ ] Test: "Use minecraft-docs-architect to document this mod"
- [ ] Test: Orchestrator auto-invokes agents for relevant requests

---

### Phase 3: Separate Plugins (Week 3)

**Goals**: Create qingyi-code-review and qingyi-modernizer plugins

**Tasks**:

**qingyi-code-review:**
1. Create qingyi-code-review/ directory structure
2. Create qingyi-code-review/.claude-plugin/plugin.json (v1.0.0)
3. Create qingyi-code-review/agents/code-reviewer.md
   - Customize from wshobson/agents code-reviewer.md
   - Add YAML frontmatter
   - Add Minecraft-specific review section (optional, auto-detected)
   - Add integration notes with minecraft-code-validator
   - Reference minecraft-code-review-patterns skill
4. Create qingyi-code-review/commands/mod-review.md
5. Copy pattern-recognition skill to qingyi-code-review/skills/

**qingyi-modernizer:**
6. Create qingyi-modernizer/ directory structure
7. Create qingyi-modernizer/.claude-plugin/plugin.json (v1.0.0)
8. Create qingyi-modernizer/agents/legacy-modernizer.md
   - Customize from wshobson/agents legacy-modernizer.md
   - Add YAML frontmatter
   - Add Minecraft migration patterns (version, framework, multi-loader)
   - Add backward compatibility checklist
   - Reference mod-migration-guide skill
9. Create qingyi-modernizer/commands/mod-refactor.md
10. Copy commands from wshobson/agents: refactor-clean.md, tech-debt.md, context-restore.md
11. Copy pattern-recognition skill to qingyi-modernizer/skills/

**Validation Checklist**:
- [ ] Both plugin directories created with proper structure
- [ ] plugin.json files valid (name, version, description)
- [ ] code-reviewer agent functional in separate plugin
- [ ] legacy-modernizer agent functional in separate plugin
- [ ] Test: Load qingyi-code-review plugin (restart Claude Code)
- [ ] Test: Load qingyi-modernizer plugin (restart Claude Code)
- [ ] Test: Minecraft checks activate when mod detected
- [ ] Test: /mod-review command works
- [ ] Test: /mod-refactor command works

---

### Phase 4: Documentation & Testing (Week 4)

**Goals**: Update all documentation, comprehensive testing, quality assurance

**Tasks**:

**Documentation Updates:**
1. Update docs/AGENTS.md with 5 new agent entries
2. Update docs/SKILLS.md with 8 new skill entries
3. Update README.md with features and companion plugins sections
4. Create qingyi-code-review/README.md
5. Create qingyi-code-review/docs/AGENTS.md
6. Create qingyi-code-review/docs/SKILLS.md
7. Create qingyi-code-review/CHANGELOG.md
8. Create qingyi-modernizer/README.md
9. Create qingyi-modernizer/docs/AGENTS.md
10. Create qingyi-modernizer/docs/SKILLS.md
11. Create qingyi-modernizer/CHANGELOG.md

**Testing:**
12. Execute all test scenarios (Section 8):
    - Agent functionality tests (Tests 1-5)
    - Integration tests (Tests 6-7)
    - Skill loading tests (Test 8)
    - Command tests (Test 9)
    - Framework detection tests (Test 10)
13. Fix issues discovered during testing
14. Update documentation based on test findings

**Validation Checklist**:
- [ ] All documentation files created
- [ ] Cross-references correct (no broken links)
- [ ] Test 1 passed: minecraft-docs-architect generates docs
- [ ] Test 2 passed: minecraft-tutorial-engineer creates tutorials
- [ ] Test 3 passed: minecraft-architect-reviewer reviews architecture
- [ ] Test 4 passed: code-reviewer reviews with Minecraft checks
- [ ] Test 5 passed: legacy-modernizer creates migration plans
- [ ] Test 6 passed: Orchestrator delegates correctly
- [ ] Test 7 passed: Validation after documentation works
- [ ] Test 8 passed: All skills pre-load correctly
- [ ] Test 9 passed: All slash commands functional
- [ ] Test 10 passed: Framework detection accurate

---

### Phase 5: Refinement & Release (Week 5)

**Goals**: Polish, create examples, prepare release

**Tasks**:

**Create Examples:**
1. Use minecraft-docs-architect on MusicMod → examples/minecraft-docs-architect-output.md
2. Use minecraft-tutorial-engineer for "Custom Item" → examples/tutorial-custom-item.md
3. Use minecraft-architect-reviewer on Apocalypse_TNT → examples/architecture-review-report.md
4. Use code-reviewer on EventHandler.java → qingyi-code-review/examples/code-review-report.md
5. Use legacy-modernizer for 1.20→1.21 → qingyi-modernizer/examples/migration-plan.md

**Final Validation:**
6. Run all tests again (regression check)
7. Verify examples are accurate
8. Check all links work
9. Ensure version numbers consistent (1.2.0 for Qingyi, 1.0.0 for plugins)

**Prepare Release:**
10. Tag Git commit: `v1.2.0`
11. Update CHANGELOG.md with release date
12. Create release notes summarizing changes

**Validation Checklist**:
- [ ] 5 example outputs created
- [ ] Examples demonstrate real-world usage
- [ ] All tests pass (regression check)
- [ ] No broken links in documentation
- [ ] Version numbers consistent
- [ ] Git tag created: v1.2.0
- [ ] CHANGELOG.md has release date
- [ ] Release notes written
- [ ] Ready for user testing

---

## 10. Critical Success Factors

### 10.1 Must-Have Features

1. **Framework Auto-Detection**: Agents must correctly identify Forge/NeoForge/Fabric
2. **Skill Progressive Loading**: SKILL.md <200 lines, supporting files on-demand
3. **Real Code Examples**: Use actual MusicMod/Apocalypse_TNT code, not pseudocode
4. **Client/Server Separation**: minecraft-architect-reviewer and code-reviewer MUST catch violations
5. **Backward Compatibility**: legacy-modernizer MUST provide rollback plans

### 10.2 Testing Requirements

- **10/10 test scenarios must pass** before Phase 5
- **Framework detection accuracy**: 100% on test projects (Forge 1.19, 1.20, NeoForge 1.21, Fabric 1.20)
- **No regressions**: Existing Qingyi agents remain functional

### 10.3 Documentation Quality

- **No broken links**: All cross-references must resolve
- **Examples must be real**: Use actual project output, not fabricated examples
- **Clear installation**: Separate plugins must have clear install instructions

---

## 11. Risk Mitigation

### 11.1 Risk: Skill Token Limits
**Mitigation**: Keep SKILL.md <200 lines, use progressive loading, review before Phase 4

### 11.2 Risk: Agent Overlap with minecraft-code-validator
**Mitigation**: Document clear separation (validator=fast/automated, code-reviewer=deep/educational)

### 11.3 Risk: Framework Detection Inaccuracy
**Mitigation**: Explicit detection logic, test with diverse projects, allow user override

### 11.4 Risk: Real Code Examples Staleness
**Mitigation**: Version-tag examples, add "as of" dates, schedule quarterly reviews

### 11.5 Risk: Separate Plugin Discoverability
**Mitigation**: Prominent README mention, orchestrator suggestions, documentation cross-links

---

## 12. Post-Implementation Recommendations

### 12.1 Future Enhancements (v1.3.0)

**Potential Agents**:
- minecraft-performance-optimizer: Profile mods, suggest optimizations
- minecraft-data-generator: Create data generation providers
- minecraft-mixin-expert: Mixin development specialist

**Potential Skills**:
- fabric-event-system: Fabric hooks (parallel to forge-event-system)
- quilt-patterns: Quilt-specific features and QSL
- performance-optimization-patterns: Profiling, caching, async

**Potential Commands**:
- /mod-profile: Performance profiling
- /data-gen: Interactive data generation
- /mixin-debug: Mixin troubleshooting

### 12.2 Community Feedback Integration

After v1.2.0 release:
1. Gather feedback from Minecraft modding community
2. Identify pain points in current agent behavior
3. Propose improvements as GitHub issues
4. Prioritize based on user votes and impact

### 12.3 Maintenance Plan

**Quarterly**: Review code examples for Minecraft updates, update gradle-migration-patterns
**Yearly**: Major Minecraft version update (e.g., 1.21→1.22), update all registry examples
**As-Needed**: New framework support (e.g., Architectury), new mod loader support

---

## Summary

This plan provides a comprehensive roadmap for customizing 5 agents from wshobson/agents for Qingyi:

- **3 agents integrated** into Qingyi (minecraft-docs-architect, minecraft-tutorial-engineer, minecraft-architect-reviewer)
- **2 agents as separate plugins** (code-reviewer, legacy-modernizer)
- **8 new skills** covering documentation, tutorials, architecture, reviews, migrations
- **4 new commands** for quick access
- **5-week phased implementation** with clear validation checkpoints
- **10 comprehensive tests** ensuring quality
- **Complete documentation updates** across all files

**Next Step**: Begin Phase 1 (Foundation) - Create 8 skills and update plugin manifest.
