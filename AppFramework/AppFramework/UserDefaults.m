//
//  UserDefaults.m
//  cheyixiao
//
//  Created by lxt on 2018/11/20.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import "UserDefaults.h"
#import "BaseDefine.h"

@implementation UserDefaults

+ (instancetype)shareInstance
{
    static UserDefaults *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (instancetype) allocWithZone:(struct _NSZone *)zone
{
    return [UserDefaults shareInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [UserDefaults shareInstance];
}

- (void)setToken:(NSString *)token
{
    if(token != nil){
        [[NSUserDefaults standardUserDefaults]setObject:token forKey:TOKEN];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:TOKEN];
        BASELog(@"token is nil");
    }
}

- (NSString *)token
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:TOKEN];
}

- (void)setSaler:(NSString *)saler
{
    if(saler != nil){
        [[NSUserDefaults standardUserDefaults]setObject:saler forKey:SALER];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SALER];
        BASELog(@"saler is nil");
    }
}
- (NSString *)saler
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SALER];
}

- (void)setRole:(NSString *)role {
    
    if(role != nil){
        [[NSUserDefaults standardUserDefaults]setObject:role forKey:ROLE];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ROLE];
        BASELog(@"role is nil");
    }
}
- (NSString *)role
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:ROLE];
}

- (void)setCert_code:(NSString *)cert_code {
    if(cert_code != nil){
        [[NSUserDefaults standardUserDefaults]setObject:cert_code forKey:CERT_CODE];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:CERT_CODE];
        BASELog(@"cert_code is nil");
    }
}
- (NSString *)cert_code
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:CERT_CODE];
}

- (void)setHistoryUsernameArray:(NSArray *)historyUsernameArray
{
    if (historyUsernameArray.count > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:historyUsernameArray forKey:HISTORYUSER];
    }
}
- (NSArray *)historyUsernameArray
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:HISTORYUSER];
}

- (void)setBindPhone:(NSString *)bindPhone {
    if(bindPhone != nil){
        [[NSUserDefaults standardUserDefaults]setObject:bindPhone forKey:BINDPHONE];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:BINDPHONE];
        BASELog(@"bindPhone is nil");
    }
}

- (NSString *)bindPhone {
    return [[NSUserDefaults standardUserDefaults] objectForKey:BINDPHONE];
}

- (void)setFeVersion:(NSString *)FeVersion
{
    if (FeVersion != nil) {
      [[NSUserDefaults standardUserDefaults]setObject:FeVersion forKey:FEVERSION];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:FEVERSION];
        BASELog(@"FeVersion is nil");
    }
}

-(NSString *)FeVersion
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:FEVERSION];
}

- (void)setUuidForDevice:(NSString *)uuidForDevice
{
    if (uuidForDevice != nil) {
        [[NSUserDefaults standardUserDefaults]setObject:uuidForDevice forKey:UUIDFORDEVICE];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:UUIDFORDEVICE];
        BASELog(@"uuidForDevice is nil");
    }
}

-(NSString *)uuidForDevice
{
   return [[NSUserDefaults standardUserDefaults] objectForKey:UUIDFORDEVICE];
}

-(void)setUserBehaviorId:(NSString *)userBehaviorId
{
    if (userBehaviorId != nil) {
        [[NSUserDefaults standardUserDefaults]setObject:userBehaviorId forKey:USERBEHAVIORID];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERBEHAVIORID];
        BASELog(@"userBehaviorId is nil");
    }
}

-(NSString *)userBehaviorId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USERBEHAVIORID];
}

- (void)setDeviceToken:(NSString *)deviceToken
{
    if (deviceToken != nil) {
        [[NSUserDefaults standardUserDefaults]setObject:deviceToken forKey:DEVICETOKEN];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DEVICETOKEN];
        BASELog(@"deviceToken is nil");
    }
}

-(NSString *)deviceToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:DEVICETOKEN];
}

- (void)setIs_bind:(NSString *)is_bind
{
    if (is_bind != nil) {
       [[NSUserDefaults standardUserDefaults]setObject:is_bind forKey:IS_BIND];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:IS_BIND];
        BASELog(@"is_bind is nil");
    }
}

-(NSString *)is_bind
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:IS_BIND];
}

- (void)setLatitude:(NSString *)latitude{
    if (latitude != nil) {
        [[NSUserDefaults standardUserDefaults]setObject:latitude forKey:LATITUDE];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:LATITUDE];
        BASELog(@"latitude is nil");
    }
}

-(NSString *)latitude
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:LATITUDE];
}


- (void)setLongitude:(NSString *)longitude
{
    if (longitude != nil) {
        [[NSUserDefaults standardUserDefaults]setObject:longitude forKey:LONGITUDE];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:LONGITUDE];
        BASELog(@"longitude is nil");
    }
}

-(NSString *)longitude
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:LONGITUDE];
}

- (void)setIsNotify:(NSString *)isNotify
{
    if (isNotify != nil) {
        [[NSUserDefaults standardUserDefaults]setObject:isNotify forKey:ISNOTIFY];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ISNOTIFY];
        BASELog(@"isNotify is nil");
    }
}

-(NSString *)isNotify
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:ISNOTIFY];
}
- (void)setNotifyCustomer:(NSString *)notifyCustomer{
    if (notifyCustomer != nil) {
        [[NSUserDefaults standardUserDefaults]setObject:notifyCustomer forKey:NOTIFYCUSTOMER];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:NOTIFYCUSTOMER];
    }
}
- (NSString *)notifyCustomer{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NOTIFYCUSTOMER];
}
- (void)setPromptCode:(NSString *)promptCode
{
    if (promptCode != nil) {
        [[NSUserDefaults standardUserDefaults]setObject:promptCode forKey:PROMPTCODE];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PROMPTCODE];
        BASELog(@"promptCode is nil");
    }
}

-(NSString *)promptCode
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PROMPTCODE];
}

-(void)setJumpTabbar:(NSString *)jumpTabbar
{
    if (jumpTabbar != nil) {
        [[NSUserDefaults standardUserDefaults]setObject:jumpTabbar forKey:JUMPTABBAR];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:JUMPTABBAR];
        BASELog(@"jumpTabbar is nil");
    }
}

-(NSString *)jumpTabbar
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:JUMPTABBAR];
}

-(void)setJumpWebView:(NSString *)jumpWebView
{
    if (jumpWebView != nil) {
        [[NSUserDefaults standardUserDefaults]setObject:jumpWebView forKey:JUMPWEBVIEW];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:JUMPWEBVIEW];
        BASELog(@"jumpWebView is nil");
    }
}

-(NSString *)jumpWebView
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:JUMPWEBVIEW];
}




-(void)synchronize
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)clearLoginInfo {
    [UserDefaults shareInstance].token = nil;
    [UserDefaults shareInstance].saler = nil;
    [UserDefaults shareInstance].role = nil;
    [UserDefaults shareInstance].cert_code = nil;
    [UserDefaults shareInstance].is_bind = nil;
    //清除用户线索
    [UserDefaults shareInstance].userBehaviorId = nil;
}
-(NSMutableArray *)car_source_show{
    if (!_car_source_show) {
        _car_source_show = [NSMutableArray array];
    }
    return _car_source_show;
}
@end
