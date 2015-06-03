//
//  NoteContent.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/3.
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
+(NSString*)entityName
{
    return @"NoteContent";
}

@end
