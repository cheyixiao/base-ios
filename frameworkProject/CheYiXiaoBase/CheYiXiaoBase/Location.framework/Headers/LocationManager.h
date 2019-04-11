//
//  LocationManager.h
//  cheyixiao
//
//  Created by 王天诚 on 2018/12/25.
//  Copyright © 2018 cheshikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationManager : NSObject

+ (instancetype)shareInstance;
- (void)initAmap:(NSString *)amapKey;
- (void)requestLocationWithReGeocode;

@end

NS_ASSUME_NONNULL_END
