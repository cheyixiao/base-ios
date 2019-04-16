//
//  WebRequestManager.m
//  AppFramework
//
//  Created by bjb on 2019/4/1.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import "WebRequestManager.h"
#import <DownLoad/DownLoadCenterManager.h>
#import <CheYiXiaoBase/AppFrameworkTool.h>
#import <DownLoad/DownloadConst.h>
#import <Networking/AppNetWorking.h>
#import <DownLoad/WebDownloadModel.h>
#import <BaseFramework/NSData+Extension.h>
#import "WebCenterManager.h"
#import "DownLoadCacheModel.h"
#import <WebIntercept/WebInterceptDownLoadManager.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


@implementation WebRequestManager

static WebRequestManager* instance = nil;

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
    return [WebRequestManager shareInstance] ;
}
-(id) copyWithZone:(struct _NSZone *)zone
{
    return [WebRequestManager shareInstance] ;
}
- (void)loadData:(NSString *)carId update:(BOOL )update uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
         success:(void(^_Nullable)(NSArray * _Nullable result , NSInteger update,NSInteger finishedCount))success
         failurl:(void(^_Nullable)(void))failure{
    
    if ([DownLoadCenterManager shareInstance].loadCarJson == YES ) {
        return;
    }
    [DownLoadCenterManager shareInstance].loadCarJson = YES;
    [DownLoadCenterManager shareInstance].check       = YES;
    
    NSString *url = @"";
    if (IS_IPAD) {
        url = [NSString stringWithFormat:@"%@/%@/36-ensure.json.manifest",[WebCenterManager shareInstance].requestBaseUrl,carId];
    }else{
        url = [NSString stringWithFormat:@"%@/%@/18-ensure.json.manifest",[WebCenterManager shareInstance].requestBaseUrl,carId];
    }
    [[AppNetWorking shareInstance]getCarSourceSessionTaskWithURLString:url parameters:@{} uploadProgressBlock:^(NSProgress * _Nullable uploadProgress) {
        
    } success:^(NSDictionary * _Nullable result) {
        if (result) {
            
            dispatch_async(dispatch_get_global_queue(0, 0),^{
                
                NSDictionary *dic       = @{};
                NSArray *arr                = (NSArray *)result;
                [self addWebInterceptHash:arr carId:carId];
                NSString *basePath = [NSString stringWithFormat:@"%@/%@",CYXCachesDirectory,carId];
                if (![[NSFileManager defaultManager]fileExistsAtPath:basePath]) {
                    
                    dic = [self addDownLoadModel:arr carId:carId];
                }else{
                    
                    dic = [self updateDownLoadModel:arr carId:carId update:update];
                }
                NSArray *downLoadArr           = dic[@"arr"];
                NSInteger update               = [dic[@"update"] integerValue];
                NSInteger finishedCount        = [dic[@"count"] integerValue];
                if ([DownLoadCenterManager shareInstance].check == YES) {
                    if (success) {
                        success(downLoadArr,update,finishedCount);
                    }
                }
                [DownLoadCenterManager shareInstance].check = NO;
                [DownLoadCenterManager shareInstance].loadCarJson = NO;
                
            });
            
        }else{
            [DownLoadCenterManager shareInstance].check = NO;
            [DownLoadCenterManager shareInstance].loadCarJson = NO;
            if (failure) {
                failure();
            }
        }
    } failurl:^{
        [DownLoadCenterManager shareInstance].loadCarJson = NO;
        [DownLoadCenterManager shareInstance].check = NO;
        
        if (failure) {
            failure();
        }
    }];
}
- (void)addWebInterceptHash:(NSArray *)result carId:(NSString *)carId{
    
     for (NSDictionary *dic in result) {
         
         NSString * url      = [NSString stringWithFormat:@"https://cdn.autoforce.net/ixiao/cars/%@/%@",carId,[AppFrameworkTool safeString:dic[@"file"]]];
         NSString * fileHash        = [AppFrameworkTool safeString:dic[@"hash"]];
         [[WebInterceptDownLoadManager shareInstance].downLoadHashDic setObject:fileHash forKey:url];
     }
    

}
- (NSDictionary *)addDownLoadModel:(NSArray *)result carId:(NSString *)carId{
    
    NSMutableArray *downLoadArr = [NSMutableArray array];
    
    for (NSDictionary *dic in result) {
        
//        NSString * fileName = [self fileName:dic carId:carId];
        NSString * fileName = [AppFrameworkTool safeString:dic[@"file"]];

        NSString * url      = [NSString stringWithFormat:@"https://cdn.autoforce.net/ixiao/cars/%@/%@",carId,[AppFrameworkTool safeString:dic[@"file"]]];
        url      =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString * fileHash        = [AppFrameworkTool safeString:dic[@"hash"]];
        WebDownloadModel *model    = [[WebDownloadModel alloc] init];
        model.urlString            = url;
        model.md5Name              = fileHash;
        model.fileName             = fileName;
        model.jsonFileName         = [AppFrameworkTool safeString:dic[@"file"]];
        model.folder                = carId;
        [downLoadArr addObject:model];
    }
    NSDictionary *attributes = @{@"arr":downLoadArr,@"update":@"1",@"count":@"0"};
    return attributes;
}
- (NSDictionary *)updateDownLoadModel:(NSArray *)result carId:(NSString *)carId update:(BOOL )up{
    
    NSMutableArray *downLoadArr = [NSMutableArray array];
    NSInteger update            = doneDownLoad;
    NSMutableArray *finishedArr = [NSMutableArray array];
    
    for (NSDictionary *dic in result) {
        
        if ([DownLoadCenterManager shareInstance].check == NO) {
            break;
        }
//        NSString * fileName = [self fileName:dic carId:carId];
        NSString * fileName = [AppFrameworkTool safeString:dic[@"file"]];
        NSString * url      = [NSString stringWithFormat:@"https://cdn.autoforce.net/ixiao/cars/%@/%@",carId,[AppFrameworkTool safeString:dic[@"file"]]];
        url      =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString * fileHash = [AppFrameworkTool safeString:dic[@"hash"]];
        if ([self isUrlAddress:url] && ![[DownLoadCenterManager shareInstance].downLoadFailUrls containsObject:url] ) {
            //有效的url
            NSString *downLoadPath = [NSString stringWithFormat:@"%@/%@/%@",CYXCachesDirectory,carId,fileName];
            
            BOOL exsit =  [[NSFileManager defaultManager]fileExistsAtPath:downLoadPath];
            if (exsit) {
                //下载过
                NSData *downLoadData = [NSData dataWithContentsOfFile:downLoadPath];
                if (downLoadData) {
                    NSString *downLoadMD5 = downLoadData.getMD5Data;
                    if (![downLoadMD5 isEqualToString:fileHash]) {
                        //有更新
                        WebDownloadModel *model    = [[WebDownloadModel alloc] init];
                        model.urlString            = url;
                        model.md5Name              = fileHash;
                        model.fileName             = fileName;
                         model.jsonFileName         = [AppFrameworkTool safeString:dic[@"file"]];
                        model.folder               = carId;
                        [downLoadArr addObject:model];
                    }else{
                        [finishedArr addObject:dic];
                    }
                }else{
                    //排队中
                    update                     = queueDownLoad;
                    //有更新
                    WebDownloadModel *model    = [[WebDownloadModel alloc] init];
                    model.urlString            = url;
                    model.md5Name              = fileHash;
                    model.fileName             = fileName;
                     model.jsonFileName         = [AppFrameworkTool safeString:dic[@"file"]];
                    model.folder               = carId;
                    [downLoadArr addObject:model];
                }
                
            }else{
                //排队中
                update                      = queueDownLoad;
                WebDownloadModel *model     = [[WebDownloadModel alloc] init];
                model.urlString            = url;
                model.md5Name              = fileHash;
                model.fileName             = fileName;
                model.jsonFileName         = [AppFrameworkTool safeString:dic[@"file"]];
                model.folder               = carId;
                [downLoadArr addObject:model];
                
            }
            
        }
    }
    NSDictionary *attributes = @{@"arr":downLoadArr,@"update":[NSString stringWithFormat:@"%ld",(long)update],@"count":[NSString stringWithFormat:@"%ld",(long)finishedArr.count]};
    return attributes;
}
//用hash做文件名
- (NSString *)fileName:(NSDictionary *)dic carId:(NSString *)carId{
    
    NSString * fileName = [AppFrameworkTool safeString:dic[@"file"]];
    fileName            = [NSString stringWithFormat:@"/ixiao/cars/%@/%@",carId,fileName];
    fileName            = [AppFrameworkTool md5:fileName];
    fileName            = [fileName stringByAppendingString:[AppFrameworkTool fileFormat:[AppFrameworkTool safeString:dic[@"file"]]]];
    return fileName;
    
}
- (void)loadCarVersion:(NSString *)carId uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
               success:(void(^_Nullable)(NSString *version))success
               failurl:(void(^_Nullable)(void))failure{
    
    NSString *url = @"";
    if (IS_IPAD) {
        url = [NSString stringWithFormat:@"%@/%@/36-ensure.json",[WebCenterManager shareInstance].requestBaseUrl,carId];
    }else{
        url = [NSString stringWithFormat:@"%@/%@/18-ensure.json",[WebCenterManager shareInstance].requestBaseUrl,carId];
    }
    [[AppNetWorking shareInstance]getCarSourceSessionTaskWithURLString:url parameters:@{} uploadProgressBlock:^(NSProgress * _Nullable uploadProgress) {
        
    } success:^(NSDictionary * _Nullable result) {
        if (result) {
            NSLog(@"result:%@",result);
            NSString *version                 = [AppFrameworkTool safeString:result[@"release"]];
            DownLoadCacheModel *downLoadModel = [NSKeyedUnarchiver unarchiveObjectWithFile:[DownLoadCacheModel systemMsgCachePath]];
            if (!downLoadModel) {
                downLoadModel = [[DownLoadCacheModel alloc] init];
            }
            [downLoadModel.tempVersions setObject:version forKey:carId];
            dispatch_async(dispatch_get_global_queue(0, 0),^{
                [NSKeyedArchiver archiveRootObject:downLoadModel toFile:[DownLoadCacheModel systemMsgCachePath]];
            });
            if (success) {
                success(version);
            }
        }else{
            if (failure) {
                failure();
            }
        }
    } failurl:^{
        if (failure) {
            failure();
        }
    }];
}

//是否是有效URL
- (BOOL)isUrlAddress:(NSString*)url{
    
    NSString*reg =@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSPredicate*urlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];
    return[urlPredicate evaluateWithObject:url];
    
}

@end
