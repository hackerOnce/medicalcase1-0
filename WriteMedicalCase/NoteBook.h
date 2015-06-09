//
//  NoteBook.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NoteContent;

@interface NoteBook : NSManagedObject

@property (nonatomic, retain) NSNumber *isCurrentNote;

@property (nonatomic, retain) NSString * noteType;//0 for patient 1for origin
@property (nonatomic, retain) NSString * noteTitle;
@property (nonatomic, retain) NSString * notePatientName;
@property (nonatomic, retain) NSString * noteID;
@property (nonatomic, retain) NSString * notePatientID;
@property (nonatomic, retain) NSString * dID;
@property (nonatomic, retain) NSString * dName;
@property (nonatomic, retain) NSString * createDate;
@property (nonatomic, retain) NSString * updateDate;
@property (nonatomic, retain) NSString * noteUUID;
@property (nonatomic, retain) NSOrderedSet *contents;

@property (nonatomic, retain) NSString * warningCommit;
@property (nonatomic, retain) NSString * warningContent;
@property (nonatomic, retain) NSString * warningTime;

@end

@interface NoteBook (CoreDataGeneratedAccessors)
+(NSString*)entityName;

- (void)insertObject:(NoteContent *)value inContentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromContentsAtIndex:(NSUInteger)idx;
- (void)insertContents:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeContentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInContentsAtIndex:(NSUInteger)idx withObject:(NoteContent *)value;
- (void)replaceContentsAtIndexes:(NSIndexSet *)indexes withContents:(NSArray *)values;
- (void)addContentsObject:(NoteContent *)value;
- (void)removeContentsObject:(NoteContent *)value;
- (void)addContents:(NSOrderedSet *)values;
- (void)removeContents:(NSOrderedSet *)values;
@end
