// (c) 2025 ShikiSuen (BSD-3-Clause License).
// ====================
// This code is released under the BSD-3-Clause license
// 
// Based on vChewing Project's KimoDataReader implementation
// Original code (c) 2021 and onwards The vChewing Project (MIT-NTL License)
// 
// 免責聲明：
// 與奇摩輸入法有關的原始碼是由 Yahoo 奇摩以 `SPDX Identifier: BSD-3-Clause` 釋出的，
// 但敝模組只是藉由其 Protocol API 與該當程式進行跨執行緒通訊，所以屬於合理使用範圍。

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KimoUserDataReaderService
- (BOOL)userPhraseDBCanProvideService;
- (int)userPhraseDBNumberOfRow;
- (NSDictionary *)userPhraseDBDictionaryAtRow:(int)row;
- (bool)exportUserPhraseDBToFile:(NSString *)path;
@end

/// 不要理會 Xcode 對 NSDistantObject 的過期狗吠。
/// 奇摩輸入法是用 NSConnection 寫的，
/// 換用 NSXPCConnection 只會製造更多的問題。
@interface ObjcKimoCommunicator : NSObject

/// 嘗試連線。
- (bool)establishConnection;

/// 偵測連線是否有效。
- (bool)hasValidConnection;

/// 斷開連線。
- (void)disconnect;

// Conforming KimoUserDataReaderService protocol.
- (BOOL)userPhraseDBCanProvideService;
- (int)userPhraseDBTotalAmountOfRows;
- (NSDictionary<NSString*, NSString*> *)userPhraseDBDictionaryAtRow:(int)row;
- (bool)exportUserPhraseDBToFile:(NSString *)path;
@end

NS_ASSUME_NONNULL_END