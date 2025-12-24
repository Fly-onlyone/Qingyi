---
description: Initialize Claude Code context structure for a new project
---

I'll set up the recommended Claude Code context management structure for this project.

## What I'll Create

```
project/
├── .claude/
│   ├── CLAUDE.md                # Project-specific instructions
│   └── rules/
│       ├── conventions.md       # Code style and naming conventions
│       └── architecture.md      # Architecture patterns and decisions
├── docs/
│   └── api-discoveries/         # Auto-populated API documentation
│       └── .gitkeep
└── CLAUDE.local.md              # Your personal preferences (auto-gitignored)
```

## Steps

1. **Detect Project Type**: Analyze build files to identify framework (Minecraft mod, Python, Node.js, etc.)
2. **Create Structure**: Generate `.claude/`, `docs/api-discoveries/`, and template files
3. **Auto-Populate**: Fill in detected project info (build commands, dependencies, framework)
4. **Add to .gitignore**: Ensure `CLAUDE.local.md` is ignored

## After Initialization

- Edit `.claude/CLAUDE.md` to add project-specific conventions
- Use `.claude/rules/` for detailed topic-specific guidelines
- Claude will auto-populate `docs/api-discoveries/` as it learns your APIs
- Use `CLAUDE.local.md` for personal workspace preferences

## Documentation Management (Optional)

For version-specific library documentation, consider setting up docs-mcp-server:

1. **Install**: `npx @arabold/docs-mcp-server@latest` (or add to Claude Code MCP config)
2. **Index project docs**: Use `scrape_docs` to index framework/library documentation
3. **Search indexed docs**: Use `search_docs` for version-aware documentation lookup
4. **Web UI**: Access at `http://localhost:6280` when running standalone

Example: Index Minecraft Forge 1.20.1 docs for quick reference during development.

Let me initialize this structure now...
