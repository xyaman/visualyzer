#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>

// #import "Views/BarsView.h"
// #import "Views/VisualyzerView.h"
#import <Sona/SonaView.h>
#import <Sona/SonaBarsView.h>

// Preferences
HBPreferences *preferences = nil;
BOOL isEnabled = NO;

NSNumber *location = nil;
int clockLocation = 1;
int signalLocation = 2;
int batteryLocation = 3;

// View Related
NSString *prefUpdatesPerSecond = nil;
NSString *prefSensitivity = nil;
NSString *prefAirpodsBoost = nil;
NSString *prefRadius = nil;
NSString *prefSpacing = nil;
NSString *prefWidth = nil;
NSString *prefNumber = nil;

// Gestures
BOOL prefIsSingleTapEnabled = YES;
BOOL prefIsLongTapEnabled = YES;


// TimeRelated
BOOL prefHideCarrier = NO;


@interface SBMediaController : NSObject
+ (instancetype)sharedInstance;
// - (SBApplication *)nowPlayingApplication;
- (void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 ;
- (BOOL) isPlaying;
@end

/*
THE REASON WHY I'M USING VISUALIZER NOTIFICATION SELECTOR INSIDE THIS CLASS, IT'S BECAUSE
WE NEED TO INITIALIZE VISUALIZER THE FIRST TIME, TO GET THE CORRECT FRAME
*/

@interface _UIStatusBarStringView : UIView
@property(nonatomic, retain) SonaView *sonaView;
@property(nonatomic) BOOL iAmTime;
@property(nonatomic) BOOL iAmCarrier;

- (void) setText:(id)arg1;

- (void) startVisualyzer;
-(void) stopVisualyzer;

-(void) playVisualyzer;
-(void) pauseVisualyzer;

-(void) changeVisualyzerColor:(NSNotification *)notification;

@end


@interface _UIStatusBarCellularSignalView : UIView
@property(nonatomic, retain) SonaView *sonaView;

-(void) startVisualyzer;
-(void) stopVisualyzer;

-(void) playVisualyzer;
-(void) pauseVisualyzer;

-(void) changeVisualyzerColor:(NSNotification *)notification;
@end