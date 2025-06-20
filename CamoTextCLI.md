# CamoText CLI Documentation

## Overview

CamoText is distributed as a single PyInstaller-bundled executable that automatically operates in either GUI or CLI mode
depending on how it's invoked. When launched without arguments, it opens the graphical interface. When launched with
command-line arguments, it runs in headless CLI mode for batch processing and automated workflows.

This dual-mode approach makes CamoText suitable for both interactive use and server environments, CI/CD pipelines, and
automated data processing tasks.

## Features

- **Headless Operation**: Run without GUI dependencies
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

## Quick Start

For immediate help and argument reference:

```bash
# Get comprehensive help
camotext.exe --help    # Windows
./camotext --help      # macOS/Linux

# Get help in short form
camotext.exe -h        # Windows
./camotext -h          # macOS/Linux
```

Both forms display organized argument groups with descriptions, types, and examples.

## System Requirements

CamoText is distributed as a self-contained executable with all dependencies bundled:

- **No Python installation required** - All dependencies included in executable
- **No additional downloads** - NLP model bundled internally
- **Cross-platform support** - Native executables for Windows, macOS, and Linux
- **No environment setup** - Ready to run immediately after download

## GUI vs CLI Mode

CamoText operates in two distinct modes depending on how it's invoked:

### GUI Mode (Default)

When launched without arguments, the CamoText executable opens the graphical user interface:

```bash
# Double-click the executable or run from command line without arguments
camotext.exe                     # Windows
./camotext                       # macOS/Linux
```

**GUI Features:**

- Interactive drag-and-drop file processing
- Visual anonymization key management with checkboxes
- Real-time text editing and highlighting
- Theme switching (light/dark mode)
- Manual text selection and anonymization
- Category-based entity reversion
- New window output viewing with search

### CLI Mode (Headless)

When launched with command-line arguments, the same CamoText executable runs in headless mode without GUI:

```bash
# Same executable, CLI mode triggered by arguments
camotext.exe --input document.txt --output anonymized.txt       # Windows
camotext.exe --input-dir ./docs --output-dir ./processed

./camotext --input document.txt --output anonymized.txt         # macOS/Linux
./camotext --input-dir ./docs --output-dir ./processed
```

**CLI Features:**

- Batch directory processing with parallel execution
- Scriptable automation and CI/CD integration
- Progress reporting and error handling
- JSON key export for audit trails
- Entity analysis across multiple files
- No GUI dependencies required

### Deployment Differences

| Aspect           | GUI Mode                       | CLI Mode                        |
| ---------------- | ------------------------------ | ------------------------------- |
| **Execution**    | Interactive window opens       | Runs in terminal/command prompt |
| **Dependencies** | Requires display/window system | Headless compatible             |
| **Automation**   | Manual operation               | Fully scriptable                |
| **Output**       | Visual interface               | STDOUT/files                    |
| **File Size**    | Same executable file           | Same executable file            |
| **Server Use**   | Not suitable                   | Ideal for server environments   |

### Single Executable Benefits

CamoText is distributed as a PyInstaller-bundled executable with these advantages:

#### Universal Deployment

- **Single File**: No Python installation or package management required
- **All Dependencies Included**: Libraries, NLP models, and assets bundled internally
- **Cross-Platform**: Native executables for Windows, macOS, and Linux
- **Dual-Mode Operation**: Same executable automatically detects GUI vs CLI usage

#### CLI-Specific Benefits

- **Server Deployment**: Deploy to headless servers without GUI dependencies
- **Container Friendly**: Works in Docker containers and CI/CD environments
- **Resource Efficiency**: GUI libraries loaded but not initialized in CLI mode
- **Path Independence**: No need to manage Python PATH or virtual environments

#### Usage Examples

```bash
# Windows Server
C:\tools\camotext.exe --input-dir C:\data --output-dir C:\processed --workers 8

# Linux Container
./camotext --input-dir /data --output-dir /processed --recursive

# macOS Automation
./camotext --input /Users/data/report.pdf --output /Users/clean/report.pdf
```

#### Performance Notes

- **Startup Time**: Bundled executable has ~2-3 second initialization time
- **Memory Usage**: Full application loaded, but GUI components unused in CLI mode
- **File Size**: Single executable includes all components (typically 200-400MB)
- **Efficiency**: No performance difference between modes once initialized

