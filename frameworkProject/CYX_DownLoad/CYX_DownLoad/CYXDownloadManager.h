//
//  CYXDownloadManager.h
//  CYXDownload
//
//  Created by wangqichao on 2018/12/8.
//  Copyright © 2018年 wangqichao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CYXOperationType) {
    kCYXOperationType_startAll,
    kCYXOperationType_suspendAll ,
    kCYXOperationType_resumeAll,
    kCYXOperationType_stopAll
};

#define kCYXDownloadManager [CYXDownloadManager sharedManager]


@protocol CYXDownloadManagerDelegate <NSObject>

@optional
//任务进度回调
- (void)didCompleteTaskWithWithPersent:(CGFloat)persent carID:(NSString *)carID isFinished:(BOOL)result;

@end

@class CYXWebDownloadModel;

@interface CYXDownloadManager : NSObject

@property (nonatomic, weak) id<CYXDownloadManagerDelegate> delegate;

@property (nonatomic, strong, readonly) NSMutableDictionary * downloadModels;

@property (nonatomic, strong, readonly) NSMutableDictionary * completeModels;

@property (nonatomic, strong, readonly) NSMutableDictionary * downloadingModels;

@property (nonatomic, strong, readonly) NSMutableDictionary * pauseModels;

@property (nonatomic, strong, readonly) NSMutableDictionary * waitModels;

@property (nonatomic, assign) NSInteger maxConcurrentOperationCount;
@property (nonatomic, assign) NSInteger currentOperationCount;


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
- (CYXWebDownloadModel *)downloadModelWithUrl:(NSString *)url carID:(NSString *)carID;

#pragma mark - 单任务下载控制
/**
 *  开始下载
 */
- (void)startWithDownloadModel:(CYXWebDownloadModel *)model;
/**
 *  暂停下载
 */
- (void)suspendWithDownloadModel:(CYXWebDownloadModel *)model;
/**
 *  恢复下载
 */
- (void)resumeWithDownloadModel:(CYXWebDownloadModel *)model;
/**
 *  取消下载 (取消下载后 operation将从队列中移除 并 移除下载模型和对应文件)
 */
- (void)stopWithDownloadModel:(CYXWebDownloadModel *)model;

#pragma mark - 多任务下载控制
/**
 *  批量下载操作
 */
- (void)startWithDownloadModels:(NSArray<CYXWebDownloadModel *> *)downloadModels finished:(NSString *)count;
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
