//
//  TemplateModel.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/11.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "TemplateModel.h"

@implementation TemplateModel

-(instancetype)initWithTemplate:(TemplateModel *)templateModel
{
    if (self = [super init]) {
        _dID = templateModel.dID;
        _templateID = templateModel.templateID;
        _condition = templateModel.condition;
        _content = templateModel.content;
        _gender = templateModel.gender;
        _ageHigh = templateModel.ageHigh;
        _admittingDiagnosis = templateModel.admittingDiagnosis;
        _simultaneousPhenomenon = templateModel.simultaneousPhenomenon;
        _ageLow = templateModel.ageLow;
        _cardinalSymptom = templateModel.cardinalSymptom;
        _createDate = templateModel.createDate;
        _section =  templateModel.section;
        _updatedTime = templateModel.updatedTime;
        _sourceType = templateModel.sourceType;
        _createPeople = templateModel.createPeople;
        _templateType = templateModel.templateType;
        _templatedName = templateModel.templatedName;
        
    }
    return self;
}
-(instancetype)initWithDic:(NSDictionary*)dic
{
  
    
     if (self = [super init]) {
         
         if ([dic.allKeys containsObject:@"_created"]) {
             _createDate = dic[@"_created"];
         }
         if ([dic.allKeys containsObject:@"_id"]) {
             _templateID = dic[@"_id"];
         }
         if ([dic.allKeys containsObject:@"_updated"]) {
             _updatedTime = dic[@"_updated"];
         }
         if ([dic.allKeys containsObject:@"dID"]) {
             _templateID = dic[@"dID"];
         }
         
         if ([dic.allKeys containsObject:@"doctor"]) {
             NSDictionary *dict = (NSDictionary*)dic[@"doctor"];
             
             if ([dict.allKeys containsObject:@"dID"]) {
                 _dID = dict[@"dID"];
             }
             if ([dict.allKeys containsObject:@"dName"]) {
                 _dName = dict[@"dName"];
             }
             if ([dict.allKeys containsObject:@"createPeople"]) {
                 _createPeople = dict[@"createPeople"];
             }else {
                 _createPeople = _dName;
             }
             
         }
         
         if ([dic.allKeys containsObject:@"tArgs"]) {
             NSDictionary *dict = (NSDictionary*)dic[@"tArgs"];
             
             if ([dict.allKeys containsObject:@"diagnose"]) {
                 _admittingDiagnosis = dict[@"diagnose"];
             }
             if ([dict.allKeys containsObject:@"gender"]) {
                 _gender =[(NSString*)dict[@"gender"] isEqualToString:@"M"]?@"男":@"女";
             }
             if ([dict.allKeys containsObject:@"highAge"]) {
                  _ageHigh = dict[@"highAge"];
             }
             if ([dict.allKeys containsObject:@"lowAge"]) {
                 _ageLow = dict[@"lowAge"];
             }
             if ([dict.allKeys containsObject:@"mainSymptom"]) {
                 _cardinalSymptom = dict[@"mainSymptom"];
             }
             if ([dict.allKeys containsObject:@"otherSymptom"]) {
                 _simultaneousPhenomenon = dict[@"otherSymptom"];
             }
         }
         
         
         if ([dic.allKeys containsObject:@"tContent"]) {
             _content = dic[@"tContent"];
         }
         if ([dic.allKeys containsObject:@"templateName"]) {
             _templatedName = dic[@"templateName"];
         }
         if ([dic.allKeys containsObject:@"templateType"]) {
             _templateType = dic[@"templateType"];
         }
         
         
        if ([dic.allKeys containsObject:@"dID"]) {
            _dID = dic[@"dID"];
        }
         if ([dic.allKeys containsObject:@"templateID"]) {
             _templateID = dic[@"templateID"];
         }
        
        if ([dic.allKeys containsObject:@"content"]) {
            _content = dic[@"content"];
        }
         if ([dic.allKeys containsObject:@"templateType"]) {
             _templateType = dic[@"templateType"];
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
         
         if ([dic.allKeys containsObject:@"condition"]) {
             _condition = dic[@"condition"];
         }else {
              _condition = [NSString stringWithFormat:@"性别是:%@,年龄段是%@-%@,入院诊断是:%@,主要症状是:%@,伴随症状是:%@",self.gender,self.ageLow,self.ageHigh,self.admittingDiagnosis,self.cardinalSymptom,self.simultaneousPhenomenon];
         }
    }
    return self;
}

@end
