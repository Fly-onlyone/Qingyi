---
name: fetch-notion-tasks
description: >-
  Fetches tasks from a Notion database using multi-query search to work around
  Notion MCP's semantic search limitations, optionally rewrites empty descriptions,
  and executes all verified tasks concurrently — each in its own git worktree under
  `.claude/worktrees/` — before handing off to `merge-worktree` to land the changes.
  This skill should be used when the user asks to "fetch tasks", "get notion tasks",
  "check tasks", "show tasks", "list tasks", "what tasks are in progress",
  "pull tasks from notion", "check notion board", "rewrite task descriptions",
  "plan tasks", "plan implementation", "implement notion tasks",
  "what needs to be done", or mentions task status from Notion.
version: 0.3.0
---

# Fetch Notion Tasks

Fetch tasks from a Notion task database, verify their status and description quality,
validate understanding with the user, rewrite inaccurate descriptions, and plan implementation.

---

## Phase 0: Discover Database

Before searching, locate the Notion database configuration:

1. Check project docs for Notion database info (e.g., `CLAUDE.md`, `docs/NOTION.md`, or similar).
   Look for: database ID, data source URL (`collection://...`), status values.
2. If not found in docs, use `notion-search` with `"task"` or the project name to find the database.
3. `notion-fetch` the database URL/ID to get:
   - The `<data-source url="collection://...">` tag — this is the data source URL for queries
   - The schema (property names, types, status values)
4. Note the **status values** and their groups (To Do, In Progress, Complete) from the schema.

Store these for use in subsequent phases:
- `DATA_SOURCE_URL` — the `collection://...` URL
- `STATUS_VALUES` — map of status names to groups
- `PROPERTIES` — property names and types (especially the title field name)

## Phase 1: Multi-Query Search

Notion MCP `notion-search` uses **semantic search**, not status filtering. A single query misses
tasks. Always run multiple queries.

1. Run 3+ `notion-search` queries **in parallel** against the data source:
   - The requested status (e.g., `"In progress"`)
   - Related status from the same group (e.g., if "In progress" and "Impossible" share a group)
   - A broad keyword query (e.g., `"task"`, `"feature"`, `"bug"`)
   - Adapt/add queries based on user's request (e.g., `"Done"` if they ask for completed tasks)
2. All queries use:
   - `data_source_url`: the `DATA_SOURCE_URL` from Phase 0
   - `page_size: 25`
   - `max_highlight_length: 0`
   - `filters: {}`
3. Collect all results and **deduplicate by page ID**.

## Phase 2: Fetch & Verify

1. `notion-fetch` each unique page ID (**parallel** where possible).
2. Read the actual `Status` property from the fetched page — do NOT trust search result ordering
   or highlights for status filtering.
3. Filter by requested status (default: `"In progress"`).
4. Assess description quality for each task. Three levels:
   - **Empty**: Description property is `""` AND page body contains default template text
     (e.g., `"Provide an overview"`, empty sub-tasks `- [ ]` with no text)
   - **Detailed**: Has meaningful description and filled-in sub-tasks
   - **Suspect**: Has a description but it may be outdated, wrong, or mismatched with the task
     title. Flag if: description references completed work, uses vague language, or the scope
     seems misaligned with the title.

## Phase 3: Report & Triage

Present results as a markdown table:

```
| # | Icon | Task Name | Status | Description | Link |
|---|------|-----------|--------|-------------|------|
```

- Description column: "Empty", "Detailed", or "Suspect"
- Highlight empty and suspect tasks explicitly

Then use `AskUserQuestion` to ask what to do next:
- **Verify & rewrite descriptions** — proceed to Phase 4
- **Plan implementation of all tasks** — proceed to Phase 4 (verify step) then Phase 6
- **Start implementing a specific task** — exit skill, begin implementation
- **Something else** — follow user's direction

## Phase 4: Verify Understanding Per Task

**Critical lesson: A detailed description can still be wrong.** Before planning or implementing,
walk through each task with the user to confirm the description matches their actual intent.

