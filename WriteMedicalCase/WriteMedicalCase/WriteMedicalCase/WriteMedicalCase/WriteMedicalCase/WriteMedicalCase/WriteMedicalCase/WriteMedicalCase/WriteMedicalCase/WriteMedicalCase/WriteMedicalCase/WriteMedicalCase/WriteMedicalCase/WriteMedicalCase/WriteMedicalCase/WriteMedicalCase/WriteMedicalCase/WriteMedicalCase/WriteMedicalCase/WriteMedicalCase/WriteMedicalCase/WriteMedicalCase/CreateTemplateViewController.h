//
//  ViewController.h
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/1.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol CreateTemplateViewController
//
//-(void)getCreateTemplateData:(NSDictionary*)dataDic;
//
//@end

@interface CreateTemplateViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *conditionLabel;
//@property (weak, nonatomic) id <CreateTemplateViewController> createTemplateDelegate;
@property (nonatomic,strong) NSString *conditionLabelStr;
@property (nonatomic,strong) NSString *contentStr;
@property (nonatomic,strong) NSMutableDictionary *conditionDicData;
@end

