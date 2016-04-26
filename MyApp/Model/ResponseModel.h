//
//  ResponseModel.h
//  TestNetwork
//
//  Created by wangchong on 16/3/24.
//  Copyright © 2016年 wangchong. All rights reserved.
//

#import "BaseModel.h"

@class WeatherModel;

@interface ResponseModel : BaseModel

@property (nonatomic, strong) NSNumber *errNum;
@property (nonatomic, copy) NSString *errMsg;
@property (nonatomic, strong) WeatherModel *weatherModel;

@end
