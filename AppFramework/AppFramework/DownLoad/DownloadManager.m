//
//  CYXDownloadManager.m
//  CYXDownload
//
//  Created by wangqichao on 2018/12/8.
//  Copyright © 2018年 wangqichao. All rights reserved.
//

#import "DownloadManager.h"
#import <UIKit/UIKit.h>
#import "UncaughtExceptionHandler.h"
#import "DownloadConst.h"
#import "WebDownloadModel.h"
#import "DownloadOperation.h"

@interface DownloadManager ()<NSURLSessionDataDelegate,NSURLSessionTaskDelegate>{
    NSMutableDictionary *_downloadModels;
    NSMutableDictionary *_completeModels;
    NSMutableDictionary *_downloadingModels;
    NSMutableDictionary *_pauseModels;
    NSMutableDictionary *_waitModels;
    BOOL                  _enableProgressLog;
}


@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSURLSession *backgroundSession;

@end

static UIBackgroundTaskIdentifier bgTask;


@implementation DownloadManager

- (NSInteger)currentOperationCount {
    
    return self.queue.operationCount;
}
#pragma mark - 单例相关
static id instace = nil;
+ (id)allocWithZone:(struct _NSZone *)zone
{
    if (instace == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instace = [super allocWithZone:zone];
            // 添加未捕获异常的监听
            [instace handleUncaughtExreption];
            // 添加监听
            [instace addObservers];
            // 创建缓存目录
            [instace createCacheDirectory];
        });
    }
    return instace;
}

- (instancetype)init
{
    return instace;
}

+ (instancetype)sharedManager
{
    return [[self alloc] init];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return instace;
}

- (id)mutableCopyWithZone:(struct _NSZone *)zone{
    return instace;
}
#pragma mark - 单例初始化调用
/**
 *  添加监听
 */
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:instace selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:instace selector:@selector(endBackgroundTask) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:instace selector:@selector(getBackgroundTask) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:instace selector:@selector(applicationWillTerminate) name:kNotificationUncaughtException object:nil];
}

/**
 *  创建缓存目录
 */
- (void)createCacheDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:CYXCachesDirectory]) {
        [fileManager createDirectoryAtPath:CYXCachesDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    } else {
        
    }
}

/**
 *  添加未捕获异常的监听
 */
- (void)handleUncaughtExreption
{
    [UncaughtExceptionHandler setDefaultHandler];
}

/**
 *  禁止打印进度日志
 */
- (void)enableProgressLog:(BOOL)enable
{
    _enableProgressLog = enable;
}

#pragma mark - 模型相关
- (void)addDownloadModel:(WebDownloadModel *)model
{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.downloadModels [model.folder]];
    
    if (!arr) {
        arr = [NSMutableArray array];
    }
    if (![arr containsObject:model]) {
        [arr addObject:model];
    }
    
    if ([self.downloadModels.allKeys containsObject:model.folder]) {
        [self.downloadModels removeObjectForKey:model.folder];
    }
    [self.downloadModels setObject:arr forKey:model.folder];
}

- (void)addDownloadModels:(NSArray<WebDownloadModel *> *)models
{
    if ([models isKindOfClass:[NSArray class]]) {
        [models enumerateObjectsUsingBlock:^(WebDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addDownloadModel:obj];
        }];
    }
}
- (WebDownloadModel *)downloadModelWithUrl:(NSString *)url carID:(NSString *)carID
{
    NSMutableArray *array = [self.downloadModels objectForKey:carID];
    if (array) {
        for (WebDownloadModel *tmpModel in array) {
            if ([url isEqualToString:tmpModel.urlString]) {
                return tmpModel;
            }
        }
    }
    return nil;
}
#pragma mark - 单任务下载控制
- (void)startWithDownloadModel:(WebDownloadModel *)model
{
    if (model.status == kDownloadStatus_Completed) {
        return;
    }
    //检查队列是否挂起
    if(self.queue.suspended){
        self.queue.suspended = NO;
    }
    
    model.operation = [[DownloadOperation alloc] initWithDownloadModel:model andSession:self.backgroundSession];
    [self.queue addOperation:model.operation];
}

//暂停后操作将销毁 若想继续执行 则需重新创建operation并添加
- (void)suspendWithDownloadModel:(WebDownloadModel *)model
{
    [self suspendWithDownloadModel:model forAll:NO];
}


