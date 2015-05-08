//
//  ParseXML.h
//  CoreData
//
//  Created by ihefe-JF on 15/1/21.
//  Copyright (c) 2015年 JFAppHourse.app. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseXML : NSObject
@property (nonatomic,strong) NSMutableDictionary *rawDic;
-(WLKCaseNode*)getNodeWithKey:(NSString *)strKey;
-(instancetype)initWithXMLName:(NSString*)name extendName:(NSString *)extendName;
@end
