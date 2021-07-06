#import "Tweak.h"

%hook SBMediaController

-(void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 {
	%orig;

	if([self isPlaying])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerIsPlaying" object:nil];
	else
		[[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerIsNotPlaying" object:nil];
}

%end


%hook SBBacklightController

-(void)setBacklightFactorPending:(float)value {
	%orig;

	// Screen is on
	if(value > 0.0f) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerBacklightIsOn" object:nil];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerBacklightIsOff" object:nil];
	}
};
%end

%group ClockView
%hook _UIStatusBarStringView
%property(nonatomic) BOOL isClock;
%property(nonatomic, retain) BarsView *barsView;

-(instancetype) initWithFrame:(CGRect) frame {
	id orig = %orig;
	self.isClock = NO;	

	// Start/stop status
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startVisualyzer) name:@"visualyzerIsPlaying" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVisualyzer) name:@"visualyzerIsNotPlaying" object:nil];


	// Play/pause because of screen backlight
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVisualyzer) name:@"visualyzerBacklightIsOn" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseVisualyzer) name:@"visualyzerBacklightIsOff" object:nil];

	return orig;
}

-(void) setText:(NSString*)text {
	self.isClock = [text containsString:@":"];
	%orig;
}

%new
-(void) startVisualyzer {

	if(!self.isClock) return;

	if(!self.barsView) {
		self.barsView = [[BarsView alloc] initWithFrame:self.frame];
		[self.superview addSubview:self.barsView];
		[self.barsView setHidden:YES];
	}

	[self setHidden:YES];
	[self.barsView setHidden:NO];

	[self.barsView start];

}

%new
-(void) playVisualyzer {
	if(!self.isClock) return;

	[self.barsView play];
}

%new
-(void) stopVisualyzer {

	if(!self.isClock) return;

	[self setHidden:NO];
	[self.barsView setHidden:YES];

	[self.barsView stop];
}

%new
-(void) pauseVisualyzer {
	if(!self.isClock) return;

	[self.barsView pause];
}

%end
%end

%ctor {
	%init;
	%init(ClockView);
}