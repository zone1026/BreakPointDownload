//
//  BPFileManager.h
//  BreakPointDownload
//
//  Created by 黄亚州 on 2017/5/30.
//  Copyright © 2017年 黄亚州. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPFileManager : NSObject

+ (NSString*)getDownloadCachePathWithFilePath:(NSString*)filePath WithFileName:(NSString*)fileName;

// 获取
+ (long long)getLengthForFilePath:(NSString*)filePath;

// 删除文件
+ (void)deleteLocalFilePath:(NSString*)filePath;

// 写入文件
+ (void)saveData:(NSData*)aData toFilePath:(NSString *)filePath;

@end
