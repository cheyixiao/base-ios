//
//  ThirdSdkManager.m
//  cheyixiao
//
//  Created by bjb on 2019/3/20.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import "ThirdSdkManager.h"
#import <Bugly/Bugly.h>
#import <UMCommon/UMCommon.h>
#import <UMPush/UMessage.h>
#import <Location/LocationManager.h>

@implementation ThirdSdkManager

static ThirdSdkManager* instance = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    }) ;
    return instance ;
}
+(id) allocWithZone:(struct _NSZone *)zone
{
    return [ThirdSdkManager shareInstance] ;
}
-(id) copyWithZone:(struct _NSZone *)zone
{
    return [ThirdSdkManager shareInstance] ;
}
- (BOOL)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                   blockMonitorEnable:(BOOL)blockMonitorEnable
                  blockMonitorTimeout:(NSTimeInterval )blockMonitorTimeout unexpectedTerminatingDetectionEnable:(BOOL )unexpectedTerminatingDetectionEnable
                              buglyId:(NSString *)buglyId
                             UmAppKey:(NSString *)UAppKey
                              AmapKey:(NSString *)AmapKey{
    /*----------------------bugly-------------------------*/
    [self initBuglyWithbBlockMonitorEnable:blockMonitorEnable blockMonitorTimeout:blockMonitorTimeout unexpectedTerminatingDetectionEnable:unexpectedTerminatingDetectionEnable buglyId:buglyId];
    
     /*----------------------UM-------------------------*/
    [self initUMWithUAppKey:UAppKey launchOptions:launchOptions];
    
     /*----------------------AMap-------------------------*/
    [self initAmap:AmapKey];
    
    return YES;
}
-(void)initBuglyWithbBlockMonitorEnable:(BOOL)blockMonitorEnable
       blockMonitorTimeout:(NSTimeInterval )blockMonitorTimeout unexpectedTerminatingDetectionEnable:(BOOL )unexpectedTerminatingDetectionEnable
       buglyId:(NSString *)buglyId
{
    BuglyConfig *config                         = [[BuglyConfig alloc] init];
    config.blockMonitorEnable                   = blockMonitorEnable; // 卡顿监控开关，默认关闭
    config.blockMonitorTimeout                  = blockMonitorTimeout;
    config.unexpectedTerminatingDetectionEnable = unexpectedTerminatingDetectionEnable; // 非正常退出事件记录开关，默认关闭
    // 读取Info.plist中的参数初始化SDK
    [Bugly startWithAppId:buglyId config:config];
}

- (void)initUMWithUAppKey:(NSString *)UAppKey launchOptions:(NSDictionary *)launchOptions{
    
    [UMConfigure initWithAppkey:UAppKey channel:nil];
    // Push组件基本功能配置
    UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
    //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
    entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionSound|UMessageAuthorizationOptionAlert;
//    if (@available(iOS 10.0, *)) {
//        [UNUserNotificationCenter currentNotificationCenter].delegate = nil;
//    } else {
//        // Fallback on earlier versions
//    }
    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity     completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            
        }else{
        }
    }];

}
- (void)initAmap:(NSString *)amapKey{
    //高德定位
    [[LocationManager shareInstance]initAmap:amapKey];
}
@end
