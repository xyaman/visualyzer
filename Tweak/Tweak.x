#import "Tweak.h"

/*----------------------
 |  Notifications
 -----------------------*/

// Sends the notification when the device starts playing music
%hook SBMediaController
-(void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 {
    %orig;

    if([self isPlaying])
        [[NSNotificationCenter defaultCenter] postNotificationName:vizStartPlaying object:nil];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:vizStopPlaying object:nil];

}
%end

// Only used when artwork color is enabled
%group ArtworkColorNotification
%hook SBMediaController
// This method is for sending the new song artwork
-(void)setNowPlayingInfo:(NSDictionary *)arg1 {
    %orig;

    // arg1 returns a dict that doesn't work for us :(

    if(!prefUseArtworkColor) return;

    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary *info = (__bridge NSDictionary *)(information);
        [[NSNotificationCenter defaultCenter] postNotificationName:vizNewPlayingInfo object:nil userInfo:info];
    });
}
%end
%end



// Sends the notification when the phone's screen if OFF or ON
%hook SBBacklightController
-(void)setBacklightFactorPending:(float)value {
    %orig;

    // Screen is on
    if(value > 0.0f) {
        [[NSNotificationCenter defaultCenter] postNotificationName:vizResume object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:vizPause object:nil];
    }
}
%end

/*----------------------
 |  Hide Carrier
 -----------------------*/
%group HideCarrier
%hook _UIStatusBarStringView
%property(nonatomic) BOOL iAmCarrier;

- (id) initWithFrame:(CGRect)frame {
    id orig = %orig;
    self.iAmCarrier = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hide) name:vizStartPlaying object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unhide) name:vizStopPlaying object:nil];

    return orig;
}

// We are only interested on Carrier
-(void) setText:(NSString*)arg1 {
    %orig;
    if (!self.iAmCarrier && ![arg1 containsString:@":"] && ![arg1 containsString:@"%"] && ![arg1 containsString:@"2G"] && ![arg1 containsString:@"3G"] && ![arg1 containsString:@"4G"] && ![arg1 containsString:@"5G"] && ![arg1 containsString:@"LTE"] && ![arg1 isEqualToString:@"E"]) {
        self.iAmCarrier = YES;
        if([[%c(SBMediaController) sharedInstance] isPlaying]) self.hidden = YES;
    }
}

%new
- (void) hide {
    if(self.iAmCarrier) self.hidden = YES;
}

%new
- (void) unhide {
    if(self.iAmCarrier) self.hidden = NO;
}
%end
%end


/*----------------------
 |  Visualyzer on Time
 -----------------------*/
%group PlaceOnTime
%hook _UIStatusBarStringView
%property(nonatomic, retain) SNAView *sonaView;
%property(nonatomic) BOOL iAmTime;

- (id) initWithFrame:(CGRect)frame {
    id orig = %orig;
    self.iAmTime = NO;

    // Method to start our Sona view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initVisualyzer) name:vizStartPlaying object:nil];

    return orig;
}

- (void) setFrame:(CGRect)frame {
    %orig;

    if(!self.iAmTime || !self.sonaView) return;

    self.sonaView.frame = self.frame;
    [self.sonaView renderPoints];
}


// We are only interested in time
-(void) setText:(NSString*)arg1 {
    %orig;
    if([arg1 containsString:@":"]) self.iAmTime = YES;
}

// Set user system color
-(void) setTextColor:(UIColor *)textColor {
    %orig;
    // Only update if we don't use custom color
    if(self.sonaView && self.iAmTime && !prefUseCustomPrimaryColor) {
        self.sonaView.pointColor = textColor;
        [self.sonaView updateColors];
    }
}


