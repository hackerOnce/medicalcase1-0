//
//  TempCaseBaseInfo.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "TempCaseBaseInfo.h"

@implementation TempCaseBaseInfo


-(instancetype)initWithCaseInfoDic:(NSDictionary*)caseInfoDic
{
    self = [super init];

    if (self) {
        if (caseInfoDic) {
            if ([caseInfoDic.allKeys containsObject:@"createdTime"]) {
                self.createdTime = caseInfoDic[@"createdTime"];
            }
            if ([caseInfoDic.allKeys containsObject:@"lastModifyTime"]) {
                self.lastModifyTime = caseInfoDic[@"lastModifyTime"];
            }
            if ([caseInfoDic.allKeys containsObject:@"archivedTime"]) {
                self.archivedTime = caseInfoDic[@"archivedTime"];
            }
            if ([caseInfoDic.allKeys containsObject:@"casePresenter"]) {
                self.casePresenter = caseInfoDic[@"casePresenter"];
            }
            if ([caseInfoDic.allKeys containsObject:@"archivedTime"]) {
                self.archivedTime = caseInfoDic[@"archivedTime"];
            }
            
            //caseContent is a dic
            if ([caseInfoDic.allKeys containsObject:@"caseContent"]) {
                self.caseContent = caseInfoDic[@"caseContent"];
            }
            if ([caseInfoDic.allKeys containsObject:@"caseType"]) {
                self.caseType = caseInfoDic[@"caseType"];
            }
 
        }
    }
    
    return self;
}
@end
