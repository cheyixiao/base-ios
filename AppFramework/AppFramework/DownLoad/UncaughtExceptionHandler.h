//
//  CYXUncaughtExceptionHandler.h
//  CYXDownload
//
//  Created by wangqichao on 2018/12/8.
//  Copyright © 2018年 wangqichao. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kNotificationUncaughtException = @"kNotificationUncaughtException";

NS_ASSUME_NONNULL_BEGIN

@interface UncaughtExceptionHandler : NSObject

+ (void)setDefaultHandler;
+ (NSUncaughtExceptionHandler *)getHandler;
+ (void)TakeException:(NSException *) exception;

@end

NS_ASSUME_NONNULL_END
