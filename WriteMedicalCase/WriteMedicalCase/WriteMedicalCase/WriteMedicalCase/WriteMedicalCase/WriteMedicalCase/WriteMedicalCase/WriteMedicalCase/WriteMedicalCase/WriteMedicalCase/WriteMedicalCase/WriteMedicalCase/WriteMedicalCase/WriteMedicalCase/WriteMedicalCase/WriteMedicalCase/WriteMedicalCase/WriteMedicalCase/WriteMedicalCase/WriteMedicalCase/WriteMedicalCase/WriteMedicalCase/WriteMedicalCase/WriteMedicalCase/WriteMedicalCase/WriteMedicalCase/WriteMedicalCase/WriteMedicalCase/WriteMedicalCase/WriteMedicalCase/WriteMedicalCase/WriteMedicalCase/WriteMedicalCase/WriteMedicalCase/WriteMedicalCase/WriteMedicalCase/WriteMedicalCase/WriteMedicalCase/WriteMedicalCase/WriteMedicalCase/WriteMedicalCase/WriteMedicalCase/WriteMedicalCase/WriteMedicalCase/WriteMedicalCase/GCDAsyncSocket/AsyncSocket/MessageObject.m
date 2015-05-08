//
//  MessageObject.m
//  NSStreamClient
//
//  Created by lsw on 14-2-19.
//  Copyright (c) 2014年 lsw. All rights reserved.
//

#import "MessageObject.h"
#import <UIKit/UIKit.h>
@implementation MessageObject

@synthesize jsonDic;

@synthesize sync_usrStr;
@synthesize sync_pwdStr;
@synthesize sync_versionInt;
@synthesize sync_snStr;
@synthesize sync_appStr;
@synthesize sync_optInt;
@synthesize sync_data;
//@synthesize sync_dataArr;
@synthesize sync_network;

- (id)init
{
    self = [super init];
    if (self)
    {
        sync_versionInt = 1;
        sync_snStr = @"1234";
        sync_appStr = @"com.ihefe.health.chat";
        
        jsonDic = [[NSMutableDictionary alloc] init];
        
        [jsonDic setObject:[NSNumber numberWithInteger:sync_versionInt] forKey:@"sync_version"];
        NSString *deviceStr =[[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        [jsonDic setObject:deviceStr forKey:@"sync_device"];     //设备号加入聊天中
        
//        [jsonDic setObject:[NSNumber numberWithInteger:sync_snInt] forKey:@"sync_sn"];
        [jsonDic setObject:sync_snStr forKey:@"sync_sn"];
        [jsonDic setObject:sync_appStr forKey:@"sync_app"];
        [jsonDic setObject:[NSDictionary dictionary] forKey:@"sync_data"];
        
    }
    
    return self;
}

#pragma mark - 32位md5加密
- (NSString *)getMd5_32Bit_String:(NSString *)srcString
{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (unsigned int)strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    return result;
}

//重写set方法
- (void)setSync_snStr:(NSString *)_sync_snStr
{
    if ([_sync_snStr length] > 0)
    {
        sync_snStr = _sync_snStr;
        
        [jsonDic setObject:sync_snStr forKey:@"sync_sn"];
    }
}

//重写set方法
- (void)setSync_usrStr:(NSString *)_sync_usrStr
{
    if ([_sync_usrStr length] > 0)
    {
        sync_usrStr = _sync_usrStr;
        [jsonDic setObject:sync_usrStr forKey:@"sync_usr"];
    }
}

//重写set方法
- (void)setSync_pwdStr:(NSString *)_sync_pwdStr
{
    if ([_sync_pwdStr length] > 0)
    {
        sync_pwdStr = [self getMd5_32Bit_String:_sync_pwdStr];
        [jsonDic setObject:sync_pwdStr forKey:@"sync_pwd"];
    }
}

//重写set方法
- (void)setSync_optInt:(NSInteger)_sync_optInt
{
    if (_sync_optInt != 0)
    {
        sync_optInt = _sync_optInt;
        [jsonDic setObject:[NSNumber numberWithInteger:sync_optInt] forKey:@"sync_opt"];
    }
}

//重写set方法
- (void)setSync_network:(NSInteger)_sync_network
{
    sync_network = _sync_network;
    [jsonDic setObject:[NSNumber numberWithInteger:sync_network] forKey:@"sync_network"];
}

//重写set方法
- (void)setSync_data:(id)_sync_data
{
    if (_sync_data != nil)
    {
        sync_data = _sync_data;
        [jsonDic setObject:sync_data forKey:@"sync_data"];
    }
}

@end
