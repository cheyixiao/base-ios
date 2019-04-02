//
//  AppDelegate.m
//  TeSt
//
//  Created by bjb on 2019/3/20.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import "BaseAppDelegate.h"
#import "WebInterceptDownLoadManager.h"
#import "AppFrameworkTool.h"
#import "BaseDefine.h"
#import "AppFrameworkHeader.h"
#import "LocationManager.h"
#import "UserDefaults.h"
#import "FCUUID.h"

@interface BaseAppDelegate ()

@property (nonatomic, strong) dispatch_source_t timer;


@end

@implementation BaseAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[WebInterceptDownLoadManager shareInstance] registerWeb];//webview拦截
    [AppFrameworkTool removeLauchCache];
    //应用处于前台时持续定位 间隔半个小时
    [self continuousLocation];
    //监听UIWindow隐藏
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];
    
    //清除用户的线索id
    [UserDefaults shareInstance].userBehaviorId = nil;
    [self getDeviceId];
    if (IS_IPAD) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }else{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    //屏幕右侧左滑，呼出 sandbox 目录的文件浏览器。需要时打开
    //    [[PAirSandbox sharedInstance] enableSwipe];
    
    //一个界面只先响应一个
    [[UIButton appearance] setExclusiveTouch:YES];
    [[UIView appearance] setExclusiveTouch:YES];
    [AppFrameworkTool setUserAgent:nil];
    
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     [[LocationManager shareInstance] requestLocationWithReGeocode];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[LocationManager shareInstance] requestLocationWithReGeocode];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   
}
//持续定位
- (void)continuousLocation {
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 60*30 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        BASELog(@"------定时器开启");
        [[LocationManager shareInstance] requestLocationWithReGeocode];
    });
    dispatch_resume(_timer);
}
-(void)endFullScreen{
    dispatch_async(dispatch_get_main_queue(),^{
        
        [UIApplication sharedApplication].statusBarHidden = NO;
    });
    
}
///获取手机设备的唯一标识
-(void)getDeviceId
{
    [UserDefaults shareInstance].uuidForDevice = [FCUUID uuidForDevice];
}
@end
