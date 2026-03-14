---
name: setup-permission
description: >-
  This skill should be used when the user wants to configure Claude Code permission rules
  (allow/deny entries in settings.json).

  ACTION TRIGGERS:
  - "setup permissions", "configure permissions", "allow tools", "permission rules"
  - "settings.json", "setup allow rules", "generate permissions", "auto-allow"
  - "scan for commands", "discover tools", "permission config"
  - "stop asking for permission", "auto-approve", "tired of approving"

  NATURAL LANGUAGE PATTERNS:
  - "set up permissions" + project context
  - "allow" / "whitelist" + tools/commands
  - "generate settings.json rules"
  - "what commands should I allow"
  - "scan my project for permission rules"
  - "stop prompting me" / "auto-approve everything"
  - "trust these tools" / "reduce permission prompts"

  NOTE: Deny rules are ONLY generated when the user explicitly asks for them
  (e.g., "add deny rules", "block commands", "restrict tools"). Otherwise,
  only allow rules are produced.
allowed-tools: Read, Glob, Grep, Bash, Edit, Write, AskUserQuestion
---

# Setup Permission Rules

Scan a codebase to discover reusable commands and MCP tools, then generate Claude Code permission rules (`allow` entries
in `.claude/settings.json` or `.claude/settings.local.json`).

## Step 1: Check Existing Settings

Read these files if they exist (skip gracefully if missing):

1. `.claude/settings.local.json` (personal, gitignored)
2. `.claude/settings.json` (team, committed)

Record all existing `allow` and `deny` entries to avoid duplicates later.

**If `.claude/` directory doesn't exist**: Note this — it will be created in Step 8.

## Step 2: Detect Project Type

Glob for build files to determine the project type:

| Build File                            | Project Type          |
|---------------------------------------|-----------------------|
| `package.json`                        | JavaScript/TypeScript |
| `build.gradle` / `build.gradle.kts`   | Java/Kotlin (Gradle)  |
| `pom.xml`                             | Java (Maven)          |
| `requirements.txt` / `pyproject.toml` | Python                |
| `Cargo.toml`                          | Rust                  |
| `go.mod`                              | Go                    |
| `composer.json`                       | PHP                   |
| `Gemfile`                             | Ruby                  |
| `*.csproj` / `*.sln`                  | C# / .NET             |

Multiple build files may coexist (e.g., monorepo). Detect all that apply.

**If no build file found**: Skip to Step 3 (universal scan) and Step 4 (MCP).

## Step 3: Scan for Commands

Discover runnable commands based on detected project types. Generate `Bash(...)` permission patterns for each.

### Per-Project-Type Discovery

**JavaScript/TypeScript** (`package.json`):

- Read `scripts` object → generate `Bash(npm run <script>)` for each key
- If `yarn.lock` exists, also generate `Bash(yarn <script>)`
- If `pnpm-lock.yaml` exists, also generate `Bash(pnpm run <script>)`
- Common: `Bash(npx *)`, `Bash(npm install)`, `Bash(npm test)`

**Java/Kotlin — Gradle** (`build.gradle` / `build.gradle.kts`):

- Check for `gradlew` wrapper → prefer `Bash(./gradlew <task>)`
- Common tasks: `build`, `test`, `clean`, `assemble`, `check`
- If no wrapper: `Bash(gradle <task>)`

**Java — Maven** (`pom.xml`):

- Check for `mvnw` wrapper → prefer `Bash(./mvnw <goal>)`
- Common goals: `compile`, `test`, `package`, `clean`, `verify`, `install`
- If no wrapper: `Bash(mvn <goal>)`

**Python** (`pyproject.toml` / `requirements.txt`):

- Read `[project.scripts]` or `[tool.poetry.scripts]` in `pyproject.toml`
- Detect test/lint tools from config or dependencies: `pytest`, `ruff`, `mypy`, `black`, `flake8`
- Generate targeted patterns: `Bash(pytest *)`, `Bash(ruff *)`, `Bash(mypy *)`, `Bash(black *)`, `Bash(python -m *)`,
  etc.
- Avoid `Bash(python *)` — it is overly broad and auto-approves any script. Prefer specific module patterns instead.
- If `Makefile` exists, also scan targets

**Rust** (`Cargo.toml`):

- Standard commands: `Bash(cargo build *)`, `Bash(cargo test *)`, `Bash(cargo run *)`, `Bash(cargo clippy *)`,
  `Bash(cargo fmt *)`

**Go** (`go.mod`):

- Standard commands: `Bash(go build *)`, `Bash(go test *)`, `Bash(go run *)`, `Bash(go vet *)`, `Bash(golangci-lint *)`
- If `Makefile` exists, scan targets

**PHP** (`composer.json`):

- Read `scripts` object → generate `Bash(composer <script>)`
- Common: `Bash(php *)`, `Bash(phpunit *)`, `Bash(composer install)`

**Ruby** (`Gemfile`):

- Common: `Bash(bundle exec *)`, `Bash(rake *)`, `Bash(rspec *)`, `Bash(rubocop *)`

**C# / .NET** (`*.csproj` / `*.sln`):

- Standard commands: `Bash(dotnet build *)`, `Bash(dotnet test *)`, `Bash(dotnet run *)`, `Bash(dotnet restore)`

### Universal Scans (all project types)

**Makefile targets:**

- If `Makefile` exists, parse targets → `Bash(make <target>)` for each

**Linter/Formatter configs:**

