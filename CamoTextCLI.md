# CamoTextCLI Documentation
*version 0.1.1*

## Overview

CamoText is now distributed as two executables: one for the graphical user interface (GUI) and one for the command-line
interface (CLI). This documentation is for the latter; consult the [User Guide](https://camotext.ai/assets/CamoTextUserGuide.pdf) for the CamoText GUI app.

**camo** or **camotextcli**: Always runs in headless CLI mode for quick and customizable anonymizations, batch processing, and automated workflows.

This approach makes CamoText suitable for both interactive use and server environments, CI/CD pipelines, and automated
data processing tasks, including AI agents, with explicit control over which mode is launched.


## Features

- **Headless Operation**: Run without GUI dependencies (CLI only)
- **Native Batch Processing**: Built-in directory processing with parallel execution
- **Flexible Input**: Accept single files, raw text strings, or entire directories
- **Multiple Output Formats**: Support for various file formats
- **Entity Detection**: List detected entity types before processing
- **Key Management**: Export anonymization keys for audit trails
- **Configurable Hashing**: Customize hash length for anonymization tags
- **Parallel Processing**: Multi-threaded batch processing for faster execution
- **Recursive Processing**: Process nested directory structures
- **Progress Reporting**: Real-time progress updates during batch operations
- **Comprehensive Help**: Built-in help system with organized argument documentation
- **Error Handling**: Clear error messages with suggestions for valid arguments

### Dedicated CLI Entry Point (camotextcli.py)

For advanced users, packagers, or those building from source, there is now a dedicated CLI launcher script:

- Bundled executable 'camo'/'camotextcli'
- This script imports only the CLI logic and never imports or runs any GUI code.
- It is safe for use in headless/server environments, containers, and CI/CD pipelines.
- Use this entry point for all CLI/batch/automation workflows.

---

## Quick Start

See Setting PATH below. For immediate help and argument reference:

```bash
# Get comprehensive help (CLI)
camo --help    # Windows
./camo --help  # macOS/Linux

# Get help in short form (CLI)
camo -h        # Windows
./camo -h      # macOS/Linux
```

Both forms display organized argument groups with descriptions, types, and examples.

## System Requirements

CamoTextCLI is distributed as self-contained frozen executable with all dependencies bundled:

- **No Python installation required** - All dependencies included in executables
- **No additional downloads** - NLP model bundled internally
- **Cross-platform support** - Native executables for Windows, macOS, and Linux
- **No environment setup** - Ready to run immediately after download

When launched as 'camo', 'camo.exe', 'camotextcli', or 'camotextcli.exe', the command-line interface runs in headless
mode:

```bash
# CLI executable, always headless
camo --input document.txt --output anonymized.txt       # Windows
camo --input-dir ./docs --output-dir ./processed

./camo --input document.txt --output anonymized.txt     # macOS/Linux
./camo --input-dir ./docs --output-dir ./processed
```

**CLI Features:**

- Batch directory processing with parallel execution
- Scriptable automation and CI/CD integration
- Progress reporting and error handling
- JSON key export for audit trails
- Entity analysis across multiple files
- No GUI dependencies required

---

| Aspect           | GUI Mode (camotext)            | CLI Mode (camo/camotextcli/camotextcli.py) |
| ---------------- | ------------------------------ | ------------------------------------------ |
| **Execution**    | Interactive window opens       | Runs in terminal/command prompt            |
| **Dependencies** | Requires display/window system | Headless compatible                        |
| **Automation**   | Manual operation               | Fully scriptable                           |
| **Output**       | Visual interface               | STDOUT/files                               |
| **File Size**    | Separate executable            | Separate executable                        |
| **Server Use**   | Not suitable                   | Ideal for server environments              |

### Setting PATH


- One PATH is set, use **camo** to invoke CLI mode (headless, scriptable) rather than having to specify the CamoTextCLI directory in a string

*Setting PATH on Windows:*

1) Win+R → type sysdm.cpl → Enter.

2) “Advanced” tab → Environment Variables…

3) Under User variables (or System variables for all users) select Path → Edit.

4) New → paste C:\full\path\to\CamoTextCLI (your folder containing camo.exe) → OK all the way out.


*Setting PATH on MacOS*

Edit your shell’s startup file. Recent macOS versions default to zsh.

1) Open your shell config in a text editor. run:
```bash
nano ~/.zshrc
```

2) Add this line at the bottom, replacing /full/path/to with the folder containing camo.app:
```bash
export PATH="/full/path/to:$PATH"
```

3) Save (Ctrl + O, Enter) and exit (Ctrl + X).

4) Reload the file so you don’t have to restart Terminal:
```bash
source ~/.zshrc
```


### Usage Examples

> **Note:** Usage examples assume PATH has been set


