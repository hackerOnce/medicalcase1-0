//
//  NoteBook.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "NoteBook.h"
#import "NoteContent.h"


@implementation NoteBook

@dynamic noteType;
@dynamic noteTitle;
@dynamic notePatientName;
@dynamic noteID;
@dynamic notePatientID;
@dynamic dID;
@dynamic dName;
@dynamic createDate;
@dynamic updateDate;
@dynamic noteUUID;
@dynamic contents;
+(NSString*)entityName
{
    return @"NoteBook";
}
@end
