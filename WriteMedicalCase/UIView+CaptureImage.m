//
//  UIView+CaptureImage.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "UIView+CaptureImage.h"

@implementation UIView (CaptureImage)

-(UIImage*)capture
{
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
