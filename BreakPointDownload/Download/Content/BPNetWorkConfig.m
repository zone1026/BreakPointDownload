//
//  BPNetWorkConfig.m
//  BreakPointDownload
//
//  Created by 黄亚州 on 2017/5/30.
//  Copyright © 2017年 黄亚州. All rights reserved.
//

#import "BPNetWorkConfig.h"

@implementation BPNetWorkConfig

+ (BPNetWorkConfig *)sharedConfig
{
    static dispatch_once_t onceToken;
    static BPNetWorkConfig *shared;
    dispatch_once(&onceToken, ^{
        shared = [[BPNetWorkConfig alloc] init];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)getDownloadType:(EDownloadType)aType{
    NSString *typeName = @"";
    switch (aType) {
        case EDownloadTypeNone:
            typeName = @"EDownloadTypeNone";
            break;
            
        default:
            break;
    }
    return typeName;
}

- (NSInteger)getMaxDownloadForType:(EDownloadType)aType{
    return 3;
}

@end
