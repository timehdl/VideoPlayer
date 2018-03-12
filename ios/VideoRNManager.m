//
//  VideoRNManager.m
//  RNDemo
//
//  Created by hupengwei on 2018/3/1.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "VideoRNManager.h"

@implementation VideoRNManager
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD (videoPlayArr:(NSArray *)arr resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)reject) {

  [[NSUserDefaults standardUserDefaults] setObject:@"htt" forKey:@"urlName"];
  ;
  if (resolver) {
//    resolver(dic);
  }
  
  
}
@end
