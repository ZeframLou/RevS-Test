//
//  NSData+AES.h
//  Novelize
//
//  Created by 邦 泽 on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)
- (NSData*)AES256EncryptWithKey:(NSString*)key;
- (NSData*)AES256DecryptWithKey:(NSString*)key;
+ (NSData*) encryptString:(NSString*)plaintext withKey:(NSString*)key;
+ (NSString*) decryptData:(NSData*)ciphertext withKey:(NSString*)key;
@end
