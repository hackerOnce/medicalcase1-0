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
        
        if ([dic.allKeys containsObject:@"templateID"]) {
            _templateID = dic[@"templateID"];
        }
        
        if ([dic.allKeys containsObject:@"condition"]) {
            _condition = dic[@"condition"];
        }
        if ([dic.allKeys containsObject:@"content"]) {
            _content = dic[@"content"];
        }
        if ([dic.allKeys containsObject:@"createPeople"]) {
            _createPeople = dic[@"createPeople"];
        }
    }
    return self;
}
@end
