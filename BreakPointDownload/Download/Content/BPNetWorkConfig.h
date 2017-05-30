//
//  BPNetWorkConfig.h
//  BreakPointDownload
//
//  Created by 黄亚州 on 2017/5/30.
//  Copyright © 2017年 黄亚州. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EDownloadType) {
    EDownloadTypeNone
};

@interface BPNetWorkConfig : NSObject

+ (BPNetWorkConfig *)sharedConfig;
- (NSString *)getDownloadType:(EDownloadType)aType;
- (NSInteger)getMaxDownloadForType:(EDownloadType)aType;

@end
