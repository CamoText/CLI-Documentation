"""
NOTE: FOR DEMONSTRATION PURPOSES ONLY. REVIEW AND TEST THIS EXAMPLE BEFORE
USING IT IN PRODUCTION.

Example MCP server for the CamoText CLI documented in `CamoTextCLI.md`
(currently aligned to the v1.2.0 feature set).

Setup
-----
1. Install CamoText CLI and verify the executable works:
     camo --help
2. Install Python 3.8+ and the MCP Python SDK:
     pip install "mcp[cli]"
3. If `camo` is not on PATH, point the server at the executable:
     export CAMO_BINARY_PATH="/full/path/to/camo"
4. Start the example server:
     uv run mcp dev examples/mcp_camotext_server.py
   or:
     python3 examples/mcp_camotext_server.py

Example MCP usage
-----------------
# Raw text anonymization
anonymize_text(
    text="John Doe works at Acme Corp and uses john@acme.com",
    redact=True,
)

# Single-file processing with key export
anonymize_text(
    input_path="report.docx",
    output_path="report_anonymized.docx",
    preserve_docx_formatting=True,
    dump_key=True,
)

# Batch processing with workers and category exclusions
anonymize_text(
    input_dir="./documents",
    output_dir="./anonymized",
    recursive=True,
    workers=4,
    ignore_category=["organization", "location"],
)

# Entity listing for a file or raw text string
list_entities(input_path="report.pdf")
list_entities(text="John Doe works at Acme Corp")

# Selective term reversion and full de-anonymization
revert_terms(input_dir="./anonymized", terms=["John Doe"], key_dir="./keys")
deanonymize_directory(input_dir="./anonymized", output_dir="./cleaned")
"""

from __future__ import annotations

import os
import shlex
import subprocess
from typing import List, Optional, Sequence, Tuple

from mcp.server.fastmcp import Context, FastMCP


CAMO_BINARY_PATH = os.getenv("CAMO_BINARY_PATH", "camo")
TRACK_CHANGES_CHOICES = ("accept", "reject")

mcp = FastMCP(
    name="CamoTextCLI",
    description=(
        "Expose CamoText CLI via MCP for anonymization, entity listing, "
        "term reversion, and directory de-anonymization."
    ),
)


def _quote_command(cmd: Sequence[str]) -> str:
    return " ".join(shlex.quote(part) for part in cmd)


def _append_repeatable_flag(
    cmd: List[str],
    flag: str,
    values: Optional[Sequence[str]],
) -> None:
    for value in values or []:
        if value:
            cmd.extend([flag, value])


def _append_extensions(cmd: List[str], extensions: Optional[Sequence[str]]) -> None:
    cleaned = [extension for extension in (extensions or []) if extension]
    if cleaned:
        cmd.extend(["--extensions", *cleaned])


def _append_optional_value_flag(
    cmd: List[str],
    flag: str,
    enabled: bool,
    value: Optional[str],
) -> None:
    if value is not None:
        cmd.extend([flag, value])
    elif enabled:
        cmd.append(flag)


def _require_positive_int(name: str, value: Optional[int]) -> None:
    if value is not None and value < 1:
        raise ValueError(f"`{name}` must be >= 1 when provided.")


def _validate_docx_options(
    preserve_docx_formatting: bool,
    docx_track_changes: Optional[str],
) -> None:
    if docx_track_changes is None:
        return

    if docx_track_changes not in TRACK_CHANGES_CHOICES:
        allowed = ", ".join(TRACK_CHANGES_CHOICES)
        raise ValueError(f"`docx_track_changes` must be one of: {allowed}.")

    if not preserve_docx_formatting:
        raise ValueError(
            "`docx_track_changes` requires `preserve_docx_formatting=True`."
        )


