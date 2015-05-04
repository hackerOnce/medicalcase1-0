//
//  MessageObject+DY.h
//  community
//
//  Created by ihefe33 on 3/6/15.
//  Copyright (c) 2015 ihefe. All rights reserved.
//

#import "MessageObject.h"
#import "IHMsgSocket.h"
#import "UIView+DY.h"
@interface MessageObject (DY)

/**
 *  请求数据方法
 *
 *  @param usrStr 用户名
 *  @param pwdStr 密码
 *  @param socket IHMsgSocket
 *  @param optInt 端口号
 *  @param dicM   发送给服务器的数据
 *  @param block  返回数据
 */
+(void)messageObjectWithUsrStr:(NSString *)usrStr pwdStr:(NSString *)pwdStr iHMsgSocket:(IHMsgSocket *)socket  optInt:(NSInteger)optInt dictionary:(NSMutableDictionary *)dicM block:(void(^)(IHSockRequest *request))block failConection:(void (^)(NSError *))fail;

/**
 *  请求数据方法
 *
 *  @param usrStr 用户名
 *  @param pwdStr 密码
 *  @param view   等待加载视图
 *  @param socket IHMsgSocket
 *  @param optInt 端口号
 *  @param dicM   发送给服务器的数据
 *  @param block  返回数据
 */
+(void)messageObjectWithUsrStr:(NSString *)usrStr pwdStr:(NSString *)pwdStr view:(UIView *)view iHMsgSocket:(IHMsgSocket *)socket  optInt:(NSInteger)optInt dictionary:(NSMutableDictionary *)dicM block:(void(^)(IHSockRequest *request))block;

/**
 *  请求数据方法
 *
 *  @param socket IHMsgSocket
 *  @param optInt 端口号
 *  @param dicM   发送给服务器的数据
 *  @param block  返回数据
 */
+(void)messageObjectWithIHMsgSocket:(IHMsgSocket *)socket optInt:(NSInteger)optInt dictionary:(NSMutableDictionary *)dicM block:(void(^)(IHSockRequest *request))block;

/**
 *  请求数据方法
 *
 *  @param view   等待加载视图
 *  @param socket IHMsgSocket
 *  @param optInt 端口号
 *  @param dicM   发送给服务器的数据
 *  @param block  返回数据
 */

+(void)messageObjectWithView:(UIView *)view iHMsgSocket:(IHMsgSocket *)socket optInt:(NSInteger)optInt dictionary:(NSMutableDictionary *)dicM block:(void(^)(IHSockRequest *request))block;

/**
 *  监测网络状态
 *
 */
+(BOOL)isConnectionAvailable;
/**
 *  获取当前时间
 *
 */
+(NSString *)getCurrentDateStr;

@end
