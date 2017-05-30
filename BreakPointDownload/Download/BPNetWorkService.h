//
//  BPNetWorkService.h
//  BreakPointDownload
//
//  Created by 黄亚州 on 2017/5/30.
//  Copyright © 2017年 黄亚州. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BPNetWorkConfig.h"

@class BPDownloadContent;
@interface BPNetWorkService : NSObject

+ (BPNetWorkService *)shared;
- (void)removeDownloadManagerForType:(EDownloadType)type;

// 默认 EDownloadTypeNone
- (void)downloadContent:(BPDownloadContent *)aContent onProgress:(void(^)(int64_t completeBytes, int64_t totalBytes))aProgress onComplete:(void(^)(BPDownloadContent* aContent, NSError* aError))aComplete;

- (void)downloadType:(EDownloadType)type content:(BPDownloadContent *)aContent onProgress:(void(^)(int64_t completeBytes, int64_t totalBytes))aProgress onComplete:(void(^)(BPDownloadContent* aContent, NSError* aError))aComplete;

// 一个urlString 不该做为多种 EDownloadType。
- (void)cancelUrlString:(NSString *)urlString;
- (void)canceltype:(EDownloadType)type UrlString:(NSString *)urlString;
- (void)cancelBlockType:(EDownloadType)type;

@end
