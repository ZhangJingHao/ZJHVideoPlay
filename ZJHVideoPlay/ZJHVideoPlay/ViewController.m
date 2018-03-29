//
//  ViewController.m
//  WuKongVideoPlayDemo
//
//  Created by ZhangJingHao2345 on 2018/3/13.
//  Copyright © 2018年 ZhangJingHao2345. All rights reserved.
//

#import "ViewController.h"
#import "WKVideoListViewController.h"

@interface ViewController () 


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self clickBtn];
}

- (IBAction)clickBtn {
    WKVideoListViewController *vc = [WKVideoListViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
