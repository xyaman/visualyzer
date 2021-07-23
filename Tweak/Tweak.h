#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>
#import <MediaRemote/MediaRemote.h>

#import <Sona/SonaView.h>
#import <Sona/SonaBarsView.h>
#import <Sona/SonaLineView.h>
#import <Kitten/libKitten.h>

// Preferences
HBPreferences *preferences = nil;
BOOL isEnabled = NO;
NSString *prefVizStyle = nil;
BOOL prefUseArtworkColor = nil;

NSNumber *location = nil;
int clockLocation = 1;
int signalLocation = 2;
int batteryLocation = 3;

// Bars Related
NSString *prefBarsNumber = nil;
NSString *prefBarsWidth = nil;
NSString *prefBarsSpacing = nil;
NSString *prefBarsRadius = nil;
NSString *prefBarsSensitivity = nil;

NSString *prefUpdatesPerSecond = nil;
NSString *prefAirpodsBoost = nil;

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


// Utils
@interface Utils : NSObject
+ (SonaView *) initializeVisualyzerWithParent:(UIView *)parent;
@end

@implementation Utils
+ (SonaView *) initializeVisualyzerWithParent:(UIView *)parent {

	SonaView *sonaView;

	switch([prefVizStyle intValue]) {
		case 1:
			sonaView = [[SonaBarsView alloc] initWithFrame:parent.frame];
			sonaView.pointNumber = [prefBarsNumber intValue];
			sonaView.pointWidth = [prefBarsWidth floatValue];
			sonaView.pointSpacing = [prefBarsSpacing floatValue];
			sonaView.pointRadius = [prefBarsRadius floatValue];
			sonaView.pointSensitivity = [prefBarsSensitivity floatValue];
			break;

		case 2:
			sonaView = [[SonaLineView alloc] initWithFrame:parent.frame];
			sonaView.pointNumber = [prefBarsNumber intValue]; // Delete
			sonaView.pointWidth = [prefBarsWidth floatValue]; // Delete
			sonaView.pointSpacing = [prefBarsSpacing floatValue]; // Delete
			sonaView.pointRadius = [prefBarsRadius floatValue]; // Delete
			sonaView.pointSensitivity = [prefBarsSensitivity floatValue]; // Delete
			break;
	}

	sonaView.pointAirpodsBoost = [prefAirpodsBoost floatValue];
	sonaView.refreshRateInSeconds = (1.0f / [prefUpdatesPerSecond floatValue]);
	sonaView.parent = parent;

	return sonaView;
}
@end


/*
THE REASON WHY I'M USING VISUALIZER NOTIFICATION SELECTOR INSIDE THIS CLASS, IT'S BECAUSE
WE NEED TO INITIALIZE VISUALIZER THE FIRST TIME, TO GET THE CORRECT FRAME
*/

@interface _UIStatusBarStringView : UIView
@property(nonatomic, retain) SonaView *sonaView;
@property(nonatomic) BOOL iAmTime;
@property(nonatomic) BOOL iAmCarrier;

// new
- (void) updateArtworkColor:(NSNotification *)notification;

- (void) setText:(id)arg1;

- (void) startVisualyzer;
-(void) stopVisualyzer;

-(void) playVisualyzer;
-(void) pauseVisualyzer;

-(void) changeVisualyzerColor:(NSNotification *)notification;

@end


@interface _UIStatusBarCellularSignalView : UIView
@property(nonatomic, retain) SonaView *sonaView;

// new
- (void) updateArtworkColor:(NSNotification *)notification;

-(void) startVisualyzer;
-(void) stopVisualyzer;

-(void) playVisualyzer;
-(void) pauseVisualyzer;

-(void) changeVisualyzerColor:(NSNotification *)notification;
@end