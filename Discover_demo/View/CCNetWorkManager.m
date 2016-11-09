//
//  CCNetWorkManager.m
//  Discover_demo
//
//  Created by 24hmb on 2016/11/9.
//  Copyright © 2016年 24hmb. All rights reserved.
//

#import "CCNetWorkManager.h"

@implementation CCNetWorkManager

+ (instancetype)shareManager {
    static CCNetWorkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:NULL]init];
    });
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [CCNetWorkManager shareManager];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [CCNetWorkManager shareManager];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    
}

@end