- (void)suspendWithDownloadModel:(WebDownloadModel *)model forAll:(BOOL)forAll
{
    if (forAll) {//暂停全部
        if (model.status == kDownloadStatus_Running) {//下载中 则暂停
            [model.operation suspend];
        }else if (model.status == kDownloadStatus_Waiting){//等待中 则取消
            [model.operation cancel];
        }
    }else{
        if (model.status == kDownloadStatus_Running) {
            [model.operation suspend];
        }
    }
    
    model.operation = nil;
}


- (void)resumeWithDownloadModel:(WebDownloadModel *)model
{
    if (model.status == kDownloadStatus_Completed ||
        model.status == kDownloadStatus_Running) {
        return;
    }
    //等待中 且操作已在队列中 则无需恢复
    if (model.status == kDownloadStatus_Waiting && model.operation) {
        return;
    }
    model.operation = nil;
    
    //检查队列是否挂起
    if(self.queue.suspended){
        self.queue.suspended = NO;
    }
    
    model.operation = [[DownloadOperation alloc] initWithDownloadModel:model andSession:self.backgroundSession];
    [self.queue addOperation:model.operation];

}



- (void)stopWithDownloadModel:(WebDownloadModel *)model
{
    [self stopWithDownloadModel:model forAll:NO];
}



- (void)stopWithDownloadModel:(WebDownloadModel *)model forAll:(BOOL)forAll
{
    if (model.status != kDownloadStatus_Completed) {
        [model.operation cancel];
    }
    //释放operation
    model.operation = nil;
    
    //单个删除 则直接从数组中移除下载模型 否则等清空文件后统一移除
    if(!forAll){
        NSMutableArray *arr = [self.downloadModels objectForKey:model.folder];
        if (arr) {
            [arr removeObject:model];
        } else {
        }
    }
}


#pragma mark - 批量下载相关
//存储当前下载的车源包模型
- (void)setTmpDownloadModels:(NSArray<WebDownloadModel *> *)downloadModels{
    
//    [WebSourceManager shareInstance].currentArr = downloadModels;
    WebDownloadModel *model = downloadModels.firstObject;
    [DownloadManager sharedManager].downLoadCenterManager.currentCarID = model.folder;
    [DownloadManager sharedManager].downLoadCenterManager.downing      = YES;
}
/**
 *  批量下载操作
 */
- (void)startWithDownloadModels:(NSArray<WebDownloadModel *> *)downloadModels finished:(NSString *)count
{
    if (!self) {
        return;
    }
    if (downloadModels && downloadModels.count) {
        
        [DownloadManager sharedManager].downLoadCenterManager.finishedCount = [count integerValue];;
        [self setTmpDownloadModels:downloadModels];
        WebDownloadModel *model = downloadModels.firstObject;
        
        if ([DownloadManager sharedManager].downLoadCenterManager.allCarDic && [[DownloadManager sharedManager].downLoadCenterManager.allCarDic.allKeys containsObject:model.folder ] ) {
            [[DownloadManager sharedManager].downLoadCenterManager.allCarDic removeObjectForKey:model.folder];
        }
        
        NSString *count = [NSString stringWithFormat:@"%lu",(long)downloadModels.count];
        if ([DownloadManager sharedManager].downLoadCenterManager.carCount && [[DownloadManager sharedManager].downLoadCenterManager.carCount.allKeys containsObject:model.folder]) {
            [[DownloadManager sharedManager].downLoadCenterManager.carCount removeObjectForKey:model.folder];
        }
        
        [[DownloadManager sharedManager].downLoadCenterManager.carCount setObject:count forKey:model.folder];
        [self addDownloadModels:downloadModels];
        [self operateTasksWithOperationType:kCYXOperationType_startAll];
    }
    
}

/**
 *  暂停所有下载任务
 */
- (void)suspendAll
{
    //保存任务模型
    [self.queue setSuspended:YES];
    [self operateTasksWithOperationType:kCYXOperationType_suspendAll];
    
}

/**
 *  恢复下载任务（进行中、已完成、等待中除外）
 */
- (void)resumeAll
{
    [self.queue setSuspended:NO];
    [self operateTasksWithOperationType:kCYXOperationType_resumeAll];
}

