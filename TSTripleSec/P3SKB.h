//
//  P3SKB.h
//  TSTripleSec
//
//  Created by Gabriel on 7/3/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, P3SKBEncryptionType) {
  P3SKBEncryptionTypeTripleSec = 3,
};

@interface P3SKB : NSObject <NSSecureCoding, NSCopying>

@property (readonly) NSData *publicKey;
@property (readonly) NSData *encryptedPrivateKey;

/*!
 Create P3SKB from unencrypted private and public key.
 
 This operation may take awhile since the encryption process can be pretty heavy.
 
 @param privateKey Unencrypted private key data
 @param password Password (to use to encrypt private key data)
 @param publicKey Public key data
 @param error Out error
 @result P3SKB or nil if error
 */
+ (instancetype)P3SKBWithPrivateKey:(NSData *)privateKey password:(NSString *)password publicKey:(NSData *)publicKey error:(NSError * __autoreleasing *)error;

/*!
 Create P3SKB from encrypted (TripleSec) private key and public key.
 @param encryptedPrivateKey Encrypted key
 @param encryptionType Encryption type (TripleSec)
 @param publicKey Public key data
 @result P3SKB or nil if error
 */
+ (instancetype)P3SKBWithEncryptedPrivateKey:(NSData *)encryptedPrivateKey encryptionType:(P3SKBEncryptionType)encryptionType publicKey:(NSData *)publicKey;

/*!
 Create P3SKB from serialized data.
 @param data Data
 @param error Out error
 @result P3SKB or nil if error
 */
+ (instancetype)P3SKBFromData:(NSData *)data error:(NSError * __autoreleasing *)error;

/*!
 Create P3SKB from key bundle (Base64 encoded data).
 @param keyBundle Key bundle
 @param error Out error
 @result P3SKB or nil if error
 */
+ (instancetype)P3SKBFromKeyBundle:(NSString *)keyBundle error:(NSError * __autoreleasing *)error;

/*!
 Decrypt private key.
 @param password
 @result Unecrypted key or nil if invalid password
 */
- (NSData *)decryptPrivateKeyWithPassword:(NSString *)password error:(NSError * __autoreleasing *)error;

/*!
 Change password.
 */
- (BOOL)changeFromPassword:(NSString *)fromPassword toPassword:(NSString *)toPassword error:(NSError * __autoreleasing *)error;

/*!
 Data (Message-packed encrypted TripleSec).
 */
- (NSData *)data;

/*!
 Key bundle (Base64 encoded mssage-packed encrypted TripleSec).
 */
- (NSString *)keyBundle;

@end
