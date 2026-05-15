# Verification Reference

Two verification layers: **filesystem-level** (works headless, always available) and
**Obsidian CLI** (graph-aware, requires Obsidian 1.12+ running).

## Layer 1: Filesystem wikilink integrity (Python)

Run this from any shell. Reports total references, unique targets, resolved %, top
backlinked concepts, and any leaf folders missing `_index.md`.

Obsidian resolves wikilinks **case-insensitively** but this script case-folds both
sides for parity — so `[[mongodb]]` resolves to `MongoDB.md`.

```python
# verify_vault.py
import re
from pathlib import Path
from collections import Counter

base = Path("./obsidian")  # adjust if vault lives elsewhere
WIKILINK_RE = re.compile(r"\[\[([^\]|#]+)")

# Template placeholders are not real broken links — filter before %
TEMPLATE_PLACEHOLDERS = {
    "other concept", "calling concept", "related concept",
    "use case a", "use case b", "related integration", "related pattern",
    "integration", "wikilinks", "...",
}

filenames_cf = {p.stem.casefold(): p.stem for p in base.rglob("*.md")}

targets = []
for md in base.rglob("*.md"):
    text = md.read_text(encoding="utf-8", errors="replace")
    for m in WIKILINK_RE.finditer(text):
        t = m.group(1).strip()
        if "/" in t:
            t = t.rsplit("/", 1)[-1]
        targets.append(t)

# Filter placeholders BEFORE computing % so the math reflects real health
real_targets = [t for t in targets if t.casefold() not in TEMPLATE_PLACEHOLDERS]
cnt = Counter(real_targets)
broken = [(t, n) for t, n in cnt.most_common() if t.casefold() not in filenames_cf]

resolved_refs = sum(cnt.values()) - sum(n for _, n in broken)
print(f"Total .md files: {len(filenames_cf)}")
print(f"Real wikilink references (excl. template placeholders): {sum(cnt.values())}")
print(f"Unique targets: {len(cnt)}")
print(f"Resolved references: {resolved_refs}/{sum(cnt.values())} "
      f"({100*resolved_refs/max(sum(cnt.values()),1):.2f}%)")
print(f"\nBroken: {len(broken)}")
for t, n in broken[:30]:
    print(f"  {n:4d}  | {t}")

# Top backlinked concepts (graph hubs)
backlinks = Counter(t for t in real_targets if t.casefold() in filenames_cf)
print(f"\nTop 10 hubs (most backlinks):")
for name, n in backlinks.most_common(10):
    print(f"  {n:4d}  -> {name}")

# Leaf folders missing _index.md
missing_index = []
for d in base.rglob("*"):
    if not d.is_dir() or d.name in (".obsidian", "_Templates"):
        continue
    if not (d / "_index.md").exists():
        missing_index.append(d.relative_to(base))
if missing_index:
    print(f"\nFolders missing _index.md ({len(missing_index)}):")
    for f in missing_index:
        print(f"  {f}")
else:
    print(f"\nAll folders have _index.md ✓")
```

**Target:** ≥99% of references resolve. Hub concepts (most backlinks) should be flow
notes, key patterns, and primary integrations — if e.g. `MongoDB` has only 2 backlinks
in a Mongo-heavy codebase, you've under-cross-linked.

## Layer 2: Bulk wikilink rename script

For fixing naming mismatches across the vault:

```python
# fix_wikilinks.py
import re
from pathlib import Path

base = Path("./obsidian")

renames = [
    # (regex pattern, replacement) — operate on wikilink-aware patterns
    (r"\[\[Old Name", "[[New Name"),
    (r"\[\[Wrong Name\]\]", "[[Right Name]]"),
]

fixes = 0
for md in base.rglob("*.md"):
    if "_Templates" in md.parts:
        continue
    text = md.read_text(encoding="utf-8", errors="replace")
    orig = text
    for pat, repl in renames:
        text = re.sub(pat, repl, text)
    if text != orig:
        md.write_text(text, encoding="utf-8")
        fixes += 1

print(f"Files modified: {fixes}")
```

## Layer 3: Obsidian CLI (graph-aware, requires app running)

The official Obsidian CLI ships with **Obsidian 1.12+**. It is a *remote control* of a
running Obsidian instance — it cannot operate on a closed vault.

### Locations

| OS | Binary path |
|---|---|
| Windows | `%LOCALAPPDATA%\Programs\Obsidian\Obsidian.com` |
| macOS | `/Applications/Obsidian.app/Contents/MacOS/Obsidian` (added to PATH via `~/.zprofile`) |
| Linux | varies by install method |

### Enable the CLI

Open Obsidian → **Settings → General** → toggle **"Enable Command line interface"**.

### Launch sequence (Windows PowerShell)

```powershell
$cli = "C:\Users\$env:USERNAME\AppData\Local\Programs\Obsidian\Obsidian.com"

# Launch Obsidian if not running
if (-not (Get-Process -Name "Obsidian*" -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath "$($cli -replace '\.com$','.exe')"
    Start-Sleep -Seconds 4  # wait for CLI bridge to come up
}

# Run CLI commands
& $cli files total
```

### Verification command set

```powershell
$cli = "C:\Users\$env:USERNAME\AppData\Local\Programs\Obsidian\Obsidian.com"

# Structural
& $cli files total                          # total .md count
& $cli folders total                        # total folder count

# Graph health
& $cli orphans                              # files with no incoming links
& $cli orphans total
& $cli deadends                             # files with no outgoing links
& $cli deadends total

# Per-note inspection
& $cli read file="_HOME"                    # render a note
& $cli links file="_HOME"                   # outgoing links
& $cli links file="_HOME" total
& $cli backlinks file="_HOME" total         # incoming links count
& $cli backlinks file="<concept>"           # full backlink list

# Content
& $cli search query="<term>" total          # global search hit count
& $cli search query="<term>"                # full results
& $cli search:context query="<term>"        # with context lines

# Properties (frontmatter)
& $cli properties name=tags counts          # tag distribution
& $cli properties total
```

### Expected healthy results

For a freshly-initialized vault with ~150 concepts:

| Check | Expected |
|---|---|
| `files total` | matches your concept count + indexes + templates + README + _HOME |
| `deadends total` | `0` (every concept should link somewhere) |
| `orphans total` | small number (`_HOME`, `README`, templates only) |
| `backlinks file="<key-concept>" total` | 10+ for hub concepts |

### When NOT to use the CLI

- During the initial scaffold (vault doesn't exist yet)
- In CI / headless environments (no Obsidian app available)
- When the user hasn't enabled the CLI toggle in Settings

For all those cases, fall back to the Python integrity script (Layer 1).

## Final report shape

After verification, report to the user:

```
Vault stats:
  Total markdown files: <N>
  Wikilink references: <N>
  References resolved: <%> (e.g., 99.5%)
  Orphans: <N> (expected: _HOME, README, templates)
  Dead-ends: 0

Top backlinked concepts:
  <N>  backlinks → <Concept A>
  <N>  backlinks → <Concept B>
  ...

To open: Obsidian → "Open folder as vault" → select <path>
```

Hub concepts with the most backlinks tell you what the codebase's center of gravity
is — usually flow notes, key patterns, and primary integrations.
