//
//  KSOverlayView.m
//  AVPlayerIOS
//
//  Created by shivaaz on 4/30/23.
//

#import "KSPlayerUIView.h"




@interface KSPlayerUIView()

@property (nonatomic, assign) double durationSecs;
@property (nonatomic, assign) double currentTimeSecs;
@property (nonatomic, assign) bool playing;
@property (nonatomic, assign) bool bSeeking;

@property (nonatomic, assign) float sliderWidth;
@property (nonatomic, assign) float sliderHeight;
@end
@implementation KSPlayerUIView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
         float  screeWidth = [UIScreen mainScreen].bounds.size.width;
         float  screenHeight = [UIScreen mainScreen].bounds.size.height;


        _sliderWidth = screeWidth;
        _sliderHeight = 240;
        
        NSLog(@"frame bounds  %lf %lf",screeWidth,screenHeight);
        
        //Create SubViews;
        
        //seekbar
       _seekBar = [[UISlider alloc] initWithFrame:CGRectMake(0.0f, screenHeight - _sliderHeight , _sliderWidth, _sliderHeight)];
        _seekBar.enabled = TRUE;
        _seekBar.selected = TRUE;
        [_seekBar addTarget:self action:@selector(seekUI:) forControlEvents:UIControlEventValueChanged];
        
        
        //playButton
       _playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50.0f, 50.0f) ];
        [self.playButton setTitle:@"play/pause" forState:0];
        self.playButton.backgroundColor = UIColor.blueColor;
        [self.playButton addTarget:self action:@selector(togglePlay:) forControlEvents:UIControlEventTouchUpInside];
        
        
       [self addSubview:_seekBar];
       [self addSubview:_playButton];
        
        _playing = true;
        _bSeeking = false;
    }
    return self;
}
- (IBAction)togglePlay:(id)sender;
{
    if(_playing)
    {
        NSLog(@"pause");
        [self.delegate pause];
    }
    else
    {
        NSLog(@"play");
        [self.delegate play];
    }
    
    _playing = !_playing;
}
-(void)playbackComplete {
    
}

- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration {
    
    _currentTimeSecs = time;
    //_durationSecs = duration;
    
    NSLog(@"duration %lf currentTime %lf",_durationSecs,_currentTimeSecs);
    
    double seekPercentage = (_currentTimeSecs)/(_durationSecs);
    seekPercentage *= _seekBar.maximumValue;
   _seekBar.value = seekPercentage;
    
    
}
-(void)seekUI:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    double seekTime = _durationSecs *slider.value/slider.maximumValue ;
    NSLog(@"seeking %lf",seekTime);
    
    
}

- (void)setScrubbingTime:(NSTimeInterval)time {
    
}

- (void)setTitle:(NSString *)title {
    
}

- (void)setTotalDurationSecs:(double)duration
{
    _durationSecs = duration;
    _seekBar.minimumValue = 0;
    _seekBar.maximumValue = _durationSecs;
}


-(void)setPlayDelegate:(id<KSTransportDelegate>)delegate
{
    self.delegate = delegate;
}





@end
