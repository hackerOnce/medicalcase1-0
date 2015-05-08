//
//  ModelPlateConditionsViewController.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/2.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "ModelPlateConditionsViewController.h"
#import "ModelPlateConditionViewController.h"
#import "AgePickerViewController.h"
#import "CreateTemplateViewController.h"

@interface ModelPlateConditionsViewController ()<UITableViewDelegate,UITableViewDataSource,ModelPlateConditionViewControllerDelegate,AgePickerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableDictionary *dataDic;
@property (weak, nonatomic) IBOutlet UILabel *selectedConditionResultStr;

@property (nonatomic,strong) NSMutableDictionary *dataDicWithValueArray;

@property(nonatomic,strong) NSString *selectedCellStr;
@property(nonatomic,strong) NSString *selectedCellContentStr;

@property(nonatomic,strong) NSMutableArray *tempResultArray;
@property (nonatomic,strong) NSMutableOrderedSet *tempResultSet;

@end

@implementation ModelPlateConditionsViewController

-(NSMutableArray *)dataArray
{
    if (!_dataArray){
        _dataArray = [[NSMutableArray alloc] init];
        [_dataArray addObject:@"性别"];
        [_dataArray addObject:@"年龄段"];
        [_dataArray addObject:@"入院诊断"];
        [_dataArray addObject:@"主要症状"];
        [_dataArray addObject:@"伴随症状"];
    }
    return _dataArray;
}
-(NSMutableArray *)tempResultArray
{
    if(!_tempResultArray){
        _tempResultArray = [[NSMutableArray alloc] init];
    }
    return _tempResultArray;
}
-(NSMutableOrderedSet *)tempResultSet
{
    if(!_tempResultSet){
        _tempResultSet = [[NSMutableOrderedSet alloc] init];
    }
    return _tempResultSet;
}
-(NSMutableDictionary *)dataDicWithValueArray
{
    if(!_dataDicWithValueArray){
        _dataDicWithValueArray = [[NSMutableDictionary alloc] init];
        
        NSArray *arr1 = @[@"男",@"女"];
        NSArray *arr2 = @[@"哮喘1",@"哮喘2",@"哮喘3",@"哮喘4",@"哮喘5",@"哮喘6"];
        NSArray *arr3 = @[@"咳嗽1",@"咳嗽2",@"咳嗽3",@"咳嗽4",@"咳嗽5",@"咳嗽6"];
        NSArray *arr4 = @[@"呼吸困难1",@"呼吸困难2",@"呼吸困难3",@"呼吸困难4",@"呼吸困难5",@"呼吸困难6"];

        NSArray *sumArray = @[arr1,arr2,arr3,arr4];
        NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:self.dataArray];
        [tempArr removeObject:@"年龄段"];
        
        for (NSString *str in tempArr) {
            NSInteger index = [tempArr indexOfObject:str];
            [_dataDicWithValueArray setValue:sumArray[index] forKey:str];
        }
    }
    return _dataDicWithValueArray;
}
-(NSMutableDictionary *)dataDic
{
    if (!_dataDic) {
        _dataDic = [[NSMutableDictionary alloc] init];
        
        for (NSString *str in self.dataArray) {
            [_dataDic setObject:@"请选择" forKey:str];
        }
    }
        return _dataDic;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count + 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == self.dataArray.count) {
        cell  =[tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
        UILabel *customCellLabel = (UILabel*)[cell viewWithTag:101];
        customCellLabel.text = @"自定义";
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ModelPlateConditionsCell"];
        [self configCell:cell withIndexPath:indexPath];
    }
        return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *cellLabel = (UILabel*)[cell viewWithTag:1001];
    UILabel *cellSelectedContentLabel = (UILabel*)[cell viewWithTag:1002];
    self.selectedCellContentStr = cellSelectedContentLabel.text;
    self.selectedCellStr = cellLabel.text;
    
    if([cellLabel.text isEqualToString:@"年龄段"]){
        [self performSegueWithIdentifier:@"conditionAgeSegue" sender:nil];
    }else {
        [self performSegueWithIdentifier:@"selecteConditionSegue" sender:nil];
    }
    
}
-(void)configCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    UILabel *cellLabelClass = (UILabel*)[cell viewWithTag:1001];
    UILabel *cellLabelContent = (UILabel*)[cell viewWithTag:1002];
    
    NSString *str = [self.dataArray objectAtIndex:indexPath.row];
    cellLabelClass.text = str;
    cellLabelContent.text = [self.dataDic objectForKey:str];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selecteConditionSegue"]) {
        ModelPlateConditionViewController *conditionVC = (ModelPlateConditionViewController*)segue.destinationViewController;
        
        if ([self.selectedCellStr isEqual:@"性别"]) {
            conditionVC.dataSource = [self.dataDicWithValueArray objectForKey:self.selectedCellStr];
            conditionVC.hideSearchBar = YES;
            conditionVC.title = @"选择性别";
        }else {
          if ([self.selectedCellStr isEqualToString:@"入院诊断"]) {
             conditionVC.loadURLStr = @"diseases";
              conditionVC.title = self.selectedCellStr;
          }else if([self.selectedCellStr isEqualToString:@"伴随症状"]){
              conditionVC.subSymptom = @"sub_symptoms";
              conditionVC.symptomName =  [self.dataDic objectForKey:@"主要症状"];
             conditionVC.loadURLStr = @"symptoms";
              conditionVC.hideSearchBar = YES;
              conditionVC.title = self.selectedCellStr;

          }else if([self.selectedCellStr isEqualToString:@"主要症状"]){
            conditionVC.loadURLStr = @"symptoms";
              conditionVC.title = self.selectedCellStr;

          }
        }

        conditionVC.conditionDelegate = self;
    }else  if ([segue.identifier isEqualToString:@"conditionAgeSegue"]){
        AgePickerViewController *ageVC = (AgePickerViewController*)segue.destinationViewController;
        ageVC.ageDelegate = self;
        ageVC.title = @"选择年龄";
        if([self.selectedCellContentStr isEqualToString:@"请选择"]){
            self.selectedCellContentStr = @"0岁 - 0岁";
        }
        ageVC.defaultString = self.selectedCellContentStr;
    } else if([segue.identifier isEqualToString:@"unwindToCreateTemplateVC"]){
        CreateTemplateViewController *createVC =(CreateTemplateViewController*) segue.destinationViewController;
        createVC.conditionLabelStr = self.selectedConditionResultStr.text != nil ? self.selectedConditionResultStr.text : @"I am default";
        createVC.conditionDicData = [[NSMutableDictionary alloc] initWithDictionary:self.dataDic];
    }
}

