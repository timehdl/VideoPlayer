//
//  SelBackControl.m
//  SelVideoPlayer
//
//  Created by zhuku on 2018/1/26.
//  Copyright © 2018年 selwyn. All rights reserved.
//

#import "SelPlaybackControls.h"
#import <Masonry.h>
#import <MediaPlayer/MediaPlayer.h>

static const CGFloat PlaybackControlsAutoHideTimeInterval = 0.3f;
@interface SelPlaybackControls()

/** 控制面板是否显示 */
@property (nonatomic, assign) BOOL isShowing;
/** 加载指示器是否显示 */
@property (nonatomic, assign) BOOL isActivityShowing;
/** 重新加载是否显示 */
@property (nonatomic, assign) BOOL isRetryShowing;


@end

@implementation SelPlaybackControls

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}


/** 重置控制面板 */
- (void)_resetPlaybackControls
{
    self.bottomControlsBar.alpha = 0;
    self.isShowing = NO;
    [self _activityIndicatorViewShow:YES];
}

/**
 设置视频时间显示以及滑杆状态
 @param playTime 当前播放时间
 @param totalTime 视频总时间
 @param sliderValue 滑杆滑动值
 */
- (void)_setPlaybackControlsWithPlayTime:(NSInteger)playTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)sliderValue
{
    self.totalTime = totalTime;
    self.playTime = playTime;
    //当前时长进度progress
    NSInteger proMin = playTime / 60;//当前秒
    NSInteger proSec = playTime % 60;//当前分钟
    //duration 总时长
    NSInteger durMin = totalTime / 60;//总秒
    NSInteger durSec = totalTime % 60;//总分钟
    
    //更新当前播放时间
    self.videoSlider.value = sliderValue;
    self.playTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    //更新总时间
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
}

/** 显示或隐藏加载指示器 */
- (void)_activityIndicatorViewShow:(BOOL)show
{
    self.isActivityShowing = show;
    if (show) {
        self.playButton.hidden = YES;
        [self.activityIndicatorView startAnimating];
    }
    else
    {
        if (self.isShowing) {
            self.playButton.hidden = NO;
        }
        [self.activityIndicatorView stopAnimating];
    }
}

/** 显示或隐藏重新加载按钮 */
- (void)_retryButtonShow:(BOOL)show
{
    self.isRetryShowing = show;
    if (show) {
        self.playButton.selected = NO;
        self.playButton.hidden = YES;
        self.retryButton.hidden = NO;
    }else
    {
        self.retryButton.hidden = YES;
    }
}

/** progress显示缓冲进度 */
- (void)_setPlayerProgress:(CGFloat)progress {
    [self.progress setProgress:progress animated:NO];
}

/** 控制播放按钮选择状态 */
- (void)_setPlayButtonSelect:(BOOL)select
{
    self.playButton.selected = select;
}

/** 显示或隐藏控制面板 */
- (void)_playerShowOrHidePlaybackControls
{
    if (self.isShowing) {
        [self _playerHidePlaybackControls];
    } else {
        [self _playerShowPlaybackControls];
    }
}

/** 显示控制面板 */
- (void)_playerShowPlaybackControls
{
    [self _playerCancelAutoHidePlaybackControls];
    [UIView animateWithDuration:PlaybackControlsAutoHideTimeInterval animations:^{
        [self _showPlaybackControls];
    } completion:^(BOOL finished) {
        self.isShowing = YES;
        [self _playerAutoHidePlaybackControls];
    }];
}

/** 隐藏控制面板 */
- (void)_playerHidePlaybackControls
{
    [self _playerCancelAutoHidePlaybackControls];
    [UIView animateWithDuration:PlaybackControlsAutoHideTimeInterval animations:^{
        [self _hidePlaybackControls];
    } completion:^(BOOL finished) {
        self.isShowing = NO;
    }];
}

/** 显示控制面板 */
- (void)_showPlaybackControls
{
    self.isShowing = YES;
    self.bottomControlsBar.alpha = 1;
    if (!self.isActivityShowing && !self.isRetryShowing) {
        self.playButton.hidden = NO;
    }
    [self _showOrHideStatusBar];
}


/** 隐藏控制面板 */
- (void)_hidePlaybackControls
{
    self.isShowing = NO;
    self.bottomControlsBar.alpha = 0;
    self.playButton.hidden = YES;
    if (self.isFullScreen) {
        [self _showOrHideStatusBar];
    }
}


