//
//  WKPlayerView.m
//  WuKongVideoPlayDemo
//
//  Created by ZhangJingHao2345 on 2018/3/15.
//  Copyright © 2018年 ZhangJingHao2345. All rights reserved.
//

#import "WKPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface WKPlayerView ()

@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, weak) UIView *coverView;
@property (nonatomic, weak) UIView *upView;
@property (nonatomic, weak) UIImageView *upBgView;
@property (nonatomic, weak) UIButton *backBtn;
@property (nonatomic, weak) UILabel *nameLab;
@property (nonatomic, weak) UIButton *playBtn;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UIImageView *bottomBgView;
@property (nonatomic, weak) UILabel *timeLab;
@property (nonatomic, weak) UILabel *totalLab;
@property (nonatomic, weak) UISlider *slider;
@property (nonatomic, weak) UIButton *fullBtn;
@property (nonatomic, weak) UIImageView *bgImgView;
@property (nonatomic, weak) UIProgressView *cacheProgress;
@property (nonatomic, weak) UIActivityIndicatorView *activity;
@property (nonatomic, weak) UIView *errView;
@property (nonatomic, weak) UILabel *errLab;
@property (nonatomic, weak) UIButton *errBtn;

@property (nonatomic, strong) NSTimer *showTimer;

@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL isTurnRight;
@property (nonatomic, assign) BOOL isChanging;

@property (nonatomic, strong) UIViewController *fullVC;
@property (nonatomic, assign) CGRect originF;

@end

@implementation WKPlayerView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self configNotification];
    }
    return self;
}

// 相关配置
- (void)configNotification {
    // 添加点击事件
    UITapGestureRecognizer *tapGesturRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapPlayerView)];
    [self addGestureRecognizer:tapGesturRecognizer];
}

