//
//  VideoRNManager.h
//  RNDemo
//
//  Created by hupengwei on 2018/3/1.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"

@interface VideoRNManager : NSObject<RCTBridgeModule>
@property (nonatomic, copy) RCTPromiseResolveBlock resolver;

@end
