//
//  CYXBaseViewController.h
//  cheyixiao
//
//  Created by bjb on 2018/11/15.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import <BaseFramework/BaseViewController.h>

#import "BaseNoNetworkView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CheYiXiaoBaseViewController : BaseViewController

//导航栏右侧按钮
@property (nonatomic, strong) UIButton *rightBarButton;
//导航栏右侧按钮
@property (nonatomic, strong) UIButton *leftBarButton;

//网络请求失败刷新按钮
//@property(nonatomic,strong)UIButton *reloadBtn;

//加载失败view
@property (nonatomic, strong) BaseNoNetworkView *noNetworkView;

//网页url
//@property (nonatomic,copy) NSString *baseWebUrl;

/// 1竖屏、2横屏 ,yes代表横屏
//@property (nonatomic,assign) BOOL isOrientation;

@property (nonatomic,strong) UIButton *goBackBtn;

//导航栏左侧按钮点击事件
- (void)navLeftBtnClick;

//导航栏右侧按钮点击事件
- (void)navRightBtnClick;

//网络请求失败刷新按钮点击事件
- (void)relodBtnClick:(UIButton *)sender;

//隐藏导航栏投影，默认为不隐藏
- (void)hiddenNavShadow:(BOOL)hidden;

- (void)clickReloadButton;
- (void)clickBackButton;
-(void)navSet;


@end

NS_ASSUME_NONNULL_END
