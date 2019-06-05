//
//  WebImageManager.h
//  Code
//
//  Created by 兰旭平 on 2019/6/4.
//  Copyright © 2019 兰旭平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void(^kcompleteHandle)(UIImage *);
NS_ASSUME_NONNULL_BEGIN

@interface WebImageManager : NSObject
+ (instancetype)shareManager;
- (void)downloadImageWithUrlString:(NSString *)urlString completeHandle:(kcompleteHandle)completeHandle tag:(NSString *)tag;
- (void)cancelDownloadImageViewWithUrlString:(NSString *)urlString;
@end

NS_ASSUME_NONNULL_END
