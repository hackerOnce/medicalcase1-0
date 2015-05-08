//
//  WLKTooles.h
//  MedImageReader
//
//  Created by ihefe36 on 14/12/25.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonTooles.h"
#define NetworkJudge [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus > 0
#define DataCenter [WLKDataCenter getInstance]
#define DataBaseHelper [WLKDataCenter getInstance].databaseHelper
#define NetClient [WLKDataCenter getInstance].netClient
@interface WLKTooles : NSObject
#pragma mark - methods
/**
 * 单例方法
 */
+ (instancetype)getInstance;

/**
 * 判断目前是否可访问网络
 */
+ (BOOL)currentNetworkStatus;

@end
