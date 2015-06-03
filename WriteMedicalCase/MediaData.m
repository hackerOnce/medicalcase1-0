//
//  MediaData.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/3.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "MediaData.h"
#import "NoteContent.h"


@implementation MediaData

@dynamic dataType;
@dynamic location;
@dynamic noteID;
@dynamic data;
@dynamic owner;
+(NSString*)entityName
{
    return @"MediaData";
}

@end
