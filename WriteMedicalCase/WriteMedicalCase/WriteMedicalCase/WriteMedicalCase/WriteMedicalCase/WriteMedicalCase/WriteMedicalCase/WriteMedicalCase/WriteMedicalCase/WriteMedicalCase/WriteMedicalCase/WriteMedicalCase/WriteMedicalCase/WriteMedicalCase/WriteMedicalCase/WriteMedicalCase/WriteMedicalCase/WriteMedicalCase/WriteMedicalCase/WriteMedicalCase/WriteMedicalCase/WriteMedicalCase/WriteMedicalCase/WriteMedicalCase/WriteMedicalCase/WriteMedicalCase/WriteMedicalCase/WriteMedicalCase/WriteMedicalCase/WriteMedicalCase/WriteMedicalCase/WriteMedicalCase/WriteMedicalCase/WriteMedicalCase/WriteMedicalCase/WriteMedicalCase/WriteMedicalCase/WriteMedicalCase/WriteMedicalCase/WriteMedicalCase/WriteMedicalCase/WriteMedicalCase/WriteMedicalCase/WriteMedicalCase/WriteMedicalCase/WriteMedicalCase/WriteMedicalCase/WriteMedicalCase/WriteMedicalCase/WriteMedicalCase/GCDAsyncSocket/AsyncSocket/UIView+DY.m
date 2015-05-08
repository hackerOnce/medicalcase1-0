//
//  UIView+DY.m
//  community
//
//  Created by ihefe33 on 3/19/15.
//  Copyright (c) 2015 ihefe. All rights reserved.
//

#import "UIView+DY.h"

@implementation UIView (DY)

+(void)viewWithMessage:(NSString *)message toView:(UIView *)view
{
    UIView *showView =  [[UIView alloc]init];
    showView.backgroundColor = [UIColor grayColor];
//    showView.alpha = 0.8f;
    showView.layer.cornerRadius = 5.0f;
    showView.layer.masksToBounds = YES;
    [view addSubview:showView];
    
//
//    NSDictionary *attributeDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   DYFont(25),NSFontAttributeName,
//                                   [UIColor grayColor],NSForegroundColorAttributeName,nil];
//
    UILabel *label = [[UILabel alloc]init];


    label.textAlignment = NSTextAlignmentCenter;
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:30];
    [showView addSubview:label];
    
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize labelSize = [label.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:options attributes:nil context:nil].size;
    
    showView.center = CGPointMake(view.frame.size.width * 1/2, view.frame.size.height * 1/2);
    showView.bounds = CGRectMake(0, 0, labelSize.width + 200, labelSize.height + 100);
    label.frame = CGRectMake(0, 0, showView.frame.size.width , showView.frame.size.height);
    [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionTransitionNone animations:^{
        showView.alpha = 0;
    } completion:^(BOOL finished) {
        [showView removeFromSuperview];

    }];
}



@end
