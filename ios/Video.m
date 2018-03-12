//
//  Video.m
//  RNDemo
//
//  Created by hupengwei on 2018/3/10.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "Video.h"

@implementation Video
//Poster={'http://timemyh.com/images/uploads/article/1501739780794.jpg'}
//
//VideoUrl={'http://obukb5fdy.bkt.clouddn.com/icevideo/video/nayuta.mp4'}
//
//Definition={'LD'}
//PlayInfoList = {
//  {
//    "PlayInfo": [{
//      "Definition": "LD",
//      "PlayURL": "http://obukb5fdy.bkt.clouddn.com/icevideo/video/nayuta.mp4"
//    },
//                 {
//                   "Definition": "SD",
//                   "PlayURL": "http://obukb5fdy.bkt.clouddn.com/icevideo/video/nayuta.mp4"
//                 }
//                 ]
//  }
//}x

-(void)setPoster:(NSString *)Poster{
  
  [[NSUserDefaults standardUserDefaults] setObject:Poster forKey:@"Poster"];
  
  SelPlayerConfiguration *configuration = [[SelPlayerConfiguration alloc]init];
  self.configuration = configuration;
  configuration.shouldAutoPlay = YES;
  configuration.supportedDoubleTap = YES;
  configuration.shouldAutorotate = YES;
  configuration.repeatPlay = YES;
  configuration.statusBarHideState = SelStatusBarHideStateFollowControls;
  
  
  if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"VideoUrl"] length] > 0) {
    
    if ([[[HSDownloadManager sharedInstance] pathSourceFile:[[NSUserDefaults standardUserDefaults] objectForKey:@"VideoUrl"]] length] <= 0) {
      //http://120.25.226.186:32812/resources/videos/minion_02.mp4
      //http://obukb5fdy.bkt.clouddn.com/icevideo/video/nayuta.mp4
      configuration.sourceUrl = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"VideoUrl"]];
      //      configuration.sourceUrl = [NSURL URLWithString:@"http://obukb5fdy.bkt.clouddn.com/icevideo/video/nayuta.mp4"];
      
      
    }else{
      
      configuration.sourceUrl = [NSURL fileURLWithPath:[[HSDownloadManager sharedInstance] pathSourceFile:[[NSUserDefaults standardUserDefaults] objectForKey:@"VideoUrl"]] ];
      
    }
  }
  
  
  configuration.videoGravity = SelVideoGravityResizeAspect;
  SelVideoPlayer *videoPlayer = [[SelVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, [[UIApplication sharedApplication].delegate window].frame.size.width ,300) configuration:configuration];
  [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"bannerImage"];
  [videoPlayer _pauseVideo];
  [self addSubview:videoPlayer];
  
  
  
}

-(void)setVideoUrl:(NSString *)VideoUrl{
  
  [[NSUserDefaults standardUserDefaults] setObject:VideoUrl forKey:@"VideoUrl"];

}

-(void)setDefinition:(NSString *)Definition{
  
  [[NSUserDefaults standardUserDefaults] setObject:Definition forKey:@"Definition"];
  
  
}

-(void)setPlayInfoList:(NSArray *)PlayInfoList{
  
  if ([PlayInfoList[0][@"PlayInfo"] count] > 0) {
    
    [[NSUserDefaults standardUserDefaults] setObject:PlayInfoList[0][@"PlayInfo"] forKey:@"PlayInfoList"];
   
    
  }
  
}

//-(Video *)videoViewV{
//
//
//    SelPlayerConfiguration *configuration = [[SelPlayerConfiguration alloc]init];
//    self.configuration = configuration;
//    configuration.shouldAutoPlay = YES;
//    configuration.supportedDoubleTap = YES;
//    configuration.shouldAutorotate = YES;
//    configuration.repeatPlay = YES;
//    configuration.statusBarHideState = SelStatusBarHideStateFollowControls;
//
//
//  if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"VideoUrl"] length] > 0) {
//
//    if ([[[HSDownloadManager sharedInstance] pathSourceFile:[[NSUserDefaults standardUserDefaults] objectForKey:@"VideoUrl"]] length] <= 0) {
//      //http://120.25.226.186:32812/resources/videos/minion_02.mp4
//  //http://obukb5fdy.bkt.clouddn.com/icevideo/video/nayuta.mp4
//      configuration.sourceUrl = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"VideoUrl"]];
////      configuration.sourceUrl = [NSURL URLWithString:@"http://obukb5fdy.bkt.clouddn.com/icevideo/video/nayuta.mp4"];
//
//
//    }else{
//
//      configuration.sourceUrl = [NSURL fileURLWithPath:[[HSDownloadManager sharedInstance] pathSourceFile:[[NSUserDefaults standardUserDefaults] objectForKey:@"VideoUrl"]] ];
//
//    }
//  }
//
//
//    configuration.videoGravity = SelVideoGravityResizeAspect;
//    SelVideoPlayer *videoPlayer = [[SelVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, [[UIApplication sharedApplication].delegate window].frame.size.width ,300) configuration:configuration];
//    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"bannerImage"];
//    [videoPlayer _pauseVideo];
//    [self addSubview:videoPlayer];
//    return self;
//
//
//}




@end
