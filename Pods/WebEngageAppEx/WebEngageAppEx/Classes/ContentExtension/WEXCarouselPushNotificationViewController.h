//
//  WEXCarouselPushNotificationViewController.h
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "WEXRichPushLayout.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#endif


#define WEX_EVENT_NAME_PUSH_NOTIFICATION_ITEM_VIEW  @"push_notification_item_view"

#define MAIN_VIEW_TO_SUPER_VIEW_WIDTH_RATIO         0.7;
#define MAIN_VIEW_TO_SUPER_VIEW_VERTICAL_MARGINS    5;
#define DESCRIPTION_VIEW_HEIGHT                     50;
#define DESCRIPTION_VIEW_ALPHA                      0.5;
#define INTER_VIEW_MARGINS                          10;
#define SIDE_VIEWS_FADE_ALPHA                       0.75;
#define SLIDE_ANIMATION_DURATION                    0.5
#define LANDSCAPE_ASPECT                            0.5
#define PORTRAIT_ASPECT                             1.0
#define NOTIFICATION_CONTENT_BAR_HEIGHT             50.0


typedef NS_ENUM(NSInteger, WEXCarouselFrameLocation) {
    
    WEXPreviousLeft = -2,
    WEXLeft = -1,
    WEXCurrent = 0,
    WEXRight = 1,
    WEXNextRight = 2
};

@interface WEXCarouselPushNotificationViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
: WEXRichPushLayout
#else
: NSObject
#endif

@end
