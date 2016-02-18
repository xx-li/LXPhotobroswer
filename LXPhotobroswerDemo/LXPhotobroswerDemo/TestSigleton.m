//
//  TestSigleton.m
//  LXPhotobroswerDemo
//
//  Created by 李新星 on 16/2/18.
//  Copyright © 2016年 xx-li. All rights reserved.
//

#import "TestSigleton.h"

static id singleton = nil;

@implementation TestSigleton

+ (instancetype)sharedTestSigleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[[self class] alloc] init];
    });
    return singleton;
}

- (instancetype)init
{
    if (singleton) {
        return singleton;
    }
    self = [super init];
    if (self) {

    }
    singleton = self;
    return self;
}


@end