```bash
# CLI mode
camo --input file.txt --output out.txt           # Windows
camotextcli --input file.txt --output out.txt    # Windows
./camo --input file.txt --output out.txt         # macOS/Linux
./camotextcli --input file.txt --output out.txt  # macOS/Linux
```

### Getting Help

To display all available arguments, their syntax, types, and descriptions:

```bash
# Display comprehensive help
--help
-h          # Short form

# Example output shows organized argument groups:
# - Input/Output Options
# - Anonymization Options
# - Key Management
# - Batch Processing Options
# - Analysis Options
```

### Error Handling

If invalid arguments are provided, CamoText displays helpful error messages:

```bash
# Invalid argument example
camotext.exe --invalid-arg file.txt

# Output:
# Error: Invalid argument(s): --invalid-arg
#
# Supported CLI arguments: --dump-key, --extensions, --hash-length, --help, --ignore-category, --input, --input-dir, --key-dir, --list-entities, --output, --output-dir, --priority, --revert, --recursive, --workers, -h
#
# Use --help or -h for detailed usage information.
```

### Required Arguments

CamoText requires either single file input or batch processing input:

| Mode             | Required Arguments               |
| ---------------- | -------------------------------- |
| Single File      | `--input`                        |
| Batch Processing | `--input-dir` AND `--output-dir` |

### Argument Reference

All CLI arguments, organized into groups:

#### Input/Output Options

| Argument           | Type   | Metavar | Description                                                       |
| ------------------ | ------ | ------- | ----------------------------------------------------------------- |
| `-i` OR `--input`  | string | FILE    | Input file path or raw text string                                |
| `-o` OR `--output` | string | FILE    | Output file path. If omitted, prints to STDOUT                    |
| `--input-dir`      | string | DIR     | Input directory for batch processing                              |
| `--output-dir`     | string | DIR     | Output directory for batch processing (required with --input-dir) |

#### Anonymization Options

| Argument             | Type    | Metavar  | Default | Description                                                                                                                                  |
| -------------------- | ------- | -------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `-p` OR `--priority` | string  | TEXT     | none    | Text that should be anonymized with priority. Case-insensitive. Can be used multiple times                                                   |
| `-r` OR `--revert`   | string  | TEXT     | none    | Text to revert from anonymized files. Case-insensitive. Can be used multiple times. Requires --input-dir                                     |
| `--hash-length`      | integer | N        | 8       | Length of the anonymization hashes                                                                                                           |
| `--ignore-category`  | string  | CATEGORY | none    | Category to ignore (revert after anonymization). Case-insensitive. Can be used multiple times. Examples: PERSON, EMAIL_ADDRESS, PHONE_NUMBER |
| `--config`           | string  | FILE     | none    | Path to JSON configuration file containing anonymization settings                                                                            |

#### Key Management

| Argument     | Type   | Metavar | Description                                                                                                       |
| ------------ | ------ | ------- | ----------------------------------------------------------------------------------------------------------------- |
| `--dump-key` | string | FILE    | Path to write the anonymization key as a JSON file. If no value provided, uses default naming in output directory |
| `--key-dir`  | string | DIR     | Directory to save anonymization keys during batch processing. If no value provided, uses output directory         |

#### Batch Processing Options

| Argument       | Type    | Metavar | Default                         | Description                                                |
| -------------- | ------- | ------- | ------------------------------- | ---------------------------------------------------------- |
| `--recursive`  | flag    | -       | false                           | Process subdirectories recursively during batch processing |
| `--extensions` | list    | EXT     | .txt .pdf .docx .xlsx .csv .rtf | File extensions to process                                 |
| `--workers`    | integer | N       | 1                               | Number of parallel workers for batch processing            |

#### Analysis Options

| Argument          | Type | Metavar | Description                                                      |
| ----------------- | ---- | ------- | ---------------------------------------------------------------- |
| `--list-entities` | flag | -       | List detected entity types and exit (no anonymization performed) |

## Usage Examples

### Getting Help and Information

```bash
# Display comprehensive help with all arguments organized by category
camo --help                # Windows
camotextcli --help         # Windows
./camo --help              # macOS/Linux
./camotextcli --help       # macOS/Linux

# Short form help
camo -h                    # Windows
camotextcli -h             # Windows
./camo -h                  # macOS/Linux
./camotextcli -h           # macOS/Linux

# Example help output structure:
# CamoText: Anonymize text from files or strings.
#
# Input/Output Options:
#   --input FILE            Input file path or raw text string
#   --output FILE           Output file path. If omitted, prints to STDOUT
#   --input-dir DIR         Input directory for batch processing
#   --output-dir DIR        Output directory for batch processing
#
# Anonymization Options:
#   --priority TEXT         Text that should be anonymized with priority
#   --revert TEXT           Text to revert from anonymized files
#   --hash-length N         Length of the anonymization hashes (default: 8)
#   --ignore-category CAT   Category to ignore (revert after anonymization)
#
# Key Management:
#   --dump-key [FILE]       Path to write the anonymization key as a JSON file
#   --key-dir [DIR]         Directory to save anonymization keys
#
# Batch Processing Options:
#   --recursive             Process subdirectories recursively
#   --extensions EXT        File extensions to process
#   --workers N             Number of parallel workers (default: 1)
#
# Analysis Options:
#   --list-entities         List detected entity types and exit
```

