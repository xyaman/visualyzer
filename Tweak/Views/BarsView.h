#import "VisualyzerView.h"
#import "AudioManager.h"

@interface BarsView : VisualyzerView <AudioManagerDelegate> 

// Playing and screen status
@property(nonatomic) BOOL isMusicPlaying;

@end