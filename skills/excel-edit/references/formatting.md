# Conditional Formatting & Data Validation

## Color Scale (Gradient)

```python
from openpyxl.formatting.rule import ColorScaleRule

# Green to red gradient
rule = ColorScaleRule(
    start_type='min', start_color='63BE7B',  # Green
    end_type='max', end_color='F8696B'       # Red
)
ws.conditional_formatting.add('B2:B100', rule)
```

## Formula-Based Formatting

```python
from openpyxl.formatting.rule import FormulaRule

# Highlight cells > 100
red_fill = PatternFill(start_color="FFEBEE", fill_type="solid")
rule = FormulaRule(formula=['B2>100'], fill=red_fill)
ws.conditional_formatting.add('B2:B100', rule)
```

## Text Contains

```python
from openpyxl.formatting.rule import Rule
from openpyxl.styles.differential import DifferentialStyle

green_style = DifferentialStyle(
    fill=PatternFill(start_color="E8F5E9", fill_type="solid"),
    font=Font(color="1B5E20", bold=True)
)
rule = Rule(type='containsText', operator='containsText', text='Done', dxf=green_style)
rule.formula = ['NOT(ISERROR(SEARCH("Done",D2)))']
ws.conditional_formatting.add('D2:D100', rule)
```

## Data Validation (Dropdowns)

```python
from openpyxl.worksheet.datavalidation import DataValidation

dv = DataValidation(
    type="list",
    formula1='"Done,In Progress,Planned,Not Started"',
    showDropDown=False,  # False = show dropdown arrow
    allowBlank=True
)
dv.error = "Please select from the list"
dv.errorTitle = "Invalid Entry"

ws.add_data_validation(dv)
dv.add('D2:D100')
```
