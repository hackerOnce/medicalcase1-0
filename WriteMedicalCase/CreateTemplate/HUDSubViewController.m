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
@property (weak, nonatomic) IBOutlet UIView *labelView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *refreshView;
@property (nonatomic,strong) NSString *originText;
@end

@implementation HUDSubViewController
- (IBAction)clearLabel:(UIButton *)sender
{
    //清空 text
    [_multiTables.caseNode clearSelected];
    self.selectedText.text = @"";
}
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
    
//    [[CKHttpClient getInstance] GET:@"knowledgebase" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if ([responseObject isKindOfClass:[NSDictionary class]]) {
//            
//            NSArray *tempA = (NSArray*)responseObject[@"_items"];
//            NSDictionary *dic = (NSDictionary*)[tempA firstObject];
//            
//            WLKCaseNode *node = [WLKCaseNode nodeWithDictionary:dic];
//            self.detailCaseNode = node;
//            [self.refreshView stopAnimating];
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self.refreshView stopAnimating];
//    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSelectedTextLabel];
    
    self.selectedText.text = _multiTables.caseNode.nodeContent;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.isInContainerView) {
        [self.refreshView startAnimating];

    }
   // [self performSegueWithIdentifier:@"testSegue" sender:nil];
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
//    [self.multiTables buildUI];
    
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
-(void)configSelectedTextLabel
{
    _labelView.backgroundColor = [UIColor clearColor];
    _labelView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    _labelView.layer.cornerRadius = 10;
    _labelView.layer.borderColor = [UIColor blackColor].CGColor;
    _labelView.layer.borderWidth = 0.5;
    
    _labelView.layer.shadowColor = [UIColor blackColor].CGColor;
    _labelView.layer.shadowOpacity = 0.4;
    _labelView.layer.shadowRadius = 5.0;
    _labelView.layer.shadowOffset = CGSizeMake(0, 3);
    
    _labelView.clipsToBounds = YES;
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"unwindToCreateVC"]){
        CreateTemplateViewController *createVC =(CreateTemplateViewController*) segue.destinationViewController;
        createVC.contentStr = self.selectedText.text != nil ? self.selectedText.text : @"I am default";
       // createVC.conditionDicData = [[NSMutableDictionary alloc] initWithDictionary:self.dataDic];
    }
}


@end
