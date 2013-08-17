//
//  RSDownload.m
//  RevS
//
//  Created by lzbdd on 13-8-1.
//  Copyright (c) 2013年 lzbdd. All rights reserved.
//

#import "RevS.h"

@interface RSDownload () <RSListenerDelegate>

@property (nonatomic,strong) NSMutableArray *delegates;
@property (nonatomic,strong) RSMessager *messager;

@end

@implementation RSDownload

@synthesize delegates,messager;

+ (RSDownload *)sharedInstance
{
    static RSDownload *sharedInstance;
    if (!sharedInstance) {
        sharedInstance = [[RSDownload alloc]init];
        sharedInstance.delegates = [NSMutableArray array];
        sharedInstance.messager = [RSMessager messagerWithPort:DOWNLOAD_PORT];
        [sharedInstance.messager addDelegate:[RSListener sharedListener]];
        [[RSListener sharedListener] addDelegate:sharedInstance];
    }
    return sharedInstance;
}

- (void)downloadFile:(NSString *)fileName;
{
    NSArray *contactList = [RSUtilities contactListWithKValue:K];
    //Send search query
    for (NSString *ipAddress in contactList) {
        NSString *messageString = [NSString stringWithFormat:@"S_%@;%@;%@;%d",[RSUtilities getLocalIPAddress],[RSUtilities getLocalIPAddress],fileName,TTL];
        [messager sendTcpMessage:messageString toHost:ipAddress tag:0];
    }
}

- (void)downloadFile:(NSString *)fileName fromIP:(NSString *)ipAddress
{
    [messager sendTcpMessage:[NSString stringWithFormat:@"DFILE_%@,%@",fileName,[RSUtilities getLocalIPAddress]] toHost:ipAddress tag:0];
}

- (void)addDelegate:(id <RSDownloadDelegate>)delegate
{
    if (![delegates containsObject:delegate]) {
        [delegates addObject:delegate];
    }
}

#pragma mark - RSListenerDelegate

- (void)didSaveFile:(NSString *)fileName
{
    for (id delegate in delegates) {
        if ([delegate respondsToSelector:@selector(didDownloadFile:)]) {
            [delegate didDownloadFile:fileName];
        }
    }
}

@end
