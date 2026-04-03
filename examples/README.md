# CamoText MCP Server Example

This directory contains `mcp_camotext_server.py`, an example Model Context
Protocol server that wraps the local CamoText CLI described in
`../CamoTextCLI.md`.

The example is aligned to the CLI features documented for CamoText CLI v1.2.0
and exposes these MCP tools:

- `anonymize_text` for raw text, single-file, and batch directory anonymization
- `list_entities` for file, directory, or raw-text entity inspection
- `revert_terms` for selective restoration of terms in anonymized directories
- `deanonymize_directory` for full directory de-anonymization
- `show_cli_help` to return the exact help text from the installed local CLI

## Why use an MCP server instead of calling `camo` directly?

Direct CLI invocation is still the simplest choice for shell scripts, CI jobs,
and one-off local commands. The MCP layer is useful when you want CamoText to
be consumed by an AI assistant, editor integration, or any client that speaks
the Model Context Protocol.

Benefits of the MCP wrapper include:

- **Tool-shaped API for agents**: an MCP client can call named tools with
  structured arguments instead of assembling shell commands manually.
- **Safer argument validation**: the example server rejects invalid option
  combinations before invoking `camo`, which reduces avoidable subprocess
  failures.
- **Reusable integration surface**: editor plugins, local assistants, and other
  MCP-aware clients can all use the same server contract.
- **Better observability in MCP clients**: command execution and failures can be
  surfaced through MCP tool logs rather than requiring shell access.
- **Less command-construction overhead**: callers do not need to manage quoting,
  repeatable flags, or per-mode command shape themselves.

Tradeoff:

- The MCP server is an extra Python process on top of the CamoText executable,
  so it adds a small amount of startup and translation overhead compared with
  invoking `camo` directly.

## Setup

1. Install the CamoText CLI and confirm it is available:

   ```bash
   camo --help
   ```

2. Install Python 3.8+ and the MCP SDK:

   ```bash
   pip install "mcp[cli]"
   ```

3. If the executable is not on your `PATH`, set the environment variable used
   by the example server:

   ```bash
   export CAMO_BINARY_PATH="/full/path/to/camo"
   ```

4. Start the MCP server:

   ```bash
   uv run mcp dev examples/mcp_camotext_server.py
   ```

   or:

   ```bash
   python3 examples/mcp_camotext_server.py
   ```

## Example MCP usage

```python
anonymize_text(
    text="John Doe works at Acme Corp and uses john@acme.com",
    redact=True,
)

anonymize_text(
    input_path="report.docx",
    output_path="report_anonymized.docx",
    preserve_docx_formatting=True,
    dump_key=True,
)

anonymize_text(
    input_dir="./documents",
    output_dir="./anonymized",
    recursive=True,
    workers=4,
    ignore_category=["organization", "location"],
)

list_entities(input_path="report.pdf")
revert_terms(input_dir="./anonymized", terms=["John Doe"], key_dir="./keys")
deanonymize_directory(input_dir="./anonymized", output_dir="./cleaned")
```

## Notes

- The example server is intentionally lightweight and shells out to the local
  CamoText executable instead of re-implementing anonymization logic in Python.
- Raw text is passed directly to `camo --input`, which avoids temporary-file
  overhead but means callers should use `input_path` when they want explicit
  file processing semantics.
- Full server execution was not verified in this environment because the `mcp`
  package and `camo` executable were not installed here; syntax validation was
  completed with `python3 -m py_compile`.
