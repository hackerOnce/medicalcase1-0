//
//  TempRecord.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/19.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "TempRecord.h"

@implementation TempRecord
-(instancetype)initWithDic:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        if ([dict.allKeys containsObject:@"caseType"]) {
            _caseType = dict[@"caseType"];
        }
        if ([dict.allKeys containsObject:@"caseStatus"]) {
            _caseStatus = dict[@"caseStatus"];
        }
    }
    
    return self;
}
@end
