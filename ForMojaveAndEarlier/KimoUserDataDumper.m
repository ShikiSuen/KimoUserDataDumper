// (c) 2025 ShikiSuen (BSD-3-Clause License).
// ====================
// This code is released under the BSD-3-Clause license
// 
// 免責聲明：
// 與奇摩輸入法有關的原始碼是由 Yahoo 奇摩以 `SPDX Identifier: BSD-3-Clause` 釋出的，
// 但敝模組只是藉由其 Protocol API 與該當程式進行跨執行緒通訊，所以屬於合理使用範圍。
//
// Pure Objective-C version for macOS Mojave and earlier systems.

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#define kYahooKimoDataObjectConnectionName @"YahooKeyKeyService"

// MARK: - Protocol Definition

@protocol KimoUserDataReaderService
- (BOOL)userPhraseDBCanProvideService;
- (int)userPhraseDBNumberOfRow;
- (NSDictionary *)userPhraseDBDictionaryAtRow:(int)row;
- (bool)exportUserPhraseDBToFile:(NSString *)path;
@end

// MARK: - Output Format Enum

typedef enum {
    OutputFormatPlain,
    OutputFormatJSON,
    OutputFormatCSV
} OutputFormat;

// MARK: - CLI Options Structure

@interface CLIOptions : NSObject
@property (nonatomic) OutputFormat outputFormat;
@property (nonatomic, strong) NSString *outputFile;
@property (nonatomic) BOOL useBuiltinExport;
@property (nonatomic) BOOL showHelp;
@end

@implementation CLIOptions

- (instancetype)init {
    self = [super init];
    if (self) {
        _outputFormat = OutputFormatPlain;
        _outputFile = nil;
        _useBuiltinExport = NO;
        _showHelp = NO;
    }
    return self;
}

- (void)dealloc {
    [_outputFile release];
    [super dealloc];
}

@end

// MARK: - Kimo Communicator Class

@interface KimoCommunicator : NSObject
@property (nonatomic, strong) id xpcConnection;

- (BOOL)establishConnection;
- (BOOL)hasValidConnection;
- (void)disconnect;
- (BOOL)userPhraseDBCanProvideService;
- (int)userPhraseDBTotalAmountOfRows;
- (NSDictionary<NSString*, NSString*> *)userPhraseDBDictionaryAtRow:(int)row;
- (BOOL)exportUserPhraseDBToFile:(NSString *)path;
- (NSArray<NSDictionary<NSString*, NSString*>*> *)dumpAllUserPhrases;
@end

@implementation KimoCommunicator

- (void)dealloc {
    [self disconnect];
    [_xpcConnection release];
    [super dealloc];
}

- (void)disconnect {
    _xpcConnection = nil;
}

- (BOOL)establishConnection {
    // 奇摩輸入法2012最終版在建置的時候還沒用到 NSXPCConnection，實質上並不支援
    // NSXPCConnection。 因此，這裡使用 NSXPCConnection 的話反而會壞事。
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    _xpcConnection = [NSConnection rootProxyForConnectionWithRegisteredName:
                                     kYahooKimoDataObjectConnectionName
                                                                     host:nil];
#pragma GCC diagnostic pop
    BOOL result = NO;
    if (_xpcConnection) {
        result = YES;
    }
    if (result) {
        [_xpcConnection setProtocolForProxy:@protocol(KimoUserDataReaderService)];
        printf("KimoUserDataDumper: Connection successful. Available data amount: %d.\n",
              [_xpcConnection userPhraseDBNumberOfRow]);
    }
    return result;
}

- (BOOL)hasValidConnection {
    return _xpcConnection != nil;
}

- (BOOL)userPhraseDBCanProvideService {
    return [self hasValidConnection] ? [_xpcConnection userPhraseDBCanProvideService] : NO;
}

- (int)userPhraseDBTotalAmountOfRows {
    return [self hasValidConnection] ? [_xpcConnection userPhraseDBNumberOfRow] : 0;
}

