//
//  HUDSubViewController.m
//  MedCase
//
//  Created by ihefe-JF on 15/1/14.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "HUDSubViewController.h"
#import "WLKMultiTableView.h"
#import <QuartzCore/QuartzCore.h>
#import "KeyValueObserver.h"
#import "ConstantVariable.h"
#import "CreateTemplateViewController.h"
//#import "CKHttpClient.h"
#import "WLKCaseNode.h"

@interface HUDSubViewController ()

@property (nonatomic,strong) id multiTablesObsevToken;

@property (nonatomic,strong) NSString *originText;
@end

@implementation HUDSubViewController
-(void)setProgectName:(NSString *)progectName
{
    _progectName = progectName;

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    ;
    [tempDic setObject:_progectName forKey:@"nodeName"];
    NSData *json = [NSJSONSerialization dataWithJSONObject:tempDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    [dic setObject:jsonStr forKey:@"where"];
    

}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedText.text = _multiTables.caseNode.nodeContent;
}

-(void)setIsInContainerView:(BOOL)isInContainerView
{
    _isInContainerView = isInContainerView;
    
    [self addContainerViewObserver];

}
-(void)addContainerViewObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedCellLabel:) name:@"containerToSub" object:nil];
}
-(void)didSelectedCellLabel:(NSNotification *)info
{
    id tempID = [info object];
    
    if ([tempID isKindOfClass:[WLKCaseNode class]]) {
        if ([self.selectedText.text isEqualToString:self.originText]) {
            
        }else {
            if (self.selectedText.text != nil ) {
                [self.subDelegate didSelectedNodesString:self.selectedText.text withParentNodeName:self.detailCaseNode.nodeName];
            }
        }
        self.detailCaseNode = (WLKCaseNode*)[info object];
        _multiTables.caseNode = self.detailCaseNode;
        [_multiTables buildUI];
        
        self.originText = self.selectedText.text;
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _multiTables.caseNode = self.detailCaseNode;
    
}

-(void)setMultiTables:(WLKMultiTableView *)multiTables
{
    _multiTables = multiTables;
    self.multiTablesObsevToken = [KeyValueObserver observeObject:self.multiTables keyPath:@"selectedStr" target:self selector:@selector(selectedTextDidChange:) options:NSKeyValueObservingOptionInitial];
   
}
-(void)selectedTextDidChange:(NSDictionary*)change
{
    self.selectedText.text = self.multiTables.selectedStr;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if([self.selectedText.text isEqualToString:self.multiTables.caseNode.nodeName]){
        return;
    }
    if([self.selectedText.text isEqualToString:@""]){
        self.selectedText.text = self.detailCaseNode.nodeName;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kInputTextCompleted object:self.selectedText.text];
    
   
}
-(void)dealloc
{
    if (self.isInContainerView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"unwindToCreateVC"]){
        CreateTemplateViewController *createVC =(CreateTemplateViewController*) segue.destinationViewController;
        createVC.contentStr = self.selectedText.text != nil ? self.selectedText.text : @"I am default";
    }
}


@end
