//
//  WEXRichPushLayout.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import "WEXRichPushLayout.h"


@interface WEXRichPushLayout ()
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property (nonatomic, readwrite) WEXRichPushNotificationViewController *viewController;
@property (nonatomic, readwrite) UIView *view;
#endif
@end


@implementation WEXRichPushLayout

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

- (instancetype)initWithNotificationViewController:(WEXRichPushNotificationViewController *)viewController {
    
    if (self = [super init]) {
        self.viewController = viewController;
        self.view = viewController.view;
    }
    
    return self;
}

- (void)didReceiveNotification:(UNNotification *)notification  API_AVAILABLE(ios(10.0)) { }

#endif

@end
