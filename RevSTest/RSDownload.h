//
//  RSDownload.h
//  RevS
//
//  Created by lzbdd on 13-8-1.
//  Copyright (c) 2013年 lzbdd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RSDownloadDelegate;

@interface RSDownload : NSObject

+ (RSDownload *)sharedInstance;
- (void)downloadFile:(NSString *)fileName;
- (void)downloadFile:(NSString *)fileName fromIP:(NSString *)ipAddress;
- (void)addDelegate:(id <RSDownloadDelegate>)delegate;

@end

@protocol RSDownloadDelegate <NSObject>

@optional

- (void)didDownloadFile:(NSString *)fileName;

@end
