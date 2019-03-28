//
//  CYXBaseNavigationController.m
//  cheyixiao
//
//  Created by bjb on 2018/11/15.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hidesBottomBarWhenPushed = YES;
}

/**
 重写这个方法的目的是拦截所有push进来的控制器
 
 @param viewController 即将push进来的控制器
 @param animated 是否有动画效果
 */
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    
    if (self.viewControllers.count > 0) {
        // 这是push进来的控制器器不是第一个控制器
        viewController.hidesBottomBarWhenPushed = self.hidesBottomBarWhenPushed; // 自动隐藏tabbar
    }
    [super pushViewController:viewController animated:animated];
}
//- (UIViewController *)childViewControllerForStatusBarStyle
//{
//    return self.topViewController;
//}
- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *topVC = self.topViewController;
    return [topVC preferredStatusBarStyle];
}



//-(void)back{
//
//    [self popViewControllerAnimated:YES];
//
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
