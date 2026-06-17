# CamoVoice CLI Guide

Current CLI version: 1.2.0.

CamoVoice CLI is the headless command-line mode for CamoVoice. It transcribes supported audio files locally from a terminal, script, scheduled job, folder watcher, or automation agent.

The CLI uses the same bundled local transcription stack as the desktop app. It does not require cloud APIs, accounts, telemetry, runtime network services, host-installed speech tools, or user-installed Python packages in packaged builds.

## Commands

Installed CamoVoice CLI is exposed through this command:

```text
camovoice
```

On Windows, the installer creates a `camovoice.cmd` wrapper in the install folder's `cli` subfolder. The wrapper calls the bundled console executable `CamoVoiceCLI.exe`. The GUI executable remains `CamoVoice.exe`, so command-line invocation does not conflict with launching the desktop app.

On macOS, the future package should expose the same `camovoice` command with the same arguments and behavior.

## Installation And PATH

### Windows

The Windows installer includes an option named:

```text
Add camovoice command line tool to PATH
```

When selected, the installer adds the CamoVoice `cli` subfolder to the current user's PATH so `camovoice` is available from new Command Prompt, PowerShell, Windows Terminal, and automation sessions.

If a terminal was already open during installation, close it and open a new terminal before testing PATH.

Check installation:

```powershell
camovoice --version
```

Expected output:

```text
CamoVoice 1.2.0
```

### macOS

The macOS CLI mode is expected to be distributed through a `.pkg` installer and should expose the same command name:

```zsh
camovoice --version
```

The macOS package should make `camovoice` available on PATH and route it to the bundled CamoVoice CLI implementation. It should not rely on Homebrew, system installs, online services, or user-installed Python packages at runtime.

## Requirements

Runtime requirements for installed builds:

- A completed CamoVoice installation.
- Local audio files readable by the current user.
- Write permission to the selected output file or output directory.
- No network connection required.

Development command:

```powershell
python camovoice.py --help
```

## Synopsis

```text
camovoice [-h] [-i FILE | --input-dir DIR] [-o FILE]
          [--output-dir DIR] [-f EXT] [--name NAME]
          [--recursive] [--extensions EXTS]
          [--mode {Fast,Thinking}]
          [--timestamps | --no-timestamps]
          [--use-settings | --no-settings]
          [--custom-word WORD] [--custom-words-json FILE]
          [--save-custom-words]
          [--metadata]
          [--on-conflict {fail,overwrite,rename}] [--overwrite]
          [--dry-run] [--quiet] [--json]
          [--list-formats] [--version]
```

## Input Modes

CamoVoice CLI has two input modes:

- Single-file mode: use `--input FILE` or `-i FILE`.
- Batch directory mode: use `--input-dir DIR`.

These modes are mutually exclusive. Use one or the other in each command.

## Output Rules

Single-file mode can infer the output format from the output filename:

```powershell
camovoice -i .\meeting.wav -o .\meeting.docx
```

Single-file mode can also use `--format` and write into an output directory:

```powershell
camovoice -i .\meeting.mp3 --format txt --output-dir .\transcripts
```

Batch mode requires `--format` because each input needs a consistent target format:

```powershell
camovoice --input-dir .\recordings --format txt
```

If `--output-dir` is omitted, outputs are written beside their input files.

## Options

| Option | Description |
| --- | --- |
| `-h`, `--help` | Show help text and exit. |
| `-i FILE`, `--input FILE` | Transcribe one audio file. Mutually exclusive with `--input-dir`. |
| `--input-dir DIR` | Batch-transcribe files in a directory. Mutually exclusive with `--input`. |
| `-o FILE`, `--output FILE` | Output file for single-file transcription. The extension is used as the output format when `--format` is omitted. |
| `--output-dir DIR` | Directory for transcription outputs. In recursive batch mode, relative subfolders are preserved under this directory. |
| `-f EXT`, `--format EXT` | Output format: `txt`, `docx`, `pdf`, or `json`. Required with `--input-dir`. |
| `--name NAME` | Custom output basename for single-file mode. |
| `--recursive` | Include nested folders during batch transcription. |
| `--extensions EXTS` | Comma-separated input extension filter for batch mode, such as `wav,mp3,m4a`. |
| `--mode Fast\|Thinking` | Select the transcription mode. Defaults to saved settings, then `Fast`. |
| `--timestamps` | Include source timestamps in transcript output when available. |
| `--no-timestamps` | Disable source timestamps for this run. |
| `--use-settings` | Load the GUI-compatible settings file. Default. |
| `--no-settings` | Ignore saved GUI settings for this run. |
| `--custom-word WORD` | Add a recognition hint for this run. Repeatable. |
| `--custom-words-json FILE` | Import recognition hints from a JSON array of strings. |
| `--save-custom-words` | Persist imported and inline custom words back to GUI-compatible settings. |
| `--metadata` | Write `[filename]_metadata.json` beside each output. |
| `--on-conflict fail\|overwrite\|rename` | Output conflict behavior. Default: `fail`. |
| `--overwrite` | Shortcut for `--on-conflict overwrite`. |
| `--dry-run` | Print planned transcriptions without writing output files. |
| `--quiet` | Suppress human-readable progress and summary output. |
| `--json` | Print machine-readable JSON results to STDOUT. |
| `--list-formats` | List supported input and output formats. |
| `--version` | Print the bundled CamoVoice version and exit. |

