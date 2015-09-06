include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BadgerLite
BadgerLite_FILES = $(wildcard *.m *.xm *.x)
BadgerLite_LIBRARIES = cephei
BadgerLite_CFLAGS += -Iinclude
BadgerLite_FRAMEWORKS = UIKit Foundation CoreGraphics

SUBPROJECTS = prefs

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"