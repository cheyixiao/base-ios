//
//  NSURLSessionTask+CYXModel.m
//  CYXDownload
//
//  Created by wangqichao on 2018/12/8.
//  Copyright © 2018年 wangqichao. All rights reserved.
//

#import "NSURLSessionTask+CYXModel.h"
#import <objc/runtime.h>
#import "CYXWebDownloadModel.h"
//#import "MJExtension.h"


@implementation NSURLSessionTask (CYXModel)

/**
 *  添加downloadModel属性
 */

static const void *CYX_downloadModelKey = @"downloadModelKey";

- (void)setDownloadModel:(CYXWebDownloadModel *)downloadModel{
    
    objc_setAssociatedObject(self, &CYX_downloadModelKey, downloadModel, OBJC_ASSOCIATION_ASSIGN);
}


- (CYXWebDownloadModel *)downloadModel{
    
    return objc_getAssociatedObject(self, &CYX_downloadModelKey);
}


@end
