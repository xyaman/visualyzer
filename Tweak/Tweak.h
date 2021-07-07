#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>

#import "Views/BarsView.h"

// Preferences
HBPreferences *preferences = nil;
BOOL isEnabled = NO;

// View Related
float refreshRateInSeconds = 0.7f;
float sensivity = 1.1f;
float radius = 1.0f;
float spacing = 2.0f;
NSString *width = nil;
NSString *number = nil;


@interface SBMediaController
-(void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 ;
-(BOOL) isPlaying;
@end


@interface _UIStatusBar : UIView
@property(nonatomic, copy) UIColor *foregroundColor;                                                                                             //@synthesize foregroundColor=_foregroundColor - In the implementation block
@end



@interface _UIStatusBarStringView : UIView
@property(nonatomic) BOOL isClock;
@property(nonatomic, retain) BarsView *barsView;

-(void) setText:(id)arg1;

-(void) startVisualyzer;
-(void) stopVisualyzer;

-(void) playVisualyzer;
-(void) pauseVisualyzer;

@end