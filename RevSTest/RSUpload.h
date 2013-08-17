//
//  RSUpload.h
//  RevS
//
//  Created by lzbdd on 13-8-1.
//  Copyright (c) 2013年 lzbdd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RSUploadDelegate <NSObject>

@optional

- (void)didUploadFile:(NSString *)fileName;

@end

@interface RSUpload : NSObject

+ (RSUpload *)sharedInstance;
+ (void)uploadFile:(NSString *)fileName;
- (void)addDelegate:(id <RSUploadDelegate>)delegate;

@end
