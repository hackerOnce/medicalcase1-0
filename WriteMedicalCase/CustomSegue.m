//
//  CustomSegue.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/22.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "CustomSegue.h"
#import "WriteCaseEditViewController.h"
#import "WriteCaseShowTemplateViewController.h"


static BOOL segueFlag = NO;

@implementation CustomSegue
-(void)perform
{
    WriteCaseEditViewController *sourceVC = (WriteCaseEditViewController*)self.sourceViewController;
    //UINavigationController *navigation =
    __block  WriteCaseShowTemplateViewController *destinationVC = (WriteCaseShowTemplateViewController*) self.destinationViewController;
    
    
    [destinationVC.view setFrame:sourceVC.rightSideSlideView.bounds];
    
    CGRect tempRect = sourceVC.rightSideSlideView.frame;
    
    if(tempRect.origin.x >= CGRectGetWidth(sourceVC.view.frame)){
        tempRect.origin.x -= rightSideSlideViewWidth;
        segueFlag = NO;
        [sourceVC.rightSideSlideView addSubview:destinationVC.view];
    }else {
      //  sourceVC.maskView.alpha = 0;
        tempRect.origin.x += rightSideSlideViewWidth;
        
        segueFlag = YES;
    }
    //[sourceVC.rightSideSlideView setTransform:CGAffineTransformMakeRotation(-M_PI/2)];
    
    
    
   // sourceVC.medicalCaseModelButton.enabled = NO;
    [UIView animateWithDuration:0.4 animations:^{
        
        sourceVC.rightSideSlideView.frame = tempRect;
        
    } completion:^(BOOL finished) {
        
     //   sourceVC.medicalCaseModelButton.enabled = YES;
        
        if(segueFlag){
            
            [destinationVC removeFromParentViewController];
            
            [destinationVC.view removeFromSuperview];
            [destinationVC didMoveToParentViewController:nil];
            [sourceVC.rightSideSlideView removeFromSuperview];
            sourceVC.rightSideSlideView = nil;
            destinationVC = nil;
            
          //  sourceVC.maskView = nil;
            sourceVC.rightSlideViewFlag = NO;
        }else {
           // sourceVC.maskView.alpha = 0.5;
            [sourceVC addChildViewController:destinationVC];
            
            // [destinationVC didMoveToParentViewController:sourceVC];
        }
    }];
    
}

@end
