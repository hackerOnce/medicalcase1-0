//
//  NoteShowViewController.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/5.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NoteShowViewControllerDelegate<NSObject>

-(void)didSelectedANoteWithNoteID:(NSString*)noteID andCreateDoctorID:(NSString*)dID withNoteUUID:(NSString*)noteUUID;
-(void)didDeletedNoteWithNoteID:(NSString*)noteID andNoteUUID:(NSString*)noteUUID;
@end

@interface NoteShowViewController : UIViewController

@property (nonatomic,weak) id<NoteShowViewControllerDelegate> delegate;

@end