## Supported Formats

Check the installed build at any time:

```powershell
camovoice --list-formats
camovoice --list-formats --json
```

Supported inputs:

```text
.aac, .m4a, .mp3, .wav
```

Supported outputs:

```text
.docx, .json, .pdf, .txt
```

## Examples

### Show Help And Version

```powershell
camovoice --help
camovoice --version
```

```zsh
camovoice --help
camovoice --version
```

### Transcribe One File

```powershell
camovoice -i .\meeting.wav -o .\meeting.txt
```

```zsh
camovoice -i ./meeting.wav -o ./meeting.txt
```

### Transcribe With Thinking Mode

```powershell
camovoice -i .\interview.m4a --format docx --mode Thinking --output-dir .\transcripts
```

```zsh
camovoice -i ./interview.m4a --format docx --mode Thinking --output-dir ./transcripts
```

### Transcribe A Folder

```powershell
camovoice --input-dir .\recordings --output-dir .\transcripts --format txt
```

```zsh
camovoice --input-dir ./recordings --output-dir ./transcripts --format txt
```

### Transcribe A Folder Recursively

```powershell
camovoice --input-dir .\recordings --output-dir .\transcripts --format pdf --recursive
```

```zsh
camovoice --input-dir ./recordings --output-dir ./transcripts --format pdf --recursive
```

### Include Timestamps

```powershell
camovoice -i .\call.mp3 -o .\call.txt --timestamps
```

```zsh
camovoice -i ./call.mp3 -o ./call.txt --timestamps
```

### Add Custom Words For One Run

```powershell
camovoice -i .\demo.wav --custom-word CamoVoice --custom-word CTranslate2
```

```zsh
camovoice -i ./demo.wav --custom-word CamoVoice --custom-word CTranslate2
```

### Import And Save Custom Words

```powershell
camovoice -i .\demo.wav --custom-words-json .\words.json --save-custom-words
```

```zsh
camovoice -i ./demo.wav --custom-words-json ./words.json --save-custom-words
```

`words.json` must contain a JSON array of strings:

```json
["CamoVoice", "CTranslate2", "faster-whisper"]
```

### Save Input Metadata

```powershell
camovoice -i .\meeting.wav -o .\meeting.txt --metadata
```

```zsh
camovoice -i ./meeting.wav -o ./meeting.txt --metadata
```

### Rename Output Conflicts

```powershell
camovoice --input-dir .\recordings --format txt --on-conflict rename
```

```zsh
camovoice --input-dir ./recordings --format txt --on-conflict rename
```

### Preview Without Writing Files

```powershell
camovoice --input-dir .\recordings --format txt --dry-run
```

```zsh
camovoice --input-dir ./recordings --format txt --dry-run
```

### Produce JSON For Automation

```powershell
camovoice -i .\meeting.wav -o .\meeting.txt --json
```

```zsh
camovoice -i ./meeting.wav -o ./meeting.txt --json
```

## Auto-Splitting

CamoVoice automatically splits files that exceed the selected mode's size or duration limits. Split transcription stays fully local and uses the same limits as the desktop app:

| Mode | Duration limit | Approximate file-size limit |
| --- | --- | --- |
| `Fast` | 15 minutes | 90 MB |
| `Thinking` | 7 minutes | 45 MB |

The CLI auto-splits without prompting. The GUI continues to ask before splitting oversized files.

