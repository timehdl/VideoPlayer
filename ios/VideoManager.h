//
//  VideoManager.h
//  RNDemo
//
//  Created by hupengwei on 2018/2/28.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "RCTViewManager.h"
#import "Video.h"

@interface VideoManager : RCTViewManager

@property (nonatomic, copy) RCTPromiseResolveBlock resolver;

@property (nonatomic,strong) Video *videoView;
@end
