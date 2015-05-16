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
#import "ModelPlateConditionDetailViewController.h"

@interface ModelPlateConditionsViewController ()<UITableViewDelegate,UITableViewDataSource,
    NSFetchedResultsControllerDelegate,
   ModelPlateConditionViewControllerDelegate,AgePickerViewControllerDelegate,UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableDictionary *dataDic;
@property (weak, nonatomic) IBOutlet UILabel *selectedConditionResultStr;

@property (nonatomic,strong) NSMutableDictionary *dataDicWithValueArray;

@property(nonatomic,strong) NSString *selectedCellStr;
@property(nonatomic,strong) NSString *selectedCellContentStr;

@property(nonatomic,strong) NSMutableArray *tempResultArray;
@property (nonatomic,strong) NSMutableOrderedSet *tempResultSet;

@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) ParentNode *parentNode;

@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) Node *selectedNode;

@property (nonatomic,strong) NSIndexPath *selectedIndexPath;

@property (nonatomic,strong) UIPopoverPresentationController *ppc;
@end

@implementation ModelPlateConditionsViewController

-(NSManagedObjectContext *)managedObjectContext
{
    return self.coreDataStack.managedObjectContext;
}
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}
-(ParentNode *)parentNode
{
    if (!_parentNode) {
        _parentNode = [self.coreDataStack fetchParentNodeWithNodeEntityName:@"条件"];
    }
    return _parentNode;
}
-(NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[Node entityName]];
       // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentNode.nodeName = %@ AND nodeIndex != 2",@"条件"];
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentNode.nodeName = %@",@"条件"];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nodeIndex" ascending:YES];
        fetchRequest.sortDescriptors = @[sortDescriptor];
        
        fetchRequest.predicate = predicate;
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        NSError *error;
        
        if (![_fetchedResultsController performFetch:&error]) {
            NSLog(@"error:");
        }
    }
    return _fetchedResultsController;
}

//-(NSMutableArray *)dataArray
//{
//    if (!_dataArray){
//        _dataArray = [[NSMutableArray alloc] init];
//        [_dataArray addObject:@"性别"];
//        [_dataArray addObject:@"年龄段"];
//        [_dataArray addObject:@"入院诊断"];
//        [_dataArray addObject:@"主要症状"];
//        [_dataArray addObject:@"伴随症状"];
//    }
//    return _dataArray;
//}
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
//-(NSMutableDictionary *)dataDicWithValueArray
//{
//    if(!_dataDicWithValueArray){
//        _dataDicWithValueArray = [[NSMutableDictionary alloc] init];
//        
//        NSArray *arr1 = @[@"男",@"女"];
//        NSArray *arr2 = @[@"哮喘1",@"哮喘2",@"哮喘3",@"哮喘4",@"哮喘5",@"哮喘6"];
//        NSArray *arr3 = @[@"咳嗽1",@"咳嗽2",@"咳嗽3",@"咳嗽4",@"咳嗽5",@"咳嗽6"];
//        NSArray *arr4 = @[@"呼吸困难1",@"呼吸困难2",@"呼吸困难3",@"呼吸困难4",@"呼吸困难5",@"呼吸困难6"];
//
//        NSArray *sumArray = @[arr1,arr2,arr3,arr4];
//        NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:self.dataArray];
//        [tempArr removeObject:@"年龄段"];
//        
//        for (NSString *str in tempArr) {
//            NSInteger index = [tempArr indexOfObject:str];
//            [_dataDicWithValueArray setValue:sumArray[index] forKey:str];
//        }
//    }
//    return _dataDicWithValueArray;
//}
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
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"ModelPlateConditionsCell"];
    
    [self configCell:cell withIndexPath:indexPath];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 45;

    if (indexPath.row == 2) {
        height = 0;
    }
    
    return height;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedNode = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.selectedIndexPath = indexPath;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *cellLabelContent = (UILabel*)[cell viewWithTag:1002];

    if ([self.selectedNode.nodeName isEqualToString:@"年龄段"]) {
        [self performSegueWithIdentifier:@"conditionAgeSegue" sender:cellLabelContent];
    }else {
      [self performSegueWithIdentifier:@"conditionDetailSegue" sender:cellLabelContent];
    }
    
    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    UILabel *cellLabel = (UILabel*)[cell viewWithTag:1001];
