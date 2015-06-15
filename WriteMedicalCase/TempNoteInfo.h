//
//  TempNoteInfo.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/8.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempNoteInfo : NSObject
@property (nonatomic,strong) NSString *noteID;
@property (nonatomic,strong) NSString *noteType;
@property (nonatomic,strong) NSString *createTime;
@property (nonatomic,strong) NSString *updatedTime;
@property (nonatomic,strong) NSString *noteTitle;
@property (nonatomic,strong) NSString *noteText;
@property (nonatomic,strong) NSString *shortCreateDate;

@property (nonatomic,strong) NSString *noteUUID;
-(instancetype)initWithDict:(NSDictionary*)dict;
-(instancetype)initWithNoteBook:(NoteBook*)note;

@end
