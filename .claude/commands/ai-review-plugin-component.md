# AI-Powered Plugin Component Review

You are an expert AI-powered code review specialist adapted for Claude Code plugin components. Instead of traditional code, you review markdown-based agents, skills, and documentation for quality, consistency, and effectiveness.

## Context

The Qingyi plugin is a **markdown-based configuration project** for Claude Code, not traditional software. Reviews focus on:
- **YAML frontmatter** validity and completeness
- **Agent effectiveness** (clear instructions, domain boundaries)
- **Skill quality** (progressive loading, keyword optimization)
- **Documentation accuracy** (cross-references, consistency)
- **Real code examples** (from actual projects vs pseudocode)
- **Token efficiency** (progressive loading, no duplication)

## Requirements

Review: **{{COMPONENT_PATH}}**

Perform comprehensive analysis covering structure, content quality, effectiveness, token efficiency, and integration with the plugin ecosystem.

## Review Categories

### 1. YAML Frontmatter Analysis

**YAML Standards**: See [PLUGIN_STANDARDS.md - YAML Frontmatter](../../PLUGIN_STANDARDS.md#3-yaml-frontmatter-standards) for complete validation rules.

**For Agents (`agents/*.md`)**:

```yaml
---
name: kebab-case                           # ✓ Check: Valid kebab-case
description: Expert in X. Use PROACTIVELY  # ✓ Check: Clear + auto-invoke keyword
tools: Read, Write, Edit, Bash             # ✓ Check: Comma-space format, appropriate tools
model: sonnet                              # ✓ Check: Valid model (sonnet/opus/haiku/inherit)
permissionMode: default                    # ✓ Check: Valid mode
skills: skill1, skill2                     # ✓ Check: Referenced skills exist
---
```

**Checklist**:
- [ ] YAML syntax valid (parseable)
- [ ] All required fields present (name, description, tools, model, permissionMode)
- [ ] Name uses kebab-case (no underscores, CamelCase)
- [ ] Description clear and specific
- [ ] "Use PROACTIVELY" included if auto-invocation desired
- [ ] Tools list formatted with comma-space separation
- [ ] Tools match actual usage in agent instructions
- [ ] Model is valid choice (sonnet, opus, haiku, inherit)
- [ ] Model version is current (if using full API model names)
- [ ] permissionMode appropriate for agent's operations
- [ ] Skills list contains only existing, relevant skills
- [ ] No special characters unescaped in strings

**Model Version Check**:

See [PLUGIN_STANDARDS.md - Claude Model Version Mappings](../../PLUGIN_STANDARDS.md#1-claude-model-version-mappings) for current model specifications.

**Quick Reference**:
- Valid: `sonnet`, `opus`, `haiku`, `inherit`
- Deprecated: `claude-3-sonnet-*`, `claude-3-opus-*`, `claude-2.*`
- Invalid: `gpt-*`, `gemini-*` (not Claude models)

**Issue Severity**:
- Using deprecated model: **MEDIUM** (still works but outdated)
- Using invalid model name: **HIGH** (may not work)
- Using non-Claude model: **CRITICAL** (incompatible)

**Example Check**:
```python
def check_model_version(frontmatter: dict) -> List[Issue]:
    model = frontmatter.get('model', '')
    valid_models = {'sonnet', 'opus', 'haiku', 'inherit'}
    deprecated_patterns = {
        'claude-3-sonnet': 'Use "sonnet" instead (maps to Claude 3.5 Sonnet)',
        'claude-3-opus': 'Use "opus" instead (maps to Claude Opus 4.5)',
        'claude-2': 'Strongly recommend upgrading to "sonnet" or "opus"',
    }

    if model not in valid_models:
        # Check if it's a deprecated pattern
        for pattern, suggestion in deprecated_patterns.items():
            if pattern in model:
                return [Issue(
                    severity='MEDIUM',
                    title=f'Outdated model: {model}',
                    description=suggestion,
                    suggested_fix=f'model: sonnet  # or opus/haiku'
                )]

        # Check if it's a non-Claude model
        if model.startswith('gpt-') or model.startswith('gemini-'):
            return [Issue(
                severity='CRITICAL',
                title='Invalid model for Claude Code plugin',
                description=f'Model "{model}" is not a Claude model',
                suggested_fix='model: sonnet  # Use Claude model'
            )]

    return []
```

**For Skills (`skills/*/SKILL.md`)**:

```yaml
---
name: kebab-case                           # ✓ Check: Valid kebab-case
description: Specific keywords for matching # ✓ Check: Contains searchable keywords
allowed-tools: Read, Grep, Glob            # ✓ Check: Optional, if restrictive
---
```

**Checklist**:
- [ ] YAML syntax valid
- [ ] Name uses kebab-case
- [ ] Description contains specific keywords that match content
- [ ] Keywords include API names, framework terms, concepts
- [ ] allowed-tools specified only if restricting (optional field)

### 2. Content Structure Analysis

**For Agents**:

```markdown
# Agent Name - Descriptive Title

## Core Responsibilities
[What this agent does - bulleted list]

## Behavioral Guidelines
[How it should behave - decision frameworks]

## Examples
[Real code from actual projects with citations]

## [Optional Sections]
- Delegation Strategy
- Error Handling
- Common Pitfalls
```

**Checklist**:
- [ ] H1 title present with format: "# Agent Name - Title"
- [ ] Core Responsibilities section with clear list
- [ ] Behavioral Guidelines with decision-making framework
- [ ] Examples section with real code (not pseudocode)
- [ ] Code examples cite source (project, file, line number)
- [ ] Sections logically organized
- [ ] No walls of text (use headings, lists, code blocks)
- [ ] Actionable instructions (not vague suggestions)
- [ ] Framework-specific guidance clearly marked

**For Skills**:

```markdown
# Skill Name

## Overview
[Concise introduction - what and when]

## Core Patterns
[Most common use cases with examples]

## Advanced Topics
- [Link to supporting file](./advanced.md)
- [Link to another file](./antipatterns.md)

## References
[Links to official documentation]
```

**Checklist**:
- [ ] H1 title present
- [ ] Overview section concise (~50-100 lines)
- [ ] Core Patterns with common use cases
- [ ] Progressive loading: Links to supporting files for details
- [ ] Main SKILL.md ≤ 300 lines (ideally ~200)
- [ ] Supporting files created for advanced topics
- [ ] Relative links to supporting files (./ paths)
- [ ] References to official documentation
- [ ] No duplicate content from other skills

### 3. Code Example Quality Analysis

**Code Example Standards**: See [PLUGIN_STANDARDS.md - Code Example Quality](../../PLUGIN_STANDARDS.md#4-code-example-quality-standards)

**Real vs Pseudocode Detection**:

```markdown
❌ PSEUDOCODE (Low Quality):
```java
// Generic example
public void doSomething() {
    // Implementation here
}
```

✅ REAL CODE (High Quality):
```java
// Real example from MusicMod (Forge 1.20.1)
// Source: qingyi.thefatrat.client.screens.MusicTrackerScreen:245

@SubscribeEvent
public static void onClientTick(TickEvent.ClientTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        Minecraft mc = Minecraft.getInstance();
        if (mc.player != null && MusicService.getInstance().isPlaying()) {
            float currentTime = MusicService.getInstance().getCurrentTime();
            updateProgressBar(currentTime);
        }
    }
}
```
```

**Checklist**:
- [ ] Code examples are from real user projects (MusicMod, Apocalypse_TNT, etc.)
- [ ] Source citation present (project name, file path, line number)
- [ ] Complete context shown (imports, class structure, not just snippets)
- [ ] Framework and version specified (Forge 1.20.1, NeoForge 1.21.3, etc.)
- [ ] Code is working/tested (not hypothetical)
- [ ] Explanatory comments present
- [ ] No placeholders or TODOs in examples
- [ ] Examples demonstrate the point clearly
- [ ] Multiple framework variants shown if applicable (Forge vs Fabric)

### 4. Domain Boundary Analysis

**Agent Overlap Detection**:

```python
def detect_agent_overlap(agent_path: str, all_agents: List[str]) -> List[OverlapIssue]:
    """
    Analyze if agent's domain overlaps with other agents.

    Checks:
    1. Description keyword similarity
    2. Shared skills (if >70% overlap, domains too similar)
    3. Responsibilities collision
    4. Example topics (same topics in different agents)
    """

    current_agent = parse_agent(agent_path)
    overlaps = []

    for other_agent in all_agents:
        if other_agent == agent_path:
            continue

        similarity = calculate_domain_similarity(current_agent, parse_agent(other_agent))

        if similarity > 0.7:  # >70% overlap
            overlaps.append({
                'severity': 'HIGH',
                'with_agent': other_agent,
                'similarity': similarity,
                'message': f'Domain overlap with {other_agent}: {similarity:.0%} similar',
                'recommendation': 'Consider merging agents or clarifying boundaries'
            })

    return overlaps
```

**Checklist**:
- [ ] Agent domain clearly defined
- [ ] No significant overlap (>50%) with other agents
- [ ] Edge cases documented (what goes to this agent vs others)
- [ ] Delegation guide in orchestrator references this agent correctly
- [ ] Skills loaded are unique to this domain (not same as all other agents)
- [ ] Responsibilities don't duplicate other agents

### 5. Token Efficiency Analysis

**Token Efficiency Standards**: See [PLUGIN_STANDARDS.md - Token Efficiency](../../PLUGIN_STANDARDS.md#2-token-efficiency-standards) for detailed thresholds.

**Progressive Loading Assessment**:

```typescript
interface TokenEfficiencyMetrics {
  skillMainFileLines: number;           // Target: ≤200 (see standards)
  supportingFilesCount: number;         // Should exist if main > 300
  supportingFilesLinked: boolean;       // Links present in main file?
  duplicateContentTokens: number;       // Target: 0
  totalTokensIfFullyLoaded: number;     // All files combined
  typicalLoadTokens: number;            // Main file only
  tokenSavings: number;                 // Percentage saved via progressive loading
}

function assessTokenEfficiency(skillPath: string): TokenEfficiencyMetrics {
  const mainFile = readSkillFile(skillPath + '/SKILL.md');
  const supportingFiles = findSupportingFiles(skillPath);

  const metrics = {
    skillMainFileLines: countLines(mainFile),
    supportingFilesCount: supportingFiles.length,
    supportingFilesLinked: checkLinksExist(mainFile, supportingFiles),
    duplicateContentTokens: findDuplicates(mainFile, supportingFiles),
    totalTokensIfFullyLoaded: estimateTokens([mainFile, ...supportingFiles]),
    typicalLoadTokens: estimateTokens([mainFile]),
    tokenSavings: 0
  };

  metrics.tokenSavings =
    ((metrics.totalTokensIfFullyLoaded - metrics.typicalLoadTokens) /
     metrics.totalTokensIfFullyLoaded) * 100;

  return metrics;
}
```

**Checklist** (thresholds from PLUGIN_STANDARDS.md):
- [ ] Main SKILL.md ideal ≤200 lines, acceptable ≤300, warning at 300-400, critical >400
- [ ] Supporting files created if main file >300 lines
- [ ] Supporting files linked from main file
- [ ] No duplicate content across agent/skill files
- [ ] Agent instructions concise (avoid verbosity)
- [ ] References used instead of embedding full content
- [ ] Token savings 50-75% if progressive loading implemented

### 6. Keyword Optimization Analysis

**Keyword Optimization Standards**: See [PLUGIN_STANDARDS.md - Keyword Optimization](../../PLUGIN_STANDARDS.md#6-keyword-optimization-standards-for-skills)

**Skill Auto-Loading Effectiveness**:

```python
def analyze_keyword_optimization(skill: Skill) -> KeywordAnalysis:
    """
    Check if skill description contains keywords that match content.
    Predict auto-loading success rate.
    """

    description_keywords = extract_keywords(skill.description)
    content_topics = analyze_content_topics(skill.content)

    # Extract API names, class names, framework terms
    api_terms = extract_api_references(skill.content)

    keyword_match_rate = calculate_overlap(description_keywords, content_topics)
    api_coverage = len(set(description_keywords) & set(api_terms)) / len(api_terms)

    return {
        'match_rate': keyword_match_rate,  # Target: >80%
        'api_coverage': api_coverage,      # Target: >70%
        'missing_keywords': set(api_terms) - set(description_keywords),
        'irrelevant_keywords': set(description_keywords) - set(content_topics),
        'auto_load_success_predicted': keyword_match_rate > 0.8 and api_coverage > 0.7
    }
```

**Checklist**:
- [ ] Description contains specific API names (`@SubscribeEvent`, `DeferredRegister`, etc.)
- [ ] Description includes framework terms (`event bus`, `tick handler`, etc.)
- [ ] Description includes concepts (`registration`, `serialization`, etc.)
- [ ] Keywords in description match actual skill content (>80% overlap)
- [ ] No vague terms ("helps with", "useful for") - be specific
- [ ] Test queries using keywords should trigger skill auto-loading

### 7. Cross-Reference Validation

**Link Integrity Check**:

```bash
# Validate all markdown links in component
find_broken_links() {
  component_file=$1

  # Extract all markdown links
  grep -oP '\[.*?\]\(\K[^)]+' "$component_file" | while read link; do
    # Resolve relative paths
    if [[ $link == ./* ]]; then
      target=$(realpath --relative-to=. "$(dirname "$component_file")/$link")
    else
      target=$link
    fi

    # Check if target exists
    if [[ ! -e $target ]] && [[ ! $link =~ ^https?:// ]]; then
      echo "❌ BROKEN LINK: $link in $component_file"
      echo "   Target: $target (not found)"
    fi
  done
}
```

**Checklist**:
- [ ] All markdown links resolve (no 404s)
- [ ] File paths use correct relative paths (./ or ../)
- [ ] Agent references to skills are correct (skills exist)
- [ ] Orchestrator delegation guide references valid agents
- [ ] CLAUDE.md agent selection table matches actual agents
- [ ] Code citations reference real files (if verifiable)
- [ ] External links to documentation are current (not dead)

### 8. Framework Compatibility Analysis

**Framework Compatibility Standards**: See [PLUGIN_STANDARDS.md - Framework Compatibility](../../PLUGIN_STANDARDS.md#5-framework-compatibility-standards)

**Multi-Framework Support Check**:

```java
// Should be marked clearly
// ✅ Good: Framework-specific sections

**Forge 1.20.1+**:
```java
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MODID);
```

**Fabric 1.20.x**:
```java
public static final Item CUSTOM_ITEM = Registry.register(
    Registries.ITEM, new Identifier(MODID, "custom_item"), item);
```

// ❌ Bad: Unmarked code (which framework?)
```java
public static void registerItem(Item item) {
    Registry.register(item);  // Forge? Fabric? Unclear!
}
```
```

**Checklist**:
- [ ] Framework specified for all code examples
- [ ] Version compatibility noted (1.19.x, 1.20.x, 1.21.x)
- [ ] Multi-framework variants shown if applicable
- [ ] Framework detection logic in orchestrator accurate
- [ ] No mixing of framework APIs in single example
- [ ] Deprecated APIs flagged with migration notes

### 9. Consistency Analysis

**Consistency Standards**: See [PLUGIN_STANDARDS.md - Terminology Dictionary](../../PLUGIN_STANDARDS.md#8-consistency-standards-terminology-dictionary)

**Terminology Standardization**:

```typescript
interface TerminologyViolation {
  term: string;
  usedIn: string[];
  preferredTerm: string;
  severity: 'LOW' | 'MEDIUM' | 'HIGH';
}

// Reference full terminology standards in PLUGIN_STANDARDS.md
const TERMINOLOGY_STANDARDS = {
  // Correct → Incorrect variants
  'DeferredRegister': ['RegistryObject holder', 'Registry manager'],
  'event bus': ['event system', 'event manager'],
  'progressive loading': ['lazy loading', 'on-demand loading'],
  'frontmatter': ['metadata', 'header', 'yaml header'],
  'kebab-case': ['dash-case', 'hyphen-case'],
};

function checkTerminologyConsistency(files: string[]): TerminologyViolation[] {
  const violations = [];

  for (const [correct, incorrect] of Object.entries(TERMINOLOGY_STANDARDS)) {
    for (const file of files) {
      const content = readFile(file);
      for (const wrongTerm of incorrect) {
        if (content.includes(wrongTerm)) {
          violations.push({
            term: wrongTerm,
            usedIn: [file],
            preferredTerm: correct,
            severity: 'MEDIUM'
          });
        }
      }
    }
  }

  return violations;
}
```

**Checklist**:
- [ ] Terminology consistent with CLAUDE.md conventions
- [ ] Agent/skill naming follows kebab-case
- [ ] Code example format consistent across components
- [ ] Heading levels used correctly (H1 for title, H2 for sections, etc.)
- [ ] Markdown formatting consistent (lists, code blocks, emphasis)
- [ ] No mix of "User" vs "user", "Minecraft" vs "minecraft", etc.

## Review Process

### Step 1: Parse Component

```python
import yaml
import re
from pathlib import Path

def parse_component(component_path: str) -> Component:
    """
    Extract YAML frontmatter and markdown content.
    """
    content = Path(component_path).read_text(encoding='utf-8')

    # Extract YAML frontmatter
    match = re.match(r'^---\n(.*?)\n---\n(.*)$', content, re.DOTALL)
    if not match:
        return Component(
            path=component_path,
            frontmatter=None,
            content=content,
            errors=[{'severity': 'CRITICAL', 'message': 'Missing YAML frontmatter'}]
        )

    frontmatter_str, markdown_content = match.groups()

    try:
        frontmatter = yaml.safe_load(frontmatter_str)
    except yaml.YAMLError as e:
        return Component(
            path=component_path,
            frontmatter=None,
            content=markdown_content,
            errors=[{'severity': 'CRITICAL', 'message': f'Invalid YAML: {e}'}]
        )

    return Component(
        path=component_path,
        frontmatter=frontmatter,
        content=markdown_content,
        errors=[]
    )
```

### Step 2: Run Analysis Layers

```python
class PluginComponentReviewer:
    def __init__(self, component_path: str):
        self.component = parse_component(component_path)
        self.component_type = self.detect_type()  # agent, skill, or doc
        self.issues: List[ReviewIssue] = []

    def review(self) -> ReviewReport:
        """Run all analysis layers."""

        # Layer 1: YAML Frontmatter
        self.issues.extend(self.analyze_frontmatter())

        # Layer 2: Content Structure
        self.issues.extend(self.analyze_structure())

        # Layer 3: Code Examples
        self.issues.extend(self.analyze_code_examples())

        # Layer 4: Domain Boundaries (agents only)
        if self.component_type == 'agent':
            self.issues.extend(self.analyze_domain_boundaries())

        # Layer 5: Token Efficiency (skills only)
        if self.component_type == 'skill':
            self.issues.extend(self.analyze_token_efficiency())

        # Layer 6: Keywords (skills only)
        if self.component_type == 'skill':
            self.issues.extend(self.analyze_keywords())

        # Layer 7: Cross-References
        self.issues.extend(self.validate_cross_references())

        # Layer 8: Framework Compatibility
        self.issues.extend(self.analyze_framework_compat())

        # Layer 9: Consistency
        self.issues.extend(self.check_consistency())

        return self.generate_report()
```

### Step 3: AI-Enhanced Analysis

```python
def ai_enhanced_review(component: Component) -> List[AIInsight]:
    """
    Use Claude 4.5 Sonnet for context-aware analysis.
    """

    prompt = f"""You are reviewing a Claude Code plugin component.

**Component Type**: {component.type}
**Path**: {component.path}

**YAML Frontmatter**:
```yaml
{yaml.dump(component.frontmatter)}
```

**Content** (first 2000 chars):
{component.content[:2000]}

Analyze for:
1. **Effectiveness**: Will this component achieve its purpose?
2. **Clarity**: Are instructions clear and actionable?
3. **Completeness**: What's missing?
4. **Best Practices**: Any anti-patterns or improvements?

For each issue, provide:
- Severity (CRITICAL/HIGH/MEDIUM/LOW)
- Category (Structure/Content/Quality/Efficiency)
- Specific line/section reference
- Concrete improvement suggestion
- Code example if applicable

Return JSON array of issues.
"""

    response = anthropic_client.messages.create(
        model="claude-3-5-sonnet-20241022",
        max_tokens=4000,
        temperature=0.2,
        messages=[{"role": "user", "content": prompt}]
    )

    return parse_ai_insights(response.content[0].text)
```

### Step 4: Generate Review Report

```markdown
## 🤖 Plugin Component Review

**Component**: `{component_path}`
**Type**: Agent | Skill | Documentation
**Reviewed**: {timestamp}

---

### Summary

- **CRITICAL**: {count_critical} 🔴
- **HIGH**: {count_high} 🟠
- **MEDIUM**: {count_medium} 🟡
- **LOW**: {count_low} ⚪
- **INFO**: {count_info} 🔵

**Overall Grade**: A+ | A | B | C | D | F

---

### Issues by Category

#### 1. YAML Frontmatter (2 issues)

**[CRITICAL]** Invalid YAML syntax (line 3)
```yaml
# ❌ Current
tools: Read Write Edit    # Missing commas

# ✅ Should be
tools: Read, Write, Edit
```

**[HIGH]** Missing required field: `permissionMode`
- Add `permissionMode: default` to frontmatter
- Choose from: default, acceptEdits, bypassPermissions, plan

---

#### 2. Content Structure (1 issue)

**[MEDIUM]** Missing "Core Responsibilities" section
- Agents should have clear responsibilities list
- Example:
```markdown
## Core Responsibilities

- Register items, blocks, entities
- Handle DeferredRegister setup
- Configure creative tabs
```

---

#### 3. Code Examples (3 issues)

**[HIGH]** Pseudocode instead of real code (line 45)
```java
// ❌ Current (pseudocode)
public void doSomething() {
    // Implementation
}

// ✅ Should be (real code from MusicMod)
// Source: qingyi.thefatrat.registry.ItemRegistry:15
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MOD_ID);
```

**[MEDIUM]** Missing source citation (line 67)
- Code examples should cite source project
- Format: `// Example from {Project} ({Framework} {Version})`
- Add: `// Source: {file_path}:{line_number}`

**[LOW]** Missing explanatory comments
- Add comments explaining why this pattern works
- Clarify non-obvious implementation details

---

#### 4. Token Efficiency (1 issue)

**[HIGH]** SKILL.md too large: 650 lines (target: ≤300)
- Implement progressive loading
- Create supporting files:
  - `advanced-patterns.md` (lines 300-450)
  - `event-catalog.md` (lines 450-650)
- Link from main SKILL.md
- **Estimated savings**: ~450 tokens (69%)

---

#### 5. Cross-References (2 issues)

**[CRITICAL]** Broken link: `./supporting-file.md` (line 120)
- File does not exist
- Create file or fix link path

**[MEDIUM]** Referenced skill doesn't exist: `non-existent-skill`
- Remove from skills list or create the skill
- Verify skill name is correct (kebab-case)

---

### Recommendations

#### Immediate Actions (Critical/High)
1. Fix YAML syntax errors
2. Replace pseudocode with real examples from MusicMod/Apocalypse_TNT
3. Implement progressive loading for large skill file
4. Fix broken links

#### Medium Priority
5. Add missing structural sections
6. Add source citations to all code examples
7. Optimize skill description keywords

#### Nice-to-Have (Low)
8. Add more explanatory comments
9. Expand examples with edge cases
10. Cross-reference related agents/skills

---

### AI-Enhanced Insights

**Claude 4.5 Sonnet Analysis**:

> "The agent's domain overlaps significantly with `registry-and-content-expert` (85% similarity). Consider merging or clearly differentiating. The current split creates user confusion about which agent to invoke."

> "Skill description lacks specific keywords. Auto-loading will fail for queries about 'event priorities' or 'tick handlers' despite content covering these topics. Add: `@SubscribeEvent, event priorities, ClientTickEvent, ServerTickEvent`."

---

### Metrics

**Before Review**:
- Lines: 650
- Tokens: ~9,750
- YAML valid: ❌
- Code examples: 40% pseudocode
- Domain overlap: 85% with another agent

**After Fixes**:
- Lines: 250 (main) + 2×200 (supporting)
- Tokens: ~3,000 (main only, ~69% reduction)
- YAML valid: ✅
- Code examples: 100% real code
- Domain overlap: <30% (merged/clarified)

---

### Quality Checklist

Agent Quality:
- [❌] YAML frontmatter valid
- [❌] Description clarity (missing keywords)
- [⚠️] Tools list matches usage
- [❌] Code examples real (60% pseudocode)
- [❌] Domain boundaries clear (85% overlap)
- [⚠️] Token efficiency (650 lines)

Skill Quality:
- [✅] SKILL.md concise
- [❌] Progressive loading (missing)
- [❌] Keywords optimized
- [⚠️] Framework compatibility marked
- [✅] Supporting files created
- [❌] Cross-references valid

Overall: **C Grade** (needs improvement)
```

## Review Comment Format

```typescript
interface PluginReviewComment {
  file_path: string;
  line_number?: number;  // Optional for document-level comments
  severity: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW' | 'INFO';
  category: 'YAML' | 'Structure' | 'CodeExamples' | 'Efficiency' | 'Keywords' | 'CrossRefs' | 'Consistency';
  title: string;
  description: string;
  current_code?: string;
  suggested_fix?: string;
  auto_fixable: boolean;
  effort: 'trivial' | 'easy' | 'medium' | 'hard';
  references?: string[];
}

// Example
const comment: PluginReviewComment = {
  file_path: "agents/registry-and-content-expert.md",
  line_number: 45,
  severity: "HIGH",
  category: "CodeExamples",
  title: "Pseudocode instead of real code example",
  description: `Code example uses pseudocode rather than real code from user projects. This reduces accuracy and increases hallucination risk.

**Impact**: Users may get incorrect implementation guidance.
**Source Requirement**: Examples should cite actual projects (MusicMod, Apocalypse_TNT).`,
  current_code: `
// Generic example
public void registerItem(Item item) {
    // Register item here
}
  `,
  suggested_fix: `
// Real example from MusicMod (Forge 1.20.1)
// Source: qingyi.thefatrat.registry.ItemRegistry:15

public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, TheFatRatMod.MOD_ID);

public static final RegistryObject<Item> MUSIC_DISC_OVERBOARD = ITEMS.register(
    "music_disc_overboard",
    () -> new RecordItem(15, ModSounds.OVERBOARD,
        new Item.Properties().stacksTo(1).rarity(Rarity.RARE), 3380)
);
  `,
  auto_fixable: false,  // Requires finding real code from projects
  effort: "medium",
  references: [
    "CLAUDE.md - Convention: Real Code Examples",
    "examples/refactor-plugin-component-example.md - Example 5"
  ]
};
```

## Integration with Plugin Workflow

### Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Review modified agents and skills
changed_components=$(git diff --cached --name-only | grep -E 'agents/.*\.md|skills/.*/SKILL\.md')

if [ -n "$changed_components" ]; then
  echo "🤖 Reviewing plugin components..."

  for component in $changed_components; do
    # Run AI review
    python scripts/ai_review_plugin.py --component "$component" --output review-results.json

    # Check for critical issues
    critical_count=$(jq '[.[] | select(.severity == "CRITICAL")] | length' review-results.json)

    if [ $critical_count -gt 0 ]; then
      echo "❌ Found $critical_count CRITICAL issues in $component"
      echo "   Fix before committing or use --no-verify to skip"
      jq '.[] | select(.severity == "CRITICAL")' review-results.json
      exit 1
    fi
  done

  echo "✅ All components passed review"
fi
```

### GitHub Actions

```yaml
# .github/workflows/plugin-component-review.yml
name: Plugin Component Review
on:
  pull_request:
    paths:
      - 'agents/**/*.md'
      - 'skills/**/SKILL.md'
      - 'CLAUDE.md'
      - 'docs/**/*.md'

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Review Modified Components
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          # Get changed files
          changed_files=$(git diff --name-only origin/master...HEAD | \
            grep -E 'agents/.*\.md|skills/.*/SKILL\.md|CLAUDE\.md|docs/.*\.md')

          # Review each component
          for file in $changed_files; do
            python scripts/ai_review_plugin.py \
              --component "$file" \
              --model claude-3-5-sonnet-20241022 \
              --output "review-${file//\//-}.json"
          done

      - name: Post Review Comments
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const reviews = fs.readdirSync('.')
              .filter(f => f.startsWith('review-'))
              .map(f => JSON.parse(fs.readFileSync(f)));

            for (const review of reviews) {
              for (const issue of review.issues) {
                if (issue.severity === 'CRITICAL' || issue.severity === 'HIGH') {
                  await github.rest.issues.createComment({
                    owner: context.repo.owner,
                    repo: context.repo.repo,
                    issue_number: context.issue.number,
                    body: `## ${issue.severity}: ${issue.title}\n\n` +
                          `**File**: \`${issue.file_path}\`\n` +
                          `**Line**: ${issue.line_number || 'N/A'}\n\n` +
                          issue.description
                  });
                }
              }
            }

      - name: Quality Gate
        run: |
          # Aggregate all reviews
          jq -s 'add' review-*.json > aggregate-review.json

          CRITICAL=$(jq '[.[] | select(.severity == "CRITICAL")] | length' aggregate-review.json)
          HIGH=$(jq '[.[] | select(.severity == "HIGH")] | length' aggregate-review.json)

          echo "📊 Review Summary:"
          echo "   CRITICAL: $CRITICAL"
          echo "   HIGH: $HIGH"

          # Fail if critical issues found
          if [ $CRITICAL -gt 0 ]; then
            echo "❌ Cannot merge with CRITICAL issues"
            exit 1
          fi

          # Warn if many high issues
          if [ $HIGH -gt 5 ]; then
            echo "⚠️ Many HIGH severity issues ($HIGH)"
            echo "   Consider addressing before merge"
          fi
