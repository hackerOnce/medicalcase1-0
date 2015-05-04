//
//  WriteCaseEditViewController.m
//  WriteMedicalCase
//
//  Created by GK on 15/4/29.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "WriteCaseEditViewController.h"
#import "personInfoView.h"
#import "AutoHeightTextView.h"
#import "RawDataProcess.h"
#import "WriteCaseShowTemplateViewController.h"

@interface WriteCaseEditViewController ()<UITableViewDelegate,UITableViewDataSource,WriteCaseShowTemplateViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet AutoHeightTextView *autoHeightTextView;

@property (weak, nonatomic) IBOutlet personInfoView *personInfoView;
@property (weak, nonatomic) IBOutlet WLKMultiTableView *multiTableView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *navButton;

@property (nonatomic,strong) WLKCaseNode *sourceNode;

@property (nonatomic,strong) id multiTablesObsevToken;

@property (nonatomic,strong) NSArray *nodeChildArray;
@property (nonatomic,strong) NSMutableDictionary *nodeChildDic;

@property (nonatomic,strong) WLKCaseNode *selectedNode;

@property (nonatomic) BOOL saveAsTemplate;

@property (nonatomic,strong) NSString *templateNameStr;

@end

@implementation WriteCaseEditViewController

- (IBAction)leftUpButton:(UIButton *)sender
{
    UILabel *label = (UILabel*)[self.view viewWithTag:10001];
    
    if (self.rightSlideViewFlag) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectedTitleLabel" object:label.text];
    }else {
        self.templateNameStr = label.text;
        [self performSegueWithIdentifier:@"customSegue" sender:nil];
    }
}
- (IBAction)cancelButton:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)backToPrev:(UIButton *)sender {
    
    if (self.saveAsTemplate) {
        //存储为模板
    }
    [self.Editdelegate didWriteStringToMedicalRecord:self.autoHeightTextView.text withKeyStr:self.labelString];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(NSArray *)nodeChildArray
{
    if (!_nodeChildArray) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (WLKCaseNode *tempNode in self.sourceNode.childNodes) {
            if (tempNode.nodeName) {
                [tempArray addObject:tempNode.nodeName];
            }
        }
        _nodeChildArray = [NSArray arrayWithArray:tempArray];
    }
    return _nodeChildArray;
}
#pragma mask - property
-(UIView *)rightSideSlideView
{
    if(!_rightSideSlideView){
        _rightSideSlideView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame),0,rightSideSlideViewWidth , CGRectGetHeight(self.view.frame) - 0 - 45)];
        _rightSideSlideView.backgroundColor = [UIColor yellowColor];
        
        UISwipeGestureRecognizer *recoginizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideRightSildeView:)];
        recoginizer.direction = UISwipeGestureRecognizerDirectionRight;
        
        [_rightSideSlideView addGestureRecognizer:recoginizer];
        
        // [self.view addSubview:_rightSideSlideView];
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        [keyWindow addSubview:self.rightSideSlideView];
        
        self.rightSlideViewFlag = YES;
    }
    
    return _rightSideSlideView;
}
-(void)hideRightSildeView:(UISwipeGestureRecognizer *)swipGesture
{
    
    CGRect tempRect = self.rightSideSlideView.frame;
    tempRect.origin.x += rightSideSlideViewWidth - 10;
    [UIView animateWithDuration:0.4 animations:^{
        self.rightSideSlideView.frame = tempRect;
        //[self performSegueWithIdentifier:@"MedicalCaseModel" sender:nil];
    } completion:^(BOOL finished) {
        [self performSegueWithIdentifier:@"customSegue" sender:nil];
        //self.modelVC = nil;
        //        [self.rightSideSlideView removeFromSuperview];
        //        self.rightSideSlideView = nil;
    }];
    
}
-(void)addSideButttonToWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"按钮" forState:UIControlStateNormal];
    CGRect frame = CGRectMake(keyWindow.frame.size.width - 60, CGRectGetMidY(keyWindow.frame), 60, 60);
    [button addTarget:self action:@selector(sideButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = frame;
    button.tag = 20001;
    [keyWindow addSubview:button];
}
-(void)sideButtonClicked:(UIButton*)sender
{
    self.templateNameStr = self.selectedNode.nodeName;
    if (!self.templateNameStr) {
        self.templateNameStr = self.labelString;
    }
    [self performSegueWithIdentifier:@"customSegue" sender:nil];
}

#pragma mask - setUp multiTableView
-(void)setUpMultiTableView:(NSString*)nodeName
{
    self.multiTableView.caseNode = [self getSelectedNodeWithNodeName:nodeName];
    [self.multiTableView buildUI];
    
}
-(WLKCaseNode*)getSelectedNodeWithNodeName:(NSString*)nodeName
{
    RawDataProcess *rawData = [RawDataProcess sharedRawData];
    WLKCaseNode *node = [WLKCaseNode getSubNodeFromNode:rawData.rootNode withNodeName:nodeName resultNode:nil];
    
    return node;
}

-(void)setLabelString:(NSString *)labelString
{
    _labelString = labelString;
    self.templateNameStr = _labelString;
    RawDataProcess *rawData = [RawDataProcess sharedRawData];
    self.sourceNode = [WLKCaseNode getSubNodeFromNode:rawData.rootNode withNodeName:_labelString resultNode:nil];
    
}
-(void)setMultiTableView:(WLKMultiTableView *)multiTableView
{
    _multiTableView = multiTableView;
    
    self.multiTablesObsevToken = [KeyValueObserver observeObject:self.multiTableView keyPath:@"selectedStr" target:self selector:@selector(selectedTextDidChange:) options:NSKeyValueObservingOptionInitial];
}
-(NSMutableDictionary *)nodeChildDic
{
    if (!_nodeChildDic) {
        _nodeChildDic = [[NSMutableDictionary alloc] init];
        for (int i=0; i< self.sourceNode.childNodes.count; i++) {
            NSString *tempStr = [self.nodeChildArray objectAtIndex:i];
            if (tempStr) {
                [_nodeChildDic setObject:@" " forKey:tempStr];
            }
        }
    }
    return _nodeChildDic;
}

-(void)selectedTextDidChange:(NSDictionary*)change
{
    
    if (self.rightSlideViewFlag) {
        [self performSegueWithIdentifier:@"customSegue" sender:nil];

    }
    if (self.multiTableView.selectedStr) {
        [self.nodeChildDic setObject:self.multiTableView.selectedStr forKey:self.multiTableView.caseNode.nodeName];
        
        NSString *nodeName = self.multiTableView.caseNode.nodeName;
        NSString *t = [NSString stringWithFormat:@"%@: ",nodeName];
        NSString *nodeST = [t stringByAppendingString: self.multiTableView.selectedStr];
        
        if ([self.nodeChildDic.allKeys containsObject:nodeName]) {
            [self.nodeChildDic setObject:nodeST forKey:nodeName];
        }
        
        self.autoHeightTextView.text = @"";
        NSString *tempString = @"";
        for (NSString *temp in self.nodeChildArray) {
            NSString *tempSt = self.nodeChildDic[temp];
            if (![tempSt isEqualToString:@""]) {
                //  NSString *returnStr = [tempSt stringByAppendingString:@"\n"];
                tempString = [tempString stringByAppendingString:tempSt];
            }
        }
        self.autoHeightTextView.text = tempString;
        
    }
    //self.selectedText.text = self.multiTables.selectedStr;
    
}

- (IBAction)saveToTemplate:(UIButton *)sender {
    
    UIButton *button = (UIButton*)sender;

    self.saveAsTemplate = !self.saveAsTemplate;
    if (self.saveAsTemplate) {
        button.backgroundColor = [UIColor redColor];
    }else {
        button.backgroundColor = [UIColor whiteColor];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.personInfoView.isHideSubView = YES;
    self.autoHeightTextView.text = nil;
    self.title = self.labelString;
    [self setUpTableView];
    
    self.navButton.layer.cornerRadius = self.navButton.frame.size.width/2;
    self.navButton.backgroundColor = [UIColor whiteColor];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.titleLabel.text = self.labelString;
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    id windowView = [keyWindow viewWithTag:20001];
    if (windowView) {
        
    }else {
        [self addSideButttonToWindow];
    }
    [self performSegueWithIdentifier:@"customSegue" sender:nil];

    if (![self.textViewContent isEqualToString:@" "]) {
        self.autoHeightTextView.text = self.textViewContent;
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    id windowView = [keyWindow viewWithTag:20001];
    
    if ([windowView isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)windowView;
        [button removeFromSuperview];
    }
    if (self.rightSlideViewFlag) {
        [self performSegueWithIdentifier:@"customSegue" sender:nil];
    }
}
-(void)setUpTableView
{
    self.tableView.layer.shadowColor = [[UIColor grayColor] CGColor];
    self.tableView.layer.shadowOffset = CGSizeMake(2.0f, -2.0f);
    self.tableView.layer.shadowOpacity = 0.5f;
    self.tableView.layer.shadowRadius = 2.0f;
    ;
    self.multiTableView.layer.borderWidth = 1;
    self.tableView.layer.borderWidth  = 1;
}
#pragma mask - table view delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sourceNode.childNodes.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"navagationCell"];
    UILabel *cellLabel =(UILabel*) [cell viewWithTag:1001];
    WLKCaseNode *tempNode = [self.sourceNode.childNodes objectAtIndex:indexPath.row];
    cellLabel.text = tempNode.nodeName;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedNode = [self.sourceNode.childNodes objectAtIndex:indexPath.row];
    [self setUpMultiTableView:self.selectedNode.nodeName];
    //[self performSegueWithIdentifier:@"customSegue" sender:nil];

    if (self.rightSlideViewFlag) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectedTitleLabel" object:self.selectedNode.nodeName];
    }
}

///did selected template
-(void)didSelectedTemplateWithNode:(Template *)templated withTitleStr:(NSString *)titleStr
{
    
    NSString *nodeName = titleStr;
    NSString *nodesString = templated.content;
    
    if ([nodeName isEqualToString:self.labelString]) {
        self.autoHeightTextView.text = nodesString;
    }else {
        NSString *t = [NSString stringWithFormat:@"%@: ",nodeName];
        NSString *nodeST = [t stringByAppendingString: nodesString];
        
        if ([self.nodeChildDic.allKeys containsObject:nodeName]) {
            [self.nodeChildDic setObject:nodeST forKey:nodeName];
        }
        
        self.autoHeightTextView.text = @"";
        NSString *tempString = @"";
        for (NSString *temp in self.nodeChildArray) {
            NSString *tempSt = self.nodeChildDic[temp];
            if (![tempSt isEqualToString:@""]) {
                tempString = [tempString stringByAppendingString:tempSt];
            }
        }
        self.autoHeightTextView.text = tempString;
    }
    self.rightSlideViewFlag = NO;
    [self performSegueWithIdentifier:@"customSegue" sender:nil];
    
}
-(void)didSelectedTemplateWithString:(NSString *)str
{
    self.autoHeightTextView.text = str;
    [self performSegueWithIdentifier:@"customSegue" sender:nil];

}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"customSegue"]) {
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        WriteCaseShowTemplateViewController *showTemplateVC = (WriteCaseShowTemplateViewController*)[nav.viewControllers firstObject];
        showTemplateVC.templateName = self.templateNameStr;
        showTemplateVC.showTemplateDelegate = self;
    }
}

@end
