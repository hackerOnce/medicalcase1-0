//
//  Template.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "Template.h"
#import "Node.h"
#import "SharedDepartment.h"
#import "SharedUser.h"


@implementation Template

@dynamic dID;
@dynamic dName;
@dynamic gender;
@dynamic mainSymptom;
@dynamic acompanySymptom;
@dynamic lowAge;
@dynamic highAge;
@dynamic diagnose;
@dynamic sharedStatus;
@dynamic sharedType;
@dynamic node;
@dynamic sharedUsers;
@dynamic sharedDepartments;
+(NSString*)entityName
{
    return @"Template";
}

@end
