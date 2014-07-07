//
//  TSTripleSec.h
//  TripleSec
//
//  Created by Gabriel on 6/20/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <NAChloride/NAChloride.h>
#import "P3SKB.h"


@interface TSTripleSec : NSObject <NACryptoBox>

/*!
 Encypt data with key.
 @param data
 @param key
 @param error Out error
 @result Encrypted data or nil on error
 */
- (NSData *)encrypt:(NSData *)data key:(NSData *)key error:(NSError * __autoreleasing *)error;

/*!
 Decrypt data with key.
 @param data
 @param key
 @param error Out error
 @result Decrypted data or nil on error
 */
- (NSData *)decrypt:(NSData *)data key:(NSData *)key error:(NSError * __autoreleasing *)error;


@end
