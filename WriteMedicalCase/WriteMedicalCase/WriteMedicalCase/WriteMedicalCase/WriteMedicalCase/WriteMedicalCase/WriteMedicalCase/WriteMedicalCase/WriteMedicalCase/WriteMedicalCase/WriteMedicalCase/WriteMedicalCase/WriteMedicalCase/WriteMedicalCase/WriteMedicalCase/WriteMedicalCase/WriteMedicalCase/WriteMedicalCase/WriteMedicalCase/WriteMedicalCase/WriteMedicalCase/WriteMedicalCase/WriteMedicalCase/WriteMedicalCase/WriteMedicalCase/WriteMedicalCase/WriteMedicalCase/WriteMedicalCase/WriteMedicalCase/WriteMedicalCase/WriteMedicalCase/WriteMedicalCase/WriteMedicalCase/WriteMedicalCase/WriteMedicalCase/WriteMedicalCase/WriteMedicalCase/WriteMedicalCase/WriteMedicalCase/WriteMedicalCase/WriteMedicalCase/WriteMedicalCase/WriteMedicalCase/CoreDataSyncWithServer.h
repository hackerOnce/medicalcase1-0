//
//  CoreDataSyncWithServer.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/6.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CoreDataSyncWithServerDelegate<NSObject>

-(void)successfulSync;
-(void)failureSync;

@end

@interface CoreDataSyncWithServer : NSObject
@property (nonatomic,strong) NSString *user;
@property (nonatomic,strong) NSString *password;

@property (nonatomic,strong) NSString *doctorID;

@property (nonatomic,weak) id <CoreDataSyncWithServerDelegate> delegate;
@end
