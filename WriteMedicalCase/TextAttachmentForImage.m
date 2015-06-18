//
//  TextAttachmentForImage.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "TextAttachmentForImage.h"

@implementation TextAttachmentForImage
-(CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    return CGRectMake(0, -2,self.image.size.width, self.image.size.height);
}
@end