// 设置界面
- (void)setupUI {
    // 背景遮盖
    UIView *coverView = [[UIView alloc] init];
    [self addSubview:coverView];
    self.coverView = coverView;
    
    // 顶部视图
    UIView *upview = [UIView new];
    [coverView addSubview:upview];
    self.upView = upview;
    
    UIImageView *upBgView = [UIImageView new];
    upBgView.image = [UIImage imageNamed:@"top_shadow"];
    [upview addSubview:upBgView];
    self.upBgView = upBgView;
    
    UIButton *backBtn = [UIButton new];
    [backBtn setImage:[UIImage imageNamed:@"navbar_back_hig"]
             forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    [upview addSubview:backBtn];
    self.backBtn = backBtn;
    
    UILabel *nameLab = [UILabel new];
    nameLab.textColor = [UIColor whiteColor];
    nameLab.numberOfLines = 0;
    [upview addSubview:nameLab];
    self.nameLab = nameLab;
    
    // 中间按钮
    UIButton *playBtn = [UIButton new];
    [playBtn setImage:[UIImage imageNamed:@"full_play_btn"]
             forState:UIControlStateNormal];
    [playBtn setImage:[UIImage imageNamed:@"full_pause_btn"]
             forState:UIControlStateSelected];
    [playBtn addTarget:self
                action:@selector(clickPlayBtn:)
      forControlEvents:UIControlEventTouchUpInside];
    playBtn.selected = YES;
    [coverView addSubview:playBtn];
    self.playBtn = playBtn;
    
    // 底部视图
    UIView *bottomView = [UIView new];
    [coverView addSubview:bottomView];
    self.bottomView = bottomView;
    
    UIImageView *bottomBgView = [UIImageView new];
    bottomBgView.image = [UIImage imageNamed:@"sc_video_play_fs_loading_bg"];
    [bottomView addSubview:bottomBgView];
    self.bottomBgView = bottomBgView;
    
    UILabel *timeLab = [UILabel new];
    timeLab.textAlignment = NSTextAlignmentCenter;
    timeLab.textColor = [UIColor whiteColor];
    [bottomView addSubview:timeLab];
    self.timeLab = timeLab;
    
    UILabel *totalLab = [UILabel new];
    totalLab.textAlignment = NSTextAlignmentCenter;
    totalLab.textColor = [UIColor whiteColor];
    [bottomView addSubview:totalLab];
    self.totalLab = totalLab;
    
    UIProgressView *cacheProgress = [UIProgressView new];
    cacheProgress.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    cacheProgress.trackTintColor = [UIColor clearColor];
    [bottomView addSubview:cacheProgress];
    self.cacheProgress = cacheProgress;
    
    UISlider *slider = [UISlider new];
    [slider addTarget:self
               action:@selector(sliderChange:)
     forControlEvents:UIControlEventValueChanged];
    [slider setThumbImage:[UIImage imageNamed:@"thumbImage"]
                 forState:UIControlStateNormal];
    slider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
//    slider.minimumTrackTintColor = [UIColor orangeColor];
    //    [slider setMaximumTrackImage:[UIImage imageNamed:@"MaximumTrackImage"]
    //                        forState:UIControlStateNormal];
    [slider setMinimumTrackImage:[UIImage imageNamed:@"MinimumTrackImage"]
                        forState:UIControlStateNormal];
    [bottomView addSubview:slider];
    self.slider = slider;
    
    UIButton *fullBtn = [UIButton new];
    [fullBtn addTarget:self
                action:@selector(clickBackBtn)
      forControlEvents:UIControlEventTouchUpInside];
    [fullBtn setImage:[UIImage imageNamed:@"sc_video_play_fs_enter_ns_btn"]
             forState:UIControlStateSelected];
    [fullBtn setImage:[UIImage imageNamed:@"sc_video_play_ns_enter_fs_btn"]
             forState:UIControlStateNormal];
    [fullBtn addTarget:self
                action:@selector(clickFullBtn:)
      forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:fullBtn];
    self.fullBtn = fullBtn;
    
    // 背景图
    UIImageView *bgImgView = [UIImageView new];
    bgImgView.clipsToBounds = YES;
    bgImgView.contentMode = UIViewContentModeScaleAspectFill;
    bgImgView.backgroundColor = [UIColor blackColor];
    [self addSubview:bgImgView];
    self.bgImgView = bgImgView;
    
    // 加载图
    UIActivityIndicatorView *activity = [UIActivityIndicatorView new];
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self addSubview:activity];
    self.activity = activity;
    
    // 加载失败提示
    UIView *errorView = [UIView new];
    errorView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.85];
    [self addSubview:errorView];
    self.errView = errorView;
    UILabel *errLab = [UILabel new];
    errLab.textColor = [UIColor whiteColor];
    errLab.textAlignment = NSTextAlignmentCenter;
    errLab.font = [UIFont systemFontOfSize:15];
    errLab.text = @"视频加载失败";
    [errorView addSubview:errLab];
    self.errLab = errLab;
    UIButton *errBtn = [UIButton new];
    errBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    errBtn.layer.borderWidth = 1.5;
    errBtn.layer.cornerRadius = 5;
    [errBtn setTitle:@"点击重试" forState:UIControlStateNormal];
    [errBtn addTarget:self action:@selector(clickReplyBtn) forControlEvents:UIControlEventTouchUpInside];
    [errorView addSubview:errBtn];
    self.errBtn = errBtn;
}

