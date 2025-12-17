# Brave Search Optimization Guide

Advanced techniques for maximizing search accuracy and token efficiency when using Brave MCP search tools.

## Token Cost Analysis

### Per-Search Token Costs (Approximate)

| Tool | Input Tokens | Output Tokens (per result) | Recommended Count |
|------|--------------|---------------------------|-------------------|
| `brave_web_search` | 15-30 | 50-80 | 5-15 results |
| `brave_news_search` | 15-30 | 40-60 | 10-20 results |
| `brave_video_search` | 15-25 | 30-50 | 20-30 results |
| `brave_image_search` | 15-25 | 20-30 | 50-100 results |
| `brave_local_search` | 15-30 | 60-100 | 5-10 results |
| `brave_summarizer` | 10-15 | 200-500 | N/A (1 summary) |

### Cost Optimization Strategies

**Strategy 1: Progressive Search Refinement**

Instead of one broad search, use iterative narrow searches:

```javascript
// INEFFICIENT: Broad search with max results
brave_web_search({
  query: "Minecraft modding",
  count: 20  // Too broad, wastes tokens
})

// EFFICIENT: Specific search with fewer results
brave_web_search({
  query: "NeoForge 1.21.3 DeferredRegister tutorial 2025",
  count: 5,  // Specific query = fewer results needed
  freshness: "pm"
})
```

**Strategy 2: Result Filter Targeting**

Only request result types you need:

```javascript
// INEFFICIENT: All result types
brave_web_search({
  query: "NeoForge documentation",
  result_filter: ["web", "discussions", "faq", "news", "videos"]
  // Returns mixed results, harder to parse
})

// EFFICIENT: Target specific types
brave_web_search({
  query: "NeoForge documentation",
  result_filter: ["web"]  // Only documentation pages
})
```

**Strategy 3: Domain Pre-Filtering**

Use `allowed_domains` to eliminate irrelevant results:

```javascript
// INEFFICIENT: Open search, filter manually
brave_web_search({
  query: "NeoForge API reference",
  count: 20
})
// Get spam, outdated sites, need to filter manually

// EFFICIENT: Pre-filter to official sources
brave_web_search({
  query: "NeoForge API reference",
  allowed_domains: ["docs.neoforged.net", "github.com/neoforged"],
  count: 5  // Fewer results needed when pre-filtered
})
```

## Query Construction Patterns

### Pattern 1: Version-Specific Queries

**Problem**: Getting results for wrong Minecraft/framework version

**Solution**: Include version explicitly + year

```javascript
// BAD: Ambiguous version
query: "Minecraft block registration"

// GOOD: Specific version + year
query: "NeoForge 1.21.3 block registration 2025"

// EXCELLENT: Version + framework + specific API
query: "NeoForge 1.21.3 DeferredRegister blocks example 2025"
```

### Pattern 2: Framework Disambiguation

**Problem**: Mixing Forge/NeoForge/Fabric results

**Solution**: Use framework-specific terminology

```javascript
// Forge/NeoForge specific
query: "DeferredRegister ForgeRegistries items 1.20.1"

// Fabric specific
query: "Registry.register Registries.ITEM Fabric 1.20"

// With domain filtering
brave_web_search({
  query: "block registration tutorial",
  allowed_domains: ["fabricmc.net"]  // Forces Fabric results
})
```

### Pattern 3: Finding Recent Updates

**Problem**: Documentation becomes outdated quickly

**Solution**: Combine freshness filters with year in query

```javascript
brave_web_search({
  query: "NeoForge breaking changes 1.21 2025",
  freshness: "pm",  // Last month
  result_filter: ["web", "discussions"]
})

// For bleeding edge info
brave_news_search({
  query: "Minecraft 1.21.5 snapshot modding changes",
  freshness: "pd"  // Last 24 hours
})
```

### Pattern 4: Multi-Framework Comparison

**Problem**: Need to compare patterns across frameworks

**Solution**: Separate searches with consistent structure

```javascript
// Search 1: Framework A
const forgeResults = brave_web_search({
  query: "NeoForge event bus registration pattern 2025",
  allowed_domains: ["docs.neoforged.net"],
  count: 5
})

// Search 2: Framework B
const fabricResults = brave_web_search({
  query: "Fabric event callback registration pattern 2025",
  allowed_domains: ["fabricmc.net"],
  count: 5
})

// Compare in synthesis
```

## Advanced Filtering Techniques

### Freshness Filter Decision Tree

