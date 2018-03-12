
//  RNDemo
//
//  Created by hupengwei on 2018/3/12.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "SelPlayerConfiguration.h"

@implementation SelPlayerConfiguration


/**
 初始化 设置缺省值
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        _hideControlsInterval = 5.0f;
    }
    return self;
}

@end
