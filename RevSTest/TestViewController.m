//
//  TestViewController.m
//  RevSTest
//
//  Created by lzbdd on 13-8-13.
//  Copyright (c) 2013年 lzbdd. All rights reserved.
//

#import "TestViewController.h"
#import "RevS.h"

@interface TestViewController () <RSUploadDelegate,RSDownloadDelegate,UITextViewDelegate,RSMessagerDelegate>

@property (nonatomic,strong) RSMessager *messager;

@end

@implementation TestViewController

@synthesize inputTextView,outputTextView,messager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    inputTextView.delegate = self;
    [RSNodeManage join];
    [[RSDownload sharedInstance] addDelegate:self];
    [[RSUpload sharedInstance] addDelegate:self];
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
}

- (IBAction)downloadPressed:(id)sender {
    
    [[RSDownload sharedInstance] downloadFile:@"file"];
    [self updateOutput:@"Started downloading"];
}

- (void)updateOutput:(NSString *)string
{
    outputTextView.text = [outputTextView.text stringByAppendingFormat:@"%@\n",string];
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
