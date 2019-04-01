//
//  AppFrameworkTool.m
//  AppFramework
//
//  Created by bjb on 2019/3/20.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import "AppFrameworkTool.h"
#import "UIDevice+CCDevice.h"
#import <CommonCrypto/CommonDigest.h>
#import "BaseDefine.h"
#include <sys/xattr.h>
#import "WebCenterManager.h"

@implementation AppFrameworkTool

+ (void)pushWebViewcontroller:(UIViewController *)controller{
    
    if (controller) {
        UIViewController *vc = [self jsd_getCurrentViewController];
        if ([vc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navi = (UINavigationController *)vc;
            [navi pushViewController:controller animated:YES];
        }else if ([vc isKindOfClass:[UIViewController class]]){
            [vc.navigationController pushViewController:controller animated:YES];
        }
        
    }
}
+ (UIViewController *)jsd_getRootViewController{
    
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"The window is empty");
    return window.rootViewController;
}
+ (UIViewController *)jsd_getCurrentViewController{
    
    UIViewController* currentViewController = [self jsd_getRootViewController];
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            
            currentViewController = currentViewController.presentedViewController;
        } else if ([currentViewController isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController* navigationController = (UINavigationController* )currentViewController;
            currentViewController = [navigationController.childViewControllers lastObject];
            
        } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
            
            UITabBarController* tabBarController = (UITabBarController* )currentViewController;
            currentViewController = tabBarController.selectedViewController;
        } else {
            
            NSUInteger childViewControllerCount = currentViewController.childViewControllers.count;
            if (childViewControllerCount > 0) {
                
                currentViewController = currentViewController.childViewControllers.lastObject;
                
                return currentViewController;
            } else {
                
                return currentViewController;
            }
        }
        
    }
    return currentViewController;
}
+ (void )setUserAgent:(WKWebView *)wkWebView{
    
    if (!wkWebView) {
        wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
    }
    [wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        NSLog(@"userAgent:%@", result);
        [self appendUserAgent:result webView:wkWebView];
    }];
    
}
+(void )appendUserAgent:(NSString *)userAgent webView:(WKWebView *)webView{
    
    if (userAgent) {
        if ([userAgent containsString:@" cheyixiao/"]) {
            //会重复拼接 需要把上一次的删除
            NSRange range = [userAgent rangeOfString:@" cheyixiao/"];
            userAgent     = [userAgent substringToIndex:range.location];
        }
        NSString *customUserAgent = [userAgent stringByAppendingString:[NSString stringWithFormat:@" cheyixiao/%@",[self getAppVersion]]];
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":customUserAgent}];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //        webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    }else{
        [self setUserAgent:webView];
    }
    
}
+ (NSString *)getAppVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDictionary));
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}
+(void)screenDirection:(BOOL)screenDirection{
    
    [WebCenterManager shareInstance].screenDirection = screenDirection;
    if (screenDirection) {
        //调用横屏代码
        [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
    }else{
        //切换到竖屏
        [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    }
    
}
+ (nullable NSString *)md5:(nullable NSString *)str {
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
+ (NSString *)fileFormat:(NSString *)url{
    NSString *fileFormat = @"";
    NSArray *urlArr = [url componentsSeparatedByString:@"."];
    if (urlArr && urlArr.count>1) {
        fileFormat = [@"." stringByAppendingString:[urlArr lastObject]];
    }
    return fileFormat;
}

+ (CGSize)getTextWidthMethod:(NSString *)textString font:(UIFont *)font maxSize:(CGSize)size {
    CGSize textSize = [textString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    return textSize;
}

+ (void)removeLauchCache {
    NSArray *pathsArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[pathsArray objectAtIndex:0] stringByAppendingString:@"/LaunchImages"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}
+(NSString*)safeString:(id)obj{
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@",obj];
    }
    if (!obj || [obj isKindOfClass:[NSNull class]] || ![obj isKindOfClass:[NSString class]]){
        return @"";
    }
    return obj;
}

+(NSArray*)showGifAnimation:(NSString*)name{
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:name withExtension:@"gif"];//加载GIF图片
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);//将GIF图片转换成对应的图片源
    size_t imageCout=CGImageSourceGetCount(gifSource);//获取其中图片源个数，即由多少帧图片组成
    NSMutableArray* images=[[NSMutableArray alloc] init];//定义数组存储拆分出来的图片
    for (int i = 0; i<imageCout; i++) {
        CGImageRef imageRef=CGImageSourceCreateImageAtIndex(gifSource, i, NULL);//从GIF图片中取出源图片
        UIImage* imageName=[UIImage imageWithCGImage:imageRef];//将图片源转换成UIimageView能使用的图片源
        [images addObject:imageName];//将图片加入数组中
        CGImageRelease(imageRef);
    }
    return images;
}
+ (NSArray *)getTopicRangeArray:(NSAttributedString *)attributedString textView:(UITextView *)textView judgeColor:(BOOL )judgeColor regular:(NSString *)regular resultColor:(NSString *)resultColor{
    NSAttributedString *traveAStr = attributedString ?: textView.attributedText;
    __block NSMutableArray *rangeArray = [NSMutableArray array];
    static NSRegularExpression *iExpression;
    iExpression = iExpression ?: [NSRegularExpression regularExpressionWithPattern:regular options:0 error:NULL];
    [iExpression enumerateMatchesInString:traveAStr.string
                                  options:0
                                    range:NSMakeRange(0, traveAStr.string.length)
                               usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                   if (judgeColor) {
                                       NSRange resultRange = result.range;
                                       NSDictionary *attributedDict = [traveAStr attributesAtIndex:resultRange.location effectiveRange:&resultRange];
                                       if ([attributedDict[NSForegroundColorAttributeName] isEqual:resultColor]) {
                                           [rangeArray addObject:NSStringFromRange(result.range)];
                                       }
                                   }else{
                                       [rangeArray addObject:NSStringFromRange(result.range)];
                                   }
                                   
                               }];
    return rangeArray;
}

/**
 * 开始到结束的时间差
 */
+ (NSString *)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime{
    
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *startD =[date dateFromString:startTime];
    NSDate *endD = [date dateFromString:endTime];
    NSTimeInterval start = [startD timeIntervalSince1970]*1;
    NSTimeInterval end = [endD timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    
    NSString *str = [NSString stringWithFormat:@"%f",value];
    
    return str;
}

+ (NSString *)currentTimeTemp{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

+ (NSString *)encodeUrl:(NSString *)url{
    
    //     NSString *url = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *result = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              
                                                              (CFStringRef)url,
                                                              
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              NULL,
                                                              
                                                              kCFStringEncodingUTF8));
    return result;
}

//json字符串格式化
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers error:&err];
    
    if(err) {
        BASELog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}
+(NSDictionary *)dictionaryWithUrlString:(NSString *)urlStr
{
    if (urlStr && urlStr.length && [urlStr rangeOfString:@"?"].length == 1) {
        NSArray *array = [urlStr componentsSeparatedByString:@"?"];
        if (array && array.count == 2) {
            NSString *paramsStr = array[1];
            if (paramsStr.length) {
                NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
                NSArray *paramArray = [paramsStr componentsSeparatedByString:@"&"];
                for (NSString *param in paramArray) {
                    if (param && param.length) {
                        NSArray *parArr = [param componentsSeparatedByString:@"="];
                        if (parArr.count == 2) {
                            [paramsDict setObject:parArr[1] forKey:parArr[0]];
                        }
                    }
                }
                return paramsDict;
            }else{
                return nil;
            }
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}
@end
