//
//  UpdateAlertView.m
//  MccPro
//
//  Created by 洪清 on 2019/4/1.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import "UpdateAlertView.h"
#import "UpdateModel.h"
#import "UIColor+CCColor.h"
#import "FrameDefine.h"
#import "AppFrameworkTool.h"
#import "Masonry.h"
@interface UpdateAlertView()
@property (nonatomic,strong) UIButton *updateBtn;
@property (nonatomic,strong) UIButton *cancelBtn;
@property (nonatomic,strong) UIImageView *bkImageView;
@property (nonatomic,strong) UILabel *descLabel;
@property (nonatomic,strong) UIStackView *stackView;
@property (nonatomic,strong) UpdateModel *model;
///更新内容动态高度
@property (nonatomic,assign) CGFloat height;
@end
@implementation UpdateAlertView

#pragma mark- 懒加载
-(UIButton *)updateBtn
{
    if (!_updateBtn) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor =[UIColor colorWithHex:@"D5001C"];
        button.layer.cornerRadius =5;
        button.layer.masksToBounds =YES;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button addTarget:self action:@selector(updateAction) forControlEvents:UIControlEventTouchUpInside];
        _updateBtn =button;
    }
    return _updateBtn;
}

-(UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor =[UIColor whiteColor];
        button.layer.cornerRadius =5;
        button.layer.masksToBounds =YES;
        button.layer.borderWidth =1;
        button.layer.borderColor = [UIColor colorWithHex:@"cccccc"].CGColor;
        [button setTitle:@"暂不更新" forState:UIControlStateNormal];
        [button setTitle:@"暂不更新" forState:UIControlStateSelected];
        [button setTitleColor:[UIColor colorWithHex:@"999999"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHex:@"999999"] forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn =button;
    }
    return _cancelBtn;
}

-(instancetype)initWithUpdateModel:(UpdateModel *)model frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.model = model;
        [self initUI];
    }
    return self;
}

- (void)setImageName:(NSString *)imageName
{
    _imageName =imageName;
    [self.bkImageView setImage:[UIImage imageNamed:imageName]];
}

-(void)updateAction
{
    [self dismissAlertView];
    if (self.clickBlock) {
        self.clickBlock(self.model);
    }
}

-(void)showAlertView
{
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
}

-(void)cancelAction
{
    [self dismissAlertView];
}

-(void)dismissAlertView
{
    [self removeFromSuperview];
}

-(void)initUI
{
    self.backgroundColor =[UIColor colorWithHexString:@"000000" alpha:0.6];
    self.bkImageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"updateImg"]];
    self.bkImageView.userInteractionEnabled =YES;
    [self addSubview:self.bkImageView];
    [self.bkImageView addSubview:self.updateBtn];
    [self.updateBtn setTitle:self.model.button forState:UIControlStateNormal];
    if (self.model.type ==updateType &&[self.model.force_update isEqualToString:@"0"]) {
        [self.bkImageView addSubview:self.cancelBtn];
    }
    self.descLabel =[[UILabel alloc]init];
    self.descLabel.text = self.model.title;
    self.descLabel.font =[UIFont systemFontOfSize:18];
    [self.bkImageView addSubview:self.descLabel];
    
    NSMutableArray *viewArr =[NSMutableArray array];
    for (int i=0; i<self.model.update_content.count;i++) {
        UILabel *label =[[UILabel alloc]init];
        //        label.backgroundColor =[UIColor yellowColor];
        label.textColor =[UIColor colorWithHex:@"#666666"];
        label.font =[UIFont systemFontOfSize:15];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:self.model.update_content[i]];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        //        paragraphStyle.lineSpacing = 2.0; // 设置行间距
        paragraphStyle.alignment = NSTextAlignmentJustified; //设置两端对齐显示
        [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedStr.length)];
        label.numberOfLines =0;
        label.attributedText = attributedStr;
        if (IS_IPAD) {
            self.height += [AppFrameworkTool getTextWidthMethod:self.model.update_content[i] font:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(320, MAXFLOAT)].height+5;
        }else{
            self.height += [AppFrameworkTool getTextWidthMethod:self.model.update_content[i] font:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(kScreenWidth-90, MAXFLOAT)].height+5;
        }
        [viewArr addObject:label];
    }
    self.stackView = [[UIStackView alloc]initWithArrangedSubviews:viewArr];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.spacing =5;
    //    //设置轴方向上的子视图分布比例
    self.stackView.distribution = UIStackViewDistributionEqualSpacing;
    self.stackView.alignment = UIStackViewAlignmentLeading;
    [self.bkImageView addSubview:self.stackView];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (IS_IPAD) {
        [self.bkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@320);
            make.centerY.equalTo(self.mas_centerY);
            make.centerX.equalTo(self.mas_centerX);
        }];
    }else{
        [self.bkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(30);
            make.right.equalTo(self.mas_right).offset(-30);
            make.centerY.equalTo(self.mas_centerY);
            make.centerX.equalTo(self.mas_centerX);
        }];
    }
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bkImageView.mas_top).offset(150);
        make.left.equalTo(self.bkImageView.mas_left).offset(15);
        make.height.equalTo(@20);
    }];
    
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descLabel.mas_bottom).offset(20);
        make.left.equalTo(self.bkImageView.mas_left).offset(15);
        make.right.equalTo(self.bkImageView.mas_right).offset(-15);
        make.height.equalTo(@(self.height));
    }];
    
    if (self.model.type ==updateType &&[self.model.force_update isEqualToString:@"0"]) {
        [self.updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.stackView.mas_bottom).offset(20);
            make.bottom.equalTo(self.bkImageView.mas_bottom).offset(-15);
            make.left.equalTo(self.bkImageView.mas_centerX).offset(5);
            make.height.equalTo(@40);
            make.right.equalTo(self.bkImageView.mas_right).offset(-15);
        }];
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.bkImageView.mas_bottom).offset(-15);
            make.right.equalTo(self.bkImageView.mas_centerX).offset(-5);
            make.left.equalTo(self.bkImageView.mas_left).offset(15);
            make.height.equalTo(@40);
            
            make.top.equalTo(self.updateBtn.mas_top);
        }];
        
    }else{
        [self.updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.stackView.mas_bottom).offset(20);
            make.bottom.equalTo(self.bkImageView.mas_bottom).offset(-15);
            make.left.equalTo(self.bkImageView.mas_left).offset(15);
            make.height.equalTo(@40);
            make.right.equalTo(self.bkImageView.mas_right).offset(-15);
        }];
    }
    [self.bkImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.updateBtn.mas_bottom).offset(15);
    }];
    
}
@end