### When to Use Each Mode

#### Choose GUI Mode When:

- **Interactive Processing**: Need to review and manually adjust anonymization
- **One-off Documents**: Processing individual files occasionally
- **Visual Verification**: Want to see real-time anonymization results
- **Entity Review**: Need to selectively revert specific anonymized items
- **Learning**: First-time users exploring CamoText capabilities
- **Complex Decisions**: Require human judgment for anonymization choices

#### Choose CLI Mode When:

- **Batch Processing**: Need to process multiple files or directories
- **Automation**: Integrating into scripts, workflows, or CI/CD pipelines
- **Server Environments**: Running on headless servers or containers
- **Consistent Processing**: Same anonymization rules across many files
- **Scheduled Tasks**: Automated processing at regular intervals
- **High Volume**: Processing hundreds or thousands of documents

#### Hybrid Approach

You can combine both modes in your workflow using the same executable:

```bash
# 1. Use CLI for initial batch processing
camotext.exe --input-dir ./raw_data --output-dir ./processed --key-dir ./keys

# 2. Use GUI for fine-tuning specific documents
camotext.exe
# (Opens GUI window for manual review and adjustment)
```

### Supported File Formats

| Input Formats | Output Formats |
| ------------- | -------------- |
| `.txt`        | `.txt`         |
| `.pdf`        | `.pdf`         |
| `.docx`       | `.docx`        |
| `.xlsx`       | `.xlsx`        |
| `.csv`        | `.csv`         |
| `.rtf`        | `.rtf`         |

## Command Syntax

```bash
# Windows
camotext.exe [OPTIONS]

# macOS/Linux
./camotext [OPTIONS]
```

### Getting Help

To display all available arguments, their syntax, types, and descriptions:

```bash
# Display comprehensive help
camotext.exe --help
camotext.exe -h          # Short form

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
camotext.exe --help                # Windows
./camotext --help                  # macOS/Linux

# Short form help
camotext.exe -h                    # Windows
./camotext -h                      # macOS/Linux

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
camotext.exe --unknown-option file.txt
# Output:
# Error: Invalid argument(s): --unknown-option
#
# Supported CLI arguments: --dump-key, --extensions, --hash-length, --help, --ignore-category, --input, --input-dir, --key-dir, --list-entities, --output, --output-dir, --priority, --revert, --recursive, --workers, -h
#
# Use --help or -h for detailed usage information.

# Example 2: Missing required arguments (argparse error)
camotext.exe --output file.txt
# Output:
# Error: Invalid argument(s) provided.
#
# Supported CLI arguments: --dump-key, --extensions, --hash-length, --help, --ignore-category, --input, --input-dir, --key-dir, --list-entities, --output, --output-dir, --priority, --revert, --recursive, --workers, -h
#
# Use --help or -h for detailed usage information.

# Example 3: Get help to see proper usage
camotext.exe --help
# Shows complete help documentation with examples
```

### Basic File Anonymization

```bash
# Anonymize a text file to STDOUT (using long forms)
camotext.exe --input document.txt                               # Windows
./camotext --input document.txt                                 # macOS/Linux

# Anonymize a text file to STDOUT (using short forms)
camotext.exe -i document.txt                                    # Windows
./camotext -i document.txt                                      # macOS/Linux

# Anonymize a PDF and save to file (using long forms)
camotext.exe --input report.pdf --output anonymized_report.pdf  # Windows
./camotext --input report.pdf --output anonymized_report.pdf    # macOS/Linux

# Anonymize a PDF and save to file (using short forms)
camotext.exe -i report.pdf -o anonymized_report.pdf            # Windows
./camotext -i report.pdf -o anonymized_report.pdf              # macOS/Linux
```

### Raw Text Processing

```bash
# Process raw text string (Windows)
camotext.exe --input "John Doe works at Acme Corp and can be reached at john@acme.com"

# Process raw text string (macOS/Linux)
./camotext --input "John Doe works at Acme Corp and can be reached at john@acme.com"

# Process with custom hash length
camotext.exe --input "Sensitive data here" --hash-length 12     # Windows
./camotext --input "Sensitive data here" --hash-length 12       # macOS/Linux
```

