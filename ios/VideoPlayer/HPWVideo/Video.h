//
//  Video.h
//  RNDemo
//
//  Created by hupengwei on 2018/3/10.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelVideoPlayer.h"
#import "SelPlayerConfiguration.h"
#import "HSDownloadManager.h"
@interface Video : UIView
@property (nonatomic,strong) NSString *Poster;
@property (nonatomic,strong) NSString *VideoUrl;
@property (nonatomic,strong) NSString *Definition;
@property (nonatomic,strong) NSArray *PlayInfoList;
@property (nonatomic, strong) SelVideoPlayer *player;
@property (nonatomic,strong) SelPlayerConfiguration *configuration;

-(Video *)videoViewV;
@end