def _build_input_command(
    text: Optional[str],
    input_path: Optional[str],
    input_dir: Optional[str],
) -> Tuple[List[str], str]:
    provided = [
        ("text", text is not None),
        ("input_path", input_path is not None),
        ("input_dir", input_dir is not None),
    ]
    selected = [name for name, is_set in provided if is_set]
    if len(selected) != 1:
        raise ValueError(
            "Provide exactly one of `text`, `input_path`, or `input_dir`."
        )

    if text is not None:
        return [CAMO_BINARY_PATH, "--input", text], "text"
    if input_path is not None:
        return [CAMO_BINARY_PATH, "--input", input_path], "file"
    return [CAMO_BINARY_PATH, "--input-dir", input_dir], "directory"


def _run_camo(
    cmd: Sequence[str],
    ctx: Optional[Context],
    success_message: str,
) -> str:
    if ctx:
        ctx.info("Running: " + _quote_command(cmd))

    try:
        proc = subprocess.run(
            list(cmd),
            capture_output=True,
            stdin=subprocess.DEVNULL,
            text=True,
            check=False,
        )
    except FileNotFoundError as exc:
        raise RuntimeError(
            "Could not find the CamoText CLI executable. Install `camo` and "
            "ensure it is on PATH, or set CAMO_BINARY_PATH."
        ) from exc

    stdout = proc.stdout.strip()
    stderr = proc.stderr.strip()

    if proc.returncode != 0:
        details = "\n".join(part for part in (stderr, stdout) if part)
        if ctx and details:
            ctx.error(details)
        raise RuntimeError(
            "CamoText CLI failed with exit code "
            f"{proc.returncode}: {details or 'no additional error output'}"
        )

    if ctx:
        ctx.debug("Completed successfully.")
        if stderr:
            ctx.debug("CamoText CLI stderr: " + stderr)

    if stdout and stderr:
        return stdout + "\n\n[stderr]\n" + stderr
    if stdout:
        return stdout
    if stderr:
        return stderr
    return success_message


@mcp.tool()
def anonymize_text(
    text: Optional[str] = None,
    input_path: Optional[str] = None,
    output_path: Optional[str] = None,
    input_dir: Optional[str] = None,
    output_dir: Optional[str] = None,
    priority: Optional[List[str]] = None,
    ignore_category: Optional[List[str]] = None,
    hash_length: Optional[int] = None,
    config_path: Optional[str] = None,
    redact: bool = False,
    dump_key: bool = False,
    dump_key_path: Optional[str] = None,
    key_dir: Optional[str] = None,
    use_output_dir_as_key_dir: bool = False,
    recursive: bool = False,
    extensions: Optional[List[str]] = None,
    workers: Optional[int] = None,
    preserve_docx_formatting: bool = False,
    docx_track_changes: Optional[str] = None,
    preserve_xlsx_formatting: bool = False,
    ctx: Optional[Context] = None,
) -> str:
    """
    Run CamoText anonymization in one of three modes:
    - raw text: `text=...`
    - single file: `input_path=...`
    - batch directory: `input_dir=...` plus `output_dir=...`

    This wrapper tracks the current CamoText CLI surface, including redaction,
    Office formatting preservation, key export, and batch worker options.
    """

    _require_positive_int("hash_length", hash_length)
    _require_positive_int("workers", workers)
    _validate_docx_options(preserve_docx_formatting, docx_track_changes)

    cmd, mode = _build_input_command(text=text, input_path=input_path, input_dir=input_dir)

    if mode == "directory":
        if output_path is not None:
            raise ValueError("`output_path` is only valid with `input_path` or `text`.")
        if not output_dir:
            raise ValueError("`output_dir` is required when using `input_dir`.")
        cmd.extend(["--output-dir", output_dir])
    else:
        if output_dir is not None:
            raise ValueError("`output_dir` is only valid with `input_dir`.")
        if recursive:
            raise ValueError("`recursive` is only valid with `input_dir`.")
        if extensions:
            raise ValueError("`extensions` are only valid with `input_dir`.")
        if workers is not None:
            raise ValueError("`workers` is only valid with `input_dir`.")
        if output_path:
            cmd.extend(["--output", output_path])

    _append_repeatable_flag(cmd, "--priority", priority)
    _append_repeatable_flag(cmd, "--ignore-category", ignore_category)

    if hash_length is not None:
        cmd.extend(["--hash-length", str(hash_length)])
    if config_path:
        cmd.extend(["--config", config_path])
    if redact:
        cmd.append("--redact")

    _append_optional_value_flag(
        cmd,
        "--dump-key",
        enabled=dump_key or dump_key_path is not None,
        value=dump_key_path,
    )
    _append_optional_value_flag(
        cmd,
        "--key-dir",
        enabled=use_output_dir_as_key_dir or key_dir is not None,
        value=key_dir,
    )

    if preserve_docx_formatting:
        cmd.append("--preserve-docx-formatting")
    if docx_track_changes:
        cmd.extend(["--docx-track-changes", docx_track_changes])
    if preserve_xlsx_formatting:
        cmd.append("--preserve-xlsx-formatting")

    if mode == "directory":
        if recursive:
            cmd.append("--recursive")
        _append_extensions(cmd, extensions)
        if workers is not None:
            cmd.extend(["--workers", str(workers)])

    return _run_camo(
        cmd,
        ctx,
        success_message="CamoText anonymization completed successfully.",
    )