/** 延时自动隐藏控制面板 */
- (void)_playerAutoHidePlaybackControls
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_playerHidePlaybackControls) object:nil];
    [self performSelector:@selector(_playerHidePlaybackControls) withObject:nil afterDelay:_hideInterval];
}

/** 显示或隐藏状态栏 */
- (void)_showOrHideStatusBar
{
    switch (_statusBarHideState) {
        case SelStatusBarHideStateFollowControls:
        {
            [[UIApplication sharedApplication] setStatusBarHidden:!self.isShowing];
        }
            break;
        case SelStatusBarHideStateNever:
        {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
            break;
        case SelStatusBarHideStateAlways:
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
            break;
        default:
            break;
    }
}

/** 是否处于全屏状态 */
- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    self.fullScreenButton.selected = _isFullScreen;
}

/** 取消延时隐藏playbackControls */
- (void)_playerCancelAutoHidePlaybackControls
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

/** 创建UI */
- (void)setupUI
{
  
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.playButton];
    [self addSubview:self.bottomControlsBar];
    [self addSubview:self.activityIndicatorView];
    [self addSubview:self.retryButton];
    [self addSubview:self.coverImageView];

    
    [_bottomControlsBar addSubview:self.fullScreenButton];
    [_bottomControlsBar addSubview:self.playTimeLabel];
    [_bottomControlsBar addSubview:self.totalTimeLabel];
    [_bottomControlsBar addSubview:self.progress];
    [_bottomControlsBar addSubview:self.videoSlider];
    [_bottomControlsBar addSubview:self.playClarityBtn];
    [_bottomControlsBar addSubview:self.playRateBtn];
    [_bottomControlsBar addSubview:self.audioOrVideoBtn];
    [_bottomControlsBar addSubview:self.lockButton];
    [_bottomControlsBar addSubview:self.playCacheBtn];
  
    [self makeConstraints];
    [self _resetPlaybackControls];
    [self addGesture];
    [self initW];
}

/** 添加手势 */
- (void)addGesture
{
    //单击手势
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:singleTapGesture];
    
    //双击手势
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGesture];
    
    //当系统检测不到双击手势时执行再识别单击手势，解决单双击收拾冲突
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
}

/** 添加约束 */
- (void)makeConstraints
{
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    
    [_bottomControlsBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@30);
    }];
    
    [_activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [_retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
  
  //封面图
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self).offset(0);
      make.right.equalTo(self).offset(5);
      make.left.equalTo(self).offset(-5);
      make.bottom.equalTo(_bottomControlsBar).offset(-30);

    }];
  
  
  
    [_fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(_bottomControlsBar);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];

  
    [_playTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomControlsBar).offset(5);
        make.width.equalTo(@45);
        make.centerY.equalTo(_bottomControlsBar.mas_centerY);
    }];
  
  //锁屏
  [_lockButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(_fullScreenButton).offset(-35);
    make.width.equalTo(@45);
    make.centerY.equalTo(_bottomControlsBar.mas_centerY);
  }];
  
  //几倍速播放
    [_playRateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(_lockButton).offset(-35);
      make.width.equalTo(@45);
      make.centerY.equalTo(_bottomControlsBar.mas_centerY);
    }];
  
    //清晰度切换
    [_playClarityBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(_playRateBtn).offset(-35);
      make.width.equalTo(@45);
      make.centerY.equalTo(_bottomControlsBar.mas_centerY);
    }];
  
     //音频和视频切换
    [_audioOrVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(_playClarityBtn).offset(-35);
      make.width.equalTo(@45);
      make.centerY.equalTo(_bottomControlsBar.mas_centerY);
    }];
  
    //是否缓存
    [_playCacheBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(_audioOrVideoBtn).offset(-35);
      make.width.equalTo(@45);
      make.centerY.equalTo(_bottomControlsBar.mas_centerY);
    }];
  
  
  
    [_totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_playCacheBtn.mas_left).offset(-5);
        make.width.equalTo(@45);
        make.centerY.equalTo(_bottomControlsBar.mas_centerY);
    }];
    
    [_progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_playTimeLabel.mas_right).offset(5);
        make.right.equalTo(_totalTimeLabel.mas_left).offset(-5);
        make.height.equalTo(@2);
        make.centerY.equalTo(_bottomControlsBar.mas_centerY);
    }];

    [_videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_progress);
    }];
}

