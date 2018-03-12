
//  RNDemo
//
//  Created by hupengwei on 2018/3/12.
//  Copyright © 2018年 Facebook. All rights reserved.
//
#import "SelVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "SelPlayerConfiguration.h"
#import "SelPlaybackControls.h"
#import "HSDownloadManager.h"
#import "PlayInfoModel.h"
//#import ""<SDWebImage/UIImageView+WebCache.h>""
//#import <SDWebImage/UIButton+WebCache.h>
//#import <SDWebImage/SDWebImageCompat.h>
#import "SDWebImageManager.h"
#define  VideoUrl [[NSUserDefaults standardUserDefaults] objectForKey:@"VideoUrl"]
#define ArrPlayInfoList  [[NSUserDefaults standardUserDefaults] objectForKey:@"PlayInfoList"]

/** 播放器的播放状态 */
typedef NS_ENUM(NSInteger, SelVideoPlayerState) {
    SelVideoPlayerStateFailed,     // 播放失败
    SelVideoPlayerStateBuffering,  // 缓冲中
    SelVideoPlayerStatePlaying,    // 播放中
    SelVideoPlayerStatePause,      // 暂停播放
};


typedef NS_ENUM(NSUInteger, MoveDirection) {
  MoveDirection_none = 0,
  MoveDirection_up,
  MoveDirection_down,
  MoveDirection_left,
  MoveDirection_right
};

//播放状态用于快进快退
typedef NS_ENUM(NSUInteger, VideoPlayerStatus) {
  videoPlayer_unknown,
  videoPlayer_readyToPlay,
  videoPlayer_playing,
  videoPlayer_pause,
  videoPlayer_loading,
  videoPlayer_playEnd,
  videoPlayer_playFailed
};


@interface SelVideoPlayer()<SelPlaybackControlsDelegate>

@property (nonatomic,strong) NSArray *videoOrAudioArr;

@property (nonatomic,strong) NSArray *cacheArr;

@property (nonatomic,strong) NSMutableArray *clarityArr;
/// 快进退的总时长
@property (nonatomic, assign) CGFloat sumTime;
//几倍速播放数组
@property (nonatomic,strong) NSArray *rates;
/** 播放状态 */
@property (nonatomic, assign , readonly) VideoPlayerStatus playStatus;
/** 开始移动 */
@property (nonatomic, assign) CGPoint startPoint;
/** 移动方向 */
@property (nonatomic, assign) MoveDirection moveDirection;
/** 播放器 */
@property (nonatomic, strong) AVPlayerItem *playerItem;
/** 播放器item */
@property (nonatomic, strong) AVPlayer *player;
/** 播放器layer */
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
/** 是否播放完毕 */
@property (nonatomic, assign) BOOL isFinish;
/** 是否处于全屏状态 */
@property (nonatomic, assign) BOOL isFullScreen;
/** 播放器配置信息 */
@property (nonatomic, strong) SelPlayerConfiguration *playerConfiguration;
/** 视频播放控制面板 */
@property (nonatomic, strong) SelPlaybackControls *playbackControls;
/** 非全屏状态下播放器 superview */
@property (nonatomic, strong) UIView *originalSuperview;
/** 非全屏状态下播放器 frame */
@property (nonatomic, assign) CGRect originalRect;
/** 时间监听器 */
@property (nonatomic, strong) id timeObserve;
/** 播放器的播放状态 */
@property (nonatomic, assign) SelVideoPlayerState playerState;
/** 是否结束播放 */
@property (nonatomic, assign) BOOL playDidEnd;
/** 亮度调节 */
@property (nonatomic, assign) CGFloat brightness;

/** 系统音量 */
@property (nonatomic, assign) CGFloat sysVolume;
@end

@implementation SelVideoPlayer

-(NSMutableArray *)clarityArr{
  
  if (_clarityArr == nil) {
    _clarityArr = [NSMutableArray arrayWithCapacity:0];
  }
  return _clarityArr;
}

