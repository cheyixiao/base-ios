//
//  WebSourceManager.m
//  cheyixiao
//
//  Created by bjb on 2018/12/6.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import "WebSourceManager.h"
#import "CYXWebDownloadModel.h"
@interface WebSourceManager ()


@end

@implementation WebSourceManager

static WebSourceManager* instance = nil;

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
    return [WebSourceManager shareInstance] ;
}
-(id) copyWithZone:(struct _NSZone *)zone
{
    return [WebSourceManager shareInstance] ;
}

#pragma mark -lazyLoad
-(NSMutableDictionary *)allCarDic{
    if (!_allCarDic) {
        _allCarDic = [NSMutableDictionary dictionary];
    }
    return _allCarDic;
}
-(NSMutableDictionary *)carCount{
    if (!_carCount) {
        _carCount = [NSMutableDictionary dictionary];
    }
    return _carCount;
}

- (NSMutableDictionary *)downLoadCar {
    if (!_downLoadCar) {
        _downLoadCar = [NSMutableDictionary dictionary];
    }
    
    return _downLoadCar;
}
-(NSMutableArray *)downLoadFailUrls{
    if (!_downLoadFailUrls) {
        _downLoadFailUrls = [NSMutableArray array];
    }
    return _downLoadFailUrls;
}

@end
