//
//  ContainerCellView.m
//  HorizontalScrollingTableView
//
//  Created by GK on 15/6/7.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ContainerCellView.h"
#import "CollectionViewCell.h"

@interface ContainerCellView () <UICollectionViewDataSource,UICollectionViewDelegate>
@property (strong, nonatomic) NSArray *collectionData;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@end
@implementation ContainerCellView
@synthesize collectionData = _collectionData;
- (void)awakeFromNib {
    
   // self.collectionView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(300, 300);
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    // Register the colleciton cell
    [_collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionViewCell"];
    
}

#pragma mark - Getter/Setter overrides
- (void)setCollectionData:(NSArray *)collectionData {
   // self.collectionData = [NSArray arrayWithArray:collectionData];
  //  self.collectionData = collectionData;
    _collectionData = collectionData;
    [_collectionView setContentOffset:CGPointZero animated:NO];
    [_collectionView reloadData];
}
#pragma mark - UICollectionViewDataSource methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectionData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    
    MediaData *mediaData = [self.collectionData objectAtIndex:indexPath.row];
    
    cell.imageView.image = [UIImage imageWithData:mediaData.data scale:0.5];
    
   // NSDictionary *cellData = [self.collectionData objectAtIndex:[indexPath row]];
    cell.titleLabel.text = mediaData.mediaNameString;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellData = [self.collectionData objectAtIndex:[indexPath row]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectItemFromCollectionView" object:cellData];
}
@end