### Priority Text Processing

```bash
# Process with priority text that must be anonymized first (Windows)
camotext.exe --priority "confidential" --input "This is confidential information"

# Process with multiple priority texts (macOS/Linux)
./camotext --priority "classified" --priority "top secret" --input document.txt

# Priority text with file output
camotext.exe --priority "internal use only" --input report.pdf --output anonymized_report.pdf

# Batch processing with priority text
camotext.exe --priority "proprietary" --input-dir ./documents --output-dir ./anonymized
```

### Term Reversion

```bash
# Revert specific terms from anonymized files (Windows)
camotext.exe --input-dir ./anonymized --revert "John Doe" --revert "Acme Corp"

# Revert specific terms (macOS/Linux)
./camotext --input-dir ./anonymized --revert "John Doe" --revert "Acme Corp"

# Revert with short form
camotext.exe --input-dir ./anonymized -r "John Doe" -r "Acme Corp"

# Revert with custom key directory
camotext.exe --input-dir ./anonymized --key-dir ./keys --revert "confidential"

# Revert with recursive processing
camotext.exe --input-dir ./anonymized --revert "internal" --recursive
```

### Category Ignoring (Reversion)

The `--ignore-category` option allows you to specify entity categories that should be ignored (reverted to original text
after anonymization). This is useful when you want to anonymize most entities but keep certain types visible.

```bash
# Ignore organization names (Windows)
camotext.exe --ignore-category "organization" --input document.txt --output anonymized.txt

# Ignore multiple categories (macOS/Linux)
./camotext --ignore-category "person" --ignore-category "location" --input report.pdf --output clean_report.pdf

# Case-insensitive category matching
camotext.exe --ignore-category "ORGANIZATION" --ignore-category "person" --input data.txt

# Batch processing with ignored categories
./camotext --input-dir ./docs --output-dir ./processed --ignore-category "organization" --ignore-category "location"

# Combine with priority text
camotext.exe --priority "confidential" --ignore-category "organization" --input document.txt
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
- And more... (see main documentation for complete list)

### Key File Placement

When using `--dump-key` with output directories, the key file is automatically placed in the appropriate location:

```bash
# Single file: key placed in same directory as output
camotext.exe --input document.txt --output ./processed/anonymized.txt --dump-key key.json
# Result: key saved to ./processed/key.json (not ./key.json)

# Batch processing: keys placed in output directory when --key-dir not specified
./camotext --input-dir ./docs --output-dir ./processed --dump-key keys.json
# Result: individual key files placed in ./processed/ directory

# Explicit key directory overrides automatic placement
camotext.exe --input-dir ./docs --output-dir ./processed --key-dir ./audit --dump-key keys.json
# Result: keys saved to ./audit/ directory (--key-dir takes precedence)
```

### Entity Detection

```bash
# List detected entity types without anonymization
camotext.exe --input document.txt --list-entities               # Windows
./camotext --input document.txt --list-entities                 # macOS/Linux

# Example output:
# ["PERSON", "EMAIL_ADDRESS", "ORGANIZATION"]
```

### Key Management

```bash
# Generate anonymization key file for single file
camotext.exe --input document.txt --output anonymized.txt --dump-key key.json  # Windows
./camotext --input document.txt --output anonymized.txt --dump-key key.json    # macOS/Linux

# Use default key naming (no value provided)
camotext.exe --input document.txt --output anonymized.txt --dump-key
# Result: Creates anonymized_key.json in the same directory as output

# Batch processing with centralized key directory
camotext.exe --input-dir ./docs --output-dir ./anonymized --key-dir ./keys --dump-key batch_key.json

# Batch processing with automatic individual key files (no --key-dir specified)
camotext.exe --input-dir ./docs --output-dir ./anonymized --dump-key keys.json
# Result: Creates individual key files like document1_key.json, document2_key.json, etc. in ./anonymized/

# Batch processing with default key directory (no value for --key-dir)
camotext.exe --input-dir ./docs --output-dir ./anonymized --key-dir --dump-key
# Result: Keys saved to ./anonymized/ directory with default naming

