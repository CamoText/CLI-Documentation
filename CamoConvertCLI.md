# CamoConvert CLI Guide

Current CLI version: 1.0.0.

CamoConvert CLI is the headless command-line mode for CamoConvert. It converts supported image, video, audio, and document files locally from a terminal, script, scheduled job, folder watcher, or automation agent.

The CLI uses the same bundled local conversion stack as the desktop app. It does not require cloud APIs, MCP servers, runtime network services, host-installed dependencies, or external conversion applications.

## Commands

Installed CamoConvert CLI is exposed through this command:

```text
camoconvert
```

The command invokes the bundled CLI implementation, accepts the arguments documented below, and returns the exit codes documented below.

On Windows, the installer creates a `camoconvert.cmd` wrapper in the install folder's `cli` subfolder. The wrapper calls the bundled `camoconvert-cli.exe`. On macOS, the `.pkg` distribution should expose the same `camoconvert` command with the same arguments and behavior.

## Installation And PATH

### Windows

The Windows installer includes an option named:

```text
Add camoconvert command line tool to PATH
```

When selected, the installer adds the CamoConvert `cli` subfolder to the current user's PATH so `camoconvert` is available from new Command Prompt, PowerShell, Windows Terminal, and automation sessions.

The wrapper lives in a separate `cli` subfolder so Windows does not resolve `camoconvert` to the GUI executable `CamoConvert.exe` before the command wrapper.

If a terminal was already open during installation, close it and open a new terminal before testing PATH.

Check installation:

```powershell
camoconvert --version
```

Expected output:

```text
CamoConvert 1.0.0
```

### macOS

The macOS CLI mode is expected to be distributed through a `.pkg` installer and should expose the same command name:

```zsh
camoconvert --version
```

The macOS package should make `camoconvert` available on PATH and route it to the bundled CamoConvert CLI implementation. It should not rely on Homebrew, system installs, host-installed document tools, online services, or user-installed Python packages at runtime.

If a shell was already open during installation, open a new shell before testing PATH.

## Requirements

Runtime requirements for installed builds:

- A completed CamoConvert installation.
- Local files readable by the current user.
- Write permission to the selected output file or output directory.
- No network connection required.
- No host-installed Microsoft Word, Office automation, LibreOffice, Apple Events automation, or cloud conversion service required.

Development requirements when running from source:

- Python environment with dependencies from `requirements.txt`.
- Use `python -m camoconvert.cli` for direct CLI testing from source.

Development command:

```powershell
python -m camoconvert.cli --help
```

## Synopsis

```text
camoconvert [-h] [-i FILE | --input-dir DIR] [-o FILE]
            [--output-dir DIR] [-f EXT] [--recursive]
            [--extensions EXTS] [--workers N]
            [--on-conflict {fail,overwrite,rename}] [--overwrite]
            [--dry-run] [--quiet] [--json] [--list-formats] [--version]
```

## Input Modes

CamoConvert CLI has two input modes:

- Single-file mode: use `--input FILE` or `-i FILE`.
- Batch directory mode: use `--input-dir DIR`.

These modes are mutually exclusive. Use one or the other in each command.

## Output Rules

Single-file mode can infer the output format from the output filename:

```powershell
camoconvert -i .\photo.heic -o .\photo.jpg
```

Single-file mode can also use `--format` and write into an output directory:

```powershell
camoconvert -i .\clip.mp4 --format mp3 --output-dir .\audio
```

Batch mode requires `--format` because each input needs a consistent target format:

```powershell
camoconvert --input-dir .\incoming --format webp
```

If `--output-dir` is omitted, converted outputs are written beside their input files.

## Options

| Option | Description |
| --- | --- |
| `-h`, `--help` | Show help text and exit. |
| `-i FILE`, `--input FILE` | Convert one input file. Mutually exclusive with `--input-dir`. |
| `--input-dir DIR` | Batch-convert files in a directory. Mutually exclusive with `--input`. |
| `-o FILE`, `--output FILE` | Output file for single-file conversion. The extension is used as the target format when `--format` is omitted. |
| `--output-dir DIR` | Directory for converted outputs. In recursive batch mode, relative subfolders are preserved under this directory. |
| `-f EXT`, `--format EXT` | Target output format, such as `jpg`, `png`, `webp`, `mp4`, `mp3`, `aac`, `md`, `html`, or `txt`. The leading dot is optional. Required with `--input-dir`. |
| `--recursive` | Include nested folders during batch directory conversion. |
| `--extensions EXTS` | Comma-separated input extension filter for batch mode, such as `jpg,png,heic`. |
| `--workers N` | Parallel worker count for batch conversions. Default: `1`. Must be `1` or greater. |
| `--on-conflict fail\|overwrite\|rename` | Output conflict behavior. Default: `fail`. |
| `--overwrite` | Shortcut for `--on-conflict overwrite`. |
| `--dry-run` | Print planned conversions without writing output files. |
| `--quiet` | Suppress human-readable progress and summary output. |
| `--json` | Print machine-readable JSON results to STDOUT. |
| `--list-formats` | List supported input and output formats. |
| `--version` | Print the bundled CamoConvert version and exit. |

