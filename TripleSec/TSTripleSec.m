//
//  TSTripleSec.m
//  TripleSec
//
//  Created by Gabriel on 6/20/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "TSTripleSec.h"

#define HMAC_SHA_512_KEYSIZE (48)
#define HMAC_SHA3_512_KEYSIZE (48)
#define XSALSA20_KEYSIZE (32)
#define TWO_FISH_CTR_KEYSIZE (32)
#define AES_256_CTR_KEYSIZE (32)

@interface TSTripleSecKeys : NSObject
@property NSArray *MACKeys;
@property NSArray *cipherKeys;
@end
@implementation TSTripleSecKeys
@end

@implementation TSTripleSec

- (TSTripleSecKeys *)keysForKey:(NSData *)key salt:(NSData *)salt error:(NSError * __autoreleasing *)error {
  NSUInteger totalKeysBytes = HMAC_SHA_512_KEYSIZE + HMAC_SHA3_512_KEYSIZE + XSALSA20_KEYSIZE + TWO_FISH_CTR_KEYSIZE + AES_256_CTR_KEYSIZE;
  NSData *keyMaterial = [NAScrypt scrypt:key salt:salt N:32768U r:8 p:1 length:totalKeysBytes error:error];
  if (!keyMaterial) return nil;
  
  size_t offset = 0;
  NSData *HMACSHA512Key = [NSData na_dataNoCopy:keyMaterial offset:offset length:HMAC_SHA_512_KEYSIZE];
  offset += HMAC_SHA_512_KEYSIZE;
  NSData *HMACSHA3Key = [NSData na_dataNoCopy:keyMaterial offset:offset length:HMAC_SHA3_512_KEYSIZE];
  offset += HMAC_SHA3_512_KEYSIZE;
  
  // The first key is the outermost cipher, so even though we encrypt XSalsa20, TwoFish, AES, the key material is sliced AES, Twofish, XSalsa20
  NSData *AESKey = [NSData na_dataNoCopy:keyMaterial offset:offset length:AES_256_CTR_KEYSIZE];
  offset += AES_256_CTR_KEYSIZE;
  NSData *twoFishKey = [NSData na_dataNoCopy:keyMaterial offset:offset length:TWO_FISH_CTR_KEYSIZE];
  offset += TWO_FISH_CTR_KEYSIZE;
  NSData *XSalsa20Key = [NSData na_dataNoCopy:keyMaterial offset:offset length:XSALSA20_KEYSIZE];
  offset += XSALSA20_KEYSIZE;
  
  NSAssert(totalKeysBytes == offset, @"Size mismatch");

  TSTripleSecKeys *keys = [[TSTripleSecKeys alloc] init];
  keys.MACKeys = @[HMACSHA512Key, HMACSHA3Key];
  keys.cipherKeys = @[XSalsa20Key, twoFishKey, AESKey];
  return keys;
}

- (NSData *)encrypt:(NSData *)data key:(NSData *)key error:(NSError * __autoreleasing *)error {
  NSData *salt = [NARandom randomData:16 error:error];
  if (!salt) return nil;
  
  TSTripleSecKeys *keys = [self keysForKey:key salt:salt error:error];
  if (!keys) return nil;
  NSData *HMACSHA512Key = keys.MACKeys[0];
  NSData *HMACSHA3Key = keys.MACKeys[1];
  NSData *XSalsa20Key = keys.cipherKeys[0];
  NSData *twoFishKey = keys.cipherKeys[1];
  NSData *AESKey = keys.cipherKeys[2];
  
  NSData *XSalsa20Nonce = [NARandom randomData:24 error:error];
  if (!XSalsa20Nonce) return nil;
  NAXSalsa20 *XSalsa20 = [[NAXSalsa20 alloc] init];
  data = [XSalsa20 encrypt:data nonce:XSalsa20Nonce key:XSalsa20Key error:error];
  if (!data) return nil;
  data = [NSData na_dataWithDatas:@[XSalsa20Nonce, data]];
  
  NSData *twoFishNonce = [NARandom randomData:16 error:error];
  if (!twoFishNonce) return nil;
  NATwoFish *twoFish = [[NATwoFish alloc] init];
  data = [twoFish encrypt:data nonce:twoFishNonce key:twoFishKey error:error];
  if (!data) return nil;
  data = [NSData na_dataWithDatas:@[twoFishNonce, data]];
  
  NSData *AESNonce = [NARandom randomData:16 error:error];
  if (!AESNonce) return nil;
  NAAES *AES = [[NAAES alloc] initWithAlgorithm:NAAESAlgorithm256CTR];
  data = [AES encrypt:data nonce:AESNonce key:AESKey error:error];
  if (!data) return nil;
  data = [NSData na_dataWithDatas:@[AESNonce, data]];
  
  NSData *encryptedMaterial = data;
  
  NSData *header = [@"1c94d7de00000003" na_dataFromHexString]; // Magic bytes + version number
  
  NSData *authenticatedData = [NSData na_dataWithDatas:@[header, salt, encryptedMaterial]];
  
  NAHMAC *hmac1 = [[NAHMAC alloc] initWithAlgorithm:NAHMACAlgorithmSHA512];
  NSData *mac1 = [hmac1 HMACForKey:HMACSHA512Key data:authenticatedData];
  
  NAHMAC *hmac2 = [[NAHMAC alloc] initWithAlgorithm:NAHMACAlgorithmSHA3_512];
  NSData *mac2 = [hmac2 HMACForKey:HMACSHA3Key data:authenticatedData];
  
  return [NSData na_dataWithDatas:@[header, salt, mac1, mac2, encryptedMaterial]];
}

