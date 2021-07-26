#include "VLZRootListController.h"

@implementation VLZRootListController

- (instancetype) init {
    self = [super init];

    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:0.08 green:0.35 blue:0.45 alpha:1.0];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0.0 alpha:0.0];

        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];

    // Add respring at right
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStyleDone target:self action:@selector(respring:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.08 green:0.35 blue:0.45 alpha:1.0];
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }

    return _specifiers;
}

- (UITableViewStyle)tableViewStyle {
  return UITableViewStyleInsetGrouped;
}

// Litten's Diary
- (void)resetPrefsPrompt {

    UIAlertController* resetAlert = [UIAlertController alertControllerWithTitle:@"Visualyzer" message:@"Do you really want to reset your preferences?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Preferences/com.xyaman.visualyzerpreferences.plist" error:nil];
        [self respring:nil];
    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];

    [resetAlert addAction:confirmAction];
    [resetAlert addAction:cancelAction];

    [self presentViewController:resetAlert animated:YES completion:nil];

}

- (void)respring:(id)sender {
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/shuffle.dylib"]) {
        [HBRespringController respringAndReturnTo:[NSURL URLWithString:@"prefs:root=Tweaks&path=Visualyzer"]];
    } else {
        [HBRespringController respringAndReturnTo:[NSURL URLWithString:@"prefs:root=Visualyzer"]];   
    }
}

- (void)restartmsd:(id)sender {
    pid_t pid;
    const char* args[] = {"killall", "mediaserverd", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}

@end