@mcp.tool()
def list_entities(
    text: Optional[str] = None,
    input_path: Optional[str] = None,
    input_dir: Optional[str] = None,
    ctx: Optional[Context] = None,
) -> str:
    """
    List the entity types detected by CamoText for a raw text string, single
    file, or directory.
    """

    cmd, _mode = _build_input_command(text=text, input_path=input_path, input_dir=input_dir)
    cmd.append("--list-entities")
    return _run_camo(
        cmd,
        ctx,
        success_message="Entity listing completed successfully.",
    )


@mcp.tool()
def revert_terms(
    input_dir: str,
    terms: List[str],
    key_dir: Optional[str] = None,
    recursive: bool = False,
    extensions: Optional[List[str]] = None,
    workers: Optional[int] = None,
    ctx: Optional[Context] = None,
) -> str:
    """
    Selectively restore matching original terms in a previously anonymized
    directory using CamoText's `--revert` workflow.
    """

    if not input_dir:
        raise ValueError("`input_dir` is required.")
    if not terms:
        raise ValueError("Provide at least one term in `terms`.")

    _require_positive_int("workers", workers)

    cmd = [CAMO_BINARY_PATH, "--input-dir", input_dir]
    _append_repeatable_flag(cmd, "--revert", terms)

    if key_dir:
        cmd.extend(["--key-dir", key_dir])
    if recursive:
        cmd.append("--recursive")
    _append_extensions(cmd, extensions)
    if workers is not None:
        cmd.extend(["--workers", str(workers)])

    return _run_camo(
        cmd,
        ctx,
        success_message="CamoText term reversion completed successfully.",
    )


@mcp.tool()
def deanonymize_directory(
    input_dir: str,
    output_dir: Optional[str] = None,
    recursive: bool = False,
    extensions: Optional[List[str]] = None,
    workers: Optional[int] = None,
    ctx: Optional[Context] = None,
) -> str:
    """
    Fully restore anonymized files in a directory using discovered key files.
    """

    if not input_dir:
        raise ValueError("`input_dir` is required.")

    _require_positive_int("workers", workers)

    cmd = [CAMO_BINARY_PATH, "--input-dir", input_dir, "--deanon"]
    if output_dir:
        cmd.extend(["--output-dir", output_dir])
    if recursive:
        cmd.append("--recursive")
    _append_extensions(cmd, extensions)
    if workers is not None:
        cmd.extend(["--workers", str(workers)])

    return _run_camo(
        cmd,
        ctx,
        success_message="CamoText de-anonymization completed successfully.",
    )


@mcp.tool()
def show_cli_help(ctx: Optional[Context] = None) -> str:
    """
    Return the installed CamoText CLI help text. This is useful when you want
    the server to expose the exact flags available in the local executable.
    """

    return _run_camo(
        [CAMO_BINARY_PATH, "--help"],
        ctx,
        success_message="Displayed CamoText CLI help.",
    )


if __name__ == "__main__":
    mcp.run(
        transport="streamable_http",
        mount_path="/mcp",
    )
