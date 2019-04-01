//
//  CYXBaseViewController.m
//  cheyixiao
//
//  Created by bjb on 2018/11/15.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import "BaseViewController.h"
#import "AppFrameworkTool.h"
#import "FrameDefine.h"

@interface BaseViewController ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation BaseViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:self.hideNavigationBar animated:animated];

     [AppFrameworkTool screenDirection:self.isOrientation];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.swipNoBack) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;

}
- (void)resetRelodBtnFrame:(UIImage *)reloadImage{
    
    self.reloadBtn.frame     = CGRectMake(kScreenWidth * 0.5 - reloadImage.size.width * 0.5,
                                      kScreenHeight * 0.5 - reloadImage.size.height * 0.5, reloadImage.size.width,
                                      reloadImage.size.height);
    [self.reloadBtn setImage:reloadImage forState:UIControlStateNormal];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    //    [self setNavigationStatus:viewController];
    
    // 判断要显示的控制器是否是自己
    
    
}
-(void )relodBtnClick:(UIButton *)sender{
    
}
#pragma mark lazyLoad
-(UIButton *)reloadBtn{
    if (!_reloadBtn) {
        NSString *path       = [[NSBundle mainBundle] bundlePath];
        path                 = [path stringByAppendingString:@"/noNetImage"];
        UIImage *reloadImage = [UIImage imageWithContentsOfFile:path];
        _reloadBtn           = [UIButton buttonWithType:UIButtonTypeCustom];
        _reloadBtn.frame     = CGRectMake(kScreenWidth * 0.5 - reloadImage.size.width * 0.5,
                                          kScreenHeight * 0.5 - reloadImage.size.height * 0.5, reloadImage.size.width,
                                          reloadImage.size.height);
        _reloadBtn.hidden   = YES;
        [_reloadBtn setImage:reloadImage forState:UIControlStateNormal];
        [_reloadBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_reloadBtn addTarget:self action:@selector(relodBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reloadBtn;
}
@end