## Settings And Custom Words

By default, the CLI reads the same settings file as the GUI:

```text
%LOCALAPPDATA%\CamoVoice\settings.json
```

On macOS the equivalent path is:

```text
~/Library/Application Support/CamoVoice/settings.json
```

Use `--no-settings` to ignore saved settings for a run.

Custom words are case-preserved, deduplicated case-insensitively, and capped at 100 words. Inline and imported custom words affect only the current run unless `--save-custom-words` is provided.

## Metadata JSON

Use `--metadata` to write a metadata file beside each transcription:

```text
meeting_metadata.json
```

Metadata includes:

- app name and version
- input path, name, extension, size, created time, and modified time
- transcription mode, duration if discoverable, detected source timestamp, split status, and chunk count
- output path

## JSON Output

Use `--json` when another program needs to parse results. JSON output includes the app name, version, aggregate counts, and one report object per input file.

Example shape:

```json
{
  "app": "CamoVoice",
  "version": "1.2.0",
  "converted": 1,
  "planned": 0,
  "failed": 0,
  "skipped": 0,
  "files": [
    {
      "input": "meeting.wav",
      "output": "meeting.txt",
      "format": ".txt",
      "status": "converted",
      "message": "Transcribed successfully.",
      "input_size_bytes": 123456,
      "output_size_bytes": 7890,
      "duration_seconds": 62.4,
      "chunk_count": 1
    }
  ]
}
```

Possible file statuses:

- `converted`: output was written.
- `planned`: `--dry-run` planned the transcription without writing.
- `skipped`: reserved for compatible future batch skipping.
- `failed`: transcription failed for that file.

## Exit Codes

| Exit code | Meaning |
| --- | --- |
| `0` | Success. All reports were `converted`, `planned`, or `skipped`. |
| `1` | Runtime failure. One or more transcriptions failed, or an unexpected error occurred. |
| `2` | Usage error. Arguments were missing, invalid, or incompatible. |

## Conflict Behavior

Default behavior is `--on-conflict fail`. If the output path already exists, the file is not overwritten.

Use `--overwrite` or `--on-conflict overwrite` to replace existing output files.

Use `--on-conflict rename` to keep existing files and create a numbered output name:

```text
meeting (1).txt
meeting (2).txt
```

## Offline And Privacy Behavior

CamoVoice CLI is designed for local, offline transcription:

- Audio decoding uses local Python packages or bundled ffmpeg.
- Transcription uses bundled faster-whisper/CTranslate2 models.
- Packaged builds set offline model environment flags.
- No audio is sent to any server.
- No accounts, telemetry, analytics, or external APIs are used.

## Troubleshooting

### `camovoice` Is Not Recognized

Open a new terminal after installation and try again.

On Windows, confirm the installer PATH task was selected. If it was not selected, rerun the installer and choose the PATH option.

### Batch Mode Says `--format` Is Required

Batch mode always requires `--format`:

```powershell
camovoice --input-dir .\recordings --format txt
```

### Output Already Exists

Use one of:

```powershell
--overwrite
--on-conflict overwrite
--on-conflict rename
```

### Paths With Spaces

Quote paths that contain spaces:

```powershell
camovoice -i ".\Input Files\meeting.wav" -o ".\Output Files\meeting.txt"
```

```zsh
camovoice -i "./Input Files/meeting.wav" -o "./Output Files/meeting.txt"
```

## Automation Notes

For scripts and agents:

- Use `camovoice` in scripts and automation.
- Use `--json` for parseable output.
- Use `--quiet --json` when logs should contain only machine-readable results.
- Check the process exit code.
- Use `--dry-run` before large batch runs.
- Use `--on-conflict fail` for conservative automation.
- Use absolute paths when running from scheduled tasks or folder watchers.

PowerShell example:

```powershell
camovoice --input-dir "C:\IncomingAudio" --output-dir "C:\Transcripts" --format txt --recursive --json
if ($LASTEXITCODE -ne 0) {
    throw "CamoVoice failed with exit code $LASTEXITCODE"
}
```

zsh example:

```zsh
camovoice --input-dir "$HOME/IncomingAudio" --output-dir "$HOME/Transcripts" --format txt --recursive --json
status=$?
if [ "$status" -ne 0 ]; then
  echo "CamoVoice failed with exit code $status" >&2
  exit "$status"
fi
```
