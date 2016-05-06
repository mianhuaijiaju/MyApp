//
//  WLLCRequestConst.h
//  MyApp
//
//  Created by wangchong on 16/5/6.
//  Copyright © 2016年 wangchong. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 常量定义

#define NETWORK_UNCONNECTION        @"网络不给力哦，请稍后尝试"     //!< 无网络连接
#define NETWORK_TIMEOUT             @"网络不给力哦，请稍后尝试"     //!< 网络连接超时
#define NETWORK_ERROR               @"网络不给力哦，请稍后尝试"     //!< 网络连接错误

/**
 *  网络请求响应key
 */
extern NSString * const WLLC_ResponseStatus;                    //!< 网络请求响应的状态key
extern NSString * const WLLC_ResponseResult;                    //!< 网络请求响应的结果key
extern NSString * const WLLC_ResponseMessage;                   //!< 网络请求响应的消息key

/**
 *  错误域
 */
extern NSString * const WLLC_NetworkRequestErrorDomain;         //!< 网络请求错误域
extern NSString * const WLLC_NetworkJSONParserErrorDomain;      //!< JSON解析错误域
extern NSString * const WLLC_NetworkXMLParserErrorDomain;       //!< XML解析错误域
extern NSString * const WLLC_NetworkServerErrorDomain;          //!< 服务端错误域

#pragma mark - 枚举定义

/**
 *  HTTP请求方式
 */
typedef NS_ENUM(NSUInteger, WLLC_HTTPRequestType) {
    WLLC_HTTPRequestTypeGET,                                    //!< GET请求
    WLLC_HTTPRequestTypePOST,                                   //!< POST请求
    WLLC_HTTPRequestTypePUT,                                    //!< PUT请求
    WLLC_HTTPRequestTypeHEAD                                    //!< HEAD请求
};

/**
 *  HTTP请求返回数据类型
 */
typedef NS_ENUM(NSUInteger, WLLC_HTTPReponseType) {
    WLLC_HTTPResponseTypeJSON,                                 //!< 返回JSON格式的数据类型
    WLLC_HTTPResponseTypeXML,                                  //!< 返回XML格式的数据类型
    WLLC_HTTPResponseTyptUnknown                               //!< 返回位置格式的数据类型
};

/**
 *  网络请求的状态
 */
typedef NS_ENUM(NSUInteger, WLLC_SessionStatus) {
    WLLC_SessionStatusWait,                                    //!< 网络请求等待状态，此时连接对象位于重用队列中
    WLLC_SessionStatusStart,                                   //!< 网络请求开始状态，此时连接对象位于请求队列中
    WLLC_SessionStatusSuspend,                                 //!< 网络请求挂起状态，此时连接对象位于请求队列中
    WLLC_SessionStatusResume                                   //!< 网络请求恢复状态，此时连接对象位于请求队列中
};

#pragma mark - Block声明

@class WLLCURLRequest;

/**
 *  网络请求成功的回调Block
 *
 *  @param request    网络请求对象
 *  @param components 服务器返回的原始数据 (解析后的数据，只解析JSON,xml格式的)
 */
typedef void (^RequestFinishedBlock) (WLLCURLRequest *request, id components);

/**
 *  网络请求失败的回调Block
 *
 *  @param request    网络请求对象
 *  @param conponents 服务器返回的原始数据 (解析后的数据，只解析json,xml格式的)
 *  @param error      请求异常，包括网络请求异常与业务逻辑异常
 */
typedef void (^RequestFailedBlock) (WLLCURLRequest *request, id conponents, NSError *error);

/**
 *  取消请求的回调Block
 *
 *  @param request 网络请求对象
 */
typedef void (^RequestCancelBlock) (WLLCURLRequest *request);

/**
 *  请求链Block
 *
 *  @param request 网络请求对象
 *  @param error   错误描述
 */
typedef void (^RequestFilter) (WLLCURLRequest *request, NSError **error);

/**
 *  响应链Block
 *
 *  @param request 网络请求对象
 *  @param data    响应数据
 *  @param error   错误描述
 */
typedef void (^ResponseFilter) (WLLCURLRequest *request, id data, NSError **error);
