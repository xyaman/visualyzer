#import "Tweak.h"

// Sends the notification when the device starts playing music
//
// - Start playing -> @"visualyzerIsPlaying"
// - Stop playing -> @"visualyzerIsNotPlaying"
%hook SBMediaController
-(void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 {
	%orig;

	if([self isPlaying])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerIsPlaying" object:nil];
	else
		[[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerIsNotPlaying" object:nil];

}
%end

// Sends the notification when the phone's screen if OFF or ON
//
// - Backlight ON -> @"visualyzerBacklightIsOn"
// - Stop playing -> @"visualyzerBacklightIsOff"
%hook SBBacklightController
-(void)setBacklightFactorPending:(float)value {
	%orig;

	// Screen is on
	if(value > 0.0f) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerBacklightIsOn" object:nil];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerBacklightIsOff" object:nil];
	}
}
%end

/*
*/