//
//  SelectedDentalNumber.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/16.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "SelectedDentalNumber.h"
#import "SelectedDentalNumberCell.h"

@interface SelectedDentalNumber()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UILabel *showNumber;
@property (nonatomic,strong) UILabel *dentalNumber;
@property (nonatomic,strong) NSArray *dataSource;

@property (nonatomic,strong) NSArray *dataSource2;

@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic,strong) NSString *faceText;
@end

@implementation SelectedDentalNumber

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.isFace = NO;
    self.direction = 1;

    [self addViewToMyView];
    
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    self.isFace = NO;
    self.direction = 3;
    [self addViewToMyView];
    
    return self;
}

-(void)addViewToMyView
{
    
    if (self.isFace) {
        
        if (self.faceLabel) {
            [self.faceLabel removeFromSuperview];
            self.faceLabel = nil;
        }
       // [self clearSubviews];
        
        UILabel *dentalNumber = [[UILabel alloc] init];
        dentalNumber.text = @"牙齿编号";
        dentalNumber.textAlignment = NSTextAlignmentLeft;
        
        self.dentalNumber = dentalNumber;
        
        UILabel *showNumber = [[UILabel alloc] init];
        showNumber.text = @"6";
        showNumber.textAlignment = NSTextAlignmentLeft;
        self.showNumber = showNumber;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(4, self.frame.size.height - 45, self.frame.size.width - 4, 44) collectionViewLayout:flowLayout];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.flowLayout = flowLayout;
        
        // flowLayout.itemSize = CGSizeMake(40, 40);
        [collectionView setCollectionViewLayout:flowLayout];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        
        
        collectionView.backgroundColor = [UIColor whiteColor];
        
        [collectionView registerNib:[UINib nibWithNibName:@"SelectedDentalNumberCell" bundle:nil] forCellWithReuseIdentifier:@"SelectedDentalNumberCell"];
        self.collectionView = collectionView;
        
        [self addSubview:self.showNumber];
        [self addSubview:self.dentalNumber];
        [self addSubview:self.collectionView];

    }else {
        
        if (self.showNumber) {
            [self.showNumber removeFromSuperview];
            self.showNumber = nil;
        }
        if (self.dentalNumber)
        {
            [self.dentalNumber removeFromSuperview];
            self.dentalNumber = nil;
        }
        if (self.collectionView) {
            [self.collectionView removeFromSuperview];
            self.collectionView = nil;
        }
       // [self clearSubviews];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 21)];
        if (self.direction <= 0) {
            self.direction = 1;
        }
        if (self.direction >= 5) {
            self.direction = 4;
        }
        label.text = [self faceTextWithNumber:self.direction];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        //label.backgroundColor = [UIColor redColor];
        [label sizeToFit];
       // label.center = self.center;
        self.faceLabel = label;
        
        self.faceText = self.faceLabel.text;
        [self addSubview:self.faceLabel];
        
    }
    
    
}

-(void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    if (self.isFace) {
        self.dentalNumber.frame = CGRectMake(4, 20, 68, 21);
        self.showNumber.frame = CGRectMake(75, 20, 39, 21);
        self.collectionView.frame = CGRectMake(4, self.frame.size.height - 45, self.frame.size.width - 4, 44);
        
        
        [self.collectionView reloadData];
    }else {
        self.faceLabel.text = [self faceTextWithNumber:self.direction];
        [self.faceLabel sizeToFit];
        CGRect labelFrame = self.faceLabel.frame;
        self.faceLabel.frame = CGRectMake(self.frame.size.width/2.0 - labelFrame.size.width/2.0, self.frame.size.height/2.0 - labelFrame.size.height/2.0, labelFrame.size.width, labelFrame.size.height);
       // self.faceLabel.backgroundColor = [UIColor yellowColor];
    }
    

}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isFace) {
        
        self.dentalNumber.frame = CGRectMake(4, 20, 68, 21);
        self.showNumber.frame = CGRectMake(75, 20, 39, 21);
        self.collectionView.frame = CGRectMake(4, self.frame.size.height - 45, self.frame.size.width - 4, 44);
        
        [self.collectionView reloadData];
    }else {
        
        self.faceText = @"";
        self.faceLabel.text = [self faceTextWithNumber:self.direction];
        self.faceText = self.faceLabel.text;

        [self.faceLabel sizeToFit];
        CGRect labelFrame = self.faceLabel.frame;
        self.faceLabel.frame = CGRectMake(self.frame.size.width/2.0 - labelFrame.size.width/2.0, self.frame.size.height/2.0 - labelFrame.size.height/2.0, labelFrame.size.width, labelFrame.size.height);

    }
    
}

#pragma mask - UICollectionFlowLayout
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.frame.size.width/13,44);
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - UICollectionViewDataSource methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.isFace?1:0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.direction == 2 || self.direction == 4) {
        return [self.dataSource2 count];
    }else {
        return [self.dataSource count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"SelectedDentalNumberCell";
    SelectedDentalNumberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID  forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.cellLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    
   return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedString = [self.dataSource objectAtIndex:indexPath.row];
    self.showNumber.text = selectedString;

    [self.delegate didSelectedDentalNumber:selectedString atIndexPath:indexPath department:self.faceText ];
}
#pragma mask -m UILabel 

#pragma mask -m  Property: DataSource
-(NSArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = @[@"A",@"B",@"C",@"D",@"E",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8"];
    }
    return _dataSource;
}
-(NSArray *)dataSource2
{
    if (!_dataSource) {
        _dataSource = @[@"8",@"7",@"6",@"5",@"4",@"3",@"2",@"1",@"E",@"D",@"C",@"B",@"A"];
    }
    return _dataSource;
}
-(NSString *)faceTextWithNumber:(NSInteger)faceNumber
{
    NSArray *textArray = @[@"右上位",@"左上位",@"右下位",@"左下位"];
    
    return [textArray objectAtIndex:(faceNumber-1)];
}
@end
