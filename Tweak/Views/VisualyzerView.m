#import "VisualyzerView.h"

@interface VisualyzerView ()
@end

@implementation VisualyzerView
- (instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	// Just defaults, but necessary values in case I forgot to add them later
	self.refreshRateInSeconds = 0.1f;
	self.pointSensitivity = 1.0f;
	self.pointAirpodsBoost = 1.0f;
	self.pointRadius = 1.0f;
	self.pointSpacing = 2.0f;
	self.pointWidth = 3.6f;
	self.pointNumber = 4;

	self.pointColor = [UIColor whiteColor];
	self.isMusicPlaying = NO;

	self.audioManager = [[AudioManager alloc] init];
	self.audioManager.delegate = self;
	self.audioManager.refreshRateInSeconds = self.refreshRateInSeconds;

	UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[self addGestureRecognizer:singleFingerTap];

	return self;
}

- (void) handleSingleTap:(UITapGestureRecognizer *)recognizer {

	if(self.parent) {
		// Animate dissapear
		[UIView animateWithDuration:0.5
			animations:^{
				self.alpha = 0.0;
    		} 
    		completion:^(BOOL finished){
    			self.parent.hidden = NO;
    		}
    	];	

		// Wait 2 seconds and show visualyzer again
		[NSTimer scheduledTimerWithTimeInterval:2 repeats:NO block:^(NSTimer *timer){
			self.alpha = 1;

			if(self.isMusicPlaying) self.parent.hidden = YES;
		}];
	}	

}

- (void) start {

}

- (void) stop {

}

- (void) resume {

}

- (void) pause {

}

-(void) newAudioDataWasProcessed:(float *)data withLength:(int)length {

}
@end