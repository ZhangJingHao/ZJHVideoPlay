# iOS视频播放、AVFoundation使用

点击下载 [Demo](https://github.com/ZhangJingHao/ZJHVideoPlay)

![视频播放demo.gif](https://upload-images.jianshu.io/upload_images/2120486-e72956ad9845af4d.gif?imageMogr2/auto-orient/strip)

###一、AVPlayer简介

AVPlayer存在于AVFoundation中，它更加接近于底层，所以灵活性极高。
AVPlayer本身并不能显示视频，如果AVPlayer要显示必须创建一个播放器图层AVPlayerLayer用于展示，该播放器图层继承于CALayer。

#####AVPlayer视频播放使用步骤：

1、创建视频资源地址URL，可以是网络URL
2、通过URL创建视频内容对象AVPlayerItem，一个视频对应一个AVPlayerItem
3、创建AVPlayer视频播放器对象，需要一个AVPlayerItem进行初始化
4、创建AVPlayerLayer播放图层对象，添加到显示视图上去
5、播放器播放play，播放器暂停pause
6、添加通知中心监听视频播放完成，使用KVO监听播放内容的属性变化
7、进度条监听是调用AVPlayer的对象方法

###二、设置视频数据

```
// 设置视频数据
- (void)playWithViedeoUrl:(NSString *)videoUrl {
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
}
```

初始化AVPlayerItem视频内容对象。AVPlayerItem：该类主要是用于管理资源对象，提供播放数据源，旨在表示由AVPlayer播放的资产的呈现状态，并允许观察该状态，它控制着视频从创建到销毁的诸多状态。AVPlayerItem提供了AVPlayer播放需要的媒体文件，时间、状态、文件大小等信息，是AVPlayer媒体文件的载体。

```
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
```

初始化播放器图层对象。AVPlayerLayer是AVFoundation的底层图层。拥有AVPlayer属性，可以播放媒体文件。

```
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
```

###三、监听视频数据

通过KVO监听AVPlayerItem的属性`status`获取状态改，来判断视频加载成功或失败。监听AVPlayerItem的属性`loadedTimeRanges`，可以实时知道当前视频的进度缓冲。

```
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
```

AVPlayer提供了一个Block回调，当播放进度改变的时候回主动回调该Block，但是当视频卡顿的时候是不会回调的，可以在该回调里面处理进度条以及播放时间的刷新

```
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

```

###四、销毁视频

视频播放完，需要销毁视频，包括通知及KVO等

```
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
```

<br>
 [Demo](https://github.com/ZhangJingHao/ZJHVideoPlay) 中有具体的使用，仿照网易、今日头条短视频的播放。包括视频的全屏的切换、播放暂停、进度设置等基本操作。


