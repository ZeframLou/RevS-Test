//
//  TestViewController.m
//  RevSTest
//
//  Created by Zebang Liu on 13-8-13.
//  Copyright (c) 2013 Zebang Liu. All rights reserved.
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

#import "TestViewController.h"
#import "RevS.h"

@interface TestViewController () <RSUploadDelegate,RSDownloadDelegate,UITextViewDelegate,RSMessengerDelegate>
@end

@implementation TestViewController

@synthesize inputTextView,outputTextView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    inputTextView.delegate = self;
    [RSClient join];
    [RSDownload addDelegate:self];
    [RSUpload addDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)uploadPressed:(id)sender {
    NSString *inputString = inputTextView.text;
    if (inputString.length > 0) {
        [inputString writeToFile:[STORED_DATA_DIRECTORY stringByAppendingString:@"upload"] atomically:YES encoding:NSASCIIStringEncoding error:nil];
        [RSUpload uploadFile:@"upload"];
        [self updateOutput:@"Started uploading"];
    }
    //[messenger1 sendServerMessage:[RSMessenger messageWithIdentifier:@"Test" arguments:@[@"I'm not a man,I walk in eternity."]] toServerAddress:SERVER_IP tag:0];
    //[messenger1 sendUdpMessage:[RSMessenger messageWithIdentifier:@"Test" arguments:@[@"I'm not a man,I walk in eternity."]]toHostWithPublicAddress:SERVER_IP privateAddress:@"192.168.1.107" tag:0];
}

- (IBAction)downloadPressed:(id)sender {
    
    [RSDownload downloadFile:@"file"];
    [self updateOutput:@"Started downloading"];
}

- (void)updateOutput:(NSString *)string
{
    outputTextView.text = [outputTextView.text stringByAppendingFormat:@"%@\n",string];
}

- (void)messenger:(RSMessenger *)messenger didRecieveMessageWithIdentifier:(NSString *)identifier arguments:(NSArray *)arguments tag:(NSInteger)tag
{
    [self updateOutput:arguments.lastObject];
}

#pragma mark - RSUploadDelegate

- (void)didUploadFile:(NSString *)fileName
{
    [self updateOutput:[NSString stringWithFormat:@"Uploaded:%@",fileName]];
}

#pragma mark - RSDownloadDelegate

- (void)didDownloadFile:(NSString *)fileName
{
    [self updateOutput:[NSString stringWithFormat:@"Downloaded:%@",[NSString stringWithContentsOfFile:[STORED_DATA_DIRECTORY stringByAppendingString:fileName] encoding:NSASCIIStringEncoding error:nil]]];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

@end