# Batch processing with explicit key directory (overrides automatic behavior)
camotext.exe --input-dir ./docs --output-dir ./anonymized --key-dir ./audit --dump-key keys.json
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
camotext.exe --input-dir ./documents --output-dir ./anonymized --key-dir ./keys

# Process entire directory (macOS/Linux)
./camotext --input-dir ./documents --output-dir ./anonymized --key-dir ./keys

# Process with specific file types
camotext.exe --input-dir ./docs --output-dir ./anon --extensions .txt .pdf

# Recursive processing with parallel workers
camotext.exe --input-dir ./projects --output-dir ./anonymized ^
             --key-dir ./keys --recursive --workers 4

# List all entities in a directory
camotext.exe --input-dir ./documents --list-entities
```

### Advanced Batch Examples

```bash
# Large dataset processing with 8 workers (Windows)
camotext.exe --input-dir C:\data\sensitive --output-dir C:\data\anonymized ^
             --key-dir C:\data\keys --workers 8 --hash-length 12

# Large dataset processing (macOS/Linux)
./camotext --input-dir /data/sensitive --output-dir /data/anonymized \
           --key-dir /data/keys --workers 8 --hash-length 12

# Process only specific file types recursively
camotext.exe --input-dir ./mixed_files --output-dir ./cleaned ^
             --extensions .docx .pdf --recursive

# Batch entity analysis
camotext.exe --input-dir ./compliance_docs --list-entities > entity_report.json

# Advanced priority text processing
camotext.exe --priority "Operation Blackbird" --priority "classified" ^
             --input-dir ./sensitive --output-dir ./sanitized ^
             --key-dir ./keys --workers 4

# Complex processing with category ignoring
camotext.exe --priority "confidential" --ignore-category "organization" ^
             --ignore-category "location" --input-dir ./documents ^
             --output-dir ./processed --dump-key audit.json --workers 6

# Selective anonymization keeping organizations visible
./camotext --input-dir ./compliance_docs --output-dir ./redacted \
           --ignore-category "organization" --ignore-category "entity" \
           --recursive --workers 8
```

## Term Reversion Feature

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
camotext.exe --input-dir ./anonymized --revert "John Doe" --revert "Acme Corp"

# Basic reversion (macOS/Linux)
./camotext --input-dir ./anonymized --revert "John Doe" --revert "Acme Corp"

# Revert with short form
camotext.exe --input-dir ./anonymized -r "John Doe" -r "Acme Corp"

# Revert with custom key directory
camotext.exe --input-dir ./anonymized --key-dir ./keys --revert "confidential"

# Revert with recursive processing
camotext.exe --input-dir ./anonymized --revert "internal" --recursive

# Revert with parallel processing
camotext.exe --input-dir ./anonymized --revert "sensitive" --workers 4

# Revert multiple terms in one command
camotext.exe --input-dir ./anonymized --revert "John Doe" --revert "Acme Corp" --revert "confidential"

# Revert with specific file types
camotext.exe --input-dir ./anonymized --revert "classified" --extensions .txt .pdf
```

### Example Workflow

```bash
# 1. Initial anonymization
camotext.exe --input-dir ./documents --output-dir ./anonymized --key-dir ./keys

# 2. Later, revert specific terms
camotext.exe --input-dir ./anonymized --key-dir ./keys --revert "John Doe"

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

- **Selective disclosure**: Revert only specific names or terms for authorized personnel
- **Audit trails**: Restore original text for compliance or verification purposes
- **Data sharing**: Revert non-sensitive terms while keeping sensitive data anonymized
- **Document review**: Temporarily restore specific information for review processes
- **Compliance**: Meet regulatory requirements for data handling and disclosure

## Priority Text Feature

CamoText supports priority text anonymization, which allows you to specify text that should be anonymized verbatim with
the highest priority, before other entity types are processed.

### How Priority Text Works

1. **First Priority**: Priority texts are processed before any other entity detection
2. **Verbatim Matching**: Priority text is matched exactly as specified (case-insensitive)
3. **PRIORITY Entity Type**: All priority text receives the entity type "PRIORITY" with a hash
4. **Longest First**: Multiple priority texts are processed longest-first to avoid conflicts
5. **Full Integration**: Priority texts appear in anonymization keys and can be reverted like any other entity

### Priority Text Examples

```bash
# Simple priority text (using long forms)
camotext.exe --priority "Project Aurora" --input document.txt
# Result: "Project Aurora" becomes <PRIORITY_abc123de>

