//
//  WebImageManager.m
//  Code
//
//  Created by 兰旭平 on 2019/6/4.
//  Copyright © 2019 兰旭平. All rights reserved.
//

#import "WebImageManager.h"
#import <UIKit/UIKit.h>
#import "NSString+FilePath.h"
#import "WebImageDownloadNSOperation.h"

NSString * ApplicationActionRemoveWebImageCache = @"ApplicationActionRemoveWebImageCache";

@interface WebImageManager ()
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *imageCacheDict;//内存
@property (nonatomic, strong) NSMutableDictionary *operationDict;//事物
@property (nonatomic, strong) NSMutableDictionary *completeHandleDict;//存在需要下载重复文件，但是不会下载，保存回调。等下载第一个成功后返回
@end
@implementation WebImageManager
+ (instancetype)shareManager {
    static WebImageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WebImageManager alloc] init];
    });
    return manager;
}
- (instancetype)init {
    if (self = [super init]) {
        self.queue.maxConcurrentOperationCount = 3;
        //注册内存警告
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarning) name:ApplicationActionRemoveWebImageCache object:nil];
        
    }
    return self;
}
- (void)downloadImageWithUrlString:(NSString *)urlString completeHandle:(kcompleteHandle)completeHandle tag:(nonnull NSString *)tag{
    //从内存加载
    UIImage *cacheImage = self.imageCacheDict[urlString];
    if (cacheImage) {
        NSLog(@"从内存加载image数据");
        completeHandle(cacheImage);
        return;
    }
    
    //从磁盘加载
    cacheImage = [UIImage imageWithContentsOfFile:[urlString getDowloadImagePath]];
    if (cacheImage) {
        NSLog(@"从磁盘加载image数据");
        completeHandle(cacheImage);
        [self.imageCacheDict setObject:cacheImage forKey:urlString];
        return;
    }
    
    if (self.operationDict[urlString]) {
        NSLog(@"稍等,%@正在下载中",tag);

        NSMutableArray *arr = self.completeHandleDict[urlString];
        if (!arr) {
            arr = [NSMutableArray array];
        }
        [arr addObject:completeHandle];
        [self.completeHandleDict setObject:arr forKey:urlString];
        return;
    }
    
    
    
    WebImageDownloadNSOperation *op = [[WebImageDownloadNSOperation alloc] initWithDownloadImageUrl:urlString complete:^(NSData *data, NSString *string) {
        if (data) {
            UIImage *downloadImage = [UIImage imageWithData:data];
            if (downloadImage) {
                [self.imageCacheDict setObject:downloadImage forKey:urlString];
                [self.operationDict removeObjectForKey:urlString];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completeHandle(downloadImage);
                    for (kcompleteHandle handle in self.completeHandleDict[urlString]) {
                        handle(downloadImage);
                    }
                    [self.completeHandleDict removeObjectForKey:urlString];
                }];
            }
        }
    } tag:tag];
    //操作加入队列
    [self.queue addOperation:op];
    //操作缓存
    [self.operationDict setObject:op forKey:urlString];
}
//下载取消操作
- (void)cancelDownloadImageViewWithUrlString:(NSString *)urlString {
    [self.operationDict removeObjectForKey:urlString];
    [self.completeHandleDict removeObjectForKey:urlString];
    WebImageDownloadNSOperation *op = self.operationDict[urlString];
    [op cancel];
}
- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}
- (NSMutableDictionary *)imageCacheDict {
    if (!_imageCacheDict) {
        _imageCacheDict = [NSMutableDictionary dictionary];
    }
    return _imageCacheDict;
}
- (NSMutableDictionary *)operationDict {
    if (!_operationDict) {
        _operationDict = [NSMutableDictionary dictionary];
    }
    return _operationDict;
}
- (NSMutableDictionary *)completeHandleDict {
    if (!_completeHandleDict) {
        _completeHandleDict = [NSMutableDictionary dictionary];
    }
    return _completeHandleDict;
}
- (void)memoryWarning {
    NSLog(@"收到内存警告");
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        //内存数据删除
        [self.imageCacheDict removeAllObjects];
        //已经有内存警告就不执行操作
        [self.queue cancelAllOperations];
        //清空操作
        [self.operationDict removeAllObjects];
        //操作缓存清除
        [self.completeHandleDict removeAllObjects];
        //清除磁盘
        NSFileManager *fieldManager = [NSFileManager defaultManager];
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        cachePath = [cachePath stringByAppendingPathComponent:@"img"];
        if ([fieldManager fileExistsAtPath:cachePath]) {
            BOOL isDel = [fieldManager removeItemAtPath:cachePath error:nil];
            if (isDel) {
                NSLog(@"删除沙盒数据成功");
            }
        }
    }];
    [queue addOperation:op];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}
@end
