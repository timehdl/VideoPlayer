//
//  VideoManager.m
//  RNDemo
//
//  Created by hupengwei on 2018/2/28.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "VideoManager.h"
#import <Masonry.h>
#import "HSDownloadManager.h"
#import "Video.h"


@implementation VideoManager

@synthesize bridge = _bridge;
RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(VideoUrl, NSString);
RCT_EXPORT_VIEW_PROPERTY(Poster, NSString);
RCT_EXPORT_VIEW_PROPERTY(Definition, NSString);
RCT_EXPORT_VIEW_PROPERTY(PlayInfoList, NSArray);



//RCT_EXPORT_METHOD(Video:(NSString *)url  resolver:(RCTPromiseResolveBlock)resolver
//                  rejecter:(RCTPromiseRejectBlock)reject){
//
//
//}



-(UIView *)view
{
  
  Video *videoView =  [[Video alloc] init];
  self.videoView = videoView;
  return videoView;
 
}
@end
