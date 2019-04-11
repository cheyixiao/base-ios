//
//  SYWebViewManager.m
//
//

#import "WebViewManager.h"
#import "WKProcessPool+WebCarProcessPool.h"
#import "Masonry/Masonry/Masonry.h"

#import "UIView+CCView.h"
#import "UIColor+CCColor.h"

@interface WebViewManager ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic,strong,readwrite) WKWebView *webView;
@property (nonatomic ,strong) UIView *progress;
@property (nonatomic ,strong) CAGradientLayer *gradientLayer;
/** 键盘弹起屏幕偏移量 */
@property (nonatomic, assign) CGPoint keyBoardPoint;
@end

@implementation WebViewManager

-(UIView *)lineView
{
    if (!_lineView) {
        _lineView =[UIView new];
        _lineView.backgroundColor =[UIColor clearColor];
    }
    return _lineView;
}

-(void)sendWebViewToSuperView:(UIView *)superView withFrame:(CGRect)frame{
    [superView addSubview:self.webView];
    [self.webView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.webView);
        make.width.equalTo(@15);
    }];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView);
    }];
    [self registerKVO];
}
-(void)webViewAddScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name{
    if( self.webView.configuration.userContentController == nil ){
        self.webView.configuration.userContentController = [[WKUserContentController alloc] init];
    }
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:name];
    [self.webView.configuration.userContentController addScriptMessageHandler:scriptMessageHandler name:name];
    
}

-(void)webViewAddUserScriptSource:(NSString *)scriptSource atInjectionTime:(WKUserScriptInjectionTime)injectionTime{
    if( self.webView.configuration.userContentController == nil ){
        self.webView.configuration.userContentController = [[WKUserContentController alloc] init];
    }
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:scriptSource injectionTime:injectionTime forMainFrameOnly:YES];
    [self.webView.configuration.userContentController addUserScript:userScript];
    
}
-(void)evaluateJavaScript:(NSString *)scriptSource{
    [self.webView evaluateJavaScript:scriptSource completionHandler:^(id object, NSError * _Nullable error) {
        
    }];
}
//当wkwebview把html加载完之后，调用此方法(否则无效)
-(void)webViewRemoveAllUserScript{
    [self.webView.configuration.userContentController removeAllUserScripts];
}
-(void)webViewRemoveScriptMessageHandlerForName:(NSString *)name{
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:name];
}

-(void)reloadWebView{
    [self.webView reload];
}

-(void)webViewLoadUrl:(NSString *)urlString{

    if ([urlString containsString:@"http://"] || [urlString containsString:@"https://"]) {
        dispatch_async(dispatch_get_main_queue(),^{
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            [self.webView loadRequest:request];
        });
        
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if( [object isEqual:self.webView] ){
        if( [keyPath isEqualToString:@"title"] ){
            if( [self.delegate respondsToSelector:@selector(webViewManager:webViewTitleDidChange:)] ){
                [self.delegate webViewManager:self webViewTitleDidChange:self.webView.title];
            }
        }
        if( [keyPath isEqualToString:@"estimatedProgress"] ){
            if( !_progressHidden ){
                self.progress.width =self.webView.estimatedProgress*[UIScreen mainScreen].bounds.size.width;
                _gradientLayer.frame = self.progress.frame;
                if( self.webView.estimatedProgress==1 ){
                    [self removeProgressView];
                }
            }
            if( [self.delegate respondsToSelector:@selector(webViewManager:webViewLoadingWithProgress:)] ){
                [self.delegate webViewManager:self webViewLoadingWithProgress:self.webView.estimatedProgress];
            }
        }
    }
}
#pragma mark - webView navigation delegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if( [self.delegate respondsToSelector:@selector(webViewManagerLoadingDidStart:)] ){
        [self.delegate webViewManagerLoadingDidStart:self];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if( [self.delegate respondsToSelector:@selector(webViewManagerLoadingDidFinished:)] ){
        [self.delegate webViewManagerLoadingDidFinished:self];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
   
    if (((NSHTTPURLResponse *)navigationResponse.response).statusCode == 200) {
        decisionHandler (WKNavigationResponsePolicyAllow);
    }else {
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
    //允许跳转
//        decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    [self removeWebView];
    if( [self.delegate respondsToSelector:@selector(webViewManagerLoadingDidFailed:)] ){
        [self.delegate webViewManagerLoadingDidFailed:self];
    }
    if( !_progressHidden ){
        [self removeProgressView];
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *URL = navigationAction.request.URL;
    
    
    NSString *scheme = [URL scheme];
    if ([scheme isEqualToString:self.scheme]) {
        
        decisionHandler(WKNavigationActionPolicyCancel);
        
        NSString *absoluteString = URL.absoluteString;
        if ([absoluteString containsString:@"https"]) {
            absoluteString = [absoluteString stringByReplacingOccurrencesOfString:@"https//" withString:@"https://"];
        }else{
            absoluteString = [absoluteString stringByReplacingOccurrencesOfString:@"http//" withString:@"http://"];
        }
        if ([self.delegate respondsToSelector:@selector(webViewManager:pushWebViewController:)]) {
            [self.delegate webViewManager:self pushWebViewController:absoluteString];
        }        
        return;
    }
    
    if ([scheme isEqualToString:@"haleyaction"]) {
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.delegate respondsToSelector:@selector(cyx_userContentController:didReceiveScriptMessage:)]) {
        [self.delegate cyx_userContentController:userContentController didReceiveScriptMessage:message];
    }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
}

#pragma mark WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:alertController animated:YES completion:nil];
    
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:alertController animated:YES completion:nil];
}
- (void)deleteWebCache {
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        
                    NSSet *websiteDataTypes
        
                    = [NSSet setWithArray:@[
        
                                            WKWebsiteDataTypeDiskCache,
        
                                            WKWebsiteDataTypeOfflineWebApplicationCache,
        
                                            WKWebsiteDataTypeMemoryCache,
        
//                                            WKWebsiteDataTypeLocalStorage,
        
                                            WKWebsiteDataTypeCookies,
        
                                            WKWebsiteDataTypeSessionStorage,
        
                                            WKWebsiteDataTypeIndexedDBDatabases,
        
                                            WKWebsiteDataTypeWebSQLDatabases
        
                                            ]];
        
        //// All kinds of data
        
//        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        
        //// Date from
        
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        
        //// Execute
        
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            // Done
        }];
        
    } else {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        
        NSError *errors;
        
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    }
}

