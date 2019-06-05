//
//  UIImageView+WebImage.h
//  Code
//
//  Created by 兰旭平 on 2019/6/4.
//  Copyright © 2019 兰旭平. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (WebCache)
@property (nonatomic, copy) NSString *private_urlString;
@property (nonatomic, copy) NSString *private_tag;
- (void)my_setImageWithUrlString:(NSString *)urlString tag:(NSString *)tag;
@end

NS_ASSUME_NONNULL_END
