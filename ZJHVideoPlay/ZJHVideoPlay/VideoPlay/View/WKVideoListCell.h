//
//  WKVideoListCell.h
//  WuKongVideoPlayDemo
//
//  Created by ZhangJingHao2345 on 2018/3/14.
//  Copyright © 2018年 ZhangJingHao2345. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKVideoListItem.h"

@interface WKVideoListCell : UITableViewCell

@property (nonatomic, weak) UIImageView *imgView;

@property (nonatomic, copy) void (^playBtnBlcok)(WKVideoListCell *cell);

@property (nonatomic, strong) WKVideoListItem *videoItem;


+ (CGFloat)cellHeight;

@end
