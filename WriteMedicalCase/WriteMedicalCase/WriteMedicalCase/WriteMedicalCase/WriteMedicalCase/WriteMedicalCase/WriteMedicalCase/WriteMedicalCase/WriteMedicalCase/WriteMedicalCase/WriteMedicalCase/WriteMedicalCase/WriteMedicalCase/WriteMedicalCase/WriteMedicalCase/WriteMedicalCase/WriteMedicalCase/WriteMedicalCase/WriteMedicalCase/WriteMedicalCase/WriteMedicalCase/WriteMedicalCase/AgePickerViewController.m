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

@end

@implementation AgePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.title = @"新建年龄段";
    
}
- (IBAction)ageSaveBtn:(UIBarButtonItem *)sender {
    
    self.startAgeString =[NSString stringWithFormat:@"%@岁",@([self.pickerView selectedRowInComponent:0])];
    self.endAgeString =[NSString stringWithFormat:@"%@岁",@([self.endPickerView selectedRowInComponent:0])];
    [self.ageDelegate selectedAgeRangeIs:[NSString stringWithFormat:@"%@ - %@",self.startAgeString,self.endAgeString]];
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.defaultString){
        NSArray *tempArray =  [self.defaultString componentsSeparatedByString:@"岁"];
        self.startAgeString = tempArray[0];
        
        NSString *tempStr = tempArray[1];

        self.endAgeString = [[tempStr componentsSeparatedByString:@" "] objectAtIndex:2];
        
        [self.endPickerView selectRow:[self.endAgeString integerValue] inComponent:0 animated:NO];
        [self.pickerView selectRow:[self.startAgeString integerValue] inComponent:0 animated:NO];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
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
/*
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if(component == 0){
        return  200;
    }else {
        return 200;

}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"unwindSegueAgeCancel"]) {
        
    }
}


@end
