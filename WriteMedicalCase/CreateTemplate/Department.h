//
//  Department.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/21.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Department : NSObject
@property (nonatomic,strong) NSString *departmentName;
@property (nonatomic,strong) NSString *departmentID;

-(instancetype)initWithDepartmentDict:(NSDictionary*)dict;

@end
