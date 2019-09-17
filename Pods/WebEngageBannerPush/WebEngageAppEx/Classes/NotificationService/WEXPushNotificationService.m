//
//  WEXPushNotificationService.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import "WEXPushNotificationService.h"


@interface WEXPushNotificationService ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property (nonatomic) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic) UNMutableNotificationContent *bestAttemptContent;
#endif

@end


@implementation WEXPushNotificationService

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000


#pragma mark - Service Extension Delegates

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request
                   withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler {
    
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSLog(@"Push Notification content: %@", request.content.userInfo);
    
    NSDictionary *expandableDetails = request.content.userInfo[@"expandableDetails"];
    
    NSString *style = expandableDetails[@"style"];
    
    if (expandableDetails && style && [style isEqualToString:@"CAROUSEL_V1"]) {
        
        [self drawCarouselViewWith:expandableDetails[@"items"]];
    }
    else if (expandableDetails && style &&
             ([style isEqualToString:@"RATING_V1"] || [style isEqualToString:@"BIG_PICTURE"])) {
        
        [self drawBannerViewWith:expandableDetails[@"image"]];
    }
    else {
        [self trackEventWithCompletion:^{
            self.contentHandler(self.bestAttemptContent);
        }];
    }
}

- (void)serviceExtensionTimeWillExpire {
    NSLog(@"%@", @(__FUNCTION__));
    self.contentHandler(self.bestAttemptContent);
}


#pragma mark - Rich Push View Helpers

- (void)drawCarouselViewWith:(NSArray *)items {
    
    NSMutableArray *attachmentsArray = [[NSMutableArray alloc] initWithCapacity:items.count];
    
    if (items.count >= 3) {
        
        NSUInteger itemCounter = 0;
        NSUInteger __block imageDownloadAttemptCounter = 0;
        
        for (NSDictionary *carouselItem in items) {
            
            NSString *imageURL = carouselItem[@"image"];
            
            [self fetchAttachmentFor:imageURL
                                  at:itemCounter
                   completionHandler:^(UNNotificationAttachment *attachment, NSUInteger index) {
                       
                       imageDownloadAttemptCounter++;
                       
                       if (attachment) {
                           NSLog(@"Downloaded Attachment No. %ld", (unsigned long)index);
                           [attachmentsArray addObject:attachment];
                           self.bestAttemptContent.attachments = attachmentsArray;
                       }
                       
                       if (imageDownloadAttemptCounter == items.count) {
                           
                           [self trackEventWithCompletion:^{
                               NSLog(@"Ending WebEngage Rich Push Service");
                               self.contentHandler(self.bestAttemptContent);
                           }];
                       }
                   }];
            itemCounter++;
        }
    }
}

- (void)drawBannerViewWith:(NSString *)urlStr {
    
    [self fetchAttachmentFor:urlStr
                          at:0
           completionHandler:^(UNNotificationAttachment *attachment, NSUInteger index) {
               
               if (attachment) {
                   NSLog(@"WebEngage Downloaded Image for Rating Layout");
                   self.bestAttemptContent.attachments = @[ attachment ];
               }
               
               [self trackEventWithCompletion:^{
                   self.contentHandler(self.bestAttemptContent);
               }];
           }];
}

- (void)fetchAttachmentFor:(NSString *)urlString
                        at:(NSUInteger)index
         completionHandler:(void (^)(UNNotificationAttachment *, NSUInteger))completionHandler {
    
    NSString *fileExt = [@"." stringByAppendingString:urlString.pathExtension];
    
    [[[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:urlString]
                                     completionHandler:^(NSURL *temporaryFileLocation,  NSURLResponse *response, NSError *error) {
                                         
         UNNotificationAttachment *attachment = nil;
         
         if (error != nil) {
             NSLog(@"%@", error);
         } else {
             
             NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
             
             NSError *moveError;
             [[NSFileManager defaultManager] moveItemAtURL:temporaryFileLocation
                                                     toURL:localURL
                                                     error:&moveError];
             
             if (moveError) {
                 NSLog(@"File Move Error: %@", moveError);
             }
             
             NSError *attachmentError;
             
             attachment = [UNNotificationAttachment attachmentWithIdentifier:[NSString stringWithFormat:@"%ld",(unsigned long)index] URL:localURL options:nil error:&attachmentError];
             
             if (attachmentError) {
                 NSLog(@"%@", attachmentError);
             }
         }
         
         NSLog(@"Sending Callback");
         
         completionHandler(attachment, index);
         
     }] resume];
}