-(void)removeProgressView{
    if( _progress ){
        [_progress removeFromSuperview];
        _progress = nil;
    }
}
-(void)removeWebView{
    if( _webView){
        [self unRegisterKVO];
        [_webView removeFromSuperview];
        _webView = nil;
    }
}

-(void)setProgressHidden:(BOOL)progressHidden{
    _progressHidden = progressHidden;
    if( _progressHidden ){
        [self removeProgressView];
    }
}

#pragma mark 
-(void)registerKVO{
    if(_webView ){
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
//        Reachability *rea = [Reachability reachabilityForInternetConnection];
//        [rea startNotifier];
    }
}

//-(void)networkStateChange
//{
//    if ([WebSourceManager shareInstance].cutNet) {
//        if( [self.delegate respondsToSelector:@selector(webViewManagerNetWorkFailed:)]){
//            [self.delegate webViewManagerNetWorkFailed:self];
//        }
//    }
//}


-(void)unRegisterKVO{
    if( _webView ){
        
        @try {
            
            [self.webView removeObserver:self forKeyPath:@"title"];
            [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
}
#pragma mark
-(WKWebView *)webView{
    if( !_webView ){
        _progressHidden = NO;
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.allowsInlineMediaPlayback = YES;
        configuration.processPool = [WKProcessPool sharedProcessPool];
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        if (@available(iOS 10.0, *)) {
//            configuration.mediaTypesRequiringUserActionForPlayback = false;
        } else {
            // Fallback on earlier versions
        }
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        [_webView.configuration.preferences setValue:@(YES) forKey:@"allowFileAccessFromFileURLs"];
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        _webView.scrollView.scrollEnabled = NO;
        _webView.allowsBackForwardNavigationGestures = YES;
        [self setUserAgent:_webView];
        //iOS12 - 使用WKWebView出现input键盘将页面上顶不下移
        // 监听将要弹起
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow) name:UIKeyboardWillShowNotification object:nil];
        // 监听将要隐藏
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHidden) name:UIKeyboardWillHideNotification object:nil];
    }
    return _webView;
}
- (void )setUserAgent:(WKWebView *)wkWebView{
    
    if (!wkWebView) {
        wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
    }
    [wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        NSLog(@"userAgent:%@", result);
        [self appendUserAgent:result webView:wkWebView];
    }];
    
}
-(void )appendUserAgent:(NSString *)userAgent webView:(WKWebView *)webView{
    
    if (userAgent) {
        if ([userAgent containsString:@" cheyixiao/"]) {
            //会重复拼接 需要把上一次的删除
            NSRange range = [userAgent rangeOfString:@" cheyixiao/"];
            userAgent     = [userAgent substringToIndex:range.location];
        }
        NSString *customUserAgent = [userAgent stringByAppendingString:[NSString stringWithFormat:@" cheyixiao/%@",[self getAppVersion]]];
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":customUserAgent}];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //        webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    }else{
        [self setUserAgent:webView];
    }
    
}
- (NSString *)getAppVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDictionary));
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}
/// 键盘将要弹起
- (void)keyBoardShow {
    CGPoint point = self.webView.scrollView.contentOffset;
    self.keyBoardPoint = point;
    
}
/// 键盘将要隐藏
- (void)keyBoardHidden {
    if (@available(iOS 12.0, *)) {
        WKWebView *webview = (WKWebView*)self.webView;
        for(UIView* v in webview.subviews){
            if([v isKindOfClass:NSClassFromString(@"WKScrollView")]){
                UIScrollView *scrollView = (UIScrollView*)v;
                [scrollView setContentOffset:CGPointMake(0, 0)];
            }
        }
    }
//    self.webView.scrollView.contentOffset = self.keyBoardPoint;
//    CYXLog(@"%.2f %.2f", self.webView.width, self.webView.height);
}

-(UIView *)progress
{
    if (!_progress)
    {
        _progress = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 3)];
        _progress.layer.cornerRadius = _progress.height/2;
        _progress.layer.masksToBounds = YES;
        [_webView addSubview:_progress];
        [_webView bringSubviewToFront:_progress];
        
        _gradientLayer = [CAGradientLayer layer];
        
        //  设置 gradientLayer 的 Frame
        _gradientLayer.frame = _progress.frame;
        
        //  创建渐变色数组，需要转换为CGColor颜色
        _gradientLayer.colors = @[(id)[UIColor whiteColor].CGColor,
                                 
                                 (id)[UIColor  colorWithHex:@"#FF4C4B"].CGColor];
        
        //  设置三种颜色变化点，取值范围 0.0~1.0
        _gradientLayer.locations = @[@(0.1f) ,@(1.0f)];
        
        //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(1, 0);
        //  添加渐变色到创建的 UIView 上去
        [_progress.layer addSublayer:_gradientLayer];

    }
    return _progress;
}

-(void)dealloc
{
    [self unRegisterKVO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}
@end
