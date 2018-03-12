
//  RNDemo
//
//  Created by hupengwei on 2018/3/12.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXVideoPlayerTimeIndicatorView.h"
@class SelPlayerConfiguration;
@interface SelVideoPlayer : UIView
@property (nonatomic, strong, readwrite) ZXVideoPlayerTimeIndicatorView *timeIndicatorView;
//@property (nonatomic,strong) UIView *timeIndicatorView;

/**
 初始化播放器
 @param configuration 播放器配置信息
 */
- (instancetype)initWithFrame:(CGRect)frame configuration:(SelPlayerConfiguration *)configuration;

/** 播放视频 */
- (void)_playVideo;
/** 暂停播放 */
- (void)_pauseVideo;
/** 释放播放器 */
- (void)_deallocPlayer;
/// 快进、快退指示器
@end
