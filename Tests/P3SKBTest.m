//
//  P3SKBTest.m
//

#import <GHUnit/GHUnit.h>

#import "P3SKB.h"
#import <NAChloride/NAChloride.h>
#import <MPMessagePack/MPMessagePack.h>

@interface P3SKBTest : GHTestCase
@end

@implementation P3SKBTest

- (void)test {
  NSData *privateKey = [@"deadbeef" na_dataFromHexString];
  NSData *publicKey = [@"ff00ff00" na_dataFromHexString];
  P3SKB *key = [P3SKB P3SKBWithPrivateKey:privateKey password:@"toomanysecrets" publicKey:publicKey error:nil];
  GHAssertNotNil(key, nil);
  
  NSError *error = nil;
  NSData *decrypt = [key decryptPrivateKeyWithPassword:@"toomanysecrets" error:&error];
  GHAssertEqualObjects(privateKey, decrypt, nil);
  
  P3SKB *keyOut = [P3SKB P3SKBFromData:[key data] error:&error];
  GHAssertNotNil(keyOut, nil);
  
  //NSLog(@"encryptedPrivateData: %@", [[keyOut encryptedPrivateKey] na_hexString]);
  
  NSData *privateKeyDataOut = [keyOut decryptPrivateKeyWithPassword:@"toomanysecrets" error:&error];
  GHAssertEqualObjects(privateKey, privateKeyDataOut, nil);
  GHAssertEqualObjects(publicKey, keyOut.publicKey, nil);
}

- (void)testFile {
  NSString *keyPath = [[NSBundle mainBundle] pathForResource:@"test_key" ofType:@"p3skb"];
  NSString *keyStrData = [NSString stringWithContentsOfFile:keyPath encoding:NSUTF8StringEncoding error:NULL];
  NSData *keyData = [[NSData alloc] initWithBase64EncodedString:keyStrData options:0];

  NSError *error = nil;
  P3SKB *key = [P3SKB P3SKBFromData:keyData error:&error];
  GHAssertNotNil(key, nil);
  
  GHTestLog(@"publicKey: %@", [[NSString alloc] initWithData:key.publicKey encoding:NSUTF8StringEncoding]);
  NSData *unencryptedPrivateKey = [key decryptPrivateKeyWithPassword:@"Gj8vvokBfxC2xx" error:nil];
  
  GHTestLog(@"unencryptedPrivateKey: %@", unencryptedPrivateKey);
}

- (void)testNSCoding {
  NSData *privateKey = [@"deadbeef" na_dataFromHexString];
  NSData *publicKey = [@"ff00ff00" na_dataFromHexString];
  P3SKB *key = [P3SKB P3SKBWithPrivateKey:privateKey password:@"toomanysecrets" publicKey:publicKey error:nil];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:key];
  P3SKB *keyOut = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  GHAssertEqualObjects(key, keyOut, nil);
}

@end