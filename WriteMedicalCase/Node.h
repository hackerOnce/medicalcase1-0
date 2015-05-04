//
//  Node.h
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/8.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ParentNode, Template;

@interface Node : NSManagedObject

@property (nonatomic, retain) NSNumber * hasSubNode;
@property (nonatomic, retain) NSString * nodeContent;
@property (nonatomic, retain) NSNumber * nodeIndex;
@property (nonatomic, retain) NSString * nodeName;
@property (nonatomic, retain) NSNumber * nodeType;
@property (nonatomic, retain) ParentNode *parentNode;
@property (nonatomic, retain) NSOrderedSet *templates;
@property (nonatomic, retain) NSString *nodeIdentifier;

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
