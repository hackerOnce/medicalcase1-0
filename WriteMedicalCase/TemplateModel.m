//
//  TemplateModel.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/11.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "TemplateModel.h"

@implementation TemplateModel

-(instancetype)initWithDic:(NSDictionary*)dic
{
     if (self = [super init]) {
        if ([dic.allKeys containsObject:@"dID"]) {
            _dID = dic[@"dID"];
        }
        if ([dic.allKeys containsObject:@"condition"]) {
            _condition = dic[@"condition"];
        }
        if ([dic.allKeys containsObject:@"content"]) {
            _content = dic[@"content"];
        }
        
        if ([dic.allKeys containsObject:@"gender"]) {
            _gender = dic[@"gender"];
        }
        if ([dic.allKeys containsObject:@"ageHigh"]) {
            _ageHigh = dic[@"ageHigh"];
        }
        if ([dic.allKeys containsObject:@"admittingDiagnosis"]) {
            _admittingDiagnosis = dic[@"admittingDiagnosis"];
        }
        if ([dic.allKeys containsObject:@"simultaneousPhenomenon"]) {
            _simultaneousPhenomenon = dic[@"simultaneousPhenomenon"];
        }
       
        if ([dic.allKeys containsObject:@"ageLow"]) {
            _ageLow = dic[@"ageLow"];
        }
        if ([dic.allKeys containsObject:@"cardinalSymptom"]) {
            _cardinalSymptom = dic[@"cardinalSymptom"];
        }
        if ([dic.allKeys containsObject:@"createDate"]) {
            _createDate = dic[@"createDate"];
        }
        if ([dic.allKeys containsObject:@"updatedTime"]) {
            _updatedTime = dic[@"updatedTime"];
        }
        if ([dic.allKeys containsObject:@"createPeople"]) {
            _createPeople = dic[@"createPeople"];
        }
        if ([dic.allKeys containsObject:@"sourceType"]) {
            _sourceType = dic[@"sourceType"];
        }
    }
    return self;
}
@end
