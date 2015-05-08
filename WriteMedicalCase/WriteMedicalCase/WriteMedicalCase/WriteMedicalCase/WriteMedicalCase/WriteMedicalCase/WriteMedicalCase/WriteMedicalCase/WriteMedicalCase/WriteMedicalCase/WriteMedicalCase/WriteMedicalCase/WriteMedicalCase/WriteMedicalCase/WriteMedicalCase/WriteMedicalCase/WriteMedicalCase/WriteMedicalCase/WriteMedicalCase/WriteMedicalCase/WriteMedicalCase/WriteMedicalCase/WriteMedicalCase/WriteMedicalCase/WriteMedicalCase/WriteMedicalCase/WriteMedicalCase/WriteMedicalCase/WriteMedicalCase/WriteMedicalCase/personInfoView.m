//
//  personInfoView.m
//  MedicalCase
//
//  Created by GK on 15/4/28.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "personInfoView.h"
@interface personInfoView()
@property (nonatomic,strong) NSMutableArray *labelArray;
@property (nonatomic,strong) UIView *secondView;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) NSLayoutConstraint *heightConstraint;

@property (nonatomic,strong) NSMutableArray *dataArray;
@end
@implementation personInfoView

-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
    if (self) {
        [self addSubViewToCurrentView];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
   self =  [super initWithFrame:frame];
    
    if (self) {
        [self addSubViewToCurrentView];
    }
    return self;
}
-(void)setIsHideSubView:(BOOL)isHideSubView
{
    _isHideSubView = isHideSubView;
    
    
    if (!_isHideSubView) {
        CGFloat subHeight = self.frame.size.height;
        self.heightConstraint.constant = subHeight*3+16;
        [UIView animateWithDuration:0.5 animations:^{
            
            [self needsUpdateConstraints];
            [self.secondView setHidden:NO];
            
        }];
    }else {
        CGFloat subHeight1 = (self.frame.size.height-16)/3.0 ;
        
        self.heightConstraint.constant = subHeight1;
        [UIView animateWithDuration:0.5 animations:^{
            [self needsUpdateConstraints];
            [self.secondView setHidden:YES];
        }];
        
    }


}
-(NSMutableArray *)labelArray
{
    if (!_labelArray) {
        _labelArray = [[NSMutableArray alloc] init];
    }
    return _labelArray;
}
//-(NSMutableArray *)dataArray
//{
//    if (!_dataArray) {
////        _dataArray = @[@"马云",@"性别: 男",@"年龄: 55",@"科室: 新年恩克",@"住院号: 09999",@"床好: 98",@"mm",@"性别: 男",@"年龄: 55",@"科室: 新年恩克",@"住院号: 09999",@"床好: 98",@"mm",@"科室: 新年恩克",@"住院号: 09999",@"床好: 98",@"性别: 男",@"性别: 男"];
//        _dataArray = [[NSMutableArray alloc] init];
//    }
//    return _dataArray;
//}
-(void)setTempPatient:(TempPatient *)tempPatient
{
    _tempPatient = tempPatient;
    
    self.dataArray = [[NSMutableArray alloc] init];
    
    NSString *nameStr = tempPatient.pName?tempPatient.pName:@"王天扎";
    NSString *genderStr = [NSString stringWithFormat:@"性别: %@",tempPatient.pGender?tempPatient.pGender:@"男"];
    
    NSString *ageStr = [NSString stringWithFormat:@"年龄: %@",tempPatient.pAge?tempPatient.pAge:@"24"];
    
    NSString *administrative = [NSString stringWithFormat:@"科室: %@",tempPatient.pDept?tempPatient.pDept:@"心内科"];
    NSString *pID = [NSString stringWithFormat:@"住院号: %@",tempPatient.pID?tempPatient.pID:@"078899"];
    NSString *pBedNum = [NSString stringWithFormat:@"床号: %@",tempPatient.pBedNum?tempPatient.pBedNum:@"098"];

    NSString *pNULL1 = @" ";

    
    NSString *pNation = [NSString stringWithFormat:@"民族: %@",tempPatient.pNation?tempPatient.pNation:@"汉"];
    NSString *pProfession = [NSString stringWithFormat:@"职业: %@",tempPatient.pProfession?tempPatient.pProfession:@"法律"];
    NSString *presenter = [NSString stringWithFormat:@"病史陈述者: %@",tempPatient.presenter?tempPatient.presenter:@"本人"];
    NSString *pAdmissionTime = [NSString stringWithFormat:@"入院时间: %@",tempPatient.pAdmissionTime?tempPatient.pAdmissionTime:@"2015-08-09"]; //年月日
    NSString *pAdmissionTimeSub = tempPatient.pSubAdmissionTime?tempPatient.pSubAdmissionTime:@"上午 09:00:00";//时分秒
    
    NSString *pNULL2 = @" ";
    NSString *pMaritalStatus = [NSString stringWithFormat:@"婚姻: %@",tempPatient.pMaritalStatus?tempPatient.pMaritalStatus:@"未婚"];
    NSString *pProvince = [NSString stringWithFormat:@"籍贯: %@",tempPatient.pProvince?tempPatient.pProvince:@"上海"];
    NSString *pDetailAddress = [NSString stringWithFormat:@"现居地: %@",tempPatient.pDetailAddress?tempPatient.pDetailAddress:@"上海市闸北区彭江路602号"];
    NSDate *date = [NSDate date];
    NSString *pRecordTime = [self getYearAndMonthWithDateStr:date];
    NSString *pSubRecordTime = [self getHourAndMinutesWithDateStr:date];
    
    [self.dataArray addObject: nameStr];
    [self.dataArray addObject: genderStr];
    [self.dataArray addObject: ageStr];
    [self.dataArray addObject: administrative];
    [self.dataArray addObject: pID];
    [self.dataArray addObject: pBedNum];
    [self.dataArray addObject: pNULL1];
    
    [self.dataArray addObject: pNation];
    [self.dataArray addObject: pProfession];
    [self.dataArray addObject: presenter];
    [self.dataArray addObject: pAdmissionTime];
    [self.dataArray addObject: pAdmissionTimeSub];
    [self.dataArray addObject: pNULL2];

    [self.dataArray addObject: pMaritalStatus];
    [self.dataArray addObject: pProvince];
    [self.dataArray addObject: pDetailAddress];
    [self.dataArray addObject: pRecordTime];
    [self.dataArray addObject: pSubRecordTime];
    
    [self setNeedsLayout];
  //  [self layoutSubviews];
}
-(NSString*)getYearAndMonthWithDateStr:(NSDate*)date
{
    NSString *dateStr = @"记录日期: ";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    dateStr = [dateStr stringByAppendingString:[formatter stringFromDate:date]];
    
    NSLog(@"date : %@",dateStr);
    return dateStr;
}
-(NSString*)getHourAndMinutesWithDateStr:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    
    NSString *str = @"";

    NSString *dateStr = [formatter stringFromDate:date];
    
    NSLog(@"date : %@",dateStr);
    
    NSMutableArray *tempA = [[NSMutableArray alloc] initWithArray:[dateStr componentsSeparatedByString:@":"]];

    if ([tempA[0] integerValue] > 12) {
        
        NSString *tempStr = @"下午 ";
        tempA[0] = [NSString stringWithFormat:@"%@",@([tempA[0] integerValue] - 12)];
        
        str = [tempA componentsJoinedByString:@":"];
        str = [tempStr stringByAppendingString:str];
        
    }else {
        NSString *tempStr = @"上午 ";
        str = [tempStr stringByAppendingString:dateStr];
    }
    return str;
}