- (NSDictionary<NSString*, NSString*> *)userPhraseDBDictionaryAtRow:(int)row {
    return [self hasValidConnection] ? [_xpcConnection userPhraseDBDictionaryAtRow:row] : @{};
}

- (BOOL)exportUserPhraseDBToFile:(NSString *)path {
    return [self hasValidConnection] ? [_xpcConnection exportUserPhraseDBToFile:path] : NO;
}

- (NSArray<NSDictionary<NSString*, NSString*>*> *)dumpAllUserPhrases {
    NSMutableArray *results = [[[NSMutableArray alloc] init] autorelease];
    
    if (![self establishConnection]) {
        printf("Error: Failed to establish connection to Yahoo KeyKey IME service.\n");
        return results;
    }
    
    if (![self hasValidConnection]) {
        printf("Error: No valid connection to Yahoo KeyKey IME service.\n");
        return results;
    }
    
    int totalRows = [self userPhraseDBTotalAmountOfRows];
    printf("Found %d user phrases in Yahoo KeyKey IME database.\n", totalRows);
    
    for (int i = 0; i < totalRows; i++) {
        NSDictionary *fetched = [self userPhraseDBDictionaryAtRow:i];
        NSString *key = [fetched objectForKey:@"BPMF"];
        NSString *text = [fetched objectForKey:@"Text"];
        
        if (key && text) {
            NSDictionary *phraseDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       key, @"key",
                                       text, @"value",
                                       nil];
            [results addObject:phraseDict];
        }
    }
    
    return results;
}

@end

// MARK: - Utility Functions

CLIOptions *parseArguments(int argc, char *argv[]) {
    CLIOptions *options = [[[CLIOptions alloc] init] autorelease];
    
    for (int i = 1; i < argc; i++) {
        NSString *arg = [NSString stringWithUTF8String:argv[i]];
        
        if ([arg isEqualToString:@"-h"] || [arg isEqualToString:@"--help"]) {
            options.showHelp = YES;
        } else if ([arg isEqualToString:@"-f"] || [arg isEqualToString:@"--format"]) {
            if (i + 1 < argc) {
                NSString *formatString = [NSString stringWithUTF8String:argv[i + 1]];
                if ([formatString isEqualToString:@"plain"]) {
                    options.outputFormat = OutputFormatPlain;
                } else if ([formatString isEqualToString:@"json"]) {
                    options.outputFormat = OutputFormatJSON;
                } else if ([formatString isEqualToString:@"csv"]) {
                    options.outputFormat = OutputFormatCSV;
                } else {
                    printf("Warning: Unknown format '%s'. Using plain format.\n", [formatString UTF8String]);
                }
                i++;
            }
        } else if ([arg isEqualToString:@"-o"] || [arg isEqualToString:@"--output"]) {
            if (i + 1 < argc) {
                options.outputFile = [[NSString stringWithUTF8String:argv[i + 1]] retain];
                i++;
            }
        } else if ([arg isEqualToString:@"--builtin-export"]) {
            options.useBuiltinExport = YES;
        } else {
            printf("Warning: Unknown argument '%s'\n", [arg UTF8String]);
        }
    }
    
    return options;
}

void printHelp() {
    printf("KimoUserDataDumper - Export user phrases from Yahoo KeyKey IME\n");
    printf("\n");
    printf("Usage: KimoUserDataDumper [OPTIONS]\n");
    printf("\n");
    printf("Options:\n");
    printf("    -h, --help                Show this help message\n");
    printf("    -f, --format FORMAT       Output format (plain, json, csv). Default: plain\n");
    printf("    -o, --output FILE         Output to file instead of stdout\n");
    printf("    --builtin-export          Use Yahoo KeyKey's built-in export functionality\n");
    printf("\n");
    printf("Examples:\n");
    printf("    KimoUserDataDumper                              # Print all phrases in plain format\n");
    printf("    KimoUserDataDumper -f json                      # Print all phrases in JSON format\n");
    printf("    KimoUserDataDumper -o output.txt                # Save to file in plain format\n");
    printf("    KimoUserDataDumper -f csv -o phrases.csv        # Save to CSV file\n");
    printf("    KimoUserDataDumper --builtin-export -o data.txt # Use built-in export to file\n");
    printf("\n");
}

