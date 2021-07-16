#import <UIKit/UIKit.h>
#import "AudioManager.h"

@interface VisualyzerView: UIView <AudioManagerDelegate>

@property(nonatomic, retain) AudioManager *audioManager;

@property(nonatomic) float refreshRateInSeconds;
@property(nonatomic) float pointSensitivity;
@property(nonatomic) float pointRadius;
@property(nonatomic) float pointSpacing;
@property(nonatomic) float pointWidth;
@property(nonatomic) int pointNumber;
@property(nonatomic) UIColor *pointColor;


- (void) start;
- (void) stop;

- (void) resume;
- (void) pause;

@end