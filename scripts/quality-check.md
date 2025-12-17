# Qingyi Plugin Quality Check

Run these tests after installing the plugin to verify everything works correctly.

## 1. Structure Validation

### Check Plugin Files
```bash
# Verify marketplace configuration
cat .claude-plugin/marketplace.json

# Count agents (should be 10+ files)
ls -l plugins/qingyi/agents/*.md | wc -l

# Count skills (should be 17+ SKILL.md files)
find plugins/qingyi/skills -name "SKILL.md" | wc -l

# Verify YAML frontmatter in agents
head -20 plugins/qingyi/agents/qingyi-orchestrator.md
```

**Expected Results**:
- ✅ marketplace.json exists and is valid JSON
- ✅ 10+ agent files in plugins/qingyi/agents/
- ✅ 17+ skill files with SKILL.md
- ✅ All agents have valid YAML frontmatter

---

## 2. Agent Invocation Tests

### Test A: Master Orchestrator
**Command**: `Use the qingyi-orchestrator agent to analyze this Minecraft mod project structure`

**Expected Behavior**:
1. Agent launches in isolated context
2. Reads build.gradle, gradle.properties to detect framework
3. Provides structured analysis with phase breakdown
4. Suggests relevant specialist agents

**Validation Checklist**:
- [ ] Agent launches without errors
- [ ] Auto-detects Forge/NeoForge/Fabric correctly
- [ ] Loads pattern-recognition skill
- [ ] Provides phase-based implementation plan

---

### Test B: Registry Expert
**Command**: `Use the registry-and-content-expert agent to create a custom sword item`

**Expected Behavior**:
1. Auto-detects framework from project files
2. Uses correct pattern (DeferredRegister for Forge/NeoForge, Registry.register for Fabric)
3. References creative tab registration
4. Provides complete working code

**Validation Checklist**:
- [ ] Correct framework pattern used
- [ ] forge-registry-api or neoforge-registry-api skill loaded
- [ ] Code includes creative tab registration
- [ ] No mixing of framework patterns

---

### Test C: Event Expert
**Command**: `Use the events-and-lifecycle-expert agent to add a player join event handler`

**Expected Behavior**:
1. Uses @SubscribeEvent for Forge/NeoForge
2. Uses correct event bus (MOD_EVENT_BUS vs FORGE)
3. Includes proper method signature
4. Loads forge-event-system skill

**Validation Checklist**:
- [ ] forge-event-system skill referenced
- [ ] Correct event bus selection
- [ ] @SubscribeEvent annotation present
- [ ] Side awareness (client/server) explained

---

## 3. Skill Loading Tests

### Test D: Progressive Loading
**Command**: `I need advanced Forge event priorities and cancellation rules`

