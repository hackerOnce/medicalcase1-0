//
//  Template.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Node, SharedDepartment, SharedUser;

@interface Template : NSManagedObject

@property (nonatomic, retain) NSString * dID;
@property (nonatomic, retain) NSString * dName;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * mainSymptom;
@property (nonatomic, retain) NSString * acompanySymptom;
@property (nonatomic, retain) NSString * lowAge;
@property (nonatomic, retain) NSString * highAge;
@property (nonatomic, retain) NSString * diagnose;
@property (nonatomic, retain) NSString * sharedStatus;
@property (nonatomic, retain) NSString * sharedType;
@property (nonatomic, retain) Node *node;
@property (nonatomic, retain) NSOrderedSet *sharedUsers;
@property (nonatomic, retain) NSOrderedSet *sharedDepartments;
@end

@interface Template (CoreDataGeneratedAccessors)
+(NSString*)entityName;


- (void)insertObject:(SharedUser *)value inSharedUsersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSharedUsersAtIndex:(NSUInteger)idx;
- (void)insertSharedUsers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSharedUsersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSharedUsersAtIndex:(NSUInteger)idx withObject:(SharedUser *)value;
- (void)replaceSharedUsersAtIndexes:(NSIndexSet *)indexes withSharedUsers:(NSArray *)values;
- (void)addSharedUsersObject:(SharedUser *)value;
- (void)removeSharedUsersObject:(SharedUser *)value;
- (void)addSharedUsers:(NSOrderedSet *)values;
- (void)removeSharedUsers:(NSOrderedSet *)values;
- (void)insertObject:(SharedDepartment *)value inSharedDepartmentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSharedDepartmentsAtIndex:(NSUInteger)idx;
- (void)insertSharedDepartments:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSharedDepartmentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSharedDepartmentsAtIndex:(NSUInteger)idx withObject:(SharedDepartment *)value;
- (void)replaceSharedDepartmentsAtIndexes:(NSIndexSet *)indexes withSharedDepartments:(NSArray *)values;
- (void)addSharedDepartmentsObject:(SharedDepartment *)value;
- (void)removeSharedDepartmentsObject:(SharedDepartment *)value;
- (void)addSharedDepartments:(NSOrderedSet *)values;
- (void)removeSharedDepartments:(NSOrderedSet *)values;
@end
