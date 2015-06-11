//
//  RecordAndPlayView.h
//  RecordAndPlayAudio
//
//  Created by GK on 15/6/8.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecordViewDelegate <NSObject>

-(void)didCompletedAudioWithDuration:(NSString*)durationString audioName:(NSString*)audioName audioURL:(NSURL*)audioURL;

@end
@interface RecordView : UIView
-(void)startRecord;
-(void)stopRecord;
@property (nonatomic,strong) NSURL *audioURL;

@property (nonatomic,weak) id <RecordViewDelegate> delegate;
@end