- (ZXVideoPlayerTimeIndicatorView *)timeIndicatorView
{
  if (!_timeIndicatorView) {
    _timeIndicatorView = [[ZXVideoPlayerTimeIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kVideoTimeIndicatorViewSide, kVideoTimeIndicatorViewSide)];
    _timeIndicatorView.center = self.center;
  }
  return _timeIndicatorView;
}

/**
 初始化播放器
 @param configuration 播放器配置信息
 */
- (instancetype)initWithFrame:(CGRect)frame configuration:(SelPlayerConfiguration *)configuration
{
    self = [super initWithFrame:frame];
    if (self) {
        _playerConfiguration = configuration;
        [self _setupPlayer];
        [self _setupPlayControls];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterBackground:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterPlayground:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

/** 屏幕翻转监听事件 */
- (void)orientationChanged:(NSNotification *)notify
{
    if (_playerConfiguration.shouldAutorotate) {
        [self orientationAspect];
    }
}

/** 根据屏幕旋转方向改变当前视频屏幕状态 */
- (void)orientationAspect
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
  if([[[NSUserDefaults standardUserDefaults] objectForKey:@"screenDirection"] isEqualToString:@"YES"]){
    
    if (orientation == UIDeviceOrientationLandscapeLeft){
      if (!_isFullScreen){
        [self _videoZoomInWithDirection:UIInterfaceOrientationLandscapeRight];
      }
    }
    else if (orientation == UIDeviceOrientationLandscapeRight){
      if (!_isFullScreen){
        [self _videoZoomInWithDirection:UIInterfaceOrientationLandscapeLeft];
      }
    }
    else if(orientation == UIDeviceOrientationPortrait){
      if (_isFullScreen){
        [self _videoZoomOut];
        
      }
    }
  }
  
}

/**
 视频放大全屏幕
 @param orientation 旋转方向
 */
- (void)_videoZoomInWithDirection:(UIInterfaceOrientation)orientation
{
    _originalSuperview = self.superview;
    _originalRect = self.frame;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    
    [UIView animateWithDuration:duration animations:^{
        if (orientation == UIInterfaceOrientationLandscapeLeft){
            self.transform = CGAffineTransformMakeRotation(-M_PI/2);

        }else if (orientation == UIInterfaceOrientationLandscapeRight) {
            self.transform = CGAffineTransformMakeRotation(M_PI/2);
        
        }
      
      
    }completion:^(BOOL finished) {
      
    }];
    
    self.frame = keyWindow.bounds;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.isFullScreen = YES;
    //显示或隐藏状态栏
    [self.playbackControls _showOrHideStatusBar];
  
  self.timeIndicatorView.center = CGPointMake(self.center.y ,self.center.x);
}

/** 视频退出全屏幕 */
- (void)_videoZoomOut
{
    //退出全屏时强制取消隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    [UIView animateWithDuration:duration animations:^{
        self.transform = CGAffineTransformMakeRotation(0);
    }completion:^(BOOL finished) {
        
    }];
    self.frame = _originalRect;
    [_originalSuperview addSubview:self];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.timeIndicatorView.center = self.center;
    self.isFullScreen = NO;
}

/** 播放视频 */
- (void)_playVideo
{
  [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"bannerImage"];
//  self.playbackControls.coverImageView.hidden = YES
    if (self.playDidEnd && self.playbackControls.videoSlider.value == 1.0) {
        //若播放已结束重新播放
        [self _replayVideo];
    }else
    {
        [_player play];
        [self.playbackControls _setPlayButtonSelect:YES];
        if (self.playerState == SelVideoPlayerStatePause) {
            self.playerState = SelVideoPlayerStatePlaying;
        }
    }
}



/** 暂停播放 */
- (void)_pauseVideo
{
    [_player pause];
    [self.playbackControls _setPlayButtonSelect:NO];
    if (self.playerState == SelVideoPlayerStatePlaying) {
        self.playerState = SelVideoPlayerStatePause;
    }
}