- `.eslintrc*` / `eslint.config.*` → `Bash(npx eslint *)`
- `.prettierrc*` / `prettier.config.*` → `Bash(npx prettier *)`
- `ruff.toml` / `[tool.ruff]` in `pyproject.toml` → `Bash(ruff *)`
- `.rubocop.yml` → `Bash(rubocop *)`
- `rustfmt.toml` → `Bash(cargo fmt *)`

**Docker:**

- If `Dockerfile` or `docker-compose.yml` exists → `Bash(docker *)`, `Bash(docker compose *)`

**Git (auto-suggested, user confirms in Step 5):**

- `Bash(git *)` — standard git operations

## Step 4: Discover MCP Tools

Discover MCP servers and tools from the current session context.

**IMPORTANT**: Do NOT read `.mcp.json` — it contains `env` blocks with API keys and secrets.

Instead, use the MCP tools already visible in your current session. All connected MCP tools appear as
`mcp__<server>__<tool>` in your available tools. Collect the unique server names and their tool names from this list.

If no MCP tools are visible in the session, skip MCP discovery.

**Ask user for granularity preference** via `AskUserQuestion`:
> "I found MCP servers: [list names]. How should I generate permission rules?"
> - **Server-level** — `mcp__<server-name>` (allows all tools from that server)
> - **Tool-level** — `mcp__<server-name>__<tool-name>` (granular per-tool rules)
> - **Skip** — Don't add MCP rules

## Step 5: Compose Allow Rules

Assemble all discovered rules into categories:

```
Build:   Bash(npm run build), Bash(dotnet build *), ...
Test:    Bash(npm test), Bash(pytest *), ...
Lint:    Bash(npx eslint *), Bash(ruff *), ...
Git:     Bash(git *)
MCP:     mcp__github, mcp__sentry, ...
Other:   Bash(docker *), Bash(make *), ...
```

**Deduplicate**: Remove any rules already present in existing settings (from Step 1).

**Present to user** via `AskUserQuestion`:
> "Here are the permission rules I'd like to add:"
> [formatted list grouped by category]
> - **All** — Add all rules
> - **Select** — Let me choose categories
> - **Cancel** — Don't add any rules

If "Select": ask which categories to include.

## Step 6: Deny Rules (ONLY if User Explicitly Asked)

**HARD GATE**: Skip this step entirely unless the user's original request explicitly mentioned deny/block/restrict
patterns (e.g., "add deny rules", "block force push", "restrict dangerous commands").

If requested, suggest common deny patterns grouped by risk:

**Destructive operations:**

- `Bash(git push --force *)` — force push
- `Bash(git reset --hard *)` — discard changes
- `Bash(rm -rf *)` — recursive delete
- `Bash(git clean -fd *)` — remove untracked files

**Privilege escalation:**

- `Bash(sudo *)` — superuser commands
- `Bash(chmod 777 *)` — overly permissive

**Sensitive file edits:**

- `Edit(.env)`, `Edit(.env.*)` — environment secrets
- `Edit(*credentials*)`, `Edit(*secret*)` — credential files

Present categories to user via `AskUserQuestion`, let them select which to include.

## Step 7: Choose Target File

Ask user via `AskUserQuestion`:
> "Where should I save the permission rules?"
> - **Personal** — `.claude/settings.local.json` (gitignored, just for you)
> - **Team** — `.claude/settings.json` (committed, shared with team)
> - **Both** — Allow rules to team file, deny rules to personal file

Recommend **Personal** as the default for most cases.

## Step 8: Write Settings

**If target file exists:**

- Read existing JSON content
- If the file contains JSON5 features (comments `//`, trailing commas), strip them before parsing to avoid errors
- Merge new `allow` (and optionally `deny`) entries into the existing arrays
- Preserve all other settings in the file
- Use `Edit` to update the JSON (write back as strict JSON — no comments or trailing commas)

**If target file doesn't exist:**

- Create `.claude/` directory if missing: `Bash(mkdir -p .claude)`
- Write a new JSON file with the rules using `Write`:

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(npm run *)"
    ]
  }
}
```

**Validation:**

- Ensure the output is valid JSON (no trailing commas, proper escaping)
- Verify no duplicate entries in the final arrays

## Step 9: Report

Display a summary:

```
Permission rules updated!

Target: .claude/settings.local.json

Added (12 rules):
  Build:  3 rules (npm run build, npm run dev, npm run start)
  Test:   2 rules (npm test, npx jest *)
  Lint:   2 rules (npx eslint *, npx prettier *)
  Git:    1 rule  (git *)
  MCP:    3 rules (mcp__github, mcp__sentry, mcp__context7)
  Other:  1 rule  (docker compose *)

Skipped (duplicates): 2
Deny rules: not requested
```

## Error Handling

| Condition                      | Response                                                                                          |
|--------------------------------|---------------------------------------------------------------------------------------------------|
| No build file found            | Report "No build files detected" — proceed with universal scans (Makefile, Docker, Git, MCP) only |
| Settings file has invalid JSON | Report parse error with file path and line — ask user to fix manually or overwrite                |
| No MCP config found            | Skip MCP discovery — note in report "No .mcp.json found"                                          |
| `.claude/` directory missing   | Create it with `mkdir -p .claude` before writing                                                  |
| User declines all rules        | "No rules added. Run this skill again when ready."                                                |
| No commands discovered         | Report "No project commands found" — offer to add only Git + MCP rules                            |
