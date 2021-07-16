#include "VLZRootListController.h"
#include <spawn.h>

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

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)respring:(id)sender {
	pid_t pid;
	const char *args[] = {"sbreload", NULL, NULL, NULL};
	posix_spawn(&pid, "usr/bin/sbreload", NULL, NULL, (char *const *)args, NULL);
}

- (void)restartmsd:(id)sender {
	pid_t pid;
    const char* args[] = {"killall", "mediaserverd", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}

@end
