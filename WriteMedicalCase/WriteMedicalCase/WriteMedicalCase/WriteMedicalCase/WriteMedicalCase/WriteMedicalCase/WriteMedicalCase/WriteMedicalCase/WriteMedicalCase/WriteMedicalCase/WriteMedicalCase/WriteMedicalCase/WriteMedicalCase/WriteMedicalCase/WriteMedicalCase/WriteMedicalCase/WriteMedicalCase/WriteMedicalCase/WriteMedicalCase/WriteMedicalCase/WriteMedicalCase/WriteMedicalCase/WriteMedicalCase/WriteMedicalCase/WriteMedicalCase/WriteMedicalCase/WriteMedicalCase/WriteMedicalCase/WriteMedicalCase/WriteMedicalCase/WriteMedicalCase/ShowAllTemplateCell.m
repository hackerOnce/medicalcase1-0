//
//  ShowAllTemplateCell.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/14.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "ShowAllTemplateCell.h"

@implementation ShowAllTemplateCell

-(void)textViewDidChange:(UITextView *)textView
{
    if ([self.showAllTemplateDelegate respondsToSelector:@selector(showAllTemplateCell:didChangeText: withTextView:)]) {
        [self.showAllTemplateDelegate showAllTemplateCell:self didChangeText:textView.text withTextView:textView];
    }
    
    CGRect bounds = textView.bounds;
    
    CGSize maxSize = CGSizeMake(bounds.size.width, CGFLOAT_MAX);
    CGSize newSize = [textView sizeThatFits:maxSize];
    
    if (newSize.width < bounds.size.width) {
        newSize.width = bounds.size.width;
    }
    if (newSize.height < bounds.size.height) {
        newSize.height = bounds.size.height;
    }
    bounds.size = newSize;
    
    textView.bounds = bounds;
    
    UITableView *tableView = [self tableView];
    [tableView beginUpdates];
    [tableView endUpdates];
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:self];
    [self.showAllTemplateDelegate textViewDidBeginEditing:textView withCellIndexPath:indexPath];
    
    return YES;
}
-(UITableView*)tableView
{
    UIView *tableView  = self.superview;
    
    while (![tableView isKindOfClass:[UITableView class]] && tableView) {
        tableView = tableView.superview;
    }
    return  (UITableView*)tableView;
}

@end
