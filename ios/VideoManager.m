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
@implementation VideoManager

RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(pitchEnabled, BOOL)

RCT_EXPORT_METHOD(Video:(NSString *)url resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)reject){
  
  
}

-(UIView *)view
{
//  UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  UIView *v = [[UIView alloc] init];
  v.backgroundColor = [UIColor whiteColor];
  
//  NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//
//  NSString *documentsDirectory = [paths objectAtIndex:0];
//
//
//  self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:[[HSDownloadManager sharedInstance] pathSourceFile:@"http://120.25.226.186:32812/resources/videos/minion_02.mp4"] ]];
//
//
//
//
//
//[self.player replaceCurrentItemWithPlayerItem:self.playerItem];
//[self.player seekToTime:CMTimeMakeWithSeconds(self.playbackControls.videoSlider.value*self.playbackControls.totalTime, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
//  [self _playVideo];
//}];
  
  SelPlayerConfiguration *configuration = [[SelPlayerConfiguration alloc]init];
  configuration.shouldAutoPlay = YES;
  configuration.supportedDoubleTap = YES;
  configuration.shouldAutorotate = YES;
  configuration.repeatPlay = YES;
  configuration.statusBarHideState = SelStatusBarHideStateFollowControls;
  if ([[[HSDownloadManager sharedInstance] pathSourceFile:@"http://120.25.226.186:32812/resources/videos/minion_02.mp4"] length] <= 0) {
    
    configuration.sourceUrl = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"urlName"]];
    
  }else{
    
    configuration.sourceUrl = [NSURL fileURLWithPath:[[HSDownloadManager sharedInstance] pathSourceFile:[[NSUserDefaults standardUserDefaults] objectForKey:@"urlName"]] ];

  }

  configuration.videoGravity = SelVideoGravityResizeAspect;
  SelVideoPlayer *videoPlayer = [[SelVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, [[UIApplication sharedApplication].delegate window].frame.size.width ,300) configuration:configuration];
  [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"bannerImage"];
  [videoPlayer _pauseVideo];
  [v addSubview:videoPlayer];
  return v;
}
@end
