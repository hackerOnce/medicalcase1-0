//
//  ParentNode.h
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/8.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Node;

@interface ParentNode : NSManagedObject

@property (nonatomic, retain) NSString * nodeName;
@property (nonatomic, retain) NSOrderedSet *nodes;
@end

@interface ParentNode (CoreDataGeneratedAccessors)
+(NSString*)entityName;

- (void)insertObject:(Node *)value inNodesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromNodesAtIndex:(NSUInteger)idx;
- (void)insertNodes:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeNodesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInNodesAtIndex:(NSUInteger)idx withObject:(Node *)value;
- (void)replaceNodesAtIndexes:(NSIndexSet *)indexes withNodes:(NSArray *)values;
- (void)addNodesObject:(Node *)value;
- (void)removeNodesObject:(Node *)value;
- (void)addNodes:(NSOrderedSet *)values;
- (void)removeNodes:(NSOrderedSet *)values;
@end
