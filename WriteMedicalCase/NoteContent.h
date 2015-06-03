//
//  NoteContent.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/3.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MediaData, NoteBook;

@interface NoteContent : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSSet *medias;
@property (nonatomic, retain) NoteBook *noteBook;
@end

@interface NoteContent (CoreDataGeneratedAccessors)

- (void)addMediasObject:(MediaData *)value;
- (void)removeMediasObject:(MediaData *)value;
- (void)addMedias:(NSSet *)values;
- (void)removeMedias:(NSSet *)values;
+(NSString*)entityName;

@end
