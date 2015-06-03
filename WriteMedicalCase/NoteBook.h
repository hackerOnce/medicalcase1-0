//
//  NoteBook.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/3.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NoteContent, NoteIndex;

@interface NoteBook : NSManagedObject

@property (nonatomic, retain) NSString * noteType;
@property (nonatomic, retain) NSString * noteTitle;
@property (nonatomic, retain) NSString * notePatientName;
@property (nonatomic, retain) NSString * noteID;
@property (nonatomic, retain) NSString * notePatientID;
@property (nonatomic, retain) NSString * dID;
@property (nonatomic, retain) NSString * dName;
@property (nonatomic, retain) NSString * createDate;
@property (nonatomic, retain) NSString * updateDate;
@property (nonatomic, retain) NSNumber * noteIndex;
@property (nonatomic, retain) NSOrderedSet *contents;
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
