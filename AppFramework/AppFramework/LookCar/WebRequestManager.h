//
//  WebRequestManager.h
//  AppFramework
//
//  Created by bjb on 2019/4/1.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebRequestManager : NSObject

+(instancetype) shareInstance;

- (void)loadData:(NSString *)carId update:(BOOL )update uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
         success:(void(^_Nullable)(NSArray * _Nullable result , NSInteger update,NSInteger finishedCount))success
         failurl:(void(^_Nullable)(void))failure;

@end

NS_ASSUME_NONNULL_END