/** 重新播放 */
- (void)_replayVideo
{
    self.playDidEnd = NO;
    [_player seekToTime:CMTimeMake(0, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self _playVideo];
}

/** 监听播放器事件 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        // 计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [_playbackControls _setPlayerProgress:timeInterval / totalDuration];
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        
        // 当无缓冲视频数据时
        if (self.playerItem.playbackBufferEmpty) {
            self.playerState = SelVideoPlayerStateBuffering;
            [self bufferingSomeSecond];
        }
    }
    else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        // 当视频缓冲好时
        if (self.playerItem.playbackLikelyToKeepUp && self.playerState == SelVideoPlayerStateBuffering){
            self.playerState = SelVideoPlayerStatePlaying;
        }
    }
    else if ([keyPath isEqualToString:@"status"])
    {
        if (self.player.currentItem.status == AVPlayerStatusReadyToPlay) {
            [self setNeedsLayout];
            [self layoutIfNeeded];
            [self.layer insertSublayer:_playerLayer atIndex:0];
            self.playerState = SelVideoPlayerStatePlaying;
        }
        else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
            self.playerState = SelVideoPlayerStateFailed;
        }
    }
}

/**
 *  计算缓冲进度
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - 缓冲较差时候

/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond {
    self.playerState = SelVideoPlayerStateBuffering;
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    __block BOOL isBuffering = NO;
    if (isBuffering) return;
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self _pauseVideo];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self _playVideo];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.playerItem.isPlaybackLikelyToKeepUp)
        {
            [self bufferingSomeSecond];
        }
        
    });
}

/** 应用进入后台 */
- (void)appDidEnterBackground:(NSNotification *)notify
{
    [self _pauseVideo];
  //记录上次播放的时间

  [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",self.playbackControls.videoSlider.value*self.playbackControls.totalTime] forKey:@"playTime"];
}

/** 应用进入前台 */
- (void)appDidEnterPlayground:(NSNotification *)notify
{
  NSString* time = [[NSUserDefaults standardUserDefaults] objectForKey:@"playTime"];
  [self _pauseVideo];
  if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"bannerImage"] isEqualToString:@"YES"]) {
    self.playbackControls.coverImageView.hidden = NO;

  }
  if (time != nil) {
    [self.player seekToTime:CMTimeMakeWithSeconds([time floatValue], NSEC_PER_SEC) completionHandler:^(BOOL finished) {

    }];
  }



}

/** 视频播放结束事件监听 */
- (void)videoDidPlayToEnd:(NSNotification *)notify
{
    self.playDidEnd = YES;
    if (_playerConfiguration.repeatPlay) {
        [self _replayVideo];
    }else
    {
        [self _pauseVideo];
    }
}

/** 创建播放器 以及控制面板*/
- (void)_setupPlayer
{
    self.playerItem = [AVPlayerItem playerItemWithURL:_playerConfiguration.sourceUrl];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self _setVideoGravity:_playerConfiguration.videoGravity];
    self.backgroundColor = [UIColor blackColor];
    [self createTimer];
    
    if (_playerConfiguration.shouldAutoPlay) {
        [self _playVideo];
    }
}


/** 添加播放器控制面板 */
- (void)_setupPlayControls
{
    [self addSubview:self.playbackControls];
}


/** 创建定时器 */
- (void)createTimer {
    __weak typeof(self) weakSelf = self;
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time){
        AVPlayerItem *currentItem = weakSelf.playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
            CGFloat totalTime = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
            CGFloat value = CMTimeGetSeconds([currentItem currentTime]) / totalTime;
            [weakSelf.playbackControls _setPlaybackControlsWithPlayTime:currentTime totalTime:totalTime sliderValue:value];
        }
    }];
}

/**
 配置playerLayer拉伸方式
 @param videoGravity 拉伸方式
 */
- (void)_setVideoGravity:(SelVideoGravity)videoGravity
{
    NSString *fillMode = AVLayerVideoGravityResize;
    switch (videoGravity) {
        case SelVideoGravityResize:
            fillMode = AVLayerVideoGravityResize;
            break;
        case SelVideoGravityResizeAspect:
            fillMode = AVLayerVideoGravityResizeAspect;
            break;
        case SelVideoGravityResizeAspectFill:
            fillMode = AVLayerVideoGravityResizeAspectFill;
            break;
        default:
            break;
    }
    _playerLayer.videoGravity = fillMode;
}


