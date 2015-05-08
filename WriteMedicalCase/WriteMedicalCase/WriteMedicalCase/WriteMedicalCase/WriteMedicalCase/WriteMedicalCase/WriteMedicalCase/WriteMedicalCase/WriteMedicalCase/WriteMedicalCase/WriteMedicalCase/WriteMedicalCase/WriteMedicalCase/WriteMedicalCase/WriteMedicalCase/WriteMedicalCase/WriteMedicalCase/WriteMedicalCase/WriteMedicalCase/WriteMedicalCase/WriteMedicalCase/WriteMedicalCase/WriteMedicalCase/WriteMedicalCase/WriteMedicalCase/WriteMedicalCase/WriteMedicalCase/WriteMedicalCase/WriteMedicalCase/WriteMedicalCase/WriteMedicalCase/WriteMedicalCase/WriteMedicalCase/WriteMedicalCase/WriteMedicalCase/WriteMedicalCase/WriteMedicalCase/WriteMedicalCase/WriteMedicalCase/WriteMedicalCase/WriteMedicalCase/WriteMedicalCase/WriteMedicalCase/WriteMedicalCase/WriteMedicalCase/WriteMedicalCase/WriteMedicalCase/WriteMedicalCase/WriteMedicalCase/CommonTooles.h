//
//  CommonConfig.h
//  MedCase
//
//  Created by ihefe36 on 14/12/31.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#ifndef MedCase_CommonConfig_h
#define MedCase_CommonConfig_h

#ifdef DEBUG
#define WLKLog(s, ...) NSLog( @"[%@ %@] %@",NSStringFromClass([self class]), NSStringFromSelector(_cmd),[NSString stringWithFormat:(s), ##__VA_ARGS__] )
#endif
#define SCREENHEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREENWIDTH [[UIScreen mainScreen] bounds].size.width
#define TopBarHeight ([[[UIDevice currentDevice] systemVersion] floatValue]<7.0?44.0f:64.0f)
#define StateBarHeight ([[[UIDevice currentDevice] systemVersion] floatValue]<7.0?20.0f:0.0f)

//SYSTEM_VERSION_EQUAL_TO(@"7.1")
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define DocumentDrictoryPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

/**
 *  读取文件内容
 *
 *  @param filePath 文件路径
 *
 *  @return 返回文件内容
 */
inline static NSDictionary *ReadFileDictionary(NSString *filePath){
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return dict;
}
/**
 *  写入文件内容
 *
 *  @param dict     写入文件
 *  @param filePath 文件路径
 *
 *  @return
 */
inline static BOOL WriteDictionaryToFile(NSDictionary *dict , NSString *filePath){
    if ([dict isKindOfClass:[NSNull class]]||dict==nil) {
        return NO;
    }
    return [dict writeToFile:filePath atomically:YES];
}

/**
 *  字符串验证
 *
 *  @param value 验证内容
 *
 *  @return 验证后返回NSString
 */
inline static NSString *StringValue(NSObject *value)
{
    if ([value isKindOfClass:[NSNull class]]|| value == nil) {
        return  @"";
        //NSlog(@"%@",@"NSString is NSNull or nil ,please check server response.");
    }else if ([value isKindOfClass:[NSNumber class]]) {
        //NSlog(@"%@",@"NSString type is not valide ,the value is NSNumber type");
        return  [NSString stringWithFormat:@"%@",[value description]];
    }else if([value isKindOfClass:[NSString class]]){
        //		NSMutableArray *array = (NSMutableArray *)desCharArray();
        //		for (int i=0; i<array.count; i++) {
        //		value = [(NSString *)value stringByReplacingOccurrencesOfString:array[i] withString:@""];
        //		}
        return (NSString *)value;
    }else{
        //NSlog(@"NSString type is not valide :%@",value);
        return @"";
    }
    return @"";
}

/**
 *  integer值验证
 *
 *  @param value 验证内容
 *
 *  @return 验证后返回nsinteger
 */

inline static NSInteger IntValue(NSObject *value){
    if ([value isKindOfClass:[NSNull class]]||value==nil) {
        return 0;
    }else if([value isKindOfClass:[NSNumber class]]){
        return [(NSNumber *)value integerValue];
    }else if([value isKindOfClass:[NSString class]]&&[(NSString *)value length]>0){
        return [(NSString *)value integerValue];
    }else{
        return 0;
    }
    return 0;
}
/**
 *  double值验证
 *
 *  @param value 验证内容
 *
 *  @return 验证后返回double
 */
inline static double DoubleValue(NSObject *value){
    if ([value isKindOfClass:[NSNull class]]||value==nil) {
        return 0.0000;
    }else if([value isKindOfClass:[NSNumber class]]){
        return [(NSNumber *)value doubleValue];
    }else if([value isKindOfClass:[NSString class]]&&[(NSString *)value length]>0){
        return [(NSString *)value doubleValue];
    }else{
        return 0.0000;
    }
    return 0.0;
}


#endif
