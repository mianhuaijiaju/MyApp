//
//  NetKit.m
//  TestNetwork
//
//  Created by wangchong on 16/3/24.
//  Copyright © 2016年 wangchong. All rights reserved.
//

#import "NetKit.h"

@interface NetKit()<NSURLConnectionDelegate>

@end

@implementation NetKit

+ (void)getRequestWithURL:(NSString *)urlStr urlParams:(NSDictionary *)urlParams headerParams:(NSDictionary *)headerParams successHandler:(SuccessHandler)successHandler failureHandler:(FailureHandler)failureHandler {
    
    // 1:configure the urlParams
    __block NSMutableString *url = [NSMutableString string];
    if (urlParams) {
        [urlParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [url appendString:[NSString stringWithFormat:@"%@=%@&",key,obj]];
        }];
        
        url = (NSMutableString *)[url substringToIndex:url.length - 1];
        url = (NSMutableString *)[NSString stringWithFormat:@"%@?%@",urlStr,url];
    }
    
    NSURL *requestURL = [NSURL URLWithString:url];
    if (!requestURL) {
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request setHTTPMethod:@"GET"];
    
    // 2:configure the headerParams
    [headerParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:(NSString *)key];
    }];
    
    // 3:load the request
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data) {
            !successHandler ?: successHandler(data);
        } else {
            !failureHandler ?: failureHandler(connectionError);
        }
    }];
}

+ (void)postRequestWithURL:(NSString *)urlStr params:(NSDictionary *)params successHandler:(SuccessHandler)successHandler failureHandler:(FailureHandler)failureHandler {
    
}

@end
