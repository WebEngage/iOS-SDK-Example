//
//  WEXRichPushNotificationViewController.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import "WEXRichPushNotificationViewController+Private.h"
#import "WEXCarouselPushNotificationViewController.h"
#import "WEXRatingPushNotificationViewController.h"
#import "WEXRichPushLayout.h"
#import <WebEngageAppEx/WEXAnalytics.h>
#import <WebEngageAppEx/WEXRichPushNotificationViewController.h>


API_AVAILABLE(ios(10.0))
@interface WEXRichPushNotificationViewController ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

@property (nonatomic) UILabel *label;
@property (nonatomic) WEXRichPushLayout *currentLayout;
@property (nonatomic) UNNotification *notification;
@property (nonatomic) NSUserDefaults *richPushDefaults;

@property (atomic) BOOL isRendering;

#endif

@end


@implementation WEXRichPushNotificationViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

- (void)loadView {
    self.view = [[UIView alloc] init];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (self.label) {
        [self.label removeFromSuperview];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self updateActivityWithObject:[NSNumber numberWithBool:YES] forKey:@"collapsed"];
    [super viewWillDisappear:animated];
}

- (BOOL)canBecomeFirstResponder {
    
    if (self.currentLayout && [self.currentLayout respondsToSelector:@selector(canBecomeFirstResponder)]) {
        return (BOOL)[self.currentLayout performSelector:@selector(canBecomeFirstResponder)];
    }
    return NO;
}

- (UIView *)inputAccessoryView {
    
    if (self.currentLayout && [self.currentLayout respondsToSelector:@selector(inputAccessoryView)]) {
        return [self.currentLayout performSelector:@selector(inputAccessoryView)];
    } else {
        
        return [super inputAccessoryView];
    }
}

- (UIView *)inputView {
    
    if (self.currentLayout && [self.currentLayout respondsToSelector:@selector(inputView)]) {
        return [self.currentLayout performSelector:@selector(inputView)];
    } else {
        return [super inputView];
    }
}

- (void)didReceiveNotification:(UNNotification *)notification  API_AVAILABLE(ios(10.0)) {
    
    self.notification = notification;
    self.isRendering = YES;
    
    NSString *appGroup = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"WEX_APP_GROUP"];
    
    if (!appGroup) {
        
        /*
         Retrieving the app bundle identifier using the method described here:
         https://stackoverflow.com/a/27849695/1357328
         */
        
        NSBundle *bundle = [NSBundle mainBundle];
        
        if ([[bundle.bundleURL pathExtension] isEqualToString:@"appex"]) {
            // Peel off two directory levels - MY_APP.app/PlugIns/MY_APP_EXTENSION.appex
            bundle = [NSBundle bundleWithURL:[[bundle.bundleURL URLByDeletingLastPathComponent] URLByDeletingLastPathComponent]];
        }
        
        NSString *bundleIdentifier = [bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        
        appGroup = [NSString stringWithFormat:@"group.%@.WEGNotificationGroup", bundleIdentifier];
    }
    
    self.richPushDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroup];
    
    [self updateActivityWithObject:[NSNumber numberWithBool:NO] forKey:@"collapsed"];
    [self updateActivityWithObject:[NSNumber numberWithBool:YES] forKey:@"expanded"];
    
    NSString *style = self.notification.request.content.userInfo[@"expandableDetails"][@"style"];
    self.currentLayout = [self layoutForStyle:style];
    
    if (self.currentLayout) {
        [self.currentLayout didReceiveNotification:notification];
    }
}

- (WEXRichPushLayout *)layoutForStyle:(NSString *)style {
    
    if (style && [style isEqualToString:@"CAROUSEL_V1"]) {
        return [[WEXCarouselPushNotificationViewController alloc] initWithNotificationViewController:self];
    } else if (style && [style isEqualToString:@"RATING_V1"]) {
        return [[WEXRatingPushNotificationViewController alloc] initWithNotificationViewController:self];
    }
    
    return nil;
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion  API_AVAILABLE(ios(10.0)) {
    
    [self.currentLayout didReceiveNotificationResponse:response completionHandler:completion];
}


- (NSMutableDictionary *) getActivityDictionaryForCurrentNotification {
    
    NSString *expId = self.notification.request.content.userInfo[@"experiment_id"];
    NSString *notifId = self.notification.request.content.userInfo[@"notification_id"];
    NSString *finalNotifId = [[expId stringByAppendingString:@"|"] stringByAppendingString:notifId];
    NSString *expandableDetails = self.notification.request.content.userInfo[@"expandableDetails"];
    
    id customData = self.notification.request.content.userInfo[@"customData"];
    
    NSMutableDictionary *dictionary = [[self.richPushDefaults dictionaryForKey:finalNotifId] mutableCopy];
    
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:expId forKey:@"experiment_id"];
        [dictionary setObject:notifId forKey:@"notification_id"];
        [dictionary setObject:expandableDetails forKey:@"expandableDetails"];
        
        if (customData && [customData isKindOfClass:[NSArray class]]) {
            [dictionary setObject:customData forKey:@"customData"];
        }
    }
    
    return dictionary;
}

- (void)updateActivityWithObject:(id)object forKey:(NSString *)key {
    
    NSMutableDictionary *activityDictionary = [self getActivityDictionaryForCurrentNotification];
    
    [activityDictionary setObject:object forKey:key];
    
    [self setActivityForCurrentNotification:activityDictionary];
}

- (void)setActivityForCurrentNotification:(NSDictionary *)activity {
    
    NSString *expId = self.notification.request.content.userInfo[@"experiment_id"];
    NSString *notifId = self.notification.request.content.userInfo[@"notification_id"];
    
    NSString *finalNotifId = [[expId stringByAppendingString:@"|"] stringByAppendingString:notifId];
    
    [self.richPushDefaults setObject:activity forKey:finalNotifId];
    [self.richPushDefaults synchronize];
}

- (void)addSystemEventWithName:(NSString *)eventName
                    systemData:(NSDictionary *)systemData
               applicationData:(NSDictionary *)applicationData {
    
    [self addEventWithName:eventName
                systemData:systemData
           applicationData:applicationData
                  category:@"system"];
}

- (void)addEventWithName:(NSString *)eventName
              systemData:(NSDictionary *)systemData
         applicationData:(NSDictionary *)applicationData
                category:(NSString *)category {
    
    id customData = self.notification.request.content.userInfo[@"customData"];
    
    NSMutableDictionary *customDataDictionary = [[NSMutableDictionary alloc] init];
    
    if (customData && [customData isKindOfClass:[NSArray class]]) {
        NSArray *customDataArray = customData;
        for (NSDictionary *customDataItem in customDataArray) {
            customDataDictionary[customDataItem[@"key"]] = customDataItem[@"value"];
        }
    }
    
    if (applicationData) {
        [customDataDictionary addEntriesFromDictionary:applicationData];
    }
    
    if ([category isEqualToString:@"system"]) {
        [WEXAnalytics trackEventWithName:[@"we_" stringByAppendingString:eventName]
                                andValue:@{
                                            @"system_data_overrides": systemData ? systemData : @{},
                                            @"event_data_overrides": customDataDictionary
                                        }];
    } else {
        [WEXAnalytics trackEventWithName:eventName andValue:customDataDictionary];
    }
}

- (void)setCTAWithId:(NSString *)ctaId andLink:(NSString *)actionLink {
    
    NSDictionary *cta = @{@"id": ctaId, @"actionLink": actionLink};
    
    [self updateActivityWithObject:cta forKey:@"cta"];
}

#endif

@end
