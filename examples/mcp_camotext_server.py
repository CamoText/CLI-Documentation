"""
NOTE: FOR DEMONSTRATION PURPOSES ONLY; DO NOT USE IN PRODUCTION 
WITHOUT THOROUGH TESTING FOR YOUR IMPLEMENTATION

mcp_camotext_server.py

An example local MCP server wrapping CamoTextCLI for text and batched directory anonymization.

This is a single, cross-platform Python script that spins up an MCP server exposing 
CamoTextCLI as a tool. It will work on both Windows and macOS if you have 
Python 3.8+, the MCP SDK installed, and the camo binary on your PATH

--- Requirements ---------------------------------------------------------

1. Python 3.8+
2. Install the MCP Python SDK:
     pip install "mcp[cli]"
3. Ensure the CamoTextCLI binary ("camo") is on your PATH, or set:
     export CAMO_BINARY_PATH="/full/path/to/camo"
4. (Optional) If you want to supply a JSON config (for priorities, hash_length, etc.),
   prepare a file (e.g. `config.json`) and pass its path in the MCP call.

For help on setting PATH, 
see https://github.com/CamoText/CLI-Documentation/blob/main/CamoTextCLI.md#setting-path

See also: https://github.com/modelcontextprotocol/python-sdk for reference
-------------------------------------------------------------------------

--- Usage ----------------------------------------------------------------

# Development / quick test (requires `uv`):
uv init myproject
uv add "mcp[cli]"
cp mcp_camotext_server.py .
uv run mcp dev mcp_camotext_server.py

# Or directly:
python mcp_camotext_server.py

(defaults to listening on http://localhost:8000/mcp):

The tool `anonymize_text` accepts either:
  – text (single-string mode), or
  – input_dir + output_dir (batch mode).

It also supports:
  – --priority       (multi)
  – --revert         (multi; batch only)
  – --ignore-category (multi)
  – --recursive
  – --extensions     (multi)
  – --workers
  – --hash-length
  – --config         (JSON file for advanced settings)
  - key dumping and key-directory management, entity listing
-------------------------------------------------------------------------
"""

import os
import shlex
import subprocess
import tempfile

from mcp.server.fastmcp import FastMCP, Context

# ──────────────────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────────────────

CAMO_BINARY_PATH = os.getenv("CAMO_BINARY_PATH", "camo")

mcp = FastMCP(
    name="CamoTextCLI",
    description="Expose CamoTextCLI features via MCP, including key management.",
)

# ──────────────────────────────────────────────────────────────────────────
# Tool: anonymize_text
# ──────────────────────────────────────────────────────────────────────────

@mcp.tool()
def anonymize_text(
    text: str = None,
    input_dir: str = None,
    output_dir: str = None,
    # Anonymization:
    priority: list[str] = None,
    revert: list[str] = None,
    ignore_category: list[str] = None,
    hash_length: int = None,
    config_path: str = None,
    # Key management:
    dump_key: str = None,     # --dump-key [FILE]
    key_dir: str = None,      # --key-dir [DIR]
    # Batch processing:
    recursive: bool = False,
    extensions: list[str] = None,
    workers: int = None,
    ctx: Context = None,
) -> str:
    """
    Runs CamoTextCLI with the combination of provided arguments.
    Returns the CLI's stdout (progress + anonymized text).
    """

    # 1) Build base command depending on mode
    if input_dir:
        if not output_dir:
            raise ValueError("`output_dir` is required when using `input_dir`.")
        cmd = [CAMO_BINARY_PATH, "--input-dir", input_dir, "--output-dir", output_dir]
    else:
        if text is None:
            raise ValueError("Provide either `text` or `input_dir`.")
        tmp = tempfile.NamedTemporaryFile(mode="w+", encoding="utf-8", delete=False, suffix=".txt")
        try:
            tmp.write(text)
            tmp.flush()
            tmp_path = tmp.name
        finally:
            tmp.close()
        cmd = [CAMO_BINARY_PATH, "--input", tmp_path]

    # 2) Add anonymization options
    for p in (priority or []):
        cmd += ["--priority", p]
    for r in (revert or []):
        if not input_dir:
            raise ValueError("`revert` requires batch mode (`input_dir`).")
        cmd += ["--revert", r]
    for cat in (ignore_category or []):
        cmd += ["--ignore-category", cat]
    if hash_length is not None:
        cmd += ["--hash-length", str(hash_length)]
    if config_path:
        cmd += ["--config", config_path]

    # 3) Add key management flags
    if dump_key:
        cmd += ["--dump-key", dump_key]
    if key_dir:
        cmd += ["--key-dir", key_dir]

    # 4) Batch-only tuning
    if input_dir:
        if recursive:
            cmd.append("--recursive")
        for ext in (extensions or []):
            cmd += ["--extensions", ext]
        if workers is not None:
            cmd += ["--workers", str(workers)]

    # 5) Log and execute
    if ctx:
        ctx.info("Running: " + " ".join(shlex.quote(c) for c in cmd))

    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, check=True)
        if ctx:
            ctx.debug("Completed successfully.")
        return proc.stdout

    except subprocess.CalledProcessError as e:
        err = (e.stderr or e.stdout).strip()
        if ctx:
            ctx.error("Error: " + err)
        raise RuntimeError("CamoTextCLI failed: " + err)

    finally:
        if 'tmp_path' in locals():
            try: os.unlink(tmp_path)
            except OSError: pass


# ──────────────────────────────────────────────────────────────────────────
# Tool: list_entities
# ──────────────────────────────────────────────────────────────────────────

@mcp.tool()
def list_entities(ctx: Context = None) -> str:
    """
    Invoke `camo --list-entities` to see which entity types the bundled NER detects.
    """
    cmd = [CAMO_BINARY_PATH, "--list-entities"]
    if ctx:
        ctx.info("Running: " + " ".join(shlex.quote(c) for c in cmd))
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return proc.stdout
    except subprocess.CalledProcessError as e:
        err = (e.stderr or e.stdout).strip()
        if ctx:
            ctx.error("Error: " + err)
        raise RuntimeError("CamoTextCLI failed: " + err)


# ──────────────────────────────────────────────────────────────────────────
# Server Entrypoint
# ──────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    mcp.run(
        transport="streamable_http",  # or "sse"
        mount_path="/mcp",
    )
