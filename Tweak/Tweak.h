#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>

#import "Views/BarsView.h"
#import "Views/VisualyzerView.h"

// Preferences
HBPreferences *preferences = nil;
BOOL isEnabled = NO;

NSNumber *location = nil;
int clockLocation = 1;
int signalLocation = 2;
int batteryLocation = 3;

// View Related
NSString *prefUpdatesPerSecond = nil;
NSString *prefSensivity = nil;
NSString *prefRadius = nil;
NSString *prefSpacing = nil;
NSString *prefWidth = nil;
NSString *prefNumber = nil;


@interface SBMediaController
-(void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 ;
-(BOOL) isPlaying;
@end


/*
THE REASON WHY I'M USING VISUALIZER NOTIFICATION SELECTOR INSIDE THIS CLASS, IT'S BECAUSE
WE NEED TO INITIALIZE VISUALIZER THE FIRST TIME, TO GET THE CORRECT FRAME
*/

@interface _UIStatusBarStringView : UIView
@property(nonatomic, retain) VisualyzerView *vizView;
@property(nonatomic) BOOL iAmTheChosen;

-(void) setText:(id)arg1;

-(void) startVisualyzer;
-(void) stopVisualyzer;

-(void) playVisualyzer;
-(void) pauseVisualyzer;

-(void) changeVisualyzerColor:(NSNotification *)notification;

@end


@interface _UIStatusBarCellularSignalView : UIView
@property(nonatomic, retain) VisualyzerView *vizView;

-(void) startVisualyzer;
-(void) stopVisualyzer;

-(void) playVisualyzer;
-(void) pauseVisualyzer;

-(void) changeVisualyzerColor:(NSNotification *)notification;
@end