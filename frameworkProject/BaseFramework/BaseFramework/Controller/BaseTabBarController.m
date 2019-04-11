//
//  CYXBaseTabBarController.m
//  cheyixiao
//
//  Created by bjb on 2018/11/15.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import "BaseTabBarController.h"
#import "BaseNavigationController.h"
#import "BaseViewController.h"

#define kIPhoneXBottomHeight ([UIScreen mainScreen].bounds.size.height == 812.0 || [UIScreen mainScreen].bounds.size.height == 896.0 ? 34 :0)


@interface BaseTabBarController ()<UITabBarControllerDelegate>

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //iOS 12.1更新 tabbar 从二级页面切回来出现跳动问题
    [[UITabBar appearance] setTranslucent:NO];
    
    //bug fix：去掉tabBar顶部线条；原理：其实并没有删除横线（remove掉），只是把它变成透明的不影响操作和界面美观而已（视觉错）
    CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.tabBar setBackgroundImage:img];
    [self.tabBar setShadowImage:img];
    
    
    
    //修改tabbar，title和icon的间距
    [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -5)];
    
    self.delegate = self;
}

- (void)defaultSetWithTitleArr:(NSArray *)titleArr imageArr:(NSArray *)imageArr selectedImageArr:(NSArray *)selectedImageArr{
    
    for (int i = 0; i < titleArr.count; i ++) {
        UIImage *image = imageArr[i];
        UIImage *selectedImage = selectedImageArr[i];
        BaseViewController *controller = [[BaseViewController alloc] init];
        [self addViewController:controller title:titleArr[i] image:image selectedImage:selectedImage];
    }
}
// 添加某个 childViewController
-(void)addViewController:(UIViewController *)childController title:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage{
    
    
    childController.title = title;
    
    childController.tabBarItem.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childController.tabBarItem.selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 先把外面传进来的控制器包装成一个导航控制器
    BaseNavigationController *mainNav = [[BaseNavigationController alloc ]initWithRootViewController:childController];
    // 添加子控制器
    [self addChildViewController:mainNav];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGRect tabFrame = self.tabBar.frame;
    tabFrame.size.height = 49 + kIPhoneXBottomHeight ;
    tabFrame.origin.y = self.view.frame.size.height - 49 - kIPhoneXBottomHeight;
    self.tabBar.frame = tabFrame;
}

@end
