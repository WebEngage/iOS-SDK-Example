//
//  WEXUser.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import "WEXUser.h"
#import "WEXCoreUtils.h"

@implementation WEXUser

// TODO: unify following flavors.
+ (void)setAttribute:(NSString *)attributeName withAnyValue:(id)value {
    
    if (attributeName && ![attributeName isEqualToString:@""]) {
        if (value) {
            [WEXAnalytics trackEventWithName:[@"we_" stringByAppendingString:WEG_EVENT_NAME_USER_UPDATE]
                                    andValue:@{ @"event_data_overrides": @{attributeName : value} }];
        } else {
            NSLog(@"Invalid value(nil) in `setAttribute` for attribute %@: ", attributeName);
        }
    } else {
        NSLog(@"Invalid attribute name in `setAttribute`: nil or empty string");
    }
}

+ (void)setAttribute:(NSString *)attributeName
     withStringValue:(NSString *)value {
    [self setAttribute:attributeName withAnyValue:value];
}

+ (void)setAttribute:(NSString *)attributeName withValue:(NSNumber *)value {
    [self setAttribute:attributeName withAnyValue:value];
}

+ (void)setAttribute:(NSString *)attributeName withArrayValue:(NSArray *)value {
    [self setAttribute:attributeName withAnyValue:value];
}

+ (void)setAttribute:(NSString *)attributeName withDateValue:(NSDate *)value {
    [self setAttribute:attributeName withAnyValue:value];
}

+ (void)setAttribute:(NSString *)attributeName
 withDictionaryValue:(NSDictionary *)value {
    [self setAttribute:attributeName withAnyValue:value];
}

+ (void)deleteAttribute:(NSString *)attributeName {
    [WEXAnalytics trackEventWithName:[@"we_" stringByAppendingString:WEG_EVENT_NAME_USER_DELETE_ATTRS]
                            andValue:@{ @"event_data_overrides": @{attributeName: [NSNull null]}}];
}

+ (void)deleteAttributes:(NSArray *)attributes {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *s in attributes) {
        [dict setObject:[NSNull null] forKey:s];
    }
    
    [WEXAnalytics trackEventWithName:[@"we_" stringByAppendingString:WEG_EVENT_NAME_USER_DELETE_ATTRS]
                            andValue:@{ @"event_data_overrides": dict }];
}

+ (void)setEmail:(NSString *)email {
    [self setSystemAttribute:@"email" withValue:email];
}

+ (void)setHashedEmail:(NSString *)hashedEmail {
    [self setSystemAttribute:@"hashed_email" withValue:hashedEmail];
}

+ (void)setPhone:(NSString *)phone {
    [self setSystemAttribute:@"phone" withValue:phone];
}

+ (void)setHashedPhone:(NSString *)hashedPhone {
    [self setSystemAttribute:@"hashed_phone" withValue:hashedPhone];
}

+ (void)setBirthDate:(NSDate *)dob {
    [self setSystemAttribute:@"birth_date" withValue:dob];
}

+ (void)setBirthDateString:(NSString *)dobString {
    
    NSDate *date = [[WEXCoreUtils getDateFormatter] dateFromString:dobString];
    if (date) {
        [self setSystemAttribute:@"birth_date" withValue:date];
    } else {
        NSLog(@"Incorrect date format in setBirthDateString. Should be yyyy-MM-dd");
    }
}

+ (void)setGender:(NSString *)gender {
    [self setSystemAttribute:@"gender" withValue:gender];
}

+ (void)setFirstName:(NSString *)name {
    
    [self setSystemAttribute:@"first_name" withValue:name];
}

+ (void)setLastName:(NSString *)name {
    [self setSystemAttribute:@"last_name" withValue:name];
}

+ (void)setCompany:(NSString *)company {
    [self setSystemAttribute:@"company" withValue:company];
}

+ (void)setOptInStatusForChannel:(WEGEngagementChannel)channel
                          status:(BOOL)statusValue {
    
    NSString *attrName = nil;
    
    switch (channel) {
        case WEXEngagementChannelPush:
            attrName = @"push_opt_in";
            break;
        case WEXEngagementChannelInApp:
            attrName = @"inapp_opt_in";
            break;
        case WEXEngagementChannelEmail:
            attrName = @"email_opt_in";
            break;
        case WEXEngagementChannelSMS:
            attrName = @"sms_opt_in";
            break;
    }
    
    if (attrName) {
        [self setSystemAttribute:attrName withValue:[NSNumber numberWithBool:statusValue]];
    }
}

+ (void)setSystemAttribute:(NSString *)attributeName withValue:(id)value {
    
    if (value) {
        [WEXAnalytics trackEventWithName:[@"we_" stringByAppendingString:WEG_EVENT_NAME_USER_UPDATE]
                                andValue:@{ @"system_data_overrides": @{ attributeName: value }}];
    } else {
        NSLog(@"Invalid Value(nil) for System Attribute `%@`", attributeName);
    }
}

@end
