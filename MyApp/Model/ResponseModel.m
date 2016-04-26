//
//  ResponseModel.m
//  TestNetwork
//
//  Created by wangchong on 16/3/24.
//  Copyright © 2016年 wangchong. All rights reserved.
//

#import "ResponseModel.h"

@implementation ResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"errNum":@"errNum",
             @"errMsg":@"errMsg",
             @"weatherModel":@"retData"
             };
}



@end
