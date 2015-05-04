//
//  Node.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/8.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "Node.h"
#import "ParentNode.h"
#import "Template.h"


@implementation Node

@dynamic hasSubNode;
@dynamic nodeContent;
@dynamic nodeIndex;
@dynamic nodeName;
@dynamic nodeType;
@dynamic parentNode;
@dynamic templates;
@dynamic nodeIdentifier;
+(NSString*)entityName
{
    return @"Node";
}

@end
