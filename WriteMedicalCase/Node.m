//
//  Node.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/15.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "Node.h"
#import "ParentNode.h"


@implementation Node

@dynamic hasSubNode;
@dynamic nodeContent;
@dynamic nodeName;
@dynamic nodeEnglish;
@dynamic parentNode;
@dynamic templates;
@dynamic nodeSection;
@dynamic nodeRow;
@dynamic nodeIndex;

+(NSString*)entityName {
    return @"Node";
}

@end
