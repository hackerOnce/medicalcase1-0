//
//  ParentNode.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/8.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "ParentNode.h"
#import "Node.h"


@implementation ParentNode

@dynamic nodeName;
@dynamic nodes;

+(NSString*)entityName
{
    return @"ParentNode";
}

@end
