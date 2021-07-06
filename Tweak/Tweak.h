#import <UIKit/UIKit.h>
#import "Views/BarsView.h"

@interface SBMediaController
-(void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 ;
-(BOOL) isPlaying;
@end


@interface _UIStatusBarStringView : UIView
@property (nonatomic) BOOL isClock;
@property(nonatomic, retain) BarsView *barsView;

-(void) setText:(id)arg1;

-(void) startVisualyzer;
-(void) stopVisualyzer;

-(void) playVisualyzer;
-(void) pauseVisualyzer;
@end