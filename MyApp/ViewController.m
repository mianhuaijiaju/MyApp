//
//  ViewController.m
//  MyApp
//
//  Created by wangchong on 16/4/25.
//  Copyright © 2016年 wangchong. All rights reserved.
//

#import "ViewController.h"
#import "NetKit.h"
#import "ResponseModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 200, 100)];
    button.backgroundColor = [UIColor cyanColor];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonAction:(UIButton *)button {
    
    NSString *baseUrl = @"http://apis.baidu.com/apistore/weatherservice/cityname";
    
    NSDictionary *urlParams = @{@"cityname":@"%E5%8C%97%E4%BA%AC",@"haah":@"123456",@"hehehe":@"adfgghh"};
    NSDictionary *headerParams = @{@"apikey":@"90d2cc70534e916637c483533f3caef1",@"header":@"12345",@"header2":@"adffg"};
    
    [NetKit getRequestWithURL:baseUrl urlParams:urlParams headerParams:headerParams successHandler:^(NSData *data) {
        
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"responseBody=========:%@",responseBody);
        
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (!dic || error) {
            NSLog(@"response不是合法json");
            return;
        }
        
        if ([NSJSONSerialization isValidJSONObject:dic]) {
            NSInteger resultCode = [dic[@"errNum"] integerValue];
            if (resultCode != 0) {
                NSLog(@"返回结果失败");
            }
            //                    NSDictionary *result = dic[@"retData"];
            //                    WeatherModel *weatherModel = [MTLJSONAdapter modelOfClass:[WeatherModel class] fromJSONDictionary:result error:&error];
            
            
            ResponseModel *model = [MTLJSONAdapter modelOfClass:[ResponseModel class] fromJSONDictionary:dic error:&error];
            NSLog(@"model===========:%@",model);
            
            if (error) {
                NSLog(@"model解析错误");
            }
        } else {
            NSLog(@"response不是合法json");
        }
    } failureHandler:^(NSError *error) {
        NSLog(@"fail");
    }];
}


@end
