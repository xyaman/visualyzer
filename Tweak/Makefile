TWEAK_NAME = Visualyzer

$(TWEAK_NAME)_FILES = Tweak.x $(wildcard Views/*.m)
$(TWEAK_NAME)_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc
$(TWEAK_NAME)_LIBRARIES = sona kuro
$(TWEAK_NAME)_FRAMEWORKS = Accelerate QuartzCore UIKit
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MediaRemote
$(TWEAK_NAME)_EXTRA_FRAMEWORKS = Cephei

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk