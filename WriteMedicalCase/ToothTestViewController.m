//
//  ToothTestViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ToothTestViewController.h"
#import "ToothViewController.h"
#import "ToothView.h"
#import "TextAttachmentForImage.h"
#import "UIView+CaptureImage.h"


@interface ToothTestViewController ()<ToothViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ToothTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mask - Tooth view delegate
-(void)toothNumberSelectedResultString:(NSString *)selectedString
{
    
    NSAttributedString *attributedString = [self parseTouchNumberViewAndStringWithJsonString:selectedString];
    self.textView.attributedText = attributedString;
    
}
-(NSAttributedString*)parseTouchNumberViewAndStringWithJsonString:(NSString*)jsonString
{
    NSDictionary *dict = [self dictionaryWithJsonString:jsonString];
    NSString *number = [dict objectForKey:@"number"];
    NSString *selectedDepartment = [dict objectForKey:@"selectedDepartment"] ;
    NSString *description = [dict objectForKey:@"description" ];
    
    ToothView *toothView = [[ToothView alloc] initWithFrame:CGRectMake(100, 200, 50, 44)];
    toothView.number = number;
    toothView.position = selectedDepartment;
    
    UIImage *toothViewImage = [toothView capture];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:description?description:@" "];
    
    TextAttachmentForImage *textAttachment = [[TextAttachmentForImage alloc] initWithData:nil ofType:nil];
    textAttachment.image = toothViewImage;
    NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString insertAttributedString:textAttachmentString atIndex:0];
    
    return attributedString;
}
-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData

                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    
    return dic;
    
}
#pragma mask - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToothTest"]) {
        ToothViewController *toothVC =(ToothViewController*) [self segueToRightViewController:segue];
        toothVC.delegate = self;
    }
}
-(UIViewController*)segueToRightViewController:(UIStoryboardSegue*)segue
{
    UIViewController *viewController = segue.destinationViewController;
    if ([viewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController*)viewController;
        viewController = [nav.viewControllers firstObject];
    }
    
    return viewController;
}


@end
