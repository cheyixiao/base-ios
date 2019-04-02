//
//  AppFrameworkTool.h
//  AppFramework
//
//  Created by bjb on 2019/3/20.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppFrameworkTool : NSObject

//拦截URL跳转
+ (void)pushWebViewcontroller:(UIViewController *)controller;

//获取当前控制器
+ (UIViewController *)jsd_getRootViewController;
+ (UIViewController *)jsd_getCurrentViewController;

//修改 userAgent
+ (void )setUserAgent:(WKWebView *)wkWebView;

//获取app版本号
+ (NSString *)getAppVersion;

/*
 
 screenDirection    :将要跳转的页面的方向(YES 横屏/ NO 竖屏)
 
 */
+(void)screenDirection:(BOOL)screenDirection;

//字符串生成哈希值
+ (nullable NSString *)md5:(nullable NSString *)str;

//截取字符串格式
+ (NSString *)fileFormat:(NSString *)url;

//获取字符串长度
+ (CGSize)getTextWidthMethod:(NSString *)textString font:(UIFont *)font maxSize:(CGSize)size;

//移除启动页缓存 (LaunchImages方式)
+ (void)removeLauchCache;

//字符串安全处理
+(NSString*)safeString:(id)obj;

//将本地的GIF图转化成图片数组
+(NSArray*)showGifAnimation:(NSString*)name;

/*
 正则表达式筛选出指定字符串的位置
 
 attributedString textView内容
 textView
 judgeColor:      是否要根据颜色筛选
 regular:         正则表达式规则
 resultColor:     要筛选的字符串颜色
 */
+ (NSArray *)getTopicRangeArray:(NSAttributedString *)attributedString textView:(UITextView *)textView judgeColor:(BOOL )judgeColor regular:(NSString *)regular resultColor:(NSString *)resultColor;

/**
 * 开始到结束的时间差
 */
+ (NSString *)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime;

//获取当前的时间戳
+ (NSString *)currentTimeTemp;

//对URL进行编码（含中文等特殊字符串）
+ (NSString *)encodeUrl:(NSString *)url;

//json字符串格式化
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
/*
 指定文件路径下的文件不备份
 
 */
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

+(NSDictionary *)dictionaryWithUrlString:(NSString *)urlStr;

// app版本
+ (NSString *)getBaseUrlVersion;

@end

NS_ASSUME_NONNULL_END
