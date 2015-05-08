//
//  IHGCDSocket.h
//  iosocket
//
//  Created by macHs on 14-8-15.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

typedef enum {
    NotEmptyHeaders = 1, //四字节
    EmptyHeaders = 0 //无四字节
} isFirstFourBytes;

typedef NS_OPTIONS(NSInteger, OperationCommand)
{
    TAG_HEADER = 0, //头
    TAG_BODY = 1 ,//体
    FourBytes = 4
} ;


@protocol IHGCDSocketDelegate;

@interface IHGCDSocket : NSObject
<GCDAsyncSocketDelegate>
{
//    GCDAsyncSocket *asyncSocket;
    unsigned int remainingToRead;
    NSMutableDictionary *lists;
 
}

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;

@property(readwrite,assign)unsigned int sendNumbar;

@property(nonatomic,assign)isFirstFourBytes isFirstFourBytes;

@property(nonatomic,strong)NSMutableData *mdata;

@property (readwrite, copy) NSString *hostName;

@property (readwrite, assign) UInt16 hostPort;

@property(nonatomic,assign)NSInteger timeout;

@property(nonatomic,weak)id<IHGCDSocketDelegate> delegate;

@property(nonatomic,assign)BOOL isPrint;

@property (strong,nonatomic) void (^fail)(NSError *error);


- (void)connectToHost:(NSString *)severHost onPort:(UInt16)port;
- (void)sendDataToServer:(NSData *)msgObj;

 
- (void)close;
@end

@protocol IHGCDSocketDelegate <NSObject>
@required

//接收数据
- (void)ihSocket:(IHGCDSocket *)ihGcdSock didReceive:(NSData *)data;

@optional
//连接服务器成功
- (void)connectServerSucceed:(IHGCDSocket *)ihGcdSock;
//连接失败调用
- (void)connectServerDefeat:(IHGCDSocket *)ihGcdSock error:(NSError *)error;
 //发送成功
- (void)ihSocket:(IHGCDSocket *)ihGcdSock  total:(long )total;


- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock;
//与服务器断开
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err;
//在socket成功完成ssl/tls协商时调用
- (void)socketDidSecure:(GCDAsyncSocket *)sock;
//当产生一个socket去处理连接时调用
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket;
//  当一个socket写入一些数据，但还没有完成整个写入时调用，它可以用来更新进度条等东西
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;
// 当一个socket读取数据，但尚未完成读操作的时候调用，如果使用 readToData: or readToLength: 方法 会发生,可以被用来更新进度条等东西
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;
@end

