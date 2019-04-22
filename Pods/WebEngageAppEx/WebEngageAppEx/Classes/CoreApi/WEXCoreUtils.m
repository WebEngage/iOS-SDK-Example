//
//  WEXCoreUtils.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import "WEXCoreUtils.h"

@implementation WEXCoreUtils

+ (NSUserDefaults *)getDefaults {
    
    static NSUserDefaults *sharedDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *appGroup = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"WEG_APP_GROUP"];
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
        sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroup];
    });
    return sharedDefaults;
}

+ (NSDateFormatter *)getDateFormatter {
    static NSDateFormatter *birthDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        birthDateFormatter = [[NSDateFormatter alloc] init];
        [birthDateFormatter setDateFormat:@"yyyy-MM-dd"];
        [birthDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [birthDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"gb"]];
    });
    return birthDateFormatter;
}

@end