# Simple priority text (using short forms)
camotext.exe -p "Project Aurora" -i document.txt
# Result: "Project Aurora" becomes <PRIORITY_abc123de>

# Multiple priority texts (using long forms)
./camotext --priority "classified" --priority "top secret" --priority "confidential" --input report.txt

# Multiple priority texts (using short forms)
./camotext -p "classified" -p "top secret" -p "confidential" -i report.txt

# Priority text takes precedence over entity detection (using long forms)
camotext.exe --priority "John Smith" --input "John Smith is a person"
# Result: <PRIORITY_hash> is a person (not <PERSON_hash>)

# Priority text takes precedence over entity detection (using short forms)
camotext.exe -p "John Smith" -i "John Smith is a person"
# Result: <PRIORITY_hash> is a person (not <PERSON_hash>)
```

### GUI vs CLI Priority Text

- **GUI**: Use the "Priority Text" button to manage priority texts through an interactive window
- **CLI**: Use `--priority "text"` argument (can be repeated multiple times)
- **Persistence**: Priority texts are session-specific and don't persist between runs

## Processing Modes

The CLI supports three processing modes:

### 1. Single File Processing

Process individual files or raw text strings:

```bash
# File processing
camotext.exe --input C:\path\to\document.pdf                    # Windows
./camotext --input /path/to/document.pdf                        # macOS/Linux

# Raw text processing
camotext.exe --input "This is raw text to anonymize"
./camotext --input "This is raw text to anonymize"
```

### 2. Batch Directory Processing

Process entire directories with built-in parallelization:

```bash
# Basic directory processing
camotext.exe --input-dir ./source --output-dir ./processed      # Windows
./camotext --input-dir ./source --output-dir ./processed        # macOS/Linux

# Advanced batch processing (Windows)
camotext.exe --input-dir ./data --output-dir ./anonymized ^
             --key-dir ./keys --recursive --workers 4 ^
             --extensions .txt .pdf .docx

# Advanced batch processing (macOS/Linux)
./camotext --input-dir ./data --output-dir ./anonymized \
           --key-dir ./keys --recursive --workers 4 \
           --extensions .txt .pdf .docx
```

### 3. Entity Analysis Mode

Analyze entity types without anonymization:

```bash
# Single file analysis
camotext.exe --input document.txt --list-entities               # Windows
./camotext --input document.txt --list-entities                 # macOS/Linux

# Batch entity analysis
camotext.exe --input-dir ./documents --list-entities            # Windows
./camotext --input-dir ./documents --list-entities              # macOS/Linux
```

## Output Handling

### Single File Output

#### Standard Output (Default)

When `--output` is not specified, anonymized text is printed to STDOUT:

```bash
camotext.exe --input "John works at Acme" > output.txt          # Windows
./camotext --input "John works at Acme" > output.txt            # macOS/Linux
```

#### File Output

Specify `--output` to save directly to a file:

```bash
camotext.exe --input document.pdf --output anonymized.pdf       # Windows
./camotext --input document.pdf --output anonymized.pdf         # macOS/Linux
```

### Batch Processing Output

#### Directory Structure

Batch processing maintains directory structure with prefixed filenames:

```bash
# Input structure:
./docs/
├── file1.txt
├── reports/report1.pdf
└── data/sheet1.xlsx

# Output structure (with --input-dir ./docs --output-dir ./anonymized):
./anonymized/
├── anon_file1.txt
├── reports/anon_report1.pdf
└── data/anon_sheet1.xlsx
```

#### Progress Reporting

Real-time progress updates during batch processing:

```bash
Found 15 files to process...
[1/15] ✓ file1.txt (3 entities)
[2/15] ✓ reports/report1.pdf (12 entities)
[3/15] ✗ corrupted.docx - Error: Could not read file
[4/15] ✓ data/sheet1.xlsx (8 entities)
...

Batch processing complete:
  ✓ Successful: 14
  ✗ Failed: 1
  📁 Output directory: ./anonymized
  🔑 Keys directory: ./keys