### Error Handling Examples

```bash
# Example 1: Invalid argument
camo --unknown-option file.txt
# Output:
# Error: Invalid argument(s): --unknown-option
#
# Supported CLI arguments: --dump-key, --extensions, --hash-length, --help, --ignore-category, --input, --input-dir, --key-dir, --list-entities, --output, --output-dir, --priority, --revert, --recursive, --workers, -h
#
# Use --help or -h for detailed usage information.

# Example 2: Missing required arguments (argparse error)
camo --output file.txt
# Output:
# Error: Invalid argument(s) provided.
#
# Supported CLI arguments: --dump-key, --extensions, --hash-length, --help, --ignore-category, --input, --input-dir, --key-dir, --list-entities, --output, --output-dir, --priority, --revert, --recursive, --workers, -h
#
# Use --help or -h for detailed usage information.

# Example 3: Get help to see proper usage
camo --help
# Shows complete help documentation with examples
```

### Basic File Anonymization

```bash
# Anonymize a text file to STDOUT (using long forms)
camo --input document.txt                               # Windows
camotextcli --input document.txt                        # Windows
./camo --input document.txt                             # macOS/Linux
./camotextcli --input document.txt                      # macOS/Linux

# Anonymize a text file to STDOUT (using short forms)
camo -i document.txt                                    # Windows
camotextcli -i document.txt                             # Windows
./camo -i document.txt                                  # macOS/Linux
./camotextcli -i document.txt                           # macOS/Linux

# Anonymize a PDF and save to file (using long forms)
camo --input report.pdf --output anonymized_report.pdf   # Windows
camotextcli --input report.pdf --output anonymized_report.pdf # Windows
./camo --input report.pdf --output anonymized_report.pdf # macOS/Linux
./camotextcli --input report.pdf --output anonymized_report.pdf # macOS/Linux

# Anonymize a PDF and save to file (using short forms)
camo -i report.pdf -o anonymized_report.pdf              # Windows
camotextcli -i report.pdf -o anonymized_report.pdf       # Windows
./camo -i report.pdf -o anonymized_report.pdf            # macOS/Linux
./camotextcli -i report.pdf -o anonymized_report.pdf     # macOS/Linux
```

### Raw Text Processing

```bash
# Process raw text string (Windows)
camo --input "John Doe works at Acme Corp and can be reached at john@acme.com"

# Process raw text string (macOS/Linux)
./camo --input "John Doe works at Acme Corp and can be reached at john@acme.com"

# Process with custom hash length
camo --input "Sensitive data here" --hash-length 12     # Windows
./camo --input "Sensitive data here" --hash-length 12   # macOS/Linux
```

### Priority Text Processing

```bash
# Process with priority text that must be anonymized first (Windows)
camo --priority "confidential" --input "This is confidential information"

# Process with multiple priority texts (macOS/Linux)
./camo --priority "classified" --priority "top secret" --input document.txt

# Priority text with file output
camo --priority "internal use only" --input report.pdf --output anonymized_report.pdf

# Batch processing with priority text
camo --priority "proprietary" --input-dir ./documents --output-dir ./anonymized
```

### Term Reversion

```bash
# Revert specific terms from anonymized files (Windows)
camo --input-dir ./anonymized --revert "John Doe" --revert "Acme Corp"

# Revert specific terms (macOS/Linux)
./camo --input-dir ./anonymized --revert "John Doe" --revert "Acme Corp"

# Revert with short form
camo --input-dir ./anonymized -r "John Doe" -r "Acme Corp"

# Revert with custom key directory
camo --input-dir ./anonymized --key-dir ./keys --revert "confidential"

# Revert with recursive processing
camo --input-dir ./anonymized --revert "internal" --recursive
```

### Category Ignoring (Reversion)

The `--ignore-category` option allows you to specify entity categories that should be ignored (reverted to original text
after anonymization). This is useful when you want to anonymize most entities but keep certain types visible.

```bash
# Ignore organization names (Windows)
camo --ignore-category "organization" --input document.txt --output anonymized.txt

# Ignore multiple categories (macOS/Linux)
./camo --ignore-category "person" --ignore-category "location" --input report.pdf --output clean_report.pdf

# Case-insensitive category matching
camo --ignore-category "ORGANIZATION" --ignore-category "person" --input data.txt

# Batch processing with ignored categories
./camo --input-dir ./docs --output-dir ./processed --ignore-category "organization" --ignore-category "location"

# Combine with priority text
camo --priority "confidential" --ignore-category "organization" --input document.txt
```

