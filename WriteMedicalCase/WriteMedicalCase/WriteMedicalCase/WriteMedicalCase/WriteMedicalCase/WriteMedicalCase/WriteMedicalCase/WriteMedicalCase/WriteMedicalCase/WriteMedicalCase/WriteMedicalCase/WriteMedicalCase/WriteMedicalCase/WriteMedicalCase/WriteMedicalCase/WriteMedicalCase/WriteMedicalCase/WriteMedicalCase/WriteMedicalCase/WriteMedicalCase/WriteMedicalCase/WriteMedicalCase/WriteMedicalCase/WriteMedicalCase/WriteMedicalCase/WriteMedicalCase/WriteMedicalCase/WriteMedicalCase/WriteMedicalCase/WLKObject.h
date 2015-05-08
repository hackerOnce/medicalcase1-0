//
//  CKObject.h
//  MedImageReader
//
//  Created by ihefe36 on 14/12/29.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLKObject : NSObject <NSCoding>

/**
 * 用字典初始化对象，一般是从服务器拿到json数据后，转成字典，然后初始化
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
