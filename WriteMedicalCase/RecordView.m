//
//  RecordAndPlayView.m
//  RecordAndPlayAudio
//
//  Created by GK on 15/6/8.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "RecordView.h"
#import <AVFoundation/AVFoundation.h>
#import "SCSiriWaveformView.h"

@interface RecordView()<AVAudioRecorderDelegate>
@property (weak, nonatomic)  UILabel *durationLabel;
@property (weak, nonatomic)  UIButton *endButton;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (weak, nonatomic)  SCSiriWaveformView *waveView;

@property (nonatomic,strong) NSString *duration;
@property (nonatomic,strong) NSString *audioName;

@end
@implementation RecordView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor darkGrayColor];
        [self setUpSubViews];
        [self recorderRecord];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor darkGrayColor];
        [self setUpSubViews];
        [self recorderRecord];
    }
    return self;
}
-(void)setUpSubViews
{
    SCSiriWaveformView *waveView = [[SCSiriWaveformView alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, self.frame.size.height - 30)];
    self.waveView = waveView;
    self.waveView.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:waveView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 10, 50, self.frame.size.height - 16)];
    label.backgroundColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    label.textColor = [UIColor whiteColor];
    label.text = @"000:00";
    
    self.durationLabel = label;
    
    
    self.recorder.delegate = self;
    UIButton *endButton = [UIButton buttonWithType:UIButtonTypeSystem];
    endButton.frame = CGRectMake(self.frame.size.width-64,10, 56, self.frame.size.height - 20);
   // [endButton setTitle:@"完成" forState:UIControlStateNormal];
    [endButton setTintColor:[UIColor whiteColor]];
    [endButton addTarget:self action:@selector(endButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [endButton setBackgroundImage:[UIImage imageNamed:@"end"] forState:UIControlStateNormal];
   // endButton.backgroundColor = [UIColor lightGrayColor];
    endButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:endButton];
    
    self.endButton = endButton;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect labelFrame = CGRectMake(8, 8, 75, self.frame.size.height - 16);

    self.durationLabel.frame = labelFrame;
    CGRect buttonFrame = CGRectMake(self.frame.size.width-48,8,40,self.frame.size.height - 16);
    self.endButton.frame = buttonFrame;
    
    self.waveView.frame = CGRectMake(0, 15, self.frame.size.width, self.frame.size.height - 30);
}
-(void)endButtonClicked:(UIButton*)sender
{
    self.duration =[NSString stringWithFormat:@"%@",@(self.recorder.currentTime)];

    [self.recorder stop];
    //隐藏view
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:self.audioURL options:NSDataReadingMappedIfSafe error:&error];
    [self.delegate didCompletedAudioWithDuration:self.duration audioName:self.audioName audioURL:self.audioURL];
}
-(void)recorderRecord
{
    NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                               AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                               AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                               AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
    NSError *error;
    self.audioURL = [self getSavePath];
   self.recorder = [[AVAudioRecorder alloc] initWithURL:self.audioURL settings:settings error:&error];
    if(error) {
        NSLog(@"Ups, could not create recorder %@", error);
        return;
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    [session setActive:YES error:nil];
    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self.waveView setWaveColor:[UIColor whiteColor]];
    [self.waveView setPrimaryWaveLineWidth:2.0f];
    [self.waveView setSecondaryWaveLineWidth:1.0];
    
}
-(NSURL *)getSavePath{
    NSString *audioName = [self currentDataString];
    self.audioName = audioName;
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               [NSString stringWithFormat:@"%@.m4a",audioName],
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    return outputFileURL;
}
-(NSString*)currentDataString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_HH:mm:ss"];
    
    return [formatter stringFromDate:[NSDate new]];
}
-(void)startRecord
{
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    [self.recorder record];
}
-(void)stopRecord
{
    [self.recorder stop];
}
- (void)updateMeters
{
    CGFloat normalizedValue;
    [self.recorder updateMeters];
    normalizedValue = pow (10, [self.recorder averagePowerForChannel:0] / 30);
    
    NSInteger duration = self.recorder.currentTime;
    
    NSInteger hours = duration/60*60;
    NSInteger minutes = (duration % (60*60) )/60;
    NSInteger seconds = (duration%(60*60)%60)%60;
    NSString *secondsString,*minutesString;
    if (seconds >= 10) {
        secondsString = [NSString stringWithFormat:@"%@",@(seconds)];
    }else {
        secondsString = [NSString stringWithFormat:@"0%@",@(seconds)];
    }
    if (minutes >= 10) {
        minutesString = [NSString stringWithFormat:@"%@",@(minutes)];
    }else {
        minutesString = [NSString stringWithFormat:@"0%@",@(minutes)];
    }
    self.durationLabel.text =[NSString stringWithFormat:@"%@%@:%@",@(hours),minutesString,secondsString];
    [self.waveView updateWithLevel:normalizedValue];
}
@end
