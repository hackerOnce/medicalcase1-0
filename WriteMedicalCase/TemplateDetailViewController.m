//
//  TemplateDetailViewController.m
//  WriteMedicalCase
//
//  Created by GK on 15/5/1.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "TemplateDetailViewController.h"
#import "RWLabel.h"

@interface TemplateDetailViewController ()
@property (weak, nonatomic) IBOutlet RWLabel *createPeopleLabel;
@property (weak, nonatomic) IBOutlet RWLabel *sourceLabel;
@property (weak, nonatomic) IBOutlet RWLabel *conditionLabel;
@property (weak, nonatomic) IBOutlet RWLabel *contentLabel;

@end

@implementation TemplateDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.createPeopleLabel.text = self.templateModel.createPeople;
    self.sourceLabel.text = self.templateModel.sourceType;
    self.conditionLabel.text = self.templateModel.condition;
    self.contentLabel.text  = self.templateModel.content;
}
@end
