//
//  Node.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "Node.h"
#import "ParentNode.h"
#import "Template.h"


@implementation Node

@dynamic hasSubNode;
@dynamic nodeAge;
@dynamic nodeContent;
@dynamic nodeEnglish;
@dynamic nodeIndex;
@dynamic nodeName;
@dynamic nodeRow;
@dynamic nodeSection;
@dynamic parentNode;
@dynamic templates;
+(NSString*)entityName
{
    return @"Node";
}

@end
