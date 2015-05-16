//
//  AgePickerViewController.m
//  MedCase
//
//  Created by ihefe-JF on 15/3/9.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "AgePickerViewController.h"

@interface AgePickerViewController () <UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UIPickerView *endPickerView;

@property (nonatomic,strong) NSString *pickerString;

@property (nonatomic,strong) NSString *startAgeString;
@property (nonatomic,strong) NSString *endAgeString;
@property (nonatomic,strong) CoreDataStack *coreDataStack;

@end

@implementation AgePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}
- (IBAction)cancelButton:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)ageSaveBtn:(UIBarButtonItem *)sender {
    
    self.startAgeString =[NSString stringWithFormat:@"%@岁",@([self.pickerView selectedRowInComponent:0])];
    self.endAgeString =[NSString stringWithFormat:@"%@岁",@([self.endPickerView selectedRowInComponent:0])];
    
    self.selectedHightNode.nodeAge = self.endAgeString;
    self.selectedLowNode.nodeAge = self.startAgeString;
    
    self.selectedHightNode.nodeContent = [NSString stringWithFormat:@"%@ - %@",self.startAgeString,self.endAgeString];
    self.selectedLowNode.nodeContent = self.selectedHightNode.nodeContent;
    
    [self.coreDataStack saveContext];
    
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.ageDelegate selectedAgeRangeIs:[NSString stringWithFormat:@"%@ - %@",self.startAgeString,self.endAgeString]];
//    [self.navigationController popViewControllerAnimated:NO];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *defaultAgeString = [self.selectedHightNode.nodeContent isEqualToString:@""]?@"0岁-0岁":self.selectedHightNode.nodeContent;
    
    NSArray *tempArray =  [defaultAgeString componentsSeparatedByString:@"-"];
    self.startAgeString = tempArray[0];

    self.endAgeString = tempArray[1];
    [self.endPickerView selectRow:[self.endAgeString integerValue] inComponent:0 animated:NO];
    [self.pickerView selectRow:[self.startAgeString integerValue] inComponent:0 animated:NO];

}

#pragma mask - picker view delegate
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 100;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView == self.pickerView){
        return [NSString stringWithFormat:@"%@",@(row)];
    }else {
        return [NSString stringWithFormat:@"%@",@(row)];
 
    }
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.startAgeString =[NSString stringWithFormat:@"%@岁",@([self.pickerView selectedRowInComponent:0])];
    self.endAgeString =[NSString stringWithFormat:@"%@岁",@([self.endPickerView selectedRowInComponent:0])];
    
    if([self.startAgeString integerValue] == 99){
        [self.endPickerView selectRow:[self.startAgeString integerValue] inComponent:0 animated:YES];

    }else if([self.startAgeString integerValue] > [self.endAgeString integerValue]){
        [self.endPickerView selectRow:[self.startAgeString integerValue]+ 1 inComponent:0 animated:YES];
        
        self.endAgeString =[NSString stringWithFormat:@"%@岁",@([self.endPickerView selectedRowInComponent:0])];
    }
    
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        if ([segue.identifier isEqualToString:@"unwindSegueAgeCancel"]) {
        
    }
}


@end
