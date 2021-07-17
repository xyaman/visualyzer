#include "VLZMiscellaneousListController.h"

@implementation VLZMiscellaneousListController

- (void) viewDidLoad {
    [super viewDidLoad];

    HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
    appearanceSettings.tintColor = [UIColor colorWithRed:0.08 green:0.35 blue:0.45 alpha:1.0];
    appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0.0 alpha:0.0];

    self.hb_appearanceSettings = appearanceSettings;
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Miscellaneous" target:self];
    }

    return _specifiers;
}
@end