//
//  BPDownloader.h
//  BreakPointDownload
//
//  Created by 黄亚州 on 2017/5/30.
//  Copyright © 2017年 黄亚州. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BPDownloadContent;
@interface BPDownloader : NSObject

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) BPDownloadContent *aContent;

@property (nonatomic, copy) void (^successBlock)(BPDownloader *data);
@property (nonatomic, copy) void (^failBlock)(BPDownloader *data, NSError *error);
@property (nonatomic, copy) void (^downloadProgress)(int64_t completeBytes, int64_t totalBytes);

- (void)startDownload;
- (void)cancel;

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;

@end
