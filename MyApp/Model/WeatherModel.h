//
//  WeatherModel.h
//  TestNetwork
//
//  Created by wangchong on 16/3/24.
//  Copyright © 2016年 wangchong. All rights reserved.
//

#import "BaseModel.h"

@interface WeatherModel : BaseModel

@property (nonatomic, copy) NSString *cityname_ch;
@property (nonatomic, copy) NSString *cityname_pinyin;
@property (nonatomic, copy) NSString *citycode;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *postCode;
@property (nonatomic, copy) NSString *weather;
@property (nonatomic, copy) NSString *current_temp;
@property (nonatomic, copy) NSString *low_temp;
@property (nonatomic, copy) NSString *high_temp;
@property (nonatomic, copy) NSString *wd;
@property (nonatomic, copy) NSString *ws;
@property (nonatomic, copy) NSString *sunrise;
@property (nonatomic, copy) NSString *sunset;
@property (nonatomic, copy) NSString *altitude; // 海拔
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *latitude;

@end
