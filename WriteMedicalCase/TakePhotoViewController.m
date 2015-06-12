//
//  TakePhotoViewController.m
//  WriteMedicalCase
//
//  Created by GK on 15/6/6.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "TakePhotoViewController.h"
@interface TakePhotoViewController()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArray;


@end
@implementation TakePhotoViewController
#pragma mask - view controller life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(320, 90);
}

#pragma mask - table view delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     static NSString *cellIdentifier = @"takePhotoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UILabel *textLabel = (UILabel*)[cell viewWithTag:1001];
   // UIImageView *cellImageView = (UIImageView*)[cell viewWithTag:1002];
    
    textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:1001];

    if (indexPath.row == 0) {
        [self takePhotoFromCamera];
    }else {
        [self takePhotoFromPhotosLibrary:textLabel.frame];
    }
}
-(void)takePhotoFromPhotosLibrary:(CGRect)rect
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    
    picker.allowsEditing = YES;
    
    [self.navigationController pushViewController:picker animated:YES];
//    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
//
//    UIPopoverController  *popVC = [[UIPopoverController alloc] initWithContentViewController:picker];
//    popVC.popoverContentSize = CGSizeMake(320, 600);
//    [popVC presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
    
    
    
    //[self presentViewController:picker animated:YES completion:nil];

}
-(void)takePhotoFromCamera
{
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }else {
        
    }
}

#pragma mask - image picker view controller delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    //NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    [self.delegate didSelectedImage:image withImageData:nil atIndexPath:self.currentIndexPath];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mask -m property
-(NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[@"拍照",@"相册"];
    }
    return _dataArray;
}
@end
