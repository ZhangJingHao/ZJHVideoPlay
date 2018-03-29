//
//  WKPlayerView.h
//  WuKongVideoPlayDemo
//
//  Created by ZhangJingHao2345 on 2018/3/15.
//  Copyright © 2018年 ZhangJingHao2345. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WKPlayerViewDelegate<NSObject>
@required
// 获取需要弹框的控制器
- (UIViewController *)getpresentViewController;
// 获取视频播放器的父视图
- (UIView *)getPlayerSuperView;
@end

@interface WKPlayerView : UIView

@property (nonatomic, weak) id<WKPlayerViewDelegate> delegate;

/// 设置数据
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) UIImage *coverImage;

/// 播放视频
- (void)playWithViedeoUrl:(NSString *)videoUrl;

/// 移除视频
- (void)removePlayer;

@end
