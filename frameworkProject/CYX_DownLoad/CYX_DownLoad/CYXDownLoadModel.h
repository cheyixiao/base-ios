//
//  CYXDownLoadModel.h
//  cheyixiao
//
//  Created by bjb on 2018/11/26.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYXDownLoadModel : NSObject<NSCoding>

//首页
@property(nonatomic,strong)NSDictionary *mainResult;

//车源
@property(nonatomic,strong)NSDictionary *carResult;
//全部寻车
@property(nonatomic,strong)NSDictionary *carFindAllResult;
//我的寻车
@property(nonatomic,strong)NSDictionary *carFindMineResult;
//我收到的报价
@property(nonatomic,strong)NSDictionary *carFindReceiveResult;
//我发布的报价
@property(nonatomic,strong)NSDictionary *carFindSendResult;

//客户
@property(nonatomic,strong)NSDictionary *customerResult;

//我的
@property(nonatomic,strong)NSDictionary *mineResult;
//自营车
@property(nonatomic,strong)NSDictionary *carOwnResult;

@property(nonatomic,strong)NSDictionary *carOwnBannerResult;
//网页url
@property(nonatomic,strong)NSMutableDictionary *urlDic;

//车源包版本号
@property(nonatomic,strong)NSMutableDictionary *carVersion;

//正在下载的车源包
@property(nonatomic,strong)NSMutableDictionary  *downLoadCar;

//车源包下载状态
@property(nonatomic,strong)NSMutableDictionary    *downStatus;




+ (NSString *)systemMsgCachePath;

+ (void)removeSystemMsgCache;



@end

NS_ASSUME_NONNULL_END
