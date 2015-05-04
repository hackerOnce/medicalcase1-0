//
//  IHMsgSocket.m
//  iosocket
//
//  Created by macHs on 14-2-25.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import "IHMsgSocket.h"
#import "MessageObject+DY.h"


@implementation IHSockRequest
- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}
@end

@interface IHMsgSocket ()
{
    NSString *ipString;
    UInt16 portInt;
    
    NSError *_error;
    NSTimer *_timer;
}

@end

@implementation IHMsgSocket

static IHMsgSocket *ihMsgSocket;

+(IHMsgSocket *)sharedRequest
{
    if (!ihMsgSocket) {
        ihMsgSocket=[[IHMsgSocket alloc] init];
        return ihMsgSocket;
    }
    return ihMsgSocket;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        _IHGCDSocket = [[IHGCDSocket alloc] init];
        _IHGCDSocket.delegate=self;
        _IHGCDSocket.isPrint=1;
        _receiveTime=3;
        self.isPrint=1;
        _queueLists=[[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)connectToHost:(NSString *)host onPort:(UInt16 )port
{
    ipString = host;
    portInt = port;
    
    [_IHGCDSocket connectToHost:host onPort:port];
}

//重连服务器
- (void)reconnectServer
{
    [_IHGCDSocket connectToHost:ipString onPort:portInt];
}



#pragma mark 发送数据
-(void)sendMsg:(MessageObject *)msgObj
{
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:msgObj.jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    NSData *data = [[jsonData compress] base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [_IHGCDSocket sendDataToServer:data  ];
}

- (void)sendMsg:(MessageObject *)msgObj selector:(SEL)selector
{
    IHSockRequest *sock=[[IHSockRequest alloc]init];
    sock.opt=msgObj.sync_optInt;
    sock.requestData=msgObj.sync_data;
    sock.sn=msgObj.sync_snStr;
    sock.selector=selector;
    [_queueLists setObject:sock forKey:sock.sn];
    
    [self sendMsg:msgObj];
    

}
- (void)sendMsg:(MessageObject *)msgObj completed:(void (^)(IHSockRequest *data))completed failConnection:(void (^)(NSError *error))fail
{
    IHSockRequest *sock=[[IHSockRequest alloc]init];
    sock.opt=msgObj.sync_optInt;
    sock.requestData=msgObj.sync_data;
    sock.sn=msgObj.sync_snStr;
    sock.block=completed;
    
    self.fail = fail;
    [_queueLists setObject:sock forKey:msgObj.sync_snStr];
    
    [self sendMsg:msgObj];
    

}
- (void)sendDataOverTime:(IHSockRequest *)request
{
    request.status=-1;
    if ([_queueLists count]>0) {
 
        if (_delegate && [_delegate respondsToSelector:request.selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_delegate performSelector:request.selector withObject:request];
#pragma clang diagnostic pop
        }else if (request.block) {
            request.block(request);
        }else{
            [_delegate ihSocket:self didReceive:request ];
        }
 
    }else{
        [self ihPrint:@"null sendDataOverTime"];
    }
    
}

#pragma mark 接收回调
-(void)ihSocket:(IHGCDSocket *)ihGcdSock didReceive:(NSData *)data
{
    NSDictionary *dict=[self returnIdTodata:data];
 
    
    NSString *sn=[dict objectForKey:@"sync_sn"];
    
    NSString *opt=[dict objectForKey:@"sync_opt"];
    
    NSInteger resp = [[dict objectForKey:@"sync_resp"] integerValue];
    
    id datas=[dict objectForKey:@"sync_data"];
    
    IHSockRequest *response=(IHSockRequest *)[_queueLists objectForKey:sn];
    response.responseData=datas;
    
    NSInteger optnumber=[opt integerValue];
    
    response.opt = optnumber;
    response.resp = resp;
    
    if (optnumber==0)
    {
        [self sendheartbeatToServer:[dict objectForKey:@"alive"]];
    }
    else
    {
        if (_delegate && [_delegate respondsToSelector:response.selector])
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_delegate performSelector:response.selector withObject:response];
#pragma clang diagnostic pop
        }
        else if (response.block )
        {
            response.block(response);
        }
        else
        {
        }

}

}

#pragma mark 转换数据
-(id)returnIdTodata:(NSData *)data
{
    NSData *finishData = [[[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters] uncompress];
    id jsonDic = [NSJSONSerialization JSONObjectWithData:finishData options:NSJSONReadingMutableContainers error:nil];
    return jsonDic;
}

#pragma mark - 向服务器发心跳包
- (void)sendheartbeatToServer:(NSString *)alive
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:alive forKey:@"alive"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSData *data = [[jsonData compress] base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    [_IHGCDSocket sendDataToServer:data];
}

#pragma mark - 与服务器断开连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    _error = err;
    self.fail(err);
    [self performSelectorInBackground:@selector(createNetworkSubThread) withObject:nil];
    
}

-(void)createNetworkSubThread
{
    if (![NSThread isMainThread])
    {
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkNetworkConnect) userInfo:nil repeats:YES];
            //保持线程为活动状态，才能保证定时器执行
            [[NSRunLoop currentRunLoop] run];
        }
        
    }

}

-(void)checkNetworkConnect
{
    if ([MessageObject isConnectionAvailable])
    {
        CGFloat delayTime = 0.0f;
        
        if ([[_error localizedFailureReason] isEqualToString:@"Error in connect() function"])
        {
            delayTime = 10.0f;
        }
        [self performSelector:@selector(connectServer) withObject:nil afterDelay:delayTime];
    }
 
}

- (void)connectServer
{
    [self reconnectServer];
}

- (void)connectServerSucceed:(IHGCDSocket *)ihGcdSock
{
    NSLog(@"OK");
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    if ([self.delegate respondsToSelector:@selector(connectServerSucceed:)])
    {
        [self.delegate connectServerSucceed:self];
    }
    
    if (self.userStr && self.passwordStr)
    {
        MessageObject *msgObj = [[MessageObject alloc] init];
        
        msgObj.sync_usrStr = self.userStr;
        msgObj.sync_pwdStr = self.passwordStr;
        msgObj.sync_optInt = 300;
        
        msgObj.sync_snStr = [MessageObject getCurrentDateStr];
        
        [self sendMsg:msgObj];
    }
}

-(void)ihPrint:(id)tit
{

    
}

@end