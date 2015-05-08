//
//  TestParentNode.h
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/9.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TestParentNode : NSManagedObject

@property (nonatomic, retain) NSString * nodeName;
@property (nonatomic, retain) NSOrderedSet *testNodes;
@end

@interface TestParentNode (CoreDataGeneratedAccessors)

+(NSString*)entityName;

- (void)insertObject:(NSManagedObject *)value inTestNodesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTestNodesAtIndex:(NSUInteger)idx;
- (void)insertTestNodes:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTestNodesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTestNodesAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceTestNodesAtIndexes:(NSIndexSet *)indexes withTestNodes:(NSArray *)values;
- (void)addTestNodesObject:(NSManagedObject *)value;
- (void)removeTestNodesObject:(NSManagedObject *)value;
- (void)addTestNodes:(NSOrderedSet *)values;
- (void)removeTestNodes:(NSOrderedSet *)values;
@end
