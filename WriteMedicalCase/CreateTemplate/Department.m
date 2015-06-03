//
//  Department.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/21.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "Department.h"

@implementation Department
-(instancetype)initWithDepartmentDict:(NSDictionary*)dict
{
    if (self = [super init]) {
        if ([dict.allKeys containsObject:@"id"]) {
            _departmentID = dict[@"id"];
        }
        if ([dict.allKeys containsObject:@"name"]) {
            _departmentName = dict[@"name"];
        }
    }
    return self;
}
@end
