//
//  RecordManagedViewController.h
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/23.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordManagedViewController : UIViewController

@property(nonatomic, strong) NSMutableArray* headViewArray;

@property (nonatomic) NSInteger currentSection;
@property (nonatomic) NSInteger currentRow;

@end
