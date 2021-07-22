#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>

#import <Sona/SonaView.h>
#import <Sona/SonaBarsView.h>
#import <Sona/SonaLineView.h>

// Preferences
HBPreferences *preferences = nil;
BOOL isEnabled = NO;
NSString *prefVizStyle = nil;

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
			break;

		case 2:
			sonaView = [[SonaLineView alloc] initWithFrame:parent.frame];
			break;
	}


	sonaView.pointNumber = [prefNumber intValue];
	sonaView.pointWidth = [prefWidth floatValue];
	sonaView.pointSpacing = [prefSpacing floatValue];
	sonaView.pointRadius = [prefRadius floatValue];
	sonaView.pointSensitivity = [prefSensitivity floatValue];
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