For each task (prioritize suspect and empty tasks, but verify ALL if planning implementation):

### Step 1 — Present Your Understanding
Summarize what you think the task means in 2-3 sentences. Include:
- What will change (user-visible behavior)
- Which part of the app is affected
- Key technical approach

### Step 2 — Ask for Confirmation
Use `AskUserQuestion`: "Does this match what you want for [task name]?"
- Options: "Yes", "No, let me explain", "Partially right"

### Step 3 — Handle Corrections
If the user corrects your understanding:
1. Ask follow-up questions to nail down the actual intent
2. For UI tasks: ask about layout, placement, design direction (offer 2-4 options with previews)
3. For behavior changes: ask about the exact flow (what triggers it, what it does, what output)
4. **Update the Notion description immediately** — don't wait until the end

### Step 4 — Update Notion (if description changed)
Use two `notion-update-page` calls:

**Call 1** — `command: "update_properties"`, `properties: {...}`:
- Update `Description` to match the corrected understanding

**Call 2** — `command: "replace_content"`, `new_str: "..."`:
- Rewrite the full page body with the corrected task description (see template in Phase 5)

This ensures the Notion task is always the source of truth, not conversation context.

## Phase 5: Write Descriptions for Empty Tasks

For each task with an empty description, follow this workflow **per task**:

### Step 1 — Explore Codebase
Launch an Agent tool with `subagent_type: Explore` to understand the feature area related to the task title:
- Search for relevant files, models, endpoints, components, types
- Identify what already exists vs what needs to be built
- Note key file paths and current state

### Step 2 — Clarify Intent with User
Use `AskUserQuestion` to ask what the task actually means. Offer **3-4 concrete
interpretations** based on codebase context. Example:

> "What does '[task title]' mean to you?"
> - [Interpretation A based on codebase findings]
> - [Interpretation B]
> - [Interpretation C]
> - [Interpretation D]

### Step 3 — Clarify Design Decisions
Use `AskUserQuestion` for layout and technical approach.

**For UI tasks**, propose 2-4 design directions with ASCII previews using AskUserQuestion's
`preview` field. Let the user pick visually. Example areas to decide:
- Layout: card vs tab vs section vs page
- Placement: above existing content, sidebar, new route
- Style: minimal vs rich, data-first vs visual-first
- Interaction: polling vs WebSocket, autocomplete vs dropdown

**For backend tasks**, clarify:
- Data flow: what triggers the action, what it produces
- Integration: which existing services/APIs to reuse
- Persistence: where to store results

Only ask questions where the answer meaningfully changes the implementation.

### Step 4 — Write Description
Update the Notion page via two separate `notion-update-page` calls:

**Call 1** — `command: "update_properties"`, `properties: {...}`, `icon: "emoji"`:
- Set description property to a concise summary (2-3 sentences covering goal, approach, key files)
- Set `icon` to a relevant emoji

**Call 2** — `command: "replace_content"`, `new_str: "..."` (full page body):
```markdown
## Task description
**Goal:** [one sentence]

**Current state ([what exists]):**
- `file/path` — [what it does]
- [more files...]
- [what's missing]

**Existing integration ([what can be reused]):**
- `endpoint/path` — [what it provides]
- [more existing code...]

**Design decisions:**
- **[Decision area]:** [chosen approach]
- **[Decision area]:** [chosen approach]

**Key files to modify:**
- `path/to/file` — [what to change]
- New: `path/to/new/file` — [what to create]

## Sub-tasks
- [ ] [Actionable item 1]
- [ ] [Actionable item 2]
- [ ] [Actionable item 3]
- [ ] [Actionable item 4]
- [ ] [Actionable item 5]
- [ ] [Actionable item 6 (optional)]
- [ ] [Actionable item 7 (optional)]

## Supporting files
```

### Step 5 — Verify
`notion-fetch` the page again to confirm the update was applied correctly.

Repeat Steps 1-5 for each empty task. Use parallel Explore agents when rewriting
multiple tasks to speed up codebase exploration.

