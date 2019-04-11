//
//  CYXBaseNavigationController.h
//  cheyixiao
//
//  Created by bjb on 2018/11/15.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseNavigationController : UINavigationController

@property(nonatomic,assign)BOOL hidesBottomBarWhenPushed;//跳转次级页面时自动隐藏tabbar(yes隐藏/no不隐藏)默认yes

@end

NS_ASSUME_NONNULL_END
