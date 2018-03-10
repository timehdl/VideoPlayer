//
//  VideoManager.h
//  RNDemo
//
//  Created by hupengwei on 2018/2/28.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "RCTViewManager.h"
#import "SelVideoPlayer.h"
#import "SelPlayerConfiguration.h"


@interface VideoManager : RCTViewManager
@property (nonatomic, strong) SelVideoPlayer *player;
@property (nonatomic, copy) RCTPromiseResolveBlock resolver;

@end
