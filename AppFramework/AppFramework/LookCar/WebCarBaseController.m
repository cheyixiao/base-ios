//
//  WebCarController.m
//  cheyixiao
//
//  Created by bjb on 2018/12/20.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import "WebCarBaseController.h"
#import "WebDownloadModel.h"
#import "DownloadManager.h"
#import "WebInterceptDownLoadManager.h"
#import "WebCarModel.h"
#import "WebCenterManager.h"
#import "MBProgressHUD.h"
#import "AppFrameworkTool.h"
#import "WebRequestManager.h"
#import "BaseDefine.h"
#import "DownLoadCacheModel.h"
#import "UIColor+CCColor.h"
#import "DownloadConst.h"
#import "AppNetWorking.h"

#define COLOR(RGB_String)           [UIColor colorWithHex:RGB_String]

@interface WebCarBaseController ()



@end

@implementation WebCarBaseController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"加载中...";
   
    if (self.type == 3 || self.type == 4) {
        self.webViewManager.webView.opaque = NO;
        self.view.backgroundColor = COLOR(@"#000000");
        self.webViewManager.webView.backgroundColor = COLOR(@"#000000");
         [self.webViewManager deleteWebCache];
        if (self.type == 3) {
            [WebCenterManager shareInstance].sandi = 0;
        }
        if(@available(iOS 11.0, *)) {
            self.webViewManager.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    self.webViewManager.delegate = self;
    if (self.type == 2) {
        //图片看车
        if ([self whetherRotationWithUrlString:self.baseWebUrl] ) {
            
            [self.view addSubview:self.goBackBtn];
        }
    }else{
        [self.view addSubview:self.goBackBtn];
    }
    _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
    [[UIApplication sharedApplication].keyWindow addGestureRecognizer:_tap];

    if (self.type != 3) {
         [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
   
    if (self.type == 1) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downLoadPersent:) name:@"webCarSourceDownLoad" object:nil];

        NSString *down = [DownLoadCenterManager shareInstance].downLoadStatus[self.carId];
        if ([[DownLoadCenterManager shareInstance].downLoadCar.allKeys containsObject:self.carId]) {
            down = @"3";
             [[WebCenterManager shareInstance]setDownLoadStatus:down carId:self.carId];
        }
        self.down = down;
        if (down) {
             [self loadWeb:down];
        }
        [self loadCarJson:NO];
    }else{
        [self loadWeb:@""];
    }
   
}
- (BOOL)whetherRotationWithUrlString:(NSString *)urlStr
{
    NSDictionary *dic = [AppFrameworkTool dictionaryWithUrlString:urlStr];
    //字符串类型：1 代表竖屏， 2 代表横屏
    if ([dic[@"orientation"] isEqualToString:@"2"]) {
        return YES;
    }
    return NO;
}
-(void)doTap:(UITapGestureRecognizer *)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        
         [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}
- (void)registerWeb{
    [[WebInterceptDownLoadManager shareInstance]wk_registerScheme];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.type == 3) {
        NSString *jsStr = [NSString stringWithFormat:@"goback3d(\'%ld\')",(long)[WebCenterManager shareInstance].sandi];
        [self.webViewManager evaluateJavaScript:jsStr];
        [WebCenterManager shareInstance].sandi = 0;
        
    }
    [DownLoadCenterManager shareInstance].check = YES;
    if (self.type == 1 || self.type == 3 || self.type == 4) {
        [WebInterceptDownLoadManager shareInstance].folder = self.carId;
         [self registerWeb];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [DownLoadCenterManager shareInstance].check = NO;

    
    if (self.type == 1 || self.type == 3 || self.type == 4) {
        [self unRegisterWeb];
    }
    if (self.type == 3 || self.type == 4) {
        [self.webViewManager deleteWebCache];
    }
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.sameDirection) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }    
}


