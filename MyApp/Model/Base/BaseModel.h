//
//  WeatherModel.h
//  TestNetwork
//
//  Created by wangchong on 16/3/24.
//  Copyright © 2016年 wangchong. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface BaseModel : MTLModel <MTLJSONSerializing>

+ (NSDictionary *)JSONKeyPathsByPropertyKey;

@end