/**
 @param playerState 播放器的播放状态
 */
- (void)setPlayerState:(SelVideoPlayerState)playerState
{
    _playerState = playerState;
    switch (_playerState) {
        case SelVideoPlayerStateBuffering:
        {
            [_playbackControls _activityIndicatorViewShow:YES];
        }
            break;
        case SelVideoPlayerStatePlaying:
        {
            [_playbackControls _activityIndicatorViewShow:NO];
        }
            break;
        case SelVideoPlayerStateFailed:
        {
            [_playbackControls _activityIndicatorViewShow:NO];
            [_playbackControls _retryButtonShow:YES];
        }
            break;
        default:
            break;
    }
}

/** 改变全屏切换按钮状态 */
- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    _playbackControls.isFullScreen = isFullScreen;

}


/** 根据playerItem，来添加移除观察者 */
- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem == playerItem) {return;}
    
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _playerItem = playerItem;
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}

/** 播放器控制面板 */
- (SelPlaybackControls *)playbackControls
{
    if (!_playbackControls) {
        _playbackControls = [[SelPlaybackControls alloc]init];
        _playbackControls.delegate = self;
        _playbackControls.hideInterval = _playerConfiguration.hideControlsInterval;
        _playbackControls.statusBarHideState = _playerConfiguration.statusBarHideState;
    }
    return _playbackControls;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
    self.playbackControls.frame = self.bounds;
}

/** 释放播放器 */
- (void)_deallocPlayer
{
    [self _pauseVideo];
    
    [self.playerLayer removeFromSuperlayer];
    [self removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

/** 释放Self */
- (void)dealloc
{
    self.playerItem = nil;
    [self.playbackControls _playerCancelAutoHidePlaybackControls];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];
        self.timeObserve = nil;
    }
    self.playerLayer = nil;
    self.player = nil;
}

#pragma mark 播放器控制面板代理
/**
 播放按钮点击事件
 @param selected 播放按钮选中状态
 */
- (void)playButtonAction:(BOOL)selected
{
    if (selected){
        [self _pauseVideo];
    }else{
        [self _playVideo];
    }
}

/** 全屏切换按钮点击事件 */
- (void)fullScreenButtonAction
{
    if (!_isFullScreen) {
        self.timeIndicatorView.center = self.center;

        [self _videoZoomInWithDirection:UIInterfaceOrientationLandscapeRight];
    }else
    {
        [self _videoZoomOut];
        self.timeIndicatorView.center = [[[UIApplication sharedApplication].delegate window] center];

    }

}

//几倍速播放切换
-(void)playRateButtonAction{
  
  self.rates = @[@(1), @(1.5),@(2)];
  __block float nextRate = [[self.rates firstObject] floatValue];
  [self.rates enumerateObjectsUsingBlock:^(NSNumber *rate, NSUInteger idx, BOOL *stop) {
    if ([rate floatValue] > self.player.rate) {
      nextRate = [rate floatValue];
      [self.playbackControls.playRateBtn setTitle:[NSString stringWithFormat:@"%.1fX",nextRate] forState:UIControlStateNormal];
      *stop = YES;
      self.player.rate = nextRate;
    }
  }];
}

//是否缓存切换
-(void)playCachButtonAction{
  self.cacheArr = @[@"缓存",@"不缓存"];
  if([self.playbackControls.playCacheBtn.titleLabel.text isEqualToString:self.cacheArr.firstObject]){
    
    [self.playbackControls.playCacheBtn setTitle:self.cacheArr.lastObject forState:UIControlStateNormal];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"VideoUrl"] length] > 0) {
      [[HSDownloadManager sharedInstance] pause:[[NSUserDefaults standardUserDefaults] objectForKey:@"VideoUrl"]];

    }
  }else{
    
    [self.playbackControls.playCacheBtn setTitle:self.cacheArr.firstObject forState:UIControlStateNormal];
    [self downVideoUrl:[NSString stringWithFormat:@"%@",_playerConfiguration.sourceUrl]];

  }
  
}

