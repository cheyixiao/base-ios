//
//  CYXWebDownloadModel.h
//  CYXDownload
//
//  Created by wangqichao on 2018/12/8.
//  Copyright © 2018年 wangqichao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CYXDownloadOperation;
@class CYXWebDownloadModel;


typedef NS_ENUM(NSUInteger, CYXDownloadStatus) {
    kCYXDownloadStatus_None = 0,
    kCYXDownloadStatus_Running = 1,
    kCYXDownloadStatus_Suspended = 2,
    kCYXDownloadStatus_Completed = 3,  // 下载完成
    kCYXDownloadStatus_Failed  = 4,    // 下载失败
    kCYXDownloadStatus_Waiting = 5,   // 等待下载
    kCYXDownloadStatus_Cancel = 6,      // 取消下载
};


typedef void(^DownloadStatusChanged)(CYXWebDownloadModel *downloadModel);

typedef void(^DownloadProgressChanged)(CYXWebDownloadModel *downloadModel);



@interface CYXWebDownloadModel : NSObject<NSCoding>


@property (nonatomic ,copy) NSString * urlString;

@property (nonatomic, copy) NSString * downloadDesc;//下载描述信息

@property (nonatomic, copy) NSString *md5Name;//文件夹唯一标识

@property (nonatomic, copy) NSString *carID;//车型唯一标识

@property (nonatomic, copy) NSString * fileName;

@property (nonatomic, copy) NSString * fileFormat;

@property (nonatomic, copy) NSString * destinationPath;//文件存放地址

@property (nonatomic, strong) CYXDownloadOperation * operation;//下载操作

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) CYXDownloadStatus status;

@property (nonatomic, copy) NSString * statusText;

@property (nonatomic, copy) NSString * completeTime;//下载完成时间

@property (nonatomic, copy) DownloadStatusChanged statusChanged;//状态改变回调

@property (nonatomic, copy) DownloadProgressChanged progressChanged;//进度改变回调

@property (nonatomic, assign) BOOL isLast;//数组最后一个模型



/** 文件总大小 */
@property (nonatomic, assign) NSInteger fileTotalSize;
/** 已下载文件大小 */
@property (nonatomic, assign) NSInteger fileDownloadSize;
/** 输出流 */
@property (nonatomic, strong) NSOutputStream *stream;
/** 下载完成 */
@property (nonatomic, assign) BOOL isFinished;


@end
