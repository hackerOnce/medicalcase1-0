//
//  CustomPushAnimation.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/1.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "CustomPushAnimation.h"

@implementation CustomPushAnimation

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 3.0;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    //起始View viewController
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    //目的view controller
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    toViewController.view.transform = CGAffineTransformMakeTranslation(toViewController.view.frame.size.width, toViewController.view.frame.size.height);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.transform = CGAffineTransformMakeTranslation(-toViewController.view.frame.size.width, -toViewController.view.frame.size.height);;
        toViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
//    toViewController.view.transform = cgaff
//    [[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];
//    
//    [UIView beginAnimations:@"RoationAnimation" context:NULL];
//    [UIView setAnimationDuration:2.0];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [_]
    
    
    
}
@end
