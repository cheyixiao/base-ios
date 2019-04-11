//
//  NSURLSessionTask+CYXModel.h
//  CYXDownload
//
//  Created by wangqichao on 2018/12/8.
//  Copyright © 2018年 wangqichao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class CYXWebDownloadModel;
@interface NSURLSessionTask (CYXModel)

@property (nonatomic, weak)CYXWebDownloadModel  * downloadModel;

@end

NS_ASSUME_NONNULL_END
