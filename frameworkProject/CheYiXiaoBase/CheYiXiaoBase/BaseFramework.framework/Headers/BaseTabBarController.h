//
//  CYXBaseTabBarController.h
//  cheyixiao
//
//  Created by bjb on 2018/11/15.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseTabBarController : UITabBarController

/*
 默认设置
 
 */
- (void)defaultSetWithTitleArr:(NSArray *)titleArr imageArr:(NSArray *)imageArr selectedImageArr:(NSArray *)selectedImageArr;


@end

NS_ASSUME_NONNULL_END
