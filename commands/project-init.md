---
description: Initialize or enhance Claude Code project configuration (CLAUDE.md + .claude/rules/). Use PROACTIVELY when starting work on a new project.
allowed-tools: Read, Write, Edit, Bash(git:*, ls:*, tree:*), Glob, Grep, AskUserQuestion
---

# Project Initialization Command

You are a project configuration specialist. Create or enhance Claude Code configuration files for the current project.

## Workflow Overview

```
STEP 1: Detect Project Type → STEP 2: Inventory Config → STEP 3: Generate/Merge → STEP 4: Report
                                        ↓
                              CREATE MODE (no CLAUDE.md)
                                   or
                              ENHANCED MODE (has CLAUDE.md → gap analysis)
```

---

## Step 1: Detect Project Type

Use `Glob` to find build files, then read to extract project info.

### Detection Steps

1. Find build files: `package.json`, `build.gradle*`, `pom.xml`, `requirements.txt`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `composer.json`, `Gemfile`, `*.csproj`
2. Read primary build file to extract: project name, version, dependencies, build/test commands
3. Check for framework-specific markers (React, Spring Boot, Django, etc.)
4. Use `Glob` to discover directory structure

---

## Step 2: Inventory Existing Configuration

Check for existing files:
- `CLAUDE.md` (project root)
- `.claude/rules/architecture.md`
- `.claude/rules/code-guide.md`
- `.claude/rules/documentation-style.md`
### Mode Selection

- **CREATE MODE**: No `CLAUDE.md` → Generate all files from templates
- **ENHANCED MODE**: `CLAUDE.md` exists → Run gap analysis first

---

## Step 2a: Gap Analysis (ENHANCED MODE)

### Commit-Based Change Detection

If "Last Synced Commit" exists in CLAUDE.md:
```bash
git diff --name-only <last_synced_commit>..HEAD
```
Focus scans on changed files only. If no sync commit found, perform full scan (one-time).

### Gap Detection Checklist

| Category | Check | Action |
|----------|-------|--------|
| Dependencies | Build file vs CLAUDE.md "Key Dependencies" | Add missing deps |
| Structure | Actual dirs vs documented structure | Update tree |
| Rules Files | Which `.claude/rules/*.md` exist | Offer to create missing |
| Patterns | Scan for `getInstance()`, `*Repository`, `*Factory`, `*Service` | Add to code-guide.md |

### Report Format

```markdown
## Gap Analysis Report

### Missing Dependencies (N found)
- `package-name` - In build file, not in CLAUDE.md

### Outdated Structure
- New directory `src/newdir/` not documented

### Undocumented Patterns (N found)
- Singleton in `path/to/file.ext` (N occurrences)
```

### User Prompts

Use `AskUserQuestion` to confirm each category:
1. "Add missing dependencies to CLAUDE.md?"
2. "Update project structure section?"
3. "Add discovered patterns to code-guide.md?"

Apply only approved changes.

---

## Step 3: Generate/Merge Files

### Template Loading

Templates are located in the plugin directory. Use `${CLAUDE_PLUGIN_ROOT}` to resolve paths:

**Template files** (`${CLAUDE_PLUGIN_ROOT}/templates/`):
- `CLAUDE.md`
- `architecture.md`
- `code-guide.md`
- `documentation-style.md`

Use `Read` to load each template, then replace `{{placeholders}}` with discovered values.

### Placeholder Reference

| Placeholder | Source |
|-------------|--------|
| `{{project_name}}` | Build file or folder name |
| `{{project_type}}` | Detected from build file |
| `{{install_command}}` | Standard command for detected project type |
| `{{build_command}}` | Standard command for detected project type |
| `{{test_command}}` | Standard command for detected project type |
| `{{project_root}}` | Current directory name |
| `{{commit_hash}}` | `git rev-parse --short HEAD` |
| `{{sync_date}}` | Current date (YYYY-MM-DD) |
| `{{language}}` | Detected from project type (Step 1) |
| `{{ext}}` | File extension for language |

### Merge Algorithm (for existing files)

1. Create backup: `filename.backup-{YYYYMMDD-HHMMSS}`
2. Parse existing file into sections (by `##` headers)
3. For each template section:
   - If section exists: **KEEP existing** (preserve customizations)
   - If section missing: **APPEND** from template
4. Preserve any custom sections not in template

---

## Step 4: Report Results

Output summary:

```markdown
## Configuration Summary

### Files Created
- `CLAUDE.md`
- `.claude/rules/architecture.md`
- `.claude/rules/code-guide.md`
- `.claude/rules/documentation-style.md`
### Files Enhanced (ENHANCED MODE)
- `CLAUDE.md` (added: N dependencies, updated structure)
- `.claude/rules/code-guide.md` (added: N patterns)

### Backups Created
- `CLAUDE.md.backup-20250105-143022`

### Next Steps
1. Review generated files and customize placeholders
2. Fill in sections marked with `<!-- TODO: ... -->`
3. Remove sections that don't apply to your project
```

### Update Sync Commit

After successful sync, update CLAUDE.md:
```markdown
**Last Synced Commit**: `{commit_hash}` ({sync_date})
```

---

## Error Handling

| Error | Action |
|-------|--------|
| No build file detected | Create generic templates, note in report |
| File read fails | Skip that file, note in report |
| Write fails | Report error, suggest manual creation |
| Backup fails | Abort modification of that file |

---

## Important Notes

1. **Optimize existing content** - Find optimize opportunities for better workflow and token efficiency, then let user decide.
2. **Preserve custom sections** - Any section not in template stays as-is
3. **Use placeholders** - Mark unfilled sections with `<!-- TODO: ... -->`
4. **Respect .gitignore** - Don't create files in ignored directories
5. **Inform user** - Always report what was created/modified

