//
//  MenstruationView.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "MenstruationView.h"
#import "QuartzCore/QuartzCore.h"

@interface MenstruationView()

@property (nonatomic,strong) UILabel *label1;
@property (nonatomic,strong) UILabel *label2;
@property (nonatomic,strong) UILabel *label3;
@property (nonatomic,strong) UILabel *label4;
@property (nonatomic,strong) UILabel *label5;
@property (nonatomic,strong) UILabel *label6;

@property (nonatomic,strong) UIView *upLine;
@property (nonatomic,strong) UIView *downLine;
@property (nonatomic,strong) UIView *midLine;

@property (nonatomic,strong) NSMutableArray *labelArray;
@end
@implementation MenstruationView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addSubViewToMyView];
    }
    
    return self;
}
-(void)addSubViewToMyView
{
    self.layer.borderWidth = 2;
    
    UIView *view1 = [[UIView alloc] init];
    view1.backgroundColor = [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1];
    self.midLine = view1;
    
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor = [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1];
    self.upLine = view2;

    UIView *view3 = [[UIView alloc] init];
    view3.backgroundColor = [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1];
    self.downLine = view3;

    for (int i=0; i<6; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        [self.labelArray addObject:label];
        [self addSubview:label];
        label.text = @"";
    }
    
    [self addSubview:view1];
    [self addSubview:view2];
    [self addSubview:view3];
    
    
}
-(void)subViewFrameSet
{
    CGRect myFrame = self.frame;
    
    self.midLine.frame = CGRectMake(40, myFrame.size.height/2.0, myFrame.size.width - 2 * 40, 1);
    
    for (int i=0; i<self.array.count; i++) {
        NSString *string = [self.array objectAtIndex:i];
        UILabel *label = [self.labelArray objectAtIndex:i];
        
        label.text = string;
        [label sizeToFit];
        switch (i) {
            case 0:{
               
                label.frame = CGRectMake(8,self.midLine.frame.origin.y - label.frame.size.height/2,label.frame.size.width,label.frame.size.height);
                break;
            }
            case 1:{
                
                label.frame = CGRectMake(self.midLine.frame.origin.x + 20,self.midLine.frame.origin.y - 22, label.frame.size.width,label.frame.size.height);
                 self.upLine.frame = CGRectMake(label.frame.origin.x + label.frame.size.width + 5, label.frame.origin.y+label.frame.size.height/2.0, self.midLine.frame.size.width - 40 -10 - label.frame.size.width * 2, 0.5);
                break;
            }case 2:{
                label.frame = CGRectMake(self.midLine.frame.origin.x +self.midLine.frame.size.width - 20 - label.frame.size.width,self.midLine.frame.origin.y - 22, label.frame.size.width,label.frame.size.height);
               
                break;
            }
            case 3:{
                label.frame = CGRectMake(self.midLine.frame.origin.x + self.midLine.frame.size.width + 8,self.midLine.frame.origin.y - label.frame.size.height/2,label.frame.size.width,label.frame.size.height);
                break;
            }
            case 4:{
                label.frame = CGRectMake(self.midLine.frame.origin.x + 20,self.midLine.frame.origin.y+3, label.frame.size.width,label.frame.size.height);
                self.downLine.frame = CGRectMake(label.frame.origin.x + label.frame.size.width + 5, label.frame.origin.y+label.frame.size.height/2.0, self.midLine.frame.size.width - 40 -10 - label.frame.size.width * 2, 0.5);
                break;
            }case 5:{
                label.frame = CGRectMake(self.midLine.frame.origin.x +self.midLine.frame.size.width - 20 - label.frame.size.width,self.midLine.frame.origin.y+3, label.frame.size.width,label.frame.size.height);
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
    
    [self subViewFrameSet];
}
-(void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer: layer];
    
    [self subViewFrameSet];
}
-(NSArray *)array
{
    if (!_array) {
        _array  = @[@"12",@"4",@"7",@"67",@"28",@"30"];
    }
    return _array;
}
-(NSMutableArray *)labelArray
{
    if (!_labelArray) {
        _labelArray = [[NSMutableArray alloc] init];
    }
    return _labelArray;
}

@end
