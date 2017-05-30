//
//  BPNetWorkService.m
//  BreakPointDownload
//
//  Created by 黄亚州 on 2017/5/30.
//  Copyright © 2017年 黄亚州. All rights reserved.
//

#import "BPNetWorkService.h"
#import "BPDownloadContent.h"
#import "BPDownloadManager.h"

@interface BPNetWorkService ()

@property (nonatomic, strong) NSMutableDictionary *dictDownloadManager;

@end

@implementation BPNetWorkService

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

+ (instancetype)shared{
    static BPNetWorkService *globalService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalService = [[BPNetWorkService alloc] init];
    });
    return globalService;
}

- (void)downloadType:(EDownloadType)type content:(BPDownloadContent *)aContent onProgress:(void(^)(int64_t completeBytes, int64_t totalBytes))aProgress onComplete:(void(^)(BPDownloadContent* aContent, NSError* aError))aComplete{
    BPDownloadManager *downloadManager = [self getDownloadManagerForType:type];
    [downloadManager downloadContent:aContent onProgress:aProgress onComplete:aComplete];
}

- (void)downloadContent:(BPDownloadContent *)aContent onProgress:(void(^)(int64_t completeBytes, int64_t totalBytes))aProgress onComplete:(void(^)(BPDownloadContent* aContent, NSError* aError))aComplete{
    [self downloadType:EDownloadTypeNone content:aContent onProgress:aProgress onComplete:aComplete];
}

- (void)cancelUrlString:(NSString *)urlString{
    [self.dictDownloadManager enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        BPDownloadManager *downloadManager = self.dictDownloadManager[key];
        [downloadManager cancelUrlString:urlString];
    }];
}

- (void)canceltype:(EDownloadType)type UrlString:(NSString *)urlString{
    BPDownloadManager *downloadManager = [self getDownloadManagerForType:type];
    [downloadManager cancelUrlString:urlString];
}

- (void)cancelBlockType:(EDownloadType)type{
    BPDownloadManager *downloadManager = [self getDownloadManagerForType:type];
    [downloadManager cancelBlock];
}

#pragma mark - downloadManager 创建

- (void)setDownloadManager:(BPDownloadManager *)downloadManager forType:(EDownloadType)type{
    NSString *typeName = [[BPNetWorkConfig sharedConfig] getDownloadType:type];
    self.dictDownloadManager[typeName] = downloadManager;
}

- (BPDownloadManager *)getDownloadManagerForType:(EDownloadType)type{
    NSString *typeName = [[BPNetWorkConfig sharedConfig] getDownloadType:type];
    BPDownloadManager *downloadManager = self.dictDownloadManager[typeName];
    if (downloadManager == nil) {
        downloadManager = [[BPDownloadManager alloc] init];
        downloadManager.type = type;
        downloadManager.maxDownLoad = [[BPNetWorkConfig sharedConfig] getMaxDownloadForType:type];
        [self setDownloadManager:downloadManager forType:type];
    }
    return downloadManager;
}

- (void)removeDownloadManagerForType:(EDownloadType)type{
    NSString *typeName = [[BPNetWorkConfig sharedConfig] getDownloadType:type];
    [self.dictDownloadManager removeObjectForKey:typeName];
}

#pragma mark - lazy load

- (NSMutableDictionary *)dictDownloadManager{
    if (!_dictDownloadManager) {
        _dictDownloadManager = [[NSMutableDictionary alloc] init];
    }
    return _dictDownloadManager;
}

@end