/**
 *  停止并删除下载任务
 */
- (void)stopAll
{
    //销毁前暂停队列 防止等待中的任务执行
    [self.queue setSuspended:YES];
    [self.queue cancelAllOperations];
    [self operateTasksWithOperationType:kCYXOperationType_stopAll];
    _queue = nil;
    [self.downloadModels removeAllObjects];
    _downloadModels = nil;
}


- (void)operateTasksWithOperationType:(CYXOperationType)operationType
{
    if (!self) {
        return;
    }
    //此处开启的是所有车包得总下载任务
    [self.downloadModels enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableArray *array = obj;
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WebDownloadModel *downloadModel = obj;
            switch (operationType) {
                case kCYXOperationType_startAll:
                    [self startWithDownloadModel:downloadModel];
                    break;
                case kCYXOperationType_suspendAll:
                    [self suspendWithDownloadModel:downloadModel forAll:YES];
                    break;
                case kCYXOperationType_resumeAll:
                    [self resumeWithDownloadModel:downloadModel];
                    break;
                case kCYXOperationType_stopAll:
                    [self stopWithDownloadModel:downloadModel forAll:YES];
                    break;
                default:
                    break;
            }
        }];
    }];
}

/**
 *  从备份恢复下载数据
 */
- (void)recoverDownloadModels
{
    if ([kFileManager fileExistsAtPath:CYXSavedDownloadModelsBackup]) {
        NSError * error = nil;
        [kFileManager removeItemAtPath:CYXSavedDownloadModelsFilePath error:nil];
        BOOL recoverSuccess = [kFileManager copyItemAtPath:CYXSavedDownloadModelsBackup toPath:CYXSavedDownloadModelsFilePath error:&error];
        if (recoverSuccess) {
            
            [self.downloadModels enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSMutableArray *array = obj;
                [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    WebDownloadModel *model = obj;
                    if (model.status == kDownloadStatus_Running ||
                        model.status == kDownloadStatus_Waiting){
                        [self startWithDownloadModel:model];
                    }
                }];
            }];

        }else{
        }
    }
}

#pragma mark - 文件相关
/**
 *  保存下载模型
 */
- (void)saveData
{
    [kFileManager removeItemAtPath:CYXSavedDownloadModelsFilePath error:nil];
    BOOL flag = [NSKeyedArchiver archiveRootObject:self.downloadModels toFile:CYXSavedDownloadModelsFilePath];
   
    
    if (flag) {
        [self backupFile];
    }
}
/**
 *  备份下载模型
 */
- (void)backupFile
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        BOOL exist = [kFileManager fileExistsAtPath:CYXSavedDownloadModelsFilePath];
        if (exist) {
            BOOL backupSuccess = [kFileManager copyItemAtPath:CYXSavedDownloadModelsFilePath toPath:CYXSavedDownloadModelsBackup error:&error];
            if (backupSuccess) {
            }else{
                [self backupFile];
            }
        }
    });
}
/**
 *  移除备份
 */
- (void)removeBackupFile
{
    if ([kFileManager fileExistsAtPath:CYXSavedDownloadModelsBackup]) {
        NSError * error = nil;
        BOOL success = [kFileManager removeItemAtPath:CYXSavedDownloadModelsBackup error:&error];
        if (success) {
        }else{
        }
    }
}

/**
 *  移除目录中所有文件
 */
- (void)removeAllFiles
{
    [self removeBackupFile];
    //返回路径中的文件数组
    NSArray * files = [[NSFileManager defaultManager] subpathsAtPath:CYXCachesDirectory];
    
    for(NSString *p in files) {
        NSError*error;
        
        NSString*path = [CYXCachesDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@",p]];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            BOOL isRemove = [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
            if(isRemove) {
            }else{
            }
        }
    }
}

#pragma mark - Private Method

#pragma mark - Getters/Setters
- (NSMutableDictionary *)downloadModels
{
    if (!_downloadModels) {
        //查看本地是否有数据
        _downloadModels = [NSMutableDictionary dictionary];
    }
    return _downloadModels;
}

- (NSMutableDictionary *)completeModels
{
    __block  NSMutableArray *tmpArr = [NSMutableArray array];
    __block  NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    if (self.downloadModels) {
        [self.downloadModels enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSMutableArray *array = obj;
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                WebDownloadModel *model = obj;
                if (model.status == kDownloadStatus_Completed) {
                    [tmpArr addObject:model];
                }
                
            }];
            if (array.count >= 1) {
                WebDownloadModel *typeModel = [array firstObject];
                [mutableDic setObject:tmpArr forKey:typeModel.folder];
            }
        }];
    }
    
    _completeModels = mutableDic;
    return _completeModels;
}

- (NSMutableDictionary *)downloadingModels
{
    __block  NSMutableArray *tmpArr = [NSMutableArray array];
    __block  NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    if (self.downloadModels) {
        [self.downloadModels enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSMutableArray *array = obj;
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                WebDownloadModel *model = obj;
                if (model.status == kDownloadStatus_Running) {
                    [tmpArr addObject:model];
                }
                
            }];
            if (array.count >= 1) {
                WebDownloadModel *typeModel = [array firstObject];
                [mutableDic setObject:tmpArr forKey:typeModel.folder];
            }
        }];
    }
    _downloadingModels = mutableDic;
    return _downloadingModels;
}




- (NSMutableDictionary *)waitModels
{
    __block  NSMutableArray *tmpArr = [NSMutableArray array];
    __block  NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    if (self.downloadModels) {
        [self.downloadModels enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSMutableArray *array = obj;
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                WebDownloadModel *model = obj;
                if (model.status == kDownloadStatus_Waiting) {
                    [tmpArr addObject:model];
                }
                
            }];
            if (array.count >= 1) {
                WebDownloadModel *typeModel = [array firstObject];
                [mutableDic setObject:tmpArr forKey:typeModel.folder];
            }
        }];
    }

    _waitModels = mutableDic;
    return _waitModels;
}



- (NSMutableDictionary *)pauseModels
{
    __block  NSMutableArray *tmpArr = [NSMutableArray array];
    __block  NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    if (self.downloadModels) {
        [self.downloadModels enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSMutableArray *array = obj;
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                WebDownloadModel *model = obj;
                if (model.status == kDownloadStatus_Suspended) {
                    [tmpArr addObject:model];
                }
                
            }];
            if (array.count >= 1) {
                WebDownloadModel *typeModel = [array firstObject];
                [mutableDic setObject:tmpArr forKey:typeModel.folder];
            }
        }];
    }

    _pauseModels = mutableDic;
    return _pauseModels;
}



- (NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:CYXDownloadMaxConcurrentOperationCount];
    }
    return _queue;
}


- (void)setMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount
{
    _maxConcurrentOperationCount = maxConcurrentOperationCount;
    self.queue.maxConcurrentOperationCount = _maxConcurrentOperationCount;
}


- (NSURLSession *)backgroundSession
{
    if (!_backgroundSession) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
        //不能传self.queue
        _backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    
    return _backgroundSession;
}


- (BOOL)enableProgressLog
{
    return _enableProgressLog;
}

#pragma mark - 后台任务相关
/**
 *  获取后台任务
 */
- (void)getBackgroundTask
{
    UIBackgroundTaskIdentifier tempTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
    }];
    
    if (bgTask != UIBackgroundTaskInvalid) {
        
        [self endBackgroundTask];
    }
    
    bgTask = tempTask;
    
    [self performSelector:@selector(getBackgroundTask) withObject:nil afterDelay:120];
}


/**
 *  结束后台任务
 */
- (void)endBackgroundTask
{
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
}



#pragma mark - Event Response
/**
 *  应用强关或闪退时 保存下载数据
 */
- (void)applicationWillTerminate
{
    [self saveData];
}


#pragma mark - NSURLSessionDataDelegate
/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    if (!self) {
        return;
    }
    if (![dataTask respondsToSelector:@selector(downloadModel)]) {
        return;
    }
    WebDownloadModel *downloadModel = (WebDownloadModel *)dataTask.downloadModel;
    
    // 打开流
    [downloadModel.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + downloadModel.fileDownloadSize;
    downloadModel.fileTotalSize = totalLength;
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    
    

  
    if (!self) {
        return;
    }
    if (![dataTask respondsToSelector:@selector(downloadModel)] ) {
        return;
    }
    
    WebDownloadModel *downloadModel = (WebDownloadModel *)dataTask.downloadModel;
    
    // 写入数据
    [downloadModel.stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    NSInteger totalBytesWritten = downloadModel.fileDownloadSize;
    NSInteger totalBytesExpectedToWrite = downloadModel.fileTotalSize;
    
    double byts = totalBytesWritten * 1.0 / 1024 /1024;
    double total = totalBytesExpectedToWrite * 1.0 / 1024 /1024;
    NSString *text = [NSString stringWithFormat:@"%.1lfMB/%.1lfMB",byts,total];
    
    CGFloat progress = 1.0 * byts / total;
    
    downloadModel.statusText = text;
    downloadModel.progress = progress;
   
    
}

/**
 * 请求完毕 下载成功 | 失败
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
       
        if (task.currentRequest.URL.absoluteString && task.currentRequest.URL.absoluteString.length) {
            if (![[DownloadManager sharedManager].downLoadCenterManager.downLoadFailUrls containsObject:task.currentRequest.URL.absoluteString] && [DownloadManager sharedManager].downLoadCenterManager.cutNet == NO) {
                
                [[DownloadManager sharedManager].downLoadCenterManager.downLoadFailUrls addObject:task.currentRequest.URL.absoluteString];
            }
        }
        
        [DownloadManager sharedManager].downLoadCenterManager.downing      = NO;
            if ([DownloadManager sharedManager].downLoadCenterManager.currentCarID && [DownloadManager sharedManager].downLoadCenterManager.currentCarID.length) {
                NSDictionary *dic = @{@"carId":[DownloadManager sharedManager].downLoadCenterManager.currentCarID};
                [[NSNotificationCenter defaultCenter]postNotificationName:@"webSourceStartDownLoad" object:nil userInfo:dic];
            }
        return;
    }
    
    if ([task respondsToSelector:@selector(downloadModel)] ) {
        WebDownloadModel *downloadModel = (WebDownloadModel *)task.downloadModel;
        if (downloadModel) {
            NSInteger totalCount = [[DownloadManager sharedManager].downLoadCenterManager.carCount[downloadModel.folder] integerValue];
            
            NSMutableArray *completeArr = [DownloadManager sharedManager].downLoadCenterManager.allCarDic[downloadModel.folder];
            if (downloadModel) {
                if (completeArr) {
                    if (![completeArr containsObject:downloadModel]) {
                        [completeArr addObject:downloadModel];
                    }
                    
                }else{
                    if ([DownloadManager sharedManager].downLoadCenterManager.allCarDic && [[DownloadManager sharedManager].downLoadCenterManager.allCarDic.allKeys containsObject:downloadModel.folder]) {
                        [[DownloadManager sharedManager].downLoadCenterManager.allCarDic removeObjectForKey:downloadModel.folder];
                    }
                    completeArr = [NSMutableArray array];
                    [completeArr addObject:downloadModel];
                    [[DownloadManager sharedManager].downLoadCenterManager.allCarDic setObject:completeArr forKey:downloadModel.folder];
                }
            }
            //传递进度
                CGFloat persent;
                if (totalCount == 0) {
                    persent = 0.00;
                } else {
                    persent = (CGFloat)(completeArr.count + [DownloadManager sharedManager].downLoadCenterManager.finishedCount)/(totalCount + [DownloadManager sharedManager].downLoadCenterManager.finishedCount) *100.f;
                }
                NSString *finished = @"1";
                BOOL result = persent == 100. && completeArr.count == totalCount;
                if (result) {
                    finished = @"2";
                    [DownloadManager sharedManager].downLoadCenterManager.currentCarID = @"";
                    [DownloadManager sharedManager].downLoadCenterManager.downing      = NO;

                    [self.completeModels removeObjectForKey:downloadModel.folder];
                }else{
                    
                    [DownloadManager sharedManager].downLoadCenterManager.downing      = YES;

                }

            NSString *persentStr = [NSString stringWithFormat:@"%.2f",persent];
            NSDictionary *dic = @{@"persent":persentStr,@"carId":downloadModel.folder,@"result":finished};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"webCarSourceDownLoad" object:nil userInfo:dic];
  
        }
        
        [downloadModel.stream close];
        downloadModel.stream = nil;
        task = nil;
    }
    
    
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}
@end
