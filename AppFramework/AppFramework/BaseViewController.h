//
//  CYXBaseViewController.h
//  cheyixiao
//
//  Created by bjb on 2018/11/15.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController




//网页url
@property (nonatomic,copy)   NSString *baseWebUrl;

/// no竖屏、yes横屏
@property (nonatomic,assign) BOOL      isOrientation;

// no可以滑动返回 yes禁止滑动返回
@property(nonatomic,assign)  BOOL      swipNoBack;

@property(nonatomic,assign)  BOOL      hideNavigationBar;
//网络请求失败刷新按钮
@property(nonatomic,strong)UIButton *reloadBtn;

//重设reloadBtn frame
- (void)resetRelodBtnFrame:(UIImage *)reloadImage;

@end

NS_ASSUME_NONNULL_END
