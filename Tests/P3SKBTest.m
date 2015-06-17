//
//  TSTripleSec
//
//  Created by Gabriel on 1/16/14.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

@import TSTripleSec;

#import "NATestUtils.h"

@interface P3SKBTest : XCTestCase
@end

@implementation P3SKBTest

- (NSData *)loadBase64Data:(NSString *)file {
  NSString *path = [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension] ofType:[file pathExtension]];
  return [[NSData alloc] initWithBase64EncodedData:[[NSData alloc] initWithContentsOfFile:path] options:0];
}

- (NSString *)loadFile:(NSString *)file {
  NSString *path = [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension] ofType:[file pathExtension]];
  NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
  NSAssert(contents, @"No contents at file: %@", file);
  return contents;
}

- (void)test {
  NSData *privateKey = [@"deadbeef" dataFromHexString];
  NSData *publicKey = [@"ff00ff00" dataFromHexString];
  P3SKB *key = [P3SKB P3SKBWithPrivateKey:privateKey password:@"toomanysecrets" publicKey:publicKey error:nil];
  XCTAssertNotNil(key);
  
  NSError *error = nil;
  NSData *decrypt = [key decryptPrivateKeyWithPassword:@"toomanysecrets" error:&error];
  XCTAssertEqualObjects(privateKey, decrypt);
  
  P3SKB *keyOut = [P3SKB P3SKBFromData:[key data] error:&error];
  XCTAssertNotNil(keyOut);
  
  //NSLog(@"encryptedPrivateData: %@", [[keyOut encryptedPrivateKey] na_hexString]);
  
  NSData *privateKeyDataOut = [keyOut decryptPrivateKeyWithPassword:@"toomanysecrets" error:&error];
  XCTAssertEqualObjects(privateKey, privateKeyDataOut);
  XCTAssertEqualObjects(publicKey, keyOut.publicKey);
}

/*
- (void)testFile {
  NSData *keyData = [self loadBase64Data:@"test_key.p3skb"];

  NSError *error = nil;
  P3SKB *key = [P3SKB P3SKBFromData:keyData error:&error];
  XCTAssertNotNil(key);
  
  NSData *unencryptedPrivateKey = [key decryptPrivateKeyWithPassword:@"Gj8vvokBfxC2xx" error:nil];
  XCTAssertNotNil(unencryptedPrivateKey);
}

- (void)testHexFile {
  NSError *error = nil;
  NSData *keyData = [[self loadFile:@"test_key_hex.p3skb"] dataFromHexString];
  
  NSMutableDictionary *dict = [MPMessagePackReader readData:keyData error:&error];
  
  dict[@"hash"][@"value"] = [dict[@"hash"][@"value"] base64EncodedStringWithOptions:0];
  dict[@"body"][@"pub"] = [dict[@"body"][@"pub"] base64EncodedStringWithOptions:0];
  dict[@"body"][@"priv"][@"data"] = [dict[@"body"][@"priv"][@"data"] base64EncodedStringWithOptions:0];
  
  NSLog(@"Dict: %@", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding]);
  
  P3SKB *key = [P3SKB P3SKBFromData:keyData error:&error];
  XCTAssertNotNil(key);
  
  NSData *unencryptedPrivateKey = [key decryptPrivateKeyWithPassword:@"Gj8vvokBfxC2xx" error:nil];
  XCTAssertNotNil(unencryptedPrivateKey);
}
 */

- (void)testNSCoding {
  NSData *privateKey = [@"deadbeef" dataFromHexString];
  NSData *publicKey = [@"ff00ff00" dataFromHexString];
  P3SKB *key = [P3SKB P3SKBWithPrivateKey:privateKey password:@"toomanysecrets" publicKey:publicKey error:nil];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:key];
  P3SKB *keyOut = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  XCTAssertEqualObjects(key, keyOut);
}

/*
- (void)testChangePassword {
  NSData *keyData = [self loadBase64Data:@"test_key.p3skb"];
  P3SKB *key = [P3SKB P3SKBFromData:keyData error:nil];
  NSData *unencryptedPrivateKey1 = [key decryptPrivateKeyWithPassword:@"Gj8vvokBfxC2xx" error:nil];
  
  [key changeFromPassword:@"Gj8vvokBfxC2xx" toPassword:@"otherpassword" error:nil];
  
  NSData *unencryptedPrivateKey2 = [key decryptPrivateKeyWithPassword:@"otherpassword" error:nil];
  XCTAssertEqualObjects(unencryptedPrivateKey1, unencryptedPrivateKey2);
}
*/

@end