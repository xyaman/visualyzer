#import "BarsView.h"

#define MIN_HZ 20
#define MAX_HZ 20000

@interface BarsView ()
@end

@implementation BarsView

-(instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];


	// Just default, but necessary values in case user don't add them
	self.refreshRateInSeconds = 0.7f;
	self.barsColor = [UIColor whiteColor].CGColor;
	self.barsSensivity = 1.1;
	self.barsRadius = 1;
	self.barsSpacing = 2;
	self.barsWidth = 3.6;
	[self setNumberOfBars: 4];

	self.isMusicPlaying = NO;

	self.audioManager = [[AudioManager alloc] init];
	self.audioManager.delegate = self;
	self.audioManager.refreshRateInSeconds = self.refreshRateInSeconds;

	return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	[super traitCollectionDidChange:previousTraitCollection];


	if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
		self.barsColor = [UIColor whiteColor].CGColor;
	} else {
		self.barsColor = [UIColor blackColor].CGColor;
	}
}


// we need a different setter method, because we also need to create layers
-(void) setNumberOfBars:(int)number {
	_numberOfBars = number;

	// Calculate offset to center bars
	float leftOffset = (self.frame.size.width - (self.barsSpacing * _numberOfBars * self.barsWidth)) / 2;

	for(int i = 0; i < _numberOfBars; i++) {
		CALayer *bar = [CALayer layer];

		bar.frame = CGRectMake(leftOffset + i * (self.barsWidth + self.barsSpacing), self.frame.size.height, self.barsWidth, 0);
		bar.backgroundColor = self.barsColor;
		bar.cornerRadius = self.barsRadius;
		[self.layer addSublayer:bar];
	}
}

-(void) start {
	self.isMusicPlaying = YES;

	[self.audioManager startConnection];
}

-(void) stop {
	self.isMusicPlaying = NO;
	[self.audioManager stopConnection];
}


-(void) play {
	if (!self.isMusicPlaying) return;

	[self.audioManager startConnection];
}

-(void) pause {
	if (!self.isMusicPlaying) return;

	[self.audioManager stopConnection];
}

-(void) newAudioDataWasProcessed:(float *)data withLength:(int)length {
	
	// We want bar frequency visualizer

	// I don't know too much about audio visualization, but I will use a kind of octave bands.
	// with max capacity 10.

	float octaves[10] = {0};
	float offset = 10 / _numberOfBars;
	float freq = 0;
	float binWidth = MAX_HZ / length;

	int band = 0;
	float bandEnd = MIN_HZ * pow(2, 1);

	for(int i = 0; i < length; i++) {
		freq = i > 0 ? i * binWidth : MIN_HZ;

		octaves[band] += data[i];

		if(freq > offset * bandEnd) {
			band += 1;
			bandEnd = MIN_HZ * pow(2, band + 1);
		}
	}


	// Render new bars
	for(int i = 0; i < _numberOfBars; i++) {
		CALayer *bar = self.layer.sublayers[i];
		float heightMultiplier = octaves[i] * self.barsSensivity > 0.95 ? 0.95 : octaves[i] * self.barsSensivity;

		dispatch_async(dispatch_get_main_queue(), ^{
			bar.frame = CGRectMake(bar.frame.origin.x, self.frame.size.height, bar.frame.size.width, -heightMultiplier * self.frame.size.height);
		});
	}
}

@end