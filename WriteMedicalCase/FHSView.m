//
//  FHSView.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/17.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "FHSView.h"

@interface FHSView()

@property (nonatomic,strong) UILabel *indicatorLabel;

@property (nonatomic,strong) UIView *HView;
@property (nonatomic,strong) UIView *VView;

@property (nonatomic) CGPoint upPoint;
@property (nonatomic) CGPoint zeroPoint;
@property (nonatomic) CGPoint downPoint;

@property (nonatomic) CGPoint upLeftPoint;
@property (nonatomic) CGPoint zeroLeftPoint;
@property (nonatomic) CGPoint downLeftPoint;

@property (nonatomic) CGPoint upRightPoint;
@property (nonatomic) CGPoint zeroRightPoint;
@property (nonatomic) CGPoint downRightPoint;

@end

@implementation FHSView

-(instancetype)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
    if (self) {
        [self addSubViewToMyView];
        
        self.direction = 9;
        
        CGRect VVFrame = self.VView.frame;
        self.upLeftPoint =CGPointMake(VVFrame.origin.x, VVFrame.origin.y/4.0);
        
        
    }
    return self;
}
-(void)setDirection:(NSInteger)direction
{
    _direction = direction;
    
    [self layoutSubviews];
}
-(void)addSubViewToMyView
{
    UILabel *label = [[UILabel alloc] init];
    label.text = @"⊗";
    label.font = [UIFont systemFontOfSize:10];
    [label sizeToFit];
    self.indicatorLabel = label;
    [self addSubview:label];
    
    UIView *view1 = [[UIView alloc] init];
    view1.backgroundColor = [UIColor redColor];
    self.VView = view1;
    [self addSubview:self.VView];
    
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor = [UIColor greenColor];
    self.HView = view2;
    [self addSubview:self.HView];
        
}

-(void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    self.HView.frame = CGRectMake(0,self.frame.size.height/2, self.frame.size.width, 1);
    self.VView.frame = CGRectMake(self.frame.size.width/2,0,1,self.frame.size.height);
    
    switch (self.direction) {
        case 1: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0 - self.HView.frame.size.width/4, self.VView.frame.origin.y + self.VView.frame.size.height/8, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }
        case 2: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0, self.VView.frame.origin.y + self.VView.frame.size.height/8, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }case 3: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0 + self.HView.frame.size.width/4, self.VView.frame.origin.y + self.VView.frame.size.height/8, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }case 4: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0 - self.HView.frame.size.width/4, self.VView.frame.origin.y + self.VView.frame.size.height/2.0 - 5, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }
        case 5: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0, self.VView.frame.origin.y + self.VView.frame.size.height/2.0 - 5, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }
        case 6: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0 + self.HView.frame.size.width/4, self.VView.frame.origin.y + self.VView.frame.size.height/2.0 - 5, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }case 7: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0 - self.HView.frame.size.width/4, self.VView.frame.origin.y + self.VView.frame.size.height/2.0 - 5 + self.VView.frame.size.height/4, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }case 8: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0 , self.VView.frame.origin.y + self.VView.frame.size.height/2.0 - 5 + self.VView.frame.size.height/4, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }
        case 9: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0 + self.HView.frame.size.width/4, self.VView.frame.origin.y + self.VView.frame.size.height/2.0 - 5 + self.VView.frame.size.height/4, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }

        default:
            break;
    }
 
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.HView.frame = CGRectMake(0,self.frame.size.height/2, self.frame.size.width, 1);
    self.VView.frame = CGRectMake(self.frame.size.width/2,0,1,self.frame.size.height);
    
    switch (self.direction) {
        case 1: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0 - self.HView.frame.size.width/4, self.VView.frame.origin.y + self.VView.frame.size.height/8, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }
        case 2: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0, self.VView.frame.origin.y + self.VView.frame.size.height/8, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }case 3: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0 + self.HView.frame.size.width/4, self.VView.frame.origin.y + self.VView.frame.size.height/8, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }case 4: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0 - self.HView.frame.size.width/4, self.VView.frame.origin.y + self.VView.frame.size.height/2.0 - 5, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }
        case 5: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0, self.VView.frame.origin.y + self.VView.frame.size.height/2.0 - 5, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }
        case 6: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0 + self.HView.frame.size.width/4, self.VView.frame.origin.y + self.VView.frame.size.height/2.0 - 5, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }case 7: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0 - self.HView.frame.size.width/4, self.VView.frame.origin.y + self.VView.frame.size.height/2.0 - 5 + self.VView.frame.size.height/4, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }case 8: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0 , self.VView.frame.origin.y + self.VView.frame.size.height/2.0 - 5 + self.VView.frame.size.height/4, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }
        case 9: {
            self.indicatorLabel.frame = CGRectMake(self.VView.frame.origin.x-self.indicatorLabel.frame.size.width/2.0 + self.HView.frame.size.width/4, self.VView.frame.origin.y + self.VView.frame.size.height/2.0 - 5 + self.VView.frame.size.height/4, self.indicatorLabel.frame.size.width, self.indicatorLabel.frame.size.height);
            break;
        }
            
        default:
            break;
    }

}
@end