%new
- (void) initVisualyzer {
   if(self.iAmTime) {

        // Create our sona view using prefs
        self.sonaView = [Utils initializeVisualyzerWithParent:self];
        [self.superview addSubview:self.sonaView];
        
        // Add tap gesture
        if(prefIsSingleTapEnabled) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.sonaView action:@selector(hideAndShowParentFor2Sec)];
            [self.sonaView addGestureRecognizer:tap];
        }

        // Add long tap gesture
        if(prefIsLongTapEnabled) {
            // UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self.sonaView action:@selector(openCurrentPlayingApp)];
            UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap)];
            [self.sonaView addGestureRecognizer:longTap];
        }

        // Start it
        [self.sonaView start];

        // Update colors if we use custom
        if(prefUseCustomPrimaryColor || prefUseCustomSecondaryColor) [self.sonaView updateColors];

        // Stop receiving notifications from this view
        [[NSNotificationCenter defaultCenter] removeObserver:self name:vizStartPlaying object:nil];

        // Add play/stop notification to our view
        [[NSNotificationCenter defaultCenter] addObserver:self.sonaView selector:@selector(start) name:vizStartPlaying object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self.sonaView selector:@selector(stop) name:vizStopPlaying object:nil];

        // Add resume/pause notification
        [[NSNotificationCenter defaultCenter] addObserver:self.sonaView selector:@selector(resume) name:vizResume object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self.sonaView selector:@selector(pause) name:vizPause object:nil];

        if(prefUseArtworkColor) [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setArtworkColor:) name:vizNewPlayingInfo object:nil];
   } 
}

%new
- (void) handleLongTap {
    UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] init];
    [feedback prepare];
    [self.sonaView openCurrentPlayingApp];
    [feedback impactOccurred]; 
}

%new
- (void) setArtworkColor:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSData *artworkData = [userInfo objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];

    if(artworkData) {
        UIImage *artwork = [UIImage imageWithData:artworkData]; // TODO: Check if artwork can be null
        self.sonaView.pointSecondaryColor = [Kuro getPrimaryColor:artwork];
        [self.sonaView updateColors];
    }
}

%end
%end

/*-----------------------------
 |  Visualyzer on Cellular bars
 ------------------------------*/
%group PlaceOnCellularBars
%hook _UIStatusBarCellularSignalView
%property(nonatomic, retain) SNAView *sonaView;

- (id) initWithFrame:(CGRect)frame {
    id orig = %orig;

    // Method to start our Sona view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initVisualyzer) name:vizStartPlaying object:nil];

    return orig;
}

- (void) setFrame:(CGRect)frame {
    %orig;

    if(!self.sonaView) return;

    self.sonaView.frame = self.frame;
    [self.sonaView renderPoints];
}

// Set user system color
-(void)_colorsDidChange {
    %orig;

    if(self.sonaView && !prefUseCustomPrimaryColor) {
        UIColor *color = [[UIColor alloc] initWithCGColor:self.layer.sublayers[0].backgroundColor];
        self.sonaView.pointColor = color;
        [self.sonaView updateColors];
    }
}

%new
- (void) initVisualyzer {

    // Create our sona view using prefs
    self.sonaView = [Utils initializeVisualyzerWithParent:self];
    [self.superview addSubview:self.sonaView];
    
    // Add tap gesture
    if(prefIsSingleTapEnabled) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.sonaView action:@selector(hideAndShowParentFor2Sec)];
        [self.sonaView addGestureRecognizer:tap];
    }

    // Add long tap gesture
    if(prefIsLongTapEnabled) {
        // UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self.sonaView action:@selector(openCurrentPlayingApp)];
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap)];

        [self.sonaView addGestureRecognizer:longTap];
    }

    // Start it
    [self.sonaView start];
    
    // Update colors if we use custom ones
    if(prefUseCustomPrimaryColor || prefUseCustomSecondaryColor) [self.sonaView updateColors];

    // Stop receiving notifications from this view
    [[NSNotificationCenter defaultCenter] removeObserver:self name:vizStartPlaying object:nil];

    // Add play/stop notification to our view
    [[NSNotificationCenter defaultCenter] addObserver:self.sonaView selector:@selector(start) name:vizStartPlaying object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.sonaView selector:@selector(stop) name:vizStopPlaying object:nil];

    // Add resume/pause notification
    [[NSNotificationCenter defaultCenter] addObserver:self.sonaView selector:@selector(resume) name:vizResume object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.sonaView selector:@selector(pause) name:vizPause object:nil];

    if(prefUseArtworkColor) [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setArtworkColor:) name:vizNewPlayingInfo object:nil];
}

