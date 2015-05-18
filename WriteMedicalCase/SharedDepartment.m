//
//  SharedDepartment.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "SharedDepartment.h"
#import "Template.h"


@implementation SharedDepartment

@dynamic departmentID;
@dynamic template;
+(NSString*)entityName
{
    return @"SharedDepartment";
}
@end
