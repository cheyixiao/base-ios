//
//  WebCarModel.h
//  cheyixiao
//
//  Created by bjb on 2018/12/24.
//  Copyright © 2018年 cheshikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WebCarModel;
@protocol WebCarModelDelegate <NSObject>

- (void)webCarModel:(WebCarModel *)webCarModel persent:(NSString *)persent;
@end

@interface WebCarModel : NSObject<NSCoding>

@property(nonatomic,strong)NSString *carName;
@property(nonatomic,strong)NSString *brand;
@property(nonatomic,strong)NSString *sandi;
@property(nonatomic,strong)NSString *quanjing;
@property(nonatomic,strong)NSString *persent;
@property(nonatomic,strong)NSString *carId;
@property (nonatomic, weak) id <WebCarModelDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
