//
//  RawDataProcess.h
//  MedCase
//
//  Created by ihefe-JF on 15/1/30.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLKCaseNode.h"

@interface RawDataProcess : NSObject

//@property (nonatomic,strong) WLKCaseNode *dataNode;
@property (nonatomic,strong) WLKCaseNode *rootNode;

@property (nonatomic,strong) NSMutableDictionary *dic;
@property (nonatomic,strong) NSMutableDictionary *XMLDic;
+(RawDataProcess*)sharedRawData;

@property (nonatomic,strong) NSMutableArray *persons;

-(NSDictionary*)dicFromJsonString:(NSString*)tempStr;
-(NSString *)stringFromJsonDic:(NSMutableDictionary *)tempDic;
@end
