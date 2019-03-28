//
//  WebSourceManager.h
//  cheyixiao
//
//  Created by bjb on 2018/12/6.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownLoadCenterManager : NSObject

@property(nonatomic,strong)NSMutableDictionary    *allCarDic;
@property(nonatomic,strong)NSMutableDictionary    *carCount;
//@property(nonatomic,strong)NSArray                *currentArr;
@property(nonatomic,strong)NSString               *currentCarID;//当前正在下载的车辆ID 断网再联网时用
@property (nonatomic, strong) NSMutableArray      *downLoadFailUrls;//下载失败的链接
//@property (nonatomic, strong) NSMutableArray      *downLoadCarIds;//所有需要下载的车id
//正在下载的车源包 /临时存储(下载列表)
@property(nonatomic,strong)NSMutableDictionary    *downLoadCar;
@property(nonatomic,assign)NSInteger               finishedCount;//车源包已经下载的文件数

@property(nonatomic,assign)BOOL                    downing;     //YES正在下载  NO没有下载
@property(nonatomic,assign)BOOL                    loadCarJson; //YES正在请求下载的json文件  NO没有下载

@property(nonatomic,assign)BOOL                    cutNet;//有网  NO没网
@property(nonatomic,assign)BOOL                    check;//检查车源文件  no停止检查
@property(nonatomic,assign)BOOL                    downLoadManagerDealloc;//检查车源文件  no停止检查


+(instancetype) shareInstance;



@end

NS_ASSUME_NONNULL_END