```

#### Key Management

If you elect to save anonymization keys with --dump-key, they are saved with corresponding filenames:

```bash
# Keys structure (with --key-dir ./keys):
./keys/
├── file1.json
├── reports/report1.json
└── data/sheet1.json
```

## Error Handling

### Exit Codes

| Code | Meaning                                                 |
| ---- | ------------------------------------------------------- |
| 0    | Success                                                 |
| 1    | General error (invalid arguments, file not found, etc.) |

### Common Error Messages

```bash
# Missing required arguments
Error: Either --input or --input-dir is required.
Error: --output-dir is required when using --input-dir.

# File/directory not found
Error: Input directory './nonexistent' does not exist or is not a directory.
Error reading input: Unsupported file type: .xyz

# Permission errors
Error creating output directories: Permission denied: /restricted/path/
Error saving output file: Permission denied: /restricted/path/

# Invalid file format
Error reading input: Unsupported file type. Please use one of: .txt, .pdf, .docx, .xlsx, .csv, .rtf

# Batch processing errors
No files found with extensions ('.txt', '.pdf') in './empty_dir'.
```

## Integration Examples

### CI/CD Pipeline

```yaml
# GitHub Actions example
- name: Anonymize documents
  run: |
    ./camotext --input sensitive_report.pdf \
               --output public_report.pdf \
               --dump-key audit_key.json \
               --ignore-category "organization"
```

### Shell Script Integration

```bash
#!/bin/bash
# batch_anonymize.sh - Using native batch processing

INPUT_DIR="./sensitive_docs"
OUTPUT_DIR="./anonymized_docs"
KEY_DIR="./keys"

# Single command for entire directory (assuming CamoText executable in PATH)
./camotext \
    --input-dir "$INPUT_DIR" \
    --output-dir "$OUTPUT_DIR" \
    --key-dir "$KEY_DIR" \
    --recursive \
    --workers 4 \
    --hash-length 10 \
    --ignore-category "organization" \
    --ignore-category "location"
```

### Python Script Integration

```python
import subprocess
import json
import sys
from pathlib import Path

def anonymize_file(input_path, output_path=None, hash_length=8, ignore_categories=None, executable_path='./camotext'):
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

def batch_anonymize(input_dir, output_dir, key_dir=None, workers=4, recursive=True, ignore_categories=None, executable_path='./camotext'):
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
# Windows: Use 'camotext.exe', macOS/Linux: Use './camotext'
anonymized_content = anonymize_file('document.txt', 'anonymized.txt',
                                   ignore_categories=['organization', 'location'],
                                   executable_path='camotext.exe')
batch_success = batch_anonymize('./docs', './anonymized', './keys', workers=8,
                               ignore_categories=['organization'],
                               executable_path='camotext.exe')
