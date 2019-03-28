//
//  AppNetWorking.h
//  AppFramework
//
//  Created by bjb on 2019/3/19.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//网络请求超时时间(单位：秒)
#define NETWORK_REQUST_TIME_OUT 15

@class AFNetworking;
@class AFHTTPSessionManager;

//网络状态枚举
typedef NS_ENUM(NSInteger,NetworkReachabilityStatus) {
    NetworkReachabilityStatusUnknown          = -1, //未知
    NetworkReachabilityStatusNotReachable     = 0,  //无网络
    NetworkReachabilityStatusReachableViaWWAN = 1,  //蜂窝网络
    NetworkReachabilityStatusReachableViaWiFi = 2,  //WIFI
};
@interface AppNetWorking : NSObject

/**
 网络超时时间
 */
@property (nonatomic) CGFloat timeoutInterval;
@property (nonatomic,readonly) NetworkReachabilityStatus networkStatus;

@property (nonatomic,strong) NSString *_Nullable netWorkName;


@property (nonatomic, strong) AFHTTPSessionManager * _Nonnull httpSessionManager;

//网络数据请求任务集合
@property (nonatomic, strong) NSMutableArray *urlSessionTasks;

//自定义线程池
@property (nonatomic, strong) NSOperationQueue *operationQueue;

+(instancetype _Nullable ) shareInstance;
/**
 *  网络是否可用
 */
+ (BOOL )networkReachibility;
/*
 取消网络请求
 */
-(void)cancelAFDataTaskWithNames:(NSArray *_Nullable)names;

- (void)postImageWithURLString:(NSString *_Nullable)urlString
                      imageArr:(NSArray*_Nullable)imageArr
                   fileNameArr:(NSArray*_Nullable)fileNameArr
                     uploadKey:(NSString*_Nullable)uploadKey
                   requestBody:(NSDictionary *_Nullable)body
           uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                       success:(void(^_Nullable)(id  _Nullable responseObject))success
                       failurl:(void(^_Nullable)(NSError * _Nonnull error))failure;





- (void)getApiSessionTaskWithURLString:(NSString *_Nullable)urlString
                            parameters:(NSDictionary *_Nullable)parameters
                   uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                               success:(void(^_Nullable)(NSDictionary * _Nullable result))success
                               failurl:(void(^_Nullable)(void))failure;


/**
 
 */
- (void)postApiSessionTaskWithURLString:(NSString *_Nullable)urlString
                            requestBody:(NSDictionary *_Nullable)body
                        timeoutInterval:(NSInteger )timeoutInterval
                    uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                                success:(void(^_Nullable)(NSDictionary * _Nullable result))success
                                failurl:(void(^_Nullable)(void))failure;

/**
 base64加密上传单张图片
 
 @param uploadKey 图片key （id、pic、。。。））
 */
- (void)postImageWithImage:(UIImage*_Nullable)image
                 uploadKey:(NSString*_Nullable)uploadKey
                       url:(NSString*_Nullable)url
       uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                   success:(void(^_Nullable)(id  _Nullable responseObject))success
                   failurl:(void(^_Nullable)(NSError * _Nonnull error))failure;

- (void)getCarSourceSessionTaskWithURLString:(NSString *_Nullable)urlString
                                  parameters:(NSDictionary *_Nullable)parameters
                         uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                                     success:(void(^_Nullable)(NSDictionary * _Nullable result))success
                                     failurl:(void(^_Nullable)(void))failure;
@end

