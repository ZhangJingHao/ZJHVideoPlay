//
//  WKVideoListCell.m
//  WuKongVideoPlayDemo
//
//  Created by ZhangJingHao2345 on 2018/3/14.
//  Copyright © 2018年 ZhangJingHao2345. All rights reserved.
//

#import "WKVideoListCell.h"
#import "UIImageView+WebCache.h"

@interface WKVideoListCell ()


@property (nonatomic, weak) UILabel *nameLab;

@end


@implementation WKVideoListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [WKVideoListCell cellHeight];
    
    // 图片
    CGFloat imgH = width * 0.56;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, imgH)];
    [self addSubview:imgView];
    self.imgView = imgView;
    
    // 标题背景
    UIImageView *imgBgTop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    imgBgTop.image = [UIImage imageNamed:@"top_shadow"];
    [self addSubview:imgBgTop];
    
    // 标题
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, width - 20, 50)];
    nameLab.textAlignment = NSTextAlignmentLeft;
    nameLab.textColor = [UIColor whiteColor];
    [self addSubview:nameLab];
    self.nameLab = nameLab;
    
    // 播放按钮
    CGFloat btnWH = imgH * 0.5;
    CGFloat btnX = (width - btnWH) / 2;
    CGFloat btnY = (imgH - btnWH) / 2;
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
    [playBtn setImage:[UIImage imageNamed:@"full_play_btn"] forState:UIControlStateNormal];
    [self addSubview:playBtn];
    [playBtn addTarget:self action:@selector(clickPlayBtn) forControlEvents:UIControlEventTouchUpInside];

    // 底部工具条
    CGFloat barH = height - imgH;
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, imgH, width, barH)];
    [self addSubview:barView];
}

- (void)setVideoItem:(WKVideoListItem *)videoItem {
    _videoItem = videoItem;

    [self.imgView sd_setImageWithURL:[NSURL URLWithString:videoItem.cover]
                    placeholderImage:[UIImage imageNamed:@"sc_video_play_fs_loading_bg"]];
    NSString *str = [videoItem.title stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    self.nameLab.text = str;
}

- (void)clickPlayBtn {
    if (self.playBtnBlcok) {
        self.playBtnBlcok(self);
    }
}


+ (CGFloat)cellHeight {
    return [UIScreen mainScreen].bounds.size.width * 0.65;
}

@end
