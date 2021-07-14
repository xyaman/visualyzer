#import "VisualyzerView.h"

@interface VisualyzerView ()
@end

@implementation VisualyzerView
- (instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	// Just defaults, but necessary values in case I forgot to add them later
	self.refreshRateInSeconds = 0.1f;
	self.pointSensivity = 1.0f;
	self.pointRadius = 1.0f;
	self.pointSpacing = 2.0f;
	self.pointWidth = 3.6f;
	self.pointNumber = 4;

	self.pointColor = [UIColor whiteColor];



	self.audioManager = [[AudioManager alloc] init];
	self.audioManager.delegate = self;
	self.audioManager.refreshRateInSeconds = self.refreshRateInSeconds;


	return self;
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