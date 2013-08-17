//
//  RSListener.h
//  RevS
//
//  Created by lzbdd on 13-8-8.
//  Copyright (c) 2013年 lzbdd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RSListenerDelegate;
@class RSMessager;

@interface RSListener : NSObject

@property (nonatomic,strong) NSMutableArray *delegates;

+ (RSListener *)sharedListener;
- (void)addDelegate:(id <RSListenerDelegate>)delegate;

@end

@protocol RSListenerDelegate <NSObject>

@optional

- (void)didRecieveDataWithType:(NSString *)type arguments:(NSArray *)arguments;
- (void)didSaveFile:(NSString *)fileName;
- (void)didUploadFile:(NSString *)fileName;

@end
