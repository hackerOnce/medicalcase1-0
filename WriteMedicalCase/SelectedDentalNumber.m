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

@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;
@end

@implementation SelectedDentalNumber

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self addViewToMyView];
    
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    [self addViewToMyView];
    
    return self;
}
-(void)addViewToMyView
{
    
    
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
    
}

-(void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    self.dentalNumber.frame = CGRectMake(4, 20, 68, 21);
    self.showNumber.frame = CGRectMake(75, 20, 39, 21);
    self.collectionView.frame = CGRectMake(4, self.frame.size.height - 45, self.frame.size.width - 4, 44);
    

    [self.collectionView reloadData];

}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.dentalNumber.frame = CGRectMake(4, 20, 68, 21);
    self.showNumber.frame = CGRectMake(75, 20, 39, 21);
    self.collectionView.frame = CGRectMake(4, self.frame.size.height - 45, self.frame.size.width - 4, 44);
    
    [self.collectionView reloadData];
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
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource count];
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

@end
