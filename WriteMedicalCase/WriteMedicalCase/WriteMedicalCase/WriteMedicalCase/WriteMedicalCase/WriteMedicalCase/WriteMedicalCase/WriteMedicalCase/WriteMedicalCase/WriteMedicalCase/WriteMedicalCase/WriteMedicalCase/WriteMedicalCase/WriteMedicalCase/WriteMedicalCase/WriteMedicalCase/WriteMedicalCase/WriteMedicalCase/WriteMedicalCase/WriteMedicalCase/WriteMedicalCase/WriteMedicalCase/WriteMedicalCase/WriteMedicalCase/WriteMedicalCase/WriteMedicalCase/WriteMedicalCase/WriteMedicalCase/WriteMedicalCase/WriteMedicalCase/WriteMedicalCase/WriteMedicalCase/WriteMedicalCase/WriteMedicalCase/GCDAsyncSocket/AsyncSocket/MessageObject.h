//
//  MessageObject.h
//  NSStreamClient
//
//  Created by lsw on 14-2-19.
//  Copyright (c) 2014年 lsw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonDigest.h>

@interface MessageObject : NSObject

@property (nonatomic, strong) NSMutableDictionary *jsonDic;     //向服务器发送的字典，不要设置

@property (nonatomic, strong) NSString *sync_usrStr;               //用户ID
@property (nonatomic, strong) NSString *sync_pwdStr;               //密码
@property (nonatomic, assign) NSInteger sync_versionInt;           //版本号，有默认值
@property (nonatomic, strong) NSString *sync_snStr;                //同步序列号，有默认值
@property (nonatomic, strong) NSString *sync_appStr;               //静态字符串，有默认值
@property (nonatomic, assign) NSInteger sync_optInt;               //操作指令
@property (nonatomic, strong) id sync_data;                        //子字典或者数组，默认值为空
//@property (nonatomic, strong) NSArray *sync_dataArr;   //子数组，默认值为空

@property (nonatomic, assign) NSInteger sync_network;          //判断网络, 0表示没网, 1表示Wi-Fi, 2表示使用流量

@end
