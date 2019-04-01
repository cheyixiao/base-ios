//
//  CYXDownLoadModel.h
//  cheyixiao
//
//  Created by bjb on 2018/11/26.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownLoadCacheModel : NSObject<NSCoding>

//正在下载的车源包
@property(nonatomic,strong)NSMutableDictionary  *downLoadCar;

//车源包下载状态
@property(nonatomic,strong)NSMutableDictionary    *downStatus;




+ (NSString *)systemMsgCachePath;

+ (void)removeSystemMsgCache;



@end

NS_ASSUME_NONNULL_END
