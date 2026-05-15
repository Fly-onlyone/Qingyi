# `.obsidian/` Config Reference

Drop-in contents for the five core config files. Write all of these to
`obsidian/.obsidian/` exactly as shown.

## ⚠️ Pitfall: Obsidian auto-init

If Obsidian is running when you create the `.obsidian/` folder, it may auto-populate the
JSON files with empty `{}` placeholders before you can write them. **Read each file
first**; if it already exists with `{}` content, use `Edit` (not `Write`) to replace the
contents.

## `app.json`

```json
{
  "alwaysUpdateLinks": true,
  "newLinkFormat": "shortest",
  "useMarkdownLinks": false,
  "showLineNumber": true,
  "readableLineLength": true,
  "strictLineBreaks": false,
  "showFrontmatter": true,
  "foldHeading": true,
  "foldIndent": true,
  "useTab": true,
  "tabSize": 2,
  "defaultViewMode": "source",
  "livePreview": true,
  "spellcheck": false,
  "attachmentFolderPath": "_Attachments"
}
```

- `useMarkdownLinks: false` keeps `[[wikilink]]` syntax (don't switch to `[label](path)`).
- `newLinkFormat: "shortest"` keeps wikilinks readable (just the note name when unambiguous).
- `defaultViewMode: "source"` — show markdown source by default. Switch to `"preview"` if
  the user prefers rendered view at open.

## `appearance.json`

```json
{
  "baseFontSize": 16,
  "theme": "obsidian",
  "accentColor": "#7c3aed"
}
```

`theme: "obsidian"` is the built-in dark theme. Adjust `accentColor` to match the
project's brand if known.

## `core-plugins.json`

```json
{
  "file-explorer": true,
  "global-search": true,
  "switcher": true,
  "graph": true,
  "backlink": true,
  "canvas": false,
  "outgoing-link": true,
  "tag-pane": true,
  "footnotes": false,
  "properties": true,
  "page-preview": true,
  "daily-notes": false,
  "templates": true,
  "note-composer": true,
  "command-palette": true,
  "editor-status": true,
  "bookmarks": true,
  "markdown-importer": false,
  "zk-prefixer": false,
  "random-note": false,
  "outline": true,
  "word-count": true,
  "slides": false,
  "audio-recorder": false,
  "workspaces": false,
  "file-recovery": true,
  "publish": false,
  "sync": false,
  "bases": false,
  "webviewer": false
}
```

Disable plugins that don't fit a code-documentation vault: `canvas`, `daily-notes`,
`random-note`, `slides`, `audio-recorder`, `sync`, `bases`, `webviewer`.

**Note on `slash-command`:** Obsidian 1.12+ writes this key automatically; older
versions ignore it. Safe to omit — Obsidian will add it on first launch if the runtime
supports it.

## `graph.json` (color groups by zone — MUST be customized per project)

**⚠️ The `colorGroups` array below is a Trading Agent (full-stack) example. Rewrite it
to match the actual zones you created in Step 3.** One entry per zone you scaffolded —
no more, no fewer. Wrong path queries make Graph View look broken.

```json
{
  "collapse-filter": false,
  "search": "",
  "showTags": true,
  "showAttachments": false,
  "hideUnresolved": false,
  "showOrphans": true,
  "collapse-color-groups": false,
  "colorGroups": [
    { "query": "path:00-Architecture", "color": { "a": 1, "rgb": 14701138 } },
    { "query": "path:01-Backend",      "color": { "a": 1, "rgb": 5025616 } },
    { "query": "path:02-Frontend",     "color": { "a": 1, "rgb": 14048348 } },
    { "query": "path:03-Integrations", "color": { "a": 1, "rgb": 14592786 } },
    { "query": "path:04-Patterns",     "color": { "a": 1, "rgb": 16744703 } },
    { "query": "path:05-Operations",   "color": { "a": 1, "rgb": 12768280 } },
    { "query": "path:06-Glossary",     "color": { "a": 1, "rgb": 11842740 } }
  ],
  "collapse-display": false,
  "showArrow": true,
  "textFadeMultiplier": 0,
  "nodeSizeMultiplier": 1.2,
  "lineSizeMultiplier": 1.1,
  "collapse-forces": false,
  "centerStrength": 0.518,
  "repelStrength": 11.5,
  "linkStrength": 1,
  "linkDistance": 250,
  "scale": 1,
  "close": false
}
```

**RGB values** are decimal (Obsidian's native format); compute as `R*65536 + G*256 + B`
from hex. The 7 RGB values above are a balanced palette (purple, green, teal, cyan,
orange, blue, gray) — reuse them when adding zones, or pick new ones from a categorical
palette like Tableau 10 or D3's `schemeCategory10`.

**Examples for non-full-stack shapes:**

- Backend-only API: drop `path:02-Frontend`, keep the others.
- Library / SDK: replace `path:01-Backend` + `path:02-Frontend` with one `path:01-Core` entry; drop `path:03-Integrations` and `path:05-Operations` if they don't exist.
- Monorepo: replace single backend/frontend entries with one entry per service (e.g., `path:01-Services/auth`, `path:01-Services/billing`).

If your zone numbering differs (e.g., you used `05-Glossary` instead of `06-Glossary`
because you dropped one zone), update the `path:` queries accordingly.

## `community-plugins.json`

```json
[]
```

Always empty for init. Keep the vault portable; users add community plugins themselves.

## `workspace.json` (DO NOT WRITE)

Obsidian creates this on first open with per-user UI state (open tabs, sidebar widths).
**Don't seed it** and **gitignore it**:

```gitignore
obsidian/.obsidian/workspace.json
obsidian/.obsidian/workspace-mobile.json
obsidian/.obsidian/workspaces.json
```
