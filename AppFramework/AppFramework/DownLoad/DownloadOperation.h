//
//  CYXDownloadOperation.h
//  CYXDownload
//
//  Created by wangqichao on 2018/12/8.
//  Copyright © 2018年 wangqichao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSURLSessionTask+DownLoadModel.h"

typedef void(^DownloadStatusChangedBlock)(void);

@class WebDownloadModel;

@interface DownloadOperation : NSOperation


@property (nonatomic, weak) WebDownloadModel * downloadModel;

@property (nonatomic, strong) NSURLSessionDataTask * downloadTask;

@property (nonatomic ,weak) NSURLSession *session;

/** 下载状态改变回调 */
@property (nonatomic, copy) DownloadStatusChangedBlock downloadStatusChangedBlock ;

- (instancetype)initWithDownloadModel:(WebDownloadModel *)downloadModel andSession:(NSURLSession *)session;


- (void)suspend;
- (void)resume;


@end
