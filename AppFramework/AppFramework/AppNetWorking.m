//
//  AppNetWorking.m
//  AppFramework
//
//  Created by bjb on 2019/3/19.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import "AppNetWorking.h"
#import "Reachability.h"
#import "NSString+Extension.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"





@interface AppNetWorking ()



@end

@implementation AppNetWorking

static AppNetWorking* instance = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    }) ;
    return instance ;
}
+(id) allocWithZone:(struct _NSZone *)zone
{
    return [AppNetWorking shareInstance] ;
}
-(id) copyWithZone:(struct _NSZone *)zone
{
    return [AppNetWorking shareInstance] ;
}
-(AFHTTPSessionManager *)httpSessionManager{
    if (!_httpSessionManager) {
        //需要在建立 AFHTTPSessionManager的同时设置baseUrl
        _httpSessionManager = [AFHTTPSessionManager manager] ;
        //指定可接收服务器的数据的类型
        _httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        //指定向服务器发送的数据的类型
        [_httpSessionManager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        //        _httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.timeoutInterval = NETWORK_REQUST_TIME_OUT;
        _httpSessionManager.requestSerializer.timeoutInterval = self.timeoutInterval;
        //网络初始值默认为Unknown
        //        _networkStatus = NetworkReachabilityStatusUnknown;
        //        _httpSessionManager.securityPolicy.allowInvalidCertificates = YES;
        //        _httpSessionManager.securityPolicy.validatesDomainName = NO;
        //        if ([Connect_Host_Url containsString:@"https"]) {
        //                    [_httpSessionManager setSecurityPolicy:[CCRequestManager customSecurityPolicy]];
        //        }
    }
    return _httpSessionManager;
}

+ (AFSecurityPolicy*)customSecurityPolicy
{
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"pdhz" ofType:@"cer"];//证书的路径
    
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = NO;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = YES;
    
    securityPolicy.pinnedCertificates = [NSSet setWithObjects:certData, nil];
    
    return securityPolicy;
}

- (void)postImageWithURLString:(NSString *_Nullable)urlString
                      imageArr:(NSArray*_Nullable)imageArr
                   fileNameArr:(NSArray*_Nullable)fileNameArr
                     uploadKey:(NSString*_Nullable)uploadKey
                   requestBody:(NSDictionary *_Nullable)body
           uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                       success:(void(^_Nullable)(id  _Nullable responseObject))success
                       failurl:(void(^_Nullable)(NSError * _Nonnull error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/javascript",@"text/json",@"text/plain", nil];
    //    formData: 专门用于拼接需要上传的数据,在此位置生成一个要上传的数据体
    [manager POST:urlString parameters:body constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        //  图片上传
        for (NSInteger i = 0; i <imageArr.count; i ++) {
            UIImage *image = imageArr[i];
            NSData *picData = UIImageJPEGRepresentation(image, 0.2);
            
            [formData appendPartWithFileData:picData name:uploadKey fileName:fileNameArr[i] mimeType:@"image/png"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (uploadProgressBlock) {
            uploadProgressBlock( uploadProgress );
        }
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if( task.state != NSURLSessionTaskStateCanceling ){
                    if( success ) {
                        success(responseObject);
                    }
                }else{
                    if( success ) {
                        success(nil);
                    }
                }
            });
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        
    }];
}

- (void)getApiSessionTaskWithURLString:(NSString *_Nullable)urlString
                            parameters:(NSDictionary *_Nullable)parameters
                   uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                               success:(void(^_Nullable)(NSDictionary * _Nullable result))success
                               failurl:(void(^_Nullable)(void))failure{
    //1、判断网络，无网络return。
    if( [AppNetWorking networkReachibility] == NO )
    {
        if( failure )   failure();
        return;
    }
    //2、打开手机上网络请求提示
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
    });
    if ([urlString containsString:@".json"]) {
        self.httpSessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    }
    NSURLSessionTask *sessionTask = [self.httpSessionManager GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        if( downloadProgress ){
            uploadProgressBlock(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        });
        __block id response = responseObject;
        __block id result = nil;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            result = [[response gtm_stringByUnescapingFromURLArgument] objectFromJSONString_Ext];
            result = [response objectFromJSONString_Ext];
            if (task.state != NSURLSessionTaskStateCanceling) {
                
                if (success) {
                    success(result);
                }
            }else{
                if (success) {
                    success(nil);
                }
            }
        });
        
        [self removeUrlSessionTask:task];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        });
        
        if( error.code != -999 ){  //任务被取消,则不弹出警告框
            //            [ZTool showAlertWithMessage:@"连接超时"];
        }
        if( failure )
        {
            failure();
        }
        
        
        [self removeUrlSessionTask:task];
    }];
    sessionTask.taskDescription = urlString;
    [self.urlSessionTasks addObject:sessionTask];
}
//判断网络状态
+ (BOOL )networkReachibility{
    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    NSString *net = @"WIFI";
    if (internetStatus == ReachableViaWiFi) {
        net = @"WIFI";
        return YES;
        
    }else if (internetStatus == ReachableViaWWAN){
        net = @"蜂窝数据";
        
        return YES;
        
    }else if (internetStatus == NotReachable){
        net = @"当前无网路连接";
        
        return NO;
        
    }else{
        
        return NO;
        
    }
    
}
//移除任务队列中的任务task
-(void)removeUrlSessionTask:(NSURLSessionTask *)task{
    if( [self.urlSessionTasks containsObject:task] ){
        [self.urlSessionTasks  removeObject:task];
    }
}
#pragma mark - 取消网络操作
-(void)cancelAFDataTaskWithNames:(NSArray *)names{
    //如果任务队列中无任务，则不进行任何操作
    if( self.urlSessionTasks.count == 0 )  return;
    if( names && names.count ){
        for (int i = 0; i < self.urlSessionTasks.count; i++)
        {
            NSURLSessionTask *task = self.urlSessionTasks[i];
            if( [names containsObject:task.taskDescription] ){
                switch (task.state) {
                    case NSURLSessionTaskStateSuspended:
                    case NSURLSessionTaskStateRunning:
                        [task cancel];
                        [self removeUrlSessionTask:task];
                        i--;
                        break;
                    default:
                        break;
                }
            }
        }
        
    }else{
        [self.httpSessionManager.session invalidateAndCancel];
        [self.urlSessionTasks removeAllObjects];
        self.urlSessionTasks = nil;
    }
}


