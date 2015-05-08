//
//  HUDSubViewController.h
//  MedCase
//
//  Created by ihefe-JF on 15/1/14.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLKCaseNode.h"
#import "WLKMultiTableView.h"

@protocol HUDSubViewControllerDelegate <NSObject>

-(void)didSelectedNodesString:(NSString*)nodesString withParentNodeName:(NSString*)nodeName;
@end

@interface HUDSubViewController : UIViewController

@property (nonatomic,strong) WLKCaseNode *detailCaseNode;
@property (weak, nonatomic) IBOutlet UILabel *selectedText;
@property (strong, nonatomic) IBOutlet WLKMultiTableView *multiTables;
@property (nonatomic,strong) NSString *progectName;

@property (nonatomic,weak) id <HUDSubViewControllerDelegate> subDelegate;
@property (nonatomic) BOOL isInContainerView;
@end
