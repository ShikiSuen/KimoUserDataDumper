# KimoUserDataDumper - Pure Objective-C Version

This is a pure Objective-C implementation of KimoUserDataDumper, specifically designed for macOS Mojave (10.14) and earlier systems. It provides the same functionality as the main Swift version but with broader compatibility.

## Features

- **Complete standalone implementation** - Single `.m` file with no external dependencies
- **NSConnection support** - Uses deprecated NSConnection API for Yahoo KeyKey IME compatibility
- **Multiple output formats** - Plain text, JSON, and CSV export options
- **Flexible output** - Console output or file export
- **Built-in export** - Support for Yahoo KeyKey's native export functionality
- **Comprehensive CLI** - Full command-line argument parsing and help system

## System Requirements

- **macOS 10.10+** (compatible with Mojave and earlier)
- **Yahoo KeyKey IME** must be installed and running
- **Xcode Command Line Tools** for compilation

## Building

The pure Objective-C version can be built using the provided Makefile:

```bash
# Build the executable
make

# Show build help
make help

# Clean built files
make clean

# Install to system (optional)
make install
```

Alternatively, you can compile manually:

```bash
clang -Wall -Wextra -fobjc-arc -framework Foundation -framework AppKit -o KimoUserDataDumper KimoUserDataDumper.m
```

## Usage

The pure Objective-C version provides identical functionality to the Swift version:

```bash
# Export all phrases to console (plain format)
./KimoUserDataDumper

# Export as JSON to file
./KimoUserDataDumper -f json -o phrases.json

# Export as CSV
./KimoUserDataDumper -f csv -o phrases.csv

# Use Yahoo KeyKey's built-in export
./KimoUserDataDumper --builtin-export -o data.txt

# Show help
./KimoUserDataDumper --help
```

## Command Line Options

- `-h, --help` - Show help message
- `-f, --format FORMAT` - Output format (plain, json, csv). Default: plain
- `-o, --output FILE` - Output to file instead of stdout  
- `--builtin-export` - Use Yahoo KeyKey's built-in export functionality

## Output Formats

1. **Plain Text** (default): Tab-separated BPMF keys and text values
2. **JSON**: Structured array of key-value objects with pretty printing
3. **CSV**: Comma-separated values with proper quote escaping

## Implementation Notes

- Uses the same NSConnection protocol as the Swift version for maximum compatibility
- Implements proper memory management with ARC
- Provides comprehensive error handling and user feedback
- Single-file design for easy deployment and distribution
- Compatible with older macOS versions that don't support Swift Package Manager

## License

BSD-3-Clause License (same as the main project)

## Technical Details

The implementation combines the functionality of both `ObjcKimoCommunicator` and the Swift CLI interface into a single `.m` file:

- **KimoUserDataReaderService protocol** - Defines the Yahoo KeyKey IME service interface
- **KimoCommunicator class** - Handles NSConnection communication and data extraction
- **CLI parsing functions** - Process command-line arguments and options
- **Output formatting functions** - Handle plain text, JSON, and CSV export
- **Main function** - Orchestrates the complete application flow

This design ensures maximum compatibility while maintaining all the features of the modern Swift implementation.