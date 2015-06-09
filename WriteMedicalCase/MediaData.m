//
//  MediaData.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "MediaData.h"
#import "NoteContent.h"


@implementation MediaData
@dynamic hasAdded;
@dynamic hasDeleted;
@dynamic cursorX;
@dynamic cursorY;
@dynamic dataType;
@dynamic location;
@dynamic noteID;
@dynamic data;
@dynamic owner;
@dynamic mediaURLString;
@dynamic mediaNameString;
@dynamic mediaID;
+(NSString*)entityName
{
    return @"MediaData";
}

@end
