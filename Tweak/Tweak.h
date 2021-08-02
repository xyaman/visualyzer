#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>
#import <MediaRemote/MediaRemote.h>

#import <Sona/SNAView.h>
#import <Sona/SNABarsView.h>
#import <Sona/SNAWaveView.h>
#import <Kuro/libKuro.h>

// Preferences
HBPreferences *preferences = nil;
BOOL isEnabled = NO;
NSString *prefVizStyle = nil;
NSString *prefColoringStyle = nil;
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
NSString *prefBarsXOffset = nil;

// Wave Related
NSString *prefWaveNumber = nil;
NSString *prefWaveSensitivity = nil;
NSString *prefWaveXOffset = nil;
NSString *prefWaveYOffset = nil;
NSString *prefWaveStrokeWidth = nil;
BOOL prefOnlyLine = NO;

NSString *prefUpdatesPerSecond = nil;
NSString *prefAirpodsBoost = nil;

// Gestures
BOOL prefIsSingleTapEnabled = YES;
BOOL prefIsLongTapEnabled = YES;


// Miscellaneous
BOOL prefHideCarrier = NO;

/*----------------------
 |  Notifications constants
 -----------------------*/
NSString *vizStartPlaying = @"visualyzerStartPlaying";
NSString *vizStopPlaying = @"visualyzerStopPlaying";

NSString *vizResume = @"visualyzerResume";
NSString *vizPause = @"visualyzerPause";

NSString *vizNewPlayingInfo = @"visualyzerNewPlayingInfo";


/*----------------------
 |  Class definitions
 -----------------------*/
@interface SBMediaController : NSObject
- (void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 ;
- (BOOL) isPlaying;
@end

@interface SBBacklightController : NSObject
- (void)setBacklightFactorPending:(float)value;
- (void)setNowPlayingInfo:(NSDictionary *)arg1;
@end

@interface CSCoverSheetViewController : UIViewController
@end


/*----------------------
 |  Class definitions
 -----------------------*/
// Clock
@interface _UIStatusBarStringView : UIView
@property(nonatomic) BOOL iAmTime;
@property(nonatomic) BOOL iAmCarrier;
@property(nonatomic, retain) SNAView *sonaView;
@end

// Cellular
@interface _UIStatusBarCellularSignalView : UIView
@property(nonatomic, retain) SNAView *sonaView;
@end


/*----------------------
 | Utils
 -----------------------*/
@interface Utils : NSObject
+ (SNAView *) initializeVisualyzerWithParent:(UIView *)parent;
@end

@implementation Utils
+ (SNAView *) initializeVisualyzerWithParent:(UIView *)parent {

    SNAView *sonaView;

    switch([prefVizStyle intValue]) {
        case 1:
            sonaView = [[SNABarsView alloc] initWithFrame:parent.frame];
            sonaView.pointNumber = [prefBarsNumber intValue];
            sonaView.pointWidth = [prefBarsWidth floatValue];
            sonaView.pointSpacing = [prefBarsSpacing floatValue];
            sonaView.pointRadius = [prefBarsRadius floatValue];
            sonaView.pointSensitivity = [prefBarsSensitivity floatValue];
            sonaView.xOffset = [prefBarsXOffset floatValue];
            break;

        case 2:
            sonaView = [[SNAWaveView alloc] initWithFrame:parent.frame];
            sonaView.pointNumber = [prefWaveNumber intValue];
            sonaView.pointSensitivity = [prefWaveSensitivity floatValue];
            sonaView.xOffset = [prefWaveXOffset floatValue];
            sonaView.yOffset = [prefWaveYOffset floatValue];
            [(SNAWaveView*)sonaView setOnlyLine:prefOnlyLine]; 
            [[(SNAWaveView*)sonaView shapeLayer] setLineWidth:[prefWaveStrokeWidth floatValue]]; 
            break;
    }

    sonaView.coloringStyle = [prefColoringStyle intValue];
    sonaView.pointAirpodsBoost = [prefAirpodsBoost floatValue];
    sonaView.refreshRateInSeconds = (1.0f / [prefUpdatesPerSecond floatValue]);
    sonaView.parent = parent;

    // Add tap gesture
    // UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:sonaView action:@selector(hideAndShowParentFor2Sec)];
    // [sonaView addGestureRecognizer:tap]; 

    return sonaView;
}
@end