- (void)loadCarJson:(BOOL )update{
    
    __block NSString *status = @"1";
    [[WebRequestManager shareInstance]loadData:self.carId update:update uploadProgressBlock:^(NSProgress * _Nullable uploadProgress) {
        
    } success:^(NSArray * _Nullable result, NSInteger update,NSInteger finishedCount) {
        if (update != doneDownLoad && [self.down isEqualToString:@"3"] && [[DownLoadCenterManager shareInstance].downLoadCar.allKeys containsObject:self.carId] ) {
            
            [self downLoad:result finishedCount:[NSString stringWithFormat:@"%ld",(long)finishedCount]];
             status = @"3";
        }
        if (update == doneDownLoad) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
            });
           
            [[WebCenterManager shareInstance]removeDownLoadCar:self.carId status:@"4"];

            //该包不需要更新
            status = @"4";

        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
                
            });
            
            if ([self.down isEqualToString:@"3"]  && [DownLoadCenterManager shareInstance].downing == YES && self.isDowning == NO && [[DownLoadCenterManager shareInstance].downLoadCar.allKeys containsObject:self.carId]) {
                //排队中
                status = @"3";
            }
            if (update == updateDownLoad  && self.isDowning == NO) {
                //有更新
                status = @"2";
            }
            if ( self.isDowning == YES) {
                status = @"5";
            }
             [[WebCenterManager shareInstance]setDownLoadStatus:status carId:self.carId];
        }
        if (!self.down) {
            [self loadWeb:status];
        }
    } failurl:^{
        
        if (!self.down) {
            [self loadWeb:status];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
            
        });
    }];
}
//下载车源公共包
- (void)loadCarCommon{
    if (self.type == 1) {
        [[WebRequestManager shareInstance]loadData:@"common" update:YES uploadProgressBlock:^(NSProgress * _Nullable uploadProgress) {
                
            } success:^(NSArray * _Nullable result, NSInteger update,NSInteger finishedCount) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
                    
                });
                if (update != doneDownLoad) {
                     [self addDownLoadCar:@"common"];
                    [self downLoad:result finishedCount:[NSString stringWithFormat:@"%ld",(long)finishedCount]];
                }else{
                    //该包不需要更新
                    [[WebCenterManager shareInstance]removeDownLoadCar:@"common" status:@"4"];
                }
                [self loadCarJson:YES];
            } failurl:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
                    
                });
                [self loadCarJson:YES];
            }];
    }
}

- (void)downLoad:(NSArray *)car finishedCount:(NSString * )count{
   
    NSDictionary *dic = @{@"car":car,@"count":count};
    [[NSNotificationCenter defaultCenter]postNotificationName:@"webPageSourceStartDownLoad" object:nil userInfo:dic];
    
}
- (void)loadWeb:(NSString *)update{
 
}

