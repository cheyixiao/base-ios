//
//  WebCenterManager.h
//  cheyixiao
//
//  Created by bjb on 2019/3/19.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebCenterManager : NSObject


+(instancetype) shareInstance;
@property(nonatomic,assign)NSInteger               sandi;
@property(nonatomic,assign)BOOL                    screenDirection;//YES:横屏 NO:竖屏

/*
 baseUrlArr 拦截资源URL域名
 downLoad   Yes(边拦截边下) No(拦截的时候不需要下载)
 log        Yes:开启打印  No:关闭打印（拦截下载时）
 */
- (void)webCenterManagerBaseUrlArr:(NSArray *)baseUrlArr downLoad:(BOOL )downLoad log:(BOOL )log;
/*
 webview拦截
 */
- (void)registerWeb;
/*
 拦截资源的baseURL
 */
- (void)baseUrl:(NSArray *)baseUrlArr;
/*
 指定文件不备份
 */
- (void)noCloud;
/*
 注册下载监听
*/
- (void)registerNotification;

/*
 取出正在下载的车包
 */
- (void)setDownLoadCacheCar;



/*
 监听网络状态
 */
- (void)listenNetWorkingStatus;

/*
 更新公共车源包
 */
- (void)updateCarCommon;

/*
 将该车源包从下载队列移除 并改变该车的状态
 */
- (void)removeDownLoadCar:(NSString *)carId status:(NSString *)status;

/*
 将该车源包从下载队列移除
 */
- (void)removeDownLoadCar:(NSString *)carId;

/*
 更新该车的下载状态
 */
- (void)setDownLoadStatus:(NSString *)status carId:(NSString *)carId;
@end

NS_ASSUME_NONNULL_END
