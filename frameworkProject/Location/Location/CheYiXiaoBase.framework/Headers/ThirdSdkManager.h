//
//  ThirdSdkManager.h
//  cheyixiao
//
//  Created by bjb on 2019/3/20.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThirdSdkManager : NSObject

@property(nonatomic,copy)NSString  *deviceToken;

+(instancetype) shareInstance;
/*
 ----------------------bugly----------------------------
 blockMonitorEnable                    卡顿监控开关，默认关闭
 blockMonitorTimeout                   卡顿监控判断间隔，单位为秒
 unexpectedTerminatingDetectionEnable  非正常退出事件记录开关，默认关闭
 buglyId
 
 ----------------------UM-------------------------
 UAppKey
 
 ----------------------AMap-------------------------
 AmapKey
 */

- (BOOL)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
        blockMonitorEnable:(BOOL)blockMonitorEnable
        blockMonitorTimeout:(NSTimeInterval )blockMonitorTimeout unexpectedTerminatingDetectionEnable:(BOOL )unexpectedTerminatingDetectionEnable
        buglyId:(NSString *)buglyId
        UmAppKey:(NSString *)UAppKey
        AmapKey:(NSString *)AmapKey;


@end

NS_ASSUME_NONNULL_END
