//
//  WLKTooles.m
//  MedImageReader
//
//  Created by ihefe36 on 14/12/25.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import "WLKTooles.h"

@implementation WLKTooles
+ (instancetype)getInstance
{
    static WLKTooles *center = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[WLKTooles alloc] init];
    });
    return center;
}

+ (BOOL)currentNetworkStatus
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    BOOL connected;
    const char *host = "http://www.baidu.com";
    
//    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host);
//    SCNetworkReachabilityFlags flags;
//    connected = SCNetworkReachabilityGetFlags(reachability, &flags);
//    BOOL isConnected = YES;
//    isConnected = connected && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
//    CFRelease(reachability);
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
//    if(!isConnected)
//    {
//        return NO;
//    }
//    else
//    {
//        return isConnected;
//    }
    
    return false;
}

@end
