//
//  CYXDownloadConst.h
//  CYXDownload
//
//  Created by wangqichao on 2018/12/8.
//  Copyright © 2018年 wangqichao. All rights reserved.
//

#ifndef CYXDownloadConst_h
#define CYXDownloadConst_h


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

#endif /* CYXDownloadConst_h */