//封面被点击
-(void)coverClickAction{
  
    self.playbackControls.coverImageView.hidden = YES;
    [self _playVideo ];
}

//锁屏
-(void)lockButtonAction{
  
  if ( [[[NSUserDefaults standardUserDefaults] objectForKey:@"screenDirection"] isEqualToString:@"YES"]) {
    [self.playbackControls.lockButton setImage:[UIImage imageNamed:@"zx-video-player-lock"] forState:UIControlStateNormal];
     [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"screenDirection"];
  }else{
    [self.playbackControls.lockButton setImage:[UIImage imageNamed:@"zx-video-player-unlock"] forState:UIControlStateNormal];

    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"screenDirection"];

  }
}

//视频和音频的切换
-(void)audioOrVideoBtnClickAction{
  
  self.videoOrAudioArr = @[@"视频",@"音频"];
  if([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"audioOrVideo"]]  isEqualToString:self.videoOrAudioArr.firstObject]){
    
    [[NSUserDefaults standardUserDefaults] setObject:@"音频" forKey:@"audioOrVideo"];
    self.playerLayer.hidden = YES;
  }else{
     self.playerLayer.hidden = NO;


    [[NSUserDefaults standardUserDefaults] setObject:@"视频" forKey:@"audioOrVideo"];

  }
  [self.playbackControls.audioOrVideoBtn setTitle:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"audioOrVideo"]] forState:UIControlStateNormal];

}


//清晰度切换
-(void)playClarityBtnAction{
  [self.clarityArr removeAllObjects];
  NSArray *arr =  ArrPlayInfoList;
  for (int i = 0; i < arr.count; i++) {
    PlayInfoModel *model = [[PlayInfoModel alloc] init];
    model.Definition = [arr[i] objectForKey:@"Definition"];
    model.PlayURL = [arr[i] objectForKey:@"PlayURL"];

    [self.clarityArr addObject:model];
  }

  for (int i = 0; i < self.clarityArr.count; i++) {
    if([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"clarity"]] isEqualToString:[self.clarityArr[i] Definition]]){

      if([[NSString stringWithFormat:@"%@",[self.clarityArr[i] Definition]] isEqualToString:[self.clarityArr.lastObject Definition]]){

        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",[self.clarityArr[0] Definition]] forKey:@"clarity"];
        
        [self.playbackControls.playClarityBtn setTitle:[self.clarityArr[0] Definition] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:[self.clarityArr[0] PlayURL] forKey:@"VideoUrl"];

        
      }else{
        
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",[self.clarityArr[i+1] Definition]] forKey:@"clarity"];
        [self.playbackControls.playClarityBtn setTitle:[self.clarityArr[i+1] Definition] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:[self.clarityArr[i+1] PlayURL] forKey:@"VideoUrl"];


      }
      break;



    }
  }
  if ([[[HSDownloadManager sharedInstance] pathSourceFile:VideoUrl] length] > 0) {//下载完成本地播放
    
      self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:[[HSDownloadManager sharedInstance] pathSourceFile:VideoUrl] ]];
      [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
      [self.player seekToTime:CMTimeMakeWithSeconds(self.playbackControls.videoSlider.value*self.playbackControls.totalTime, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [self _playVideo];
      }];
  }else{//未下载完成，url播放
    
          if([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"clarity"]] isEqualToString:@"普清"]){
            
            [self _pauseVideo];
            _playerConfiguration.sourceUrl = [NSURL URLWithString:VideoUrl];
            self.playerItem = [AVPlayerItem playerItemWithURL:_playerConfiguration.sourceUrl];
            
            [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
            [self.player seekToTime:CMTimeMakeWithSeconds(self.playbackControls.videoSlider.value*self.playbackControls.totalTime, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
              [self _playVideo];
            }];
            
            
          }else if([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"clarity"]] isEqualToString:@"高清"]){
            
            [self _pauseVideo];
            _playerConfiguration.sourceUrl = [NSURL URLWithString:VideoUrl];
            self.playerItem = [AVPlayerItem playerItemWithURL:_playerConfiguration.sourceUrl];
            [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
            [self.player seekToTime:CMTimeMakeWithSeconds(self.playbackControls.videoSlider.value*self.playbackControls.totalTime, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
              [self _playVideo];
            }];
            
          }else{
            
            _playerConfiguration.sourceUrl = [NSURL URLWithString:VideoUrl];
            [self _pauseVideo];
            self.playerItem = [AVPlayerItem playerItemWithURL:_playerConfiguration.sourceUrl];
            [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
            [self.player seekToTime:CMTimeMakeWithSeconds(self.playbackControls.videoSlider.value*self.playbackControls.totalTime, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
              [self _playVideo];
            }];
    }
  }


 


  
}




