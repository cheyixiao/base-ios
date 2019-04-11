//
//  CYXBaseModel.m
//  cheyixiao
//
//  Created by bjb on 2018/11/15.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import "CYXBaseModel.h"
#import "UserDefaults.h"
#import "BaseFrameworkHeader.h"
#import "AppFrameworkTool.h"
#import "MJExtension.h"

@implementation CYXBaseModel

- (NSString *)changeUrlStrWith:(NSString *)url
{
    url = [url stringByAppendingString:[NSString stringWithFormat:@"&Cyx_token=%@&Cyx_saler=%@&Cyx_ref=1", [UserDefaults shareInstance].token, [UserDefaults shareInstance].saler]];
    return url;
}

- (NSString *)stringByAppendingWith: (NSString *)url withDictionary:(NSMutableDictionary *)dictionary
{
    //keyArray
    NSMutableArray *KeyArray = [NSMutableArray array];
    //valuesArray
    NSMutableArray *valueArray = [NSMutableArray array];
    if (dictionary) {
        for (NSString *str in [dictionary allKeys]) {
            NSString *value = [dictionary objectForKey:str];
            if ([value isKindOfClass:[NSNumber class]]) {
                [KeyArray addObject:str];
                [valueArray addObject:[dictionary objectForKey:str]];
            }else if (value.length > 0) {
                [KeyArray addObject:str];
                [valueArray addObject:[dictionary objectForKey:str]];
            }
        }
    }
    
    NSString *paramStr = @"?";
    for (int i = 0; i < KeyArray.count; i++) {
        paramStr = [paramStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", KeyArray[i], valueArray[i]]];
    }
//  Cyx_ref=1 代表是手机，=0代表是pad
    NSString * Cyx_ref;
    if (IS_IPAD) {
        Cyx_ref =@"0";
    }else{
        Cyx_ref =@"1";
    }
    paramStr = [paramStr stringByAppendingString:[NSString stringWithFormat:@"Cyx_token=%@&Cyx_saler=%@&Cyx_ref=%@&origin_version=%@&decid=%@", [UserDefaults shareInstance].token, [UserDefaults shareInstance].saler,Cyx_ref, [AppFrameworkTool getBaseUrlVersion],[UserDefaults shareInstance].uuidForDevice]];
    
    url = [url stringByAppendingString:paramStr];
    
    return url;
}

+(NSString *)stringByAppendingWith: (NSString *)url withDictionary:(NSMutableDictionary *)dictionary
{
    //keyArray
    NSMutableArray *KeyArray = [NSMutableArray array];
    //valuesArray
    NSMutableArray *valueArray = [NSMutableArray array];
    if (dictionary) {
        for (NSString *str in [dictionary allKeys]) {
            NSString *value = [dictionary objectForKey:str];
            if ([value isKindOfClass:[NSNumber class]]) {
                [KeyArray addObject:str];
                [valueArray addObject:[dictionary objectForKey:str]];
            }else if (value.length > 0) {
                [KeyArray addObject:str];
                [valueArray addObject:[dictionary objectForKey:str]];
            }
        }
    }
    
    NSString *paramStr = @"?";
    for (int i = 0; i < KeyArray.count; i++) {
        paramStr = [paramStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", KeyArray[i], valueArray[i]]];
    }
    //  Cyx_ref=1 代表是手机，=0代表是pad
    NSString * Cyx_ref;
    if (IS_IPAD) {
        Cyx_ref =@"0";
    }else{
        Cyx_ref =@"1";
    }
    paramStr = [paramStr stringByAppendingString:[NSString stringWithFormat:@"Cyx_token=%@&Cyx_saler=%@&Cyx_ref=%@&origin_version=%@&decid=%@", [UserDefaults shareInstance].token, [UserDefaults shareInstance].saler,Cyx_ref, [AppFrameworkTool getBaseUrlVersion],[UserDefaults shareInstance].uuidForDevice]];
    
    url = [url stringByAppendingString:paramStr];
    
    return url;
}


@end
