//
//  AppDelegate.m
//  WriteMedicalCase
//
//  Created by GK on 15/4/29.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataStack.h"
#import "MessageObject+DY.h"
#import "RawDataProcess.h"
#import "CoreDataSyncWithServer.h"

@interface AppDelegate ()
@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (nonatomic,strong) RawDataProcess *rawDataProcess;

@end

@implementation AppDelegate

-(IHMsgSocket *)socket
{
    if (!_socket) {
        _socket = [IHMsgSocket sharedRequest];
        [_socket connectToHost:@"192.168.10.106" onPort:2323];
    }
    return _socket;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.coreDataStack = [[CoreDataStack alloc] init];

//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        self.rawDataProcess = [RawDataProcess sharedRawData];
//    });

    [[NSUserDefaults standardUserDefaults] setObject:@"2216" forKey:@"dID"];
    [[NSUserDefaults standardUserDefaults] setObject:@"张三" forKey:@"dName"];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"pID"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"pName"];
    
    [self.coreDataStack saveFieldNodeListToCoreData];
    
    
    //for test
    [self.coreDataStack fetchParentNodeWithNodeEntityName:@"模板"];

   // CoreDataSyncWithServer *syncServer = [[CoreDataSyncWithServer alloc] init];
    
    //test for 病例管理
   // [self SaveTestDataToCoreData];
    
     return YES;
}






-(void)SaveTestDataToCoreData
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"personInfo" ofType:@"plist"];
    NSMutableDictionary *data  =[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    //[self.coreDataStack entityInitDoctorManagementWithDoctorDic:data];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self.coreDataStack saveContext];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.coreDataStack saveContext];

}

@end
