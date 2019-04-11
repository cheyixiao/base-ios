//
//  UpdateModel.h
//  MccPro
//
//  Created by lxt on 2018/12/18.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UpdateModel : NSObject

@property (nonatomic, assign) NSInteger code;

@property (nonatomic, copy) NSString *version_ios;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *updateContent;

@property (nonatomic, copy) NSArray *update_content;
///已经弃用，使用h5_path
@property (nonatomic,copy) NSString *web_version;
@property (nonatomic,copy) NSString *h5_path;
@property (nonatomic,assign) NSInteger type;
///是否强制更新，0不强制，1强制
@property (nonatomic,copy) NSString *force_update;
@property (nonatomic,copy) NSString *button;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,copy) NSString *h5_url;
@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString *scroll;

@property (nonatomic,copy) NSString *isRegister;



@end

NS_ASSUME_NONNULL_END
