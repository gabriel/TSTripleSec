//
//  P3SKB.m
//  TSTripleSec
//
//  Created by Gabriel on 7/3/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "P3SKB.h"

#import "TSTripleSec.h"

#import <NACrypto/NACrypto.h>
#import <MPMessagePack/MPMessagePack.h>
#import <GHODictionary/GHODictionary.h>

@interface P3SKB ()
@property NSData *encryptedPrivateKey;
@property P3SKBEncryptionType encryptionType;
@property NSData *publicKey;
@end

@implementation P3SKB

+ (instancetype)P3SKBWithPrivateKey:(NSData *)privateKey password:(NSString *)password publicKey:(NSData *)publicKey error:(NSError * __autoreleasing *)error {
  if (!password) {
    [NSException raise:NSInvalidArgumentException format:@"Can't create P3SKB with no password"];
    return nil;
  }
              
  P3SKB *sk = [[P3SKB alloc] init];
  sk.publicKey = publicKey;
  sk.encryptionType = P3SKBEncryptionTypeTripleSec;
  sk.encryptedPrivateKey = [sk _encryptPrivateKey:privateKey password:password error:error];
  if (!sk.encryptedPrivateKey) {
    return nil;
  }
  return sk;
}

+ (instancetype)P3SKBWithEncryptedPrivateKey:(NSData *)encryptedPrivateKey encryptionType:(P3SKBEncryptionType)encryptionType publicKey:(NSData *)publicKey {
  P3SKB *sk = [[P3SKB alloc] init];
  sk.encryptedPrivateKey = encryptedPrivateKey;
  sk.encryptionType = encryptionType;
  sk.publicKey = publicKey;
  return sk;
}

+ (instancetype)P3SKBFromKeyBundle:(NSString *)keyBundle error:(NSError * __autoreleasing *)error {
  NSData *data = [[NSData alloc] initWithBase64EncodedString:keyBundle options:0];
  if (!data) {
    if (error) *error = [NSError errorWithDomain:@"TripleSec" code:1200 userInfo:@{NSLocalizedDescriptionKey: @"Invalid Base64 encoding"}];
    return nil;
  }
  return [self P3SKBFromData:data error:error];
}

