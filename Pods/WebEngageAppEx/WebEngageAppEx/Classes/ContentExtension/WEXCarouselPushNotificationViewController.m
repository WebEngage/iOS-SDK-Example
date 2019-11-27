//
//  WEXCarouselPushNotificationViewController.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import "WEXCarouselPushNotificationViewController.h"
#import "WEXRichPushNotificationViewController+Private.h"

#define CONTENT_PADDING  10
#define TITLE_BODY_SPACE 5

API_AVAILABLE(ios(10.0))
@interface WEXCarouselPushNotificationViewController ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

@property (nonatomic) NSInteger current;

@property (nonatomic) NSMutableArray *images;
@property (nonatomic) NSMutableArray *wasLoaded;
@property (nonatomic) NSMutableArray *carouselItems;
@property (nonatomic) NSMutableArray *viewContainers;
@property (nonatomic) NSMutableArray *imageViews;
@property (nonatomic) NSMutableArray *descriptionViews;
@property (nonatomic) NSMutableArray *descriptionLabels;
@property (nonatomic) NSMutableArray *alphaViews;

@property (nonatomic) UNNotification *notification;

@property (nonatomic) UIImage *errorImage;
@property (nonatomic) UIImage *loadingImage;

@property (nonatomic) NSUserDefaults *richPushDefaults;

@property (atomic) NSInteger nextViewIndexToReturn;
@property (atomic) BOOL isRendering;

#endif

@end

@implementation WEXCarouselPushNotificationViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

- (void)didReceiveNotification:(UNNotification *)notification API_AVAILABLE(ios(10.0)) {
    
    self.isRendering = YES;
    self.notification = notification;
    self.current = 0;
    
    NSDictionary *expandedDetails = notification.request.content.userInfo[@"expandableDetails"];
    
    self.carouselItems = expandedDetails[@"items"];
    
    if (self.carouselItems && self.carouselItems.count > 0) {
        
        self.images = [[NSMutableArray alloc] initWithCapacity:self.carouselItems.count];
        self.wasLoaded = [[NSMutableArray alloc] initWithCapacity:self.carouselItems.count];
        
        NSInteger downloadedCount = notification.request.content.attachments ? notification.request.content.attachments.count : 0;
        
        [self setCTAForIndex:0];
        
        BOOL firstImageAdded = NO;
        
        if (downloadedCount == 0) {
            
            // Don't save the file here instead add to images directly.
            // Also handle the events for the same accordingly.
            // wasLoaded, viewEventForIndex and addToImages
            
            NSString *imageURL = self.carouselItems[0][@"image"];
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            
            UIImage *image = [UIImage imageWithData:imageData];
            
            if (image) {
                [self.images addObject:image];
                [self.wasLoaded addObject:[NSNumber numberWithBool:YES]];
                
                [self addViewEventForIndex:0 isFirst:YES];
            } else {
                [self.images addObject:[self getErrorImage]];
                [self.wasLoaded addObject:[NSNumber numberWithBool:NO]];
            }
            
            firstImageAdded = YES;
            downloadedCount = 1;
        }
        
        // After the change of adding the first image directly above this loop
        // should start from 1 only
        for (NSUInteger i = firstImageAdded ? 1 : 0; i < self.carouselItems.count; i++) {
            
            [self.wasLoaded addObject:[NSNumber numberWithBool:NO]];
            
            if (i < downloadedCount) {
                
                // This if condition means that this file was downloaded and saved
                // earlier.
                // So retrieve the saved file
                // and add to the UI.
                
                BOOL addedSuccessfully = NO;
                if (@available(iOS 10.0, *)) {
                    UNNotificationAttachment __block *attachmentValue = nil;
                    [notification.request.content.attachments enumerateObjectsUsingBlock:^(UNNotificationAttachment *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                        
                         if ([obj.identifier isEqualToString:[NSString stringWithFormat:@"%ld", (unsigned long)i]]) {
                             attachmentValue = obj;
                             *stop = YES;
                         }
                     }];
                    
                    if (attachmentValue) {
                        
                        UNNotificationAttachment *attachment = attachmentValue;
                        
                        if ([attachment.URL startAccessingSecurityScopedResource]) {
                            
                            NSData *imageData = [NSData dataWithContentsOfFile:attachment.URL.path];
                            UIImage *image = [UIImage imageWithData:imageData];
                            
                            [attachment.URL stopAccessingSecurityScopedResource];
                            
                            if (image) {
                                
                                addedSuccessfully = YES;
                                [self.images addObject:image];
                                self.wasLoaded[i] = [NSNumber numberWithBool:YES];
                                
                                if (i == 0) {
                                    [self addViewEventForIndex:0 isFirst:YES];
                                }
                            }
                        }
                    }
                    
                    if (!addedSuccessfully) {
                        [self.images addObject:[self getErrorImage]];
                    }
                } else {
                    NSLog(@"Expected to be running iOS version 10 or above");
                }
            } else {
                [self.images addObject:[self getLoadingImage]];
            }
        }
        
        [self initialiseCarouselForNotification:notification];
        
        if (downloadedCount < self.carouselItems.count) {
            
            [self downloadRemaining:downloadedCount];
        }
    }
}