NSString *escapeStringForCSV(NSString *str) {
    // Escape double quotes by doubling them
    NSString *escaped = [str stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
    return [NSString stringWithFormat:@"\"%@\"", escaped];
}

NSString *formatOutput(NSArray<NSDictionary<NSString*, NSString*>*> *phrases, OutputFormat format) {
    NSMutableString *result = [[[NSMutableString alloc] init] autorelease];
    
    switch (format) {
        case OutputFormatPlain:
            for (NSDictionary *phrase in phrases) {
                [result appendFormat:@"%@\t%@\n", [phrase objectForKey:@"key"], [phrase objectForKey:@"value"]];
            }
            break;
            
        case OutputFormatJSON: {
            NSMutableArray *jsonArray = [[[NSMutableArray alloc] init] autorelease];
            for (NSDictionary *phrase in phrases) {
                NSDictionary *jsonObj = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [phrase objectForKey:@"key"], @"key",
                                        [phrase objectForKey:@"value"], @"value",
                                        nil];
                [jsonArray addObject:jsonObj];
            }
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray
                                                              options:NSJSONWritingPrettyPrinted
                                                                error:&error];
            if (jsonData && !error) {
                NSString *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
                [result appendString:jsonString];
            } else {
                [result appendString:@"[]"];
            }
            break;
        }
            
        case OutputFormatCSV:
            [result appendString:@"BPMF,Text\n"];
            for (NSDictionary *phrase in phrases) {
                [result appendFormat:@"%@,%@\n", 
                 escapeStringForCSV([phrase objectForKey:@"key"]), 
                 escapeStringForCSV([phrase objectForKey:@"value"])];
            }
            break;
    }
    
    return result;
}

// MARK: - Main Function

int main(int argc, char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    CLIOptions *options = parseArguments(argc, argv);
    
    if (options.showHelp) {
        printHelp();
        [pool release];
        return 0;
    }
    
    KimoCommunicator *communicator = [[[KimoCommunicator alloc] init] autorelease];
    
    if (options.useBuiltinExport) {
        if (!options.outputFile) {
            printf("Error: --builtin-export requires -o/--output option to specify output file.\n");
            [pool release];
            return 1;
        }
        
        printf("Using Yahoo KeyKey's built-in export functionality...\n");
        
        if (![communicator establishConnection]) {
            printf("Error: Failed to establish connection to Yahoo KeyKey IME service.\n");
            [pool release];
            return 1;
        }
        
        if ([communicator exportUserPhraseDBToFile:options.outputFile]) {
            printf("Successfully exported user phrases to: %s\n", [options.outputFile UTF8String]);
        } else {
            printf("Error: Failed to export user phrases.\n");
            [pool release];
            return 1;
        }
        [pool release];
        return 0;
    }
    
    // Regular export using our custom implementation
    printf("Connecting to Yahoo KeyKey IME...\n");
    NSArray *phrases = [communicator dumpAllUserPhrases];
    
    if ([phrases count] == 0) {
        printf("No user phrases found or failed to connect to Yahoo KeyKey IME.\n");
        [pool release];
        return 1;
    }
    
    NSString *output = formatOutput(phrases, options.outputFormat);
    
    if (options.outputFile) {
        NSError *error;
        BOOL success = [output writeToFile:options.outputFile
                                atomically:YES
                                  encoding:NSUTF8StringEncoding
                                     error:&error];
        if (success) {
            printf("Successfully exported %lu user phrases to: %s\n", 
                   (unsigned long)[phrases count], [options.outputFile UTF8String]);
        } else {
            printf("Error writing to file: %s\n", [[error localizedDescription] UTF8String]);
            [pool release];
            return 1;
        }
    } else {
        printf("%s\n", [output UTF8String]);
    }
    
    [pool release];
    return 0;
}