# Custom Commands

This directory contains reusable slash commands for the Qingyi plugin development workflow.

## Available Commands

### `/refactor-plugin-component` - Refactor Agents, Skills, or Documentation

Specialized refactoring command adapted for markdown-based Claude Code plugin components.

**When to use**:
- Agent YAML frontmatter issues
- Outdated Claude model versions
- Skills too large (need progressive loading)
- Duplicate patterns across components
- Outdated code examples
- Poor domain boundaries between agents
- Missing keywords in skill descriptions
- Documentation inconsistencies

**Usage**:

```
/refactor-plugin-component <component-path>
```

**Examples**:

```bash
# Refactor an agent
/refactor-plugin-component agents/qingyi-orchestrator.md

# Refactor a skill
/refactor-plugin-component skills/forge-event-system/SKILL.md

# Refactor documentation
/refactor-plugin-component CLAUDE.md
```

**What it does**:
1. Analyzes the component structure and content
2. Identifies issues (YAML syntax, duplicates, token waste, etc.)
3. Creates a prioritized refactoring plan
4. Implements improvements (with your approval)
5. Validates changes and updates related components
6. Provides testing checklist

**Output includes**:
- Issue analysis with severity ratings
- Refactoring plan with phases
- Complete refactored files with inline comments
- Testing checklist
- List of related components that need updates

### `/ai-review-plugin-component` - AI-Powered Quality Review

Comprehensive AI-powered review for plugin components using automated checks + Claude 4.5 Sonnet.

**When to use**:
- Before committing new agents or skills
- PR review automation (GitHub Actions)
- Regular quality checks
- Detecting YAML errors, broken links, pseudocode
- Validating token efficiency and keywords
- Checking domain boundaries and consistency

**Usage**:

```
/ai-review-plugin-component <component-path>
```

**Examples**:

```bash
# Review an agent
/ai-review-plugin-component agents/registry-and-content-expert.md

# Review a skill
/ai-review-plugin-component skills/forge-event-system/SKILL.md

# Review documentation
/ai-review-plugin-component CLAUDE.md
```

**What it does**:
1. Validates YAML frontmatter (syntax, required fields, formatting)
2. Analyzes content structure and organization
3. Checks code example quality (real vs pseudocode)
4. Detects agent domain overlap
5. Measures token efficiency (progressive loading)
6. Optimizes skill keywords for auto-loading
7. Validates cross-references and links
8. Verifies framework compatibility
9. Checks terminology consistency
10. AI-enhanced contextual analysis with Claude 4.5 Sonnet

**Output includes**:
- Severity-rated issues (CRITICAL/HIGH/MEDIUM/LOW)
- Category classification (YAML/Structure/Content/Quality/Efficiency)
- Line-by-line feedback with suggested fixes
- Token efficiency metrics (before/after)
- AI insights for contextual improvements
- Quality grade (A+ to F)
- Auto-fixable issue detection

## Command Workflow

### Recommended Workflow

The two commands work together for comprehensive quality management. Here's the recommended order:

#### For New Components

1. **Create** - Write new agent/skill
2. **Review** - `/ai-review-plugin-component <component>` → Identify issues with severity ratings
3. **Fix Critical/High Issues** - Address CRITICAL and HIGH severity issues manually
4. **Refactor** - `/refactor-plugin-component <component>` → Structural improvements (split agents, progressive loading, extract patterns)
5. **Re-review** - `/ai-review-plugin-component <component>` → Verify quality grade is A or B
6. **Commit** - Only commit if Grade A or B achieved

**Example**:
```bash
# 1. Create new agent
# (Edit agents/new-agent.md)

# 2. Review for issues
/ai-review-plugin-component agents/new-agent.md
# Output: Grade C - 2 CRITICAL, 3 HIGH, 5 MEDIUM issues

# 3. Fix critical/high issues manually
# (Fix YAML errors, add missing fields, etc.)

# 4. Refactor for structure
/refactor-plugin-component agents/new-agent.md
# Output: Proposed improvements (split agent, extract patterns, etc.)

# 5. Re-review
/ai-review-plugin-component agents/new-agent.md
# Output: Grade A - 0 CRITICAL, 0 HIGH, 1 MEDIUM issue

# 6. Commit
git add agents/new-agent.md
git commit -m "Add new agent with Grade A quality"
```

#### For Existing Components

**Quality Check** (regular audits):
```bash
/ai-review-plugin-component agents/existing-agent.md
# If Grade A/B: All good!
# If Grade C/D/F: Fix issues or refactor
```

**Large Structural Changes**:
```bash
/refactor-plugin-component agents/existing-agent.md
# Then re-review to verify quality maintained
/ai-review-plugin-component agents/existing-agent.md
```

#### When to Use Each Command

