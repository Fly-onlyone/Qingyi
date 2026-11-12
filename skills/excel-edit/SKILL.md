---
name: excel-edit
description: >-
  This skill should be used when the user wants to WRITE, FORMAT, STYLE, or DESIGN Excel files.

  FILE-BASED TRIGGERS (highest priority):
  - Any mention of ".xlsx" or ".xls" files WITH edit/create intent
  - "the excel file", "this excel" + modification context

  ACTION TRIGGERS:
  - EDIT: "edit excel", "modify spreadsheet", "update cells", "change values"
  - CREATE: "create excel", "new spreadsheet", "make xlsx", "build a table"
  - FORMAT: "format excel", "style cells", "add colors", "professional formatting",
    "beautify spreadsheet", "eye-catching", "modern look"
  - STRUCTURE: "add worksheet", "merge cells", "add chart", "pivot table",
    "add rows", "delete columns", "insert data", "freeze panes"
  - ORGANIZE: "reorganize excel", "restructure spreadsheet", "clean up excel",
    "sort spreadsheet", "rearrange columns"

  NATURAL LANGUAGE PATTERNS:
  - "make the excel" + improvement verb
  - "add" / "change" / "update" + excel/spreadsheet context
  - File path ending in .xlsx or .xls + modification request
---

# Excel Edit & Design with Python openpyxl

Write, format, style, and design professional Excel files using Python openpyxl.

## Environment

**Before running any script**, determine the Python runner (`excel_runner`). It comes from the plugin's
`excel_runner` option:

`excel_runner` = `${user_config.excel_runner}`

If that value is empty or still starts with `${` (the option is not set), use `python`.

Run command: `<excel_runner> <script_path>`

## Workflow

1. **Create Python script** at `scripts/excel/` from project root
2. **Execute script**: `<excel_runner> scripts/excel/<script_name>.py`
3. **Keep scripts** for reference and reusability

## Common Imports

```python
from openpyxl import Workbook, load_workbook
from openpyxl.styles import Font, PatternFill, Border, Side, Alignment
from openpyxl.utils import get_column_letter
from pathlib import Path
```

Import additional modules as needed: `NamedStyle`, `DataValidation`, `ColorScaleRule`, `FormulaRule`,
`DifferentialStyle`, `Rule`.

## Writing Operations

```python
ws['A1'] = 'Header'  # Single cell
ws.append(['Col1', 'Col2', 'Col3'])  # Append row
wb.save(path)  # Save
```

## Column & Row Sizing

```python
ws.column_dimensions['A'].width = 15
ws.row_dimensions[1].height = 25

# Multiple columns
for i, width in enumerate([5, 12, 35, 10], 1):
    ws.column_dimensions[get_column_letter(i)].width = width
```

## Design Principles

1. **White backgrounds** -- Always use white (#FFFFFF) for data cells
2. **3-4 colors max** -- Primary + 2-3 accent colors
3. **High contrast** -- Dark text on light backgrounds
4. **Consistent spacing** -- Uniform column widths where logical
5. **Visual hierarchy** -- Headers clearly distinguished from data
6. **Minimal borders** -- Use sparingly, prefer whitespace

## MS Office 2023 Color Palette

```python
# Primary (headers, accents)
BLUE_PRIMARY = "2B579A"  # Headers, titles
GREEN_PRIMARY = "217346"  # Positive/success
ORANGE_PRIMARY = "D24726"  # Warnings/highlights

# Neutral (backgrounds, borders)
WHITE = "FFFFFF"  # Cell backgrounds
LIGHT_GRAY = "F5F5F5"  # Alternate row shading
MEDIUM_GRAY = "E0E0E0"  # Borders, dividers
DARK_GRAY = "333333"  # Primary text

# Status (semantic)
SUCCESS_BG, SUCCESS_TEXT = "E8F5E9", "1B5E20"
WARNING_BG, WARNING_TEXT = "FFF3E0", "E65100"
ERROR_BG, ERROR_TEXT = "FFEBEE", "B71C1C"
INFO_BG, INFO_TEXT = "E3F2FD", "0D47A1"
```

## Font Sizes

```python
FONT_TITLE = 16  # Main title
FONT_HEADER = 11  # Column headers (bold)
FONT_DATA = 10  # Regular data cells
FONT_SMALL = 9  # Notes, footnotes
```

## Reference Files

For detailed API patterns, see:

- [styling.md](references/styling.md) -- Headers, borders, alternating rows, named styles, status colors
- [formatting.md](references/formatting.md) -- Conditional formatting, color scales, data validation
- [operations.md](references/operations.md) -- Merge, freeze, worksheets, hyperlinks, tabs, dashboard patterns
