//
//  DownloadNetWork.m
//  Code
//
//  Created by 兰旭平 on 2019/6/13.
//  Copyright © 2019 兰旭平. All rights reserved.
//

#import "DownloadNetWork.h"
#import <CommonCrypto/CommonDigest.h>

@interface DownloadNetWork ()<NSURLSessionDelegate>
@property (nonatomic) BOOL  mIsSuspend;
@property (nonatomic, copy) NSString* fileName;
@property (nonatomic, strong) NSData *myResumeData;
@end
@implementation DownloadNetWork
- (void)downloadFile:(NSString *)fileUrl isBreakpoint:(BOOL)breakpoint {
    if (!fileUrl || fileUrl.length == 0 || ![self checkIsUrlAtString:fileUrl]) {
        NSLog(@"fileUrl 无效");
        return;
    }
    
    NSURL *url = [NSURL URLWithString:fileUrl];
    if (!self.session) {
        self.fileName = [self md5:fileUrl];

        //1.创建session，设置代理
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[self currentDateStr]];
        config.allowsCellularAccess = YES;//允许蜂窝网络
        config.timeoutIntervalForRequest = 30;
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    //2.创建task
    if (breakpoint == NO) {
        self.downloadTask = [self.session downloadTaskWithURL:url];
    } else {
        [self downloadWithResumeData];//断点下载

    }
    [self.downloadTask resume];
    [self saveTmpFile]; //后台杀死应用程序，没有取消。不能获取到data。手动取消一次并断点下载
    
}
- (void)suspendDownload {
    if (self.mIsSuspend) {
        [self.downloadTask resume];
    }else {
        [self.downloadTask suspend];
    }
    self.mIsSuspend = !self.mIsSuspend;
}
- (void)cancelDownload {
    __weak typeof(self) weakSelf = self;
    [weakSelf.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        weakSelf.myResumeData = resumeData;
        weakSelf.downloadTask = nil;
        [resumeData writeToFile:[weakSelf getTmpFileUrl] atomically:NO];
    }];
}
- (void)downloadWithResumeData {
    if (!self.session) {
        return;
    }
    NSData *data = nil;
    if (self.myResumeData) {
        data = self.myResumeData;
    } else {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        data = [fileManager contentsAtPath:[self getTmpFileUrl]];
    }
    self.downloadTask = [self.session downloadTaskWithResumeData:data];
}


//提前保存临时文件 预防下载中杀掉app
//开启定时器
-(void)saveTmpFile{
    
    [NSTimer scheduledTimerWithTimeInterval:4 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        [self downloadTmpFile];
    }];
    
}

//杀掉app后 不至于下载的部分文件全部丢失
- (void)downloadTmpFile{
    __weak typeof(self) weakSelf = self;
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
        weakSelf.myResumeData = resumeData;
        weakSelf.downloadTask  = nil;
        [resumeData writeToFile:[weakSelf getTmpFileUrl] atomically:NO];
        
        self.downloadTask =  [self.session downloadTaskWithResumeData:resumeData];
        [self.downloadTask resume];
    }];
}

- (BOOL)checkIsUrlAtString:(NSString *)url {
    NSString *pattern = @"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&=]*)?";
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSArray *regexArray = [regex matchesInString:url options:0 range:NSMakeRange(0, url.length)];
    
    if (regexArray.count > 0) {
        return YES;
    }else {
        return NO;
    }
}
//获取当前时间 下载id标识用
- (NSString *)currentDateStr{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSTimeInterval timeInterval = [currentDate timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.f",timeInterval];
}
//用url获取文件名称 MD5加密
- (NSString *)md5:(NSString *)string{
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}
//未下载完的临时文件url地址
-(NSString*)getTmpFileUrl{
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"download.tmp"];
    NSLog(@"%@",filePath);
    
    //    NSString* url = [NSString stringWithFormat:@"/Users/LM/Desktop/%@.tmp",self.fileName];
    return filePath;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"location == %@",location.path);
    
    //拼接Doc 更换的路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    NSString *file = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",self.fileName]];
    
    //创建文件管理器
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath: file]) {
        //如果文件夹下有同名文件  则将其删除
        [manager removeItemAtPath:file error:nil];
    }
    NSError *saveError;
    [manager moveItemAtURL:location toURL:[NSURL URLWithString:file] error:&saveError];
    
    //将视频资源从原有路径移动到自己指定的路径
    BOOL success = [manager copyItemAtPath:location.path toPath:file error:nil];
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *url = [[NSURL alloc]initFileURLWithPath:file];
            if(self.mydelegate && [self.mydelegate respondsToSelector:@selector(downSucceed:tag:)])
                [self.mydelegate downSucceed:url tag:self.tag];
        });
    }
    //已经拷贝 删除缓存文件
    [manager removeItemAtPath:location.path error:nil];
    
    [manager removeItemAtPath:[self getTmpFileUrl] error:nil];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float dowProgress = 1.0 *totalBytesWritten / totalBytesExpectedToWrite;
    if (self.mydelegate && [self.mydelegate respondsToSelector:@selector(backDownprogress:tag:)]) {
        [self.mydelegate backDownprogress:dowProgress tag:self.tag];
    }
}
//下载失败调用
-(void)URLSession:(nonnull NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if(error && self.mydelegate && [self.mydelegate respondsToSelector:@selector(downError:tag:)] && error.code != -999)
        [self.mydelegate downError:error tag:self.tag];
}
@end
