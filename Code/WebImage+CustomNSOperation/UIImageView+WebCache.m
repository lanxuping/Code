//
//  UIImageView+WebImage.m
//  Code
//
//  Created by 兰旭平 on 2019/6/4.
//  Copyright © 2019 兰旭平. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import <objc/runtime.h>
#import "WebImageManager.h"
@implementation UIImageView (WebCache)
- (void)my_setImageWithUrlString:(NSString *)urlString tag:(NSString *)tag {
    self.image = nil;
    if (!urlString) {
        NSLog(@"urlString 为空");
        return;
    }
    if ([self.private_urlString isEqualToString:urlString]) {
        NSLog(@"%@ 两次下载地址一样，没必要重复下载",self.private_tag);
    }
    
    //cell 滑动时， 下载ing，（网速，图片太大）  取消下载
    if (self.private_urlString && self.private_urlString.length > 0 && ![self.private_urlString isEqualToString:urlString]) {
        NSLog(@"取消之前的下载 %@",self.private_tag);
        [[WebImageManager shareManager] cancelDownloadImageViewWithUrlString:urlString];
    }
    //新的下载 记录
    self.private_tag = tag;
    self.private_urlString = urlString;
    
    [[WebImageManager shareManager] downloadImageWithUrlString:urlString completeHandle:^(UIImage *image) {
        if (image && [urlString isEqualToString:self.private_urlString]) {
            self.image = image;
            self.private_tag = nil;
            self.private_urlString = nil;
        }
    } tag:tag];
}
- (NSString *)private_urlString {
    return objc_getAssociatedObject(self, @selector(private_urlString));
}
- (void)setPrivate_urlString:(NSString *)private_urlString {
    objc_setAssociatedObject(self, @selector(private_urlString), private_urlString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)private_tag {
    return objc_getAssociatedObject(self, @selector(private_tag));
}
- (void)setPrivate_tag:(NSString *)private_tag {
    objc_setAssociatedObject(self, @selector(private_tag), private_tag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end
