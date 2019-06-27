#!/bin/sh
# if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
#   echo "This is a pull request. No deployment will be done."
#   exit 0
# fi
security list-keychains -s ios-build.keychain
rm ~/Library/MobileDevice/Provisioning\ Profiles/$PROFILE_NAME.mobileprovision
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles/
cp ./scripts/profile/$PROFILE_NAME.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
echo "*********************"
echo "*     Archiving     *"
echo "*********************"
xcrun xcodebuild -workspace PublicDemo.xcworkspace -scheme PublicDemo -archivePath $ARCHIVE_NAME.xcarchive archive
# echo "**********************"
# echo "*     Exporting      *"
# echo "**********************"
# xcrun xcodebuild -exportArchive -archivePath $ARCHIVE_NAME.xcarchive -exportPath . -exportOptionsPlist ExportOptions.plist