## Supported Formats

Check the installed build at any time:

```powershell
camoconvert --list-formats
camoconvert --list-formats --json
```

Supported inputs:

```text
.aac, .avi, .avif, .bmp, .docx, .flac, .gif, .heic, .heif,
.htm, .html, .icns, .ico, .jfif, .jpe, .jpeg, .jpg, .m4a,
.m4v, .md, .mkv, .mov, .mp3, .mp4, .ogg, .pdf, .png,
.pptx, .tif, .tiff, .txt, .wav, .webm, .webp, .wmv, .xls,
.xlsx
```

Output formats by category:

| Category | Outputs |
| --- | --- |
| Image | `.jpg`, `.png`, `.webp`, `.heic`, `.ico`, `.icns`, `.gif`, `.bmp`, `.tiff`, `.avif` |
| Video | `.mp4`, `.webm`, `.mov`, `.mkv`, `.avi` |
| Audio | `.mp3`, `.m4a`, `.aac`, `.wav`, `.flac`, `.ogg` |
| Document | `.md`, `.html`, `.txt` |

Video inputs can be converted to video outputs or audio-only outputs. Audio inputs can be converted to audio outputs. Document conversion extracts text content to Markdown, HTML, or Plain Text rather than recreating the source layout pixel-for-pixel.

## Examples

### Show Help And Version

```powershell
camoconvert --help
camoconvert --version
```

```zsh
camoconvert --help
camoconvert --version
```

### Convert One Image

```powershell
camoconvert -i .\photo.heic -o .\photo.jpg
```

```zsh
camoconvert -i ./photo.heic -o ./photo.jpg
```

### Convert One File Into A Directory

```powershell
camoconvert -i .\clip.mp4 --format mp3 --output-dir .\audio
```

```zsh
camoconvert -i ./clip.mp4 --format mp3 --output-dir ./audio
```

### Convert A Document To Markdown

```powershell
camoconvert -i .\report.pdf -o .\report.md
```

```zsh
camoconvert -i ./report.pdf -o ./report.md
```

### Convert A Folder

```powershell
camoconvert --input-dir .\incoming --output-dir .\converted --format webp
```

```zsh
camoconvert --input-dir ./incoming --output-dir ./converted --format webp
```

### Convert A Folder Recursively

```powershell
camoconvert --input-dir .\incoming --output-dir .\converted --format jpg --recursive
```

```zsh
camoconvert --input-dir ./incoming --output-dir ./converted --format jpg --recursive
```

### Filter Batch Inputs By Extension

```powershell
camoconvert --input-dir .\incoming --format webp --extensions jpg,png,heic
```

```zsh
camoconvert --input-dir ./incoming --format webp --extensions jpg,png,heic
```

### Rename Output Conflicts

```powershell
camoconvert --input-dir .\incoming --format jpg --on-conflict rename
```

```zsh
camoconvert --input-dir ./incoming --format jpg --on-conflict rename
```

### Overwrite Output Conflicts

```powershell
camoconvert -i .\photo.png -o .\photo.jpg --overwrite
```

```zsh
camoconvert -i ./photo.png -o ./photo.jpg --overwrite
```

### Preview Without Writing Files

```powershell
camoconvert --input-dir .\incoming --format webp --dry-run
```

```zsh
camoconvert --input-dir ./incoming --format webp --dry-run
```

### Produce JSON For Automation

```powershell
camoconvert -i .\report.pdf -o .\report.md --json
```

```zsh
camoconvert -i ./report.pdf -o ./report.md --json
```

### Quiet JSON Batch Run

```powershell
camoconvert --input-dir .\incoming --output-dir .\converted --format mp3 --recursive --json --quiet
```

```zsh
camoconvert --input-dir ./incoming --output-dir ./converted --format mp3 --recursive --json --quiet
```

## JSON Output

Use `--json` when another program needs to parse results. JSON output includes the app name, version, aggregate counts, and one report object per input file.

Example command:

```powershell
camoconvert -i .\photo.heic -o .\photo.jpg --json
```

Example shape:

