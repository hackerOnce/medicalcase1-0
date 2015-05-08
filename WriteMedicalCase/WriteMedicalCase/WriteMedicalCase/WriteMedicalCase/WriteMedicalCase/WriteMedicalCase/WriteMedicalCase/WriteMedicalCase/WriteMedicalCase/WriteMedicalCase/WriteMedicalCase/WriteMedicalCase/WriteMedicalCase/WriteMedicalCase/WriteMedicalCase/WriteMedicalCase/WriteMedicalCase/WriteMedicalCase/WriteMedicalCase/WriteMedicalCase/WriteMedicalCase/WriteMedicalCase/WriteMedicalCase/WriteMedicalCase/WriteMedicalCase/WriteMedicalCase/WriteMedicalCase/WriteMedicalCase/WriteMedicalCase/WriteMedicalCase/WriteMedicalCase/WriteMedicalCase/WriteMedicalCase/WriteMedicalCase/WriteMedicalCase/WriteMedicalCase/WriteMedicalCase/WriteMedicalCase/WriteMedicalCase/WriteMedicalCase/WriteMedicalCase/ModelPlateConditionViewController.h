//
//  ModelPlateConditionViewController.h
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/2.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ModelPlateConditionViewControllerDelegate <NSObject>

-(void)didSelectedStr:(NSString*)str;

@end
@interface ModelPlateConditionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) BOOL hideSearchBar;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSString *loadURLStr;
@property (nonatomic,strong) NSString *symptomName;
@property (nonatomic,strong) NSString *subSymptom;
@property (nonatomic,weak) id <ModelPlateConditionViewControllerDelegate> conditionDelegate;
@end
