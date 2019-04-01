//
//  WebCenterManager.m
//  cheyixiao
//
//  Created by bjb on 2019/3/19.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import "WebCenterManager.h"
#import "DownLoadManager.h"
#import "WebCarModel.h"
#include <sys/xattr.h>
#import "MyURLProtocol.h"
#import "WebInterceptDownLoadManager.h"
#import "DownLoadCacheModel.h"
#import "WebRequestManager.h"
#import "DownloadConst.h"
#import "AFNetworking.h"
#import "AppFrameworkTool.h"
#import "BaseDefine.h"
#import "MBProgressHUD.h"

@implementation WebCenterManager

static WebCenterManager* instance = nil;

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
    return [WebCenterManager shareInstance] ;
}
-(id) copyWithZone:(struct _NSZone *)zone
{
    return [WebCenterManager shareInstance] ;
}
- (void)webCenterManagerBaseUrlArr:(NSArray *)baseUrlArr downLoad:(BOOL )downLoad log:(BOOL )log{
    [[WebCenterManager shareInstance] baseUrl:baseUrlArr];
    [DownloadManager sharedManager].downLoadCenterManager  = [DownLoadCenterManager shareInstance];
    [WebInterceptDownLoadManager shareInstance].downLoad   = downLoad;
    [WebInterceptDownLoadManager shareInstance].log         = log;
    
    
    [[WebCenterManager shareInstance]setDownLoadCacheCar];
    [[WebCenterManager shareInstance]registerNotification];
    [[WebCenterManager shareInstance]listenNetWorkingStatus];
    [[WebCenterManager shareInstance]noCloud];
    [[WebCenterManager shareInstance]registerWeb];
    
    [self performSelector:@selector(updateCarCommon) withObject:nil afterDelay:3];
}
- (void)noCloud{
    BOOL exsit = [[NSFileManager defaultManager]fileExistsAtPath:CYXCachesDirectory];
    if (exsit) {
        NSURL * url = [NSURL URLWithString:CYXCachesDirectory];
        [AppFrameworkTool addSkipBackupAttributeToItemAtURL:url];
    }
}
- (void)registerWeb{
    
    [NSURLProtocol registerClass:[MyURLProtocol class]];
}
-(void)baseUrl:(NSArray *)baseUrlArr{
    [WebInterceptDownLoadManager shareInstance].baseUrlArr = baseUrlArr;
}
- (void)registerNotification{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(webStartDownLoad:) name:@"webSourceStartDownLoad" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(webPageStartDownLoad:) name:@"webPageSourceStartDownLoad" object:nil];
    //添加下载包进度监听
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downLoadPersent:) name:@"webCarSourceDownLoad" object:nil];
}
- (void)setDownLoadCacheCar{
    
    DownLoadCacheModel *downLoadModel = [NSKeyedUnarchiver unarchiveObjectWithFile:[DownLoadCacheModel systemMsgCachePath]];
    if (downLoadModel) {
        if (downLoadModel.downLoadCar) {
            [DownLoadCenterManager shareInstance].downLoadCar = downLoadModel.downLoadCar;
        }
        if (downLoadModel.downStatus) {
            [DownLoadCenterManager shareInstance].downLoadStatus = downLoadModel.downStatus;
        }
    }
}
- (void)removeDownLoadCar:(NSString *)carId status:(NSString *)status{
    DownLoadCacheModel *downLoadModel = [NSKeyedUnarchiver unarchiveObjectWithFile:[DownLoadCacheModel systemMsgCachePath]];
    if (!downLoadModel) {
        downLoadModel = [[DownLoadCacheModel alloc] init];
    }
    [downLoadModel.downStatus setObject:status forKey:carId];
    if ([downLoadModel.downLoadCar.allKeys containsObject:carId]) {
        [downLoadModel.downLoadCar removeObjectForKey:carId];
    }
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        [NSKeyedArchiver archiveRootObject:downLoadModel toFile:[DownLoadCacheModel systemMsgCachePath]];
    });
    if ([[DownLoadCenterManager shareInstance].downLoadCar.allKeys containsObject:carId]) {
        
        [[DownLoadCenterManager shareInstance].downLoadCar removeObjectForKey:carId];
    }
    [[DownLoadCenterManager shareInstance].downLoadStatus setObject:status forKey:carId];
}
- (void)removeDownLoadCar:(NSString *)carId{
    
    DownLoadCacheModel *downLoadModel = [NSKeyedUnarchiver unarchiveObjectWithFile:[DownLoadCacheModel systemMsgCachePath]];
    if (!downLoadModel) {
        downLoadModel = [[DownLoadCacheModel alloc] init];
    }
    [downLoadModel.downStatus setObject:@"4" forKey:carId];
    if ([downLoadModel.downLoadCar.allKeys containsObject:carId]) {
        [downLoadModel.downLoadCar removeObjectForKey:carId];
    }
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        [NSKeyedArchiver archiveRootObject:downLoadModel toFile:[DownLoadCacheModel systemMsgCachePath]];
    });
    if ([[DownLoadCenterManager shareInstance].downLoadCar.allKeys containsObject:carId]) {
        
        [[DownLoadCenterManager shareInstance].downLoadCar removeObjectForKey:carId];
    }
    [[DownLoadCenterManager shareInstance].downLoadStatus setObject:@"4" forKey:carId];
}
- (void)setDownLoadStatus:(NSString *)status carId:(NSString *)carId{
    
    [[DownLoadCenterManager shareInstance].downLoadStatus setObject:status forKey:carId];
    DownLoadCacheModel *downLoadModel = [NSKeyedUnarchiver unarchiveObjectWithFile:[DownLoadCacheModel systemMsgCachePath]];
    if (!downLoadModel) {
        downLoadModel = [[DownLoadCacheModel alloc] init];
    }
    [downLoadModel.downStatus setObject:status forKey:carId];
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        [NSKeyedArchiver archiveRootObject:downLoadModel toFile:[DownLoadCacheModel systemMsgCachePath]];
    });
}
//监听网络状态
-(void)listenNetWorkingStatus {
    //1:创建网络监听者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    //2:获取网络状态
    /*
     AFNetworkReachabilityStatusUnknown          = 未知网络，
     AFNetworkReachabilityStatusNotReachable     = 没有联网
     AFNetworkReachabilityStatusReachableViaWWAN = 蜂窝数据
     AFNetworkReachabilityStatusReachableViaWiFi = 无线网
     */
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                BASELog(@"未知网络");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                [[DownloadManager sharedManager] stopAll];
                [DownLoadCenterManager shareInstance].cutNet = YES;
                BASELog(@"没有联网");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                BASELog(@"蜂窝数据");
                [DownLoadCenterManager shareInstance].cutNet = NO;
                if ([DownLoadCenterManager shareInstance].currentCarID && [DownLoadCenterManager shareInstance].currentCarID.length) {
                    [DownLoadCenterManager shareInstance].downing = NO;
                    [self loadCarJson:[DownLoadCenterManager shareInstance].currentCarID];
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                BASELog(@"无线网");
                [DownLoadCenterManager shareInstance].cutNet = NO;
                if ([DownLoadCenterManager shareInstance].currentCarID && [DownLoadCenterManager shareInstance].currentCarID.length) {
                    [DownLoadCenterManager shareInstance].downing = NO;
                    [self loadCarJson:[DownLoadCenterManager shareInstance].currentCarID];
                }
                break;
            default:
                break;
        }
    }];
    //开启网络监听
    [manager startMonitoring];
}
//更新车源公共包
- (void)updateCarCommon{
    [[WebRequestManager shareInstance]loadData:@"common" update:YES uploadProgressBlock:^(NSProgress * _Nullable uploadProgress) {
        
    } success:^(NSArray * _Nullable result, NSInteger update,NSInteger finishedCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
            
        });
        if (update != doneDownLoad) {
            
            NSString *down = [DownLoadCenterManager shareInstance].downLoadStatus[@"common"];
            if ([down isEqualToString:@"3"]) {
                [self loadCarJson:@"common"];
            }
            [self setDownLoadStatus:[NSString stringWithFormat:@"%ld",(long)update] carId:@"common"];
        }else{
            //该包不需要更新
            [self removeDownLoadCar:@"common" status:@"4"];
        }
    } failurl:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
            
        });
    }];
}
- (void)loadCarJson:(NSString *)carID{
    
    if (carID && carID.length ) {
        
        [[WebRequestManager shareInstance]loadData:carID update:YES uploadProgressBlock:^(NSProgress * _Nullable uploadProgress) {
            
        } success:^(NSArray * _Nullable result, NSInteger update,NSInteger finishedCount) {
            
            if ([DownLoadCenterManager shareInstance].downing == NO) {
                //该包需要更新
                if (update != doneDownLoad) {
                    [self downLoad:result finishedCount:[NSString stringWithFormat:@"%ld",(long)finishedCount]];
                }
            }else{
                if ([DownLoadCenterManager shareInstance].currentCarID && [DownLoadCenterManager shareInstance].currentCarID.length && update != doneDownLoad) {
                    if ([[DownLoadCenterManager shareInstance].currentCarID isEqualToString:carID]) {
                        [self downLoad:result finishedCount:[NSString stringWithFormat:@"%ld",(long)finishedCount]];
                    }
                }
            }
            if (update == doneDownLoad) {
                
                [self removeDownLoadCar:carID];
            }
            
        } failurl:^{
            
        }];
    }
}
- (void)downLoadPersent:(NSNotification *)noification{
    NSDictionary *dic = noification.userInfo;
    if (dic) {
        NSString *carId = dic[@"carId"];
        NSString *persent  = dic[@"persent"];
        NSString *result   = dic[@"result"];
        if ([result isEqualToString:@"2"]) {
            //下载完成
             [[DownloadManager sharedManager] stopAll];
            //当前车包下载完后进行下一个车包的下载
            
            [self nextDownLoadCar:carId];
           
        }else{
            //正在下载
            [self downLoadingCar:carId persent:persent];
        }
    }
}
- (void)nextDownLoadCar:(NSString *)carId{
    //当前车包下载完后进行下一个车包的下载
    DownLoadCacheModel *downLoadModel = [NSKeyedUnarchiver unarchiveObjectWithFile:[DownLoadCacheModel systemMsgCachePath]];
    if (!downLoadModel) {
        downLoadModel = [[DownLoadCacheModel alloc] init];
    }
    WebCarModel *model = [DownLoadCenterManager shareInstance].downLoadCar[carId];
    if (model) {
        model.persent = @"100";
        dispatch_async(dispatch_get_main_queue(),^{
            if ([model.delegate respondsToSelector:@selector(webCarModel:persent:)]) {
                [model.delegate webCarModel:model persent:@"100"];
            }
        });
    }
    
    if (downLoadModel && downLoadModel.downLoadCar && [downLoadModel.downLoadCar.allKeys containsObject:carId]) {
        
        [downLoadModel.downLoadCar removeObjectForKey:carId];
    }
    if ([[DownLoadCenterManager shareInstance].downLoadCar.allKeys containsObject:carId]) {
        [[DownLoadCenterManager shareInstance].downLoadCar removeObjectForKey:carId];
    }
    NSArray *keys = [DownLoadCenterManager shareInstance].downLoadCar.allKeys;
    if (keys && keys.count) {
        NSString *key = keys.firstObject;
        WebCarModel *model = downLoadModel.downLoadCar[key];
        NSString *nextCarId = model.carId;
        [self loadCarJson:nextCarId];
    }
    [downLoadModel.downStatus setObject:@"4" forKey:carId];
    [[DownLoadCenterManager shareInstance].downLoadStatus setObject:@"4" forKey:carId];
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        [NSKeyedArchiver archiveRootObject:downLoadModel toFile:[DownLoadCacheModel systemMsgCachePath]];
    });
}
- (void)downLoadingCar:(NSString *)carId persent:(NSString *)persent{
    
    WebCarModel *model = [DownLoadCenterManager shareInstance].downLoadCar[carId];
    model.persent      = persent;
    if ([model.delegate respondsToSelector:@selector(webCarModel:persent:)]) {
        [model.delegate webCarModel:model persent:persent];
    }
    
}
//下载过程中出错 重新下载
- (void)webStartDownLoad:(NSNotification *)notification{
    
    NSDictionary *dic = notification.userInfo;
    if (dic) {
        NSString *carId = dic[@"carId"];
        [self loadCarJson:carId];
    }
}
- (void)webPageStartDownLoad:(NSNotification *)notification{
    
    if ([DownLoadCenterManager shareInstance].downing == NO) {
        NSDictionary *dic = notification.userInfo;
        if (dic) {
            NSArray *arr    = dic[@"car"];
            NSString *count = dic[@"count"];
            [self downLoad:arr finishedCount:count];
        }
    }
}
- (void)downLoad:(NSArray *)car finishedCount:(NSString * )count{
    
    [[DownloadManager sharedManager] stopAll];
    [[DownloadManager sharedManager]startWithDownloadModels:car finished:count];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}
@end
