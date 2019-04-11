//
//  FrameDefine.h
//  DingDing
//
//  Created by Dry on 2017/5/4.
//  Copyright © 2017年 Cstorm. All rights reserved.
//

#ifndef FrameDefine_h
#define FrameDefine_h


//屏幕宽、高
#define kScreenWidth          [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight         [[UIScreen mainScreen] bounds].size.height

//返回指定view的宽和高
#define kOffsetX(view)   view.frame.origin.x
#define kOffsetY(view)   view.frame.origin.y
#define kWidth(view)     CGRectGetWidth(view.frame)
#define kHeight(view)    CGRectGetHeight(view.frame)

//其他屏幕大小相对于6宽度的比率，做屏幕适配
#define kWidthRates  [UIScreen mainScreen].bounds.size.width/375
#define kHeightRates (kScreenHeight == 812.0 || kScreenHeight == 896.0 ?  1: kScreenHeight/667)

//某些适配，大屏上需要登录比例放大，小屏不需要缩小，用该比例实现大屏幕放大，小屏幕不变的效果
#define kBigScreenWidthRate  ((kScreenWidth>320)?kWidthRates:1)
#define kBigScreenHeightRate  ((kScreenWidth>320)?kHeightRates:1)


//导航栏高度+状态栏高度iPhoneX88 其他机型64
#define NavigationHeight (kScreenHeight == 812.0 || kScreenHeight == 896.0 ? 88 : 64)
//如果是iPhoneX 导航栏顶部刘海距离
#define kIPhoneXTopHeight       (kScreenHeight == 812 || kScreenHeight == 896.0 ? 24 : 0)
//底部安全距离
#define kIPhoneXBottomHeight (kScreenHeight == 812.0 || kScreenHeight == 896.0 ? 34 :0)
//比例 以iPhone6 为基准
#define kWRatio kScreenWidth/375
#define kHRatio kScreenHeight/667

//按宽度比例适配,大屏放大，小屏不变
#define kWFit(num)     ((kWRatio<1)?(num):(kWRatio*num))
#define kHFit(num)     ((kHRatio<1)?(num):(kHRatio*num))

#define kIphoneXSeries ((([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0f) && ([[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom > 0.0))? YES : NO)
#define  kIsIphone5  (kScreenWidth ==320)


//按屏幕宽度比例适配,大屏放大，小屏变小
#define kWFit_Ratio(num)     (kWRatio*num)
#define kHFit_Ratio(num)     (kHRatio*num)

///ipad左侧宽度
#define ipadLeftPading 124
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define VTSTATUSBAR_HEIGHT (kIphoneXSeries ? 44 : 20)

#define kIPad_choiceCar_brand_size 104.f
#endif /* FrameDefine_h */