```json
{
  "app": "CamoConvert",
  "version": "1.0.0",
  "converted": 1,
  "planned": 0,
  "failed": 0,
  "skipped": 0,
  "files": [
    {
      "input": "photo.heic",
      "output": "photo.jpg",
      "format": ".jpg",
      "status": "converted",
      "message": "Converted successfully.",
      "input_size_bytes": 123456,
      "output_size_bytes": 78901
    }
  ]
}
```

Possible file statuses:

- `converted`: output was written.
- `planned`: `--dry-run` planned the conversion without writing.
- `skipped`: batch input was unsupported or incompatible with the selected output format.
- `failed`: conversion failed for that file.

## Exit Codes

| Exit code | Meaning |
| --- | --- |
| `0` | Success. All reports were `converted`, `planned`, or `skipped`. |
| `1` | Runtime failure. One or more conversions failed, or an unexpected error occurred. |
| `2` | Usage error. Arguments were missing, invalid, or incompatible. |

For batch runs, unsupported files may be reported as `skipped`. A run with only converted, planned, and skipped reports returns `0`.

## Conflict Behavior

Default behavior is `--on-conflict fail`. If the output path already exists, the file is not overwritten.

Use `--overwrite` or `--on-conflict overwrite` to replace existing output files:

```powershell
camoconvert -i .\photo.png -o .\photo.jpg --overwrite
```

Use `--on-conflict rename` to keep existing files and create a numbered output name:

```powershell
camoconvert --input-dir .\incoming --format jpg --on-conflict rename
```

Rename output uses names like:

```text
photo (1).jpg
photo (2).jpg
```

## Batch Behavior

Batch mode scans files in the selected input directory. Use `--recursive` to include nested folders.

When `--output-dir` is provided with `--recursive`, CamoConvert preserves each file's relative folder path under the output directory.

Example:

```text
incoming\raw\photo.heic
```

With:

```powershell
camoconvert --input-dir .\incoming --output-dir .\converted --format jpg --recursive
```

Output path:

```text
converted\raw\photo.jpg
```

Use `--workers N` to process batch conversions in parallel. The default is `1`, which is the most conservative setting for CPU, memory, and disk pressure.

## Offline And Privacy Behavior

CamoConvert CLI is designed for local, offline conversion:

- Media conversion uses the bundled binary resolved by the packaged app.
- Document conversion disables MarkItDown plugins.
- Document conversion uses a no-network request session.
- Document conversion temporarily blocks Python socket connection attempts while local extraction runs.
- Image conversion writes fresh image files and removes EXIF metadata from converted image outputs.
- Media outputs remove metadata and chapters with bundled arguments.

## Troubleshooting

### `camoconvert` Is Not Recognized

Open a new terminal after installation and try again.

On Windows, confirm the installer PATH task was selected. If it was not selected, rerun the installer and choose the PATH option.

On macOS, confirm the `.pkg` installed the CLI links into a directory on PATH.

### Output Already Exists

Use one of:

```powershell
--overwrite
--on-conflict overwrite
--on-conflict rename
```

### Batch Mode Says `--format` Is Required

Batch mode always requires `--format`:

```powershell
camoconvert --input-dir .\incoming --format jpg
```

### A File Is Skipped

The file may be unsupported, or the selected output format may not be compatible with that input category. Run:

```powershell
camoconvert --list-formats
```

### Paths With Spaces

Quote paths that contain spaces.

PowerShell:

```powershell
camoconvert -i ".\Input Files\photo.heic" -o ".\Output Files\photo.jpg"
```

zsh:

```zsh
camoconvert -i "./Input Files/photo.heic" -o "./Output Files/photo.jpg"
```

## Automation Notes

For scripts and agents:

- Use `camoconvert` in scripts and automation.
- Use `--json` for parseable output.
- Use `--quiet --json` when logs should contain only machine-readable results.
- Check the process exit code.
- Use `--dry-run` before destructive runs.
- Use `--on-conflict fail` for conservative automation.
- Use `--on-conflict rename` when preserving existing outputs matters.
- Use absolute paths when running from scheduled tasks or folder watchers.

PowerShell example:

```powershell
camoconvert --input-dir "C:\Incoming" --output-dir "C:\Converted" --format webp --recursive --json
if ($LASTEXITCODE -ne 0) {
    throw "CamoConvert failed with exit code $LASTEXITCODE"
}
```

zsh example:

```zsh
camoconvert --input-dir "$HOME/Incoming" --output-dir "$HOME/Converted" --format webp --recursive --json
status=$?
if [ "$status" -ne 0 ]; then
  echo "CamoConvert failed with exit code $status" >&2
  exit "$status"
fi
```