#pragma -mask ModelPlateConditionViewControllerDelegate
-(void)didSelectedStr:(NSString *)str
{
    self.tempResultSet = nil;
    
    NSString *tempStr = [self.dataDic objectForKey:self.selectedCellStr];
    if (![tempStr isEqualToString:str]) {
        [self.dataDic setValue:str forKey:self.selectedCellStr];
        if ([self.selectedCellStr isEqualToString:@"主要症状"]) {
            [self.dataDic setValue:@"请选择" forKey:@"伴随症状"];
        }
    }
      //  [self.tempResultArray addObject:str];
    for (NSString *str in self.dataArray) {
        if (![[self.dataDic objectForKey:str] isEqualToString:@"请选择"]) {
            [self.tempResultSet addObject:[self.dataDic objectForKey:str]];
        }
    }
    self.selectedConditionResultStr.text = [self.tempResultSet.array componentsJoinedByString:@","];
    
    [self.tableView reloadData];
}
#pragma -mask AgePickerViewControllerDelegate
-(void)selectedAgeRangeIs:(NSString *)ageString
{
    self.tempResultSet = nil;

    [self.dataDic setValue:ageString forKey:self.selectedCellStr];
   // [self.tempResultArray addObject:ageString];
    
    for (NSString *str in self.dataArray) {
        if (![[self.dataDic objectForKey:str] isEqualToString:@"请选择"]) {
            [self.tempResultSet addObject:[self.dataDic objectForKey:str]];
        }
    }
    self.selectedConditionResultStr.text = [self.tempResultSet.array componentsJoinedByString:@","];
    [self.tableView reloadData];
}

#pragma mask - unwind
///other conditions segue
- (IBAction)unwindSegueFromConditionVCToConditionsVC:(UIStoryboardSegue *)segue{
    
    
    
}

//- (IBAction)unwindSegueSaveFromConditionVCToConditionsVC:(UIStoryboardSegue *)segue {
//    
//    
//    
//}
///age unwind segue
- (IBAction)unwindSegueAgeCancelVCFromConditionVCToConditionsVC:(UIStoryboardSegue *)segue {
    
    
    
}
//- (IBAction)unwindSegueAgeSaveVCFromConditionVCToConditionsVC:(UIStoryboardSegue *)segue {
//    
//    
//    
//}

@end
