//
//  TSTripleSec
//
//  Created by Gabriel on 1/16/14.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "NATestUtils.h"

@import TSTripleSec;

@interface TSTripleSecTest : XCTestCase
@end

@implementation TSTripleSecTest

- (void)test {
  NSData *message = [@"this is a secret message" dataUsingEncoding:NSUTF8StringEncoding];
  NSData *key = [@"toomanysecrets" dataUsingEncoding:NSUTF8StringEncoding];
  
  NSError *error = nil;
  TSTripleSec *tripleSec = [[TSTripleSec alloc] init];
  NSData *encrypted = [tripleSec encrypt:message key:key error:&error];
  XCTAssertNil(error);
  
  NSData *decrypted = [tripleSec decrypt:encrypted key:key error:&error];
  XCTAssertNil(error);
  
  XCTAssertEqualObjects(message, decrypted);
}

- (void)testDecrypt {
  // triplesec --key toomanysecrets enc 'this is a really secret message'
  NSData *encrypted = [@"1c94d7de0000000378ad843339b7328da65be613c4208f8d50b11c689eefac9c9825b40025b0a5ccc4e1d7c13b2997f85163f1d0ae807575a309a4483ed034032bc4a10782b2966f6b0df2eec58ace6a3dae7d9911c024b860139c677c4291b33c6d5a9256e76e2621e24f19cc4035b9c8a90ef859e5c86992b8a3f3f2ead880d1a740671594293ba28b09b7fed06c7df2a15e9bf0a473841da194625aaac9f97fff8e7da973bc5881edc9293a16f55da654aa4caff1465a3a16b58d8d1a86516070559a61fafaf3131f032a692642af37dddfc91580eb5720760536284bab463921ada601212e5f2b510396fb60ff" dataFromHexString];
  
  NSData *key = [@"toomanysecrets" dataUsingEncoding:NSUTF8StringEncoding];
  
  NSError *error = nil;
  TSTripleSec *tripleSec = [[TSTripleSec alloc] init];
  NSData *decrypted = [tripleSec decrypt:encrypted key:key error:&error];
  XCTAssertNil(error);
  
  NSData *message = [@"this is a really secret message" dataUsingEncoding:NSUTF8StringEncoding];
  XCTAssertEqualObjects(message, decrypted);
}

// TODO
- (void)_testVectors {
  NSString *path = [[NSBundle mainBundle] pathForResource:@"vectors" ofType:@"json"];
  NSData *data = [NSData dataWithContentsOfFile:path];
  NSArray *testVectors = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  NSAssert(testVectors, nil);
  
  for (NSDictionary *test in testVectors) {
    NSData *key = [test[@"key"] dataFromHexString];
    NSData *ciphertext = [test[@"ciphertext"] dataFromHexString];
    NSData *plaintext = [test[@"plaintext"] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    TSTripleSec *tripleSec = [[TSTripleSec alloc] init];
    //NSData *encrypted = [tripleSec encrypt:plaintext key:key error:&error];
    //GHAssertNil(error, nil);
    NSData *decrypted = [tripleSec decrypt:ciphertext key:key error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(plaintext, decrypted);
  }
}

@end
