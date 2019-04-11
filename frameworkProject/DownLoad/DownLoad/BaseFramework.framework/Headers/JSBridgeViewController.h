//
//  CYXJSBridgeViewController.h
//  cheyixiao
//
//  Created by wangqichao on 2018/12/5.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import "BaseViewController.h"
#import "WebViewManager.h"

NS_ASSUME_NONNULL_BEGIN
@class WebViewManager;
@interface JSBridgeViewController : BaseViewController

@property (nonatomic, strong) WebViewManager *webViewManager;


@end

NS_ASSUME_NONNULL_END
