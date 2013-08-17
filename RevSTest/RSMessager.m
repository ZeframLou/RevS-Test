//
//  RSMessager.m
//  RevSTest
//
//  Created by lzbdd on 13-8-15.
//  Copyright (c) 2013年 lzbdd. All rights reserved.
//

#import "RevS.h"

@interface RSMessager () <GCDAsyncSocketDelegate>

@property (nonatomic,strong) NSMutableArray *delegates;
@property (nonatomic) NSInteger tag;
@property (nonatomic) uint16_t port;
@property (nonatomic,strong) NSString *tcpMessage;
@property (nonatomic,strong) GCDAsyncSocket *tcpSocket;

@end

@implementation RSMessager

@synthesize delegates,tag,port,tcpMessage,tcpSocket;

+ (RSMessager *)messagerWithPort:(uint16_t)port
{
    static RSMessager *messager;
    if (!messager) {
        messager = [[RSMessager alloc]init];
        messager.delegates = [NSMutableArray array];
        messager.tcpSocket = [[GCDAsyncSocket alloc]initWithDelegate:messager delegateQueue:[RSMessager delegateQueue]];
        [messager.tcpSocket acceptOnPort:port error:nil];
        messager.port = port;
    }
    return messager;
}

- (void)sendTcpMessage:(NSString *)message toHost:(NSString *)host tag:(NSInteger)tag
{
    self.tag = tag;
    tcpMessage = message;
    if (![[tcpSocket connectedHost] isEqualToString:host] && ![tcpSocket isConnected]) {
        [tcpSocket disconnect];
        NSError *error;
        [tcpSocket connectToHost:host onPort:port error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
    }
    else
    {
        [tcpSocket writeData:[NSData encryptString:tcpMessage withKey:CODE] withTimeout:30 tag:0];
    }
}

- (void)addDelegate:(id <RSMessagerDelegate>)delegate
{
    if (![delegates containsObject:delegate]) {
        [delegates addObject:delegate];
    }
}

+ (dispatch_queue_t)delegateQueue
{
    static dispatch_queue_t queue;
    if (!queue) {
        queue = dispatch_queue_create("delegate queue", NULL);
    }
    return queue;
}

+ (dispatch_queue_t)filterQueue
{
    static dispatch_queue_t queue;
    if (!queue) {
        queue = dispatch_queue_create("filter queue", NULL);
    }
    return queue;
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [sock writeData:[NSData encryptString:tcpMessage withKey:CODE] withTimeout:30 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    tcpSocket.delegate = self;
    tcpSocket.delegateQueue = [RSMessager delegateQueue];
    NSError *error;
    if (error) {
        NSLog(@"%@",error);
    }
    [tcpSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id delegate in delegates) {
            if ([delegate respondsToSelector:@selector(messager:didRecieveData:tag:)]) {
                [delegate messager:self didRecieveData:data tag:tag];
            }
        }
    });
    [tcpSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id delegate in delegates) {
            if ([delegate respondsToSelector:@selector(messager:didWriteDataWithTag:)]) {
                [delegate messager:self didWriteDataWithTag:tag];
            }
        }
    });
    [tcpSocket readDataWithTimeout:-1 tag:0];
}

@end
