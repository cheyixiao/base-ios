//
//  WebDownLoadManager.m
//  cheyixiao
//
//  Created by bjb on 2019/3/7.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import "WebInterceptDownLoadManager.h"
#import <UIKit/UIKit.h>
#import "MyURLProtocol.h"
#import "NSURLProtocol+WKWebVIew.h"
#import <CommonCrypto/CommonDigest.h>
#import <BaseFramework/NSData+Extension.h>

#define  CYXCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/NoCloud/"]

@implementation WebInterceptDownLoadManager

static WebInterceptDownLoadManager* instance = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
        instance.completionHandlerDictionary = @{}.mutableCopy;
        instance.backgroundSession = [instance backgroundURLSession];
    }) ;
    
    return instance ;
}
+(id) allocWithZone:(struct _NSZone *)zone
{
    return [WebInterceptDownLoadManager shareInstance] ;
}
-(id) copyWithZone:(struct _NSZone *)zone
{
    return [WebInterceptDownLoadManager shareInstance] ;
}
- (void)registerWeb{
    [NSURLProtocol registerClass:[MyURLProtocol class]];

}
- (void)wk_registerScheme{
    
    [NSURLProtocol wk_registerScheme:@"http"];
    [NSURLProtocol wk_registerScheme:@"https"];
}
- (void)wk_unregisterScheme{
    
    [NSURLProtocol wk_unregisterScheme:@"http"];
    [NSURLProtocol wk_unregisterScheme:@"https"];
}
#pragma mark - backgroundURLSession
- (NSURLSession *)backgroundURLSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifier = @"com.yourcompany.appId.BackgroundSession";
        NSURLSessionConfiguration* sessionConfig = nil;
        #if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000)
                sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        #else
                sessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
        #endif
        
        session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                delegate:self
                                           delegateQueue:nil];
    });
    
    return session;
}
#pragma mark Save completionHandler
- (void)setbackGroundidentifier:(NSString *)identifier completionHandler:(CompletionHandlerType)handler{
    /*
     你必须重新建立一个后台 seesion 的参照 否则 NSURLSessionDownloadDelegate 和 NSURLSessionDelegate 方法会因为没有对 session 的 delegate 设定而不会被调用。参见上面的 backgroundURLSession
    */
    
    // 保存 completion handler 以在处理 session 事件后更新 UI
    [self addCompletionHandler:handler forSession:identifier];
}
- (void)addCompletionHandler:(CompletionHandlerType)handler forSession:(NSString *)identifier {
    if ([self.completionHandlerDictionary objectForKey:identifier]) {
      
    }
    
    [self.completionHandlerDictionary setObject:handler forKey:identifier];
}

- (void)callCompletionHandlerForSession:(NSString *)identifier {
    CompletionHandlerType handler = [self.completionHandlerDictionary objectForKey:identifier];
    
    if (handler) {
        [self.completionHandlerDictionary removeObjectForKey: identifier];
        
        handler();
    }
}
-(void)beginTask
{
    UIBackgroundTaskIdentifier _backIden = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        // 如果在系统规定时间内任务还没有完成，在时间到之前会调用到这个方法，一般是10分钟
        
        [self endBack:_backIden];
    }];
}
//
-(void)endBack:(UIBackgroundTaskIdentifier )backIden
{
    [[UIApplication sharedApplication] endBackgroundTask:backIden];
    backIden = UIBackgroundTaskInvalid;
    //    [self beginTask];
    //    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
}
- (void)beginDownloadWithUrl:(NSString *)downloadURLString {
    NSURL *downloadURL = [NSURL URLWithString:downloadURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadURL];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", (long long int)[self hasDownloadedLength:downloadURL]] forHTTPHeaderField:@"Range"];
    //cancel last download task
    //    [self.downloadTask cancelByProducingResumeData:^(NSData * resumeData) {
    //
    //    }];
    self.downloadTask = [self.backgroundSession downloadTaskWithRequest:request];
    [self.downloadTask resume];
}
- (NSInteger)hasDownloadedLength:(NSURL *)URL {
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self fileFullPathOfURL:URL] error:nil];
    if (!fileAttributes) {
        return 0;
    }
    return [fileAttributes[NSFileSize] integerValue];
}
- (NSString *)fileFullPathOfURL:(NSURL *)URL {
    
    return [self pathWithFolder:URL];
}
- (NSString *)pathWithFolder:(NSURL *)url{
    
//    NSString *localPath = @"";
//    if ([url.absoluteString containsString:[WebInterceptDownLoadManager shareInstance].folderCarId]) {
//        localPath = [WebInterceptDownLoadManager shareInstance].folderCarId;
//
//    }else if ([url.absoluteString containsString:[WebInterceptDownLoadManager shareInstance].folderCommon]){
//
//         localPath = [WebInterceptDownLoadManager shareInstance].folderCommon;
//
//    }else{
//        localPath = @"webIntercept";
//    }
    
//    NSString *patientPhotoFolder = [[WebInterceptDownLoadManager shareInstance].basePath?:CYXCachesDirectory stringByAppendingPathComponent:localPath];
    
//    NSFileManager *fileManager = [[NSFileManager alloc] init];
//    if (![fileManager fileExistsAtPath:patientPhotoFolder]) {
//        [fileManager createDirectoryAtPath:patientPhotoFolder
//
//               withIntermediateDirectories:YES
//
//                                attributes:nil
//
//                                     error:nil];
//    }
    //储存文件名称+格式
    NSString *absoluteString        = url.absoluteString;
    for (NSString *baseUrl in [WebInterceptDownLoadManager shareInstance].baseUrlArr) {
        if ([absoluteString containsString:baseUrl]) {
            absoluteString                  = [absoluteString substringFromIndex:baseUrl.length];//截取掉下标baseUrl.length之后的字符串
            break;
        }
    }
    NSString *basePath            = [WebInterceptDownLoadManager shareInstance].basePath?:CYXCachesDirectory;
    
    NSString *patientPhotoFolder = [basePath stringByAppendingPathComponent:[absoluteString stringByDeletingLastPathComponent]];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:patientPhotoFolder]) {
        [fileManager createDirectoryAtPath:patientPhotoFolder
         
               withIntermediateDirectories:YES
         
                                attributes:nil
         
                                     error:nil];
    }
