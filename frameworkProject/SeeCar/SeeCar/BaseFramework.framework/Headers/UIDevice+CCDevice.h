//
//  UIDevice+CCDevice.h
//  WeexDemo
//
//  Created by bjb on 2018/4/24.
//  Copyright © 2018年 taobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (CCDevice)

/**
 * @interfaceOrientation 输入要强制转屏的方向
 */
+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