```
Is the topic version-specific (e.g., "NeoForge 1.21")?
├─ YES → Use freshness: "py" (last year)
│   └─ Still getting old results?
│       └─ Use freshness: "pm" (last month)
│
└─ NO → Is it rapidly evolving (e.g., "AI coding tools")?
    ├─ YES → Use freshness: "pw" or "pd" (week/day)
    └─ NO → Use freshness: "py" or omit (general knowledge)
```

### Country/Language Selection

**Use Cases:**

1. **Multi-Language Community Research**
```javascript
// Japanese modding community
brave_web_search({
  query: "Minecraft MOD開発 チュートリアル",
  search_lang: "jp",
  ui_lang: "ja-JP",
  country: "JP"
})
```

2. **Regional Framework Preference**
```javascript
// European Fabric community
brave_web_search({
  query: "Fabric modding guide",
  country: "DE",
  search_lang: "de"
})
```

3. **Global English Results**
```javascript
brave_web_search({
  query: "Minecraft modding best practices",
  country: "ALL",  // Not limited to one country
  search_lang: "en"
})
```

### Result Type Strategy Matrix

| Research Goal | Recommended result_filter |
|---------------|---------------------------|
| Official documentation | `["web"]` |
| Community troubleshooting | `["discussions", "faq"]` |
| Breaking news | `["news"]` |
| Tutorial discovery | `["web", "videos"]` |
| Forum discussions | `["discussions"]` |
| Comprehensive research | `["web", "discussions", "news"]` |

## Specialized Search Workflows

### Workflow 1: Documentation Hierarchy Search

**Goal**: Find both official docs AND community explanations

```javascript
// Step 1: Official documentation
const officialDocs = brave_web_search({
  query: "NeoForge 1.21 registry system documentation",
  allowed_domains: ["docs.neoforged.net"],
  count: 3
})

// Step 2: Community tutorials
const tutorials = brave_web_search({
  query: "NeoForge 1.21 registry tutorial beginner",
  result_filter: ["web"],
  blocked_domains: ["docs.neoforged.net"],  // Exclude official docs
  count: 5
})

// Step 3: Community discussions
const discussions = brave_web_search({
  query: "NeoForge registry common issues",
  result_filter: ["discussions"],
  count: 5
})
```

### Workflow 2: Video Tutorial Discovery

**Goal**: Find high-quality video tutorials

```javascript
// Step 1: Recent video tutorials
const recentVideos = brave_video_search({
  query: "NeoForge 1.21 modding tutorial complete",
  freshness: "pm",  // Last month
  count: 30
})

// Step 2: Sort by creator reputation (manual)
// Look for: TurtyWurty, McJty, Kaupenjoe in titles

// Step 3: Get written companion guides
const writtenGuides = brave_web_search({
  query: "NeoForge 1.21 tutorial written guide",
  result_filter: ["web"],
  count: 10
})
```

### Workflow 3: API Breaking Changes Research

**Goal**: Identify migration requirements for version upgrade

```javascript
// Step 1: Official changelog
const changelog = brave_web_search({
  query: "NeoForge 1.20 to 1.21 breaking changes changelog",
  allowed_domains: ["docs.neoforged.net", "github.com/neoforged"],
  count: 5
})

// Step 2: Community migration guides
const migrationGuides = brave_web_search({
  query: "Forge 1.20 to NeoForge 1.21 migration guide",
  result_filter: ["web", "discussions"],
  freshness: "pm",
  count: 10
})

// Step 3: GitHub migration PRs (real examples)
const githubExamples = brave_web_search({
  query: "NeoForge 1.21 migration site:github.com",
  count: 10
})
```

### Workflow 4: Troubleshooting Research

**Goal**: Find solutions to specific errors

```javascript
// Step 1: Exact error search
const exactError = brave_web_search({
  query: "\"class file for net.neoforged.neoforge.registries.DeferredRegister not found\"",
  result_filter: ["discussions", "web"],
  freshness: "py",
  count: 10
})

// Step 2: Broader symptom search
const symptomSearch = brave_web_search({
  query: "NeoForge DeferredRegister class not found gradle",
  result_filter: ["discussions"],
  count: 10
})

// Step 3: Official issue tracker
const issueTracker = brave_web_search({
  query: "DeferredRegister not found site:github.com/neoforged",
  count: 5
})
```

## Summarizer Advanced Usage

### When to Use Summarizer

**Good Use Cases:**
- ✅ Complex topic requiring synthesis from 10+ sources
- ✅ Comparing multiple implementation approaches
- ✅ Understanding unfamiliar domain quickly
- ✅ Extracting key points from lengthy documentation

