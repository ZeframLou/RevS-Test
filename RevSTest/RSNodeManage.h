//
//  RSNodeManage.h
//  RevS
//
//  Created by lzbdd on 13-8-1.
//  Copyright (c) 2013年 lzbdd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSNodeManage : NSObject

+ (RSNodeManage *)sharedInstance;
- (void)join;
- (void)quit;

@end
