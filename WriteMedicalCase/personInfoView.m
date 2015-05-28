//
//  personInfoView.m
//  MedicalCase
//
//  Created by GK on 15/4/28.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "personInfoView.h"
#import "Patient.h"

@interface personInfoView()
@property (nonatomic,strong) NSMutableArray *labelArray;
@property (nonatomic,strong) UIView *secondView;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) NSLayoutConstraint *heightConstraint;

@property (nonatomic,strong) NSMutableArray *dataArray;

@property (nonatomic,strong) IHMsgSocket *socket;


@property (nonatomic,strong) CoreDataStack *coreDataStack;

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
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
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

-(void)setPatient:(Patient *)patient
{
    _patient = patient;
    NSString *nameStr = self.patient.pName?self.patient.pName:@" ";
    NSString *genderStr = [NSString stringWithFormat:@"性别: %@",self.patient.pGender?self.patient.pGender:@" "];
    
    NSString *ageStr = [NSString stringWithFormat:@"年龄: %@",self.patient.pAge?self.patient.pAge:@" "];
    
    NSString *administrative = [NSString stringWithFormat:@"科室: %@",self.patient.pDept?self.patient.pDept:@" "];
    NSString *pID = [NSString stringWithFormat:@"住院号: %@",self.patient.pID?self.patient.pID:@" "];
    NSString *pBedNum = [NSString stringWithFormat:@"床号: %@",self.patient.pBedNum?self.patient.pBedNum:@" "];
    
    NSString *pNation = [NSString stringWithFormat:@"民族: %@",self.patient.pNation?self.patient.pNation:@" "];
    NSString *pProfession = [NSString stringWithFormat:@"职业: %@",self.patient.pProfession?self.patient.pProfession:@" "];
    NSString *presenter = @"病史陈述者：本人";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddhh:mm:ss"];
    NSDate *admissionTime = [formatter dateFromString:StringValue(patient.pAdmitDate)];
    NSString *pAdmissionTime = [self getYearAndMonthWithDateStr:admissionTime]; //年月日
    NSString *pAdmissionTimeSub =[self getHourAndMinutesWithDateStr:admissionTime] ;//时分秒
    
    NSString *pMaritalStatus = [NSString stringWithFormat:@"婚姻: %@",self.patient.pMaritalStatus?self.patient.pMaritalStatus:@" "];
    NSString *pProvince = [NSString stringWithFormat:@"籍贯: %@",self.patient.pProvince?self.patient.pProvince:@" "];
    NSString *pDetailAddress = [NSString stringWithFormat:@"现居地: %@",self.patient.pDetailAddress?self.patient.pDetailAddress:@" "];
    NSDate *date = [NSDate date];
    NSString *pRecordTime = [self getYearAndMonthWithDateStr:date];
    NSString *pSubRecordTime = [self getHourAndMinutesWithDateStr:date];
    
    self.dataArray = [[NSMutableArray alloc] init];
    
    [self.dataArray addObject: nameStr];
    [self.dataArray addObject: genderStr];
    [self.dataArray addObject: ageStr];
    [self.dataArray addObject: administrative];
    [self.dataArray addObject: pID];
    [self.dataArray addObject: pBedNum];
    
    [self.dataArray addObject: pNation];
    [self.dataArray addObject: presenter];
    [self.dataArray addObject: pProfession];

    
    [self.dataArray addObject: pAdmissionTime];
    [self.dataArray addObject: pAdmissionTimeSub];
    
    [self.dataArray addObject: pMaritalStatus];
    [self.dataArray addObject: pProvince];
    [self.dataArray addObject: pDetailAddress];
    
    [self.dataArray addObject: pRecordTime];
    [self.dataArray addObject: pSubRecordTime];
    
    [self setNeedsLayout];
}
//-(void)setTempPatient:(TempPatient *)tempPatient
//{
//    _tempPatient = tempPatient;
//    
//    self.dataArray = [[NSMutableArray alloc] init];
//    
//    NSString *pID1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"pID"];
//    NSString *dID1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
//    
//    NSDictionary *dict = @{@"pID":pID1,@"dID":dID1};
//
//    
//  //[self layoutSubviews];
//}
-(NSString*)getYearAndMonthWithDateStr:(NSDate*)date
{
    if (date) {
        NSString *dateStr = @"";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        dateStr = [dateStr stringByAppendingString:[formatter stringFromDate:date]];
        
        NSLog(@"date : %@",dateStr);
        return dateStr;
    }else {
       return  @"";
    }
    
}
-(NSString*)getHourAndMinutesWithDateStr:(NSDate*)date
{
    if (date) {
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
    }else {
      return @"";
    }
    
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
        
        for (int i=0; i<10; i++){
            UILabel  *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentLeft;
            label.backgroundColor = [self randomColor];
            label.textColor  =[UIColor darkGrayColor];

            if (i < 6) {
                label.frame = CGRectMake(i*subWidth, 0, subWidth, 29);
            }else if(i == 8){
                label.frame = CGRectMake((i-6)*subWidth, subHeight, 2 * subWidth, 29);
            }else if(i==9){
                label.frame = CGRectMake((i-6)*subWidth+subWidth, subHeight, subWidth, 29);

            }else{
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
        }else if (index < 11) {
            if (index == 6) {
                label.frame = CGRectMake((index-6)*subWidth+8, 8, firstWWidth, 29);
            }else if(index == 8){
                label.frame = CGRectMake((index-6)*subWidth+8, 8, 2 * subWidth, 29);
            }else if(index == 9){
                label.frame = CGRectMake((index-6)*subWidth+subWidth+8, 8,subWidth, 29);

            }else if(index == 10){
                label.frame = CGRectMake((index-6)*subWidth+8+subWidth, 8, subWidth, 29);

            }else {
                label.frame = CGRectMake((index-6)*subWidth+8, 8, subWidth, 29);

            }

        }else {
            if(index == 11){
                label.frame = CGRectMake((index-11)*subWidth+8, 8+subHeight, firstWWidth, 29);

            }else if (index == 13) {
                label.frame = CGRectMake((index-11)*subWidth+8, 8+subHeight, subWidth*2, 29);
            }else if(index == 14){
                label.frame = CGRectMake((index-11)*subWidth+8+subWidth, 8+subHeight, subWidth, 29);
            }else if(index == 15){
                label.frame = CGRectMake((index-11)*subWidth+8+subWidth, 8+subHeight, subWidth, 29);
   
            }else {
                label.frame = CGRectMake((index-11)*subWidth+8, 8+subHeight, subWidth, 29);
 
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