```

## Performance Considerations

### File Size Limits

- Maximum file size: 50MB per file
- Maximum PDF pages: 800 per file
- Large files are processed in 5KB chunks for memory efficiency

### Processing Speed

- Text files: ~1MB/second per worker
- PDF files: ~500KB/second per worker (depends on complexity)
- Excel/CSV files: ~2MB/second per worker
- **Note**: Using `--ignore-category` has minimal performance impact (~5% overhead)

### Parallel Processing

- **Workers**: Use `--workers N` to process multiple files simultaneously
- **Optimal worker count**: 2-4x CPU cores for I/O bound tasks
- **Memory scaling**: Each worker requires ~200MB base + file processing memory
- **Network storage**: Reduce workers when processing files over network

### Memory Usage

- Base memory per worker: ~200MB (NLP model loading)
- Additional per file: ~10MB per 1MB of input text
- Batch processing: Memory usage scales with worker count
- Chunking prevents memory issues with large files

### Batch Processing Performance

```bash
# Example processing times (4-core system)
# 100 small files (1MB each): ~25 seconds with --workers 4
# 10 large files (10MB each): ~50 seconds with --workers 2
# 1000 documents recursively: Use --workers 8 for optimal throughput
```

## Security Best Practices

### Key Management

1. **Secure Storage**: Store anonymization keys in secure, access-controlled locations
2. **Audit Trail**: Keep logs of anonymization operations
3. **Key Rotation**: Generate new keys for different data sets

```bash
# Example with timestamped keys
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
./camotext --input sensitive.txt --dump-key "keys/key_$TIMESTAMP.json"
```

### Data Handling

1. **Validate Input**: Ensure input files are from trusted sources
2. **Clean Output**: Verify anonymized output meets compliance requirements
3. **Secure Deletion**: Securely delete original files after anonymization

## Troubleshooting

### Common Issues

**Issue**: "Could not load 'en_core_web_md' model"

```bash
# Solution: This should not occur with bundled executable, but if it does:
# Re-download the executable from the official distribution
```

**Issue**: "Permission denied" when writing output

```bash
# Solution: Check file permissions and directory access
chmod 755 output_directory/
```

**Issue**: CLI arguments not recognized

```bash
# Solution: Ensure you're using the correct argument format
camotext.exe --input="file.txt" --output="out.txt"        # Correct
camotext.exe -input file.txt -output out.txt              # Incorrect (missing second dash)
```

**Issue**: Invalid category name for `--ignore-category`

```bash
# Solution: Use exact category names (case-insensitive)
camotext.exe --ignore-category "PERSON"                   # Correct
camotext.exe --ignore-category "person"                   # Correct (case-insensitive)
camotext.exe --ignore-category "people"                   # Incorrect (use "PERSON")
```

**Issue**: Key files not placed in expected location

```bash
# When using --dump-key with output directories, keys are placed relative to output
# This behavior is automatic and intended for better organization
camotext.exe --input doc.txt --output ./processed/doc.txt --dump-key key.json
# Result: key saved to ./processed/key.json (not ./key.json)
```

### Debug Mode

For verbose output during processing:

```bash
# Redirect stderr to see warnings and debug info (Windows)
camotext.exe --input document.txt 2> debug.log

# Redirect stderr to see warnings and debug info (macOS/Linux)
./camotext --input document.txt 2> debug.log
```

## API Reference

### Core Function

The CLI internally uses the `anonymize_text_raw()` function:

```python
def anonymize_text_raw(text: str, hash_length: int = 8) -> Tuple[str, Dict[str, str]]:
    """
    Anonymizes raw text using the CamoText engine.

    Args:
        text: Input text to anonymize
        hash_length: Length of anonymization hashes

    Returns:
        Tuple of (anonymized_text, key_mapping)
    """
```

### Supported Entity Types

The entity types detected and anonymized by the system can be found in the CamoText User Guide

## AI Agent Integration

CamoText is well-suited for AI agents and local bots due to its executable-based CLI design.

### Excellent AI Agent Compatibility

#### ✅ **Perfect CLI Interface**

- **No GUI dependencies** - Runs headless in any environment
- **Structured input/output** - Predictable command syntax and responses
- **Standard exit codes** - Proper success/failure signaling
- **JSON output** - Machine-readable entity lists and anonymization keys

#### ✅ **Zero-Setup Deployment**

```bash
# AI agent can simply invoke the executable
./camotext --input "sensitive data" --output result.txt --dump-key key.json
```

- **Self-contained executable** - No Python environment or dependency management
- **Cross-platform** - Same interface on Windows, macOS, Linux
- **Immediate availability** - Download and run, no installation steps

#### ✅ **Batch Processing Power**

```bash
# Process entire directories with parallel workers
./camotext --input-dir ./data --output-dir ./anonymized --workers 8 --key-dir ./keys
```

- **Native parallelization** - Built-in multi-threading for large datasets
- **Progress reporting** - Real-time status updates for monitoring
- **Error resilience** - Continues processing even if individual files fail

#### ✅ **Flexible Integration Patterns**

**1. Direct subprocess calls:**

```python
import subprocess
import json

result = subprocess.run(['./camotext', '--input', text, '--list-entities'],
                       capture_output=True, text=True)
entities = json.loads(result.stdout)
```

**2. File-based workflows:**

```python
# Agent writes files, processes them, reads results
with open('temp_input.txt', 'w') as f:
    f.write(sensitive_data)

subprocess.run(['./camotext', '--input', 'temp_input.txt',
                '--output', 'anonymized.txt', '--dump-key', 'key.json'])

