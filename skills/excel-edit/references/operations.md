# Worksheet Operations

## Merge Cells

```python
ws.merge_cells('A1:D1')           # By range string
ws.merge_cells(start_row=1, start_column=1, end_row=1, end_column=4)
ws.unmerge_cells('A1:D1')         # Unmerge
```

## Freeze Panes

```python
ws.freeze_panes = 'A2'            # Freeze header row
ws.freeze_panes = 'B1'            # Freeze first column
ws.freeze_panes = 'B2'            # Freeze both
```

## Worksheet Management

```python
ws_new = wb.create_sheet('NewSheet')
ws_new = wb.create_sheet('First', 0)  # At position
wb.copy_worksheet(ws)
del wb['SheetName']
ws.title = 'NewName'
```

## Tab Colors

```python
ws.sheet_properties.tabColor = "2B579A"  # Blue tab

colors = {"Data": "217346", "Summary": "D24726", "Notes": "7C3AED"}
for name, color in colors.items():
    if name in wb.sheetnames:
        wb[name].sheet_properties.tabColor = color
```

## Hyperlinks

```python
# URL hyperlink
ws['A1'].hyperlink = "https://example.com"
ws['A1'].value = "Click here"
ws['A1'].style = "Hyperlink"

# Internal link to another sheet
ws['B1'].hyperlink = "#'Sheet2'!A1"
ws['B1'].value = "Go to Sheet2"
```

## Dashboard Patterns

### KPI Card Layout

```python
def create_kpi_card(ws, start_row, start_col, title, value, color):
    """Create a KPI card with title and large value."""
    end_col = start_col + 2
    ws.merge_cells(start_row=start_row, start_column=start_col,
                   end_row=start_row, end_column=end_col)
    ws.merge_cells(start_row=start_row+1, start_column=start_col,
                   end_row=start_row+1, end_column=end_col)

    title_cell = ws.cell(row=start_row, column=start_col, value=title)
    title_cell.font = Font(size=10, color="666666")
    title_cell.alignment = Alignment(horizontal='center')

    value_cell = ws.cell(row=start_row+1, column=start_col, value=value)
    value_cell.font = Font(size=24, bold=True, color=color)
    value_cell.alignment = Alignment(horizontal='center')
```

### Section Headers

```python
def add_section_header(ws, row, text, col_span=5):
    """Add a styled section header spanning multiple columns."""
    ws.merge_cells(start_row=row, start_column=1, end_row=row, end_column=col_span)
    cell = ws.cell(row=row, column=1, value=text)
    cell.font = Font(size=14, bold=True, color="2B579A")
    cell.alignment = Alignment(horizontal='left', vertical='center')
    ws.row_dimensions[row].height = 30
```