**Expected Behavior**:
1. Main skill loads first (forge-event-system/SKILL.md)
2. Supporting file loads on-demand (event-priorities.md)
3. Provides detailed priority examples
4. Token-efficient (doesn't load unneeded files)

**Validation Checklist**:
- [ ] Mentions event-priorities.md explicitly
- [ ] Shows EventPriority enum values
- [ ] Explains cancellation mechanics
- [ ] Doesn't load tick-handlers.md (not needed)

---

### Test E: Framework Detection
**Command**: `Show me how to register a block`

**Expected Behavior**:
1. Reads build.gradle to detect framework
2. Loads appropriate skill (forge-registry-api vs fabric-registry-api)
3. Uses framework-specific patterns
4. No "here's Forge, here's Fabric" - just the right one

**Validation Checklist**:
- [ ] Only shows pattern for detected framework
- [ ] Correct DeferredRegister or Registry.register usage
- [ ] Namespace/MODID handling correct
- [ ] Block item registration included

---

## 4. IntelliJ Integration Tests

### Test F: Code Navigator
**Command**: `Use the intellij-code-navigator agent to find all event handlers in this project`

**Expected Behavior**:
1. Uses mcp__intellij__search_in_files_by_text
2. Searches for @SubscribeEvent annotation
3. Uses intellij-navigation-patterns skill
4. Provides file paths with line numbers

**Validation Checklist**:
- [ ] Uses IntelliJ MCP tools (not Bash grep)
- [ ] Finds all @SubscribeEvent methods
- [ ] Provides file:line references
- [ ] Groups by event type

---

### Test G: Code Validator
**Command**: `Use the minecraft-code-validator agent to check for common issues`

**Expected Behavior**:
1. Uses mcp__intellij__get_file_problems
2. Loads intellij-inspection-guide skill
3. Checks for Minecraft-specific anti-patterns
4. Prioritizes errors over warnings

**Validation Checklist**:
- [ ] Uses IntelliJ inspections (not manual analysis)
- [ ] Flags registry name mismatches
- [ ] Detects side-only violations
- [ ] Warns about NBT type mismatches

---

### Test H: Refactoring Master
**Command**: `Use the intellij-refactoring-master agent to rename MyItem to CustomSword`

**Expected Behavior**:
1. Uses mcp__intellij__rename_refactoring tool
2. Checks for registry name conflicts
3. Loads intellij-refactoring-safety skill
4. Updates all references atomically

**Validation Checklist**:
- [ ] Uses rename_refactoring (not search-replace)
- [ ] Warns about registry name changes
- [ ] Updates resource files if needed
- [ ] Verifies world compatibility impact

---

## 5. Self-Evolution Tests

### Test I: Pattern Recognition
**Command**: `Use the qingyi-orchestrator agent to learn patterns from this project`

**Expected Behavior**:
1. Scans project for custom patterns
2. Compares with existing skills
3. Proposes new skill if pattern is novel
4. Asks permission before creating

**Validation Checklist**:
- [ ] Identifies project-specific patterns
- [ ] Compares with pattern-recognition skill
- [ ] Generates skill proposal with examples
- [ ] Doesn't auto-create (asks first)

---

## 6. Cross-Plugin Tests

### Test J: Code Review Plugin
**Command**: `Review this Minecraft mod code for security issues`

**Expected Behavior**:
1. qingyi-code-review skills load
2. java-security-patterns skill active
3. minecraft-code-review-patterns skill active
4. Checks for command injection, file access vulnerabilities

**Validation Checklist**:
- [ ] Both code review skills referenced
- [ ] Flags command injection risks
- [ ] Checks file path validation
- [ ] Warns about NBT deserialization

---

### Test K: Modernizer Plugin
**Command**: `Help me migrate from Forge 1.20.1 to NeoForge 1.21.3`

**Expected Behavior**:
1. qingyi-modernizer skills load
2. mod-migration-guide/forge-to-neoforge.md referenced
3. Provides step-by-step migration plan
4. Uses strangler fig pattern

**Validation Checklist**:
- [ ] Migration guide skill loaded
- [ ] Phased migration plan (not big bang)
- [ ] Package name changes documented
- [ ] Dependency updates included

---

## 7. Common Issues & Fixes

### Issue: Agent Not Found
**Symptom**: "Agent not available" error when invoking

**Checks**:
1. Verify file exists: `ls plugins/qingyi/agents/[agent-name].md`
2. Check marketplace.json lists the agent
3. Restart Claude Code session
4. Check YAML frontmatter has `name:` field

### Issue: Skill Not Loading
**Symptom**: Generic responses, no framework-specific code

**Checks**:
1. Verify SKILL.md exists in skill directory
2. Check YAML frontmatter in SKILL.md
3. Ensure agent's `skills:` field lists the skill
4. Check skill description matches query keywords

### Issue: Wrong Framework Pattern
**Symptom**: Forge code suggested for Fabric project

**Checks**:
1. Verify build.gradle contains correct plugin (Loom vs ForgeGradle)
2. Check for mods.toml (Forge) vs fabric.mod.json (Fabric)
3. Ensure agent reads project files before suggesting code
4. Check gradle.properties for version numbers

### Issue: IntelliJ Tools Not Working
**Symptom**: "IntelliJ MCP not available" error

**Checks**:
1. Verify IntelliJ MCP server is running
2. Check Claude Code settings for MCP configuration
3. Ensure project is open in IntelliJ
4. Restart IntelliJ and Claude Code

---

## 8. Performance Benchmarks

### Token Efficiency Test
Compare token usage for the same task with/without skills:

**Without Skills** (baseline):
- Task: "Create a custom item"
- Estimated tokens: ~5000 (explains everything from scratch)

**With Skills** (Qingyi):
- Task: "Create a custom item"
- Estimated tokens: ~1500 (references existing patterns)
- **Savings**: ~70% reduction

### Accuracy Test
Verify code compiles without changes:

**Test Setup**:
1. Ask agent to generate complete feature
2. Copy code exactly as provided
3. Run Minecraft client/server

**Success Criteria**:
- [ ] Code compiles without errors
- [ ] No runtime crashes
- [ ] Feature works as described
- [ ] No console errors/warnings

---

## 9. Regression Tests

Run these periodically to ensure updates don't break functionality:

```bash
# Test 1: All agents invoke successfully
for agent in qingyi-orchestrator registry-and-content-expert events-and-lifecycle-expert; do
  echo "Testing $agent..."
  # Invoke agent and check for errors
done

# Test 2: All skills have valid YAML
find plugins/qingyi/skills -name "SKILL.md" -exec head -10 {} \;

# Test 3: No broken markdown links
find plugins/qingyi -name "*.md" -exec grep -o '\[.*\](\.\/.*\.md)' {} \; | sort -u

# Test 4: Check for TODO/FIXME markers
grep -r "TODO\|FIXME" plugins/qingyi/
```

---

## 10. Quality Gates

Before considering the plugin production-ready:

- [ ] All 11 tests (A-K) pass
- [ ] No YAML syntax errors in agents/skills
- [ ] All markdown links resolve
- [ ] Token savings ≥50% vs baseline
- [ ] Code accuracy ≥95% (compiles without changes)
- [ ] IntelliJ integration works
- [ ] Framework detection 100% accurate
- [ ] Progressive loading works (supporting files load on-demand)
- [ ] Self-evolution proposes valid skills
- [ ] Cross-plugin compatibility verified

---

## Quick Smoke Test

Run this minimal test to verify basic functionality:

```bash
# 1. Structure check
test -f .claude-plugin/marketplace.json && echo "✓ Marketplace config exists"

# 2. Agent check
test -f plugins/qingyi/agents/qingyi-orchestrator.md && echo "✓ Orchestrator exists"

# 3. Skill check
test -f plugins/qingyi/skills/forge-registry-api/SKILL.md && echo "✓ Registry skill exists"
```

Then in Claude Code:
1. Type: `Use the qingyi-orchestrator agent to say hello`
2. Verify agent launches
3. Type: `Show me Forge item registration`
4. Verify skill is referenced

If all pass → Plugin is functional! 🎉

---

## Support

If tests fail, check:
1. [CLAUDE.md](../CLAUDE.md) - Plugin development guide
2. [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md) - System design
3. [docs/AGENTS.md](../docs/AGENTS.md) - Agent creation
4. [examples/](../examples/) - Working examples

Report issues with test results and error messages.
