//
//  WLKTemplate.h
//  MedCase
//
//  Created by ihefe36 on 14/12/31.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import "WLKObject.h"
@class WLKCaseNode;
@interface WLKTemplate : WLKObject

/**
 * 模版id
 */
@property (strong, nonatomic) NSString *templateID;

/**
 * 病历模版的主要数据，各字段以及各字段对应的值，先使用字典，待与服务器讨论后改为WLKCaseNode；
 */
@property (strong, nonatomic) NSMutableDictionary *mainData;

#warning more properties
@end