%new
- (void) handleLongTap {
    UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] init];
    [feedback prepare];
    [self.sonaView openCurrentPlayingApp];
    [feedback impactOccurred]; 
}

%new
- (void) setArtworkColor:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSData *artworkData = [userInfo objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];

    if(artworkData) {
        UIImage *artwork = [UIImage imageWithData:artworkData]; // TODO: Check if artwork can be null
        self.sonaView.pointSecondaryColor = [Kuro getPrimaryColor:artwork];
        [self.sonaView updateColors];
    }
}

%end
%end


%ctor {

    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.xyaman.visualyzerpreferences"];
    
    [preferences registerBool:&isEnabled default:NO forKey:@"isEnabled"];
    if(!isEnabled) return;

    // Location
    [preferences registerObject:&location default:@"1" forKey:@"location"];

    // Style
    [preferences registerObject:&prefVizStyle default:@"1" forKey:@"vizStyle"]; // Number of bars/points/etc
    [preferences registerObject:&prefColoringStyle default:@"2" forKey:@"coloringStyle"];
    [preferences registerBool:&prefUseArtworkColor default:NO forKey:@"useArtworkColor"];
    [preferences registerBool:&prefUseCustomPrimaryColor default:NO forKey:@"useCustomPrimaryColor"];
    [preferences registerBool:&prefUseCustomSecondaryColor default:NO forKey:@"useCustomSecondaryColor"];
    [preferences registerObject:&prefPrimaryCustomColor default:@"000000" forKey:@"primaryCustomColor"];
    [preferences registerObject:&prefSecondaryCustomColor default:@"000000" forKey:@"secondaryCustomColor"];

    // Bars
    [preferences registerObject:&prefBarsNumber default:@"4" forKey:@"barsNumber"];
    [preferences registerObject:&prefBarsWidth default:@"3.6" forKey:@"barsWidth"];
    [preferences registerObject:&prefBarsSpacing default:@"2.0" forKey:@"barsSpacing"];
    [preferences registerObject:&prefBarsRadius default:@"1.0" forKey:@"barsRadius"];
    [preferences registerObject:&prefBarsSensitivity default:@"1.0" forKey:@"barsSensitivity"];
    [preferences registerObject:&prefBarsXOffset default:@"1.0" forKey:@"barsXOffset"];

    // Wave
    [preferences registerObject:&prefWaveNumber default:@"16" forKey:@"waveNumber"];
    [preferences registerObject:&prefWaveSensitivity default:@"4.0" forKey:@"waveSensitivity"];
    [preferences registerObject:&prefWaveStrokeWidth default:@"1.5" forKey:@"waveStrokeWidth"];
    [preferences registerObject:&prefWaveXOffset default:@"0" forKey:@"waveXOffset"];
    [preferences registerObject:&prefWaveYOffset default:@"0" forKey:@"waveYOffset"];
    [preferences registerBool:&prefOnlyLine default:NO forKey:@"waveOnlyLine"];

    // Load all preferences
    [preferences registerObject:&prefAirpodsBoost default:@"1.0" forKey:@"airpodsBoost"];
    [preferences registerObject:&prefUpdatesPerSecond default:@"10.0" forKey:@"updatesPerSecond"];

    // Miscellaneous
    [preferences registerBool:&prefHideCarrier default:NO forKey:@"hideCarrier"];

    // Gestures
    [preferences registerBool:&prefIsSingleTapEnabled default:YES forKey:@"isSingleTapEnabled"];
    [preferences registerBool:&prefIsLongTapEnabled default:YES forKey:@"isLongTapEnabled"];


    %init;

    // Notifications
    if(prefUseArtworkColor) %init(ArtworkColorNotification);
    if(prefHideCarrier) %init(HideCarrier);

    if([location intValue] == clockLocation){
        %init(PlaceOnTime);   
    } else if ([location intValue] == signalLocation) {
        %init(PlaceOnCellularBars);
    }
}