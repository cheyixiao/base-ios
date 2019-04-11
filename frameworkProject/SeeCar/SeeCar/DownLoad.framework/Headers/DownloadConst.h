//
//  CYXDownloadConst.h
//  CYXDownload
//
//  Created by wangqichao on 2018/12/8.
//  Copyright © 2018年 wangqichao. All rights reserved.
//

#ifndef DownloadConst_h
#define DownloadConst_h


#define kFileManager [NSFileManager defaultManager]

// 缓存主目录
//#define  CYXCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/WCYXDownload/"]

#define  CYXSavedDownloadModelsFilePath [CYXCachesDirectory stringByAppendingFormat:@"CYXSavedDownloadModels"]

#define  CYXSavedDownloadModelsBackup [CYXCachesDirectory stringByAppendingFormat:@"CYXSavedDownloadModelsBackup"]

#define  CYXLocalDownloadModelsFilePath [CYXCachesDirectory stringByAppendingFormat:@"CYXLocalDownloadModels"]

#define  CYX_tmpDownloadBaseFilePath [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define  CYXCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/NoCloud/cars/"]


// 下载operation最大并发数
#define CYXDownloadMaxConcurrentOperationCount  1

//下载状态
typedef NS_ENUM(NSUInteger,CYXCarSourceDownLoadStaus) {
    NotDownLoad = 1,   //未下载
    updateDownLoad = 2, //有更新
    queueDownLoad = 3,  //排队中
    doneDownLoad = 4,    //下载完成
    ingDownLoad = 5    //下载中
};

#endif /* CYXDownloadConst_h */
