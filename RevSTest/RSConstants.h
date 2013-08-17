//
//  RSConstants.h
//  RevS
//
//  Created by lzbdd on 13-8-5.
//  Copyright (c) 2013年 lzbdd. All rights reserved.
//

#warning If you don't change these and publish your app with it,you might want to shoot yourself in the face LOL

static const NSString *CODE = @"just a simple code(you need to change this into a 256 bit password)";
static const NSString *SERVER_IP = @"127.0.0.1";

//As for the constants below,change them,don't change them,it doesn't really matter

#define IP_LIST_PATH [NSString stringWithFormat:@"%@/Documents/ipList",NSHomeDirectory()]
#define PROB_INDEX_PATH [NSString stringWithFormat:@"%@/Documents/probIndex",NSHomeDirectory()]
#define STORED_DATA_DIRECTORY [NSString stringWithFormat:@"%@/Documents/Data/",NSHomeDirectory()]

static const uint16_t MESSAGE_PORT = 99;
static const uint16_t DOWNLOAD_PORT = 527;
static const uint16_t UPLOAD_PORT = 805;
static const NSString *MESSAGE_END = @"\n";
//static const NSString *IP_LIST_PATH = [NSString stringWithFormat:@"%@/Documents/ipList",NSHomeDirectory()];
//static const NSString *PROB_INDEX_PATH = [NSString stringWithFormat:@"%@/Documents/probIndex",NSHomeDirectory()];
//static const NSString *STORED_DATA_DIRECTORY = [NSString stringWithFormat:@"%@/Documents/Data/",NSHomeDirectory()];
static const NSUInteger TTL = 6;//Time to live
static const NSUInteger K = 8;//Number of neighbors to contact
static const NSUInteger K_NEIGHBOUR = 2;//K value applied on your neighbors during a search
static const NSUInteger INDEX_INC = 10;
static const NSUInteger NEIGHBOUR_COUNT = 16;
static const NSUInteger INITIAL_PROB_INDEX = 10;