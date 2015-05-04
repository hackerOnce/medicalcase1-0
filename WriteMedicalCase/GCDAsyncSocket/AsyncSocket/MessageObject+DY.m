//
//  MessageObject+DY.m
//  community
//
//  Created by ihefe33 on 3/6/15.
//  Copyright (c) 2015 ihefe. All rights reserved.
//

#import "MessageObject+DY.h"
#import "MBProgressHUD+MJ.h"
#import "Reachability.h"
@interface MessageObject()

@end

@implementation MessageObject (DY)





+(void)messageObjectWithUsrStr:(NSString *)usrStr pwdStr:(NSString *)pwdStr iHMsgSocket:(IHMsgSocket *)socket optInt:(NSInteger)optInt dictionary:(NSMutableDictionary *)dicM block:(void (^)(IHSockRequest *))block failConection:(void (^)(NSError *))fail
{
    if ([self isConnectionAvailable]) {
        MessageObject *messageObject = [[MessageObject alloc]init];
        messageObject.sync_usrStr = usrStr;
        messageObject.sync_pwdStr = pwdStr;
        messageObject.sync_optInt = optInt;
        messageObject.sync_snStr = @"1234";
        messageObject.sync_data = dicM;
        [socket sendMsg:messageObject completed:block failConnection:fail];
    }

}

+(void)messageObjectWithUsrStr:(NSString *)usrStr pwdStr:(NSString *)pwdStr view:(UIView *)view iHMsgSocket:(IHMsgSocket *)socket optInt:(NSInteger)optInt dictionary:(NSMutableDictionary *)dicM block:(void (^)(IHSockRequest *))block failConection:(void (^)(NSError *))fail
{
    if ([self isConnectionAvailable:view]) {
        [MBProgressHUD showMessage:@"正在加载..." toView:view dismissAfterDelay:4];
        MessageObject *messageObject = [[MessageObject alloc]init];
        messageObject.sync_usrStr = usrStr;
        messageObject.sync_pwdStr = pwdStr;
        messageObject.sync_optInt = optInt;
        messageObject.sync_snStr = [self getCurrentDateStr];
        messageObject.sync_data = dicM;
        [socket sendMsg:messageObject completed:block failConnection:fail];
    }

}
+(void)messageObjectWithIHMsgSocket:(IHMsgSocket *)socket optInt:(NSInteger)optInt dictionary:(NSMutableDictionary *)dicM block:(void (^)(IHSockRequest *))block failConection:(void (^)(NSError *))fail
{
    if ([self isConnectionAvailable]) {
        MessageObject *messageObject = [[MessageObject alloc]init];
        messageObject.sync_usrStr = @"1";
        messageObject.sync_pwdStr = @"test";
        messageObject.sync_optInt = optInt;
        messageObject.sync_snStr = [self getCurrentDateStr];
        messageObject.sync_data = dicM;
        [socket sendMsg:messageObject completed:block failConnection:fail];
    }
    
}
+(void)messageObjectWithView:(UIView *)view iHMsgSocket:(IHMsgSocket *)socket optInt:(NSInteger)optInt dictionary:(NSMutableDictionary *)dicM block:(void (^)(IHSockRequest *))block failConection:(void (^)(NSError *))fail
{
    if ([self isConnectionAvailable:view]) {
        [MBProgressHUD showMessage:@"正在加载..." toView:view dismissAfterDelay:4];
        MessageObject *messageObject = [[MessageObject alloc]init];
        messageObject.sync_usrStr = @"1";
        messageObject.sync_pwdStr = @"test";
        messageObject.sync_optInt = optInt;
        messageObject.sync_snStr = [self getCurrentDateStr];
        messageObject.sync_data = dicM;
        [socket sendMsg:messageObject completed:block failConnection:fail];
    }

}

+(BOOL)isConnectionAvailable:(UIView *)view{
 
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            break;
    }
    
    if (!isExistenceNetwork) {
        [UIView viewWithMessage:@"无网络连接" toView:view];
        return NO;
    }
    
    return isExistenceNetwork;
}
+(BOOL)isConnectionAvailable
{
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            break;
    }
    
    if (!isExistenceNetwork) {
        return NO;
    }
    
    return isExistenceNetwork;
}

+(NSString *)getCurrentDateStr
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy_MM_dd_HH_mm_ss_SSS"];
    NSString *dateStr = [format stringFromDate:currentDate];
    
    return dateStr;
}

@end
