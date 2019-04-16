//
//  CYXDownloadManager.h
//  CYXDownload
//
//  Created by wangqichao on 2018/12/8.
//  Copyright © 2018年 wangqichao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DownLoadCenterManager.h"

typedef NS_ENUM(NSUInteger, CYXOperationType) {
    kCYXOperationType_startAll,
    kCYXOperationType_suspendAll ,
    kCYXOperationType_resumeAll,
    kCYXOperationType_stopAll
};

#define kCYXDownloadManager [DownloadManager sharedManager]


@protocol DownloadManagerDelegate <NSObject>

@optional
//任务进度回调
- (void)didCompleteTaskWithWithPersent:(CGFloat)persent carID:(NSString *)carID isFinished:(BOOL)result;

@end

@class WebDownloadModel;

@interface DownloadManager : NSObject

@property (nonatomic, weak) id<DownloadManagerDelegate> delegate;

@property (nonatomic, strong, readonly) NSMutableDictionary * downloadModels;

@property (nonatomic, strong, readonly) NSMutableDictionary * completeModels;

@property (nonatomic, strong, readonly) NSMutableDictionary * downloadingModels;

@property (nonatomic, strong, readonly) NSMutableDictionary * pauseModels;

@property (nonatomic, strong, readonly) NSMutableDictionary * waitModels;

@property (nonatomic, assign) NSInteger maxConcurrentOperationCount;
@property (nonatomic, assign) NSInteger currentOperationCount;
@property (nonatomic, strong) DownLoadCenterManager *downLoadCenterManager;


/** 是否禁用进度打印日志 */
@property (readonly, nonatomic, assign) BOOL enableProgressLog;

#pragma mark - 单例方法
+ (instancetype)sharedManager;
/**
 *  禁止打印进度日志
 */
- (void)enableProgressLog:(BOOL)enable;
/**
 *  获取下载模型
 */
- (WebDownloadModel *)downloadModelWithUrl:(NSString *)url carID:(NSString *)carID;

#pragma mark - 单任务下载控制
/**
 *  开始下载
 */
- (void)startWithDownloadModel:(WebDownloadModel *)model;
/**
 *  暂停下载
 */
- (void)suspendWithDownloadModel:(WebDownloadModel *)model;
/**
 *  恢复下载
 */
- (void)resumeWithDownloadModel:(WebDownloadModel *)model;
/**
 *  取消下载 (取消下载后 operation将从队列中移除 并 移除下载模型和对应文件)
 */
- (void)stopWithDownloadModel:(WebDownloadModel *)model;

#pragma mark - 多任务下载控制
/**
 *  批量下载操作
 */
- (void)startWithDownloadModels:(NSArray<WebDownloadModel *> *)downloadModels finished:(NSString *)count;
/**
 *  暂停所有下载任务
 */
- (void)suspendAll;
/**
 *  恢复下载任务（进行中、已完成、等待中除外）
 */
- (void)resumeAll;
/**
 *  停止并删除下载任务
 */
- (void)stopAll;


@end
