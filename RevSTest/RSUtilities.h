//
//  RSUtilities.h
//  RevS
//
//  Created by lzbdd on 13-8-1.
//  Copyright (c) 2013年 lzbdd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@protocol RSIPListDelegate;

@interface RSUtilities : NSObject

+ (NSArray *)localIpList;

- (void)remoteIpList;
- (void)remoteIpListInString;

+ (NSArray *)contactListWithKValue:(NSUInteger)k;

+ (NSString *)getLocalIPAddress;

+ (NSString *)hashFromString:(NSString *)string;
//+ (NSArray *)listOfHashedFilenames;
+ (NSArray *)listOfFilenames;

@property (nonatomic,strong) id <RSIPListDelegate> delegate;

@end

@protocol RSIPListDelegate <NSObject>

@optional

- (void)didRecieveRemoteIPList:(id)list;

@end