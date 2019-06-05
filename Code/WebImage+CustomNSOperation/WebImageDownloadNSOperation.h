//
//  WebImageDownloadNSOperation.h
//  Code
//
//  Created by 兰旭平 on 2019/6/5.
//  Copyright © 2019 兰旭平. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^complete)(id data,id string);

NS_ASSUME_NONNULL_BEGIN

@interface WebImageDownloadNSOperation : NSOperation
- (instancetype)initWithDownloadImageUrl:(NSString *)imageUrl complete:(complete)complete tag:(id)tag;
@end

NS_ASSUME_NONNULL_END