| Scenario | Command | Purpose |
|----------|---------|---------|
| **Before commit** | `/ai-review-plugin-component` | Validation - catch issues before merge |
| **PR automation** | `/ai-review-plugin-component` | CI/CD quality gates |
| **Regular audit** | `/ai-review-plugin-component` | Health check - identify technical debt |
| **Split agent** | `/refactor-plugin-component` | Transformation - restructure components |
| **Add progressive loading** | `/refactor-plugin-component` | Optimization - reduce token usage |
| **Extract patterns** | `/refactor-plugin-component` | Organization - eliminate duplication |
| **Update framework patterns** | `/refactor-plugin-component` | Maintenance - keep examples current |

**Key Principle**: **Review first** (find issues) → **Refactor second** (fix structure) → **Review again** (verify quality)

### Typical Session

```bash
# 1. Analyze and refactor an agent
/refactor-plugin-component agents/registry-and-content-expert.md

# Claude will:
# - Analyze YAML frontmatter
# - Check tools list vs actual usage
# - Review code examples (real vs pseudocode)
# - Identify overlaps with other agents
# - Propose improvements

# 2. Refactor a large skill (800+ lines)
/refactor-plugin-component skills/forge-event-system/SKILL.md

# Claude will:
# - Split into main SKILL.md (~200 lines) + supporting files
# - Create progressive loading structure
# - Optimize keywords in description
# - Extract duplicate examples

# 3. Fix inconsistencies across docs
/refactor-plugin-component CLAUDE.md

# Claude will:
# - Check cross-references
# - Verify agent selection table
# - Update conventions if changed
# - Ensure consistency with actual components
```

## Best Practices

### 1. Run After Major Changes

Refactor components after:
- Adding new agents or skills
- Updating framework versions
- Learning new patterns from projects
- Receiving user feedback

### 2. Validate Cross-References

Always check that related components are updated:
- Orchestrator's delegation guide
- CLAUDE.md agent selection table
- docs/AGENTS.md and docs/SKILLS.md
- Cross-references in other agents/skills

### 3. Test After Refactoring

```bash
# Restart Claude Code to reload plugin
# Then test:

# For agents:
"Use <agent-name> to <task>"

# For skills:
# Ask a question that should trigger auto-loading
# Check Claude's response for skill reference
```

### 4. Keep Backups

Before major refactoring:
```bash
# Create a backup branch
git checkout -b backup-before-refactor
git commit -am "Backup before refactoring <component>"
git checkout master

# Now safe to refactor
/refactor-plugin-component <component>
```

## Refactoring Patterns

### Pattern 1: Split Monolithic Agent

**Before**: One agent handles items, blocks, entities, events, rendering (5+ domains)

**Command**: `/refactor-plugin-component agents/minecraft-expert.md`

**Result**: Multiple specialized agents with clear boundaries

### Pattern 2: Extract Duplicate Patterns to Skill

**Before**: Same DeferredRegister example in 4 different agents

**Command**: `/refactor-plugin-component agents/registry-expert.md` (Claude detects duplicates)

**Result**: New skill `forge-registry-api` referenced by all agents

### Pattern 3: Convert Skill to Progressive Loading

**Before**: 800-line SKILL.md file

**Command**: `/refactor-plugin-component skills/forge-events/SKILL.md`

**Result**:
```
skills/forge-events/
├── SKILL.md (200 lines)
├── priorities.md (supporting)
├── tick-handlers.md (supporting)
└── event-catalog.md (supporting)
```

### Pattern 4: Update Outdated Code Examples

**Before**: Examples use Forge 1.18 deprecated APIs

**Command**: `/refactor-plugin-component agents/registry-expert.md`

**Result**: Updated to Forge 1.20.1+ DeferredRegister pattern

### Pattern 5: Optimize Skill Keywords

**Before**: Skill description too vague, Claude doesn't auto-load it

**Command**: `/refactor-plugin-component skills/forge-events/SKILL.md`

**Result**: Description includes specific keywords (event bus, @SubscribeEvent, PlayerEvent, etc.)

## Quality Metrics

Track these metrics before/after refactoring:

### Agent Quality
- YAML frontmatter valid ✓
- Description clarity score (1-10)
- Tools list matches usage ✓
- Code examples: real vs pseudocode (%)
- Domain overlap with other agents (%)
- Token count (lines)

### Skill Quality
- SKILL.md length (target: ~200 lines)
- Progressive loading implemented ✓
- Supporting files created (count)
- Keyword relevance score (1-10)
- Code example accuracy ✓
- Version compatibility documented ✓

### Documentation Quality
- Cross-reference validity (% valid)
- Terminology consistency ✓
- Duplicate content (% duplicate)
- Completeness score (1-10)

## Integration with Plugin Workflow

### 1. During Plugin Development

```bash
# After creating a new agent
/refactor-plugin-component agents/new-agent.md

# Ensures:
# - YAML frontmatter correct
# - No overlap with existing agents
# - Skills list appropriate
# - Examples follow best practices
```

### 2. During Plugin Maintenance

```bash
# Regular health check
/refactor-plugin-component agents/qingyi-orchestrator.md
/refactor-plugin-component skills/forge-registry-api/SKILL.md
/refactor-plugin-component CLAUDE.md

# Identifies:
# - Outdated patterns
# - Broken references
# - Inconsistencies
```

