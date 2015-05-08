//
//  Template.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/8.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "Template.h"
#import "Node.h"


@implementation Template

@dynamic templateID;
@dynamic sourceType;
@dynamic createPeople;
@dynamic dName;
@dynamic dID;
@dynamic condition;
@dynamic content;
@dynamic gender;
@dynamic ageHigh;
@dynamic admittingDiagnosis;
@dynamic simultaneousPhenomenon;
@dynamic ageLow;
@dynamic cardinalSymptom;
@dynamic createDate;
@dynamic section;
@dynamic node;
@dynamic updatedTime;
@dynamic nodeID;
+(NSString*)entityName
{
    return @"Template";
}

@end