- (void)downloadRemaining:(NSUInteger)downloadFromIndex {
    
    for (NSUInteger i = downloadFromIndex; i < self.carouselItems.count; i++) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *imageURL = self.carouselItems[i][@"image"];
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            
            UIImage *image = [UIImage imageWithData:imageData];
            
            if (image) {
                self.images[i] = image;
                self.wasLoaded[i] = [NSNumber numberWithBool:YES];
            } else {
                self.images[i] = [self getErrorImage];
                self.wasLoaded[i] = [NSNumber numberWithBool:NO];
            }
        });
    }
}

- (void)initialiseCarouselForNotification:(UNNotification *)notification API_AVAILABLE(ios(10.0)) {
    
    [self initialiseViewContainers];
    
    float mainViewToSuperViewWidthRatio = MAIN_VIEW_TO_SUPER_VIEW_WIDTH_RATIO;
    float verticalMargins = MAIN_VIEW_TO_SUPER_VIEW_VERTICAL_MARGINS;
    
    float superViewWidth = self.view.frame.size.width;
    
    float viewWidth = superViewWidth * mainViewToSuperViewWidthRatio - 2 * verticalMargins;
    float viewHeight = viewWidth;
    
    // for portrait
    float superViewHeight = viewHeight + 2 * verticalMargins;
    
    NSString *mode = notification.request.content.userInfo[@"expandableDetails"][@"mode"];
    
    BOOL isPortrait = mode && [mode isEqualToString:@"portrait"];
    
    if (!isPortrait) {
        
        viewWidth = superViewWidth;
        
        viewHeight = viewWidth * LANDSCAPE_ASPECT;
        
        superViewHeight = viewHeight;
    }
    
    NSUInteger count = self.carouselItems.count;
    NSInteger current = self.current;
    NSInteger previous = (current + count - 1) % count;
    NSInteger next = (current + 1) % count;
    NSInteger nextRight = (current + 2) % count;
    
    UIView *previousView = [self viewAtPosition:previous];
    previousView.frame = [self frameForViewPosition:WEXLeft];
    
    UIView *currentView = [self viewAtPosition:current];
    currentView.frame = [self frameForViewPosition:WEXCurrent];
    
    UIView *nextView = [self viewAtPosition:next];
    nextView.frame = [self frameForViewPosition:WEXRight];
    
    UIView *nextRightView = [self viewAtPosition:nextRight];
    nextRightView.frame = [self frameForViewPosition:WEXNextRight];
    
    [self.view addSubview:previousView];
    [self.view addSubview:currentView];
    [self.view addSubview:nextView];
    [self.view addSubview:nextRightView];
    
    if (isPortrait) {
        
        previousView.subviews[2].alpha = SIDE_VIEWS_FADE_ALPHA;
        nextView.subviews[2].alpha = SIDE_VIEWS_FADE_ALPHA;
    }
    
    UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, superViewWidth, 0.5)];
    topSeparator.backgroundColor = [UIColor lightGrayColor];
    
    UIView *bottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0, superViewHeight - 0.5, superViewWidth, 0.5)];
    bottomSeparator.backgroundColor = [UIColor lightGrayColor];
    
    NSDictionary *extensionAttributes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSExtension"][@"NSExtensionAttributes"];
    
    BOOL defaultContentHidden = [extensionAttributes ? extensionAttributes[ @"UNNotificationExtensionDefaultContentHidden" ] : @(0) boolValue];
    
    [self.view addSubview:topSeparator];
    [self.view addSubview:bottomSeparator];
    
    if (defaultContentHidden) {
        
        // Add a notification content view for displaying title and body.
        UIView *notificationContentView = [[UIView alloc] init];
        notificationContentView.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = notification.request.content.title;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        titleLabel.textAlignment = [self.viewController naturalTextAligmentForText:titleLabel.text];
        
        UILabel *bodyLabel = [[UILabel alloc] init];
        bodyLabel.text = notification.request.content.body;
        bodyLabel.textColor = [UIColor blackColor];
        bodyLabel.textAlignment = [self.viewController naturalTextAligmentForText:bodyLabel.text];
        bodyLabel.numberOfLines = 0;
        
        [notificationContentView addSubview:titleLabel];
        [notificationContentView addSubview:bodyLabel];
        
        [self.view addSubview:notificationContentView];
        
        notificationContentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (@available(iOS 10.0, *)) {
            [notificationContentView.leadingAnchor
             constraintEqualToAnchor:self.view.leadingAnchor]
            .active = YES;
            
            [notificationContentView.trailingAnchor
             constraintEqualToAnchor:self.view.trailingAnchor]
            .active = YES;
            [notificationContentView.topAnchor
             constraintEqualToAnchor:bottomSeparator.bottomAnchor]
            .active = YES;
            [notificationContentView.bottomAnchor
             constraintEqualToAnchor:self.viewController.bottomLayoutGuide.topAnchor]
            .active = YES;
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [titleLabel.leadingAnchor
             constraintEqualToAnchor:notificationContentView.leadingAnchor
             constant:CONTENT_PADDING]
            .active = YES;
            [titleLabel.trailingAnchor
             constraintEqualToAnchor:notificationContentView.trailingAnchor
             constant:0 - CONTENT_PADDING]
            .active = YES;
            [titleLabel.topAnchor
             constraintEqualToAnchor:notificationContentView.topAnchor
             constant:CONTENT_PADDING]
            .active = YES;
            
            bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [bodyLabel.leadingAnchor
             constraintEqualToAnchor:notificationContentView.leadingAnchor
             constant:CONTENT_PADDING]
            .active = YES;
            [bodyLabel.trailingAnchor
             constraintEqualToAnchor:notificationContentView.trailingAnchor
             constant:0 - CONTENT_PADDING]
            .active = YES;
            [bodyLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor
                                                constant:TITLE_BODY_SPACE]
            .active = YES;
            [bodyLabel.bottomAnchor
             constraintEqualToAnchor:notificationContentView.bottomAnchor
             constant:0 - CONTENT_PADDING]
            .active = YES;
        } else {
            NSLog(@"Expected to be running iOS version 10 or above");
        }
        
    } else {
        
        self.viewController.preferredContentSize =
        CGSizeMake(superViewWidth, self.view.bounds.size.height);
        
        NSString *logMessage = [
                                [@"The `UNNotificationExtensionDefaultContentHidden` flag in your "
                                 @"Info.plist file is either not set or set to NO. "
                                 stringByAppendingString:@"Since v3.4.17 of WebEngage SDK, this "
                                 @"flag MUST be set to YES, failing which "
                                 @"other layouts(Rating etc) will not "
                                 @"render properly."]
                                stringByAppendingString:@"Refer "
                                @"http://docs.webengage.com/docs/"
                                @"ios-10-rich-push-notifications-integration"];
        
        NSLog(@"%@", logMessage);
    }
    
    self.isRendering = NO;
}

