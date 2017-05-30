//
//  BPDownloadManager.h
//  BreakPointDownload
//
//  Created by 黄亚州 on 2017/5/30.
//  Copyright © 2017年 黄亚州. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPNetWorkConfig.h"

@class BPDownloadContent;

@interface BPDownloadManager : NSObject

@property (nonatomic, assign) NSInteger maxDownLoad; // 同时存在的最大下载数
@property (nonatomic, assign) EDownloadType type;

- (void)downloadContent:(BPDownloadContent *)aContent onProgress:(void(^)(int64_t completeBytes, int64_t totalBytes))aProgress onComplete:(void(^)(BPDownloadContent *aContent, NSError *aError))aComplete;

- (void)cancelUrlString:(NSString *)urlString;

// 取消block进度回调，线程切换 卡性能
- (void)cancelBlock;

@end
