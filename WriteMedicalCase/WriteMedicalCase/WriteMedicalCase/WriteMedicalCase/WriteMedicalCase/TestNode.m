//
//  TestNode.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/9.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "TestNode.h"
#import "TestParentNode.h"


@implementation TestNode

@dynamic nodeName;
@dynamic nodeContent;
@dynamic hasSubNode;
@dynamic testParentNode;

+(NSString*)entityName
{
    return @"TestNode";
}

@end
