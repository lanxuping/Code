//
//  NetViewController.m
//  Code
//
//  Created by 兰旭平 on 2019/6/13.
//  Copyright © 2019 兰旭平. All rights reserved.



//  [data appendData:data] 会导致内存暴增
/*
 在子线程中 使用NSFileHandle 来存数据，使用文件流 存数据
 */

#import "NetViewController.h"
#import "DownloadNetWork.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
@interface NetViewController () <DownLoadDelegate>
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *msgLable;
@property (nonatomic, strong) DownloadNetWork *downloadNetWork;
@end

@implementation NetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)beginDownload:(id)sender {
    NSString *fileUrl = @"https://pic.ibaotu.com/00/48/71/79a888piCk9g.mp4";
    if (!self.downloadNetWork) {
        self.downloadNetWork = [DownloadNetWork new];
        self.downloadNetWork.mydelegate = self;
        self.downloadNetWork.tag = 1;// 区别 不同下载
    }
    [self.downloadNetWork downloadFile:fileUrl isBreakpoint:NO];
}
- (IBAction)suspend:(id)sender {
    [self.downloadNetWork suspendDownload];
}
- (IBAction)breakpoint:(id)sender {
    NSString *fileUrl = @"https://pic.ibaotu.com/00/48/71/79a888piCk9g.mp4";
    if (!self.downloadNetWork) {
        self.downloadNetWork = [DownloadNetWork new];
        self.downloadNetWork.mydelegate = self;
        self.downloadNetWork.tag = 1;// 区别 不同下载
    }
    [self.downloadNetWork downloadFile:fileUrl isBreakpoint:YES];
}
- (IBAction)cancleDownload:(id)sender {
    [self.downloadNetWork cancelDownload];
}

#pragma mark - delegate
//进度返回   每一个数据包回来调用一次
- (void)backDownprogress:(float)progress tag:(NSInteger)tag{
    
    self.progress.progress = progress;
    self.msgLable.text = [NSString stringWithFormat:@"%0.1f%@",progress*100,@"%"];
}

//下载成功
- (void)downSucceed:(NSURL*)url tag:(NSInteger)tag{
    NSLog(@"下载成功,准备播放");
    [self paly: url];
    self.progress.progress = 0;
    self.msgLable.text = @"0.0%";
    self.downloadNetWork = nil;
}

//下载失败
- (void)downError:(NSError*)error tag:(NSInteger)tag{
    
    self.downloadNetWork = nil;
    self.progress.progress = 0;
    self.msgLable.text = @"0.0%";
    NSLog(@"下载失败,请再次下载 :%@",error);
}



//传入本地url 进行视频播放
-(void)paly:(NSURL*)playUrl{
    
    //系统的视频播放器
    AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
    //播放器的播放类
    AVPlayer * player = [[AVPlayer alloc]initWithURL:playUrl];
    controller.player = player;
    //自动开始播放
    [controller.player play];
    //推出视屏播放器
    [self  presentViewController:controller animated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
