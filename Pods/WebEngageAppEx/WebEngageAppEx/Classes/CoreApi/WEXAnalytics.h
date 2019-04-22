//
//  WEXAnalytics.h
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd.. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface WEXAnalytics : NSObject

+ (void)trackEventWithName:(NSString *)eventName andValue:(NSDictionary *)eventValue;

+ (void)trackEventWithName:(NSString *)eventName;

@end
