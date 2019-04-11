//
//  NoNetworkView.h
//  cheyixiao
//
//  Created by lxt on 2018/12/17.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BaseNoNetworkViewDelegate <NSObject>

- (void)clickBackButton;

- (void)clickReloadButton;

@end

@interface BaseNoNetworkView : UIView

@property (nonatomic, weak) id<BaseNoNetworkViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