//    UILabel *cellSelectedContentLabel = (UILabel*)[cell viewWithTag:1002];
//    self.selectedCellContentStr = cellSelectedContentLabel.text;
//    self.selectedCellStr = cellLabel.text;
//    
//
//    
//    if([cellLabel.text isEqualToString:@"年龄段"]){
//        [self performSegueWithIdentifier:@"conditionAgeSegue" sender:nil];
//    }else {
//        [self performSegueWithIdentifier:@"selecteConditionSegue" sender:nil];
//    }
    
}
-(void)configCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    UILabel *cellLabelClass = (UILabel*)[cell viewWithTag:1001];
    UILabel *cellLabelContent = (UILabel*)[cell viewWithTag:1002];
    
    if (indexPath.row == 2) {
        cell.hidden  = YES;
    }
    Node *node = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cellLabelClass.text = node.nodeName;
    cellLabelContent.text = [node.nodeContent isEqualToString:@""]?@"请选择":node.nodeContent;
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"conditionDetailSegue"]) {
    
        ModelPlateConditionDetailViewController *detailVC = (ModelPlateConditionDetailViewController*)(segue.destinationViewController);
        UIPopoverPresentationController *ppc =(UIPopoverPresentationController*) detailVC.popoverPresentationController;
        
        UILabel *label = (UILabel*)sender;

        CGRect popoverSourceRect = [self convertToPopoverSourceRectangeUseView:label];
        ppc.sourceRect = popoverSourceRect ;
        detailVC.selectedNode = self.selectedNode;
       // CGSize minimumSize = [detailVC.view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        detailVC.preferredContentSize = CGSizeMake(320, 45 * 2);
    }else if([segue.identifier isEqualToString:@"conditionAgeSegue"]){
        
      //  UINavigationController *nav  =(UINavigationController*)segue.destinationViewController;
       // AgePickerViewController *ageVC = (AgePickerViewController*)[nav.viewControllers firstObject];
        AgePickerViewController *ageVC = (AgePickerViewController*)segue.destinationViewController;
        self.ppc =(UIPopoverPresentationController*)ageVC.popoverPresentationController;
        self.ppc.delegate = self;
        UILabel *label = (UILabel*)sender;
        
        CGRect popoverSourceRect = [self convertToPopoverSourceRectangeUseView:label];
        self.ppc.sourceRect = popoverSourceRect;
        self.ppc.delegate = self;
      //  CGSize minimumSize = [ageVC.view systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
        ageVC.preferredContentSize = CGSizeMake(320, 320);
       // nav.preferredContentSize = CGSizeMake(320, minimumSize.height);

        

        ageVC.selectedLowNode = self.selectedNode;
        
        NSIndexPath *highAgeIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row+1 inSection:self.selectedIndexPath.section];
        ageVC.selectedHightNode =[self.fetchedResultsController objectAtIndexPath:highAgeIndexPath];
        

    }
//    if ([segue.identifier isEqualToString:@"selecteConditionSegue"]) {
//        ModelPlateConditionViewController *conditionVC = (ModelPlateConditionViewController*)segue.destinationViewController;
//        
//        if ([self.selectedCellStr isEqual:@"性别"]) {
//            conditionVC.dataSource = [self.dataDicWithValueArray objectForKey:self.selectedCellStr];
//            conditionVC.hideSearchBar = YES;
//            conditionVC.title = @"选择性别";
//        }else {
//          if ([self.selectedCellStr isEqualToString:@"入院诊断"]) {
//             conditionVC.loadURLStr = @"diseases";
//              conditionVC.title = self.selectedCellStr;
//          }else if([self.selectedCellStr isEqualToString:@"伴随症状"]){
//              conditionVC.subSymptom = @"sub_symptoms";
//              conditionVC.symptomName =  [self.dataDic objectForKey:@"主要症状"];
//              conditionVC.loadURLStr = @"symptoms";
//              conditionVC.hideSearchBar = YES;
//              conditionVC.title = self.selectedCellStr;
//
//          }else if([self.selectedCellStr isEqualToString:@"主要症状"]){
//            conditionVC.loadURLStr = @"symptoms";
//              conditionVC.title = self.selectedCellStr;
//
//          }
//        }
//
//        conditionVC.conditionDelegate = self;
//    }else  if ([segue.identifier isEqualToString:@"conditionAgeSegue"]){
//        AgePickerViewController *ageVC = (AgePickerViewController*)segue.destinationViewController;
//        ageVC.ageDelegate = self;
//        ageVC.title = @"选择年龄";
//        if([self.selectedCellContentStr isEqualToString:@"请选择"]){
//            self.selectedCellContentStr = @"0岁 - 0岁";
//        }
//        ageVC.defaultString = self.selectedCellContentStr;
//    } else if([segue.identifier isEqualToString:@"unwindToCreateTemplateVC"]){
//        CreateTemplateViewController *createVC =(CreateTemplateViewController*) segue.destinationViewController;
//        createVC.conditionLabelStr = self.selectedConditionResultStr.text != nil ? self.selectedConditionResultStr.text : @"I am default";
//        createVC.conditionDicData = [[NSMutableDictionary alloc] initWithDictionary:self.dataDic];
//    }
}

/// fetch result controller delegate
-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}
-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:{
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeDelete:{
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeUpdate:{
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [self configCell:cell withIndexPath:indexPath];
            break;
        }
            
        default:
            break;
    }
}
-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionIndex];
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
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
#pragma mask -presentation view controller delegate
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationOverFullScreen;
}
-(UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style
{
    return [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
}
#pragma mask - helper
-(CGRect) convertToPopoverSourceRectangeUseView:(UIView*)view
{
    CGRect frame = view.frame;
    CGRect labelCenterFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    CGRect popoverSourceRect = [view convertRect:labelCenterFrame toView:self.tableView];
    popoverSourceRect.origin.x -= frame.size.width/2+view. center.x/2+50 ;
    popoverSourceRect.origin.y -= frame.size.height/2;

    return popoverSourceRect;
}
#pragma mask - unwind
///other conditions segue
- (IBAction)unwindSegueFromConditionVCToConditionsVC:(UIStoryboardSegue *)segue{
    
    
    
}

///age unwind segue
- (IBAction)unwindSegueAgeCancelVCFromConditionVCToConditionsVC:(UIStoryboardSegue *)segue {
    
    
    
}

@end
