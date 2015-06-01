//
//  ReordNoteCreateViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/1.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ReordNoteCreateViewController.h"
#import "CustomPushAnimation.h"

@interface ReordNoteCreateViewController ()<UINavigationControllerDelegate>
@property (nonatomic,strong) CustomPushAnimation *customPushAnimation;
@end

@implementation ReordNoteCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationController.delegate = self;
        
}

#pragma mask - navigation view controller delegate
-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush) {
        return self.customPushAnimation;
    }else {
        return nil;
    }
}

#pragma mask - Custom push animation
-(CustomPushAnimation *)customPushAnimation
{
    if (!_customPushAnimation) {
        _customPushAnimation = [[CustomPushAnimation alloc] init];
    }
    return _customPushAnimation;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
