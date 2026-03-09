---
name: improve-instruction
description: >-
  This skill should be used when the user asks to "improve instructions", "trim project instructions",
  "reduce CLAUDE.md tokens", "audit instruction files", "clean up project instructions",
  "review and fix CLAUDE.md", "remove outdated sections from instructions", "optimize context files",
  "reduce context size", "fix inaccuracies in instructions", or "improve CLAUDE.md".
  Provides a structured workflow for auditing, correcting, and pruning Claude Code instruction files
  to reduce per-conversation token cost without losing actionable content.
---

# Improve Instructions

Instruction files (CLAUDE.md, `.claude/rules/*.md`, MEMORY.md) are loaded into every conversation. Bloated or inaccurate instructions waste tokens and mislead. This skill provides a structured workflow to audit, fix, and prune them.

## Files in Scope

| File | Purpose | Typical Issues |
|------|---------|----------------|
| `CLAUDE.md` (project) | Project-specific guidance | Wrong file refs, outdated counts, deleted features |
| `.claude/rules/*.md` | Domain rules (arch, style, etc.) | Decorative diagrams, duplicated tables |
| `MEMORY.md` | Persistent cross-session notes | Historical entries, stack info duplicating CLAUDE.md |
| `CLAUDE.md` (global) | User-wide rules | Rarely needs changes (ask before editing) |

## Workflow

### Phase 0: Scope Check

Before starting, use `AskUserQuestion` to ask:
> "Should I also review and edit the global `~/.claude/CLAUDE.md`? (This affects ALL projects, not just this one.)"

If the user declines, exclude global CLAUDE.md from all subsequent phases.

### Phase 1: Inventory

Read all instruction files in parallel before making any changes. Take note of:
- Total approximate line/token count per file
- Sections that look decorative, historical, or potentially stale

### Phase 2: Cross-Reference Against Codebase

For each claim in the instruction files, verify against actual code:

**Common inaccuracies to check:**
- File paths and function names -- grep for actual location
- Script descriptions -- read the file to confirm what it actually does
- Error/warning counts -- run linter to get current count
- References to scripts or seed functions that may have been deleted
- Collection/model names that may have changed

**Common redundancies to flag:**
- ASCII diagrams that duplicate a package tree or table elsewhere
- Key components tables that duplicate directory listings
- Seed script docs when no seed files exist
- Stack info in MEMORY.md that duplicates CLAUDE.md Project Overview
- Historical "cleanup" entries in MEMORY.md with no future utility

### Phase 3: Plan Changes

Group findings into categories before editing:

1. **Fix** -- Inaccuracies that must be corrected (wrong file names, wrong descriptions)
2. **Delete** -- Sections with zero actionable value (decorative diagrams, historical logs)
3. **Condense** -- Sections that carry value but are longer than needed

Estimate token savings per change. Prioritize high-impact, low-risk deletions first.

### Phase 4: Execute Edits

Use the IDE MCP replace tool when the IDE is running, otherwise fall back to `Edit`. Avoid rewriting whole files unless multiple edits touch the same region.

**Order of operations:**
1. Fix inaccuracies first (prevents verifying stale data later)
2. Delete large sections (ASCII diagrams, tables) -- biggest token wins
3. Condense verbose text
4. Clean MEMORY.md last (lowest risk)

### Phase 5: Verify

Re-read each edited file to confirm:
- No broken cross-references (e.g. a line like "See `log.py`" still points to a real file)
- Removed sections had no unique info referenced elsewhere
- Remaining content is accurate and actionable

## What to Remove

### High-Value Removals (remove without hesitation)

- **ASCII box diagrams** -- decorative, typically >300 tokens, duplicated by package trees
- **"Key Components" tables** -- duplicated by `code-guide.md` package structure
- **Seed script docs** -- remove when no seed files exist and `init_db()` calls no seeds
- **Historical MEMORY entries** -- past cleanup logs, dated entries with no future utility
- **Stack info in MEMORY** -- if CLAUDE.md already has a Project Overview section

### Condense (reduce, don't delete)

- **Search tool notes** -- multi-line notes can usually become 1-2 lines
- **Anti-patterns sections** -- rules Claude follows by default need not be repeated
- **Formatting docs** -- single formatting preferences rarely referenced

### Preserve (never remove)

- Non-obvious domain-specific workflows not duplicated in code comments
- Known false-positive warnings (e.g., IDE-specific or linter quirks)
- Linting/tool conflict notes (e.g., formatter vs linter spacing conflicts)
- Context7 IDs and build command tables

## MEMORY.md Patterns

Keep MEMORY.md concise -- it's loaded in full each conversation. Standard structure:

```markdown
# Memory

## [Topic]
- Concise bullet (avoid multi-line explanations)

## Lessons
- One-liner per lesson
```

**Remove from MEMORY:**
- Session-specific context ("I fixed X on 2026-02-16")
- Info that duplicates CLAUDE.md sections
- Speculative or unverified notes

**Keep in MEMORY:**
- Environment quirks (e.g. env vars that don't expand in Windows bash)
- Cross-project lessons that recur
