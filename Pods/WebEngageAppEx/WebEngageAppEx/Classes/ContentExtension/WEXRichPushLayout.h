//
//  WEXRichPushLayout.h
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WEXRichPushNotificationViewController.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#endif


@interface WEXRichPushLayout

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
: NSObject<UNNotificationContentExtension>

@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readonly) WEXRichPushNotificationViewController *viewController;

- (instancetype)initWithNotificationViewController:(WEXRichPushNotificationViewController *)viewController;

#else
: NSObject
#endif

@end
