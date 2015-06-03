//
//  MediaData.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/3.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NoteContent;

@interface MediaData : NSManagedObject

@property (nonatomic, retain) NSString * dataType;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * noteID;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NoteContent *owner;
+(NSString*)entityName;

@end