// 更新布局
- (void)updateFrame {
    self.coverView.frame = self.bounds;
    CGFloat width = self.coverView.frame.size.width;
    CGFloat height = self.coverView.frame.size.height;
    
    self.nameLab.text = self.name;
    self.backBtn.hidden = !self.isFullScreen;
    if (self.isFullScreen) {
        CGFloat backH = height * 0.15;
        CGFloat backW = backH * 1.1;
        self.backBtn.frame = CGRectMake(0, 0, backW, backH);
        CGFloat nameW = width - backW - backH * 0.5;
        self.nameLab.frame = CGRectMake(backW, 0, nameW, backH);
    } else {
        CGFloat nameX = height * 0.05;
        CGFloat nameW = width - 2 * nameX;
        CGFloat nameH =
        [self.nameLab.text boundingRectWithSize:CGSizeMake(nameW, MAXFLOAT)
                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                        attributes:@{NSFontAttributeName: self.nameLab.font}
                           context:nil].size.height + nameX;
        self.nameLab.frame = CGRectMake(nameX, 0, nameW, nameH);
    }
    self.upView.frame = CGRectMake(0, 0, width, self.nameLab.frame.size.height);
    self.upBgView.frame = self.upView.bounds;
    
    CGFloat playBtnWH = height * 0.5;
    CGFloat playBtnX = (width - playBtnWH) / 2;
    CGFloat playBtnY = (height - playBtnWH) / 2;
    self.playBtn.frame = CGRectMake(playBtnX, playBtnY, playBtnWH, playBtnWH);
    
    CGFloat bottomH = height * 0.15;
    CGFloat bottomY = height - bottomH;
    self.bottomView.frame = CGRectMake(0, bottomY, width, bottomH);
    self.bottomBgView.frame = self.bottomView.bounds;
    
    CGFloat timeW = bottomH;
    CGFloat tiemFont = timeW / 40 * 12;
    self.timeLab.font = [UIFont systemFontOfSize:tiemFont];
    self.timeLab.frame = CGRectMake(0, 0, timeW, bottomH);
    CGFloat fullW = bottomH * 0.9;
    CGFloat fullX = width - fullW;
    self.fullBtn.frame = CGRectMake(fullX, 0, fullW, bottomH);
    CGFloat totalW = bottomH;
    CGFloat totalX = fullX - totalW;
    self.totalLab.frame = CGRectMake(totalX, 0, totalW, bottomH);
    self.totalLab.font = self.timeLab.font;
    CGFloat sliderW = totalX - timeW;
    self.slider.frame = CGRectMake(timeW, 0, sliderW, bottomH);
    CGFloat pX = 3;
    self.cacheProgress.frame = CGRectMake(timeW+pX, 0, sliderW-2*pX, bottomH);
    self.cacheProgress.center = self.slider.center;
    
    self.activity.frame = self.playBtn.frame;
    
    self.errView.frame = self.bounds;
    CGFloat errLabH = height * 0.2;
    CGFloat errLabY = height * 0.3;
    CGFloat errFont = errLabH / 50 * 17;
    self.errLab.frame = CGRectMake(0, errLabY, width, errLabH);
    self.errLab.font = [UIFont systemFontOfSize:errFont];
    CGFloat errBtnH = height * 0.15;
    CGFloat errBtnW = errBtnH * 2.2;
    CGFloat errBtnX = (width - errBtnW) / 2;
    CGFloat errBtnY = errLabY + errLabH;
    self.errBtn.frame = CGRectMake(errBtnX, errBtnY, errBtnW, errBtnH);
    self.errBtn.titleLabel.font = self.errLab.font;
}

- (void)resetUIData {
    self.totalLab.text = @"00:00";
    self.timeLab.text = self.totalLab.text;
    self.slider.value = 0;
}

#pragma mark - 设置视频数据

// 设置视频数据
- (void)playWithViedeoUrl:(NSString *)videoUrl {
    if (!videoUrl) {
        return;
    }
    _videoUrl = videoUrl;
    
    [self removePlayer];
    [self resetUIData];
    [self updateFrame];
    
    // 获取播放内容
    self.playerItem = [self getPlayItemWithUrl:videoUrl];
    // 创建视频播放器
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    // 添加播放进度监听
    [self addProgressObserver];
    // 添加播放内容KVO监听
    [self addPlayerItemObserver];
    // 添加通知中心监听播放完成
    [self addNotificationToPlayerItem];
    
    // 初始化播放器图层对象
    [self initAVPlayerLayer];
    
    if (self.coverImage) {
        self.bgImgView.hidden = NO;
        self.bgImgView.frame = self.bounds;
        self.bgImgView.image = self.coverImage;
        [self bringSubviewToFront:self.bgImgView];
    }
    
    [self bringSubviewToFront:self.coverView];
    [self bringSubviewToFront:self.activity];
    [self bringSubviewToFront:self.errView];
    self.coverView.hidden = YES;
    self.errView.hidden = YES;
    
    [self.player play];
    [self.activity startAnimating];
}

