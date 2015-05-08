//
//  TestNode.h
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/9.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TestParentNode;

@interface TestNode : NSManagedObject

@property (nonatomic, retain) NSString * nodeName;
@property (nonatomic, retain) NSString * nodeContent;
@property (nonatomic, retain) NSNumber * hasSubNode;
@property (nonatomic, retain) TestParentNode *testParentNode;
+(NSString*)entityName;

@end
