//
//  UpdateModel.m
//  MccPro
//
//  Created by lxt on 2018/12/18.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import "UpdateModel.h"
#import "MJExtension.h"

@implementation UpdateModel

-(id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property{
    if([property.name isEqualToString:@"update_content"]){
        return [NSString mj_objectArrayWithKeyValuesArray:oldValue];
    }
    return oldValue;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"isRegister" : @"register",//前边的是你想用的key，后边的是返回的key
             };
}

@end
