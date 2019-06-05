//
//  ViewModel.h
//  Code
//
//  Created by 兰旭平 on 2019/6/4.
//  Copyright © 2019 兰旭平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"
NS_ASSUME_NONNULL_BEGIN

@interface ViewModel : NSObject

- (void)loadDataSuccess:(void(^)(id _Nonnull data))block;

@end

NS_ASSUME_NONNULL_END
