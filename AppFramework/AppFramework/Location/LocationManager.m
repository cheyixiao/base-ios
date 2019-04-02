//
//  LocationManager.m
//  cheyixiao
//
//  Created by 王天诚 on 2018/12/25.
//  Copyright © 2018 cheshikeji. All rights reserved.
//

#import "LocationManager.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import "AppNetWorking.h"
#import "UserDefaults.h"
#import "BaseDefine.h"
#import "AppFrameworkTool.h"
#import "AppFrameworkHeader.h"

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
    NSString *url = [self stringByAppendingWith:tempUrl withDictionary:[NSMutableDictionary dictionary]];
    NSString *apiUrl =[NSString stringWithFormat:@"%@&longitude=%f&latitude=%f&address=%@",url,location.coordinate.longitude,location.coordinate.latitude,address];
    [UserDefaults shareInstance].longitude = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    [UserDefaults shareInstance].latitude = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    NSString *apiUrl2 = [AppFrameworkTool encodeUrl:apiUrl];
    [[AppNetWorking shareInstance] getApiSessionTaskWithURLString:apiUrl2 parameters:[NSDictionary dictionary] uploadProgressBlock:^(NSProgress * _Nullable uploadProgress) {
    } success:^(NSDictionary * _Nullable result) {
    } failurl:^{
    }];
}
- (NSString *)stringByAppendingWith: (NSString *)url withDictionary:(NSMutableDictionary *)dictionary
{
    //keyArray
    NSMutableArray *KeyArray = [NSMutableArray array];
    //valuesArray
    NSMutableArray *valueArray = [NSMutableArray array];
    if (dictionary) {
        for (NSString *str in [dictionary allKeys]) {
            NSString *value = [dictionary objectForKey:str];
            if ([value isKindOfClass:[NSNumber class]]) {
                [KeyArray addObject:str];
                [valueArray addObject:[dictionary objectForKey:str]];
            }else if (value.length > 0) {
                [KeyArray addObject:str];
                [valueArray addObject:[dictionary objectForKey:str]];
            }
        }
    }
    
    NSString *paramStr = @"?";
    for (int i = 0; i < KeyArray.count; i++) {
        paramStr = [paramStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", KeyArray[i], valueArray[i]]];
    }
    //  Cyx_ref=1 代表是手机，=0代表是pad
    NSString * Cyx_ref;
    if (IS_IPAD) {
        Cyx_ref =@"0";
    }else{
        Cyx_ref =@"1";
    }
    paramStr = [paramStr stringByAppendingString:[NSString stringWithFormat:@"Cyx_token=%@&Cyx_saler=%@&Cyx_ref=%@&origin_version=%@&decid=%@", [UserDefaults shareInstance].token, [UserDefaults shareInstance].saler,Cyx_ref, [AppFrameworkTool getBaseUrlVersion],[UserDefaults shareInstance].uuidForDevice]];
    
    url = [url stringByAppendingString:paramStr];
    
    return url;
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
