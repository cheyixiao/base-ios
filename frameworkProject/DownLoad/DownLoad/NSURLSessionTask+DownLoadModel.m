//
//  NSURLSessionTask+CYXModel.m
//  CYXDownload
//
//  Created by wangqichao on 2018/12/8.
//  Copyright © 2018年 wangqichao. All rights reserved.
//

#import "NSURLSessionTask+DownLoadModel.h"
#import <objc/runtime.h>
#import "WebDownloadModel.h"
//#import "MJExtension.h"


@implementation NSURLSessionTask (DownModel)

/**
 *  添加downloadModel属性
 */

static const void *_downloadModelKey = @"downloadModelKey";

- (void)setDownloadModel:(WebDownloadModel *)downloadModel{
    
    objc_setAssociatedObject(self, &_downloadModelKey, downloadModel, OBJC_ASSOCIATION_ASSIGN);
}


- (WebDownloadModel *)downloadModel{
    
    return objc_getAssociatedObject(self, &_downloadModelKey);
}


@end
