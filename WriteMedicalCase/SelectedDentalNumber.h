//
//  SelectedDentalNumber.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/16.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectedDentalNumberDelegate <NSObject>

-(void)didSelectedDentalNumber:(NSString*)number atIndexPath:(NSIndexPath*)indexPath;

@end

@interface SelectedDentalNumber : UIView

@property (nonatomic,strong) UICollectionView *collectionView;
@property (weak,nonatomic) id <SelectedDentalNumberDelegate> delegate;

@end
