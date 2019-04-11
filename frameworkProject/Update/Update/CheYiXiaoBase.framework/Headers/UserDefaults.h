//
//  UserDefaults.h
//  cheyixiao
//
//  Created by lxt on 2018/11/20.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TOKEN @"token"
#define SALER @"saler"
#define ROLE @"role"
#define CERT_CODE @"cert_code"
#define IS_BIND @"IS_BIND"

#define HISTORYUSER @"historyUsername"
#define BINDPHONE @"bindPhone"
#define FEVERSION @"FeVersion"
#define UUIDFORDEVICE @"uuidForDevice"
#define USERBEHAVIORID @"userBehaviorId"
#define DEVICETOKEN  @"deviceToken"
#define LONGITUDE  @"LONGITUDE"
#define LATITUDE  @"LATITUDE"
#define ISNOTIFY @"ISNOTIFY"
#define NOTIFYCUSTOMER @"NOTIFYCUSTOMER"
#define PROMPTCODE  @"PROMPTCODE"
#define JUMPTABBAR  @"JUMPTABBAR"
#define JUMPWEBVIEW  @"JUMPWEBVIEW"

@interface UserDefaults : NSObject

+ (instancetype)shareInstance;

//用户token标识
@property (nonatomic, copy) NSString *token;

//用户saler
@property (nonatomic, copy) NSString *saler;
//用户角色role
@property (nonatomic, copy) NSString *role;
//cert_code
@property (nonatomic, copy) NSString *cert_code;

@property (nonatomic,copy) NSString *is_bind;

@property (nonatomic, copy) NSArray *historyUsernameArray;

@property (nonatomic, copy) NSString *bindPhone;
///H5链接的版本号
@property (nonatomic,copy) NSString *FeVersion;
///uuidForDevice
@property (nonatomic,copy) NSString *uuidForDevice;
///用户行为记录id
@property (nonatomic,copy) NSString *userBehaviorId;
///友盟的deviceToken
@property (nonatomic,copy) NSString *deviceToken;

///经度
@property (nonatomic,copy) NSString *longitude;
///纬度
@property (nonatomic,copy) NSString *latitude;

///是否从通知去报价
@property (nonatomic,copy) NSString *isNotify;
@property (nonatomic,copy) NSString *notifyCustomer;


///首页提示信息的code码
@property (nonatomic,copy) NSString *promptCode;
///首页tabbar切换
@property (nonatomic,copy) NSString *jumpTabbar;
@property (nonatomic,copy) NSString *jumpWebView;
@property (nonatomic,copy) NSMutableArray  *car_source_show;//车源页面显示逻辑
@property(nonatomic,strong)NSArray  * car_source_pics;


-(void)synchronize;
//- (void)loginOut;
//退出时清理相关缓存信息
- (void)clearLoginInfo;

@end


