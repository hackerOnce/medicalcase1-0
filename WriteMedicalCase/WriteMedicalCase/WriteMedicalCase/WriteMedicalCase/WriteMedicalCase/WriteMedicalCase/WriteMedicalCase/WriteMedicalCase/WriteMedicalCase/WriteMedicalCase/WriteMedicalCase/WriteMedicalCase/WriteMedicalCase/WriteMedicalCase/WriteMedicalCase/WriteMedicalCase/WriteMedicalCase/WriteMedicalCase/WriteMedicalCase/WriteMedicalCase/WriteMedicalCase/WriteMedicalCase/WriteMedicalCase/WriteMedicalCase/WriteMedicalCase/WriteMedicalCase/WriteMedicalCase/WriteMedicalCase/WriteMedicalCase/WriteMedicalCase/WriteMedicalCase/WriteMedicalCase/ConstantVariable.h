//
//  ConstantVariable.h
//  MedCase
//
//  Created by ihefe-JF on 15/1/22.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#ifndef MedCase_ConstantVariable_h
#define MedCase_ConstantVariable_h

static NSString *kInputTextCompleted = @"kInputTextCompleted"; //for input text view view controller
static CGFloat rightSideSlideViewWidth = 400;
static NSString *didSelectedRowNotificationName = @"DidSelectedRowNotificationName";

#define nShouldReloadNodeTableView @"nShouldReloadNodeTableView" //节点列表更新tableview，选中某一cell后发出

// core data table names
static const NSString *personTable =  @"Person";
static const NSString *medicalCaseTable = @"MedicalCase";
static const NSString *modelCaseTable = @"ModelCase";


#endif
