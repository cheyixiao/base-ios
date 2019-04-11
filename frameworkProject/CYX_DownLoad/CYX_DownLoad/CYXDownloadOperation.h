//
//  CYXDownloadOperation.h
//  CYXDownload
//
//  Created by wangqichao on 2018/12/8.
//  Copyright © 2018年 wangqichao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSURLSessionTask+CYXModel.h"

typedef void(^DownloadStatusChangedBlock)(void);

@class CYXWebDownloadModel;

@interface CYXDownloadOperation : NSOperation


@property (nonatomic, weak) CYXWebDownloadModel * downloadModel;

@property (nonatomic, strong) NSURLSessionDataTask * downloadTask;

@property (nonatomic ,weak) NSURLSession *session;

/** 下载状态改变回调 */
@property (nonatomic, copy) DownloadStatusChangedBlock downloadStatusChangedBlock ;

- (instancetype)initWithDownloadModel:(CYXWebDownloadModel *)downloadModel andSession:(NSURLSession *)session;


- (void)suspend;
- (void)resume;


@end
