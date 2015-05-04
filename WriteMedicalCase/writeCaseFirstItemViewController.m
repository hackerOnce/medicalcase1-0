//
//  writeCaseFirstItemViewController.m
//  WriteMedicalCase
//
//  Created by GK on 15/5/2.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "writeCaseFirstItemViewController.h"
#import "WriteCaseShowTemplateViewController.h"

@interface writeCaseFirstItemViewController ()<WriteCaseShowTemplateViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *navButton;
@property (weak, nonatomic) IBOutlet AutoHeightTextView *textView;

@end

@implementation writeCaseFirstItemViewController
- (IBAction)cancelButton:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveButtonClicked:(UIButton *)sender
{
    [self.delegate didWriteWithString:self.textView.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)leftUpButton:(UIButton *)sender {
    
    if (self.rightSlideViewFlag) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectedTitleLabel" object:self.titleString];
    }else {
        [self performSegueWithIdentifier:@"firstItemCustomSegue" sender:nil];
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addSideButttonToWindow];

    self.navButton.layer.cornerRadius = self.navButton.frame.size.width/2;
    self.navButton.backgroundColor = [UIColor whiteColor];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.textView.text = self.textViewContent;

    self.title = self.titleString;
  //  [self.textView becomeFirstResponder];
    [self performSegueWithIdentifier:@"firstItemCustomSegue" sender:nil];
 
    
}
 -(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
    [self removeKeyWindowButton];
}
-(void)removeKeyWindowButton

{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    id windowView = [keyWindow viewWithTag:20002];
    
    if ([windowView isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)windowView;
        [button removeFromSuperview];
    }
    if (self.rightSlideViewFlag) {
        [self performSegueWithIdentifier:@"firstItemCustomSegue" sender:nil];
    }

}
#pragma mask - property
-(UIView *)rightSideSlideView
{
    if(!_rightSideSlideView){
        _rightSideSlideView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame),0,rightSideSlideViewWidth , CGRectGetHeight(self.view.frame) - 0 - 45)];
        _rightSideSlideView.backgroundColor = [UIColor yellowColor];
        
        UISwipeGestureRecognizer *recoginizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideRightSildeView:)];
        recoginizer.direction = UISwipeGestureRecognizerDirectionRight;
        
        [_rightSideSlideView addGestureRecognizer:recoginizer];
        
        // [self.view addSubview:_rightSideSlideView];
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        [keyWindow addSubview:self.rightSideSlideView];
        
        self.rightSlideViewFlag = YES;
    }
    
    return _rightSideSlideView;
}
-(void)hideRightSildeView:(UISwipeGestureRecognizer *)swipGesture
{
    
    CGRect tempRect = self.rightSideSlideView.frame;
    tempRect.origin.x += rightSideSlideViewWidth - 10;
    [UIView animateWithDuration:0.4 animations:^{
        self.rightSideSlideView.frame = tempRect;
    } completion:^(BOOL finished) {
        [self performSegueWithIdentifier:@"firstItemCustomSegue" sender:nil];
    }];
    
}
-(void)addSideButttonToWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"按钮" forState:UIControlStateNormal];
    CGRect frame = CGRectMake(keyWindow.frame.size.width - 60, CGRectGetMidY(keyWindow.frame), 60, 60);
    [button addTarget:self action:@selector(sideButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = frame;
    button.tag = 20002;
    [keyWindow addSubview:button];
}
-(void)sideButtonClicked:(UIButton*)sender
{
    [self performSegueWithIdentifier:@"firstItemCustomSegue" sender:nil];
}
-(void)didSelectedTemplateWithNode:(Template *)templated withTitleStr:(NSString *)titleStr
{
    self.textView.text = templated.content;
    [self performSegueWithIdentifier:@"firstItemCustomSegue" sender:nil];

}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"firstItemCustomSegue"]) {
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        WriteCaseShowTemplateViewController *showTemplateVC = (WriteCaseShowTemplateViewController*)[nav.viewControllers firstObject];
        showTemplateVC.templateName = self.titleString;
        showTemplateVC.showTemplateDelegate = self;
    }
}

@end
