//
//  CYXJSBridgeViewController.m
//  cheyixiao
//
//  Created by wangqichao on 2018/12/5.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import "JSBridgeViewController.h"


@interface JSBridgeViewController ()

//@property (nonatomic, strong) NoNetworkView *noNetworkView;

@end

@implementation JSBridgeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark lazyLoad
- (WebViewManager *)webViewManager{
    if (!_webViewManager) {
        _webViewManager = [[WebViewManager alloc] init];
        [_webViewManager sendWebViewToSuperView:self.view withFrame:CGRectZero];
        _webViewManager.progressHidden = NO;
    }
    return _webViewManager;
}
-(void)dealloc{
  if (_webViewManager) {
        [_webViewManager.webView removeFromSuperview];
        _webViewManager          = nil;
    }
}
@end
