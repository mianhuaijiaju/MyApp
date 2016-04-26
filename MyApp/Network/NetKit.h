//
//  NetKit.h
//  TestNetwork
//
//  Created by wangchong on 16/3/24.
//  Copyright © 2016年 wangchong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessHandler)(NSData *data);
typedef void (^FailureHandler)(NSError *error);

@interface NetKit : NSObject

+ (void)getRequestWithURL:(NSString *)urlStr urlParams:(NSDictionary *)urlParams headerParams:(NSDictionary *)headerParams successHandler:(SuccessHandler)successHandler failureHandler:(FailureHandler)failureHandler;

+ (void)postRequestWithURL:(NSString *)urlStr params:(NSDictionary *)params successHandler:(SuccessHandler)successHandler failureHandler:(FailureHandler)failureHandler;

@end
