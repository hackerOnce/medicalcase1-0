//
//  NoteContent.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "NoteContent.h"
#import "MediaData.h"
#import "NoteBook.h"


@implementation NoteContent

@dynamic content;
@dynamic contentType;
@dynamic medias;
@dynamic noteBook;
@dynamic contentIndex;
@dynamic updatedContent;

+(NSString*)entityName
{
    return @"NoteContent";
}

@end
