//
//  BPDownloader.m
//  BreakPointDownload
//
//  Created by 黄亚州 on 2017/5/30.
//  Copyright © 2017年 黄亚州. All rights reserved.
//

#import "BPDownloader.h"
#import "BPDownloadContent.h"
#import "NSString+BPUtil.h"
#import "BPNetWorkService.h"
#import "BPFileManager.h"

typedef NS_ENUM(NSUInteger, EDownloadFinishType) {
    EDownloadNone,    //重新下载
    EDownloadEnd,     //已下载完成
    EDownloadRange,   //断点下载
};

@interface BPDownloader ()

@property (nonatomic, copy) NSString *downloadFilePath;
@property (nonatomic, copy) NSString *fileType;

@property (nonatomic, assign) long long startLenght;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (atomic, assign) NSTimeInterval timeStamp; // 单写多读

@end

@implementation BPDownloader

- (void)startDownload{
    __weak typeof(self)weakSelf = self;
    [self getFileHead:^(NSDictionary *headerFields) {
        NSLog(@"download file cache path %@", self.aContent.cacheFilePath);
        long long length = [headerFields[@"Content-Length"] longLongValue];
        weakSelf.aContent.serverFileSize = length;
        NSString *contentType = headerFields[@"Content-Type"];
        weakSelf.fileType = [contentType deleteBeforeString:@"/"];
        NSInteger type = [weakSelf needDownload:length];
        switch (type) {
            case EDownloadNone:
                [weakSelf downloadWithStart:-1];
                break;
                
            case EDownloadRange:
                [weakSelf downloadWithStart:[weakSelf getLocalFileLength]];
                break;
                
            case EDownloadEnd:
                // 成功
                [weakSelf downloadSuccess];
                break;
                
            default:
                break;
        }
    }];
}

- (void)cancel{
    [self.dataTask cancel];
}

// range下载
- (void)downloadWithStart:(long long)start{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.aContent.urlString]];
    if (start > 0) {
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", start];
        [request setValue:requestRange forHTTPHeaderField:@"Range"];
    }
    
    self.dataTask = [self.session dataTaskWithRequest:request];
    self.dataTask.taskDescription = [self.aContent.urlString MD5String];
    self.startLenght = start;
    [self.dataTask resume];
}

#pragma mark - 请求封装，获取文件头信息 从0下载 断点下载
// 获取请求头信息
- (void)getFileHead:(void (^)(NSDictionary *headerFields))aBlock{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.aContent.urlString]];
    request.HTTPMethod = @"HEAD";
    
    __weak typeof(self)weakSelf = self;
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            [weakSelf downloadFailWithError:error];
            return;
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            aBlock(((NSHTTPURLResponse*)response).allHeaderFields);
        }
    }];
    
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error == nil) {
        [self downloadSuccess];
    }else{
        [self downloadFailWithError:error];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    [self saveFileData:data];
    
    NSTimeInterval newTime = [NSDate date].timeIntervalSince1970;
    if (newTime - self.timeStamp < 1.0) {
        if (dataTask.countOfBytesReceived != dataTask.countOfBytesExpectedToReceive) {
            return;
        }
    }
    self.timeStamp = newTime; // 异步线程使用了 atomic 单写多读，只是预防多次回调卡主线程，所以问题不大
    if (self.downloadProgress) {
        self.downloadProgress(dataTask.countOfBytesReceived + self.startLenght,dataTask.countOfBytesExpectedToReceive + self.startLenght);
    }
}

#pragma mark - 失败成功回调
- (void)downloadSuccess{
    if (self.successBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.successBlock(self);
        });
    }
}

- (void)downloadFailWithError:(NSError *)aError{
    NSLog(@"head object failed %@",aError);
    if (self.failBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.failBlock(self,aError);
        });
    }
}

// 写入文件
- (void)saveFileData:(NSData*)aData{
    [BPFileManager saveData:aData toFilePath:self.downloadFilePath];
}

#pragma mark - 下载状态判断
- (EDownloadFinishType)needDownload:(long long)length{
    long long localLength = [self getLocalFileLength];
    
    if (localLength == 0) {
        return EDownloadNone;
    }
    
    if (localLength == length) {
        return EDownloadEnd;
    }
    
    //本地大于服务端 删除后重下
    if (localLength > length) {
        [self deleteLocalFile];
        return EDownloadNone;
    }
    
    // 本地小于服务端 就 断点下载
    return EDownloadRange;
}

#pragma mark - 文件处理
// 获取本地文件的大小长度
- (long long)getLocalFileLength{
    return [BPFileManager getLengthForFilePath:self.downloadFilePath];
}

// 删除文件
- (void)deleteLocalFile{
    return [BPFileManager deleteLocalFilePath:self.downloadFilePath];
}

#pragma mark - 懒加载
- (NSString *)downloadFilePath{
    if (!_downloadFilePath) {
        return self.aContent.cacheFilePath;
    }
    return _downloadFilePath;
}

@end
