//
//  ToothView.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/17.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ToothView.h"


@interface ToothView()

@property (nonatomic,strong) UIView *HView;
@property (nonatomic,strong) UIView *VView;

@property (nonatomic,strong) UILabel *label;

@property (nonatomic) CGRect VRectLeft;
@property (nonatomic) CGRect VRectRight;

@property (nonatomic) CGRect HRectUp;
@property (nonatomic) CGRect HRectDown;

@end

@implementation ToothView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.VRectLeft = CGRectMake(0, 0, 1, self.frame.size.height);
        self.VRectRight = CGRectMake(self.frame.size.width-1, 0, 1, self.frame.size.height);
        
        self.HRectUp = CGRectMake(0, 0, self.frame.size.width, 1);
        self.HRectDown = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
        
        self.number = @"1";
        
        [self AddViewToMyView];
    }
    return self;
}
-(void)AddViewToMyView
{
    UIView *view1 = [[UIView alloc] init];
    view1.backgroundColor = [UIColor redColor];
    self.VView = view1;
    [self addSubview:self.VView];
    
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor = [UIColor greenColor];
    self.HView = view2;
    [self addSubview:self.HView];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"1";
    [label sizeToFit];
    self.label = label;
    [self addSubview:label];
}
-(void)setNumber:(NSString *)number
{
    _number = number;
    
    self.label.text = StringValue(self.number);
}
-(void)setPosition:(NSString *)position
{
    _position = position;
    
    [self layoutIfNeeded];;
}
-(void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    NSArray *textArray = @[@"右上位",@"左上位",@"右下位",@"左下位"];
    if ([textArray containsObject:self.position]) {
        NSInteger index = [textArray indexOfObject:self.position];
        
        self.label.text = StringValue(self.number);
        [self.label sizeToFit];
        self.label.frame = CGRectMake(self.frame.size.width/2-self.label.frame.size.width/2, self.frame.size.height/4-self.label.frame.size.height/2, self.label.frame.size.width, self.frame.size.height);
        
        switch (index) {
            case 0:{
                self.VView.frame = self.VRectRight;
                self.HView.frame = self.HRectDown;
                break;
            }
            case 1:{
                self.VView.frame = self.VRectLeft;
                self.HView.frame = self.HRectDown;
                
                break;
            }
            case 2:{
                self.VView.frame = self.VRectRight;
                self.HView.frame = self.HRectUp;                break;
            }
            case 3:{
                self.VView.frame = self.VRectLeft;
                self.HView.frame = self.HRectUp;
                break;
            }
            default:
                break;
        }
    }
}
-(void)layoutSubviews
{
    [super layoutSubviews];

    NSArray *textArray = @[@"右上位",@"左上位",@"右下位",@"左下位"];
    if ([textArray containsObject:self.position]) {
        NSInteger index = [textArray indexOfObject:self.position];
        
        self.label.text = StringValue(self.number);
        [self.label sizeToFit];
        self.label.frame = CGRectMake(self.frame.size.width/2-self.label.frame.size.width/2, self.frame.size.height/4-self.label.frame.size.height/2, self.label.frame.size.width, self.frame.size.height);
        
        switch (index) {
            case 0:{
                self.VView.frame = self.VRectRight;
                self.HView.frame = self.HRectDown;
                break;
            }
            case 1:{
                self.VView.frame = self.VRectLeft;
                self.HView.frame = self.HRectDown;
                
                break;
            }
            case 2:{
                self.VView.frame = self.VRectLeft;
                self.HView.frame = self.HRectUp;                break;
            }
            case 3:{
                self.VView.frame = self.VRectLeft;
                self.HView.frame = self.HRectUp;
                break;
            }
            default:
                break;
        }
    }
    
}

@end
