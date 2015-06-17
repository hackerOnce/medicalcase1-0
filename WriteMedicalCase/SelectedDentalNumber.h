//
//  SelectedDentalNumber.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/16.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectedDentalNumberDelegate <NSObject>

-(void)didSelectedDentalNumber:(NSString*)number  atIndexPath:(NSIndexPath*)indexPath department:(NSString*)selectedDepartment;

@end

@interface SelectedDentalNumber : UIView

@property (nonatomic) BOOL isFace;
@property (nonatomic,strong) UILabel *faceLabel;


@property (nonatomic) NSInteger direction;//1 : 右上，2：左上 3：右下 4: 左下
-(void)addViewToMyView;

@property (nonatomic,strong) UICollectionView *collectionView;
@property (weak,nonatomic) id <SelectedDentalNumberDelegate> delegate;

@end
