//
//  BaseViewController.m
//  SourceFramework
//
//  Created by bjb on 2019/3/29.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *imageview1 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, 100, 100)];
    NSString *path          = [[NSBundle mainBundle] pathForResource:@"source" ofType:@"bundle"];
    UIImage *image1         = [UIImage imageNamed:@"praise" inBundle:[NSBundle bundleWithPath:path] compatibleWithTraitCollection:nil];
    imageview1.image        = image1;

    [self.view addSubview:imageview1];
    
    UIImageView *imageview2 = [[UIImageView alloc] initWithFrame:CGRectMake(120, 100, 100, 100)];
    NSString *path2         = [[NSBundle mainBundle] bundlePath];
    
    UIImage *image2         = [UIImage imageWithContentsOfFile:[path2 stringByAppendingString:@"/star"]];
    imageview2.image        = image2;
    [self.view addSubview:imageview2];
}



@end
