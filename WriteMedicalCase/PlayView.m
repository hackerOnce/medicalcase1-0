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
    self.backgroundColor = [UIColor darkGrayColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor lightGrayColor];
    button.frame = CGRectMake(8,28, 44, 44);
    [button addTarget:self action:@selector(stopButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(8+button.frame.size.width+10, button.center.x+button.frame.size.height/4 , 10, 10)];
    durationLabel.text = @"0:00";
    [durationLabel sizeToFit];
    [self addSubview:durationLabel];
    
    self.durationLabel = durationLabel;
    
    UIButton *endButton = [UIButton buttonWithType:UIButtonTypeSystem];
    endButton.frame = CGRectMake(self.bounds.size.width-64,10, 56, self.frame.size.height - 20);
    [endButton setTitle:@"完成" forState:UIControlStateNormal];
    [endButton setTintColor:[UIColor whiteColor]];
    [endButton addTarget:self action:@selector(endButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    endButton.backgroundColor = [UIColor lightGrayColor];
    endButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:endButton];
    
    self.endButton = endButton;
    
    UILabel *remainLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.endButton.frame.origin.x - 10, self.endButton.center.y, 10, 10)];
    remainLabel.text = @"0:00";
    [remainLabel sizeToFit];
    remainLabel.backgroundColor = [UIColor redColor];
    [self addSubview:remainLabel];
    
    self.remainLabel = remainLabel;
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(durationLabel.frame.origin.x + durationLabel.frame.size.width + 3, durationLabel.center.y, 150, 5)];
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
    
    self.endButton.frame = CGRectMake(self.bounds.size.width-64,28, 56, self.frame.size.height - 20-18);
    self.remainLabel.frame = CGRectMake(self.endButton.frame.origin.x - 40, self.endButton.center.y-self.endButton.frame.size.width/4+5 , 10, 10);
    [self.remainLabel sizeToFit];
    
    self.progressView.frame = CGRectMake(self.durationLabel.frame.origin.x+self.durationLabel.frame.size.width+5, self.durationLabel.center.y, self.remainLabel.frame.origin.x - self.durationLabel.frame.size.width-5-self.durationLabel.frame.origin.x-5, 5);
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
