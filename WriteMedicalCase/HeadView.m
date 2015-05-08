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
        btn.frame = CGRectMake(0, 0, self.frame.size.width, 45);
        [btn addTarget:self action:@selector(doSelected) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        self.backBtn = btn;
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
       // self.layer.borderWidth  =1;
       // self.layer.borderColor= [UIColor redColor].CGColor;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 1)];
        line.tag = 1001;
        line.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:line];
        
    }
    return self;
}
-(void)doSelected{
    //    [self setImage];
    if (_delegate && [_delegate respondsToSelector:@selector(selectedWith:)]){
        [_delegate selectedWith:self];
    }
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    UIView *myView =(UIView*) [self viewWithTag:1001];
    myView.frame = CGRectMake(0, 45, self.frame.size.width, 1);
    self.backBtn.frame = CGRectMake(0, 0, self.frame.size.width, 45);
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