// 初始化AVPlayerItem视频内容对象
- (AVPlayerItem *)getPlayItemWithUrl:(NSString *)videoUrl {
    // 编码文件名，以防含有中文，导致存储失败
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *urlStr = [videoUrl stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSURL *url = [NSURL URLWithString:urlStr];
    // 创建播放内容对象
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    return item;
}

// 初始化播放器图层对象
- (void)initAVPlayerLayer {
    // 创建视频播放器图层对象
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    // 尺寸大小
    layer.frame = self.bounds;
    // 视频填充模式
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    layer.backgroundColor = [UIColor blackColor].CGColor;
    // 添加进控件图层
    [self.layer addSublayer:layer];
    self.playerLayer = layer;
    self.layer.masksToBounds = YES;
}

#pragma mark - 通知中心

- (void)addNotificationToPlayerItem {
    // 添加通知中心监听视频播放完成
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(playerDidFinished:)
                   name:AVPlayerItemDidPlayToEndTimeNotification
                 object:self.player.currentItem];
    
    // 监听屏幕改变
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    [center addObserver:self
               selector:@selector(orientationChanged:)
                   name:UIDeviceOrientationDidChangeNotification
                 object:device];
}

// 播放完成
- (void)playerDidFinished:(NSNotification *)notification {
    [self switchFullScreen:NO turnRight:self.isTurnRight];
    
    self.playBtn.selected = NO;
    self.coverView.hidden = NO;
}

// 监听屏幕旋转
- (void)orientationChanged:(NSNotification *)note  {
    UIDeviceOrientation ori = [[UIDevice currentDevice] orientation];
    if (ori == UIDeviceOrientationPortrait) { // 屏幕变正
        [self switchFullScreen:NO turnRight:self.isTurnRight];
    } else if (ori == UIDeviceOrientationLandscapeLeft) { // 左
        [self switchFullScreen:YES turnRight:NO];
    } else if (ori == UIDeviceOrientationLandscapeRight) { // 右
        [self switchFullScreen:YES turnRight:YES];
    }
}

#pragma mark - KVO监听属性

// 添加KVO，监听播放状态和缓冲加载状况
- (void)addPlayerItemObserver {
    // 监控状态属性
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    // 监控缓冲加载情况属性
    [self.playerItem addObserver:self
                      forKeyPath:@"loadedTimeRanges"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
}

// 属性发生变化，KVO响应函数
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    // 状态发生改变
    if ([keyPath isEqualToString:@"status"]) {
        [self.activity stopAnimating];
        AVPlayerStatus status = [[change objectForKey:@"new"] integerValue];
        if (status == AVPlayerStatusReadyToPlay) {
            self.totalLab.text = [self timeFormatted:CMTimeGetSeconds(playerItem.duration)];
            self.bgImgView.hidden = YES;
        } else {
            self.errView.hidden = NO;
        }
    }
    // 缓冲区域变化
    else if ( [keyPath isEqualToString:@"loadedTimeRanges"] ) {
        NSArray *array = playerItem.loadedTimeRanges;
        // 已缓冲范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        NSTimeInterval totalDuration = CMTimeGetSeconds(playerItem.duration);
        self.cacheProgress.progress = totalBuffer / totalDuration;
    }
}

// 进度监听
- (void)addProgressObserver {
    __weak typeof(self) weakSelf = self;
    AVPlayerItem *item = self.player.currentItem;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0)
                                              queue:dispatch_get_main_queue()
                                         usingBlock:^(CMTime time) {
         // CMTime是表示视频时间信息的结构体，包含视频时间点、每秒帧数等信息
         // 获取当前播放到的秒数
         float current = CMTimeGetSeconds(time);
         // 获取视频总播放秒数
         float total = CMTimeGetSeconds(item.duration);
         if (current && !weakSelf.activity.isAnimating) {
             weakSelf.slider.value = current/total;
             weakSelf.timeLab.text = [weakSelf timeFormatted:current];
         }
     }];
}

#pragma mark - UI 事件处理

// 返回按钮
- (void)clickBackBtn {
    [self switchFullScreen:NO turnRight:self.isTurnRight];
}

// 播放暂停
- (void)clickPlayBtn:(UIButton *)btn {
    btn.selected = !btn.selected;

    if (self.slider.value == 1) { // 重播
        [self playWithViedeoUrl:self.videoUrl];
    } else { // 播放暂停
        if (btn.selected) {
            [self.player play];
        } else {
            [self.player pause];
        }
    }
}

// 进度切换
- (void)sliderChange:(UISlider *)slider {
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * slider.value;
    self.timeLab.text = [self timeFormatted:currentTime];
    
    [self.player seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC)
            toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimeZero];
    
    [self addTimer];
}

