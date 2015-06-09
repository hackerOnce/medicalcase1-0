//
//  TempNoteInfo.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/8.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "TempNoteInfo.h"

@implementation TempNoteInfo

-(instancetype)initWithDict:(NSDictionary*)dict
{
    self = [super init];
    
    if (self) {
        if ([dict.allKeys containsObject:@"ih_note_id"]) {
            _noteID = [dict objectForKey:@"ih_note_id"];
        }
        if ([dict.allKeys containsObject:@"ih_note_type"]) {
            _noteType = [dict objectForKey:@"ih_note_type"];
        }
        if ([dict.allKeys containsObject:@"ih_create_time"]) {
            _createTime = [dict objectForKey:@"ih_create_time"];
        }
        if ([dict.allKeys containsObject:@"ih_modify_time"]) {
            _updatedTime = [dict objectForKey:@"ih_modify_time"];
        }
        if ([dict.allKeys containsObject:@"ih_note_title"]) {
            _noteTitle = [dict objectForKey:@"ih_note_title"];
        }
        if ([dict.allKeys containsObject:@"ih_note_text"]) {
            _noteText = [dict objectForKey:@"ih_note_text"];
        }
        _noteUUID = nil;
    }
    
    return self;
}
-(instancetype)initWithNoteBook:(NoteBook*)note
{
    self = [super init];
    if (self) {
        _noteID=  nil;
        _noteUUID = note.noteUUID;
        NSString *originString = ((NoteContent*)[note.contents firstObject]).updatedContent;
        if (originString.length > 15) {
            originString = [originString substringToIndex:15];
        }
        _noteText = originString;
        _updatedTime = note.updateDate;
        _createTime = note.createDate;
        _noteTitle = note.noteTitle;
        
    }
    return self;
}
@end
