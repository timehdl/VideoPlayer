//
//  VideoManager.m
//  RNDemo
//
//  Created by hupengwei on 2018/2/28.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "VideoPlayerManager.h"
#import "Masonry.h"
#import "HSDownloadManager.h"
#import "Video.h"


@implementation VideoPlayerManager

@synthesize bridge = _bridge;
RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(VideoUrl, NSString);
RCT_EXPORT_VIEW_PROPERTY(Poster, NSString);
RCT_EXPORT_VIEW_PROPERTY(Definition, NSString);
RCT_EXPORT_VIEW_PROPERTY(PlayInfoList, NSArray);




-(UIView *)view
{

  Video *videoView =  [[Video alloc] init];
  self.videoView = videoView;
  return videoView;

}
@end
