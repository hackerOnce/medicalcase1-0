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

@property (nonatomic,strong) NSArray *dataArray;
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
-(NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[@"马云",@"性别: 男",@"年龄: 55",@"科室: 新年恩克",@"住院号: 09999",@"床好: 98",@"mm",@"性别: 男",@"年龄: 55",@"科室: 新年恩克",@"住院号: 09999",@"床好: 98",@"mm",@"科室: 新年恩克",@"住院号: 09999",@"床好: 98",@"性别: 男",@"性别: 男"];
    }
    return _dataArray;
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
    [self addLabelText];
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
    CGFloat firstWWidth = self.frame.size.width/20.0;

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
