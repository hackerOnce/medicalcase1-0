//
//  IHGCDSocket.m
//  iosocket
//
//  Created by macHs on 14-8-15.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import "IHGCDReconnect.h"

IHGCDReconnect *selfRectnnect;

@implementation IHGCDReconnect

@synthesize msgSocket;

- (id)init
{
    self = [super init];
    if (self) {
        [self ihPrint:__func__];
 
    }
    return self;
}
-(void)activate:(IHMsgSocket *)obj
{
    msgSocket=obj;
    
    selfRectnnect = self;
}
- (void)setupNetworkMonitoring
{
	if (reachability == NULL)
	{

        
        NSString *domain = @"apple.com";
		
		reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
		
		if (reachability)
		{
			SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
			SCNetworkReachabilitySetCallback(reachability, ReachabilityChanged, &context);
			
       
			CFRunLoopRef xmppRunLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];
			if (xmppRunLoop)
			{
				SCNetworkReachabilityScheduleWithRunLoop(reachability, xmppRunLoop, kCFRunLoopDefaultMode);
			}
			else
			{
				[self ihPrint:__func__];
			}
		}
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Reachability
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static void ReachabilityChanged(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
	NSLog(@"网络发生改变调用:%d", flags);
    
    if (flags != 0)
    {
        [selfRectnnect breakLineReconnection:flags];
    }
}

- (void)breakLineReconnection:(NSInteger)flags
{
    if (msgSocket.IHGCDSocket.asyncSocket.isConnected)
    {
        if (msgSocket.userStr)
        {
            [msgSocket sendheartbeatToServer:msgSocket.userStr];
        }
        else
        {
            [msgSocket sendheartbeatToServer:@"-1"];
        }
    }
    else
    {
//        [msgSocket connectToHost:DataDemandIP onPort:DataDemandPort];
        [msgSocket reconnectServer];
    }
}

-(void)ihPrint:(const char  *)tit
{
//    if (self.isPrint) {
//        NSLog(@"%s",tit);
//    }
}
@end
