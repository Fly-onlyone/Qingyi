---
excel_runner: conda run -n Excel python
---

# Qingyi Plugin Settings

## Excel Runner

Command prefix for executing Python scripts in Excel skills.

Examples:

- `conda run -n Excel python` — Conda environment named "Excel" (default)
- `conda run -n myenv python` — Conda with custom env name
- `python` — System Python (openpyxl must be installed)
- `uv run python` — uv
- `uv run --with openpyxl python` — uv with auto-install
- `poetry run python` — Poetry
- `.venv/bin/python` — Virtual environment (Linux/macOS)
- `.venv/Scripts/python` — Virtual environment (Windows)
