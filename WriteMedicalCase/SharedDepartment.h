//
//  SharedDepartment.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Template;

@interface SharedDepartment : NSManagedObject

@property (nonatomic, retain) NSString * departmentID;
@property (nonatomic, retain) Template *template;
+(NSString*)entityName;

@end