```

## Complete Example: AI Review Script

```python
#!/usr/bin/env python3
"""
AI-powered review for Qingyi plugin components.
"""

import os, json, sys, yaml, re
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import List, Optional, Dict, Any
from anthropic import Anthropic

@dataclass
class ReviewIssue:
    file_path: str
    line_number: Optional[int]
    severity: str  # CRITICAL, HIGH, MEDIUM, LOW, INFO
    category: str
    title: str
    description: str
    current_code: str = ""
    suggested_fix: str = ""
    auto_fixable: bool = False
    effort: str = "medium"
    references: List[str] = None

    def __post_init__(self):
        if self.references is None:
            self.references = []

class PluginComponentReviewer:
    def __init__(self, component_path: str, api_key: str):
        self.component_path = Path(component_path)
        self.component_type = self.detect_type()
        self.anthropic = Anthropic(api_key=api_key)
        self.issues: List[ReviewIssue] = []

    def detect_type(self) -> str:
        """Detect if component is agent, skill, or doc."""
        if 'agents/' in str(self.component_path):
            return 'agent'
        elif 'skills/' in str(self.component_path) and self.component_path.name == 'SKILL.md':
            return 'skill'
        else:
            return 'documentation'

    def parse_component(self) -> Dict[str, Any]:
        """Extract YAML frontmatter and content."""
        content = self.component_path.read_text(encoding='utf-8')

        match = re.match(r'^---\n(.*?)\n---\n(.*)$', content, re.DOTALL)
        if not match:
            self.issues.append(ReviewIssue(
                file_path=str(self.component_path),
                line_number=1,
                severity='CRITICAL',
                category='YAML',
                title='Missing YAML frontmatter',
                description='Component must have YAML frontmatter block between --- delimiters.',
                auto_fixable=False,
                effort='trivial'
            ))
            return {'frontmatter': None, 'content': content}

        frontmatter_str, markdown_content = match.groups()

        try:
            frontmatter = yaml.safe_load(frontmatter_str)
        except yaml.YAMLError as e:
            self.issues.append(ReviewIssue(
                file_path=str(self.component_path),
                line_number=2,
                severity='CRITICAL',
                category='YAML',
                title='Invalid YAML syntax',
                description=f'YAML parsing failed: {str(e)}',
                auto_fixable=False,
                effort='easy'
            ))
            frontmatter = None

        return {'frontmatter': frontmatter, 'content': markdown_content}

    def analyze_frontmatter(self, data: Dict) -> List[ReviewIssue]:
        """Validate YAML frontmatter."""
        issues = []
        fm = data.get('frontmatter')

        if not fm:
            return issues  # Already reported as CRITICAL

        # Check required fields
        if self.component_type == 'agent':
            required = ['name', 'description', 'tools', 'model', 'permissionMode']
        else:  # skill
            required = ['name', 'description']

        for field in required:
            if field not in fm:
                issues.append(ReviewIssue(
                    file_path=str(self.component_path),
                    line_number=None,
                    severity='HIGH',
                    category='YAML',
                    title=f'Missing required field: {field}',
                    description=f'YAML frontmatter must include {field}.',
                    suggested_fix=f'{field}: [appropriate value]',
                    auto_fixable=False,
                    effort='trivial'
                ))

        # Check name format (kebab-case)
        if 'name' in fm:
            name = fm['name']
            if '_' in name or name != name.lower() or ' ' in name:
                issues.append(ReviewIssue(
                    file_path=str(self.component_path),
                    line_number=None,
                    severity='MEDIUM',
                    category='YAML',
                    title='Name should use kebab-case',
                    description=f'Name "{name}" should use kebab-case (lowercase with hyphens).',
                    current_code=f'name: {name}',
                    suggested_fix=f'name: {name.lower().replace("_", "-").replace(" ", "-")}',
                    auto_fixable=True,
                    effort='trivial'
                ))

        # Check tools format (comma-space)
        if 'tools' in fm:
            tools_str = fm['tools']
            if ',' in tools_str and ', ' not in tools_str:
                issues.append(ReviewIssue(
                    file_path=str(self.component_path),
                    line_number=None,
                    severity='LOW',
                    category='YAML',
                    title='Tools list formatting',
                    description='Tools should be comma-space separated.',
                    current_code=f'tools: {tools_str}',
                    suggested_fix=f'tools: {tools_str.replace(",", ", ")}',
                    auto_fixable=True,
                    effort='trivial'
                ))

        # Check model version (agents only)
        if self.component_type == 'agent' and 'model' in fm:
            model = fm['model']
            valid_models = {'sonnet', 'opus', 'haiku', 'inherit'}
            deprecated_patterns = {
                'claude-3-sonnet': ('MEDIUM', 'Use "sonnet" instead (maps to Claude 3.5 Sonnet)'),
                'claude-3-opus': ('MEDIUM', 'Use "opus" instead (maps to Claude Opus 4.5)'),
                'claude-2': ('MEDIUM', 'Strongly recommend upgrading to "sonnet" or "opus"'),
            }

            if model not in valid_models:
                # Check if it's a deprecated pattern
                for pattern, (severity, suggestion) in deprecated_patterns.items():
                    if pattern in model:
                        issues.append(ReviewIssue(
                            file_path=str(self.component_path),
                            line_number=None,
                            severity=severity,
                            category='YAML',
                            title=f'Outdated model: {model}',
                            description=f'{suggestion}\n\nCurrent: {model}\nRecommended: sonnet, opus, or haiku',
                            current_code=f'model: {model}',
                            suggested_fix='model: sonnet  # or opus/haiku',
                            auto_fixable=False,
                            effort='trivial'
                        ))
                        break
                else:
                    # Check if it's a non-Claude model
                    if model.startswith('gpt-') or model.startswith('gemini-'):
                        issues.append(ReviewIssue(
                            file_path=str(self.component_path),
                            line_number=None,
                            severity='CRITICAL',
                            category='YAML',
                            title='Invalid model for Claude Code plugin',
                            description=f'Model "{model}" is not a Claude model. This plugin only works with Claude models.',
                            current_code=f'model: {model}',
                            suggested_fix='model: sonnet  # Use Claude model (sonnet/opus/haiku)',
                            auto_fixable=False,
                            effort='trivial'
                        ))
                    elif model not in valid_models:
                        # Unknown model
                        issues.append(ReviewIssue(
                            file_path=str(self.component_path),
                            line_number=None,
                            severity='HIGH',
                            category='YAML',
                            title='Unrecognized model value',
                            description=f'Model "{model}" is not recognized. Use one of: sonnet, opus, haiku, inherit',
                            current_code=f'model: {model}',
                            suggested_fix='model: sonnet  # Choose: sonnet, opus, haiku, or inherit',
                            auto_fixable=False,
                            effort='trivial'
                        ))

        return issues

    def ai_review(self, data: Dict) -> List[ReviewIssue]:
        """Use Claude for context-aware analysis."""
        prompt = f"""Review this Claude Code plugin component.

**Type**: {self.component_type}
**Path**: {self.component_path}

**YAML Frontmatter**:
```yaml
{yaml.dump(data.get('frontmatter', {}), default_flow_style=False)}
```

**Content** (first 3000 chars):
{data['content'][:3000]}

Analyze for:
1. Effectiveness (will it work well?)
2. Clarity (instructions clear?)
3. Quality (real code vs pseudocode?)
4. Token efficiency (progressive loading if >300 lines?)
5. Keywords (skill descriptions optimized?)
6. Consistency (with plugin conventions?)

Return JSON array of issues:
[{{
  "severity": "CRITICAL|HIGH|MEDIUM|LOW",
  "category": "Structure|Content|Quality|Efficiency",
  "title": "Brief issue title",
  "description": "Detailed explanation",
  "suggested_fix": "Concrete improvement",
  "line_number": 42
}}]
"""

        response = self.anthropic.messages.create(
            model="claude-3-5-sonnet-20241022",
            max_tokens=4000,
            temperature=0.2,
            messages=[{"role": "user", "content": prompt}]
        )

        content = response.content[0].text
        if '```json' in content:
            content = content.split('```json')[1].split('```')[0]

        ai_issues = json.loads(content.strip())

        return [
            ReviewIssue(
                file_path=str(self.component_path),
                line_number=issue.get('line_number'),
                severity=issue['severity'],
                category=issue['category'],
                title=issue['title'],
                description=issue['description'],
                suggested_fix=issue.get('suggested_fix', ''),
                auto_fixable=False,
                effort='medium'
            )
            for issue in ai_issues
        ]

    def review(self) -> Dict[str, Any]:
        """Run complete review."""
        data = self.parse_component()

        # Automated checks
        self.issues.extend(self.analyze_frontmatter(data))

        # AI-enhanced analysis
        self.issues.extend(self.ai_review(data))

        # Generate report
        return {
            'component_path': str(self.component_path),
            'component_type': self.component_type,
            'total_issues': len(self.issues),
            'by_severity': {
                'CRITICAL': len([i for i in self.issues if i.severity == 'CRITICAL']),
                'HIGH': len([i for i in self.issues if i.severity == 'HIGH']),
                'MEDIUM': len([i for i in self.issues if i.severity == 'MEDIUM']),
                'LOW': len([i for i in self.issues if i.severity == 'LOW']),
            },
            'issues': [asdict(issue) for issue in self.issues]
        }

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='AI review for plugin components')
    parser.add_argument('--component', required=True, help='Path to component file')
    parser.add_argument('--output', default='review-results.json', help='Output file')
    parser.add_argument('--model', default='claude-3-5-sonnet-20241022', help='AI model')
    args = parser.parse_args()

    api_key = os.environ.get('ANTHROPIC_API_KEY')
    if not api_key:
        print("❌ ANTHROPIC_API_KEY not set")
        sys.exit(1)

    reviewer = PluginComponentReviewer(args.component, api_key)
    report = reviewer.review()

    # Save report
    with open(args.output, 'w') as f:
        json.dump(report, f, indent=2)

    # Print summary
    print(f"\n📊 Review Summary for {args.component}")
    print(f"   CRITICAL: {report['by_severity']['CRITICAL']}")
    print(f"   HIGH: {report['by_severity']['HIGH']}")
    print(f"   MEDIUM: {report['by_severity']['MEDIUM']}")
    print(f"   LOW: {report['by_severity']['LOW']}")

    if report['by_severity']['CRITICAL'] > 0:
        print("\n❌ CRITICAL issues found")
        sys.exit(1)
    else:
        print("\n✅ No critical issues")
```

## Usage

```bash
# Review a single component
/ai-review-plugin-component agents/qingyi-orchestrator.md

# Review with specific model
/ai-review-plugin-component skills/forge-event-system/SKILL.md --model=claude-opus-4-5

# Batch review (via script)
for file in agents/*.md; do
  /ai-review-plugin-component "$file"
done

# Integration with git workflow
git diff --name-only | grep '\.md$' | xargs -I {} /ai-review-plugin-component {}
```

## Summary

Comprehensive AI-powered review for Claude Code plugin components:

1. **YAML Validation**: Syntax, required fields, formatting
2. **Structure Analysis**: Sections, organization, clarity
3. **Code Example Quality**: Real vs pseudocode, citations, completeness
4. **Domain Boundaries**: Agent overlap detection
5. **Token Efficiency**: Progressive loading, duplication
6. **Keyword Optimization**: Auto-loading effectiveness
7. **Cross-References**: Link integrity
8. **Framework Compatibility**: Multi-framework support
9. **Consistency**: Terminology, formatting
10. **AI Enhancement**: Claude 4.5 Sonnet for contextual insights

Use this tool to maintain high quality across all plugin components, ensuring agents are effective, skills are efficient, and documentation is accurate.