/** 加载指示器 */
- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _activityIndicatorView;
}

/** 底部控制栏 */
- (UIView *)bottomControlsBar
{
    if (!_bottomControlsBar) {
        _bottomControlsBar = [[UIView alloc]init];
        _bottomControlsBar.userInteractionEnabled = YES;
    }
    return _bottomControlsBar;
}

/** 播放按钮 */
- (UIButton *)playButton
{
    if (!_playButton){
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

//音频和视频的切换
-(UIButton *)audioOrVideoBtn{
  
  if (!_audioOrVideoBtn) {
    _audioOrVideoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    [_audioOrVideoBtn setTitle:@"视频" forState:UIControlStateNormal];
    _audioOrVideoBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_audioOrVideoBtn addTarget:self action:@selector(audioOrVideoBtnClick) forControlEvents:UIControlEventTouchDown];
  }
  return _audioOrVideoBtn;
}

/** 全屏切换按钮 */
- (UIButton *)fullScreenButton
{
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:@"kr-video-player-fullscreen"] forState:UIControlStateNormal];
        [_fullScreenButton setImage:[UIImage imageNamed:@"kr-video-player-shrinkscreen"] forState:UIControlStateSelected];
        [_fullScreenButton addTarget:self action:@selector(fullScreenAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenButton;
}

//是否缓存切换
-(UIButton *)playCacheBtn{
  
  if (!_playCacheBtn) {
    _playCacheBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    [_playCacheBtn setTitle:@"不缓存" forState:UIControlStateNormal];
    _playCacheBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_playCacheBtn addTarget:self action:@selector(playCachBtnClick) forControlEvents:UIControlEventTouchDown];
  }
  return _playCacheBtn;
  
}

//封面图
-(UIImageView *)coverImageView{
  
  if (_coverImageView == nil) {
    _coverImageView = [[UIImageView alloc] init];
    _coverImageView.image = [UIImage imageNamed:@"backImage"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverClick)];
    _coverImageView.userInteractionEnabled = YES;
    [_coverImageView addGestureRecognizer:tap];
  }
  return _coverImageView;
}

/*清晰度切换*/
-(UIButton *)playClarityBtn{
  
  if (!_playClarityBtn) {
    _playClarityBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    [_playClarityBtn setTitle:@"普清" forState:UIControlStateNormal];
     _playClarityBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [[NSUserDefaults standardUserDefaults] setObject:@"普清" forKey:@"clarity"];
    [_playClarityBtn addTarget:self action:@selector(playClarityBtnClick) forControlEvents:UIControlEventTouchDown];
  }
  return _playClarityBtn;
}

/*锁屏按钮*/
-(UIButton *)lockButton{
  
  if (!_lockButton) {
    _lockButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    [_lockButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    _lockButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_lockButton addTarget:self action:@selector(lockButtonClick) forControlEvents:UIControlEventTouchDown];
    [_lockButton setImage:[UIImage imageNamed:@"zx-video-player-unlock"] forState:UIControlStateNormal];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"screenDirection"];
  }
  return _lockButton;
}

/*速度切换按钮*/
-(UIButton *)playRateBtn{
  
  if (!_playRateBtn) {
    _playRateBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    [_playRateBtn setTitle:@"1X" forState:UIControlStateNormal];
    _playRateBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_playRateBtn addTarget:self action:@selector(playRateBtnClick) forControlEvents:UIControlEventTouchDown];
  }
  return _playRateBtn;
}

/** 当前播放时间 */
- (UILabel *)playTimeLabel
{
    if (!_playTimeLabel) {
        _playTimeLabel = [[UILabel alloc]init];
        _playTimeLabel.font = [UIFont systemFontOfSize:14];
        _playTimeLabel.text = @"00:00";
        _playTimeLabel.adjustsFontSizeToFitWidth = YES;
        _playTimeLabel.textAlignment = NSTextAlignmentCenter;
        _playTimeLabel.textColor = [UIColor whiteColor];
    }
    return _playTimeLabel;
}



/** 视频总时间 */
- (UILabel *)totalTimeLabel
{
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc]init];
        _totalTimeLabel.font = [UIFont systemFontOfSize:14];
        _totalTimeLabel.text = @"00:00";
        _totalTimeLabel.adjustsFontSizeToFitWidth = YES;
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        _totalTimeLabel.textColor = [UIColor whiteColor];
    }
    return _totalTimeLabel;
}

