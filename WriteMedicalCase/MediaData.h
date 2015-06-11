//
//  MediaData.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NoteContent;

@interface MediaData : NSManagedObject

@property (nonatomic, retain) NSString * cursorX;
@property (nonatomic, retain) NSString * cursorY;
@property (nonatomic, retain) NSNumber * hasDeleted;
@property (nonatomic, retain) NSNumber * hasAdded;
@property (nonatomic, retain) NSString * dataType;//0 image,1:audio
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * noteID;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * mediaURLString;
@property (nonatomic, retain) NSString * mediaNameString;
@property (nonatomic, retain) NSString * mediaID;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NoteContent *owner;
+(NSString*)entityName;

@end
