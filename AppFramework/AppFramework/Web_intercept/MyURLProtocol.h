//
//  MyURLProtocol.h
//  iOSTest
//
//  Created by wangfangshuai on 16/8/8.
//  Copyright © 2016年 wangfangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kImageDownloadNotification  @"kImageDownloadNotification"

@interface MyURLProtocol : NSURLProtocol<NSURLSessionDelegate>

//@property (nonatomic,strong) NSURLConnection    *connection;
@property (atomic,strong,readwrite) NSURLSessionDataTask *task;
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *queue;

//+ (void)start;
@end