/** 加载失败重试按钮 */
- (UIButton *)retryButton
{
    if (!_retryButton) {
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_retryButton setImage:[UIImage imageNamed:@"Action_reload_player_100x100_"] forState:UIControlStateNormal];
        [_retryButton addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchUpInside];
        _retryButton.hidden = YES;
    }
    return _retryButton;
}

/** 播放进度条 */
- (UIProgressView *)progress
{
    if (!_progress) {
        _progress = [[UIProgressView alloc]init];
        _progress.progressTintColor = [UIColor whiteColor];
        _progress.trackTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    }
    return _progress;
}

/** 滑杆 */
- (SelVideoSlider *)videoSlider
{
    if (!_videoSlider) {
        _videoSlider = [[SelVideoSlider alloc]init];
        _videoSlider.maximumTrackTintColor = [UIColor clearColor];
        //开始拖动事件
        [_videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        //拖动中事件
        [_videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        //结束拖动事件
        [_videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    }
    return _videoSlider;
}

#pragma mark - 滑杆
/** 开始拖动事件 */
- (void)progressSliderTouchBegan:(SelVideoSlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(videoSliderTouchBegan:)]) {
        [_delegate videoSliderTouchBegan:slider];
    }
}
/** 拖动中事件 */
- (void)progressSliderValueChanged:(SelVideoSlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(videoSliderValueChanged:)]) {
        [_delegate videoSliderValueChanged:slider];
    }
}
/** 结束拖动事件 */
- (void)progressSliderTouchEnded:(SelVideoSlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(videoSliderTouchEnded:)]) {
        [_delegate videoSliderTouchEnded:slider];
    }
}

/** 播放按钮点击事件 */
- (void)playAction:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(playButtonAction:)]) {
        [_delegate playButtonAction:button.selected];
    }
}

/** 全屏切换按钮点击事件 */
- (void)fullScreenAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(fullScreenButtonAction)]) {
        [_delegate fullScreenButtonAction];
    }
}

//是否缓存切换
- (void)playCachBtnClick
{
  if (_delegate && [_delegate respondsToSelector:@selector(playCachButtonAction)]) {
    [_delegate playCachButtonAction];
  }
}


//视频锁屏
-(void)lockButtonClick{
  
  if (_delegate && [_delegate respondsToSelector:@selector(lockButtonAction)]) {
    [_delegate lockButtonAction];
  }
  
}

//封面被点击
-(void)coverClick{
  
  if (_delegate && [_delegate respondsToSelector:@selector(coverClickAction)]) {
    [_delegate coverClickAction];
  }

}

//几倍速度播放
-(void)playRateBtnClick{
  
  if (_delegate && [_delegate respondsToSelector:@selector(playRateButtonAction)]) {
    [_delegate playRateButtonAction];
  }
  
}

//视频和音频的切换
-(void)audioOrVideoBtnClick{
  
  if (_delegate && [_delegate respondsToSelector:@selector(audioOrVideoBtnClickAction)]) {
    [_delegate audioOrVideoBtnClickAction];
  }
}

//清晰度播放切换
-(void)playClarityBtnClick{
  
  if (_delegate && [_delegate respondsToSelector:@selector(playClarityBtnAction)]) {
    [_delegate playClarityBtnAction];
  }
  
}


/** 重试按钮点击事件 */
- (void)retryAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(retryButtonAction)]) {
        [_delegate retryButtonAction];
    }
}



/** 控制面板单击事件 */
- (void)tap:(UIGestureRecognizer *)gesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(tapGesture)]) {
        [_delegate tapGesture];
    }
}

/** 控制面板双击事件 */
- (void)doubleTap:(UIGestureRecognizer *)gesture
{   
    if (_delegate && [_delegate respondsToSelector:@selector(doubleTapGesture)]) {
        [_delegate doubleTapGesture];
    }
}


//音量
- (void)initW
{
  //  self.secondsForBottom = maxSecondsForBottom;
  //  self.currentTime      = 0;
  
  //获取系统音量滚动条
  MPVolumeView *volumeView = [[MPVolumeView alloc]init];
  for (UIView *tmpView in volumeView.subviews) {
    if ([[tmpView.class description] isEqualToString:@"MPVolumeSlider"]) {
      self.volumeSlider = (UISlider *)tmpView;
      self.volumeSlider.center = self.center;
    }
  }
}



@end
