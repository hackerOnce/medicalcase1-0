//  RecordNoteCreateCellTableViewCell.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/2.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "RecordNoteCreateCellTableViewCell.h"

@implementation RecordNoteCreateCellTableViewCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UITextView *textView = (UITextView*)[self viewWithTag:1002];
        textView.delegate = self;
        NSLog(@"text view:%@",textView.delegate);
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    
    UITextView *textView = (UITextView*)[self viewWithTag:1002];

    UITextField *placeHolder = (UITextField*)[self viewWithTag:1001];

    NSString *textViewText = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([StringValue(textViewText) isEqualToString:@""]) {
        placeHolder.hidden = NO;
    }else {
        placeHolder.hidden = YES;
    }
    
//    UITableView *tableView = [self tableView];
//    [tableView beginUpdates];
//    [tableView endUpdates];

}

-(void)textViewDidChange:(UITextView *)textView
{
    [self.delegate textViewCell:self didChangeText:textView.text];
    CGRect bounds = textView.bounds;
    
    CGSize maxSize = CGSizeMake(bounds.size.width, CGFLOAT_MAX);
    CGSize newSize = [textView sizeThatFits:maxSize];
    
    if (newSize.width < bounds.size.width) {
        newSize.width = bounds.size.width;
    }
    
    bounds.size = newSize;
    
    textView.bounds = bounds;
    
    UITableView *tableView = [self tableView];
    [tableView beginUpdates];
    [tableView endUpdates];
    
    UITextField *placeHolder = (UITextField*)[self viewWithTag:1001];

    if ([textView.text isEqualToString:@""]) {

        placeHolder.hidden = NO;
    }else {
        placeHolder.hidden = YES;
    }
    
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    UITextField *placeHolder = (UITextField*)[self viewWithTag:1001];

    if ([textView.text isEqualToString:@""]) {
        placeHolder.hidden = NO;
    }else {
        placeHolder.hidden = YES;

    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:self];
    [self.delegate textViewDidBeginEditing:textView withCellIndexPath:indexPath];
    
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    UITextField *placeHolder = (UITextField*)[self viewWithTag:1001];
    placeHolder.hidden = YES;
    
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:self];
    [self.delegate textViewShouldBeginEditing:textView withCellIndexPath:indexPath];
    return YES;
}

-(UITableView*)tableView
{
    UIView *tableView = self.superview;
    
    while (![tableView isKindOfClass:[UITableView class]]) {
        tableView = tableView.superview;
    }
    
    return (UITableView*)tableView;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