/** 控制面板单击事件 */
- (void)tapGesture
{
    [_playbackControls _playerShowOrHidePlaybackControls];
}

/** 控制面板双击事件 */
- (void)doubleTapGesture
{
    if (_playerConfiguration.supportedDoubleTap) {
        if (self.playerState == SelVideoPlayerStatePlaying) {
            [self _pauseVideo];
        }
        else if (self.playerState == SelVideoPlayerStatePause)
        {
            [self _playVideo];
        }
    }
}

/** 重新加载视频 */
- (void)retryButtonAction
{
    [_playbackControls _retryButtonShow:NO];
    [_playbackControls _activityIndicatorViewShow:YES];
    [self _setupPlayer];
    [self _playVideo];
}

#pragma mark 滑杆拖动代理
/** 开始拖动 */
-(void)videoSliderTouchBegan:(SelVideoSlider *)slider{
    [self _pauseVideo];
    [_playbackControls _playerCancelAutoHidePlaybackControls];
}
/** 结束拖动 */
-(void)videoSliderTouchEnded:(SelVideoSlider *)slider{

    if (slider.value != 1) {
        self.playDidEnd = NO;
    }
    if (!self.playerItem.isPlaybackLikelyToKeepUp) {
        [self bufferingSomeSecond];
    }else{
        //继续播放
        [self _playVideo];
    }
    [_playbackControls _playerAutoHidePlaybackControls];
}

