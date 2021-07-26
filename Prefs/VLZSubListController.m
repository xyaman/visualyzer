#include "VLZSubListController.h"

@implementation VLZSubListController

- (void) viewDidLoad {
    [super viewDidLoad];

    HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
    appearanceSettings.tintColor = [UIColor colorWithRed:0.08 green:0.35 blue:0.45 alpha:1.0];
    appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0.0 alpha:0.0];

    self.hb_appearanceSettings = appearanceSettings;
}

- (NSArray *)specifiers {
    return _specifiers;
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {

    NSString* sub = [specifier propertyForKey:@"VLZSub"];
    _specifiers = [self loadSpecifiersFromPlistName:sub target:self];
}

- (void)setSpecifier:(PSSpecifier *)specifier {
    [self loadFromSpecifier:specifier];
    [super setSpecifier:specifier];
}

- (BOOL)shouldReloadSpecifiersOnResume {
    return false;
}

- (UITableViewStyle)tableViewStyle {
  return UITableViewStyleInsetGrouped;
}

@end