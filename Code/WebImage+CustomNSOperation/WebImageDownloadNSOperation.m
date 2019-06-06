//
//  WebImageDownloadNSOperation.m
//  Code
//
//  Created by 兰旭平 on 2019/6/5.
//  Copyright © 2019 兰旭平. All rights reserved.
//

#import "WebImageDownloadNSOperation.h"
#import "NSString+FilePath.h"
/**
 同步的operation条件：
 1.重载main方法，这个方法里面放主业务逻辑。也需要查看cancel属性
 2.如果我们重载了getter和setter，必须确保调用是线程安全的。
 异步operation条件：
 1.重载start方法，和asynchronous，exciting，finished属性
 start方法中我们必须确保operation异步执行，在此方法中我们需要改变executing更新状态，发送executing KVO通知。当结束operation。必须更新isExecuting和isFinished状态，并触发kvo通知。当cancel一个operation时候，我们也要更新isFinished状态，即使此时operation还未执行。在queue 中的operation必须进入cancel状态后才可以被从operation中移除，
 注意：start里面不能调用[super start];在自定义异步operation中，我们完全自定义start，已经全部模拟了父类默认的start行为（start task && send KVO），在start方法里面，我们还要查看isCanceled属性，确保start task前，task是不是已经被取消。如果我们自定义了dependency，我们还需要发送isReady的KVO通知。
 */


@interface WebImageDownloadNSOperation ()
@property (nonatomic, readwrite, getter=isExecuting) BOOL executing;
@property (nonatomic, readwrite, getter=isFinished) BOOL finished;
@property (nonatomic, readwrite, getter=isCancelled) BOOL cancelled;
@property (nonatomic, readwrite, getter=isStarted) BOOL started;
@property (nonatomic, strong) NSRecursiveLock *lock;

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) complete complete;
@property (nonatomic, copy) NSString *tag;
@end

@implementation WebImageDownloadNSOperation
// 因为父类的属性是Readonly的，重载时如果需要setter的话则需要手动合成。
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancelled = _cancelled;

- (instancetype)initWithDownloadImageUrl:(NSString *)imageUrl complete:(complete)complete tag:(id)tag{
    if (self = [super init]) {
        _urlString = imageUrl;
        _lock = [NSRecursiveLock new];
        _tag = tag;
        _complete = complete;

        _finished = NO;
        _cancelled = NO;
        _executing = NO;
    }
    return self;
}

- (void)start {
    //延长生命周期，大型循环，自己创建线程
    @autoreleasepool {
        [_lock lock];
        self.started = YES;
        self.executing = YES;
//        [NSThread sleepForTimeInterval:1.5];
        NSLog(@"开始下载 %@",self.tag);
        if (self.cancelled) {
            NSLog(@"取消下载 %@",self.tag);
        }
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.urlString]];
        if (data) {
            NSLog(@"下载完成 %@",_tag);
            [self done];
            self.complete(data,_urlString);
            [data writeToFile:[_urlString getDowloadImagePath] atomically:YES];
        } else {
            NSLog(@"下载失败 %@",_tag);
            [self cancel];
            self.complete(nil,_urlString);
        }
        [_lock unlock];
    }
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
}

- (void)cancel {
    [_lock lock];
    if (!self.isCancelled) {
        [super cancel];
        self.cancelled = YES;
        if ([self isExecuting]) {
            self.executing = NO;
        }
        if (self.started) {
            self.finished = YES;
        }
    }
    [_lock unlock];
}

- (BOOL)isConcurrent { //并发
    return YES;
}

- (BOOL)isAsynchronous { //异步
    return YES;
}
#pragma mark - setter getter
- (void)setExecuting:(BOOL)executing {
    [_lock lock];
    if (_executing != executing) {
        [self willChangeValueForKey:@"isExecuting"];
        _executing = executing;
        [self didChangeValueForKey:@"isExecuting"];
    }
    [_lock lock];
}
- (BOOL)isExecuting {
    [_lock lock];
    BOOL executing = _executing;
    [_lock unlock];
    return executing;
}
- (void)setFinished:(BOOL)finished {
    [_lock lock];
    if (_finished != finished) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = finished;
        [self didChangeValueForKey:@"isFinished"];
    }
    [_lock unlock];
}
- (BOOL)isFinished {
    [_lock lock];
    BOOL finish = _finished;
    [_lock unlock];
    return finish;
}
- (void)setCancelled:(BOOL)cancelled {
    [_lock lock];
    if (_cancelled != cancelled) {
        [self willChangeValueForKey:@"isCancelled"];
        _cancelled = cancelled;
        [self didChangeValueForKey:@"isExecuting"];
    }
    [_lock unlock];
}
- (BOOL)isCancelled {
    [_lock lock];
    BOOL cancelled = _cancelled;
    [_lock unlock];
    return cancelled;
}
//苹果规定的
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"isExecuting"] ||
        [key isEqualToString:@"isFinished"] ||
        [key isEqualToString:@"isCancelled"]) {
        return NO;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}
@end