#pragma mark - Tracker Event Helpers

- (void)trackEventWithCompletion:(void(^)(void))completion {
    
    NSURLRequest *request = [self getRequestForTracker];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Could not log push_notification_view event with error: %@", error);
        }
        else {
            NSLog(@"Push Tracker URLResponse: %@", response);
        }

        if (completion) {
            completion();
        }
    }] resume];
}

- (NSURLRequest *)getRequestForTracker {
    
    NSURL *url = [NSURL URLWithString:@"https://c.webengage.com/tracker"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/transit+json" forHTTPHeaderField:@"Content-type"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    request.HTTPBody = [self getTrackerRequestBody];
    
    return request;
}

- (NSData *)getTrackerRequestBody {
    
    NSDictionary *userDefaultsData = [self getDataFromSharedUserDefaults];
    
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    
    body[@"event_name"] = @"push_notification_view";
    body[@"category"] = @"system";
    body[@"suid"] = @"null";
    body[@"luid"] = @"null";
    body[@"cuid"] = @"null";
    body[@"event_time"] = [self getCurrentFormattedTime];
    body[@"license_code"] = userDefaultsData[@"license_code"];
    body[@"interface_id"] = userDefaultsData[@"interface_id"];
    body[@"event_data"] = @{};
    
    NSMutableDictionary *systemData = [NSMutableDictionary dictionary];
    systemData[@"sdk_id"] = @(3);
    systemData[@"sdk_version"] = userDefaultsData[@"sdk_version"];
    systemData[@"app_id"] = userDefaultsData[@"app_id"];
    systemData[@"experiment_id"] = self.bestAttemptContent.userInfo[@"experiment_id"];
    systemData[@"id"] = self.bestAttemptContent.userInfo[@"notification_id"];
    
    body[@"system_data"] = systemData;
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        NSLog(@"Error in converting data: %@", error);
    }
    
    return data;
}

- (NSString *)getCurrentFormattedTime {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"'~t'yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"gb"];
    return [formatter stringFromDate:[NSDate date]];
}

- (NSDictionary<NSString *, NSString *> *)getDataFromSharedUserDefaults {
    
    NSUserDefaults *defaults = [self getSharedUserDefaults];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    data[@"license_code"] = [defaults objectForKey:@"license_code"];
    data[@"interface_id"] = [defaults objectForKey:@"interface_id"];
    data[@"sdk_version"] = [defaults objectForKey:@"sdk_version"];
    data[@"app_id"] = [defaults objectForKey:@"app_id"];
    
    return data;
}

- (NSUserDefaults *)getSharedUserDefaults {
    
    NSString *appGroup = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"WEX_APP_GROUP"];
    
    if (!appGroup) {
        NSBundle *bundle = [NSBundle mainBundle];
        
        if ([[bundle.bundleURL pathExtension] isEqualToString:@"appex"]) {
            bundle = [NSBundle bundleWithURL:[[bundle.bundleURL URLByDeletingLastPathComponent] URLByDeletingLastPathComponent]];
        }
        
        NSString *bundleIdentifier = [bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        
        appGroup = [NSString stringWithFormat:@"group.%@.WEGNotificationGroup", bundleIdentifier];
    }
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:appGroup];
    
    if (!defaults) {
        NSLog(@"Shared User Defaults could not be initialized. Ensure Shared App Groups have been enabled on Main App & Notification Service Extension Targets.");
    }
    
    return defaults;
}

#endif

@end
