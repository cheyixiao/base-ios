//
//  CYXWebViewManager.h
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class WebViewManager;

@protocol WebViewManagerDelegate <NSObject>

@optional
/*
 *  加载网页，网页标题改变时调用。
 */
-(void)webViewManager:(WebViewManager *)webViewManager webViewTitleDidChange:(NSString *)title;

/*
 *  网页加载进度。
 */
-(void)webViewManager:(WebViewManager *)webViewManager webViewLoadingWithProgress:(double)progress;

-(void)webViewManagerLoadingDidStart:(WebViewManager *)webViewManager;
-(void)webViewManagerLoadingDidFinished:(WebViewManager *)webViewManager;
-(void)webViewManagerLoadingDidFailed:(WebViewManager *)webViewManager;
-(void)webViewManagerNetWorkFailed:(WebViewManager *)webViewManager;
-(void)webViewManager:(WebViewManager *)webViewManager pushWebViewController:(NSString *)url;

- (void)cyx_userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

@end

@interface WebViewManager : NSObject

@property (nonatomic,weak) id<WebViewManagerDelegate>delegate;

@property (nonatomic,strong,readonly) WKWebView *webView;

@property (nonatomic,assign) BOOL progressHidden;   //!< default is NO
@property (nonatomic,strong) UIView   *lineView;
@property(nonatomic,copy)    NSString *scheme;//要拦截的URL


/**
 *  设置父视图以及大小位置
 *
 *  @param superView 父视图
 *  @param frame     相对父视图的大小位置，可以缺省为CGRectZero
 */
-(void)sendWebViewToSuperView:(UIView *)superView withFrame:(CGRect)frame;

/**
 *  webView向原生通信。
 *  在通信不用的时候，一定要调用webViewRemoveScriptMessageHandlerForName:来删除通信。
 *  否则，会出现内存泄露问题
 *
 *  @param scriptMessageHandler webView通知的原生对象，在相应的代理方法中，执行接收到的消息
 *  @param name                 通知的名字，由名字识别是哪个通信
 */
-(void)webViewAddScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler
                                 name:(NSString *)name;

/**
 *  原生,修改web业务逻辑 
 *
 *  @param scriptSource  脚本代码字符串
 *  @param injectionTime 脚本代码执行时间
 */
-(void)webViewAddUserScriptSource:(NSString *)scriptSource
                  atInjectionTime:(WKUserScriptInjectionTime)injectionTime;

//ios端向web端传值 当wkwebview把html加载完之后，调用此方法(否则无效)
-(void)evaluateJavaScript:(NSString *)scriptSource;
/**
 *  移除添加的脚本代码。
 */
-(void)webViewRemoveAllUserScript;

/**
 *  移除原生对webView的监听。
 *
 *  @param name 通知的名字
 */
-(void)webViewRemoveScriptMessageHandlerForName:(NSString *)name;

/**
 *  刷新webView
 */
-(void)reloadWebView;

/**
 *  webView从urlString加载数据
 */
-(void)webViewLoadUrl:(NSString *)urlString;

//清除缓存
- (void)deleteWebCache ;
@end
