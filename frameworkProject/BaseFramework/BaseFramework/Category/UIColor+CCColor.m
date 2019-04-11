//
//  UIColor+DDColor.m
//  DingDing
//
//  Created by Dry on 2017/8/2.
//  Copyright © 2017年 Cstorm. All rights reserved.
//

#import "UIColor+CCColor.h"

const NSInteger MAX_RGB_COLOR_VALUE = 0xff;
const NSInteger MAX_RGB_COLOR_VALUE_FLOAT = 255.0f;

@implementation UIColor (CCColor)

/**
 * @brief 字符串中得到颜色值
 *
 * @param stringToConvert 字符串的值 e.g:@"#FF4500"
 *
 * @return 返回颜色对象
 */
+ (UIColor *)colorFromString_Ext:(NSString *)stringToConvert {
    
    return [self colorWithHex:stringToConvert];
}



+ (UIColor *)colorWithRGBA_Ext:(uint) hex {
    return [UIColor colorWithRed:(CGFloat)((hex>>24) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                           green:(CGFloat)((hex>>16) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                            blue:(CGFloat)((hex>>8) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                           alpha:(CGFloat)((hex) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT];
}

+ (UIColor *)colorWithARGB_Ext:(uint) hex {
    return [UIColor colorWithRed:(CGFloat)((hex>>16) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                           green:(CGFloat)((hex>>8) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                            blue:(CGFloat)(hex & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                           alpha:(CGFloat)((hex>>24) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT];
}

+ (UIColor *)colorWithRGB_Ext:(uint) hex {
    return [UIColor colorWithRed:(CGFloat)((hex>>16) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                           green:(CGFloat)((hex>>8) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                            blue:(CGFloat)(hex & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                           alpha:1.0];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    if ([hexString hasPrefix:@"0x"] || [hexString hasPrefix:@"0X"]) {
        hexString = [hexString substringFromIndex:2];
    } else if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    
    unsigned int value = 0;
    BOOL flag = [[NSScanner scannerWithString:hexString] scanHexInt:&value];
    if(NO == flag)
        return [UIColor clearColor];
    float r, g, b, a;
    a = alpha;
    b = value & 0x0000FF;
    value = value >> 8;
    g = value & 0x0000FF;
    value = value >> 8;
    r = value;
    
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a];
}


+ (UIColor *)colorWithHex:(NSString *)hexString {
    unsigned long hex;
    
    // chop off hash
    if ([hexString characterAtIndex:0] == '#') {
        hexString = [hexString substringFromIndex:1];
    }
    
    // depending on character count, generate a color
    NSInteger hexStringLength = hexString.length;
    
    if (hexStringLength == 3) {
        // RGB, once character each (each should be repeated)
        hexString = [NSString stringWithFormat:@"%c%c%c%c%c%c", [hexString characterAtIndex:0], [hexString characterAtIndex:0], [hexString characterAtIndex:1], [hexString characterAtIndex:1], [hexString characterAtIndex:2], [hexString characterAtIndex:2]];
        hex = strtoul(hexString.UTF8String, NULL, 16);
        
        return [self colorWithRGB_Ext:(uint)hex];
    } else if (hexStringLength == 4) {
        // RGBA, once character each (each should be repeated)
        hexString = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c", [hexString characterAtIndex:0], [hexString characterAtIndex:0], [hexString characterAtIndex:1], [hexString characterAtIndex:1], [hexString characterAtIndex:2], [hexString characterAtIndex:2], [hexString characterAtIndex:3], [hexString characterAtIndex:3]];
        hex = strtoul(hexString.UTF8String, NULL, 16);
        
        return [self colorWithRGBA_Ext:(uint)hex];
    } else if (hexStringLength == 6) {
        // RGB
        hex = strtoul(hexString.UTF8String, NULL, 16);
        
        return [self colorWithRGB_Ext:(uint)hex];
    } else if (hexStringLength == 8) {
        // RGBA
        hex = strtoul(hexString.UTF8String, NULL, 16);
        
        return [self colorWithRGBA_Ext:(uint)hex];
    }
    
    // illegal
    [NSException raise:@"Invalid Hex String" format:@"Hex string invalid: %@", hexString];
    
    return nil;
}

- (NSString *) hexString_Ext {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    NSInteger red = (int)(components[0] * MAX_RGB_COLOR_VALUE);
    NSInteger green = (int)(components[1] * MAX_RGB_COLOR_VALUE);
    NSInteger blue = (int)(components[2] * MAX_RGB_COLOR_VALUE);
    NSInteger alpha = (int)(components[3] * MAX_RGB_COLOR_VALUE);
    
    if (alpha < 255) {
        return [NSString stringWithFormat:@"#%02lx%02lx%02lx%02lx", (long)red, (long)green, (long)blue, (long)alpha];
    }
    
    return [NSString stringWithFormat:@"#%02lx%02lx%02lx", (long)red, (long)green, (long)blue];
}

- (CGFloat)r_Ext {
    const CGFloat* rgba = CGColorGetComponents(self.CGColor);
    return rgba[0];
}

- (CGFloat)g_Ext {
    const CGFloat* rgba = CGColorGetComponents(self.CGColor);
    return rgba[1];
}

- (CGFloat)b_Ext {
    const CGFloat* rgba = CGColorGetComponents(self.CGColor);
    return rgba[2];
}

- (CGFloat)a_Ext {
    const CGFloat* rgba = CGColorGetComponents(self.CGColor);
    return rgba[3];
}


/**
 生成随机色
 
 @return UIColor对象
 */
+ (UIColor *)randomColor {
    int R = ((float)arc4random_uniform(256) / 255.0);
    int G = ((float)arc4random_uniform(256) / 255.0);
    int B = ((float)arc4random_uniform(256) / 255.0);
    return [UIColor colorWithRed:R green:G blue:B alpha:1.0];
}

@end
