TWEAK_NAME = Visualyzer

$(TWEAK_NAME)_FILES = Tweak.x $(wildcard Views/*.m)
$(TWEAK_NAME)_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = Accelerate QuartzCore UIKit

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk