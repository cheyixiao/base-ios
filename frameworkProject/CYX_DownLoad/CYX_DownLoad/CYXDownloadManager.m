//
//  CYXDownloadManager.m
//  CYXDownload
//
//  Created by wangqichao on 2018/12/8.
//  Copyright © 2018年 wangqichao. All rights reserved.
//

#import "CYXDownloadManager.h"
#import <UIKit/UIKit.h>
#import "CYXUncaughtExceptionHandler.h"
#import "CYXDownLoadModel.h"
#import "CYXDownloadConst.h"
#import "CYXWebDownloadModel.h"
#import "CYXDownloadOperation.h"
#import "WebSourceManager.h"

@interface CYXDownloadManager ()<NSURLSessionDataDelegate,NSURLSessionTaskDelegate>{
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


@implementation CYXDownloadManager

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
    [CYXUncaughtExceptionHandler setDefaultHandler];
}

/**
 *  禁止打印进度日志
 */
- (void)enableProgressLog:(BOOL)enable
{
    _enableProgressLog = enable;
}

#pragma mark - 模型相关
- (void)addDownloadModel:(CYXWebDownloadModel *)model
{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.downloadModels [model.carID]];
    
    if (!arr) {
        arr = [NSMutableArray array];
    }
    if (![arr containsObject:model]) {
        [arr addObject:model];
    }
    
    if ([self.downloadModels.allKeys containsObject:model.carID]) {
        [self.downloadModels removeObjectForKey:model.carID];
    }
    [self.downloadModels setObject:arr forKey:model.carID];
}

- (void)addDownloadModels:(NSArray<CYXWebDownloadModel *> *)models
{
    if ([models isKindOfClass:[NSArray class]]) {
        [models enumerateObjectsUsingBlock:^(CYXWebDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addDownloadModel:obj];
        }];
    }
}
- (CYXWebDownloadModel *)downloadModelWithUrl:(NSString *)url carID:(NSString *)carID
{
    NSMutableArray *array = [self.downloadModels objectForKey:carID];
    if (array) {
        for (CYXWebDownloadModel *tmpModel in array) {
            if ([url isEqualToString:tmpModel.urlString]) {
                return tmpModel;
            }
        }
    }
    return nil;
}
#pragma mark - 单任务下载控制
- (void)startWithDownloadModel:(CYXWebDownloadModel *)model
{
    if (model.status == kCYXDownloadStatus_Completed) {
        return;
    }
    //检查队列是否挂起
    if(self.queue.suspended){
        self.queue.suspended = NO;
    }
    
    model.operation = [[CYXDownloadOperation alloc] initWithDownloadModel:model andSession:self.backgroundSession];
    [self.queue addOperation:model.operation];
}

//暂停后操作将销毁 若想继续执行 则需重新创建operation并添加
- (void)suspendWithDownloadModel:(CYXWebDownloadModel *)model
{
    [self suspendWithDownloadModel:model forAll:NO];
}


- (void)suspendWithDownloadModel:(CYXWebDownloadModel *)model forAll:(BOOL)forAll
{
    if (forAll) {//暂停全部
        if (model.status == kCYXDownloadStatus_Running) {//下载中 则暂停
            [model.operation suspend];
        }else if (model.status == kCYXDownloadStatus_Waiting){//等待中 则取消
            [model.operation cancel];
        }
    }else{
        if (model.status == kCYXDownloadStatus_Running) {
            [model.operation suspend];
        }
    }
    
    model.operation = nil;
}


- (void)resumeWithDownloadModel:(CYXWebDownloadModel *)model
{
    if (model.status == kCYXDownloadStatus_Completed ||
        model.status == kCYXDownloadStatus_Running) {
        return;
    }
    //等待中 且操作已在队列中 则无需恢复
    if (model.status == kCYXDownloadStatus_Waiting && model.operation) {
        return;
    }
    model.operation = nil;
    
    //检查队列是否挂起
    if(self.queue.suspended){
        self.queue.suspended = NO;
    }
    
    model.operation = [[CYXDownloadOperation alloc] initWithDownloadModel:model andSession:self.backgroundSession];
    [self.queue addOperation:model.operation];

}



- (void)stopWithDownloadModel:(CYXWebDownloadModel *)model
{
    [self stopWithDownloadModel:model forAll:NO];
}



- (void)stopWithDownloadModel:(CYXWebDownloadModel *)model forAll:(BOOL)forAll
{
    if (model.status != kCYXDownloadStatus_Completed) {
        [model.operation cancel];
    }
    //释放operation
    model.operation = nil;
    
    //单个删除 则直接从数组中移除下载模型 否则等清空文件后统一移除
    if(!forAll){
        NSMutableArray *arr = [self.downloadModels objectForKey:model.carID];
        if (arr) {
            [arr removeObject:model];
        } else {
        }
    }
}


#pragma mark - 批量下载相关
//存储当前下载的车源包模型
- (void)setTmpDownloadModels:(NSArray<CYXWebDownloadModel *> *)downloadModels{
    
//    [WebSourceManager shareInstance].currentArr = downloadModels;
    CYXWebDownloadModel *model = downloadModels.firstObject;
    [WebSourceManager shareInstance].currentCarID = model.carID;
    [WebSourceManager shareInstance].downing      = YES;
}
/**
 *  批量下载操作
 */
- (void)startWithDownloadModels:(NSArray<CYXWebDownloadModel *> *)downloadModels finished:(NSString *)count
{
    if (!self) {
        return;
    }
    if (downloadModels && downloadModels.count) {
        
        [WebSourceManager shareInstance].finishedCount = [count integerValue];;
        [self setTmpDownloadModels:downloadModels];
        CYXWebDownloadModel *model = downloadModels.firstObject;
        
        if ([WebSourceManager shareInstance].allCarDic && [[WebSourceManager shareInstance].allCarDic.allKeys containsObject:model.carID ] ) {
            [[WebSourceManager shareInstance].allCarDic removeObjectForKey:model.carID];
        }
        
        NSString *count = [NSString stringWithFormat:@"%lu",(long)downloadModels.count];
        if ([WebSourceManager shareInstance].carCount && [[WebSourceManager shareInstance].carCount.allKeys containsObject:model.carID]) {
            [[WebSourceManager shareInstance].carCount removeObjectForKey:model.carID];
        }
        
        [[WebSourceManager shareInstance].carCount setObject:count forKey:model.carID];
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
            CYXWebDownloadModel *downloadModel = obj;
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
                    CYXWebDownloadModel *model = obj;
                    if (model.status == kCYXDownloadStatus_Running ||
                        model.status == kCYXDownloadStatus_Waiting){
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
                CYXWebDownloadModel *model = obj;
                if (model.status == kCYXDownloadStatus_Completed) {
                    [tmpArr addObject:model];
                }
                
            }];
            if (array.count >= 1) {
                CYXWebDownloadModel *typeModel = [array firstObject];
                [mutableDic setObject:tmpArr forKey:typeModel.carID];
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
                CYXWebDownloadModel *model = obj;
                if (model.status == kCYXDownloadStatus_Running) {
                    [tmpArr addObject:model];
                }
                
            }];
            if (array.count >= 1) {
                CYXWebDownloadModel *typeModel = [array firstObject];
                [mutableDic setObject:tmpArr forKey:typeModel.carID];
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
                CYXWebDownloadModel *model = obj;
                if (model.status == kCYXDownloadStatus_Waiting) {
                    [tmpArr addObject:model];
                }
                
            }];
            if (array.count >= 1) {
                CYXWebDownloadModel *typeModel = [array firstObject];
                [mutableDic setObject:tmpArr forKey:typeModel.carID];
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
                CYXWebDownloadModel *model = obj;
                if (model.status == kCYXDownloadStatus_Suspended) {
                    [tmpArr addObject:model];
                }
                
            }];
            if (array.count >= 1) {
                CYXWebDownloadModel *typeModel = [array firstObject];
                [mutableDic setObject:tmpArr forKey:typeModel.carID];
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
    CYXWebDownloadModel *downloadModel = (CYXWebDownloadModel *)dataTask.downloadModel;
    
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
    
    CYXWebDownloadModel *downloadModel = (CYXWebDownloadModel *)dataTask.downloadModel;
    
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
            if (![[WebSourceManager shareInstance].downLoadFailUrls containsObject:task.currentRequest.URL.absoluteString] && [WebSourceManager shareInstance].cutNet == NO) {
                
                [[WebSourceManager shareInstance].downLoadFailUrls addObject:task.currentRequest.URL.absoluteString];
            }
        }
        
        [WebSourceManager shareInstance].downing      = NO;
            if ([WebSourceManager shareInstance].currentCarID && [WebSourceManager shareInstance].currentCarID.length) {
                NSDictionary *dic = @{@"carId":[WebSourceManager shareInstance].currentCarID};
                [[NSNotificationCenter defaultCenter]postNotificationName:@"webSourceStartDownLoad" object:nil userInfo:dic];
            }
        return;
    }
    
    if ([task respondsToSelector:@selector(downloadModel)] ) {
        CYXWebDownloadModel *downloadModel = (CYXWebDownloadModel *)task.downloadModel;
        if (downloadModel) {
            NSInteger totalCount = [[WebSourceManager shareInstance].carCount[downloadModel.carID] integerValue];
            
            NSMutableArray *completeArr = [WebSourceManager shareInstance].allCarDic[downloadModel.carID];
            if (downloadModel) {
                if (completeArr) {
                    if (![completeArr containsObject:downloadModel]) {
                        [completeArr addObject:downloadModel];
                    }
                    
                }else{
                    if ([WebSourceManager shareInstance].allCarDic && [[WebSourceManager shareInstance].allCarDic.allKeys containsObject:downloadModel.carID]) {
                        [[WebSourceManager shareInstance].allCarDic removeObjectForKey:downloadModel.carID];
                    }
                    completeArr = [NSMutableArray array];
                    [completeArr addObject:downloadModel];
                    [[WebSourceManager shareInstance].allCarDic setObject:completeArr forKey:downloadModel.carID];
                }
            }
            //传递进度
                CGFloat persent;
                if (totalCount == 0) {
                    persent = 0.00;
                } else {
                    persent = (CGFloat)(completeArr.count + [WebSourceManager shareInstance].finishedCount)/(totalCount + [WebSourceManager shareInstance].finishedCount) *100.f;
                }
                NSString *finished = @"1";
                BOOL result = persent == 100. && completeArr.count == totalCount;
                if (result) {
                    finished = @"2";
                    [WebSourceManager shareInstance].currentCarID = @"";
                    [WebSourceManager shareInstance].downing      = NO;

                    [self.completeModels removeObjectForKey:downloadModel.carID];
                }else{
                    
                    [WebSourceManager shareInstance].downing      = YES;

                }

            NSString *persentStr = [NSString stringWithFormat:@"%.2f",persent];
            NSDictionary *dic = @{@"persent":persentStr,@"carId":downloadModel.carID,@"result":finished};
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