//    NSString * fileName = [self md5:absoluteString];
//    fileName            = [fileName stringByAppendingString:[self fileFormat:url.lastPathComponent]];
//
//    patientPhotoFolder = [patientPhotoFolder stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]];
    
     NSString *destinationPath = [patientPhotoFolder stringByAppendingString:[NSString stringWithFormat:@"/%@",[absoluteString lastPathComponent]]];
    
    return destinationPath;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    NSString *finalLocation = [self pathWithFolder:downloadTask.currentRequest.URL];
    if ([WebInterceptDownLoadManager shareInstance].log) {
       NSLog(@"finalLocation:::::::::::%@",finalLocation);
    }
    
     // 用 NSFileManager 将文件复制到应用的存储中
    NSString *locationString = [location path];
    NSMutableArray *keys     = [NSMutableArray arrayWithArray:[WebInterceptDownLoadManager shareInstance].downLoadHashDic.allKeys];
    if (![keys containsObject:downloadTask.currentRequest.URL.absoluteString]) {
        //不需要hash校验
        NSError *error;
        [[NSFileManager defaultManager] moveItemAtPath:locationString toPath:finalLocation error:&error];
    }else{
        NSData *data             = [NSData dataWithContentsOfFile:locationString];
        if (data) {
            NSString *downLoadMD5 = data.getMD5Data;
            NSString *hash        = [WebInterceptDownLoadManager shareInstance].downLoadHashDic[downloadTask.currentRequest.URL.absoluteString];
            if ([hash isEqualToString:downLoadMD5]) {
                NSError *error;
                [[NSFileManager defaultManager] moveItemAtPath:locationString toPath:finalLocation error:&error];
            }
        }
    }
    
   
}
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    

}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
    if (session.configuration.identifier) {
        // 调用在 -application:handleEventsForBackgroundURLSession: 中保存的 handler
        [self callCompletionHandlerForSession:session.configuration.identifier];
    }
}

/*
 * 该方法下载成功和失败都会回调，只是失败的是error是有值的，
 * 在下载失败时，error的userinfo属性可以通过NSURLSessionDownloadTaskResumeData
 * 这个key来取到resumeData(和上面的resumeData是一样的)，再通过resumeData恢复下载
 */
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    
    if (error) {
        // check if resume data are available
        if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]) {
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            //通过之前保存的resumeData，获取断点的NSURLSessionTask，调用resume恢复下载
            self.resumeData = resumeData;
            
        }
    } else {
        
    }
}
- (nullable NSString *)md5:(nullable NSString *)str {
    if (!str) return nil;
    
    const char *cStr = str.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *md5Str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    return md5Str;
}
- (NSString *)fileFormat:(NSString *)url{
    NSString *fileFormat = @"";
    NSArray *urlArr = [url componentsSeparatedByString:@"."];
    if (urlArr && urlArr.count>1) {
        fileFormat = [@"." stringByAppendingString:[urlArr lastObject]];
    }
    return fileFormat;
}
-(NSMutableDictionary *)downLoadHashDic{
    if (!_downLoadHashDic) {
        _downLoadHashDic = [NSMutableDictionary dictionary];
    }
    return _downLoadHashDic;
}
@end
