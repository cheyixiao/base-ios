//
//  Color.h
//  DingDing
//
//  Created by Dry on 2017/9/8.
//  Copyright © 2017年 Dry. All rights reserved.
//

#ifndef Color_h
#define Color_h


//项目常用颜色值
#define RED_COLOR                   [UIColor colorWithHex:@"ff4c4b"]     //红色
#define BACKGROUND_COLOR            [UIColor colorWithHex:@"f4f4f4"]     //背景色
#define LIGHT_GRAY_COLOR            [UIColor colorWithHex:@"c8c7cc"]     //轻灰
#define NOTCLICK_OF_RIGHTITEM       [UIColor colorWithHex:@"999"]        //导航栏按钮置灰颜色
#define WORD_COLOR                  [UIColor colorWithHex:@"666666"]     //一般字体颜色
#define WORD_DRFAULT_COLOR          [UIColor colorWithHex:@"CFCFCF"]     //默认灰色字体
#define WEIGHT_GRAY_COLOR           [UIColor colorWithHex:@"8e8e93"]     //
#define ThemeRedColor               [UIColor colorWithHex:@"D5001C"]     //主题红色
#define hqColor_999999              [UIColor colorWithHex:@"999999"]    
#define HQWhiteColor                [UIColor whiteColor]


//设置颜色快捷方式
#define COLOR(RGB_String)           [UIColor colorWithHex:RGB_String]

//随机颜色
#define kRandomColor  [UIColor colorWithRed:arc4random() % 256 / 255. green:arc4random() % 256 / 255. blue:arc4random() % 256 / 255. alpha:1]
// RGB颜色
#define kCOLOR_RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kCOLOR_RGB(r, g, b) kCOLOR_RGBA(r, g, b, 1.0f)

//16进制颜色
#define RGB(c)    [UIColor colorWithRed:((c>>16)&0xFF)/255.0    \
green:((c>>8)&0xFF)/255.0    \
blue:(c&0xFF)/255.0         \
alpha:1.0]

#endif /* Color_h */
