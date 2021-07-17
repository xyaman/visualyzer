#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "AudioManager.h"



@interface VisualyzerView: UIView <AudioManagerDelegate>

@property(nonatomic, retain) AudioManager *audioManager;
@property(nonatomic, retain) UIView *parent;

@property(nonatomic) float refreshRateInSeconds;
@property(nonatomic) float pointSensitivity;
@property(nonatomic) float pointAirpodsBoost;
@property(nonatomic) float pointRadius;
@property(nonatomic) float pointSpacing;
@property(nonatomic) float pointWidth;
@property(nonatomic) int pointNumber;
@property(nonatomic) UIColor *pointColor;

@property(nonatomic) BOOL isMusicPlaying;

// Gestures
@property(nonatomic) BOOL isSingleTapEnabled;
@property(nonatomic) BOOL isLongTapEnabled;

- (void) handleSingleTap:(UITapGestureRecognizer *)recognizer;
- (void) handleHoldTap:(UITapGestureRecognizer *)recognizer;

- (void) start;
- (void) stop;

- (void) resume;
- (void) pause;

@end




// Open Audio application related
@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;                                                                                     //@synthesize bundleIdentifier=_bundleIdentifier - In the implementation block
@end

@interface SBMediaController : NSObject
+ (instancetype)sharedInstance;
- (SBApplication *)nowPlayingApplication;
- (void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 ;
- (BOOL) isPlaying;
@end

@interface UIApplication ()
// + (instancetype) sharedApplication;
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2 ;
@end