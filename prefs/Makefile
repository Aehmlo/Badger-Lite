include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = BadgerLite
BadgerLite_FILES = BGLRootListController.m
BadgerLite_INSTALL_PATH = /Library/PreferenceBundles
BadgerLite_FRAMEWORKS = UIKit
BadgerLite_PRIVATE_FRAMEWORKS = Preferences
BadgerLite_LIBRARIES = cepheiprefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/BadgerLite.plist$(ECHO_END)
