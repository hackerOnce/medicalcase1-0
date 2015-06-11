//
//  PlayView.h
//  RecordAndPlayAudio
//
//  Created by GK on 15/6/9.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayViewDelegate <NSObject>

-(void)didCompletedAudioPlay;

@end
@interface PlayView : UIView
//@property (nonatomic,strong) NSURL *playURL;
@property (nonatomic,weak) id <PlayViewDelegate> delegate;
@property (nonatomic,strong) NSData *audioData;
-(void)play;
-(void)endPlay;
@end
