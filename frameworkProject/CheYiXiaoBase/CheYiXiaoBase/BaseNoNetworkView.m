//
//  NoNetworkView.m
//  cheyixiao
//
//  Created by lxt on 2018/12/17.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import "BaseNoNetworkView.h"
#import "Color.h"
#import "FrameDefine.h"
#import <Networking/AppNetWorking.h>

@interface BaseNoNetworkView ()



@end

@implementation BaseNoNetworkView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createView];
    }
    return self;
}

- (void)createView
{
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(19, 33, 9.5, 18.5)];
    backImage.image = [UIImage imageNamed:@"back"];
    [self addSubview:backImage];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 30, 50, 25);
    [backButton addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 33, kScreenWidth - 200, 20)];
    titleLabel.text = @"加载失败";
    titleLabel.font = [UIFont systemFontOfSize:16.0];
    titleLabel.textColor = RGB(0x333333);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 0.4)];
    view.backgroundColor = RGB(0x333333);
    [self addSubview:view];
    
    UIImage *reloadImage;
    if (![AppNetWorking networkReachibility]) {
        reloadImage = [UIImage imageNamed:@"noNetImage"];
    }else{
        reloadImage = [UIImage imageNamed:@"emptyContentImage"];
    }
    UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reloadBtn.frame = CGRectMake(0, 0, reloadImage.size.width, reloadImage.size.width);
    [reloadBtn setImage:reloadImage forState:UIControlStateNormal];
    [reloadBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [reloadBtn addTarget:self action:@selector(reloadBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:reloadBtn];
    reloadBtn.center = self.center;
    
    UILabel *reloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(reloadBtn.frame.origin.x, reloadBtn.frame.origin.y + reloadBtn.frame.size.height + 5, reloadBtn.frame.size.width, 20)];
    reloadLabel.text = @"网络异常，点击重试";
    reloadLabel.textAlignment = NSTextAlignmentCenter;
    reloadLabel.font = [UIFont systemFontOfSize:14.0];
    reloadLabel.textColor = RGB(0x999999);
    [self addSubview:reloadLabel];
}

- (void)backBtnClick
{
    if ([self.delegate respondsToSelector:@selector(clickBackButton)]) {
        [self.delegate clickBackButton];
    }
}

- (void)reloadBtnClick
{
    if ([self.delegate respondsToSelector:@selector(clickReloadButton)]) {
        [self.delegate clickReloadButton];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
