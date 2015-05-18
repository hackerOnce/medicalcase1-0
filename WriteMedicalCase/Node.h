//
//  Node.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ParentNode, Template;

@interface Node : NSManagedObject

@property (nonatomic, retain) NSNumber * hasSubNode;
@property (nonatomic, retain) NSString * nodeAge;
@property (nonatomic, retain) NSString * nodeContent;
@property (nonatomic, retain) NSString * nodeEnglish;
@property (nonatomic, retain) NSNumber * nodeIndex;
@property (nonatomic, retain) NSString * nodeName;
@property (nonatomic, retain) NSNumber * nodeRow;
@property (nonatomic, retain) NSNumber * nodeSection;
@property (nonatomic, retain) ParentNode *parentNode;
@property (nonatomic, retain) NSOrderedSet *templates;
@end

@interface Node (CoreDataGeneratedAccessors)
+(NSString*)entityName;


- (void)insertObject:(Template *)value inTemplatesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTemplatesAtIndex:(NSUInteger)idx;
- (void)insertTemplates:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTemplatesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTemplatesAtIndex:(NSUInteger)idx withObject:(Template *)value;
- (void)replaceTemplatesAtIndexes:(NSIndexSet *)indexes withTemplates:(NSArray *)values;
- (void)addTemplatesObject:(Template *)value;
- (void)removeTemplatesObject:(Template *)value;
- (void)addTemplates:(NSOrderedSet *)values;
- (void)removeTemplates:(NSOrderedSet *)values;
@end
