//
//  CYXDownLoadModel.m
//  cheyixiao
//
//  Created by bjb on 2018/11/26.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import "CYXDownLoadModel.h"
#include <objc/runtime.h>

@implementation CYXDownLoadModel

#pragma mark ---------------------------归档解档(相关方法)---------------------------
//解档
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        unsigned int count = 0;
        //获取类中所有成员变量名
        Ivar *ivar = class_copyIvarList([self class], &count);
        for (int i = 0; i<count; i++) {
            Ivar iva = ivar[i];
            const char *name = ivar_getName(iva);
            NSString *strName = [NSString stringWithUTF8String:name];
            //进行解档取值
            id value = [decoder decodeObjectForKey:strName];
            //利用KVC对属性赋值
            [self setValue:value forKey:strName];
        }
        free(ivar);
    }
    return self;
}
//归档
- (void)encodeWithCoder:(NSCoder *)encoder
{
    unsigned int count;
    Ivar *ivar = class_copyIvarList([self class], &count);
    for (int i=0; i<count; i++) {
        Ivar iv = ivar[i];
        const char *name = ivar_getName(iv);
        NSString *strName = [NSString stringWithUTF8String:name];
        //利用KVC取值
        id value = [self valueForKey:strName];
        [encoder encodeObject:value forKey:strName];
    }
    free(ivar);
}
+ (NSString *)systemMsgCachePath
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *str = [NSString stringWithFormat:@"%@TabSaveData",path];
    return  str;
}

+ (void)removeSystemMsgCache
{
    NSError *error = nil;
    if( ![[NSFileManager defaultManager] removeItemAtPath:[self systemMsgCachePath] error:&error] )
    {
        
    }
}
-(NSMutableDictionary *)urlDic{
    if (!_urlDic) {
        _urlDic = [NSMutableDictionary dictionary];
    }
    return _urlDic;
}
-(NSMutableDictionary *)carVersion{
    if (!_carVersion) {
        _carVersion = [NSMutableDictionary dictionary];
    }
    return _carVersion;
}
-(NSMutableDictionary *)downLoadCar{
    if (!_downLoadCar) {
        _downLoadCar = [NSMutableDictionary dictionary];
    }
    return _downLoadCar;
}
-(NSMutableDictionary *)downStatus{
    if (!_downStatus) {
        _downStatus = [NSMutableDictionary dictionary];
    }
    return _downStatus;
}
@end
