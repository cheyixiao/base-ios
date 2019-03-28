//
//  WKProcessPool+WebCarProcessPool.h
//  cheyixiao
//
//  Created by bjb on 2019/1/14.
//  Copyright © 2019年 cheshikeji. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKProcessPool (WebCarProcessPool)

+ (WKProcessPool *)sharedProcessPool;


@end

NS_ASSUME_NONNULL_END
