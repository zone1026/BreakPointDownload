//
//  BPDownloadContent.m
//  BreakPointDownload
//
//  Created by 黄亚州 on 2017/5/30.
//  Copyright © 2017年 黄亚州. All rights reserved.
//

#import "BPDownloadContent.h"
#import "BPFileManager.h"

@interface BPDownloadContent ()

@end

@implementation BPDownloadContent

- (NSString *)cacheFilePath{
    return [BPFileManager getDownloadCachePathWithFilePath:(self.filePath?self.filePath:@"") WithFileName:self.fileName];
}

- (long long)currentFileSize{
    return [BPFileManager getLengthForFilePath:self.cacheFilePath];
}

@end
