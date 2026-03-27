---
name: fetch-notion-tasks
description: >-
  Fetches tasks from a Notion database using multi-query search to work around
  Notion MCP's semantic search limitations, then optionally rewrites empty
  descriptions and plans parallel implementation waves. This skill should be used
  when the user asks to "fetch tasks", "get notion tasks", "check tasks", "show tasks",
  "list tasks", "what tasks are in progress", "pull tasks from notion", "check notion board",
  "rewrite task descriptions", "plan tasks", "plan implementation", "what needs to be done",
  or mentions task status from Notion.
version: 0.2.0
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

## Phase 6: Plan Implementation

After all tasks are verified and well-described, plan how to implement them:

### Step 1 — Explore All Task Areas
Launch **parallel Agent tools with `subagent_type: Explore`** (one per task or feature area) to gather:
- Exact files to modify/create for each task
- Existing utilities, components, patterns to reuse
- Complexity estimate

### Step 2 — File Overlap Analysis
Map which files each task touches. Build a conflict matrix.
Tasks that modify the same files **cannot** run in the same parallel wave.

### Step 3 — Ask User for Ordering
Use `AskUserQuestion`:
- Priority order: quick wins first? feature area grouping? custom?
- Execution mode: parallel waves? sequential?

### Step 4 — Wave Grouping
Group tasks into parallel waves:
- Tasks in the same wave must have **zero overlapping files**
- Quick wins (trivial changes) go in Wave 1
- Tasks conflicting with Wave 1 tasks go in Wave 2+
- Each wave completes and merges before the next starts

### Step 5 — Write Execution Plan
For each task, document:
- Branch name (e.g., `feat/task-short-name`)
- Step-by-step implementation (files to modify, what to change, what to create)
- Estimate

### Step 6 — Wave Summary
Present the execution timeline:
```
WAVE 1 (N parallel agents)
├── Agent A: Task X    ~estimate
├── Agent B: Task Y    ~estimate
└── Agent C: Task Z    ~estimate

── Merge + verify ──

WAVE 2 (N parallel agents)
├── Agent D: Task W    ~estimate
└── Agent E: Task V    ~estimate

── Merge + final verify ──
```

Include verification steps between waves: lint, type check, tests, dev server smoke test.