- (void)initialiseViewContainers {
    
    self.viewContainers = [[NSMutableArray alloc] initWithCapacity:4];
    self.imageViews = [[NSMutableArray alloc] initWithCapacity:4];
    self.descriptionViews = [[NSMutableArray alloc] initWithCapacity:4];
    self.descriptionLabels = [[NSMutableArray alloc] initWithCapacity:4];
    self.alphaViews = [[NSMutableArray alloc] initWithCapacity:4];
    
    for (NSUInteger i = 0; i < 4; i++) {
        
        UIView *view = [[UIView alloc] init];
        view.accessibilityIdentifier =
        [NSString stringWithFormat:@"view-%lu", (unsigned long)i];
        self.viewContainers[i] = view;
        
        self.imageViews[i] = [[UIImageView alloc] init];
        self.descriptionViews[i] = [[UIView alloc] init];
        self.descriptionLabels[i] = [[UILabel alloc] init];
        self.alphaViews[i] = [[UIView alloc] init];
    }
    
    self.nextViewIndexToReturn = 0;
}

- (CGSize)getImageFrameSize {
    
    float mainViewToSuperViewWidthRatio = MAIN_VIEW_TO_SUPER_VIEW_WIDTH_RATIO;
    float verticalMargins = MAIN_VIEW_TO_SUPER_VIEW_VERTICAL_MARGINS;
    
    float superViewWidth = self.view.frame.size.width;
    
    float viewWidth, viewHeight;
    
    NSString *mode = self.notification.request.content.userInfo[@"expandableDetails"][@"mode"];
    BOOL isPortrait = mode && [mode isEqualToString:@"portrait"];
    
    if (isPortrait) {
        
        viewWidth =
        superViewWidth * mainViewToSuperViewWidthRatio - 2 * verticalMargins;
        viewHeight = viewWidth;
        
    } else {
        
        viewWidth = superViewWidth;
        viewHeight = viewWidth * LANDSCAPE_ASPECT;
    }
    
    return CGSizeMake(viewWidth, viewHeight);
}

