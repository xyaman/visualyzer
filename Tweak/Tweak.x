#import "Tweak.h"

// Sends the notification when the phone start playing music
%hook SBMediaController
-(void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 {
    %orig;

    if([self isPlaying])
        [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerIsPlaying" object:nil];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerIsNotPlaying" object:nil];
}

-(void)setNowPlayingInfo:(NSDictionary *)arg1 {
    %orig;

    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {

        NSDictionary *dict = (__bridge NSDictionary *)(information);

        NSData *artworkData = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];

        // Artwork colouring 
        if(prefUseArtworkColor && artworkData) {
            // vide.backgroundColor = [libKitten backgroundColor: vide.iconView.image];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerArtworkChanged" object:nil userInfo:dict];
        }
    });
}
%end


// Sends the notification when the phone's screen if OFF or ON
%hook SBBacklightController
-(void)setBacklightFactorPending:(float)value {
    %orig;

    // Screen is on
    if(value > 0.0f) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerBacklightIsOn" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerBacklightIsOff" object:nil];
    }
};
%end


// // Lockscreen and notification center
// %hook CSCoverSheetViewController

// // Lockscreen appears and we want to hide visualyzer
// - (void)viewWillAppear:(BOOL)animated {
//     [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerLSWillAppear" object:nil];
// }

// - (void)viewWillDisappear:(BOOL)animated { 
//     [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerLSWillDisappear" object:nil];
// }
// %end


/***********************************
 * CLOCK VIEW
************************************/

// When we want the visualyzer be in Clock location
%group ClockView
%hook _UIStatusBarStringView
%property(nonatomic) BOOL iAmTime;
%property(nonatomic) BOOL iAmCarrier;
%property(nonatomic, retain) SonaView *sonaView;

-(instancetype) initWithFrame:(CGRect) frame {
    id orig = %orig;
    self.iAmTime = NO; // :(
    self.iAmCarrier = NO;

    // Start/stop status
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startVisualyzer) name:@"visualyzerIsPlaying" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVisualyzer) name:@"visualyzerIsNotPlaying" object:nil];


    // Play/pause because of screen backlight
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeVisualyzer) name:@"visualyzerBacklightIsOn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseVisualyzer) name:@"visualyzerBacklightIsOff" object:nil];


    // Hide lockscreen
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseVisualyzer) name:@"visualyzerLSWillAppear" object:nil];


    // Artwork colouring
    if(prefUseArtworkColor) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateArtworkColor:) name:@"visualyzerArtworkChanged" object:nil];
    }

    // Testing


    return orig;
}


%new
- (void) updateArtworkColor:(NSNotification *)notification {
    
    if(!self.sonaView) return;

    NSDictionary *userInfo = [notification userInfo];
    NSData *artworkData = [userInfo objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];

    if(artworkData) {
        UIImage *artwork = [UIImage imageWithData:artworkData]; // TODO: Check if artwork can be null
        self.sonaView.pointColor = [Kuro getPrimaryColor:artwork];
    }
}

- (void) didMoveToSuperview {
    NSLog(@"[Visualyzer] frame:%@", NSStringFromCGRect(self.frame));
}

-(void) setText:(NSString*)arg1 {
    %orig;
    if([arg1 containsString:@":"]){
        self.iAmTime = YES;
    } else if (prefHideCarrier && ![arg1 containsString:@"%"] && ![arg1 containsString:@"2G"] && ![arg1 containsString:@"3G"] && ![arg1 containsString:@"4G"] && ![arg1 containsString:@"5G"] && ![arg1 containsString:@"LTE"] && ![arg1 isEqualToString:@"E"]) {
        self.iAmCarrier = YES;
    }

}

-(void) setTextColor:(UIColor *)textColor {
    %orig;
    if(!self.iAmTime) return;

    if(self.sonaView && !prefUseArtworkColor) self.sonaView.pointColor = textColor;
}

%new
-(void) startVisualyzer {

    if(self.iAmTime) {

        // We can't create Bars at initWithFrame, because it doesn't have the same frame and bounds
        // So bars view would never appear
        if(!self.sonaView) {
            self.sonaView = [Utils initializeVisualyzerWithParent:self];
            [self.superview addSubview:self.sonaView];
            
            // Add tap gesture
            if(prefIsSingleTapEnabled) {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.sonaView action:@selector(hideAndShowParentFor2Sec)];
                [self.sonaView addGestureRecognizer:tap];
            }

            // Add tap gesture
            if(prefIsLongTapEnabled) {
                UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self.sonaView action:@selector(openCurrentPlayingApp)];
                [self.sonaView addGestureRecognizer:longTap];
            }
        }

        // Hide View
        [self setHidden:YES];

        // Show Visualyzer and start it
        [self.sonaView setHidden:NO];
        [self.sonaView start];

    } else if(self.iAmCarrier) {
        [self setHidden:YES];
    }

}

%new
-(void) stopVisualyzer {

    if(self.iAmTime) {
        [self setHidden:NO];
        [self.sonaView setHidden:YES];

        [self.sonaView stop];

    } else if(self.iAmCarrier) {
        [self setHidden:NO];
    }
}


// Probably I do need to delete this methods, because are almost pretty useless

// Used when the screen is now ON, and we want to resume
%new
-(void) resumeVisualyzer {
    if(!self.iAmTime) return;

    // [self.sonaView resume];
}


