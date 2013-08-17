//
//  RSUpload.m
//  RevS
//
//  Created by lzbdd on 13-8-1.
//  Copyright (c) 2013年 lzbdd. All rights reserved.
//

#import "RevS.h"

@interface RSUpload () <RSListenerDelegate>

@property (nonatomic,strong) NSMutableArray *delegates;

@end

@implementation RSUpload

@synthesize delegates;

+ (RSUpload *)sharedInstance
{
    static RSUpload *sharedInstance;
    if (!sharedInstance) {
        sharedInstance = [[RSUpload alloc]init];
        sharedInstance.delegates = [NSMutableArray array];
        [[RSListener sharedListener]addDelegate:sharedInstance];
    }
    return sharedInstance;
}

+ (void)uploadFile:(NSString *)fileName
{
    NSArray *contactList = [RSUtilities localIpList];
    
    for (NSUInteger i = 0; i < K_NEIGHBOUR; i++) {
        if (i < contactList.count) {
            NSString *messageString = [NSString stringWithFormat:@"UFILE_%@;%@;%d",fileName,[RSUtilities getLocalIPAddress],TTL];
            RSMessager *message = [RSMessager messagerWithPort:UPLOAD_PORT];
            [message addDelegate:[RSListener sharedListener]];
            [message sendTcpMessage:messageString toHost:[contactList objectAtIndex:i] tag:0];
        }
    }
}

- (void)addDelegate:(id <RSUploadDelegate>)delegate
{
    if (![delegates containsObject:delegate]) {
        [delegates addObject:delegate];
    }
}

#pragma mark - RSListenerDelegate

- (void)didUploadFile:(NSString *)fileName
{
    for (id delegate in delegates) {
        if ([delegate respondsToSelector:@selector(didUploadFile:)]) {
            [delegate didUploadFile:fileName];
        }
    }
}

@end
