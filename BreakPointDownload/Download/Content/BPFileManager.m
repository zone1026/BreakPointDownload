//
//  BPFileManager.m
//  BreakPointDownload
//
//  Created by 黄亚州 on 2017/5/30.
//  Copyright © 2017年 黄亚州. All rights reserved.
//

#import "BPFileManager.h"

@implementation BPFileManager

+ (NSString*)getDownloadCachePathWithFilePath:(NSString*)filePath WithFileName:(NSString*)fileName {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    return [self getRootPath:[NSString stringWithFormat:@"%@/%@", cachePath, filePath] fileName:fileName];
}

+ (NSString *)getRootPath:(NSString*)path fileName:(NSString*)fileName{
    // 如果路径不存在就创建
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (fileName != nil) {
        return path = [path stringByAppendingPathComponent:fileName];
    }
    return path;
}

// 获取本地文件的大小长度
+ (long long)getLengthForFilePath:(NSString*)filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

+ (void)deleteLocalFilePath:(NSString*)filePath{
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}


// 写入文件
+ (void)saveData:(NSData*)aData toFilePath:(NSString *)filePath{
    NSFileHandle *fp = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (fp == nil) {
        [aData writeToFile:filePath atomically:YES];
        return;
    }
    
    [fp seekToEndOfFile];
    [fp writeData:aData];
    [fp closeFile];
}

@end