-(void)addSubViewToCurrentView
{
    
    //self.isHideSubView = YES;
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            
            if (constraint.relation == NSLayoutRelationEqual) {
                self.heightConstraint = constraint;
            }
        }
    }
    self.backgroundColor =[UIColor whiteColor];
    CGFloat subWidth = self.frame.size.width/6.0;
    CGFloat subHeight = (self.frame.size.height-16)/2.0;
    
    for (int i=0; i<6; i++){
        UILabel  *label = [[UILabel alloc] init];
        label.frame = CGRectMake(i*subWidth, 8, subWidth, 29);
        label.textAlignment = NSTextAlignmentLeft;
        [self.labelArray addObject:label];
        label.textColor  =[UIColor darkGrayColor];
        label.backgroundColor = [self randomColor];
        [self addSubview:label];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  //  button.backgroundColor = [UIColor darkGrayColor];
    button.frame =CGRectMake(0, 0, self.frame.size.width, subHeight);
    [self addSubview:button];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.button = button;

    if (!self.isHideSubView) {
        UIView *secondView = [[UIView alloc] initWithFrame:CGRectMake(0,subHeight+8 , self.frame.size.width, 2 * subHeight)];
        // secondView.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:secondView];
        self.secondView = secondView;
        
        for (int i=0; i<12; i++){
            UILabel  *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentLeft;
            label.backgroundColor = [self randomColor];
            label.textColor  =[UIColor darkGrayColor];

            if (i < 6) {
                label.frame = CGRectMake(i*subWidth, 0, subWidth, 29);
            }else {
                label.frame = CGRectMake((i-6)*subWidth,subHeight, subWidth, 29);
            }
            [self.labelArray addObject:label];
            [secondView addSubview:label];
        }
 
    }
}
-(void)addLabelText
{
    for (UILabel *label in self.labelArray) {
       NSInteger labelIndex = [self.labelArray indexOfObject:label];
        
        label.text = self.dataArray[labelIndex];
    }
}
-(void)buttonClicked:(UIButton*)sender
{
    self.isHideSubView = !self.isHideSubView;
    
    if (!self.isHideSubView) {
        CGFloat subHeight = self.frame.size.height;
        self.heightConstraint.constant = subHeight*3+16;
        [UIView animateWithDuration:0.5 animations:^{
            
            [self needsUpdateConstraints];
            [self.secondView setHidden:NO];

        }];
    }else {
        CGFloat subHeight1 = (self.frame.size.height-16)/3.0 ;
        
        self.heightConstraint.constant = subHeight1;
        [UIView animateWithDuration:0.5 animations:^{
            [self needsUpdateConstraints];
            [self.secondView setHidden:YES];
        }];

    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
   // CGFloat firstWWidth = self.frame.size.width/10;
    CGFloat firstWWidth = self.frame.size.width/8.0;

    CGFloat subWidth = (self.frame.size.width-16-firstWWidth)/5.0;

    CGFloat subHeight1 = (self.frame.size.height-16)/3.0 ;
    CGFloat subHeight = (subHeight1-29)/2 + subHeight1;
    
    self.secondView.frame = CGRectMake(0, subHeight, self.frame.size.width, 2 * subHeight);
    if (self.isHideSubView) {
        self.button.frame =CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }else {
        self.button.frame =CGRectMake(0, 0, self.frame.size.width, subHeight);
    }
    for (UILabel *label in self.labelArray) {
        NSInteger index = [self.labelArray indexOfObject:label];
        if (index < 6) {
            if (index == 0) {
                label.frame = CGRectMake(index*subWidth + 8, 8, firstWWidth, 29);
            }else {
               label.frame = CGRectMake(index*subWidth + 8, 8, subWidth, 29);
            }
        }else if (index < 12) {
            if (index == 6) {
                label.frame = CGRectMake((index-6)*subWidth+8, 8, firstWWidth, 29);
            }else {
                label.frame = CGRectMake((index-6)*subWidth+8, 8, subWidth, 29);
            }

        }else {
            if (index == 12) {
                label.frame = CGRectMake((index-12)*subWidth+8, 8+subHeight, firstWWidth, 29);
            }else {
                label.frame = CGRectMake((index-12)*subWidth+8, 8+subHeight, subWidth, 29);
 
            }

        }
        
    }
    
    [self addLabelText];

}

-(UIColor*)randomColor
{
    NSArray *colorArray =  @[[UIColor blackColor],[UIColor redColor],[UIColor yellowColor],[UIColor grayColor],[UIColor greenColor],[UIColor orangeColor]];
    
    NSInteger i = arc4random() % 6;
    
   // return (UIColor*)colorArray[i];
    return [UIColor whiteColor];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
