//
//  P3SKB.h
//  TSTripleSec
//
//  Created by Gabriel on 7/3/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface P3SKB : NSObject <NSSecureCoding>

/*!
 Create P3SKB from unencrypted key.
 
 This operation may take awhile since the encryption process can be pretty heavy.
 
 @param key Unencrypted private key data
 @param password Password
 @param error Out error
 @result Key or nil if error
 */
+ (instancetype)P3SKBWithKey:(NSData *)key password:(NSString *)password error:(NSError * __autoreleasing *)error;

/*!
 Serialized.
 */
- (NSData *)data;

@end
