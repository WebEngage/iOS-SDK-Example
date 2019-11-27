# WebEngageAppEx

[![Version](https://img.shields.io/cocoapods/v/WebEngageAppEx.svg?style=flat)](http://cocoapods.org/pods/WebEngageAppEx)
[![License](https://img.shields.io/github/license/WebEngage/WebEngageAppEx.svg)](http://cocoapods.org/pods/WebEngageAppEx)
[![Platform](https://img.shields.io/cocoapods/p/WebEngageAppEx.svg?style=flat)](http://cocoapods.org/pods/WebEngageAppEx)
[![LastUpdated](https://img.shields.io/github/last-commit/WebEngage/WebEngageAppEx.svg)](https://cocoapods.org/pods/WebEngageAppEx)

Detailed Setup Guide available [here](https://docs.webengage.com/docs/ios-getting-started).

#### Minimum SDK Requirements ####

WebEngage SDK is supported for `iOS8` and above. The following frameworks should be linked as part of the Xcode project (Direct Integration).

    1. CoreLocation.framework

    2. SystemConfiguration.framework

    3. AdSupport.framework

    4. -lsqlite3

#### There are 2 ways of integrating WebEngage to your existing/new Xcode Project.

#### 1. CocoaPods Integration (Recommended)

  1. Add the following to your Podfile

          # For Xcode 10 and above:

          target 'YourAppTarget' do
              platform :ios, '8.0'
              pod 'WebEngage'
          end

          # ServiceExtension Target
          target 'NotificationService' do
              platform :ios, '10.0'
              pod 'WebEngageBannerPush'
          end

          # ContentExtension Target
          target 'NotificationViewController' do
              platform :ios, '10.0'
              pod 'WebEngageAppEx/ContentExtension'
          end

2. Install WebEngage SDK by running `pod install`


Check out Swift Bridging Header details [here](https://docs.webengage.com/docs/ios-getting-started#section-4-support-for-swift).

Learn about Podfile Specifications [here](https://guides.cocoapods.org/using/the-podfile.html).

#### 2. Direct Integration (Manual) ####

1. Download the SDK file [here](https://s3-us-west-2.amazonaws.com/webengage-sdk/ios/latest/WebEngageFramework.zip). Extract the downloaded zip file. In the extracted zip there would be two directories - xc6 and xc7. If you are using Xcode 9 use the `Webengage.framework` within the `xc9` directory. For Xcode 10 and above use the one in `xc10`. Save the appropriate `Webengage.framework` it in a location on your computer.

2. Select the name of the project in the project navigator. The project editor appears in the editor area of the Xcode workspace window.

3. Click on the `General` Tab at the top of project editor.

4. In the section `Embedded Libraries` click on `+` button. It will open up the file chooser for your project. Open WebEngage.framework and select `Copy if needed` option. This will copy the framework to your project directory.

5. Below Embedded Libraries, there is `Linked Frameworks and Libraries` click the `+` button and add the following frameworks:
    ```
    SystemConfiguration.framework
    CoreLocation.framework
    AdSupport.framework
    ```
6. Go to 'Build Settings' tab on the top of the project editor. Search for `Other Linker Flags` option.
Add `-lsqlite3` under it.

At this point, WebEngage SDK integration is complete and your project should build successfully.

Check out more details [here](https://docs.webengage.com/docs/ios-getting-started).
