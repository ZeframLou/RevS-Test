//
//  TestViewController.m
//  RevSTest
//
//  Created by lzbdd on 13-8-13.
//  Copyright (c) 2013年 lzbdd. All rights reserved.
//

#import "TestViewController.h"
#import "RevS.h"

@interface TestViewController () <RSUploadDelegate,RSDownloadDelegate,UITextViewDelegate,RSMessengerDelegate>
@property (nonatomic,strong) RSMessenger *messenger1;
@end

@implementation TestViewController

@synthesize inputTextView,outputTextView,messenger1;

- (void)viewDidLoad
{
    [super viewDidLoad];
    inputTextView.delegate = self;
    [RSClient join];
    [RSDownload addDelegate:self];
    [RSUpload addDelegate:self];
    [RSUtilities setNatTier:RSTierNoNatOrNatPmp];
    messenger1 = [RSMessenger messengerWithPort:MESSAGE_PORT delegate:self];
    [RSMessenger registerMessageIdentifiers:@[@"Test"] delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)uploadPressed:(id)sender {
    /*NSString *inputString = inputTextView.text;
    if (inputString.length > 0) {
        [inputString writeToFile:[STORED_DATA_DIRECTORY stringByAppendingString:@"upload"] atomically:YES encoding:NSASCIIStringEncoding error:nil];
        [RSUpload uploadFile:@"upload"];
        [self updateOutput:@"Started uploading"];
    }*/
    NSString *privateAddress;
    if ([[RSUtilities privateIpAddress]isEqualToString:@"192.168.1.102"]) {
        privateAddress = @"192.168.1.100";
    } else {
        privateAddress = @"192.168.1.102";
    }
    //[messenger1 sendServerMessage:[RSMessenger messageWithIdentifier:@"Test" arguments:@[@"I'm not a man,I walk in eternity."]] toServerAddress:privateAddress tag:0];
    [messenger1 sendUdpMessage:[RSMessenger messageWithIdentifier:@"Test" arguments:@[@"I'm not a man,I walk in eternity."]]toHostWithPublicAddress:[RSUtilities publicIpAddress] privateAddress:privateAddress tag:0];
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
