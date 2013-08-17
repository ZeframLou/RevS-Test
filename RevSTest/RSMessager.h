//
//  RSMessager.h
//  RevSTest
//
//  Created by lzbdd on 13-8-15.
//  Copyright (c) 2013年 lzbdd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RSMessagerDelegate;

@interface RSMessager : NSObject

+ (RSMessager *)messagerWithPort:(uint16_t)port;
- (void)sendTcpMessage:(NSString *)message toHost:(NSString *)host tag:(NSInteger)tag;
- (void)addDelegate:(id <RSMessagerDelegate>)delegate;

@end

@protocol RSMessagerDelegate <NSObject>

@optional

- (void)messager:(RSMessager *)messager didRecieveData:(NSData *)data tag:(NSInteger)tag;
- (void)messager:(RSMessager *)messager didWriteDataWithTag:(NSInteger)tag;

@end
