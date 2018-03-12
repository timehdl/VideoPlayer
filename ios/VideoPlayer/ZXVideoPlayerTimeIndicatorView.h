
//  RNDemo
//
//  Created by hupengwei on 2018/3/12.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZXTimeIndicatorPlayState) {
    ZXTimeIndicatorPlayStateRewind,      // rewind
    ZXTimeIndicatorPlayStateFastForward, // fast forward
};

static const CGFloat kVideoTimeIndicatorViewSide = 96;

@interface ZXVideoPlayerTimeIndicatorView : UIView

@property (nonatomic, strong, readwrite) NSString *labelText;
@property (nonatomic, assign, readwrite) ZXTimeIndicatorPlayState playState;
@property (nonatomic, strong, readwrite) UIImageView *arrowImageView;
@property (nonatomic, strong, readwrite) UILabel     *timeLabel;
@end
