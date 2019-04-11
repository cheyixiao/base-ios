//
//  LocationManager.m
//  cheyixiao
//
//  Created by 王天诚 on 2018/12/25.
//  Copyright © 2018 cheshikeji. All rights reserved.
//

#import "LocationManager.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <Networking/AppNetWorking.h>
#import <CheYiXiaoBase/UserDefaults.h>
#import <CheYiXiaoBase/BaseDefine.h>
#import <CheYiXiaoBase/AppFrameworkTool.h>
#import <CheYiXiaoBase/BaseFrameworkHeader.h>
#import <CheYiXiaoBase/CYXBaseModel.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface LocationManager()<AMapLocationManagerDelegate>

@property (nonatomic, strong) AMapLocationManager *locationManager;

@end

@implementation LocationManager

+ (instancetype)shareInstance {
    static LocationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:NULL] init];
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [LocationManager shareInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [LocationManager shareInstance];
}
- (void)initAmap:(NSString *)amapKey{
    //高德定位
    [[AMapServices sharedServices] setEnableHTTPS:YES];
    [AMapServices sharedServices].apiKey = amapKey;
}
- (void)requestLocationWithReGeocode {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            if (error) {
                BASELog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
                if (error.code == AMapLocationErrorLocateFailed) {
                    return;
                }
            }
//            CYXLog(@"----location:%@", location);
            if (regeocode) {
//                CYXLog(@"----reGeocode:%@", regeocode);
                if ([UserDefaults shareInstance].token) {
                    [self postLocationDataWithAddress:regeocode.formattedAddress withCLocation:location];
                }
            }
        }];
    });
}

//提交定位信息
-(void)postLocationDataWithAddress:(NSString *)address withCLocation:(CLLocation *)location
{
    NSString *tempUrl =@"https://l.autoforce.net/_.gif";
    NSString *url = [[CYXBaseModel new] stringByAppendingWith:tempUrl withDictionary:[NSMutableDictionary dictionary]];
    NSString *apiUrl =[NSString stringWithFormat:@"%@&longitude=%f&latitude=%f&address=%@",url,location.coordinate.longitude,location.coordinate.latitude,address];
    [UserDefaults shareInstance].longitude = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    [UserDefaults shareInstance].latitude = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    NSString *apiUrl2 = [AppFrameworkTool encodeUrl:apiUrl];
    [[AppNetWorking shareInstance] getApiSessionTaskWithURLString:apiUrl2 parameters:[NSDictionary dictionary] uploadProgressBlock:^(NSProgress * _Nullable uploadProgress) {
    } success:^(NSDictionary * _Nullable result) {
    } failurl:^{
    }];
}

#pragma mark ---- lazyload
- (AMapLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager setLocatingWithReGeocode:YES];
        
        //高精度定位
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        //定位超时时间 10s
        _locationManager.locationTimeout = 2;
        //逆地理请求超时时间 10s
        _locationManager.reGeocodeTimeout = 2;
        //iOS 9（不包含iOS 9） 之前设置允许后台定位参数，保持不会被系统挂起
        [self.locationManager setPausesLocationUpdatesAutomatically:NO];
        //iOS 9（包含iOS 9）之后新特性：将允许出现这种场景，同一app中多个locationmanager：一些只能在前台定位，另一些可在后台定位，并可随时禁止其后台定位。
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
//            self.locationManager.allowsBackgroundLocationUpdates = YES;
        }
    }
    return _locationManager;
}

@end
