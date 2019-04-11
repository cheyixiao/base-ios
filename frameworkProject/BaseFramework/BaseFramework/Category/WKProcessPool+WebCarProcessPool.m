//
//  WKProcessPool+WebCarProcessPool.m
//  cheyixiao
//
//  Created by bjb on 2019/1/14.
//  Copyright © 2019年 cheshikeji. All rights reserved.
//

#import "WKProcessPool+WebCarProcessPool.h"

@implementation WKProcessPool (WebCarProcessPool)

+ (WKProcessPool *)sharedProcessPool {
    static WKProcessPool *WebCarProcessPool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        WebCarProcessPool = [[WKProcessPool alloc] init];
    });
    return WebCarProcessPool;
}


@end
