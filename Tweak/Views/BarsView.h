#import <UIKit/UIKit.h>
#import "AudioManager.h"

@interface BarsView : UIView <AudioManagerDelegate> {
	int _numberOfBars;
}
@property(nonatomic, retain) AudioManager *audioManager;
@property(nonatomic) float refreshRateInSeconds;
@property(nonatomic) float barsSensivity;
@property(nonatomic) int barsRadius;
@property(nonatomic) struct CGColor *barsColor;
@property(nonatomic) float barsSpacing;
@property(nonatomic) float barsWidth;

// Playing and screen status
@property(nonatomic) BOOL isMusicPlaying;
@property(nonatomic) BOOL isScreenOn;


-(void) setNumberOfBars:(int)number;
-(void) start;
-(void) play;
-(void) stop;
-(void) pause;

@end