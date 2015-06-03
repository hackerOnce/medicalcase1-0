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
                self.caseType =StringValue(caseInfoDic[@"caseType"]);
            }
            
            
            if ([caseInfoDic.allKeys containsObject:@"residentdID"]) {
                _residentID =StringValue(caseInfoDic[@"residentdID"]);
            }
            if ([caseInfoDic.allKeys containsObject:@"residentdName"]) {
                _residentName =StringValue(caseInfoDic[@"residentdName"]);
            }
            
            
            if ([caseInfoDic.allKeys containsObject:@"attendingPhysiciandName"]){
                _attendingPhysiciandName = StringValue(caseInfoDic[@"attendingPhysiciandName"]);
            }
            if ([caseInfoDic.allKeys containsObject:@"attendingPhysiciandID"]) {
                _attendingPhysiciandID =StringValue(caseInfoDic[@"attendingPhysiciandID"]);

            }
            if ([caseInfoDic.allKeys containsObject:@"chiefPhysiciandID"]) {
                _chiefPhysiciandID = StringValue(caseInfoDic[@"chiefPhysiciandID"]);
            }
            if ([caseInfoDic.allKeys containsObject:@"chiefPhysiciandName"]){
                _chiefPhysiciandName = StringValue(caseInfoDic[@"chiefPhysiciandName"]);
            }
 
            if ([caseInfoDic.allKeys containsObject:@"pID"]) {
                _pID = StringValue(caseInfoDic[@"pID"]);
            }
            if ([caseInfoDic.allKeys containsObject:@"pName"]) {
                _pName = StringValue(caseInfoDic[@"pName"]);
            }
        }
    }
    
    return self;
}
@end
