//
//  ViewController.m
//  BreakPointDownload
//
//  Created by 黄亚州 on 2017/5/30.
//  Copyright © 2017年 黄亚州. All rights reserved.
//

#import "ViewController.h"
#import "BPDownloadContent.h"
#import "BPNetWorkService.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    BPDownloadContent *aContent = [[BPDownloadContent alloc] init];
    aContent.urlString = @"http://static.meishubao.com/video/2016-05-18/mCah6DSkD5.mp4";//http://hb-video.oss-cn-beijing.aliyuncs.com/20/1/0/227/f6ed9ef063ba51ff9440959c70fce0e8.mp4
    aContent.cacheFilePath = cacheDir;
    aContent.fileName = @"mCah6DSkD5.mp4";
    aContent.extenInfo = @{@"11":@"11",@"22":@[@"aa",@"aa1"]};
    [[BPNetWorkService shared] downloadContent:aContent onProgress:^(int64_t completeBytes, int64_t totalBytes) {
        CGFloat progress = (double)completeBytes / (double)totalBytes;
        NSLog(@"进度：%.5f",progress);
    } onComplete:^(BPDownloadContent* aContent, NSError *aError) {
        NSLog(@"%@",aContent.cacheFilePath);
        NSLog(@"%@",aError);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
