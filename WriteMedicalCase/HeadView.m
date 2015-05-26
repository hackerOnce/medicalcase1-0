//
//  HeaderView.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/23.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "HeadView.h"
@interface HeadView()


@end

@implementation HeadView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.open = YES;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, self.frame.size.width, 43);
        [btn addTarget:self action:@selector(doSelected) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor whiteColor];
        [self addSubview:btn];
        self.backBtn = btn;
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        self.backgroundColor = [UIColor whiteColor];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 1)];
        line.tag = 1001;
        line.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:line];
        
    }
    return self;
}
-(void)doSelected{
    if (_delegate && [_delegate respondsToSelector:@selector(selectedWith:)]){
        [_delegate selectedWith:self];
    }
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backBtn.frame = CGRectMake(0, 0, self.frame.size.width, 43);
    
}
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    UIView *myView =(UIView*) [self viewWithTag:1001];
    [myView removeFromSuperview];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 1)];
    line.tag = 1001;
    line.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:line];
}

@end
