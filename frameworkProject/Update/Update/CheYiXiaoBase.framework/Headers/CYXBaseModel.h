//
//  CYXBaseModel.h
//  cheyixiao
//
//  Created by bjb on 2018/11/15.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^successBlock)(id success);
typedef void (^failBlock)(id error);

@interface CYXBaseModel : NSObject

@property (nonatomic, copy) successBlock successBlock;

@property (nonatomic, copy) failBlock failBlock;

//500 服务器异常 302异地登录 403还没有登录 303认证被驳回 306停用
@property (nonatomic, assign) NSInteger code;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, copy) NSString *msg;

- (NSString *)changeUrlStrWith:(NSString *)url;

- (NSString *)stringByAppendingWith: (NSString *)url withDictionary:(NSMutableDictionary *)dictionary;

+(NSString *)stringByAppendingWith: (NSString *)url withDictionary:(NSMutableDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
