//
//  ShoNotePart.m
//  WriteMedicalCase
//
//  Created by GK on 15/6/6.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ShowNotePart.h"


@implementation ShowNotePart

@dynamic updatedTime;
@dynamic titleString;
@dynamic doctorID;
@dynamic doctorName;
@dynamic partContent;
@dynamic noteID;
@dynamic noteUUID;
+(NSString*)entityName
{
    return @"ShowNotePart";
}
@end
