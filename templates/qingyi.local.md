---
excel_runner: python
log_paths: []
---

# Qingyi Plugin Settings

## Log Paths

Production application log locations. The debug-code skill checks these automatically during **production scope** debugging — no need to mention them in your prompt. Development scope always checks logs from the project root.

Examples:

- `["C:/Server/logs"]` — Absolute path to production server logs
- `["C:/Server/logs", "C:/Server/plugins/MyPlugin/logs"]` — Multiple production paths
- `["/var/log/myapp/", "/opt/myapp/logs/"]` — Linux server paths

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