-(void)navLeftBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - webViewManager delegate
-(void)webViewManager:(WebViewManager *)webViewManager webViewTitleDidChange:(NSString *)title{
    self.title = title;
}
-(void)webViewManagerLoadingDidFailed:(WebViewManager *)webViewManager{
    
   
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self.title = @"加载失败";
        self.reloadBtn.hidden = NO;
        self.webViewManager.webView.hidden = YES;
        if (![AppNetWorking networkReachibility]) {
            UIImage *image = [UIImage imageNamed:@"noNetImage"];
            [self resetRelodBtnFrame:image];
        }else{
            UIImage *image = [UIImage imageNamed:@"emptyContentImage"];
            [self resetRelodBtnFrame:image];
        }
    });
    
}
-(void)webViewManagerLoadingDidFinished:(WebViewManager *)webViewManager{
    
   
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });

}
-(void)relodBtnClick:(UIButton *)sender{
    [self.webViewManager reloadWebView];
}
#pragma mark WKScriptMessageHandler
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{

    
}
- (void)addDownLoadCar:(NSString *)carId{
    
    DownLoadCacheModel *downLoadModel = [NSKeyedUnarchiver unarchiveObjectWithFile:[DownLoadCacheModel systemMsgCachePath]];
    if (!downLoadModel) {
        downLoadModel = [[DownLoadCacheModel alloc] init];
    }
    [downLoadModel.downStatus setObject:@"3" forKey:carId ];
    if (![downLoadModel.downLoadCar.allKeys containsObject:carId]) {
        //归档存储
        WebCarModel *model = [[WebCarModel alloc] init];
        model.carId        = carId;
        if ([carId isEqualToString:@"common"]) {
            model.sandi        = @"";
            model.quanjing     = @"";
            model.carName      = @"基础素材包";
        }else{
            model.sandi        = self.sandi;
            model.quanjing     = self.quanjing;
            model.carName      = self.carName;
            model.brand        = self.brand;
        }
       
        [downLoadModel.downLoadCar setObject:model forKey:carId];
    }
    if (![[DownLoadCenterManager shareInstance].downLoadCar.allKeys containsObject:carId]) {
        //临时存储
        WebCarModel *model = [[WebCarModel alloc] init];
        model.carId        = carId;
        if ([carId isEqualToString:@"common"]) {
            model.sandi        = @"";
            model.quanjing     = @"";
            model.carName      = @"基础素材包";
        }else{
            model.sandi        = self.sandi;
            model.quanjing     = self.quanjing;
            model.carName      = self.carName;
            model.brand        = self.brand;

        }
        [[DownLoadCenterManager shareInstance].downLoadCar setObject:model forKey:carId];
    }
    [[DownLoadCenterManager shareInstance].downLoadStatus setObject:@"3" forKey:carId];
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        [NSKeyedArchiver archiveRootObject:downLoadModel toFile:[DownLoadCacheModel systemMsgCachePath]];
    });
}
- (void)downLoadPersent:(NSNotification *)noification{
    NSDictionary *dic = noification.userInfo;
    if (dic) {
        NSString *carId = dic[@"carId"];
        if ([carId isEqualToString:self.carId]) {
            NSString *persent  = dic[@"persent"];
            float progress = [persent floatValue];
            BASELog(@"progress:%.2f",progress);
            self.isDowning = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
                NSString *jsStr = [NSString stringWithFormat:@"androidUpdateProgress(%.2f)",progress];
                [self.webViewManager evaluateJavaScript:jsStr];
            });
        }
    }
}

#pragma mark lazyLoad
-(UIButton *)goBackBtn{
    if (!_goBackBtn) {
        
        NSString *path       = [[NSBundle mainBundle] bundlePath];
        path                 = [path stringByAppendingString:@"/back"];
        UIImage *leftImg = [UIImage imageWithContentsOfFile:path];
        _goBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goBackBtn.frame = CGRectMake(16, 16, 44, 44);
        [_goBackBtn setImage:leftImg forState:UIControlStateNormal];
        [_goBackBtn addTarget:self action:@selector(navLeftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goBackBtn;
}
-(WebViewManager *)webViewManager{
    if (!_webViewManager) {
        _webViewManager = [[WebViewManager alloc] init];
        [_webViewManager sendWebViewToSuperView:self.view withFrame:CGRectZero];
        _webViewManager.progressHidden = YES;
    }
    return _webViewManager;
}
- (void)unRegisterWeb{
    [[WebInterceptDownLoadManager shareInstance]wk_unregisterScheme];

}

- (void)dealloc {
    
    [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:_tap];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if (_webViewManager) {
        [_webViewManager.webView removeFromSuperview];
        _webViewManager.delegate = nil;
        _webViewManager          = nil;
    }
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //需要注意的是self.isViewLoaded是必不可少的，其他方式访问视图会导致它加载 ，在WWDC视频也忽视这一点。
    if (self.isViewLoaded && !self.view.window)// 是否是正在使用的视图
    {
        //code
        self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
    }
}
@end
