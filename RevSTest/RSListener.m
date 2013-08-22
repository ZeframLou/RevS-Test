//
//  RSListener.m
//  RevS
//
//  Created by Zebang Liu on 13-8-1.
//  Copyright (c) 2013年 Zebang Liu. All rights reserved.
//  Contact: the.great.lzbdd@gmail.com
/*
 This file is part of RevS.
 
 RevS is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 RevS is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public License
 along with RevS.  If not, see <http://www.gnu.org/licenses/>.
 */


#import "RevS.h"

@interface RSListener () <RSMessagerDelegate>

@end

@implementation RSListener

@synthesize delegates;

+ (RSListener *)sharedListener
{
    static RSListener *listener;
    if (!listener) {
        listener = [[RSListener alloc]init];
        listener.delegates = [NSMutableArray array];
    }
    return listener;
}

- (void)addDelegate:(id <RSListenerDelegate>)delegate
{
    if (![delegates containsObject:delegate]) {
        [delegates addObject:delegate];
    }
}

#pragma mark - RSMessageDelegate

- (void)messager:(RSMessager *)messager didRecieveData:(NSData *)data tag:(NSInteger)tag;
{
    NSString *messageString = [NSData decryptData:data withKey:CODE];
    NSString *messageType = [[messageString componentsSeparatedByString:@"_"]objectAtIndex:0];
    NSArray *messageArguments = [[[messageString componentsSeparatedByString:@"_"]lastObject]componentsSeparatedByString:@";"];
    if ([messageType isEqualToString:@"S"]) {
        //Someone requested a search
        NSString *requesterIP = [messageArguments objectAtIndex:0];
        NSString *senderIP = [messageArguments objectAtIndex:1];
        NSString *fileName = [messageArguments objectAtIndex:2];
        NSUInteger ttl = [[messageArguments objectAtIndex:3] integerValue];
        ttl -= 1;
        if (ttl > 0) {
            if ([[RSUtilities listOfFilenames]containsObject:fileName]) {
                //Ooh,you have the file!First,send a message to the sender to increase the probability index on this path
                NSString *incIndexMessageString = [NSString stringWithFormat:@"INC_%ld;%@;%@",(unsigned long)INDEX_INC,[RSUtilities getLocalIPAddress],fileName];
                RSMessager *incIndexMessage = [RSMessager messagerWithPort:DOWNLOAD_PORT];
                [incIndexMessage addDelegate:self];
                [incIndexMessage sendTcpMessage:incIndexMessageString toHost:senderIP tag:0];
                
                //Next,tell the requester that you have the file
                NSString *string = [NSString stringWithFormat:@"HASFILE_%@;%@",fileName,[RSUtilities getLocalIPAddress]];
                RSMessager *message = [RSMessager messagerWithPort:DOWNLOAD_PORT];
                [message addDelegate:self];
                [message sendTcpMessage:string toHost:requesterIP tag:0];
            }
            else {
                //You don't have the file,so send a message to one of the neighbors
                [[NSUserDefaults standardUserDefaults]setObject:senderIP forKey:[NSString stringWithFormat:@"%@:sender",[RSUtilities hashFromString:fileName]]];
                NSArray *contactList = [RSUtilities contactListWithKValue:K_NEIGHBOR];
                for (NSString *ip in contactList) {
                    if (![requesterIP isEqualToString:ip]) {
                        NSString *string = [NSString stringWithFormat:@"S_%@;%@;%@;%ld",requesterIP,[RSUtilities getLocalIPAddress],fileName,(unsigned long)ttl];
                        RSMessager *message = [RSMessager messagerWithPort:DOWNLOAD_PORT];
                        [message addDelegate:self];
                        [message sendTcpMessage:string toHost:ip tag:0];
                    }
                }
            }
        }
    }
    else if ([messageType isEqualToString:@"INC"]) {
        NSUInteger inc = [[messageArguments objectAtIndex:0] integerValue];
        NSString *senderIP = [messageArguments objectAtIndex:1];
        NSString *fileName = [messageArguments objectAtIndex:2];
        
        //Change probability index
        NSString *dataString = [NSData decryptData:[NSData dataWithContentsOfFile:PROB_INDEX_PATH] withKey:CODE];
        NSMutableArray *dataArray = [NSMutableArray arrayWithArray:[dataString componentsSeparatedByString:@","]];
        
        NSMutableArray *probIndexList = [NSMutableArray array];
        NSMutableArray *probIndexContactList = [NSMutableArray array];
        for (NSString *string in dataArray) {
            NSArray *array = [string componentsSeparatedByString:@":"];
            NSString *ipAddress = [array objectAtIndex:0];
            NSNumber *probIndex = [NSNumber numberWithInteger:[[array lastObject]integerValue]];
            [probIndexContactList addObject:ipAddress];
            [probIndexList addObject:probIndex];
        }
        NSUInteger senderProbIndex = [[probIndexList objectAtIndex:[probIndexContactList indexOfObject:senderIP]] integerValue];
        senderProbIndex += inc;
        [dataArray replaceObjectAtIndex:[probIndexContactList indexOfObject:senderIP] withObject:[NSString stringWithFormat:@"%@:%ld",senderIP,(unsigned long)senderProbIndex]];
        NSString *newProbIndexString = [dataArray componentsJoinedByString:@","];
        [[NSData encryptString:newProbIndexString withKey:CODE]writeToFile:PROB_INDEX_PATH atomically:YES];
        
        //Pass on the message
        NSString *senderKey = [NSString stringWithFormat:@"%@:sender",[RSUtilities hashFromString:fileName]];
        NSString *recieverIP = [[NSUserDefaults standardUserDefaults]objectForKey:senderKey];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:senderKey];
        if (recieverIP) {
            NSString *incIndexMessageString = [NSString stringWithFormat:@"INC_%ld;%@;%@",(unsigned long)INDEX_INC,[RSUtilities getLocalIPAddress],fileName];
            RSMessager *incIndexMessage = [RSMessager messagerWithPort:DOWNLOAD_PORT];
            [incIndexMessage addDelegate:self];
            [incIndexMessage sendTcpMessage:messageString toHost:recieverIP tag:0];
        }
    }
    else if ([messageType isEqualToString:@"JOIN"]) {
        NSString *ipAddress = [messageArguments objectAtIndex:0];
        NSString *dataString = [NSData decryptData:[NSData dataWithContentsOfFile:IP_LIST_PATH] withKey:CODE];
        NSMutableArray *dataArray = [NSMutableArray arrayWithArray:[dataString componentsSeparatedByString:@";"]];
        for (NSString *string in dataArray) {
            NSArray *array = [string componentsSeparatedByString:@","];
            NSString *ip = [array objectAtIndex:0];
            if ([ipAddress isEqualToString:ip]) {
                NSString *newDataString = [NSString stringWithFormat:@"%@,1",ip];
                [dataArray replaceObjectAtIndex:[dataArray indexOfObject:string] withObject:newDataString];
            }
        }
        NSString *ipListString = [dataArray componentsJoinedByString:@";"];
        [[NSData encryptString:ipListString withKey:CODE]writeToFile:IP_LIST_PATH atomically:YES];
    }
    else if ([messageType isEqualToString:@"QUIT"]) {
        NSString *ipAddress = [messageArguments objectAtIndex:0];
        NSString *dataString = [NSData decryptData:[NSData dataWithContentsOfFile:IP_LIST_PATH] withKey:CODE];
        NSMutableArray *dataArray = [NSMutableArray arrayWithArray:[dataString componentsSeparatedByString:@";"]];
        for (NSString *string in dataArray) {
            NSArray *array = [string componentsSeparatedByString:@","];
            NSString *ip = [array objectAtIndex:0];
            if ([ipAddress isEqualToString:ip]) {
                NSString *newDataString = [NSString stringWithFormat:@"%@,0",ip];
                [dataArray replaceObjectAtIndex:[dataArray indexOfObject:string] withObject:newDataString];
            }
        }
        NSString *ipListString = [dataArray componentsJoinedByString:@";"];
        [[NSData encryptString:ipListString withKey:CODE]writeToFile:IP_LIST_PATH atomically:YES];
    }
    else if ([messageType isEqualToString:@"HASFILE"])
    {
        NSString *fileName = [messageArguments objectAtIndex:0];
        if (![[NSUserDefaults standardUserDefaults]boolForKey:[NSString stringWithFormat:@"%@:gotAHit",fileName]]) {
            NSString *fileOwnerIP = [messageArguments objectAtIndex:1];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:[NSString stringWithFormat:@"%@:gotAHit",fileName]];
            RSMessager *message = [RSMessager messagerWithPort:DOWNLOAD_PORT];
            [message addDelegate:self];
            [message sendTcpMessage:[NSString stringWithFormat:@"DFILE_%@;%@",fileName,[RSUtilities getLocalIPAddress]] toHost:fileOwnerIP tag:0];
        }
    }
    else if ([messageType isEqualToString:@"DFILE"])
    {
        NSString *fileName = [messageArguments objectAtIndex:0];
        NSString *requesterIP = [messageArguments objectAtIndex:1];
        NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@%@",STORED_DATA_DIRECTORY,fileName]];
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSString *string = [NSString stringWithFormat:@"FILE_%@;%@",fileName,dataString];
        RSMessager *message = [RSMessager messagerWithPort:DOWNLOAD_PORT];
        [message addDelegate:self];
        [message sendTcpMessage:string toHost:requesterIP tag:0];
    }
    else if ([messageType isEqualToString:@"FILE"]) {
        NSString *fileName = [messageArguments objectAtIndex:0];
        NSString *dataString = [messageArguments objectAtIndex:1];
        NSData *data = [dataString dataUsingEncoding:NSASCIIStringEncoding];
        [data writeToFile:[NSString stringWithFormat:@"%@%@",STORED_DATA_DIRECTORY,fileName] atomically:YES];
        for (id delegate in delegates) {
            if ([delegate respondsToSelector:@selector(didSaveFile:)]) {
                [delegate didSaveFile:fileName];
            }
        }
    }
    else if ([messageType isEqualToString:@"UFILE"])
    {
        NSString *fileName = [messageArguments objectAtIndex:0];
        NSString *fileOwnerIP = [messageArguments objectAtIndex:1];
        NSUInteger timeToLive = [[messageArguments objectAtIndex:2] integerValue];
        RSMessager *message = [RSMessager messagerWithPort:UPLOAD_PORT];
        [message addDelegate:self];
        [message sendTcpMessage:[NSString stringWithFormat:@"ASKFILE_%@;%@;%ld",fileName,[RSUtilities getLocalIPAddress],(unsigned long)timeToLive] toHost:fileOwnerIP tag:0];
    }
    else if ([messageType isEqualToString:@"ASKFILE"])
    {
        NSString *fileName = [messageArguments objectAtIndex:0];
        NSString *requesterIP = [messageArguments objectAtIndex:1];
        NSUInteger timeToLive = [[messageArguments objectAtIndex:2] integerValue];
        NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@%@",STORED_DATA_DIRECTORY,fileName]];
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSString *string = [NSString stringWithFormat:@"SENDFILE_%@;%@;%ld;%@",fileName,dataString,(unsigned long)timeToLive,[RSUtilities getLocalIPAddress]];
        RSMessager *message = [RSMessager messagerWithPort:DOWNLOAD_PORT];
        [message addDelegate:self];
        [message sendTcpMessage:string toHost:requesterIP tag:0];
        for (id delegate in delegates) {
            if ([delegate respondsToSelector:@selector(didUploadFile:)]) {
                [delegate didUploadFile:fileName];
            }
        }
    }
    else if ([messageType isEqualToString:@"SENDFILE"]) {
        NSString *fileName = [messageArguments objectAtIndex:0];
        NSString *dataString = [messageArguments objectAtIndex:1];
        NSUInteger timeToLive = [[messageArguments objectAtIndex:2] integerValue];
        NSString *uploaderIP = [messageArguments objectAtIndex:3];
        timeToLive -= 1;
        NSData *data = [dataString dataUsingEncoding:NSASCIIStringEncoding];
        NSString *string = [NSString stringWithFormat:@"UFILE_%@;%@;%ld",fileName,[RSUtilities getLocalIPAddress],(unsigned long)timeToLive];
        //Prevent error
        if ([RSUtilities freeDiskspace] < data.length) {
            string = [NSString stringWithFormat:@"UFILE_%@;%@;%ld",fileName,uploaderIP,(unsigned long)timeToLive + 1];
        }
        else
        {
            [data writeToFile:[NSString stringWithFormat:@"%@%@",STORED_DATA_DIRECTORY,fileName] atomically:YES];
        }
        if (timeToLive > 0) {
            NSArray *contactList = [RSUtilities contactListWithKValue:K_NEIGHBOR];
            for (NSUInteger i = 0; i < K_UPLOAD; i++) {
                if (i < contactList.count && ![[contactList objectAtIndex:i] isEqualToString:uploaderIP]) {
                    RSMessager *message = [RSMessager messagerWithPort:UPLOAD_PORT];
                    [message addDelegate:[RSListener sharedListener]];
                    [message sendTcpMessage:string toHost:[contactList objectAtIndex:i] tag:0];
                }
            }
        }
                
        for (id delegate in delegates) {
            if ([delegate respondsToSelector:@selector(didSaveFile:)]) {
                [delegate didSaveFile:fileName];
            }
        }
    }
    for (id delegate in delegates) {
        if ([delegate respondsToSelector:@selector(didRecieveDataWithType:arguments:)]) {
            [delegate didRecieveDataWithType:messageType arguments:messageArguments];
        }
    }
}

@end