**Supported Categories for --ignore-category:**

- `PERSON` - Personal names
- `EMAIL_ADDRESS` - Email addresses
- `PHONE_NUMBER` / `CONTACT_NUMBER` - Phone numbers
- `ORGANIZATION` / `ENTITY` - Company and organization names
- `LOCATION` / `ADDRESS` / `STREET_ADDRESS` - Geographic locations
- `DATE_TIME` - Dates and times
- `MONEY` - Monetary amounts
- `CREDIT_CARD` - Credit card numbers
- `US_SSN` - Social Security Numbers
- `IP_ADDRESS` - IP addresses
- `URL` - Website URLs
- `FILE` - File paths and names
- `GPS` - GPS coordinates
- `ACCOUNT` - Account handles and numbers
- `UUID` - Universal unique identifiers
- `CRYPTO_ADDRESS` - Cryptocurrency addresses
- And more... (see the [CamoText User Guide](https://camotext.ai/assets/CamoTextUserGuide.pdf) for the complete list of data categories)

### Key File Placement

When using `--dump-key` with output directories, the key file is automatically placed in the appropriate location:

```bash
# Single file: key placed in same directory as output
camo --input document.txt --output ./processed/anonymized.txt --dump-key key.json
# Result: key saved to ./processed/key.json (not ./key.json)

# Batch processing: keys placed in output directory when --key-dir not specified
./camo --input-dir ./docs --output-dir ./processed --dump-key keys.json
# Result: individual key files placed in ./processed/ directory

# Explicit key directory overrides automatic placement
camo --input-dir ./docs --output-dir ./processed --key-dir ./audit --dump-key keys.json
# Result: keys saved to ./audit/ directory (--key-dir takes precedence)
```

### Entity Detection

```bash
# List detected entity types without anonymization
camo --input document.txt --list-entities               # Windows
./camo --input document.txt --list-entities                 # macOS/Linux

# Example output:
# ["PERSON", "EMAIL_ADDRESS", "ORGANIZATION"]
```

### Key Management

```bash
# Generate anonymization key file for single file
camo --input document.txt --output anonymized.txt --dump-key key.json  # Windows
./camo --input document.txt --output anonymized.txt --dump-key key.json    # macOS/Linux

# Use default key naming (no value provided)
camo --input document.txt --output anonymized.txt --dump-key
# Result: Creates anonymized_key.json in the same directory as output

# Batch processing with centralized key directory
camo --input-dir ./docs --output-dir ./anonymized --key-dir ./keys --dump-key batch_key.json

# Batch processing with automatic individual key files (no --key-dir specified)
camo --input-dir ./docs --output-dir ./anonymized --dump-key keys.json
# Result: Creates individual key files like document1_key.json, document2_key.json, etc. in ./anonymized/

# Batch processing with default key directory (no value for --key-dir)
camo --input-dir ./docs --output-dir ./anonymized --key-dir --dump-key
# Result: Keys saved to ./anonymized/ directory with default naming

# Batch processing with explicit key directory (overrides automatic behavior)
camo --input-dir ./docs --output-dir ./anonymized --key-dir ./audit --dump-key keys.json
# Result: Keys saved to ./audit/ directory as specified by --key-dir
```

**Key File Behavior:**

- **Single file mode**: `--dump-key` saves to the specified path
- **Single file mode with no value**: `--dump-key` saves to output directory with name `{output_filename}_key.json`
- **Batch mode with `--key-dir`**: Keys saved to the specified key directory
- **Batch mode with `--key-dir` (no value)**: Keys saved to output directory
- **Batch mode without `--key-dir`**: Creates individual key files for each processed file in the output directory
- **Key file naming**: Individual key files use the pattern `{original_filename}_key.json`
- **Default naming**: When no filename is specified, uses `{document_name}_key.json` format

**Key file format (key.json):**

```json
{
  "John Doe": "<PERSON_a1b2c3d4>",
  "john@acme.com": "<EMAIL_ADDRESS_e5f6g7h8>",
  "Acme Corp": "<ORGANIZATION_i9j0k1l2>"
}
```

### Native Batch Processing

```bash
# Process entire directory (Windows)
camo --input-dir ./documents --output-dir ./anonymized --key-dir ./keys

# Process entire directory (macOS/Linux)
./camo --input-dir ./documents --output-dir ./anonymized --key-dir ./keys

# Process with specific file types
camo --input-dir ./docs --output-dir ./anon --extensions .txt .pdf

# Recursive processing with parallel workers
camo --input-dir ./projects --output-dir ./anonymized ^
             --key-dir ./keys --recursive --workers 4

# List all entities in a directory
camo --input-dir ./documents --list-entities
```

### Advanced Batch Examples

```bash
# Large dataset processing with 8 workers (Windows)
camo --input-dir C:\data\sensitive --output-dir C:\data\anonymized ^
             --key-dir C:\data\keys --workers 8 --hash-length 12

# Large dataset processing (macOS/Linux)
./camo --input-dir /data/sensitive --output-dir /data/anonymized \
           --key-dir /data/keys --workers 8 --hash-length 12

# Process only specific file types recursively
camo --input-dir ./mixed_files --output-dir ./cleaned ^
             --extensions .docx .pdf --recursive

# Batch entity analysis
camo --input-dir ./compliance_docs --list-entities > entity_report.json

# Advanced priority text processing
camo --priority "Operation Blackbird" --priority "classified" ^
             --input-dir ./sensitive --output-dir ./sanitized ^
             --key-dir ./keys --workers 4

# Complex processing with category ignoring
camo --priority "confidential" --ignore-category "organization" ^
             --ignore-category "location" --input-dir ./documents ^
             --output-dir ./processed --dump-key audit.json --workers 6

# Selective anonymization keeping organizations visible
./camo --input-dir ./compliance_docs --output-dir ./redacted \
           --ignore-category "organization" --ignore-category "entity" \
           --recursive --workers 8
```

### Term Reversion Feature

CamoText supports selective term reversion, which allows you to revert specific terms from previously anonymized files
back to their original text. This is useful when you need to selectively restore certain information that was previously
anonymized.

### How Term Reversion Works

1. **Directory Scan**: Scans the input directory for files with supported extensions
2. **Hash Detection**: Identifies anonymization hash patterns (`<ENTITY_TYPE_hash>`) in each file
3. **Key File Loading**: Loads key files (either from `--key-dir` or the same directory as input files)
4. **Term Matching**: Matches revert terms against original text in key files (case-insensitive)
5. **Hash Replacement**: Replaces all matching hash patterns with their original text
6. **File Overwrite**: Saves the reverted content back to the original file location

### Key Features

- **Case-insensitive matching**: Terms are matched regardless of case
- **Partial matching**: Terms can match any part of the original text
- **Multiple terms**: Can specify multiple terms to revert
- **Directory processing**: Processes all files in the specified directory
- **Key file integration**: Automatically finds and uses key files to map hashes to original text
- **Overwrite mode**: Reverted files overwrite the original files
- **Parallel processing**: Supports multi-threaded processing for faster execution
- **Recursive processing**: Can process nested directory structures

### Key File Discovery

- **With `--key-dir`**: Looks for `*_key.json` files in the specified key directory
- **Without `--key-dir`**: Looks for `*_key.json` files in the same directory as each input file
- **Multiple keys**: Combines all found key files to build a comprehensive mapping

### Term Reversion Examples

```bash
# Basic reversion (Windows)
camo --input-dir ./anonymized --revert "John Doe" --revert "Acme Corp"

# Basic reversion (macOS/Linux)
./camo --input-dir ./anonymized --revert "John Doe" --revert "Acme Corp"

# Revert with short form
camo --input-dir ./anonymized -r "John Doe" -r "Acme Corp"

# Revert with custom key directory
camo --input-dir ./anonymized --key-dir ./keys --revert "confidential"

# Revert with recursive processing
camo --input-dir ./anonymized --revert "internal" --recursive

# Revert with parallel processing
camo --input-dir ./anonymized --revert "sensitive" --workers 4

# Revert multiple terms in one command
camo --input-dir ./anonymized --revert "John Doe" --revert "Acme Corp" --revert "confidential"

# Revert with specific file types
camo --input-dir ./anonymized --revert "classified" --extensions .txt .pdf
```

### Example Workflow

```bash
# 1. Initial anonymization
camo --input-dir ./documents --output-dir ./anonymized --key-dir ./keys

# 2. Later, revert specific terms
camo --input-dir ./anonymized --key-dir ./keys --revert "John Doe"

# 3. Result: All instances of <PERSON_abc123de> become "John Doe" again
```

### Progress Reporting

```bash
# Example output during reversion:
Found 15 files to process for reversion...
[1/15] ✓ document1.txt (reverted 3 instances of 2 terms)
[2/15] ⚠ document2.txt - No anonymization hashes found
[3/15] ✓ document3.txt (reverted 1 instances of 1 terms)
[4/15] ⚠ document4.txt - No terms matching ['John Doe'] found in key files

Reversion complete:
  ✓ Successful: 12
  ✗ Failed: 0
  ⚠ No hashes found: 2
  ⚠ No matching terms: 1
  📁 Processed directory: ./anonymized
```

### Use Cases

- **Redact all PII, then selectively restore specific names or organizations for reporting**
- **Batch anonymize large datasets, then revert only certain terms for compliance**
- **Automate anonymization and reversion in CI/CD pipelines**

### Processing Modes

The CLI supports three processing modes:

#### 1. Single File Processing

Process individual files or raw text strings:

```bash
# File processing
camo --input C:\path\to\document.pdf                    # Windows
./camo --input /path/to/document.pdf                      # macOS/Linux

# Raw text processing
camo --input "This is raw text to anonymize"
./camo --input "This is raw text to anonymize"
```

#### 2. Batch Directory Processing

Process entire directories with built-in parallelization:

```bash
# Basic directory processing
camo --input-dir ./source --output-dir ./processed      # Windows
./camo --input-dir ./source --output-dir ./processed    # macOS/Linux

# Advanced batch processing (Windows)
camo --input-dir ./data --output-dir ./anonymized ^
             --key-dir ./keys --recursive --workers 4 ^
             --extensions .txt .pdf .docx

# Advanced batch processing (macOS/Linux)
./camo --input-dir ./data --output-dir ./anonymized \
           --key-dir ./keys --recursive --workers 4 \
           --extensions .txt .pdf .docx
```

#### 3. Entity Analysis Mode

Analyze entity types without anonymization:

```bash
# Single file analysis
camo --input document.txt --list-entities               # Windows
./camo --input document.txt --list-entities             # macOS/Linux

# Batch entity analysis
camo --input-dir ./documents --list-entities            # Windows
./camo --input-dir ./documents --list-entities          # macOS/Linux
```

### Output Handling

#### Single File Output

##### Standard Output (Default)

When `--output` is not specified, anonymized text is printed to STDOUT:

```bash
camo --input document.txt
./camo --input document.txt
```

##### File Output

```bash
camo --input document.txt --output anonymized.txt
./camo --input document.txt --output anonymized.txt
```

##### Key File Output

```bash
camo --input document.txt --output anonymized.txt --dump-key key.json  # Windows
./camo --input document.txt --output anonymized.txt --dump-key key.json    # macOS/Linux

# Use default key naming (no value provided)
camo --input document.txt --output anonymized.txt --dump-key
# Result: Creates anonymized_key.json in the same directory as output

# Batch processing with centralized key directory
camo --input-dir ./docs --output-dir ./anonymized --key-dir ./keys --dump-key batch_key.json

# Batch processing with automatic individual key files (no --key-dir specified)
camo --input-dir ./docs --output-dir ./anonymized --dump-key keys.json
# Result: Creates individual key files like document1_key.json, document2_key.json, etc. in ./anonymized/

# Batch processing with default key directory (no value for --key-dir)
camo --input-dir ./docs --output-dir ./anonymized --key-dir --dump-key
# Result: Keys saved to ./anonymized/ directory with default naming

# Batch processing with explicit key directory (overrides automatic behavior)
camo --input-dir ./docs --output-dir ./anonymized --key-dir ./audit --dump-key keys.json
# Result: Keys saved to ./audit/ directory as specified by --key-dir
```

**Key File Behavior:**

- **Single file mode**: `--dump-key` saves to the specified path
- **Single file mode with no value**: `--dump-key` saves to output directory with name `{output_filename}_key.json`
- **Batch mode with `--key-dir`**: Keys saved to the specified key directory
- **Batch mode with `--key-dir` (no value)**: Keys saved to output directory
- **Batch mode without `--key-dir`**: Creates individual key files for each processed file in the output directory
- **Key file naming**: Individual key files use the pattern `{original_filename}_key.json`
- **Default naming**: When no filename is specified, uses `{document_name}_key.json` format

**Key file format (key.json):**

```json
{
  "John Doe": "<PERSON_a1b2c3d4>",
  "john@acme.com": "<EMAIL_ADDRESS_e5f6g7h8>",
  "Acme Corp": "<ORGANIZATION_i9j0k1l2>"
}
```

### Integration Examples

#### CI/CD Pipeline

```yaml
# GitHub Actions example
- name: Anonymize documents
  run: |
    camo --input sensitive_report.pdf \
         --output public_report.pdf \
         --dump-key audit_key.json \
         --ignore-category "organization"
```

#### Shell Script Integration

```bash
#!/bin/bash
# batch_anonymize.sh - Using native batch processing

INPUT_DIR="./sensitive_docs"
OUTPUT_DIR="./anonymized_docs"
KEY_DIR="./keys"

# Single command for entire directory (assuming CamoText executable in PATH)
camo \
    --input-dir "$INPUT_DIR" \
    --output-dir "$OUTPUT_DIR" \
    --key-dir "$KEY_DIR" \
    --recursive \
    --workers 4 \
    --hash-length 10 \
    --ignore-category "organization" \
    --ignore-category "location"
```

#### Python Script Integration

```python
import subprocess
import json
import sys
from pathlib import Path

def anonymize_file(input_path, output_path=None, hash_length=8, ignore_categories=None, executable_path='camo'):
    """Anonymize a single file using CamoText executable."""
    cmd = [executable_path, '--input', input_path]

    if output_path:
        cmd.extend(['--output', output_path])

    if hash_length != 8:
        cmd.extend(['--hash-length', str(hash_length)])

    if ignore_categories:
        for category in ignore_categories:
            cmd.extend(['--ignore-category', category])

    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"Error: {result.stderr}", file=sys.stderr)
        return None

    return result.stdout

def batch_anonymize(input_dir, output_dir, key_dir=None, workers=4, recursive=True, ignore_categories=None, executable_path='camo'):
    """Batch anonymize directory using native batch processing."""
    cmd = [
        executable_path,
        '--input-dir', input_dir,
        '--output-dir', output_dir,
        '--workers', str(workers)
    ]

    if key_dir:
        cmd.extend(['--key-dir', key_dir])

    if recursive:
        cmd.append('--recursive')

    if ignore_categories:
        for category in ignore_categories:
            cmd.extend(['--ignore-category', category])

    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"Batch processing failed: {result.stderr}", file=sys.stderr)
        return False

    print(result.stdout)
    return True

# Usage examples
# Windows: Use 'camo.exe', macOS/Linux: Use './camo'
anonymized_content = anonymize_file('document.txt', 'anonymized.txt',
                                   ignore_categories=['organization', 'location'],
                                   executable_path='camo.exe')
batch_success = batch_anonymize('./docs', './anonymized', './keys', workers=8,
                               ignore_categories=['organization'],
                               executable_path='camo.exe')
```

### Performance Considerations

#### File Size Limits

CamoText enforces a maximum file size and page count for processing. See the main documentation for details.

### Supported Entity Types

The entity types detected and anonymized by the system can be found in the CamoText User Guide

### AI Agent Integration

CamoText is well-suited for AI agents and local bots due to its executable-based CLI design.

#### Excellent AI Agent Compatibility

##### ✅ **Perfect CLI Interface**

- **No GUI dependencies** - Runs headless in any environment
- **Structured input/output** - Predictable command syntax and responses
- **Standard exit codes** - Proper success/failure signaling
- **JSON output** - Machine-readable entity lists and anonymization keys

##### ✅ **Zero-Setup Deployment**

```bash
# AI agent can simply invoke the executable
./camo --input "sensitive data" --output result.txt --dump-key key.json
```

- **Self-contained executable** - No Python environment or dependency management
- **Cross-platform** - Same interface on Windows, macOS, Linux
- **Immediate availability** - Download and run, no installation steps

##### ✅ **Batch Processing Power**

```bash
# Process entire directories with parallel workers
./camo --input-dir ./data --output-dir ./anonymized --workers 8 --key-dir ./keys
```

- **Native parallelization** - Built-in multi-threading for large datasets
- **Progress reporting** - Real-time status updates for monitoring
- **Error resilience** - Continues processing even if individual files fail

##### ✅ **Flexible Integration Patterns**

**1. Direct subprocess calls:**

```python
import subprocess
import json

result = subprocess.run(['./camo', '--input', text, '--list-entities'],
                       capture_output=True, text=True)
entities = json.loads(result.stdout)
```

**2. File-based workflows:**

```python
# Agent writes files, processes them, reads results
with open('temp_input.txt', 'w') as f:
    f.write(sensitive_data)

subprocess.run(['./camo', '--input', 'temp_input.txt',
                '--output', 'temp_output.txt', '--dump-key', 'temp_key.json'])

with open('temp_output.txt') as f:
    anonymized = f.read()
with open('temp_key.json') as f:
    key = json.load(f)
```

#### Sample AI Agent Integration

```python
class CamoTextAgent:
    def __init__(self, executable_path='camo'):
        self.executable = executable_path

    def anonymize(self, text, hash_length=8, ignore_categories=None):
        """Anonymize text and return both result and key mapping."""
        import tempfile
        import json

        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write(text)
            input_file = f.name

        try:
            output_file = input_file + '.anon'
            key_file = input_file + '.key'

            cmd = [self.executable, '--input', input_file,
                   '--output', output_file, '--dump-key', key_file,
                   '--hash-length', str(hash_length)]

            if ignore_categories:
                for category in ignore_categories:
                    cmd.extend(['--ignore-category', category])

            result = subprocess.run(cmd, capture_output=True, text=True)

            if result.returncode == 0:
                with open(output_file, 'r') as f:
                    anonymized_text = f.read()
                with open(key_file, 'r') as f:
                    key_mapping = json.load(f)
                return anonymized_text, key_mapping
            else:
                raise Exception(f"CamoText error: {result.stderr}")
        finally:
            # Cleanup temporary files
            for file_path in [input_file, output_file, key_file]:
                try:
                    os.unlink(file_path)
                except:
                    pass

    def batch_process(self, input_dir, output_dir, workers=4, ignore_categories=None):
        """Process directory of files with parallel workers."""
        cmd = [self.executable, '--input-dir', input_dir,
               '--output-dir', output_dir, '--workers', str(workers)]

        if ignore_categories:
            for category in ignore_categories:
                cmd.extend(['--ignore-category', category])

        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr

    def detect_entities(self, text):
        """Get list of entity types without anonymization."""
        cmd = [self.executable, '--input', text, '--list-entities']
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode == 0:
            return json.loads(result.stdout)
        else:
            raise Exception(f"Entity detection error: {result.stderr}")

# Usage example
agent = CamoTextAgent(executable_path='camo.exe')  # Windows
anonymized, key_map = agent.anonymize("John Doe works at Acme Corp", ignore_categories=['organization'])
entities = agent.detect_entities("Analyze this sensitive document")
batch_success, output, errors = agent.batch_process('./docs', './processed',
                                                   ignore_categories=['organization', 'location'])
```

## License and Support

CamoText CLI is subject to the CamoText EULA. For technical support or feature requests, please refer to the main
documentation or contact support channels.

---

_This documentation covers CamoText CLI version 0.1.1. For the latest updates, please check the release notes._

### Configuration File

The `--config` argument allows you to specify a JSON configuration file that contains anonymization settings. This is
useful for maintaining consistent settings across multiple runs. The configuration file should have the following
format:

```json
{
  "priority": ["John Doe", "Acme Corp", "123-456-7890"],
  "hash_length": 12,
  "ignore_category": ["PERSON", "EMAIL_ADDRESS"]
}
```

All fields in the configuration file are optional. If a field is not specified, the default value or command-line
argument will be used instead.

#### Configuration File Examples

1. **Basic Configuration**

```json
{
  "priority": ["confidential", "top secret"],
  "hash_length": 10
}
```

Usage:

```bash
camo --config config.json --input document.txt
```

2. **Complex Configuration**

```json
{
  "priority": [
    "Project Aurora",
    "Operation Blackbird",
    "classified information"
  ],
  "hash_length": 12,
  "ignore_category": ["ORGANIZATION", "LOCATION", "DATE_TIME"]
}
```

Usage:

```bash
camo --config config.json --input-dir ./documents --output-dir ./anonymized
```

3. **Minimal Configuration**

```json
{
  "ignore_category": ["PERSON"]
}
```

Usage:

```bash
camo --config config.json --input document.txt --output anonymized.txt
```

#### Configuration File Benefits

1. **Consistency**: Maintain the same anonymization rules across multiple runs
2. **Reusability**: Share configuration files across team members
3. **Version Control**: Track anonymization settings in source control
4. **Reduced Command Length**: Avoid typing long command lines repeatedly

#### Configuration File Location

The configuration file can be placed anywhere on your system. Common locations include:

- Project root directory
- Configuration directory
- User's home directory

Example paths:

```bash
# Windows
camo --config C:\config\anonymization.json --input document.txt
camo --config .\config.json --input document.txt

# macOS/Linux
./camo --config /etc/camotext/config.json --input document.txt
./camo --config ./config.json --input document.txt
```

#### Configuration File Override

Command-line arguments take precedence over configuration file settings. This allows you to:

1. Use a base configuration file for common settings
2. Override specific settings via command line when needed

Example:

```bash
# config.json has hash_length: 8, but command line overrides it to 12
camo --config config.json --hash-length 12 --input document.txt
```

### Examples

Basic file anonymization:

```bash
# Using long form arguments
camo --input document.pdf --output anonymized.txt

# Using short form arguments
camo -i document.pdf -o anonymized.txt

# Using configuration file
camo --config config.json --input document.txt
```

Anonymization with priority text:

```bash
# Using long form arguments
camo --input file.txt --priority "John Doe" --priority "Acme Corp"

# Using short form arguments
camo -i file.txt -p "John Doe" -p "Acme Corp"

# Using configuration file
camo --config config.json --input file.txt
```

Batch processing:

```bash
# Basic batch processing
camo --input-dir ./docs --output-dir ./output --recursive

# Batch processing with configuration
camo --config config.json --input-dir ./docs --output-dir ./output
```

List entities without anonymization:

```bash
camo --input file.txt --list-entities
```

Ignore specific categories:

```bash
# Using command line arguments
camo --input file.txt --ignore-category PERSON --ignore-category EMAIL_ADDRESS

# Using configuration file
camo --config config.json --input file.txt
```

Supported file types: `.txt`, `.pdf`, `.docx`, `.xlsx`, `.csv`, `.rtf`
