//
//  DownloadNetWork.h
//  Code
//
//  Created by 兰旭平 on 2019/6/13.
//  Copyright © 2019 兰旭平. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol DownLoadDelegate <NSObject>
@optional
- (void)backDownprogress:(float)progress tag:(NSInteger)tag;
- (void)downSucceed:(NSURL*)url tag:(NSInteger)tag;
- (void)downError:(NSError*)error tag:(NSInteger)tag;
@end

@interface DownloadNetWork : NSObject
@property (nonatomic, weak) id<DownLoadDelegate> mydelegate;
@property (nonatomic, strong) NSURLSession* session;
@property (nonatomic, assign) NSInteger tag; //某个文件的下载标记
@property (nonatomic, strong) NSURLSessionDownloadTask* downloadTask;
- (void)downloadFile:(NSString *)fileUrl isBreakpoint:(BOOL)breakpoint;

//暂停 继续 取消 文件下载
-(void)suspendDownload;
-(void)cancelDownload;
@end