### 3. After Learning from Projects

```bash
# User completed new Minecraft mod project
# Orchestrator learned new patterns

# Extract to plugin:
/refactor-plugin-component agents/qingyi-orchestrator.md
# Add learned patterns to appropriate skills or create new ones
```

## Tips

### Tip 1: Start with Critical Issues

Focus on:
1. Invalid YAML syntax (breaks plugin loading)
2. Broken file references (404 errors)
3. Incorrect code examples (misleading)

Then address:
4. Domain overlap (confusion)
5. Token waste (large files)
6. Missing keywords (auto-loading fails)

### Tip 2: Refactor in Batches

Don't refactor all components at once. Group by:
- **Registry-related**: registry agents + registry skills
- **Event-related**: event agents + event skills
- **Documentation**: CLAUDE.md + docs/*.md

### Tip 3: Test Incrementally

After each refactoring:
1. Restart Claude Code
2. Test the refactored component
3. Verify related components still work
4. Commit changes before next refactoring

### Tip 4: Use Version Control

```bash
# Commit after each successful refactoring
git add <refactored-files>
git commit -m "Refactor: <component> - <brief description>"

# Easy to rollback if issues
git revert HEAD
```

## Troubleshooting

### Issue: YAML Frontmatter Invalid

**Symptom**: Claude Code doesn't load agent

**Fix**:
```bash
/refactor-plugin-component agents/<agent>.md
# Claude will validate and fix YAML syntax
```

**Common YAML errors**:
- Missing required fields
- Invalid indentation
- Unquoted special characters in strings
- Incorrect list format

### Issue: Skill Not Auto-Loading

**Symptom**: Skill isn't loaded when it should be

**Fix**:
```bash
/refactor-plugin-component skills/<skill>/SKILL.md
# Claude will optimize description keywords
```

**Debugging**:
1. Check skill description has specific keywords
2. Verify keywords match content
3. Test with direct questions using those keywords

### Issue: Agent Domain Overlap

**Symptom**: Unclear which agent to use for a task

**Fix**:
```bash
# Refactor both agents to clarify boundaries
/refactor-plugin-component agents/agent-a.md
/refactor-plugin-component agents/agent-b.md

# Update orchestrator's delegation guide
/refactor-plugin-component agents/qingyi-orchestrator.md
```

### Issue: Duplicate Content Across Components

**Symptom**: Same example in multiple agents/skills

**Fix**:
```bash
# Claude will detect duplicates and propose extracting to skill
/refactor-plugin-component agents/<agent-with-duplicate>.md
```

## Advanced Usage

### Batch Refactoring

To refactor multiple related components:

```bash
# Option 1: Sequential (safer)
/refactor-plugin-component agents/registry-and-content-expert.md
# Review and approve
/refactor-plugin-component skills/forge-registry-api/SKILL.md
# Review and approve
/refactor-plugin-component agents/qingyi-orchestrator.md
# Review and approve

# Option 2: Request batch analysis
"I need to refactor all registry-related components. Can you analyze:
- agents/registry-and-content-expert.md
- skills/forge-registry-api/SKILL.md
- skills/neoforge-registry-api/SKILL.md
and create a unified refactoring plan?"
```

### Creating New Patterns

After refactoring reveals a new reusable pattern:

```bash
# 1. Refactor identifies pattern
/refactor-plugin-component agents/data-and-persistence-expert.md

# Claude says: "Found reusable NBT serialization pattern across 3 agents"

# 2. Extract to new skill
"Create a new skill for NBT serialization patterns based on the duplicates you found"

# 3. Refactor agents to use new skill
/refactor-plugin-component agents/data-and-persistence-expert.md
# Repeat for other agents
```

### Performance Optimization

Track token usage before/after:

```bash
# Before refactoring
"What's the token count for agents/qingyi-orchestrator.md?"

# Refactor
/refactor-plugin-component agents/qingyi-orchestrator.md

# After refactoring
"What's the new token count? Calculate reduction percentage."

# Goal: Reduce tokens while maintaining clarity
```

## See Also

- [CLAUDE.md](../../CLAUDE.md) - Plugin development conventions
- [docs/AGENTS.md](../../docs/AGENTS.md) - Agent creation guide
- [docs/SKILLS.md](../../docs/SKILLS.md) - Skill development best practices
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md) - Plugin architecture overview

## Contributing

To add new commands:

1. Create `<command-name>.md` in this directory
2. Follow the structure of `/refactor-plugin-component`
3. Document the command in this README.md
4. Test with sample components
5. Update CHANGELOG.md

**Command naming conventions**:
- Use kebab-case: `refactor-plugin-component.md`
- Prefix with domain if specific: `plugin-`, `mc-`, etc.
- Keep names concise but descriptive

**Command structure**:
```markdown
# Command Title

You are a [role] specializing in [domain].

## Context
[What this command is for]

## Instructions
[Step-by-step process]

## Examples
[Concrete usage examples]

## Output Format
[What the command returns]
```
