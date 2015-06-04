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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commitTextViewHeightContraintes;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailTextViewHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerHeightConstraints;


@property (nonatomic,strong) NSString *selectedDateString;

@property (nonatomic,strong) NSDictionary *dict;
@end

@implementation RecordNoteWarningViewController
#pragma mask - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
   
//    [self.datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans_CN"]];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
//    
//    NSDate *minDate = [formatter dateFromString:@"1900-01-01 00:00:00"];
//    NSDate *maxDate = [formatter dateFromString:@"2099-01-01 00:00:00"];
//    self.datePicker.minimumDate = minDate;
//    self.datePicker.maximumDate = maxDate;
    
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
    self.datePickerHeightConstraints.constant = 216;
    self.detailTextViewHeightConstraints.constant = 103;
    self.commitTextViewHeightContraintes.constant = 103;

}

- (IBAction)cancel:(UIBarButtonItem *)sender
{
    NSDictionary *tempDict = @{@"comment":@"",@"detailInfoText":@"",@"warningDate":@""};
    [self.delegate didSelectedDateString:tempDict];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)save:(UIBarButtonItem *)sender
{
    NSString *commentText = StringValue(self.commentsTextView.text);
    NSString *detailInfoText = StringValue(self.detailInfoTextView.text);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSString *selectedDateString = [formatter stringFromDate:self.datePicker.date];
    
    self.dict = @{@"comment":commentText,@"detailInfoText":detailInfoText,@"warningDate":selectedDateString};
    [self.delegate didSelectedDateString:self.dict];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mask - text view delegate

-(void)textViewDidChange:(UITextView *)textView
{
    //[textView scrollRangeToVisible:textView.selectedRange];
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    
    if (textView == self.commentsTextView) {
        self.datePickerHeightConstraints.constant = 0;
        self.detailTextViewHeightConstraints.constant = 0;
    }else {
        self.datePickerHeightConstraints.constant = 0;
        self.commitTextViewHeightContraintes.constant = 0;

    }
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