#pragma mark -带HUD的网络请求 防止请求重复提交

- (void)postApiSessionTaskWithURLString:(NSString *_Nullable)urlString
                            requestBody:(NSDictionary *_Nullable)body
                        timeoutInterval:(NSInteger )timeoutInterval
                    uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                                success:(void(^_Nullable)(NSDictionary * _Nullable result))success
                                failurl:(void(^_Nullable)(void))failure {
    
    //1、判断网络，无网络return。
    if( ![AppNetWorking networkReachibility] )
    {
        if( failure ){
            failure();
        }
        return;
    }
    //2、打开手机上网络请求提示
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    });
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = timeoutInterval;
    
    NSURLSessionTask *sessionTask = [manager POST:urlString parameters:body constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (uploadProgressBlock) {
            uploadProgressBlock( uploadProgress );
        }
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (task.state != NSURLSessionTaskStateCanceling) {
                NSDictionary *result = (NSDictionary *)responseObject;
                if( success ) {
                    success(result);
                }
            }else{
                if( success ) {
                    success(nil);
                }
            }
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
        [self removeUrlSessionTask:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        });
        if (failure) {
            failure();
        }
        [self removeUrlSessionTask:task];
    }];
    sessionTask.taskDescription = urlString;
    [self.urlSessionTasks addObject:sessionTask];
}

- (void)postImageWithImage:(UIImage*_Nullable)image
                 uploadKey:(NSString*_Nullable)uploadKey
                       url:(NSString*_Nullable)url
       uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                   success:(void(^_Nullable)(id  _Nullable responseObject))success
                   failurl:(void(^_Nullable)(NSError * _Nonnull error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/javascript",@"text/json",@"text/plain", nil];;
    
    NSString *dataStr = [self image2DataURL:image];
    
    NSDictionary *parameters = @{[self safeString:uploadKey]: dataStr};
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
- (void)getCarSourceSessionTaskWithURLString:(NSString *_Nullable)urlString
                                  parameters:(NSDictionary *_Nullable)parameters
                         uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                                     success:(void(^_Nullable)(NSDictionary * _Nullable result))success
                                     failurl:(void(^_Nullable)(void))failure{
    //1、判断网络，无网络return。
    if( [AppNetWorking networkReachibility] == NO )
    {
        if( failure )   failure();
        return;
    }
    //2、打开手机上网络请求提示
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
    });
    if ([urlString containsString:@".json"]) {
        self.httpSessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    }
    NSURLSessionTask *sessionTask = [self.httpSessionManager GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        if( downloadProgress ){
            uploadProgressBlock(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        });
        __block id response = responseObject;
        __block id result = nil;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            //            CYXLog(@"返回的数据：%@", response);
            result = [[response gtm_stringByUnescapingFromURLArgument] objectFromJSONString_Ext];
            result = [response objectFromJSONString_Ext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if( task.state != NSURLSessionTaskStateCanceling ){
                    if( success )  {
                        success(result);
                    }
                    
                }else{
                    if( success )  {
                        success(nil);
                    }
                }
            });
            
        });
        
        [self removeUrlSessionTask:task];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        });
        
        
        if( error.code != -999 ){  //任务被取消,则不弹出警告框
            //            [ZTool showAlertWithMessage:@"连接超时"];
        }
        if( failure )
        {
            failure();
        }
        
        
        [self removeUrlSessionTask:task];
    }];
    sessionTask.taskDescription = urlString;
    [self.urlSessionTasks addObject:sessionTask];
}
#pragma mark pravite Methods
- (BOOL) imageHasAlpha: (UIImage *) image
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}
- (NSString *) image2DataURL: (UIImage *) image
{
    if (!image) {
        return @"";
    }
    NSData *imageData = nil;
    NSString *mimeType = nil;
    
    if ([self imageHasAlpha: image]) {
        imageData = UIImagePNGRepresentation(image);
        mimeType = @"image/png";
    } else {
        if ([image isKindOfClass:[UIImage class]]) {
            imageData = UIImageJPEGRepresentation(image, 0.2f);
            mimeType = @"image/jpeg";
        }
        
    }
    
    return [NSString stringWithFormat:@"data:%@;base64,%@", mimeType,
            [imageData base64EncodedStringWithOptions: 0]];
    
}
- (NSString*)safeString:(id)obj{
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@",obj];
    }
    if (!obj || [obj isKindOfClass:[NSNull class]] || ![obj isKindOfClass:[NSString class]]){
        return @"";
    }
    return obj;
}

@end
