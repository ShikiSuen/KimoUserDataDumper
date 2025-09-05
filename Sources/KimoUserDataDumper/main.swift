// (c) 2025 ShikiSuen (BSD-3-Clause License).
// ====================
// This code is released under the BSD-3-Clause license

import Foundation
import ObjcKimoCommunicator

class KimoCommunicator: ObjcKimoCommunicator {
    static let shared: KimoCommunicator = .init()
    
    func dumpAllUserPhrases() -> [(key: String, value: String)] {
        var results: [(key: String, value: String)] = []
        
        guard Self.shared.establishConnection() else {
            print("Error: Failed to establish connection to Yahoo KeyKey IME service.")
            return results
        }
        
        guard Self.shared.hasValidConnection() else {
            print("Error: No valid connection to Yahoo KeyKey IME service.")
            return results
        }
        
        let totalRows = Self.shared.userPhraseDBTotalAmountOfRows()
        print("Found \(totalRows) user phrases in Yahoo KeyKey IME database.")
        
        for i in 0..<totalRows {
            let fetched = Self.shared.userPhraseDBDictionary(atRow: i)
            if let key = fetched["BPMF"], let text = fetched["Text"] {
                results.append((key: key, value: text))
            }
        }
        
        return results
    }
    
    func exportToFile(path: String) -> Bool {
        guard Self.shared.establishConnection() else {
            print("Error: Failed to establish connection to Yahoo KeyKey IME service.")
            return false
        }
        
        guard Self.shared.hasValidConnection() else {
            print("Error: No valid connection to Yahoo KeyKey IME service.")
            return false
        }
        
        return Self.shared.exportUserPhraseDB(toFile: path)
    }
}

enum OutputFormat: String, CaseIterable {
    case plain = "plain"
    case json = "json"
    case csv = "csv"
}

struct CLIOptions {
    var outputFormat: OutputFormat = .plain
    var outputFile: String?
    var useBuiltinExport: Bool = false
    var showHelp: Bool = false
}

func parseArguments() -> CLIOptions {
    var options = CLIOptions()
    let arguments = CommandLine.arguments
    
    var i = 1
    while i < arguments.count {
        let arg = arguments[i]
        
        switch arg {
        case "-h", "--help":
            options.showHelp = true
        case "-f", "--format":
            if i + 1 < arguments.count {
                let formatString = arguments[i + 1]
                if let format = OutputFormat(rawValue: formatString) {
                    options.outputFormat = format
                } else {
                    print("Warning: Unknown format '\(formatString)'. Using plain format.")
                }
                i += 1
            }
        case "-o", "--output":
            if i + 1 < arguments.count {
                options.outputFile = arguments[i + 1]
                i += 1
            }
        case "--builtin-export":
            options.useBuiltinExport = true
        default:
            print("Warning: Unknown argument '\(arg)'")
        }
        i += 1
    }
    
    return options
}

func printHelp() {
    print("""
    KimoUserDataDumper - Export user phrases from Yahoo KeyKey IME
    
    Usage: KimoUserDataDumper [OPTIONS]
    
    Options:
        -h, --help                Show this help message
        -f, --format FORMAT       Output format (plain, json, csv). Default: plain
        -o, --output FILE         Output to file instead of stdout
        --builtin-export          Use Yahoo KeyKey's built-in export functionality
    
    Examples:
        KimoUserDataDumper                              # Print all phrases in plain format
        KimoUserDataDumper -f json                      # Print all phrases in JSON format
        KimoUserDataDumper -o output.txt                # Save to file in plain format
        KimoUserDataDumper -f csv -o phrases.csv        # Save to CSV file
        KimoUserDataDumper --builtin-export -o data.txt # Use built-in export to file
    """)
}

func formatOutput(_ phrases: [(key: String, value: String)], format: OutputFormat) -> String {
    switch format {
    case .plain:
        return phrases.map { "\($0.key)\t\($0.value)" }.joined(separator: "\n")
        
    case .json:
        let jsonData = phrases.map { ["key": $0.key, "value": $0.value] }
        if let data = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return "[]"
        
    case .csv:
        let header = "BPMF,Text"
        let rows = phrases.map { "\"\($0.key)\",\"\($0.value)\"" }
        return ([header] + rows).joined(separator: "\n")
    }
}

func main() {
    let options = parseArguments()
    
    if options.showHelp {
        printHelp()
        return
    }
    
    let communicator = KimoCommunicator.shared
    
    if options.useBuiltinExport {
        guard let outputFile = options.outputFile else {
            print("Error: --builtin-export requires -o/--output option to specify output file.")
            exit(1)
        }
        
        print("Using Yahoo KeyKey's built-in export functionality...")
        if communicator.exportToFile(path: outputFile) {
            print("Successfully exported user phrases to: \(outputFile)")
        } else {
            print("Error: Failed to export user phrases.")
            exit(1)
        }
        return
    }
    
    // Regular export using our custom implementation
    print("Connecting to Yahoo KeyKey IME...")
    let phrases = communicator.dumpAllUserPhrases()
    
    if phrases.isEmpty {
        print("No user phrases found or failed to connect to Yahoo KeyKey IME.")
        exit(1)
    }
    
    let output = formatOutput(phrases, format: options.outputFormat)
    
    if let outputFile = options.outputFile {
        do {
            try output.write(toFile: outputFile, atomically: true, encoding: .utf8)
            print("Successfully exported \(phrases.count) user phrases to: \(outputFile)")
        } catch {
            print("Error writing to file: \(error)")
            exit(1)
        }
    } else {
        print(output)
    }
}

main()