// Used when the screen is now OFF, and we want to pause
%new
-(void) pauseVisualyzer {
    if(!self.iAmTime) return;

    // [self.sonaView pause];
}

%end
%end


/***********************************
 * SIGNAL VIEW
************************************/

%group SignalView
%hook _UIStatusBarCellularSignalView

%property(nonatomic, retain) SonaView *sonaView;

-(id) initWithFrame:(CGRect)frame {

    id orig = %orig;
    NSLog(@"[Visualyzer] location: %@", location);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startVisualyzer) name:@"visualyzerIsPlaying" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVisualyzer) name:@"visualyzerIsNotPlaying" object:nil];


    // Play/pause because of screen backlight
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeVisualyzer) name:@"visualyzerBacklightIsOn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseVisualyzer) name:@"visualyzerBacklightIsOff" object:nil];

    // Artwork colouring
    if(prefUseArtworkColor) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateArtworkColor:) name:@"visualyzerArtworkChanged" object:nil];
    }

    return orig;
}

%new
- (void) updateArtworkColor:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSData *artworkData = [userInfo objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];

    if(artworkData) {
        UIImage *artwork = [UIImage imageWithData:artworkData]; // TODO: Check if artwork can be null
        self.sonaView.pointColor = [Kuro getPrimaryColor:artwork];
    }
}

-(void)_colorsDidChange {
    %orig;

    if(self.sonaView && !prefUseArtworkColor) {
        UIColor *color = [[UIColor alloc] initWithCGColor:self.layer.sublayers[0].backgroundColor];
        self.sonaView.pointColor = color;
    }

}

%new
-(void) startVisualyzer {

    // We can't create Bars at initWithFrame, because it doesn't have the same frame and bounds
    // So bars view would never appear
    if(!self.sonaView) {
        self.sonaView = [Utils initializeVisualyzerWithParent:self];
        [self.superview addSubview:self.sonaView];

        // Add tap gesture
        if(prefIsSingleTapEnabled) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.sonaView action:@selector(hideAndShowParentFor2Sec)];
            [self.sonaView addGestureRecognizer:tap];
        }

        // Add tap gesture
        if(prefIsLongTapEnabled) {
            UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self.sonaView action:@selector(openCurrentPlayingApp)];
            [self.sonaView addGestureRecognizer:longTap];
        }
    }

    // Hide View
    [self setHidden:YES];

    // Show Visualyzer and start it
    [self.sonaView setHidden:NO];
    [self.sonaView start];
}

%new
-(void) stopVisualyzer {

    [self setHidden:NO];
    [self.sonaView setHidden:YES];

    [self.sonaView stop];
}


// Probably I do need to delete this methods, because are almost pretty useless

// Used when the screen is now ON, and we want to resume
%new
-(void) resumeVisualyzer {
    // [self.sonaView resume];
}


// Used when the screen is now OFF, and we want to pause
%new
-(void) pauseVisualyzer {
    // [self.sonaView pause];
}

%end
%end

%ctor {

    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.xyaman.visualyzerpreferences"];
    
    [preferences registerBool:&isEnabled default:NO forKey:@"isEnabled"];
    if(!isEnabled) return;

    // Style
    [preferences registerObject:&prefVizStyle default:@"1" forKey:@"vizStyle"]; // Number of bars/points/etc
    [preferences registerBool:&prefUseArtworkColor default:NO forKey:@"useArtworkColor"];

    // Bars
    [preferences registerObject:&prefBarsNumber default:@"4" forKey:@"barsNumber"];
    [preferences registerObject:&prefBarsWidth default:@"3.6" forKey:@"barsWidth"];
    [preferences registerObject:&prefBarsSpacing default:@"2.0" forKey:@"barsSpacing"];
    [preferences registerObject:&prefBarsRadius default:@"1.0" forKey:@"barsRadius"];
    [preferences registerObject:&prefBarsSensitivity default:@"1.0" forKey:@"barsSensitivity"];

    // Wave
    [preferences registerObject:&prefWaveNumber default:@"16" forKey:@"waveNumber"];
    [preferences registerObject:&prefWaveSensitivity default:@"4.0" forKey:@"waveSensitivity"];
    [preferences registerBool:&prefOnlyLine default:NO forKey:@"waveOnlyLine"];
    [preferences registerObject:&prefWaveYOffset default:0 forKey:@"waveYOffset"];

    // Load all preferences
    [preferences registerObject:&prefAirpodsBoost default:@"1.0" forKey:@"airpodsBoost"];
    [preferences registerObject:&prefUpdatesPerSecond default:@"10.0" forKey:@"updatesPerSecond"];

    [preferences registerBool:&prefHideCarrier default:NO forKey:@"hideCarrier"];

    // Gestures
    [preferences registerBool:&prefIsSingleTapEnabled default:YES forKey:@"isSingleTapEnabled"];
    [preferences registerBool:&prefIsLongTapEnabled default:YES forKey:@"isLongTapEnabled"];

    // Location
    [preferences registerObject:&location default:@"1" forKey:@"location"];

    %init;
    if([location intValue] == clockLocation){
        %init(ClockView);   
    } else if ([location intValue] == signalLocation) {
        %init(SignalView);
    }
}