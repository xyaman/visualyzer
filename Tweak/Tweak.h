#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>
#import <MediaRemote/MediaRemote.h>

#import <Sona/SonaView.h>
#import <Sona/SonaBarsView.h>
#import <Sona/SonaWaveView.h>
#import <Kuro/libKuro.h>

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
@property(nonatomic, retain) SonaView *sonaView;
@end

// Cellular
@interface _UIStatusBarCellularSignalView : UIView
@property(nonatomic, retain) SonaView *sonaView;
@end


/*----------------------
 | Utils
 -----------------------*/
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
            sonaView.xOffset = [prefBarsXOffset floatValue];
            break;

        case 2:
            sonaView = [[SonaWaveView alloc] initWithFrame:parent.frame];
            sonaView.pointNumber = [prefWaveNumber intValue];
            sonaView.pointSensitivity = [prefWaveSensitivity floatValue];
            sonaView.xOffset = [prefWaveXOffset floatValue];
            sonaView.yOffset = [prefWaveYOffset floatValue];
            [(SonaWaveView*)sonaView setOnlyLine:prefOnlyLine]; 
            [[(SonaWaveView*)sonaView shapeLayer] setLineWidth:[prefWaveStrokeWidth floatValue]]; 
            break;
    }

    sonaView.pointAirpodsBoost = [prefAirpodsBoost floatValue];
    sonaView.refreshRateInSeconds = (1.0f / [prefUpdatesPerSecond floatValue]);
    sonaView.parent = parent;

    // Add tap gesture
    // UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:sonaView action:@selector(hideAndShowParentFor2Sec)];
    // [sonaView addGestureRecognizer:tap]; 

    return sonaView;
}
@end