- (void)renderAnimated:(UNNotification *)notification API_AVAILABLE(ios(10.0)) {
    
    NSString *mode = notification.request.content.userInfo[@"expandableDetails"][@"mode"];
    
    NSUInteger count = self.carouselItems.count;
    
    NSUInteger currentMain = self.current;
    
    NSUInteger currentLeft = (currentMain + count - 1) % count;
    NSUInteger currentRight = (currentMain + 1) % count;
    NSUInteger nextRight = (currentRight + 1) % count;
    
    self.isRendering = YES;
    
    UIView *currentLeftView = [self viewAtPosition:currentLeft];
    currentLeftView.frame = [self frameForViewPosition:WEXLeft];
    
    UIView *currentMainView = [self viewAtPosition:currentMain];
    currentMainView.frame = [self frameForViewPosition:WEXCurrent];
    
    UIView *currentRightView = [self viewAtPosition:currentRight];
    currentRightView.frame = [self frameForViewPosition:WEXRight];
    
    UIView *nextRightView = [self viewAtPosition:nextRight];
    nextRightView.frame = [self frameForViewPosition:WEXNextRight];
    
    BOOL isPortrait = [mode isEqualToString:@"portrait"];
    
    CGFloat slideBy = 0.0;
    
    if (isPortrait) {
        slideBy = currentMainView.frame.size.width + INTER_VIEW_MARGINS;
        nextRightView.subviews[2].alpha = 0.0;
    } else {
        slideBy = currentMainView.frame.size.width;
    }
    
    [UIView animateWithDuration:SLIDE_ANIMATION_DURATION
                     animations:^{
                         
                         [self slideLeft:currentLeftView By:slideBy];
                         [self slideLeft:currentMainView By:slideBy];
                         [self slideLeft:currentRightView By:slideBy];
                         
                         if (isPortrait) {
                             
                             [self slideLeft:nextRightView By:slideBy];
                             
                             currentMainView.subviews[2].alpha = SIDE_VIEWS_FADE_ALPHA;
                             
                             currentRightView.subviews[2].alpha = 0.0;
                             
                             nextRightView.subviews[2].alpha = SIDE_VIEWS_FADE_ALPHA;
                         }
                     }
                     completion:^(BOOL finished) {
                         
                         self.current = (self.current + 1) % count;
                         self.isRendering = NO;
                         
                         // Add the browsed index, irrespective of image-loading success/failure
                         //[self writeObject:currentIndex withKey: @"last_browsed_index"];
                         [self setCTAForIndex:self.current];
                         
                         // Add the viewed index only if the image was viewed.
                         if ([self.wasLoaded[self.current] boolValue] == YES) {
                             
                             [self addViewEventForIndex:self.current];
                         }
                     }];
}

- (NSMutableDictionary *)getActivityDictionaryForCurrentNotification {
    
    return [(WEXRichPushNotificationViewController *)
            self.viewController getActivityDictionaryForCurrentNotification];
}

- (void)writeObject:(id)object withKey:(NSString *)key {
    
    [(WEXRichPushNotificationViewController *)self.viewController
     updateActivityWithObject:object
     forKey:key];
}

