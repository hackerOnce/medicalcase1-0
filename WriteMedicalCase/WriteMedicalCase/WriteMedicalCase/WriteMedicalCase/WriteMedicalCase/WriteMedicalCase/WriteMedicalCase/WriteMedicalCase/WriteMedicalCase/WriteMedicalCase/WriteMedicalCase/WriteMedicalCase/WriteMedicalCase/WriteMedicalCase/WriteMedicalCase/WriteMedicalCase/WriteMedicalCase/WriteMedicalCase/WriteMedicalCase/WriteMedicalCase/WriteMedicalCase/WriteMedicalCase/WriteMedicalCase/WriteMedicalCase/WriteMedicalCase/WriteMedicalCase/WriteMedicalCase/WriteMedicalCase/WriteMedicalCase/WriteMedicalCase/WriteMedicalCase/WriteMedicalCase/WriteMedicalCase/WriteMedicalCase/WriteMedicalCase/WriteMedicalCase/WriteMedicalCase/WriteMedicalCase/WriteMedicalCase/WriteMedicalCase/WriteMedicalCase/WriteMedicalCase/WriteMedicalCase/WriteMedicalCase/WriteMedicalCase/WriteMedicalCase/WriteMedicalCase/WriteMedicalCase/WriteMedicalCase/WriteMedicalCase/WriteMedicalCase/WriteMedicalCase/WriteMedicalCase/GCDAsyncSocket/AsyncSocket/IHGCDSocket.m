//
//  IHGCDSocket.m
//  iosocket
//
//  Created by macHs on 14-8-15.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import "IHGCDSocket.h"

@implementation IHGCDSocket

@synthesize asyncSocket;

- (id)init
{
    self = [super init];
    if (self) {
        [self ihPrint:__func__];
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
 
        self.timeout=-1;
        self.isFirstFourBytes=1;
        lists=[NSMutableDictionary dictionary];
    }
    return self;
}

- (void)connectToHost:(NSString *)severHost onPort:(UInt16)port
{
    [self ihPrint:__func__];
    self.hostName=severHost;
    self.hostPort=port;
    
    NSError *error = nil;
    if([asyncSocket connectToHost:self.hostName onPort:self.hostPort error:&error]){
    }else{
        NSLog(@"connectToHost error:%@",error);
        if ([_delegate respondsToSelector:@selector(connectServerDefeat:error:)]){
            [_delegate connectServerDefeat:self error:error];
        }
    }
    
}

#pragma mark  向服务器发送消息
- (void)sendDataToServer:(NSData *)aData
{
    [self ihPrint:__func__];
    if (self.isFirstFourBytes==0) {
        [asyncSocket writeData:aData withTimeout: self.timeout tag:TAG_HEADER];
    }else{
        
        unsigned long sendLength = [aData length];
        
        unsigned char fiveChar[FourBytes];
        
        for (int i = 0; i < FourBytes; i++)
        {
            fiveChar[i] = (Byte)((sendLength >> (8 * (3 - i))) & 0xff);
        }
        
        NSMutableData *sendData = [NSMutableData dataWithBytes:fiveChar length:FourBytes];
        [sendData appendData:aData];
        
        [asyncSocket writeData:sendData withTimeout: self.timeout tag:TAG_HEADER];
    }
}

- (void)close
{
    [self ihPrint:__func__];
    [asyncSocket disconnect];
}
#pragma mark socket委托
//连接socket出错时调用
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    
    NSLog(@"断开连接");
    [self ihPrint:__func__];
    if ([_delegate respondsToSelector:@selector(socketDidDisconnect:withError:)]){
        [_delegate socketDidDisconnect:sock withError:err];
    }
}

#pragma mark 发送成功代理
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [self ihPrint:__func__];
    _sendNumbar++;
    if ([_delegate respondsToSelector:@selector(ihSocket:total:)]){
        [_delegate ihSocket:self total:_sendNumbar];
    }

 
}
//与服务器建立连接时调用(连接成功)
#pragma mark 连接成功
- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
 
    [self ihPrint:__func__];
    [asyncSocket performBlock:^{
        [asyncSocket enableBackgroundingOnSocket];
    }];
    
    if ([_delegate respondsToSelector:@selector(connectServerSucceed:)]){
        [_delegate connectServerSucceed:self];
    }
    [asyncSocket readDataToLength:FourBytes withTimeout:self.timeout tag:TAG_HEADER];
}
-(void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    [self ihPrint:__func__];
    if ([_delegate respondsToSelector:@selector(socket:didWritePartialDataOfLength:tag:)]){
        [_delegate socket:sock didWritePartialDataOfLength:partialLength tag:tag];
    }
}
-(void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    [self ihPrint:__func__  ];
    if ([_delegate respondsToSelector:@selector(socket:didReadPartialDataOfLength:tag:)]){
        [_delegate socket:sock didReadPartialDataOfLength:partialLength tag:tag];
    }
}

-(unsigned int )getHeaderLength:(NSData *)data
{
    [self ihPrint:__func__];
    const unsigned char *chars = [data bytes];
    
    unsigned char *fourChars = malloc(FourBytes);
    for (NSInteger i = 0; i < FourBytes; i++){
        fourChars[i] = chars[i];
    }
    
    int p, q, temp;
    for (p = 0, q = FourBytes - 1; p < q; p++, q--){
        temp = fourChars[p];
        fourChars[p] = fourChars[q];
        fourChars[q] = temp;
    }
    
    unsigned int c=*(unsigned int *)fourChars;
    return c;
}

-(void)responseData:(NSData *)data
{
    [self ihPrint:__func__  ];
    if ([_delegate respondsToSelector:@selector(ihSocket:didReceive:)]){
        [_delegate ihSocket:self didReceive:data];
    }
}

#pragma mark 读数据成功代理
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self ihPrint:__func__ ];
    if (tag==TAG_HEADER) {
        int headerLength=[self getHeaderLength:data] ;
        [asyncSocket readDataToLength:headerLength withTimeout:self.timeout tag:TAG_BODY];
    }else if(tag==TAG_BODY){
        [self responseData:data];
        [asyncSocket readDataToLength:FourBytes withTimeout:self.timeout tag:TAG_HEADER];
    }

//    [asyncSocket readDataWithTimeout:-1 tag:tag];
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
    [self ihPrint:__func__  ];
    if ([_delegate respondsToSelector:@selector(socketDidCloseReadStream:)]){
        [_delegate socketDidCloseReadStream:sock];
    }
}

-(void)socketDidSecure:(GCDAsyncSocket *)sock
{
    [self ihPrint:__func__ ];
    if ([_delegate respondsToSelector:@selector(socketDidSecure:)]){
        [_delegate socketDidSecure:sock];
    }
}
-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    [self ihPrint:__func__ ];
    if ([_delegate respondsToSelector:@selector(socket:didAcceptNewSocket:)]){
        [_delegate socket:sock didAcceptNewSocket:newSocket];
    }
}
-(void)ihPrint:(const char *)tit
{
//    if (self.isPrint) {
//        NSLog(@"%s",tit);
//    }
    
}
@end
