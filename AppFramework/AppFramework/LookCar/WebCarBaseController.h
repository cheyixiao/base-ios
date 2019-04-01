//
//  WebCarController.h
//  cheyixiao
//
//  Created by bjb on 2018/12/20.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import "BaseViewController.h"
#import "WebViewManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebCarBaseController : BaseViewController<WebViewManagerDelegate,WKScriptMessageHandler>

@property(nonatomic,strong)NSString  *carId;
@property(nonatomic,strong)NSString  *brand;
@property(nonatomic,strong)NSString  *carName;
@property(nonatomic,strong)NSString  *sandi;
@property(nonatomic,strong)NSString  *quanjing;
@property(nonatomic,assign)NSInteger  type; //1、3、4全景、3D看车  2图片看车
@property(nonatomic,assign)BOOL sameDirection;
@property(nonatomic,assign)BOOL isDowning; //yes是正在下载自己 不显示排队中或者已更新
@property(nonatomic,strong)UITapGestureRecognizer  *tap;
@property(nonatomic,strong)NSString  *down;
@property (nonatomic,strong) UIButton *goBackBtn;
@property (nonatomic,strong) WebViewManager *webViewManager;

- (void)loadCarJson:(BOOL )update;

- (void)loadCarCommon;

- (void)addDownLoadCar:(NSString *)carId;

- (void)unRegisterWeb;

-(void)navLeftBtnClick;
@end

NS_ASSUME_NONNULL_END