## Phase 6: Execute Implementation in Parallel Worktrees

After all tasks are verified and well-described, run every task **concurrently**, each in an
isolated git worktree, then hand off to `merge-worktree` to land the changes. File overlap
no longer gates execution — worktrees isolate the working tree, so conflicts only surface at
merge time.

### Step 1 — Explore All Task Areas (parallel)

Launch **one `Agent` per task** with `subagent_type: Explore`, all in a **single message**
with multiple tool calls. Each agent must return:
- Exact files to modify/create
- Reusable utilities, components, and patterns to call into
- A concise step-by-step implementation outline
- Complexity estimate (S / M / L)

### Step 2 — Merge-Conflict Prediction (not an execution gate)

Build a file-overlap matrix from Step 1 results. Two tasks "overlap" if they modify the
same file path.

Overlap **no longer prevents parallel execution** — each agent has its own working tree.
Use the matrix only to predict **merge-time** conflicts and recommend a **merge order**:
land lowest-overlap branches first; flag pairs that will definitely conflict.

### Step 3 — Confirm With User

Present a single concise summary, then ask before launching:

```
Ready to launch N tasks in parallel.
Worktrees will be created at:
  .claude/worktrees/<branch-1>/
  .claude/worktrees/<branch-2>/
  ...
Predicted merge conflicts (files touched by 2+ tasks):
  - path/to/file.ts        (tasks A, C)
  - path/to/other.tsx      (tasks B, D)
Recommended merge order: A → B → D → C
```

Use `AskUserQuestion` with options: **Launch all**, **Launch a subset**, **Cancel**.

### Step 4 — Create Worktrees (parallel `git worktree add`)

For each task, derive a branch name (`feat/<task-slug>`, `fix/<task-slug>`, etc.) and
create a worktree off the current main branch:

```bash
git worktree add .claude/worktrees/<branch> -b <branch>
```

Issue every `git worktree add` **in parallel** (one Bash call per worktree, all in the same
message). Git serializes internally — that's fine. Pre-checks:
- If `<branch>` already exists, append `-2`, `-3`, …
- If `.claude/worktrees/<branch>/` already exists, ask the user before reusing
- Worktrees MUST live under `.claude/worktrees/` (per project convention)

### Step 5 — Dispatch Agents in Parallel (single message, N tool calls)

Send **one message with N `Agent` tool calls** — one per task, fired in parallel. Each
agent prompt MUST include:

1. **Working directory**: absolute path to its worktree (`.claude/worktrees/<branch>/`)
2. **Task brief**: the full verified Notion description from Phase 4
3. **Step 1 findings**: files to modify, patterns to reuse, implementation outline
4. **Branch name**: for commit-message context
5. **Completion contract**:
   - Implement the task end-to-end inside the worktree
   - Run project lint/format after edits (per global CLAUDE.md)
   - Commit work with a conventional-commit message before returning (preferred), OR
     leave WIP uncommitted (`merge-worktree` will auto-commit it)
   - **NEVER** run `git worktree remove` — cleanup is the merge skill's job

Default `subagent_type: general-purpose`. Use a specialized agent (e.g.
`code-refactoring:legacy-modernizer`) only when the task description clearly matches.

### Step 6 — Aggregate Results

When all agents return, summarize per task:
- Branch + worktree path
- Files actually changed (use `git -C <worktree> diff --stat <main>..HEAD`)
- Whether the agent committed or left WIP
- Any escapes/blockers the agent reported

If any agent failed or refused, surface it and ask the user how to proceed **before**
suggesting merge.

### Step 7 — Hand Off to `merge-worktree`

Do **not** merge, push, or delete worktrees from this skill. Tell the user:

> All N agents finished. Recommended next step: run `/merge-worktree` (or
> `/merge-worktree-no-commit` if any worktree should stay uncommitted) in this merge
> order: `<order from Step 2>`.

Per project convention, worktrees are never auto-removed by anything other than the
dedicated merge skill or the user.