- (NSData *)decrypt:(NSData *)data key:(NSData *)key error:(NSError * __autoreleasing *)error {
  
  if ([data length] < 8) {
    if (error) *error = [NSError errorWithDomain:@"TripleSec" code:200 userInfo:@{NSLocalizedDescriptionKey: @"This does not look like a TripleSec ciphertext"}];
    return nil;
  }
  
  size_t offset = 0;
  NSData *header = [NSData na_dataNoCopy:data offset:offset length:8];
  offset += 8;
  
  NSData *magicBytes = nil;
  NSData *version = nil;
  [header na_sliceNoCopyAtIndex:4 data:&magicBytes data:&version];
  
  if (![magicBytes isEqual:[@"1c94d7de" na_dataFromHexString]]) {
    if (error) *error = [NSError errorWithDomain:@"TripleSec" code:201 userInfo:@{NSLocalizedDescriptionKey: @"This does not look like a TripleSec ciphertext"}];
    return nil;
  }
  if (![version isEqual:[@"00000003" na_dataFromHexString]]) {
    if (error) *error = [NSError errorWithDomain:@"TripleSec" code:202 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported version"}];
    return nil;
  }
  
  if ([data length] < 232) {
    if (error) *error = [NSError errorWithDomain:@"TripleSec" code:203 userInfo:@{NSLocalizedDescriptionKey: @"This does not look like a TripleSec ciphertext"}];
    return nil;
  }
  
  NSData *salt = [NSData na_dataNoCopy:data offset:offset length:16];
  offset += 16;
  NSData *mac1 = [NSData na_dataNoCopy:data offset:offset length:64];
  offset += 64;
  NSData *mac2 = [NSData na_dataNoCopy:data offset:offset length:64];
  offset += 64;
  
  NSData *encryptedMaterial = [NSData na_dataNoCopy:data offset:offset length:([data length] - offset)];

  TSTripleSecKeys *keys = [self keysForKey:key salt:salt error:error];
  if (!keys) return nil;
  NSData *HMACSHA512Key = keys.MACKeys[0];
  NSData *HMACSHA3Key = keys.MACKeys[1];
  NSData *XSalsa20Key = keys.cipherKeys[0];
  NSData *twoFishKey = keys.cipherKeys[1];
  NSData *AESKey = keys.cipherKeys[2];
  
  NSData *authenticatedData = [NSData na_dataWithDatas:@[header, salt, encryptedMaterial]];
  
  NAHMAC *hmac1 = [[NAHMAC alloc] initWithAlgorithm:NAHMACAlgorithmSHA512];
  NSData *genMac1 = [hmac1 HMACForKey:HMACSHA512Key data:authenticatedData];
  
  NAHMAC *hmac2 = [[NAHMAC alloc] initWithAlgorithm:NAHMACAlgorithmSHA3_512];
  NSData *genMac2 = [hmac2 HMACForKey:HMACSHA3Key data:authenticatedData];
  
  BOOL checkMac1 = [mac1 na_isEqualConstantTime:genMac1];
  BOOL checkMac2 = [mac2 na_isEqualConstantTime:genMac2];
  
  if (!checkMac1 || !checkMac2) {
    if (error) *error = [NSError errorWithDomain:@"TripleSec" code:204 userInfo:@{NSLocalizedDescriptionKey: @"Failed authentication"}];
    return nil;
  }
  
  NSData *AESNonce = nil;
  NSData *AESData = nil;
  [encryptedMaterial na_sliceNoCopyAtIndex:16 data:&AESNonce data:&AESData];
  NAAES *AES = [[NAAES alloc] initWithAlgorithm:NAAESAlgorithm256CTR];
  encryptedMaterial = [AES decrypt:AESData nonce:AESNonce key:AESKey error:error];
  if (!encryptedMaterial) return nil;

  NSData *twoFishNonce = nil;
  NSData *twoFishData = nil;
  [encryptedMaterial na_sliceNoCopyAtIndex:16 data:&twoFishNonce data:&twoFishData];
  NATwoFish *twoFish = [[NATwoFish alloc] init];
  encryptedMaterial = [twoFish encrypt:twoFishData nonce:twoFishNonce key:twoFishKey error:error];
  if (!encryptedMaterial) return nil;
  
  NSData *XSalsa20Nonce = nil;
  NSData *XSalsa20Data = nil;
  [encryptedMaterial na_sliceNoCopyAtIndex:24 data:&XSalsa20Nonce data:&XSalsa20Data];
  NAXSalsa20 *XSalsa20 = [[NAXSalsa20 alloc] init];
  encryptedMaterial = [XSalsa20 encrypt:XSalsa20Data nonce:XSalsa20Nonce key:XSalsa20Key error:error];
  if (!encryptedMaterial) return nil;
  
  NSData *decrypted = encryptedMaterial;
  
  return decrypted;
}

@end