**Bad Use Cases:**
- ❌ Simple API reference lookup (just read the docs)
- ❌ Finding specific code snippet (use code search)
- ❌ Yes/no questions (waste of tokens)

### Summarizer Workflow

```javascript
// Step 1: Broad search with summary enabled
const results = brave_web_search({
  query: "Minecraft rendering pipeline OpenGL shaders 2025",
  count: 15,  // More sources = better summary
  summary: true,  // REQUIRED
  freshness: "py"
})

// Step 2: Generate summary with references
const summary = brave_summarizer({
  key: results.summarizer.key,
  inline_references: true,  // Adds [1], [2] citations
  entity_info: true  // Includes related topics/people
})

// Step 3: Follow up on specific points from summary
// Use summary to identify key concepts, then search deeper
```

### Summarizer Output Enhancement

**Enable inline_references:**
```javascript
brave_summarizer({
  key: "...",
  inline_references: true
})

// Output includes:
// "Minecraft uses OpenGL 3.2 core profile[1][3] for rendering,
//  with shaders written in GLSL 1.50[2]."
//
// [1] https://minecraft.wiki/...
// [2] https://docs.gl/...
// [3] https://lwjgl.org/...
```

**Enable entity_info:**
```javascript
brave_summarizer({
  key: "...",
  entity_info: true
})

// Output includes:
// Related entities: LWJGL, OpenGL, GLSL, Vertex Buffers
// Key people: Notch, Grum (Mojang)
```

## Performance Benchmarks

### Search Speed Comparison

| Search Type | Avg Response Time | Token Cost | Best For |
|-------------|------------------|------------|----------|
| Web (5 results) | ~2s | ~400 tokens | Quick lookups |
| Web (15 results) | ~3s | ~1200 tokens | Comprehensive research |
| News (20 results) | ~2.5s | ~800 tokens | Recent updates |
| Video (30 results) | ~3s | ~900 tokens | Tutorial discovery |
| Image (100 results) | ~4s | ~2000 tokens | Visual references |
| Summarizer | ~5s | ~500 tokens | Topic synthesis |

### Optimization Case Studies

**Case Study 1: Reducing Token Cost by 60%**

Before:
```javascript
brave_web_search({
  query: "Minecraft modding",
  count: 20
})
// Result: 20 results, 1600 tokens, mostly irrelevant
```

After:
```javascript
brave_web_search({
  query: "NeoForge 1.21.3 modding tutorial 2025",
  allowed_domains: ["docs.neoforged.net", "github.com"],
  count: 5,
  freshness: "pm"
})
// Result: 5 results, 400 tokens, all relevant
```

**Savings**: 1200 tokens (75% reduction), 4x better relevance

**Case Study 2: Finding Recent Documentation**

Before:
```javascript
brave_web_search({
  query: "NeoForge registry"
})
// Result: Mix of Forge 1.19, Forge 1.20, NeoForge results
```

After:
```javascript
brave_web_search({
  query: "NeoForge 1.21 DeferredRegister 2025",
  freshness: "pm",
  allowed_domains: ["docs.neoforged.net"]
})
// Result: Only NeoForge 1.21+ documentation
```

**Impact**: 100% relevant results, no version confusion

## Common Pitfalls and Solutions

### Pitfall 1: Too Broad Queries

**Problem**: `query: "Minecraft blocks"` returns 20 results about block breaking, block placement, etc.

**Solution**: Add context
```javascript
query: "NeoForge 1.21 custom block registration DeferredRegister"
```

### Pitfall 2: Ignoring Freshness

**Problem**: Getting Forge 1.19 tutorials for NeoForge 1.21 query

**Solution**: Apply freshness filter
```javascript
freshness: "pm"  // Last month only
```

### Pitfall 3: Wrong Search Tool

**Problem**: Using `brave_web_search` for visual references

**Solution**: Use `brave_image_search`
```javascript
brave_image_search({
  query: "Minecraft custom GUI screen layout",
  count: 50
})
```

### Pitfall 4: Over-Using Summarizer

**Problem**: Using summarizer for simple lookups (wastes 500+ tokens)

**Solution**: Only use for complex multi-source synthesis

### Pitfall 5: Not Verifying Sources

**Problem**: Trusting first result without checking domain

**Solution**: Prioritize official docs, cross-reference multiple sources

---

**Remember**: The goal is to find the right information efficiently, not to maximize search results. Quality over quantity.