# Read anonymized results and key mapping
```

**3. Streaming/pipeline integration:**

```bash
# AI agent can pipe data through CamoText
echo "sensitive text" | ./camotext --input /dev/stdin --output /dev/stdout
```

### AI Agent Use Cases

#### 🤖 **Document Processing Pipelines**

- **RAG systems** - Anonymize documents before embedding/indexing
- **Compliance automation** - Batch process incoming documents
- **Data preparation** - Clean datasets before ML training

#### 🤖 **Real-time Chat/API Integration**

```python
def anonymize_user_input(text, keep_organizations=True):
    cmd = ['./camotext', '--input', text]
    if keep_organizations:
        cmd.extend(['--ignore-category', 'organization'])

    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout.strip()

# Agent can anonymize messages before processing
clean_text = anonymize_user_input(user_message, keep_organizations=True)
response = llm.generate(clean_text)
```

#### 🤖 **Automated Workflows**

- **Email processing** - Anonymize attachments automatically
- **Log sanitization** - Clean sensitive data from system logs
- **Report generation** - Process and anonymize reports before sharing

### Minor Considerations for AI Agents

#### ⚠️ **Startup Time**

- **~2-3 second initialization** - Consider for high-frequency calls
- **Mitigation**: Batch multiple operations or keep process running

#### ⚠️ **File Management**

- **Temporary files** - Agents need to handle cleanup
- **Directory structure** - Batch processing maintains folder hierarchy

#### ⚠️ **Resource Usage**

- **~200MB base memory** per worker
- **Plan worker count** based on available system resources

### Sample AI Agent Integration

```python
class CamoTextAgent:
    def __init__(self, executable_path='./camotext'):
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
agent = CamoTextAgent(executable_path='camotext.exe')  # Windows
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
camotext.exe --config config.json --input document.txt
```

2. **Complex Configuration**

```json
{
  "priority": ["Project Aurora", "Operation Blackbird", "classified information"],
  "hash_length": 12,
  "ignore_category": ["ORGANIZATION", "LOCATION", "DATE_TIME"]
}
```

Usage:

```bash
camotext.exe --config config.json --input-dir ./documents --output-dir ./anonymized
```

3. **Minimal Configuration**

```json
{
  "ignore_category": ["PERSON"]
}
```

Usage:

```bash
camotext.exe --config config.json --input document.txt --output anonymized.txt
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
camotext.exe --config C:\config\anonymization.json --input document.txt
camotext.exe --config .\config.json --input document.txt

# macOS/Linux
./camotext --config /etc/camotext/config.json --input document.txt
./camotext --config ./config.json --input document.txt
```

#### Configuration File Override

Command-line arguments take precedence over configuration file settings. This allows you to:

1. Use a base configuration file for common settings
2. Override specific settings via command line when needed

Example:

```bash
# config.json has hash_length: 8, but command line overrides it to 12
camotext.exe --config config.json --hash-length 12 --input document.txt
```

### Examples

Basic file anonymization:

```bash
# Using long form arguments
camotext.exe --input document.pdf --output anonymized.txt

# Using short form arguments
camotext.exe -i document.pdf -o anonymized.txt

# Using configuration file
camotext.exe --config config.json --input document.txt
```

Anonymization with priority text:

```bash
# Using long form arguments
camotext.exe --input file.txt --priority "John Doe" --priority "Acme Corp"

# Using short form arguments
camotext.exe -i file.txt -p "John Doe" -p "Acme Corp"

# Using configuration file
camotext.exe --config config.json --input file.txt
```

Batch processing:

```bash
# Basic batch processing
camotext.exe --input-dir ./docs --output-dir ./output --recursive

# Batch processing with configuration
camotext.exe --config config.json --input-dir ./docs --output-dir ./output
```

List entities without anonymization:

```bash
camotext.exe --input file.txt --list-entities
```

Ignore specific categories:

```bash
# Using command line arguments
camotext.exe --input file.txt --ignore-category PERSON --ignore-category EMAIL_ADDRESS

# Using configuration file
camotext.exe --config config.json --input file.txt
```

Supported file types: `.txt`, `.pdf`, `.docx`, `.xlsx`, `.csv`, `.rtf`
