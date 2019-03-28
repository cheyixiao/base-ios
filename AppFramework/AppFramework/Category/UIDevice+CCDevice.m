//
//  UIDevice+CCDevice.m
//  WeexDemo
//
//  Created by bjb on 2018/4/24.
//  Copyright © 2018年 taobao. All rights reserved.
//

#import "UIDevice+CCDevice.h"

@implementation UIDevice (CCDevice)

+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
    
    NSNumber *orientationTarget = [NSNumber numberWithInt:interfaceOrientation];
    
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
}



@end