+ (instancetype)P3SKBFromData:(NSData *)data error:(NSError * __autoreleasing *)error {
  NSParameterAssert(data);
  id obj = [MPMessagePackReader readData:data options:0 error:error];
  if (![obj isKindOfClass:NSDictionary.class]) {
    if (error) *error = [NSError errorWithDomain:@"TripleSec" code:1201 userInfo:@{NSLocalizedDescriptionKey: @"Invalid data"}];
    return nil;
  }
  NSDictionary *dict = obj;
  if (!dict) {
    if (error) *error = [NSError errorWithDomain:@"TripleSec" code:1201 userInfo:@{NSLocalizedDescriptionKey: @"Invalid data"}];
    return nil;
  }
  
  NSInteger version = [dict[@"version"] integerValue];
  if (version != 1) {
    if (error) *error = [NSError errorWithDomain:@"TripleSec" code:1201 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported version"}];
    return nil;
  }
  
  NSDictionary *hash = dict[@"hash"];
  NSInteger hashType = [hash[@"type"] integerValue];
  if (hashType != 8) {
    if (error) *error = [NSError errorWithDomain:@"TripleSec" code:1202 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported hash type"}];
    return nil;
  }
  
  // Check hash
  NSData *hashData = hash[@"value"];
  dict[@"hash"][@"value"] = [NSData data];
  
  NSData *hashDataComputed = [NADigest digestForData:[dict mp_messagePack:MPMessagePackWriterOptionsSortDictionaryKeys] algorithm:NADigestAlgorithmSHA2_256];
  if (![hashDataComputed isEqual:hashData]) {
    if (error) *error = [NSError errorWithDomain:@"TripleSec" code:1204 userInfo:@{NSLocalizedDescriptionKey: @"Invalid hash"}];
    return nil;
  }
  
  NSDictionary *body = dict[@"body"];
  if (!body) {
    if (error) *error = [NSError errorWithDomain:@"TripleSec" code:1205 userInfo:@{NSLocalizedDescriptionKey: @"Missing body"}];
    return nil;
  }
  
  NSDictionary *priv = body[@"priv"];
  
  NSInteger encryptionType = [priv[@"encryption"] integerValue];
  if (encryptionType != 3) {
    if (error) *error = [NSError errorWithDomain:@"TripleSec" code:1206 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported encryption type"}];
    return nil;
  }
  
  NSData *encryptedPrivateKey = priv[@"data"];
  NSData *publicKey = body[@"pub"];
  
  if (!encryptedPrivateKey || !publicKey) {
    if (error) *error = [NSError errorWithDomain:@"TripleSec" code:1207 userInfo:@{NSLocalizedDescriptionKey: @"Missing private or public key material"}];
    return nil;
  }
  
  return [self P3SKBWithEncryptedPrivateKey:encryptedPrivateKey encryptionType:P3SKBEncryptionTypeTripleSec publicKey:publicKey];
}

- (NSData *)_encryptPrivateKey:(NSData *)privateKey password:(NSString *)password error:(NSError * __autoreleasing *)error {
  TSTripleSec *tripleSec = [[TSTripleSec alloc] init];
  return [tripleSec encrypt:privateKey key:[password dataUsingEncoding:NSUTF8StringEncoding] error:error];
}

- (NSData *)data {
  NSData *data = [self _P3SKBForHashData:[NSData data]];
  NSData *hashData = [NADigest digestForData:data algorithm:NADigestAlgorithmSHA2_256];
  
  return [self _P3SKBForHashData:hashData];
}

- (NSString *)keyBundle {
  return [[self data] base64EncodedStringWithOptions:0];
}

- (NSData *)decryptPrivateKeyWithPassword:(NSString *)password error:(NSError * __autoreleasing *)error {
  TSTripleSec *tripleSec = [[TSTripleSec alloc] init];
  return [tripleSec decrypt:_encryptedPrivateKey key:[password dataUsingEncoding:NSUTF8StringEncoding] error:error];
}

- (BOOL)changeFromPassword:(NSString *)fromPassword toPassword:(NSString *)toPassword error:(NSError * __autoreleasing *)error {
  NSData *data = [self decryptPrivateKeyWithPassword:fromPassword error:error];
  if (!data) return NO;
  data = [self _encryptPrivateKey:data password:toPassword error:error];
  if (!data) return NO;
  NSAssert(_encryptedPrivateKey != data, @"Unchanged");
  _encryptedPrivateKey = data;
  return YES;
}

- (NSData *)_P3SKBForHashData:(NSData *)hashData {
  NSDictionary *dict =
  @{
    @"version": @(1),
    @"tag": @(513),
    @"hash": @{
        @"type": @(8),
        @"value": hashData,
        },
    @"body": @{
        @"priv": @{
            @"data": _encryptedPrivateKey,
            @"encryption": @(3),
            },
        @"pub": _publicKey,
        }
    };
  return [dict mp_messagePack:MPMessagePackWriterOptionsSortDictionaryKeys];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
  P3SKB *skb = [[self.class alloc] init];
  skb.publicKey = [_publicKey copy];
  skb.encryptedPrivateKey = [_encryptedPrivateKey copy];
  return skb;
}

#pragma mark Equals/Hash

- (BOOL)isEqual:(id)object {
  return ([object isKindOfClass:[P3SKB class]] &&
          [[object encryptedPrivateKey] isEqual:_encryptedPrivateKey] &&
          [[object publicKey] isEqual:_publicKey]);
}

- (NSUInteger)hash {
  return [_encryptedPrivateKey hash] ^ [_publicKey hash];
}

#pragma mark NSCoding

+ (BOOL)supportsSecureCoding { return YES; }

- (id)initWithCoder:(NSCoder *)decoder {
  NSData *data = [decoder decodeObjectOfClass:[NSData class] forKey:@"data"];
  return [P3SKB P3SKBFromData:data error:nil];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:[self data] forKey:@"data"];
}

@end