- (void)slideLeft:(UIView *)view By:(CGFloat)slide {
    
    CGRect initialFrame = view.frame;
    
    CGRect finalFrame =
    CGRectMake(initialFrame.origin.x - slide, initialFrame.origin.y,
               initialFrame.size.width, initialFrame.size.height);
    
    view.frame = finalFrame;
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response
                     completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion API_AVAILABLE(ios(10.0)) {
    
    BOOL dismissed = NO;
    
    if (self.isRendering) {
        return;
    }
    
    if ([response.actionIdentifier isEqualToString:@"WEG_NEXT"]) {
        
        [self renderAnimated:response.notification];
        
    } else if ([response.actionIdentifier isEqualToString:@"WEG_PREV"]) {
        
    } else if ([response.actionIdentifier isEqualToString:@"WEG_LAUNCH_APP"]) {
        
        if (@available(iOS 10.0, *)) {
            completion(UNNotificationContentExtensionResponseOptionDismissAndForwardAction);
        } else {
            NSLog(@"Expected to be running iOS version 10 or above");
        }
        return;
        
    } else {
        
        dismissed = YES;
    }
    
    if (dismissed) {
        
        [self writeObject:[NSNumber numberWithBool:YES] withKey:@"closed"];
        if (@available(iOS 10.0, *)) {
            completion(UNNotificationContentExtensionResponseOptionDismiss);
        } else {
            NSLog(@"Expected to be running iOS version 10 or above");
        }
        
    } else {
        
        if (@available(iOS 10.0, *)) {
            completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
        } else {
            NSLog(@"Expected to be running iOS version 10 or above");
        }
    }
}

- (UIView *)viewAtPosition:(NSInteger)index {
    
    NSInteger cachedViewIndex = [self cachedViewsIndexForViewAtIndex:index];
    
    UIView *viewToReturn = self.viewContainers[cachedViewIndex];
    
    float mainViewToSuperViewWidthRatio = MAIN_VIEW_TO_SUPER_VIEW_WIDTH_RATIO;
    float verticalMargins = MAIN_VIEW_TO_SUPER_VIEW_VERTICAL_MARGINS;
    
    float superViewWidth = self.view.frame.size.width;
    
    float viewWidth =
    superViewWidth * mainViewToSuperViewWidthRatio - 2 * verticalMargins;
    float viewHeight = viewWidth;
    
    float descriptionViewHeight = DESCRIPTION_VIEW_HEIGHT;
    
    NSString *mode =
    self.notification.request.content.userInfo[@"expandableDetails"][@"mode"];
    BOOL isPortrait = mode && [mode isEqualToString:@"portrait"];
    
    if (!isPortrait) {
        viewWidth = superViewWidth;
        viewHeight = viewWidth * LANDSCAPE_ASPECT;
    }
    
    NSDictionary *carouselItem = self.carouselItems[index];
    
    UIView *viewContainer = viewToReturn;
    UIImage *image = self.images[index];
    
    viewContainer.backgroundColor = [UIColor lightGrayColor];
    
    UIImageView *imageView = self.imageViews[cachedViewIndex];
    imageView.frame = CGRectMake(0.0, 0.0, viewWidth, viewHeight);
    
    if (![image isKindOfClass:[NSNull class]]) {
        imageView.image = image;
    } else {
        // add some default image;
    }
    
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIView *descriptionView = self.descriptionViews[cachedViewIndex];
    descriptionView.frame = CGRectMake(0, viewHeight - descriptionViewHeight,
                                       viewWidth, descriptionViewHeight);
    
    descriptionView.alpha = DESCRIPTION_VIEW_ALPHA;
    descriptionView.backgroundColor = [UIColor whiteColor];
    
    UILabel *descriptionLabel = self.descriptionLabels[cachedViewIndex];
    descriptionLabel.frame =
    CGRectMake(10.0, 10.0, descriptionView.frame.size.width - 10.0,
               descriptionView.frame.size.height - 10.0);
    
    descriptionLabel.text = carouselItem[@"actionText"];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.textColor = [UIColor blackColor];
    
    [descriptionView addSubview:descriptionLabel];
    
    [viewContainer addSubview:imageView];
    [viewContainer addSubview:descriptionView];
    
    if (isPortrait) {
        
        [viewContainer.layer setCornerRadius:8.0f];
        viewContainer.clipsToBounds = YES;
        
        UIView *alphaView = self.alphaViews[cachedViewIndex];
        alphaView.frame = CGRectMake(0.0, 0.0, viewWidth, viewHeight);
        alphaView.alpha = 0.0;
        alphaView.backgroundColor = [UIColor whiteColor];
        
        [viewContainer addSubview:alphaView];
    }
    
    return viewContainer;
}

- (NSInteger)cachedViewsIndexForViewAtIndex:(NSInteger)index {
    
    NSUInteger returnIndex = self.nextViewIndexToReturn;
    self.nextViewIndexToReturn = (self.nextViewIndexToReturn + 1) % self.viewContainers.count;
    return returnIndex;
}

- (CGRect)frameForViewPosition:(WEXCarouselFrameLocation)frameLocation {
    
    float mainViewToSuperViewWidthRatio = MAIN_VIEW_TO_SUPER_VIEW_WIDTH_RATIO;
    float verticalMargins = MAIN_VIEW_TO_SUPER_VIEW_VERTICAL_MARGINS;
    float interViewMargins = INTER_VIEW_MARGINS;
    
    float superViewWidth = self.view.frame.size.width;
    
    float viewWidth =
    superViewWidth * mainViewToSuperViewWidthRatio - 2 * verticalMargins;
    float viewHeight = viewWidth;
    
    float currentViewX =
    (1.0 - mainViewToSuperViewWidthRatio) / 2.0 * superViewWidth;
    float currentViewY = verticalMargins;
    
    NSString *mode = self.notification.request.content.userInfo[@"expandableDetails"][@"mode"];
    BOOL isPortrait = mode && [mode isEqualToString:@"portrait"];
    
    if (!isPortrait) {
        
        viewWidth = superViewWidth;
        
        viewHeight = viewWidth * LANDSCAPE_ASPECT;
        
        currentViewX = 0.0;
        currentViewY = 0.0;
        interViewMargins = 0.0;
    }
    
    return CGRectMake(currentViewX + frameLocation * interViewMargins +
                      frameLocation * viewWidth,
                      currentViewY, viewWidth, viewHeight);
}

- (void)addViewEventForIndex:(NSInteger)index {
    [self addViewEventForIndex:index isFirst:NO];
}

- (void)addViewEventForIndex:(NSInteger)index isFirst:(BOOL)first {
    
    NSDictionary *userInfo = self.notification.request.content.userInfo;
    NSArray *items = self.notification.request.content.userInfo[@"expandableDetails"][@"items"];
    NSInteger count = items.count;
    
    NSString *expId = userInfo[@"experiment_id"];
    NSString *notifId = userInfo[@"notification_id"];
    
    NSString *callToAction = items[index][@"id"];
    
    // This is temporary on assumption that only right move is there and no faulty
    // image replacements
    NSString *ctaIdPrev =
    first ? @"UNKNOWN" : items[(index + count - 1) % count][@"id"];
    
    [((WEXRichPushNotificationViewController *)self.viewController)
     addSystemEventWithName:WEX_EVENT_NAME_PUSH_NOTIFICATION_ITEM_VIEW
     systemData:@{
                  @"id" : notifId,
                  @"experiment_id" : expId,
                  @"call_to_action" : callToAction,
                  @"navigated_from" : ctaIdPrev
                  }
     applicationData:nil];
}

- (void)setCTAForIndex:(NSInteger)index {
    
    NSArray *items = self.notification.request.content.userInfo[@"expandableDetails"][@"items"];
    
    if (items) {
        
        NSString *ctaId = items[index][@"id"];
        NSString *actionLink = items[index][@"actionLink"];
        
        [((WEXRichPushNotificationViewController *)self.viewController)
         setCTAWithId:ctaId
         andLink:actionLink];
    }
}

- (UIImage *)getLoadingImage {
    
    if (!self.loadingImage) {
        
        CGSize size = [self getImageFrameSize];
        CGFloat width = size.width;
        CGFloat height = size.height;
        CGPoint center = CGPointMake(width / 2.0, height / 2.0);
        
        CGFloat holeWidth = 16.0;
        CGFloat topBottomBarExtra = 10.0;
        
        CGFloat margins = 20.0;
        
        UIGraphicsBeginImageContext(size);
        
        self.loadingImage = [[UIImage alloc] init];
        [self.loadingImage drawInRect:CGRectMake(0, 0, width, height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.5, 0.5, 0.5,
                                   1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
        
        // Top Bar
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(),
                             center.x - holeWidth / 2.0 -
                             (height - 2 * margins) / 6.0 - topBottomBarExtra,
                             margins);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),
                                center.x + holeWidth / 2.0 +
                                (height - 2 * margins) / 6.0 +
                                topBottomBarExtra,
                                margins);
        
        // Left Part
        CGContextMoveToPoint(
                             UIGraphicsGetCurrentContext(),
                             center.x - holeWidth / 2.0 - (height - 2 * margins) / 6.0, margins);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),
                                center.x - holeWidth / 2.0 -
                                (height - 2 * margins) / 6.0,
                                (height - 2 * margins) / 3.0 + margins);
        
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),
                                center.x - holeWidth / 2.0, center.y);
        
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),
                                center.x - holeWidth / 2.0 -
                                (height - 2 * margins) / 6.0,
                                center.y + (height - 2 * margins) / 6.0);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),
                                center.x - holeWidth / 2.0 -
                                (height - 2 * margins) / 6.0,
                                height - margins);
        
        // Right Part
        CGContextMoveToPoint(
                             UIGraphicsGetCurrentContext(),
                             center.x + holeWidth / 2.0 + (height - 2 * margins) / 6.0, margins);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),
                                center.x + holeWidth / 2.0 +
                                (height - 2 * margins) / 6.0,
                                (height - 2 * margins) / 3.0 + margins);
        
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),
                                center.x + holeWidth / 2.0, center.y);
        
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),
                                center.x + holeWidth / 2.0 +
                                (height - 2 * margins) / 6.0,
                                center.y + (height - 2 * margins) / 6.0);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),
                                center.x + holeWidth / 2.0 +
                                (height - 2 * margins) / 6.0,
                                height - margins);
        
        // BottomBar
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(),
                             center.x - holeWidth / 2.0 -
                             (height - 2 * margins) / 6.0 - topBottomBarExtra,
                             height - margins);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),
                                center.x + holeWidth / 2.0 +
                                (height - 2 * margins) / 6.0 +
                                topBottomBarExtra,
                                height - margins);
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.loadingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIGraphicsBeginImageContext(size);
        [self.loadingImage drawInRect:CGRectMake(0, 0, width, height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.5, 0.5, 0.5,
                                   1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
        
        CGFloat dx = 8.0;
        CGFloat dy = 8.0;
        
        for (NSInteger i = 1; i <= 4; i++) {
            
            NSInteger mid = (i + 1) / 2;
            CGFloat x;
            CGFloat yTop = center.y - i * dy;
            CGFloat yBottom = center.y + i * dy;
            
            for (NSInteger j = 1; j <= i; j++) {
                
                if (i % 2 == 0) {
                    x = center.x - ((mid - j) * dx + dx / 2.0);
                    
                } else {
                    x = (center.x - (mid - j) * dx);
                }
                
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), x, yTop);
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x, yTop);
                
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), x, yBottom);
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x, yBottom);
            }
        }
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.loadingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return self.loadingImage;
}

