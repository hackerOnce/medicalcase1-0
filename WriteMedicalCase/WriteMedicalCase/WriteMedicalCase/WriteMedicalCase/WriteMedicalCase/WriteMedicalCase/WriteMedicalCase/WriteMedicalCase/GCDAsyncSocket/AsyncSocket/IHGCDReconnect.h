//
//  IHGCDReconnect.h
//  iosocket
//
//  Created by macHs on 14-8-15.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "IHMsgSocket.h"

//@class IHMsgSocket;
//@class IHGCDSocket;
@interface IHGCDReconnect : NSObject
{
//    IHGCDSocket *ihGCDSocket;
//    IHMsgSocket *msgSocket;
    SCNetworkReachabilityRef reachability;
}

@property (nonatomic, strong) IHMsgSocket *msgSocket;
@property(nonatomic,assign)BOOL isPrint;

- (void)setupNetworkMonitoring;

-(void)activate:(IHMsgSocket *)obj;
@end


 
