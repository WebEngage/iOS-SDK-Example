//
//  WEXRichPushNotificationViewController.h
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#endif


/**
 *  This class is an encapsulation for managing handling of custom content
 *  push notifications and the interaction over them. This class has to be extended by
 *  the NotificationViewController class for the Notification Content Extension to
 *  add support for WebEngages's rich push notification service. One should never try
 *  to instantiate this class.
 */
@interface WEXRichPushNotificationViewController
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
: UIViewController<UNNotificationContentExtension>
#else
: NSObject
#endif

@end

