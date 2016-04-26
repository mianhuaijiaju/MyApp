//
//  WeatherModel.m
//  TestNetwork
//
//  Created by wangchong on 16/3/24.
//  Copyright © 2016年 wangchong. All rights reserved.
//

#import "WeatherModel.h"

@implementation WeatherModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"cityname_ch":@"city",
             @"cityname_pinyin":@"pinyin",
             @"citycode":@"citycode",
             @"date":@"date",
             @"time":@"time",
             @"postCode":@"postCode",
             @"longitude":@"longitude",
             @"latitude":@"latitude",
             @"altitude":@"altitude",
             @"weather":@"weather",
             @"current_temp":@"temp",
             @"low_temp":@"l_tmp",
             @"high_temp":@"h_tmp",
             @"wd":@"WD",
             @"ws":@"WS",
             @"sunrise":@"sunrise",
             @"sunset":@"sunset"
             };
}

@end
