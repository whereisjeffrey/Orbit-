#!/bin/bash
PLIST="/Users/jeffrey/Desktop/TranslateHelper/TranslateHelperKeyboard/Info.plist"

plutil -replace CFBundleDisplayName -string "TalkSwitch Keyboard" $PLIST
plutil -insert CFBundleExecutable -string "\$(EXECUTABLE_NAME)" $PLIST
plutil -replace CFBundleIdentifier -string "\$(PRODUCT_BUNDLE_IDENTIFIER)" $PLIST
plutil -replace CFBundleInfoDictionaryVersion -string "6.0" $PLIST
plutil -replace CFBundleName -string "\$(PRODUCT_NAME)" $PLIST
plutil -replace CFBundlePackageType -string "XPC!" $PLIST
plutil -replace CFBundleShortVersionString -string "1.0" $PLIST
plutil -replace CFBundleVersion -string "1" $PLIST

plutil -replace NSExtension.NSExtensionPointIdentifier -string "com.apple.keyboard-service" $PLIST
