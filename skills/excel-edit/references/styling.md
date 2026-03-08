# Styling Reference

## Header Style

```python
header_fill = PatternFill(start_color="2B579A", end_color="2B579A", fill_type="solid")
header_font = Font(bold=True, color="FFFFFF", size=11)
center_align = Alignment(horizontal='center', vertical='center')

for cell in ws[1]:
    cell.fill = header_fill
    cell.font = header_font
    cell.alignment = center_align
```

## Borders

```python
thin_border = Border(
    left=Side(style='thin', color='E0E0E0'),
    right=Side(style='thin', color='E0E0E0'),
    top=Side(style='thin', color='E0E0E0'),
    bottom=Side(style='thin', color='E0E0E0')
)

# Apply to range
for row in ws.iter_rows(min_row=1, max_row=10, min_col=1, max_col=5):
    for cell in row:
        cell.border = thin_border
```

## Alternating Row Colors

```python
light_fill = PatternFill(start_color="F5F5F5", fill_type="solid")

for row_num in range(2, ws.max_row + 1):
    if row_num % 2 == 0:
        for cell in ws[row_num]:
            cell.fill = light_fill
```

## Named Styles (Reusable)

```python
header_style = NamedStyle(name="header")
header_style.font = Font(bold=True, color="FFFFFF", size=11)
header_style.fill = PatternFill(start_color="2B579A", fill_type="solid")
header_style.alignment = Alignment(horizontal='center', vertical='center')

wb.add_named_style(header_style)

# Apply
ws['A1'].style = 'header'
```

## Status Colors (Task Tracking)

```python
status_styles = {
    'Done': (PatternFill(start_color="E8F5E9", fill_type="solid"), Font(color="1B5E20", bold=True)),
    'In Progress': (PatternFill(start_color="E3F2FD", fill_type="solid"), Font(color="0D47A1", bold=True)),
    'Planned': (PatternFill(start_color="FFF3E0", fill_type="solid"), Font(color="E65100", bold=True)),
    'Not Started': (PatternFill(start_color="F5F5F5", fill_type="solid"), Font(color="616161")),
}

for row in ws.iter_rows(min_row=2):
    status_cell = row[3]  # Assuming status is column D
    if status_cell.value in status_styles:
        fill, font = status_styles[status_cell.value]
        status_cell.fill = fill
        status_cell.font = font
```
