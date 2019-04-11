//
//  WebDownLoadManager.h
//  cheyixiao
//
//  Created by bjb on 2019/3/7.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CompletionHandlerType)(void);

@interface WebInterceptDownLoadManager : NSObject<NSURLSessionDownloadDelegate>

@property (strong, nonatomic) NSMutableDictionary *completionHandlerDictionary;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong, nonatomic) NSURLSession *backgroundSession;
@property (strong, nonatomic) NSData       *resumeData;
@property(nonatomic,copy)     NSString     *basePath;
@property(nonatomic,copy)     NSString     *folderCarId;//车辆文件夹
@property(nonatomic,copy)     NSString     *folderCommon;//公共文件文件夹
@property(nonatomic,copy)     NSArray      *baseUrlArr;
@property(nonatomic,assign)   BOOL          downLoad;//Yes(边拦截边下) No(拦截的时候不需要下载)

@property(nonatomic,assign)   BOOL          log;     //Yes:开启打印  No:关闭打印
@property(nonatomic, strong)NSMutableDictionary   *downLoadHashDic;//从json文件中获取到的hash值

+(instancetype) shareInstance;
-(void)beginTask;
- (void)beginDownloadWithUrl:(NSString *)downloadURLString;
- (void)setbackGroundidentifier:(NSString *)identifier completionHandler:(CompletionHandlerType)handler;
- (void)registerWeb;
- (void)wk_registerScheme;
- (void)wk_unregisterScheme;
@end

NS_ASSUME_NONNULL_END
