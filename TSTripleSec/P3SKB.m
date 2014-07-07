//
//  P3SKB.m
//  TSTripleSec
//
//  Created by Gabriel on 7/3/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "P3SKB.h"

#import "TSTripleSec.h"

#import <MPMessagePack/MPMessagePack.h>

@interface P3SKB ()
@property NSData *encryptedKey;
@end

@implementation P3SKB

+ (instancetype)P3SKBWithKey:(NSData *)key password:(NSString *)password error:(NSError * __autoreleasing *)error {
  P3SKB *sk = [[P3SKB alloc] init];
  if ([sk _setKey:key password:password error:error]) {
    return sk;
  }
  return nil;
}

- (BOOL)_setKey:(NSData *)key password:(NSString *)password error:(NSError * __autoreleasing *)error {
  TSTripleSec *tripleSec = [[TSTripleSec alloc] init];
  _encryptedKey = [tripleSec encrypt:key key:[password dataUsingEncoding:NSUTF8StringEncoding] error:error];
  return !!_encryptedKey;
}

- (NSData *)key:(NSString *)password error:(NSError * __autoreleasing *)error {
  TSTripleSec *tripleSec = [[TSTripleSec alloc] init];
  return [tripleSec decrypt:_encryptedKey key:[password dataUsingEncoding:NSUTF8StringEncoding] error:error];
}

- (NSData *)data {
  NSData *data = [self _P3SKBForHashData:[NSData data]];
  NSData *hashData = [NADigest digestForData:data algorithm:NADigestAlgorithmSHA256];
  
  return [self _P3SKBForHashData:hashData];
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
          @"priv": _encryptedKey,
          @"encryption": @(3),
          }
      };
  
  return [dict mp_messagePack];
}

#pragma mark NSCoding

+ (BOOL)supportsSecureCoding { return YES; }

- (id)initWithCoder:(NSCoder *)decoder {
  self = [super init];
  if (!self) {
    return nil;
  }
  self.encryptedKey = [decoder decodeObjectOfClass:[NSData class] forKey:@"encryptedKey"];
  return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:self.encryptedKey forKey:@"encryptedKey"];
}

@end
