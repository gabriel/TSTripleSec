//
//  P3SKBTest.m
//

#import <GRUnit/GRUnit.h>

#import "P3SKB.h"
#import <NAChloride/NAChloride.h>
#import <MPMessagePack/MPMessagePack.h>

@interface P3SKBTest : GRTestCase
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
  NSData *privateKey = [@"deadbeef" na_dataFromHexString];
  NSData *publicKey = [@"ff00ff00" na_dataFromHexString];
  P3SKB *key = [P3SKB P3SKBWithPrivateKey:privateKey password:@"toomanysecrets" publicKey:publicKey error:nil];
  GRAssertNotNil(key);
  
  NSError *error = nil;
  NSData *decrypt = [key decryptPrivateKeyWithPassword:@"toomanysecrets" error:&error];
  GRAssertEqualObjects(privateKey, decrypt);
  
  P3SKB *keyOut = [P3SKB P3SKBFromData:[key data] error:&error];
  GRAssertNotNil(keyOut);
  
  //NSLog(@"encryptedPrivateData: %@", [[keyOut encryptedPrivateKey] na_hexString]);
  
  NSData *privateKeyDataOut = [keyOut decryptPrivateKeyWithPassword:@"toomanysecrets" error:&error];
  GRAssertEqualObjects(privateKey, privateKeyDataOut);
  GRAssertEqualObjects(publicKey, keyOut.publicKey);
}

- (void)testFile {
  NSData *keyData = [self loadBase64Data:@"test_key.p3skb"];

  NSError *error = nil;
  P3SKB *key = [P3SKB P3SKBFromData:keyData error:&error];
  GRAssertNotNil(key);
  
  NSData *unencryptedPrivateKey = [key decryptPrivateKeyWithPassword:@"Gj8vvokBfxC2xx" error:nil];
  GRAssertNotNil(unencryptedPrivateKey);
}

- (void)testHexFile {
  NSError *error = nil;
  NSData *keyData = [[self loadFile:@"test_key_hex.p3skb"] na_dataFromHexString];
  
  NSMutableDictionary *dict = [MPMessagePackReader readData:keyData error:&error];
  
  dict[@"hash"][@"value"] = [dict[@"hash"][@"value"] base64EncodedStringWithOptions:0];
  dict[@"body"][@"pub"] = [dict[@"body"][@"pub"] base64EncodedStringWithOptions:0];
  dict[@"body"][@"priv"][@"data"] = [dict[@"body"][@"priv"][@"data"] base64EncodedStringWithOptions:0];
  
  GRTestLog(@"Dict: %@", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding]);
  
  P3SKB *key = [P3SKB P3SKBFromData:keyData error:&error];
  GRAssertNotNil(key);
  
  NSData *unencryptedPrivateKey = [key decryptPrivateKeyWithPassword:@"Gj8vvokBfxC2xx" error:nil];
  GRAssertNotNil(unencryptedPrivateKey);
}

- (void)testNSCoding {
  NSData *privateKey = [@"deadbeef" na_dataFromHexString];
  NSData *publicKey = [@"ff00ff00" na_dataFromHexString];
  P3SKB *key = [P3SKB P3SKBWithPrivateKey:privateKey password:@"toomanysecrets" publicKey:publicKey error:nil];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:key];
  P3SKB *keyOut = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  GRAssertEqualObjects(key, keyOut);
}

- (void)testChangePassword {
  NSData *keyData = [self loadBase64Data:@"test_key.p3skb"];
  P3SKB *key = [P3SKB P3SKBFromData:keyData error:nil];
  NSData *unencryptedPrivateKey1 = [key decryptPrivateKeyWithPassword:@"Gj8vvokBfxC2xx" error:nil];
  
  [key changeFromPassword:@"Gj8vvokBfxC2xx" toPassword:@"otherpassword" error:nil];
  
  NSData *unencryptedPrivateKey2 = [key decryptPrivateKeyWithPassword:@"otherpassword" error:nil];
  GRAssertEqualObjects(unencryptedPrivateKey1, unencryptedPrivateKey2);
}

@end