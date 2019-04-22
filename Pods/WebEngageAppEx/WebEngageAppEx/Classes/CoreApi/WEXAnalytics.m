//
//  WEXAnalytics.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import "WEXAnalytics.h"
#import "WEXCoreUtils.h"


@implementation WEXAnalytics

+ (void)trackInternalEventWithName:(NSString *)eventName
                          andValue:(NSDictionary *)eventValue
                     asSystemEvent:(BOOL)val {
    
    NSString *eventKey = [@"weg_event_" stringByAppendingString:[[NSUUID alloc] init].UUIDString];
    [[WEXCoreUtils getDefaults] setObject:@{@"event_name":eventName,@"event_value":eventValue, @"is_system":[NSNumber numberWithBool:val]} forKey:eventKey];
    [[WEXCoreUtils getDefaults] synchronize];
}

+ (void)trackEventWithName:(NSString *)eventName andValue:(NSDictionary *)eventValue {
    
    if ([eventName hasPrefix:@"we_"]) {
        [self trackInternalEventWithName:[eventName substringFromIndex:3] andValue:eventValue asSystemEvent:YES];
    } else {
        [self trackInternalEventWithName:eventName andValue:@{@"event_data_overrides" : eventValue} asSystemEvent:NO];
    }
}

+ (void)trackEventWithName:(NSString *)eventName {
    [self trackEventWithName:eventName andValue:@{}];
}

@end
