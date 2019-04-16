//
//  CYXWebDownloadModel.m
//  CYXDownload
//
//  Created by wangqichao on 2018/12/8.
//  Copyright © 2018年 wangqichao. All rights reserved.
//

#import "WebDownloadModel.h"
#import "MJExtension.h"
#import "DownloadConst.h"
#import "DownloadManager.h"

static NSInteger fileCount = 0;

@implementation WebDownloadModel

MJCodingImplementation



- (NSString *)destinationPath {
    
    NSString *patientPhotoFolder = [[CYXCachesDirectory stringByAppendingPathComponent:self.folder] stringByAppendingPathComponent:[self.fileName stringByDeletingLastPathComponent]];
//    NSString *patientPhotoFolder = [CYXCachesDirectory stringByAppendingPathComponent:self.folder];

    
    if (![kFileManager fileExistsAtPath:patientPhotoFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:patientPhotoFolder

                                  withIntermediateDirectories:YES

                                                   attributes:nil

                                                        error:nil];
    }
    
    _destinationPath = [patientPhotoFolder stringByAppendingString:[NSString stringWithFormat:@"/%@",[self.fileName lastPathComponent]]];
    NSLog(@"_destinationPath:%@",_destinationPath);
//    _destinationPath = [patientPhotoFolder stringByAppendingString:self.fileFormat];
//    _destinationPath = patientPhotoFolder;
    return _destinationPath;
}


- (NSString *)fileName{
    if (!_fileName) {
        //        NSTimeInterval timeInterval = [[NSDate date]timeIntervalSince1970];
        //        //解决多个任务同时开始时 文件重名问题
        //        NSString *timeStr = [NSString stringWithFormat:@"%.6f",timeInterval];
        //        timeStr = [timeStr stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        //        _fileName = [NSString stringWithFormat:@"%@",timeStr];
//        _fileName = _md5Name;
    }
    return _fileName;
}

- (NSString *)fileFormat{
    if (!_fileFormat && _urlString) {
        NSArray *urlArr = [_urlString componentsSeparatedByString:@"."];
        if (urlArr && urlArr.count>1) {
            self.fileFormat = [@"." stringByAppendingString:[urlArr lastObject]];
        }
    }
    return _fileFormat;
}


- (void)setProgress:(CGFloat)progress{
    if (_progress != progress) {
        _progress = progress;
    }
    
//    if ([kCYXDownloadManager enableProgressLog]) {
//        CYXLog(@"%@%@==%@==%.1f%%",self.fileName,self.fileFormat,self.statusText,progress*100*1.0);
//    }
    
    if (self.progressChanged) {
        self.progressChanged(self);
    }
}


- (void)setStatus:(DownloadStatus)status{
    
    if (_status != status) {
        _status = status;
        [self setStatusTextWith:_status];
        
        if (self.statusChanged) {
            self.statusChanged(self);
        }
    }
}


- (void)setUrlString:(NSString *)urlString{
    _urlString = urlString;
    
    NSArray *urlArr = [_urlString componentsSeparatedByString:@"."];
    if (urlArr && urlArr.count>1) {
        self.fileFormat = [@"." stringByAppendingString:[urlArr lastObject]];
    }
}

- (void)setCompleteTime:(NSString *)completeTime{
    NSDateFormatter *fomatter = [[NSDateFormatter alloc]init];
    _completeTime = [fomatter stringFromDate:[NSDate date]];
}


- (void)setStatusTextWith:(DownloadStatus)status{
    _status = status;
    
    switch (status) {
        case kDownloadStatus_Running:
            self.statusText = @"正在下载";
            break;
        case kDownloadStatus_Suspended:
            self.statusText = @"暂停下载";
            break;
        case kDownloadStatus_Failed:
            self.statusText = @"下载失败";
            break;
        case kDownloadStatus_Cancel:
            self.statusText = @"取消下载";
            break;
        case kDownloadStatus_Waiting:
            self.statusText = @"等待下载";
            break;
        case kDownloadStatus_Completed:
            self.statusText = @"下载完成";
            break;
        default:
            break;
    }
    
    if ([self.statusText isEqualToString:@"下载完成"]) {
        fileCount ++;
        [DownloadManager sharedManager].downLoadCenterManager.downing = NO;
    }
}

+ (NSArray *)mj_ignoredCodingPropertyNames {
    
    return @[@"statusChanged",@"progressChanged",@"stream",@"operation"];
}



- (NSInteger)fileDownloadSize{
    // 获取文件下载长度
    NSInteger fileDownloadSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.destinationPath error:nil][NSFileSize] integerValue];
    _fileDownloadSize = fileDownloadSize;
    return _fileDownloadSize;
}



- (NSOutputStream *)stream{
    if (!_stream) {
        _stream =  [NSOutputStream outputStreamToFileAtPath:self.destinationPath append:YES];
    }
    return _stream;
}

- (BOOL)isFinished{
    
    return (self.fileTotalSize == self.fileDownloadSize) && (self.fileTotalSize != 0);
}

-(void)dealloc{
    
    
}

@end