/** 拖拽中 */
-(void)videoSliderValueChanged:(SelVideoSlider *)slider{
    CGFloat totalTime = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
    CGFloat dragedSeconds = totalTime * slider.value;
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    [_player seekToTime:dragedCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    NSInteger currentTime = (NSInteger)CMTimeGetSeconds(dragedCMTime);
    [_playbackControls _setPlaybackControlsWithPlayTime:currentTime totalTime:totalTime sliderValue:slider.value];
}


#pragma mark - 触摸事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  
  [super touchesBegan:touches withEvent:event];
  UITouch * touch = [touches anyObject];
  self.startPoint = [touch locationInView:self];
  self.sysVolume = self.playbackControls.volumeSlider.value;
  self.brightness = [UIScreen mainScreen].brightness;
//  self.currentTime = self.bottomView.progressValue;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  
  [super touchesMoved:touches withEvent:event];
  
  //状态未知时不可拖动 如（未进入准备状态）
//  if(self.playStatus == videoPlayer_unknown ||
//     self.playStatus == videoPlayer_playFailed ||
//     self.playStatus == videoPlayer_playEnd ||
//     self.playStatus == videoPlayer_loading){
//    return;
//  }

//  [self setSecondsForBottom:maxSecondsForBottom];
  UITouch * touch = [touches anyObject];
  CGPoint movePoint = [touch locationInView:self];
//
  CGFloat subX = movePoint.x - self.startPoint.x;
  CGFloat subY = movePoint.y - self.startPoint.y;
  CGFloat width  = self.frame.size.width;
  CGFloat height = self.frame.size.height;

  BOOL startInLeft = movePoint.x < width/2.f;


//  if (self.moveDirection == MoveDirection_none) {
    if (subX >= 30) {
      self.moveDirection = MoveDirection_right;
    }else if(subX <= -30){
      self.moveDirection = MoveDirection_left;
    }else if (subY >= 30){
      self.moveDirection = MoveDirection_down;
    }else if (subY <= -30){
      self.moveDirection = MoveDirection_up;
    }
//  }

  
 if (self.moveDirection == MoveDirection_right) {//快进
      self.timeIndicatorView.hidden = NO;

        [self _pauseVideo];
        self.timeIndicatorView.playState = ZXTimeIndicatorPlayStateFastForward;
       if(self.playbackControls.videoSlider.value>0){
         
          [self.timeIndicatorView.arrowImageView setImage:[UIImage imageNamed:@"zx-video-player-fastForward"]];
       }
   
         self.playbackControls.videoSlider.value = self.playbackControls.videoSlider.value+1/(self.playbackControls.totalTime*8);
   
        self.timeIndicatorView.labelText =   [NSString stringWithFormat:@"%@/%@",self.playbackControls.playTimeLabel.text,self.playbackControls.totalTimeLabel.text] ;

        [self.playbackControls _setPlaybackControlsWithPlayTime:self.playbackControls.videoSlider.value*self.playbackControls.totalTime totalTime:self.playbackControls.totalTime sliderValue:self.playbackControls.videoSlider.value];

        [self.player seekToTime:CMTimeMakeWithSeconds(self.playbackControls.videoSlider.value*self.playbackControls.totalTime, NSEC_PER_SEC) completionHandler:^(BOOL finished) {

        }];
  
  }else if(self.moveDirection == MoveDirection_left){//快退
        self.timeIndicatorView.hidden = NO;
        [self _pauseVideo];
        self.timeIndicatorView.playState = ZXTimeIndicatorPlayStateRewind;
        if(self.playbackControls.videoSlider.value>0){
          
          [self.timeIndicatorView.arrowImageView setImage:[UIImage imageNamed:@"zx-video-player-rewind"]];
        }
        self.playbackControls.videoSlider.value = self.playbackControls.videoSlider.value-1/(self.playbackControls.totalTime*8);
        if(self.playbackControls.videoSlider.value<=0){
          
          self.playbackControls.videoSlider.value=0;
        }
        self.timeIndicatorView.labelText =   [NSString stringWithFormat:@"%@/%@",self.playbackControls.playTimeLabel.text,self.playbackControls.totalTimeLabel.text] ;
    
    
        [self.playbackControls _setPlaybackControlsWithPlayTime:self.playbackControls.videoSlider.value*self.playbackControls.totalTime totalTime:self.playbackControls.totalTime sliderValue:self.playbackControls.videoSlider.value];
        [self.player seekToTime:CMTimeMakeWithSeconds(self.playbackControls.videoSlider.value*self.playbackControls.totalTime, NSEC_PER_SEC) completionHandler:^(BOOL finished) {

          
        }];
    
  }else if (self.moveDirection == MoveDirection_up || self.moveDirection == MoveDirection_down){
    [self _playVideo];
    if (startInLeft) {//上调亮度
      self.timeIndicatorView.hidden = YES;

      [UIScreen mainScreen].brightness = self.brightness - subY/height;//10;
    }else{//上调音量
      self.timeIndicatorView.hidden = YES;

      self.playbackControls.volumeSlider.value = self.sysVolume - subY/height;//10;
    }
  }

  



//    self.timeIndicatorView.hidden = NO;
    [self addSubview: self.timeIndicatorView];
}


//资源下载
-(void)downVideoUrl:(NSString *)url{
  
  [[HSDownloadManager sharedInstance] download:url progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
    dispatch_async(dispatch_get_main_queue(), ^{

    });
  } state:^(DownloadState state) {
    dispatch_async(dispatch_get_main_queue(), ^{
    });
  }];
}

@end