- (UIImage *)getErrorImage {
    
    CGSize size = [self getImageFrameSize];
    
    if (!self.errorImage) {
        
        CGFloat width = size.width;
        CGFloat height = size.height;
        CGPoint startPoint = CGPointMake(width / 2.0, height / 4.0);
        CGPoint rightPoint =
        CGPointMake(width / 2.0 + height / 3.464, 0.75 * height);
        CGPoint leftPoint =
        CGPointMake(width / 2.0 - height / 3.464, 0.75 * height);
        
        UIGraphicsBeginImageContext(size);
        
        self.errorImage = [[UIImage alloc] init];
        [self.errorImage drawInRect:CGRectMake(0, 0, width, height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.5, 0.5, 0.5,
                                   1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
        
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), startPoint.x,
                             startPoint.y);
        
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), leftPoint.x,
                                leftPoint.y);
        
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), rightPoint.x,
                                rightPoint.y);
        
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), startPoint.x,
                                startPoint.y);
        
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), startPoint.x,
                             startPoint.y + 40);
        
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), startPoint.x,
                                rightPoint.y - 40);
        
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), startPoint.x,
                             rightPoint.y - 20);
        
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), startPoint.x,
                                rightPoint.y - 20);
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.errorImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    return self.errorImage;
}

#endif

@end
