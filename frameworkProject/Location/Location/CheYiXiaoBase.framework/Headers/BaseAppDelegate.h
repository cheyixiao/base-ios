//
//  AppDelegate.h
//  TeSt
//
//  Created by bjb on 2019/3/20.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface BaseAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,assign)BOOL allowRotation;//是否允许转向

- (void)chooseViewController;


@end

