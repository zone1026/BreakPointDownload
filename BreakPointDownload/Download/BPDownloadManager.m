//
//  BPDownloadManager.m
//  BreakPointDownload
//
//  Created by 黄亚州 on 2017/5/30.
//  Copyright © 2017年 黄亚州. All rights reserved.
//

#import "BPDownloadManager.h"
#import "BPDownloadContent.h"
#import "BPDownloader.h"
#import "BPNetWorkService.h"
#import "NSString+BPUtil.h"

@interface BPDownloadManager ()<NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary *dictDownloader;
@end

@implementation BPDownloadManager

- (instancetype)init{
    if (self = [super init]) {
        self.maxDownLoad = 3;
    }
    return self;
}

- (void)downloadContent:(BPDownloadContent *)aContent onProgress:(void(^)(int64_t completeBytes, int64_t totalBytes))aProgress onComplete:(void(^)(BPDownloadContent *aContent, NSError *aError))aComplete{
    if ([aContent.urlString checkBlankString]) {
        NSLog(@"download url is null");
        return;
    }
    
    NSString *key = [aContent.urlString MD5String];
    BPDownloader *downloader = self.dictDownloader[key];
    if (downloader == nil) {
        if (self.dictDownloader.count >= self.maxDownLoad) {
            if (aComplete) {
                NSString *errorString = [NSString stringWithFormat:@"已达最大下载数%tu",self.maxDownLoad];
                NSError *aError = [NSError errorWithDomain:@"超过最大下载数" code:1 userInfo:@{@"NSLocalizedDescription" : errorString}];
                aComplete(aContent, aError);
            }
            return;
        }
        
        downloader = [[BPDownloader alloc] init];
        downloader.aContent = aContent;
        downloader.session = self.session;
        [self setDownload:downloader forUrlString:aContent.urlString];
        [downloader startDownload];
    }
    
    
    __weak typeof(BPDownloadManager*)weakSelf = self;
    aContent.downLoadState = EDownloadStateGoing;
    downloader.successBlock = ^(BPDownloader *aCmd){
        if (aComplete) {
            aComplete(aCmd.aContent,nil);
        }
        [weakSelf.dictDownloader removeObjectForKey:key];
        [weakSelf finish];
    };
    
    downloader.failBlock = ^(BPDownloader *aCmd, NSError *aError){
        if (aError.code != -999) {
            aContent.downLoadState = EDownloadStateFaile;
        }else {
            aContent.downLoadState = EDownloadStatePause;
            aError = [NSError errorWithDomain:@"暂停下载" code:0 userInfo:@{@"NSLocalizedDescription" : @"暂停下载"}];
        }
        if (aComplete) {
            aComplete(nil,aError);
        }
        [weakSelf.dictDownloader removeObjectForKey:key];
        [weakSelf finish];
    };
    
    downloader.downloadProgress = ^(int64_t completeBytes, int64_t totalBytes){
        if (aProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                aProgress(completeBytes,totalBytes);
            });
        }
    };
}

- (void)cancelUrlString:(NSString *)urlString{
    NSString *key = [urlString MD5String];
    BPDownloader *BPDownloader = self.dictDownloader[key];
    [BPDownloader cancel];
}

// 取消block进度回调，线程切换 卡性能
- (void)cancelBlock{
    [self.dictDownloader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        BPDownloader *downloader = self.dictDownloader[key];
        [self downloadContent:downloader.aContent onProgress:nil onComplete:nil];
    }];
}

- (void)finish{
    if (self.dictDownloader.count > 0) {
        return;
    }
    [[BPNetWorkService shared] removeDownloadManagerForType:self.type];
    [self.session invalidateAndCancel];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    BPDownloader *downloader = self.dictDownloader[task.taskDescription];
    [downloader URLSession:session task:task didCompleteWithError:error];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    BPDownloader *downloader = self.dictDownloader[dataTask.taskDescription];
    [downloader URLSession:session dataTask:dataTask didReceiveData:data];
}

- (void)setDownload:(BPDownloader *)downloader forUrlString:(NSString *)urlString{
    self.dictDownloader[[urlString MD5String]] = downloader;
}


#pragma mark - lazy load

- (NSURLSession *)session{
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
    }
    return _session;
}

- (NSMutableDictionary *)dictDownloader{
    if (!_dictDownloader) {
        _dictDownloader = [[NSMutableDictionary alloc] init];
    }
    return _dictDownloader;
}

@end
