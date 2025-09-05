# KimoUserDataDumper

A Swift-written CLI application to export all user phrases from Yahoo KeyKey IME using NSConnection.

## Requirements

- **macOS 10.15 or later, before macOS 27** for the main Swift version
- **macOS 10.9 or later, before macOS 27** for the pure Objective-C version (located in `ForMojaveAndEarlier/`)
- **Yahoo KeyKey IME** installed and running on either Intel Mac or Rosetta 2
- **Swift 5.9 or later** (for the main version)
- **Xcode Command Line Tools**

## Installation

### Swift Version (Main - Recommended)

```bash
git clone https://github.com/ShikiSuen/KimoUserDataDumper.git
cd KimoUserDataDumper
swift build -c release
```

The compiled executable will be located at `.build/release/KimoUserDataDumper`.

### Pure Objective-C Version (For Older Systems)

For macOS Mojave (10.14) and earlier systems, use the pure Objective-C version:

```bash
git clone https://github.com/ShikiSuen/KimoUserDataDumper.git
cd KimoUserDataDumper/ForMojaveAndEarlier
make
```

See `ForMojaveAndEarlier/README.md` for detailed instructions on the pure Objective-C version.

## Usage

### Basic Usage

```bash
# Print all phrases in plain format to console
./KimoUserDataDumper

# Print all phrases in JSON format
./KimoUserDataDumper -f json

# Save to file in plain format
./KimoUserDataDumper -o output.txt

# Save to CSV file
./KimoUserDataDumper -f csv -o phrases.csv

# Use Yahoo KeyKey's built-in export functionality
./KimoUserDataDumper --builtin-export -o data.txt
```

### Command Line Options

- `-h`, `--help`: Show help message
- `-f`, `--format FORMAT`: Output format (`plain`, `json`, `csv`). Default: `plain`
- `-o`, `--output FILE`: Output to file instead of stdout
- `--builtin-export`: Use Yahoo KeyKey's built-in export functionality

### Output Formats

#### Plain Format (Default)
```
ㄅㄆㄇㄈ	example text
ㄉㄊㄋㄌ	another example
```

#### JSON Format
```json
[
  {
    "key": "ㄅㄆㄇㄈ",
    "value": "example text"
  },
  {
    "key": "ㄉㄊㄋㄌ", 
    "value": "another example"
  }
]
```

#### CSV Format
```csv
BPMF,Text
"ㄅㄆㄇㄈ","example text"
"ㄉㄊㄋㄌ","another example"
```

## Technical Details

This application uses NSConnection (deprecated but still functional) to communicate with Yahoo KeyKey IME's service named "YahooKeyKeyService". It connects to the IME's user phrase database and extracts:

- **BPMF**: The phonetic key (Bopomofo symbols)  
- **Text**: The corresponding text/phrase

The implementation is specifically designed to work with Yahoo KeyKey IME 2012 final version.

### Architecture

- `ObjcKimoCommunicator`: Objective-C module handling NSConnection communication
- `KimoUserDataDumper`: Swift CLI application with multiple output format support
- `ForMojaveAndEarlier/`: Pure Objective-C version for compatibility with older macOS systems

## Prerequisites

1. **Yahoo KeyKey IME must be installed and running** on your macOS system
2. The IME service "YahooKeyKeyService" must be active
3. You must have user-defined phrases in your Yahoo KeyKey database

## Limitations

- **macOS only**: This application only works on macOS due to its dependency on NSConnection and AppKit
- **Yahoo KeyKey specific**: Designed specifically for Yahoo KeyKey IME, will not work with other input methods
- **Deprecated API**: Uses NSConnection which is deprecated but still functional with Yahoo KeyKey IME

## Troubleshooting

### "Failed to establish connection"
- Ensure Yahoo KeyKey IME is installed and running
- Make sure you have some user phrases defined in Yahoo KeyKey
- Try restarting Yahoo KeyKey IME

### "No user phrases found"
- Verify that you have custom phrases added to Yahoo KeyKey IME
- Check Yahoo KeyKey preferences to ensure user phrase database is enabled

## License

This project is licensed under the BSD 3-Clause License. See [LICENSE](LICENSE) for details.

## Disclaimer

與奇摩輸入法有關的原始碼是由 Yahoo 奇摩以 `SPDX Identifier: BSD-3-Clause` 釋出的，但敝模組只是藉由其 Protocol API 與該當程式進行跨執行緒通訊，所以屬於合理使用範圍。

*The original code related to Yahoo KeyKey IME was released by Yahoo under `SPDX Identifier: BSD-3-Clause`. This module only communicates with the program through its Protocol API via inter-thread communication, which falls under reasonable use.*

## Credits

(c) 2025 ShikiSuen (BSD-3-Clause License)
