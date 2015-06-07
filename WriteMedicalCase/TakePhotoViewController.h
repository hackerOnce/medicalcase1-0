//
//  TakePhotoViewController.h
//  WriteMedicalCase
//
//  Created by GK on 15/6/6.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TakePhotoViewControllerDelegate <NSObject>

-(void)didSelectedImage:(UIImage*)image withImageData:(NSData*)imageData atIndexPath:(NSIndexPath*)indexPath;

@end
@interface TakePhotoViewController : UIViewController
@property (nonatomic,weak) id<TakePhotoViewControllerDelegate> delegate;
@property (nonatomic,strong) NSIndexPath *currentIndexPath;
@end
