# CamoTextCLI Documentation

Documentation for the command-line interface (CLI) implementation of CamoText.

## Repository Contents

- `CamoTextCLI.md` - full CLI reference and usage guide
- `examples/mcp_camotext_server.py` - MCP server integration example
- `examples/camotext_excel_scope_example.ps1` - native PowerShell Excel scope anonymization example

## New Example: Excel Column/Row Scope Anonymization (PowerShell)

The `examples/camotext_excel_scope_example.ps1` script demonstrates local, native integration with CamoTextCLI that:

- accepts a single `.xlsx` file
- anonymizes only one selected Excel **column** or one selected **row**
- writes output to a specified folder (`-OutputFolder`) or, if omitted, creates a new output folder on Desktop

### Usage

```powershell
# Column mode (letter)
powershell -ExecutionPolicy Bypass -File .\examples\camotext_excel_scope_example.ps1 `
  -InputXlsx "C:\data\sensitive.xlsx" `
  -SheetName "Sheet1" `
  -Column "C" `
  -OutputFolder "C:\data\anonymized"

# Row mode (index)
powershell -ExecutionPolicy Bypass -File .\examples\camotext_excel_scope_example.ps1 `
  -InputXlsx "C:\data\sensitive.xlsx" `
  -Row 5
```

### Notes

- This example uses native Excel COM automation, so it is Windows-focused and requires local Microsoft Excel installation.
- The script intentionally skips formula and non-text cells to reduce accidental workbook behavior changes.
- A demonstration-only disclaimer is included at the top of the script.
