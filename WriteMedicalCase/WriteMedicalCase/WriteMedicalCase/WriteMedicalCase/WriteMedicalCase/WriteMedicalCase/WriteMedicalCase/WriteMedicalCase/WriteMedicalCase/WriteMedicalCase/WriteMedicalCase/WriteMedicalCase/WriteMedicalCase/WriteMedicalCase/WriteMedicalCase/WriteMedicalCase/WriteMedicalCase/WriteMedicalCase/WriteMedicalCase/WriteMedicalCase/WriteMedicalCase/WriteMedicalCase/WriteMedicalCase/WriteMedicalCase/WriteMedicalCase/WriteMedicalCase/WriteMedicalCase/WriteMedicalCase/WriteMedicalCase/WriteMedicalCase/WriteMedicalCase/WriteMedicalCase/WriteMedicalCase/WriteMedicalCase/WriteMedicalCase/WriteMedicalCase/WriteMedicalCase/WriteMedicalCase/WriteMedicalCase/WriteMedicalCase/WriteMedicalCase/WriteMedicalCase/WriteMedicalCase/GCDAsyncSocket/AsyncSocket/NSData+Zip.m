//
//  NSData+Zip.m
//  O_M
//
//  Created by zhou shanyong on 12-6-6.
//  Copyright (c) 2012年 ihefe. All rights reserved.
//

#import "NSData+Zip.h"
#import <zlib.h>

#define kMemoryChunkSize		1024
#define kFileChunkSize			(128 * 1024) //128Kb

@implementation NSData (Zip)

- (NSData*) compress
{
	NSUInteger		length = [self length];
	//int				windowBits = 15 + 16, //Default + gzip header instead of zlib header
    int             memLevel = 8; //Default
    int             retCode;
	NSMutableData*	result;
	z_stream		stream;
	unsigned char	output[kMemoryChunkSize];
	uInt			gotBack;
	
	if((length == 0) || (length > UINT_MAX)) //FIXME: Support 64 bit inputs
        return nil;
    
	bzero(&stream, sizeof(z_stream));
	stream.avail_in = (uInt)length;
	stream.next_in = (unsigned char*)[self bytes];
	
	//retCode = deflateInit2(&stream, Z_BEST_COMPRESSION, Z_DEFLATED, windowBits, memLevel, Z_DEFAULT_STRATEGY);
    retCode = deflateInit(&stream, memLevel);
	if(retCode != Z_OK) {
		NSLog(@"%s: deflateInit2() failed with error %i", __FUNCTION__, retCode);
		return nil;
	}
	
	result = [NSMutableData dataWithCapacity:(length / 4)];
	do {
		stream.avail_out = kMemoryChunkSize;
		stream.next_out = output;
		retCode = deflate(&stream, Z_FINISH);
		if((retCode != Z_OK) && (retCode != Z_STREAM_END)) {
			NSLog(@"%s: deflate() failed with error %i", __FUNCTION__, retCode);
			deflateEnd(&stream);
			return nil;
		}
		gotBack = kMemoryChunkSize - stream.avail_out;
		if(gotBack > 0)
            [result appendBytes:output length:gotBack];
	} while(retCode == Z_OK);
	deflateEnd(&stream);
	
	return (retCode == Z_STREAM_END ? result : nil);
}

- (NSData*) uncompress
{
	NSUInteger		length = [self length];
	//int				windowBits = 15 + 16, //Default + gzip header instead of zlib header
    int             retCode;
	unsigned char	output[kMemoryChunkSize];
	uInt			gotBack;
	NSMutableData*	result;
	z_stream		stream;
	//uLong			size;
	
	if((length == 0) || (length > UINT_MAX)) //FIXME: Support 64 bit inputs
        return nil;
#if 0
	//FIXME: Remove support for original implementation of -compressGZip which wasn't generating real gzip data 
	if((length >= sizeof(unsigned int)) && ((*((unsigned char*)[self bytes]) != 0x1F) || (*((unsigned char*)[self bytes] + 1) != 0x8B))) {
		size = NSSwapBigIntToHost(*((unsigned int*)[self bytes]));
		result = (size < 0x40000000 ? [NSMutableData dataWithLength:size] : nil); //HACK: Prevent allocating more than 1 Gb
		if(result && (uncompress([result mutableBytes], &size, (unsigned char*)[self bytes] + sizeof(unsigned int), [self length] - sizeof(unsigned int)) != Z_OK))
            result = nil;
		return result;
	}
#endif
	bzero(&stream, sizeof(z_stream));
	stream.avail_in = (uInt)length;
	stream.next_in = (unsigned char*)[self bytes];
	
	//retCode = inflateInit2(&stream, windowBits);
    retCode = inflateInit(&stream);
	if(retCode != Z_OK) {
		NSLog(@"%s: inflateInit2() failed with error %i", __FUNCTION__, retCode);
		return nil;
	}
	
	result = [NSMutableData dataWithCapacity:(length * 4)];
	do {
		stream.avail_out = kMemoryChunkSize;
		stream.next_out = output;
		retCode = inflate(&stream, Z_NO_FLUSH);
		if ((retCode != Z_OK) && (retCode != Z_STREAM_END)) {
			NSLog(@"%s: inflate() failed with error %i", __FUNCTION__, retCode);
			inflateEnd(&stream);
			return nil;
		}
		gotBack = kMemoryChunkSize - stream.avail_out;
		if(gotBack > 0)
            [result appendBytes:output length:gotBack];
	} while(retCode == Z_OK);
	inflateEnd(&stream);
	
	return (retCode == Z_STREAM_END ? result : nil);
}

@end
