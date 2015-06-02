//
//  RecordNoteWarningViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/2.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "RecordNoteWarningViewController.h"

@interface RecordNoteWarningViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;
@property (weak, nonatomic) IBOutlet UITextView *detailInfoTextView;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@end

@implementation RecordNoteWarningViewController
#pragma mask - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self.datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans_CN"]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    
    NSDate *minDate = [formatter dateFromString:@"1900-01-01 00:00:00"];
    NSDate *maxDate = [formatter dateFromString:@"2099-01-01 00:00:00"];
    self.datePicker.minimumDate = minDate;
    self.datePicker.maximumDate = maxDate;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardDidHideNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)keyBoardWillHide:(NSNotification*)notificaion
{
    self.datePicker.hidden = NO;
}

- (IBAction)cancel:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)save:(UIBarButtonItem *)sender
{
   
}

#pragma mask - text view delegate

-(void)textViewDidChange:(UITextView *)textView
{
    //[textView scrollRangeToVisible:textView.selectedRange];
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.datePicker.hidden = YES;
    return YES;
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
