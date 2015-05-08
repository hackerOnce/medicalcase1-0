//
//  NSData+Zip.h
//  O_M
//
//  Created by zhou shanyong on 12-6-6.
//  Copyright (c) 2012年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Zip)

- (NSData*) compress;
- (NSData*) uncompress;

@end
