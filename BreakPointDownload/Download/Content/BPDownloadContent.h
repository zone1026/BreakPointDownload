//
//  BPDownloadContent.h
//  BreakPointDownload
//
//  Created by 黄亚州 on 2017/5/30.
//  Copyright © 2017年 黄亚州. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPNetWorkConfig.h"

typedef NS_ENUM(NSUInteger, EDownloadState) {
    EDownloadStateWaiting, // 等待下载
    EDownloadStateGoing,   // 下载中
    EDownloadStatePause,   // 暂停
    EDownloadStateFaile,   // 失败
    EDownloadStateFinish   // 完成
};

@interface BPDownloadContent : NSObject

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, assign) EDownloadState downLoadState;

// 下载的文件名字（ps:需要有后缀）
@property (nonatomic, copy) NSString *fileName;
// 下载文件的相对（Library/Caches）地址
@property (nonatomic, copy) NSString *filePath;
// 下载文件的完整地址（存储文件夹+文件名）
@property (nonatomic, copy) NSString *cacheFilePath;
// 服务器上文件总大小
@property (nonatomic, assign) long long serverFileSize;
@property (nonatomic, assign) long long currentFileSize;

// 扩展信息
@property (nonatomic, strong) NSDictionary *extenInfo;

@end
