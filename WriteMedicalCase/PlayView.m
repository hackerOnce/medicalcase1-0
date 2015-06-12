//
//  PlayView.m
//  RecordAndPlayAudio
//
//  Created by GK on 15/6/9.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "PlayView.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayView()<AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic ,strong) UIButton *endButton;
@property (nonatomic ,strong) UILabel *remainLabel;
@property (nonatomic ,strong) UIProgressView *progressView;
@property (nonatomic ,strong) UILabel *durationLabel;

@property (nonatomic,strong) UIButton *stopButton;
@end

@implementation PlayView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        //[self setUpPlayer];
        [self setUpSubView];
    }
    
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
       // [self setUpPlayer];
        [self setUpSubView];
    }
    
    return self;
}
-(void)setUpSubView
{
    
    CGRect rectFrame = self.frame;
    self.backgroundColor = [UIColor darkGrayColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    //button.backgroundColor = [UIColor lightGrayColor];
    button.frame = CGRectMake(8,8, 44, rectFrame.size.height-16);
    
    [button addTarget:self action:@selector(stopButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    self.stopButton = button;
    
    UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+button.frame.size.width, button.center.x+button.frame.size.height/4 , 45, 21)];
    durationLabel.text = @"00:00";
    [durationLabel sizeToFit];
    [self addSubview:durationLabel];
    
    self.durationLabel = durationLabel;
    
    UIButton *endButton = [UIButton buttonWithType:UIButtonTypeSystem];
    endButton.frame = CGRectMake(rectFrame.size.width-48,8,40,self.frame.size.height - 16);
    [endButton setBackgroundImage:[UIImage imageNamed:@"end"] forState:UIControlStateNormal];
   // [endButton setBackgroundImage:[UIImage imageNamed:@"end"] forState:UIControlStateNormal];
    //[endButton setTitle:@"完成" forState:UIControlStateNormal];
    [endButton setTintColor:[UIColor colorWithRed:113/255.0 green:170/255.0 blue:239/255.0 alpha:1]];
    [endButton addTarget:self action:@selector(endButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //endButton.alpha = 0.25;
    //endButton.backgroundColor = [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1];
    //endButton.backgroundColor = [UIColor lightGrayColor];
    endButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:endButton];
    
    self.endButton = endButton;
    
    UILabel *remainLabel = [[UILabel alloc] initWithFrame:CGRectMake(endButton.frame.origin.x - 45, self.endButton.center.y, 45, 21)];
    remainLabel.text = @"00:00";
    [self addSubview:remainLabel];
    
    self.remainLabel = remainLabel;
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(self.durationLabel.frame.origin.x+self.durationLabel.frame.size.width, self.durationLabel.center.y, self.remainLabel.frame.origin.x - self.durationLabel.frame.size.width-2-self.durationLabel.frame.origin.x, 5)];
    [self addSubview:progressView];
    self.progressView = progressView;
}
-(void)endButtonClicked:(UIButton*)sender
{
    [self.player stop];
    [self.delegate didCompletedAudioPlay];
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rectFrame = self.frame;
    self.stopButton.frame = CGRectMake(8,8, rectFrame.size.height-16, rectFrame.size.height-16);
    [self.stopButton setBackgroundImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    self.durationLabel.frame = CGRectMake(10+self.stopButton.frame.size.width, self.stopButton.center.y-self.stopButton.frame.size.height/4-3 , 45, 21);
    self.durationLabel.textColor = [UIColor colorWithRed:113/255.0 green:170/255.0 blue:239/255.0 alpha:1];
    
    self.endButton.frame = CGRectMake(rectFrame.size.width-48,8,40,self.frame.size.height - 16);
    self.remainLabel.frame = CGRectMake(self.endButton.frame.origin.x - 45, self.endButton.center.y - self.endButton.frame.size.height/4-5, 45, 21);
    self.remainLabel.textColor = [UIColor colorWithRed:113/255.0 green:170/255.0 blue:239/255.0 alpha:1];
    self.progressView.frame = CGRectMake(self.durationLabel.frame.origin.x+self.durationLabel.frame.size.width, self.durationLabel.center.y-2, self.remainLabel.frame.origin.x - self.durationLabel.frame.size.width-2-self.durationLabel.frame.origin.x, 5);
}
-(void)stopButtonClicked:(UIButton*)sender
{
    if ([self.player isPlaying]) {
        [self endPlay];
    }else {
        [self play];
    }
}
-(void)setPlayURL:(NSURL *)playURL
{
   // _playURL = playURL;
    
    [self setUpPlayer];
}
-(void)setAudioData:(NSData *)audioData
{
    _audioData = audioData;
    
    [self setUpPlayer];
}
-(void)setUpPlayer
{
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithData:self.audioData error:&error];
    self.player.delegate = self;
    if(error) {
        NSLog(@"Ups, could not create player %@", error);
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
        return;
    }
    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

    [self play];
}
-(void)play
{
    [self.player prepareToPlay];
    [self.player play];
}
-(void)endPlay
{
    [self.player stop];
}
- (void)updateMeters
{
    NSInteger duration = self.player.currentTime;
    NSInteger minutes = (duration % (60*60) )/60;
    NSInteger seconds = (duration%(60*60)%60)%60;
    NSString *secondsString,*minutesString;
    
    if (minutes >= 10) {
        minutesString = [NSString stringWithFormat:@"%@",@(minutes)];
    }else {
        minutesString = [NSString stringWithFormat:@"0%@",@(minutes)];
    }
    
    if (seconds >= 10) {
        secondsString = [NSString stringWithFormat:@"%@",@(seconds)];
    }else {
        secondsString = [NSString stringWithFormat:@"0%@",@(seconds)];
    }
    self.durationLabel.text = [NSString stringWithFormat:@"%@:%@",minutesString,secondsString];
    
    NSInteger remainTime = self.player.duration - self.player.currentTime;
    NSInteger ramainMinutes = (remainTime % (60*60) )/60;
    NSInteger ramainSeconds = (remainTime%(60*60)%60)%60;
    NSString *ramainMinutesString,*ramainSecondsString;
    
    if (ramainMinutes >= 10) {
        ramainMinutesString = [NSString stringWithFormat:@"%@",@(ramainMinutes)];
    }else {
        ramainMinutesString = [NSString stringWithFormat:@"0%@",@(ramainMinutes)];
    }
    
    if (ramainSeconds >= 10) {
        ramainSecondsString = [NSString stringWithFormat:@"%@",@(ramainSeconds)];
    }else {
        ramainSecondsString = [NSString stringWithFormat:@"0%@",@(ramainSeconds)];
    }
    
    self.remainLabel.text = [NSString stringWithFormat:@"%@:%@",ramainMinutesString,ramainSecondsString];
    self.progressView.progress = self.player.currentTime/self.player.duration;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
