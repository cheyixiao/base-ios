//
//  MyURLProtocol.m
//  iOSTest
//
//  Created by wangfangshuai on 16/8/8.
//  Copyright © 2016年 wangfangshuai. All rights reserved.
//

#import "MyURLProtocol.h"
#import <CommonCrypto/CommonDigest.h>
#import "WebInterceptDownLoadManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AppFrameworkTool.h"

#define LibraryDirectory [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/NoCloud/cars/"]

@implementation MyURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if([NSURLProtocol propertyForKey:@"MyURLProtocolHandledKey" inRequest:request]) {
        return NO;
    }
    return [self checkUrl:request.URL.absoluteString];
}
+ (BOOL)checkUrl:(NSString *)url{
    
    BOOL existPath    = NO;
//    NSString *baseUrl = @"https://cdn.autoforce.net/ixiao/cars";
//    if ([WebDownLoadManager shareInstance].baseUrl && [WebDownLoadManager shareInstance].baseUrl.length) {
//
//        baseUrl = [WebDownLoadManager shareInstance].baseUrl;
//    }
//    if ([url containsString:baseUrl] && ![url containsString:@"mp4"]) {
//
//        existPath           = YES;
//    }
    if (![url containsString:@"mp4"]) {
         existPath           = YES;
    }
    return existPath;

}
+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;

;
}

+(BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    
    return [super requestIsCacheEquivalent:a toRequest:b];
}

-(void)startLoading
{

    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"MyURLProtocolHandledKey" inRequest:newRequest];
   
    NSString *absoluteString        = newRequest.URL.absoluteString;
    for (NSString *baseUrl in [WebInterceptDownLoadManager shareInstance].baseUrlArr) {
        if ([absoluteString containsString:baseUrl]) {
            absoluteString                  = [absoluteString substringFromIndex:baseUrl.length];//截取掉下标baseUrl.length之后的字符串
            break;
        }
    }
    NSString *localPath = [NSString stringWithFormat:@"%@%@/%@",LibraryDirectory,[WebInterceptDownLoadManager shareInstance].folder?:@"webIntercept",[AppFrameworkTool md5:absoluteString]];
    localPath = [localPath stringByAppendingString:[AppFrameworkTool fileFormat:newRequest.URL.lastPathComponent]];
    
    BOOL existPath                  = [[NSFileManager defaultManager]fileExistsAtPath:localPath];
    if (existPath ) {
        NSData *data = [NSData dataWithContentsOfFile:localPath];
        if (data) {
            NSString *type = [self getMimeTypeWithFilePath:localPath];
            [self sendResponseWithData:data mimeType:type];
        }else{
            [self startWithSession:newRequest];
            if ([WebInterceptDownLoadManager shareInstance].downLoad) {
                [[WebInterceptDownLoadManager shareInstance]beginDownloadWithUrl:newRequest.URL.absoluteString];
            }
        }
        
    }else{
        [self startWithSession:newRequest];
        if ([WebInterceptDownLoadManager shareInstance].downLoad) {
            [[WebInterceptDownLoadManager shareInstance]beginDownloadWithUrl:newRequest.URL.absoluteString];
        }
    }
    
}
- (void)sendResponseWithData:(NSData *)data mimeType:(nullable NSString *)mimeType
{
    if (mimeType == nil) {
        mimeType = @"*/*";
    }
    NSMutableDictionary* responseHeaders = [[NSMutableDictionary alloc] init];
    responseHeaders[@"Cache-Control"] = @"no-cache";
    responseHeaders[@"Content-Type"] = mimeType;
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:super.request.URL
                                                          statusCode:200
                                                         HTTPVersion:@"HTTP/1.1"
                                                        headerFields:responseHeaders];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    if (data) {
        [[self client] URLProtocol:self didLoadData:data];
    }
    [[self client] URLProtocolDidFinishLoading:self];
}

- (NSString *)getMimeTypeWithFilePath:(NSString *)filePath{
    CFStringRef pathExtension = (__bridge_retained CFStringRef)[filePath pathExtension];
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    CFRelease(pathExtension);
    
    //The UTI can be converted to a mime type:
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    if (type != NULL)
        CFRelease(type);
    
    return mimeType;
}
- (void)startWithSession:(NSMutableURLRequest *)newRequest{
    
    NSURLSessionConfiguration *configure = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session  = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:self.queue];
    self.task = [self.session dataTaskWithRequest:newRequest];
    [self.task resume];
}
- (void)stopLoading {
    if (_session) {
        [self.session invalidateAndCancel];
        _session = nil;
    }

}
- (NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error != nil) {
        [self.client URLProtocol:self didFailWithError:error];
    }else
    {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
//    CYXLog(@"data:::::::%@",data);
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler
{
    completionHandler(proposedResponse);
}

//TODO: 重定向
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSMutableURLRequest*    redirectRequest;
    redirectRequest = [newRequest mutableCopy];
    [[self class] removePropertyForKey:@"MyURLProtocolHandledKey" inRequest:redirectRequest];
    [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
    
    [self.task cancel];
    [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}
@end
