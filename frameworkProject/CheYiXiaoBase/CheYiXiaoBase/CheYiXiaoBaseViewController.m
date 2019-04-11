//
//  CYXBaseViewController.m
//  cheyixiao
//
//  Created by bjb on 2018/11/15.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import "CheYiXiaoBaseViewController.h"
#import <BaseFramework/UIColor+CCColor.h>
#import "BaseFrameworkHeader.h"
#import "AppFrameworkTool.h"
#import "Color.h"

@interface CheYiXiaoBaseViewController ()<BaseNoNetworkViewDelegate>

@end

@implementation CheYiXiaoBaseViewController

- (BaseNoNetworkView *)noNetworkView
{
    if (!_noNetworkView) {
        _noNetworkView = [[BaseNoNetworkView alloc] initWithFrame:self.view.bounds];
        _noNetworkView.delegate = self;
        [self.view addSubview:_noNetworkView];
        _noNetworkView.hidden = YES;
    }
    return _noNetworkView;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationStatus:self];
    if (IS_IPAD) {
        [self setStatusBarBackgroundColor:[UIColor colorWithHex:@"222222"]];
        
    }
    if (self.baseWebUrl.length &&[AppFrameworkTool whetherRotationWithUrlString:self.baseWebUrl]) {
        [AppFrameworkTool screenDirection:YES];
    }else{
        [AppFrameworkTool screenDirection:NO];
    }
    
    
}
- (void )setNavigationStatus:(UIViewController *)viewController{
    
    if (!IS_IPAD) {
        NSString *classStr  = NSStringFromClass([viewController class]);
        BOOL isSelf = [classStr isEqualToString:@"CarViewController"]
        || [classStr isEqualToString:@"CustomerViewController"]
        || [classStr isEqualToString:@"ForgetCodeViewController"]
        || [classStr isEqualToString:@"ForgetPasswordViewController"]
        || [classStr isEqualToString:@"CustomPriceViewController"]
        || [classStr isEqualToString:@"OpenThirdPageViewController"]
        || [classStr isEqualToString:@"DownLoadListController"]
        || [classStr isEqualToString:@"IphoneBannerAdController"];
        
        [self.navigationController setNavigationBarHidden:!isSelf animated:YES];
    }else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];

    }
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.navigationController.viewControllers.firstObject == self) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }else{
        NSString *classStr  = NSStringFromClass([self class]);

        if ([classStr isEqualToString:@"CarSoureViewController"]
            || [classStr isEqualToString:@"CarFindViewController"]
            || [classStr isEqualToString:@"WebCarController"]
            || [classStr isEqualToString:@"CarOwnViewController"]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }else{
             self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

// 设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUND_COLOR;
    if (self.baseWebUrl.length &&[AppFrameworkTool whetherRotationWithUrlString:self.baseWebUrl]) {
//        [self setBackBtn];
        [AppFrameworkTool screenDirection:YES];
    }else{
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
        [self navSet];
        [AppFrameworkTool screenDirection:NO];
    }
   [self.view addSubview:self.reloadBtn];
    // Do any additional setup after loading the view.
}

#pragma mark 导航栏设置

-(UIButton *)goBackBtn{
    if (!_goBackBtn) {
        NSString *path       = [[NSBundle mainBundle] bundlePath];
        path                 = [path stringByAppendingString:@"/back"];
        UIImage *leftImg = [UIImage imageWithContentsOfFile:path];
        _goBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goBackBtn.frame = CGRectMake(16, 16, 44, 44);
        [_goBackBtn setImage:leftImg forState:UIControlStateNormal];
        [_goBackBtn addTarget:self action:@selector(navLeftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goBackBtn;
}
- (void)navSet {
    //左
    NSString *path       = [[NSBundle mainBundle] bundlePath];
    path                 = [path stringByAppendingString:@"/back"];
    UIImage *leftImg = [UIImage imageWithContentsOfFile:path];
    _leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBarButton.frame = CGRectMake(0, 0, 44, 44);
    [_leftBarButton setImage:leftImg forState:UIControlStateNormal];
    [_leftBarButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_leftBarButton addTarget:self action:@selector(navLeftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:_leftBarButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    //修改导航栏按钮位置
//    if (iOSVersion >= 7.0) {
//        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        item.width = 0;
//
//    }
}


- (void)navLeftBtnClick {
    
    if ( self.navigationController.viewControllers.count <= 2) {
        [AppFrameworkTool screenDirection:NO];
    }
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)navRightBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)relodBtnClick:(UIButton *)sender{
    
}
//隐藏导航栏投影，默认为不隐藏
- (void)hiddenNavShadow:(BOOL)hidden {
    float opacity = 0.2;
    float radius = 4;
    
    if (hidden) {
        opacity = 0.0;
        radius = 0;
    }
    
    //隐藏阴影颜色
    //1.设置阴影颜色
    self.navigationController.navigationBar.layer.shadowColor = [UIColor blackColor].CGColor;
    //2.设置阴影偏移范围
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 0);
    //3.设置阴影颜色的透明度
    self.navigationController.navigationBar.layer.shadowOpacity = opacity;
    //4.设置阴影半径
    self.navigationController.navigationBar.layer.shadowRadius = radius;
    self.navigationController.navigationBar.layer.shadowColor = [UIColor blackColor].CGColor;
}
#pragma mark lazyLoad
//-(UIButton *)reloadBtn{
//    if (!_reloadBtn) {
//        UIImage *reloadImage = [UIImage imageNamed:@"noNetImage"];
//        _reloadBtn           = [UIButton buttonWithType:UIButtonTypeCustom];
//        _reloadBtn.frame     = CGRectMake(kScreenWidth * 0.5 - reloadImage.size.width * 0.5,
//                                          kScreenHeight * 0.5 - reloadImage.size.height * 0.5, reloadImage.size.width,
//                                          reloadImage.size.height);
//        _reloadBtn.hidden   = YES;
//        [_reloadBtn setImage:reloadImage forState:UIControlStateNormal];
//        [_reloadBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//        [_reloadBtn addTarget:self action:@selector(relodBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _reloadBtn;
//}
//- (void)resetRelodBtnFrame:(UIImage *)reloadImage{
//
//    _reloadBtn.frame     = CGRectMake(kScreenWidth * 0.5 - reloadImage.size.width * 0.5,
//                                      kScreenHeight * 0.5 - reloadImage.size.height * 0.5, reloadImage.size.width,
//                                      reloadImage.size.height);
//    [_reloadBtn setImage:reloadImage forState:UIControlStateNormal];
//}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
//    [self setNavigationStatus:viewController];
    
    // 判断要显示的控制器是否是自己
    
}
-(void)dealloc{
//    [self.goBackBtn removeFromSuperview];
}


#pragma mark -- NoNetworkViewDelegate
- (void)clickBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickReloadButton
{
    
}

@end
