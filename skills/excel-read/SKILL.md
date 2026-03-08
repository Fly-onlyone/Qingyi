---
name: excel-read
description: >-
  This skill should be used when the user wants to VIEW, ANALYZE, or EXTRACT data from Excel files.

  FILE-BASED TRIGGERS (highest priority):
  - Any mention of ".xlsx" or ".xls" files WITH read intent
  - "the excel file", "this excel", "my spreadsheet" + viewing context

  ACTION TRIGGERS:
  - "read excel", "open xlsx", "view spreadsheet"
  - "show excel data", "what's in the excel", "display spreadsheet"
  - "check the excel", "look at the spreadsheet"
  - "analyze spreadsheet", "extract data from excel"
  - "count rows", "find values", "list worksheets"
  - "summarize the excel", "what sheets are there"
  - "parse excel", "import from excel", "convert excel to"

  NATURAL LANGUAGE PATTERNS:
  - "show me" + excel/spreadsheet
  - "what does the excel contain"
  - "read" + file path ending in .xlsx or .xls
---

# Excel Read Operations with Python openpyxl

Read, analyze, and extract data from Excel files using Python openpyxl.

## Environment

The conda "Excel" environment has openpyxl 3.1.5 installed:

```bash
conda run -n Excel python <script_path>
```

## Workflow

1. **Create Python script** at `scripts/excel/` from project root
2. **Execute with conda**: `conda run -n Excel python scripts/excel/<script_name>.py`
3. **Keep scripts** for reference and reusability

## Output Formatting

When displaying Excel data to the user, format as markdown tables:

```markdown
| Column A | Column B | Column C |
|----------|----------|----------|
| value1   | value2   | value3   |
```

For sparse data with many empty cells, show only populated rows/columns.

## Standard Imports

```python
from openpyxl import load_workbook
from openpyxl.utils import get_column_letter
from pathlib import Path
```

## Reading Operations

### Load Workbook

```python
wb = load_workbook(path, data_only=True)  # data_only=True for formula results
ws = wb.active                             # Active sheet
ws = wb['SheetName']                       # Named sheet
```

### Read Single Cell

```python
value = ws['A1'].value
value = ws.cell(row=1, column=1).value
```

### Read Range

```python
# Specific range
for row in ws['A1:C10']:
    for cell in row:
        print(cell.value)

# All data as 2D list
data = [[cell.value for cell in row] for row in ws.iter_rows()]

# With bounds
data = [[cell.value for cell in row]
        for row in ws.iter_rows(min_row=1, max_row=10, min_col=1, max_col=5)]
```

### Read Column/Row

```python
col_values = [cell.value for cell in ws['A']]    # Column A
row_values = [cell.value for cell in ws[1]]       # Row 1
```

### Iterate Rows with Values Only

```python
for row in ws.iter_rows(values_only=True):
    print(row)  # tuple of values
```

### Get Sheet Dimensions

```python
print(f"Rows: {ws.max_row}, Columns: {ws.max_column}")
print(f"Data range: {ws.dimensions}")
```

### List All Worksheets

```python
for sheet_name in wb.sheetnames:
    print(sheet_name)
```

### Find Cells by Value

```python
for row in ws.iter_rows():
    for cell in row:
        if cell.value == "SearchTerm":
            print(f"Found at {cell.coordinate}")
```

### Get Merged Cell Ranges

```python
for merged_range in ws.merged_cells.ranges:
    print(merged_range)
```

## Analysis Helpers

```python
# Count non-empty cells
count = sum(1 for row in ws.iter_rows() for cell in row if cell.value is not None)

# Unique values in column
unique = set(cell.value for cell in ws['A'] if cell.value is not None)

# Summary statistics
headers = [cell.value for cell in ws[1]]
print(f"Columns: {len(headers)}, Data rows: {ws.max_row - 1}, Headers: {headers}")
```

## Script Template

```python
from openpyxl import load_workbook
from pathlib import Path

def main():
    path = Path(r"C:\path\to\file.xlsx")
    wb = load_workbook(path, data_only=True)

    print(f"Sheets: {wb.sheetnames}")

    for sheet_name in wb.sheetnames:
        ws = wb[sheet_name]
        print(f"\n=== {sheet_name} ===")
        print(f"Dimensions: {ws.dimensions}")

        for i, row in enumerate(ws.iter_rows(values_only=True)):
            if i >= 10:
                print("...")
                break
            print(row)

if __name__ == "__main__":
    main()
```
