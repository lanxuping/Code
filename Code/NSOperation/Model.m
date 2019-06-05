//
//  Model.m
//  Code
//
//  Created by 兰旭平 on 2019/6/4.
//  Copyright © 2019 兰旭平. All rights reserved.
//

#import "Model.h"

@implementation Model
- (NSString *)description{
    return [NSString stringWithFormat:@"%@ 售价 : %@",self.title,self.money];
}
@end