// 全屏切换
- (void)clickFullBtn:(UIButton *)btn {
    [self switchFullScreen:!btn.selected turnRight:NO];
}

// 点击屏幕
- (void)tapPlayerView {
    if (!self.errView.hidden) {
        return;
    }
    
    self.coverView.hidden = !self.coverView.hidden;
    if (!self.coverView.hidden) {
        [self addTimer];
    } else {
        [self removeTimer];
    }
}

// 点击重试
- (void)clickReplyBtn {
    [self playWithViedeoUrl:self.videoUrl];
}

#pragma mark - 切换屏幕

// 切换屏幕
- (void)switchFullScreen:(BOOL)isFull turnRight:(BOOL)turnRight {
    // 正在切换中
    if (self.isChanging) {
        return;
    }
    // 没有变化
    if (self.isFullScreen == isFull && self.isTurnRight == turnRight) {
        return;
    }
    // 小屏不处理屏幕旋转
    if (self.isFullScreen == isFull && !isFull) {
        return;
    }
    
    if (self.isTurnRight != turnRight) {
        self.isTurnRight = turnRight;
    }
    
    // 全屏与小屏幕的切换
    if (self.isFullScreen != isFull) {
        self.isFullScreen = isFull;
        self.fullBtn.selected = isFull;
        self.isChanging = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:isFull];
        
        if (isFull) { // 全屏
            self.originF = self.frame;
            UIViewController *vc = [self.delegate getpresentViewController];
            [vc presentViewController:self.fullVC animated:NO completion:^{
                [self.fullVC.view addSubview:self];
                UIView *playerSuper = [self.delegate getPlayerSuperView];
                self.frame = [playerSuper convertRect:self.originF toView:self.fullVC.view];
                [self updateFrame];
                [UIView animateWithDuration:.2 animations:^{
                    CGFloat angle = turnRight ? (-M_PI / 2) : (M_PI / 2);
                    self.transform = CGAffineTransformMakeRotation(angle);
                    self.frame = self.fullVC.view.bounds;
                    self.playerLayer.frame = self.bounds;
                    [self updateFrame];
                } completion:^(BOOL finished) {
                    self.isChanging = NO;
                }];
            }];
        } else { // 小屏
            UIView *playerSuper = [self.delegate getPlayerSuperView];
            [UIView animateWithDuration:.2 animations:^{
                self.transform = CGAffineTransformIdentity;
                self.frame = [playerSuper convertRect:self.originF toView:self.fullVC.view];
                self.playerLayer.frame = self.bounds;
                [self updateFrame];
            } completion:^(BOOL finished) {
                [self.fullVC dismissViewControllerAnimated:NO completion:^{
                    [playerSuper addSubview:self];
                    self.frame = self.originF;
                    self.playerLayer.frame = self.bounds;
                    [self updateFrame];
                    self.isChanging = NO;
                }];
            }];
        }
    }
    // 全屏的左右切换
    else {
        CGFloat angle = turnRight? (-M_PI / 2) : (M_PI / 2);
        self.transform = CGAffineTransformMakeRotation(angle);
    }
}

#pragma mark - 定时器

- (void)addTimer {
    [self removeTimer];
    self.showTimer = [NSTimer timerWithTimeInterval:4
                                             target:self
                                           selector:@selector(timerOver)
                                           userInfo:nil
                                            repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.showTimer
                                 forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    if (self.showTimer) {
        [self.showTimer invalidate];
        self.showTimer = nil;
    }
}

- (void)timerOver {
    self.coverView.hidden = YES;
}

#pragma mark - 销毁

- (void)removePlayer {
    if (self.player) {
        [self.player pause];
        [self.player.currentItem cancelPendingSeeks];
        [self.player.currentItem.asset cancelLoading];
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        self.playerItem = nil;
        self.player = nil;
        self.playerLayer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    [self removeTimer];
}

- (void)dealloc {
    [self removePlayer];
    NSLog(@"销毁视频播放器");
}

#pragma mark - 私有方法

- (NSString *)timeFormatted:(float)totalSeconds {
    int min = floor(totalSeconds/60);
    int sec = round(totalSeconds - min * 60);
    return [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

- (UIViewController *)fullVC {
    if (!_fullVC) {
        _fullVC = [UIViewController new];
        _fullVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return _fullVC;
}

@end
