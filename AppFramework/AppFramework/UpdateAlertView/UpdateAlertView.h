//
//  UpdateAlertView.h
//  MccPro
//
//  Created by 洪清 on 2019/4/1.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class UpdateModel;
//首页弹框的类型
typedef NS_ENUM(NSUInteger,CYXHomePromptViewType) {
    updateType = 1,  //强制更新、更新
    jumpTabbarType = 2,  //跳转tab
    jumWebViewType = 3,  //跳转h5
    promptType = 4,  //提示
};
///确定按钮的各种操作
typedef void(^ClickBlock)(UpdateModel *model);
@interface UpdateAlertView : UIView
///项目如没有背景图，可以单独设置
@property (nonatomic,copy) NSString *imageName;
@property (nonatomic,copy) ClickBlock clickBlock;

-(instancetype)initWithUpdateModel:(UpdateModel *)model frame:(CGRect)frame;

-(void)showAlertView;

-(void)dismissAlertView;

@end

NS_ASSUME_NONNULL_END
