//
//  WEXRatingPushNotificationViewController.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import "WEXRatingPushNotificationViewController.h"

//#define NO_OF_STARS 5
#define STAR_BAR_HEIGHT 50
#define STAR_FONT_SIZE 30
#define WEX_RATING_SUBMITTED_EVENT_NAME @"push_notification_rating_submitted"
#define MAX_DESCRIPTION_LINE_COUNT 3
#define TEXT_PADDING 10

API_AVAILABLE(ios(10.0))
@interface StarPickerManager : NSObject
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
<UIPickerViewDataSource, UIPickerViewDelegate>


@property (nonatomic) UNNotification *notification;
@property (nonatomic) NSArray *starRatingRows;

#endif
@end


@implementation StarPickerManager

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

- (instancetype)initWithNotification:(UNNotification *)notification  API_AVAILABLE(ios(10.0)) {
    
    if (self = [super init]) {
        
        self.notification = notification;
        
        NSInteger noOfStars = [notification.request.content.userInfo[@"expandableDetails"][@"ratingScale"] integerValue];
        
        char starCharSelected[] = "\u2B50";
        NSData *data = [NSData dataWithBytes:starCharSelected length:strlen(starCharSelected)];
        NSString *selectedStarString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        char starCharUnselected[] = "\u2605";
        data = [NSData dataWithBytes:starCharUnselected length:strlen(starCharUnselected)];
        NSString *unselectedStarString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSMutableArray *pickerData = [[NSMutableArray alloc] initWithCapacity:noOfStars];
        
        for (NSUInteger i=1; i <= noOfStars; i++) {
            
            NSMutableString *starRowString = [[NSMutableString alloc] initWithCapacity:noOfStars];
            for (NSUInteger j=1; j<=i; j++) {
                [starRowString appendString:selectedStarString];
            }
            
            for (NSUInteger j=i+1; j <= noOfStars; j++) {
                [starRowString appendString:unselectedStarString];
            }
            
            [pickerData addObject:starRowString];
        }
        
        self.starRatingRows = pickerData;
    }
    
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
   
    return [self.notification.request.content.userInfo[@"expandableDetails"][@"ratingScale"] integerValue];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return pickerView.frame.size.width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50.0;// This may depend on a no of factors like font, etc which may again be a function of notification data
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.starRatingRows[row];
}

#endif

@end


API_AVAILABLE(ios(10.0))
@interface WEXRatingPushNotificationViewController ()
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic) UNNotification *notification;
@property (nonatomic) StarPickerManager *pickerManager;
@property (nonatomic) UILabel *selectedLabel;
@property (nonatomic) UILabel *unselectedLabel;
@property (nonatomic) UIView *labelsWrapper;

@property (nonatomic) NSInteger selectedCount;
@property (nonatomic) NSUInteger noOfStars;

#endif
@end


@implementation WEXRatingPushNotificationViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

- (void)initialiseViewHierarchy {
    
    self.view.backgroundColor = [UIColor yellowColor];
    
    UIView *superViewWrapper = [[UIView alloc] init];
    
    [self.view addSubview:superViewWrapper];
    
    UIView *mainContentView = [[UIView alloc] init];
    
    [superViewWrapper addSubview:mainContentView];
    
    NSDictionary *expandableDetails = self.notification.request.content.userInfo[@"expandableDetails"];
    
    BOOL backgroundImage = NO;
    if (expandableDetails[@"image"]) {
        
        if (self.notification.request.content.attachments
            && self.notification.request.content.attachments.count > 0) {
            
            if (@available(iOS 10.0, *)) {
                
                UNNotificationAttachment *attachment = self.notification.request.content.attachments.firstObject;
                
                if ([attachment.URL startAccessingSecurityScopedResource]) {
                    
                    NSData *imageData = [NSData dataWithContentsOfFile:attachment.URL.path];
                    UIImage *image = [UIImage imageWithData:imageData];
                    
                    [attachment.URL stopAccessingSecurityScopedResource];
                    
                    if (image) {
                        backgroundImage = YES;
                        UIImageView *imageView = [[UIImageView alloc] init];
                        imageView.image = image;
                        imageView.contentMode = UIViewContentModeScaleAspectFill;
                        [mainContentView addSubview:imageView];
                    }
                }
            } else {
                NSLog(@"Expected to be running iOS version 10 or above");
            }
        }
    }
    
    NSDictionary *content = expandableDetails[@"content"];
    NSString *title, *message, *textColor, *bckColor;
    
    if (content) {
        title = content[@"title"];
        message = content[@"message"];
        textColor = content[@"textColor"];
        bckColor = content[@"bckColor"];
    }
    
    UIView *textDisplayView = [[UIView alloc] init];
    
    if (backgroundImage) {
        textDisplayView.opaque = NO;
        textDisplayView.backgroundColor = [UIColor clearColor];
    } else {
        
        if (bckColor) {
            textDisplayView.backgroundColor = [self colorWithHexString:bckColor];
        } else {
            textDisplayView.backgroundColor = [UIColor lightTextColor];
        }
        
    }
    
    UILabel *titleLabel;
    BOOL contentTitlePresent = title &&  ![title isEqualToString:@""];
    BOOL contentMessagePresent = message && ![message isEqualToString:@""];
    if (!contentTitlePresent && !contentMessagePresent && !backgroundImage) {
        title = self.notification.request.content.title;
        message = self.notification.request.content.body;
    }
    
    BOOL titlePresent = title &&  ![title isEqualToString:@""];
    BOOL messagePresent = message && ![message isEqualToString:@""];
    
    if (titlePresent) {
        titleLabel = [[UILabel alloc] init];
        
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = title;
        titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        if (textColor) {
            titleLabel.textColor = [self colorWithHexString:textColor];
        } else {
            titleLabel.textColor = [UIColor blackColor];
        }
        
        [textDisplayView addSubview:titleLabel];
    }
    
    if (messagePresent) {
        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.textAlignment = NSTextAlignmentLeft;
        messageLabel.text = message;
        
        if (textColor) {
            messageLabel.textColor = [self colorWithHexString:textColor];
        } else {
            messageLabel.textColor = [UIColor blackColor];
        }
        
        messageLabel.numberOfLines = 3;
        
        [textDisplayView addSubview:messageLabel];
    }
    
    [mainContentView addSubview:textDisplayView];
    
    UIView *separator = [[UIView alloc] init];
    separator.backgroundColor = [UIColor lightGrayColor];
    
    [superViewWrapper addSubview:separator];
    
    UIView *starRatingView = [[UIView alloc] init];
    starRatingView.backgroundColor = [UIColor whiteColor];
    
    
    self.labelsWrapper = [[UIView alloc] init];
    self.unselectedLabel = [[UILabel alloc] init];
    
    self.selectedLabel = [[UILabel alloc] init];
    
    [self.labelsWrapper addSubview:self.selectedLabel];
    [self.labelsWrapper addSubview:self.unselectedLabel];
    
    [starRatingView addSubview:self.labelsWrapper];
    [superViewWrapper addSubview:starRatingView];
    
    [self setUpConstraintsWithImageView:backgroundImage titlePresent:titlePresent messagePresent:messagePresent];
    
    [self renderStarControl];
}

- (void)renderStarControl {
    
    NSInteger selectedCount = self.selectedCount;
    NSInteger totalCount = [self.notification.request.content.userInfo[@"expandableDetails"][@"ratingScale"] integerValue];
    
    self.selectedLabel.textAlignment = NSTextAlignmentNatural;
    
    char starChar[] = "\u2605";
    NSData *data = [NSData dataWithBytes:starChar length:strlen(starChar)];
    
    NSString *starString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *spaceAppendString = @" ";
    
    if (totalCount <= 5) {
        spaceAppendString = @"  ";
    }
    
    NSMutableString *starStringSelected = [[NSMutableString alloc] init];
    
    for (NSUInteger i=1; i<=selectedCount; i++) {
        
        [starStringSelected appendString:starString];
        
        if (i < totalCount) {
            [starStringSelected appendString:spaceAppendString];
        }
    }
    
    self.selectedLabel.text = starStringSelected;
    
    self.selectedLabel.textColor = [UIColor orangeColor];
    self.selectedLabel.font = [self.selectedLabel.font fontWithSize:STAR_FONT_SIZE];
    
    self.unselectedLabel.textAlignment = NSTextAlignmentNatural;
    
    
    NSMutableString *starStringUnselected = [[NSMutableString alloc] init];
    
    for (NSUInteger i=selectedCount+1; i<=totalCount; i++) {
        [starStringUnselected appendString:starString];
        if (i < totalCount) {
            [starStringUnselected appendString:spaceAppendString];
        }
    }
    
    self.unselectedLabel.text = starStringUnselected;
    
    self.unselectedLabel.textColor = [UIColor lightGrayColor];
    self.unselectedLabel.font = [self.unselectedLabel.font fontWithSize:STAR_FONT_SIZE];
}

- (void)setUpConstraintsWithImageView:(BOOL)imageViewIncluded
                         titlePresent:(BOOL)titlePresent
                       messagePresent:(BOOL)messagePresent {
    
    UIView *superViewWrapper = self.view.subviews[0];
    UIView *mainContentView = superViewWrapper.subviews[0];
    UIView *separator = superViewWrapper.subviews[1];
    UIView *starRatingWrapper = superViewWrapper.subviews[2];
    
    if (@available(iOS 10.0, *)) {
        
        superViewWrapper.translatesAutoresizingMaskIntoConstraints = NO;
        [superViewWrapper.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        [superViewWrapper.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        [superViewWrapper.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        [superViewWrapper.bottomAnchor constraintEqualToAnchor:starRatingWrapper.bottomAnchor].active = YES;
        
        //Top level view constraints
        mainContentView.translatesAutoresizingMaskIntoConstraints = NO;
        [mainContentView.leadingAnchor constraintEqualToAnchor:mainContentView.superview.leadingAnchor].active = YES;
        [mainContentView.trailingAnchor constraintEqualToAnchor:mainContentView.superview.trailingAnchor].active = YES;
        [mainContentView.topAnchor constraintEqualToAnchor:mainContentView.superview.topAnchor].active = YES;
        
        separator.translatesAutoresizingMaskIntoConstraints = NO;
        [separator.leadingAnchor constraintEqualToAnchor:separator.superview.leadingAnchor].active = YES;
        [separator.trailingAnchor constraintEqualToAnchor:separator.superview.trailingAnchor].active = YES;
        [separator.topAnchor constraintEqualToAnchor:mainContentView.bottomAnchor].active = YES;
        [separator.heightAnchor constraintEqualToConstant:0.5].active = YES;
        
        starRatingWrapper.translatesAutoresizingMaskIntoConstraints = NO;
        [starRatingWrapper.leadingAnchor constraintEqualToAnchor:starRatingWrapper.superview.leadingAnchor].active = YES;
        [starRatingWrapper.trailingAnchor constraintEqualToAnchor:starRatingWrapper.superview.trailingAnchor].active = YES;
        [starRatingWrapper.topAnchor constraintEqualToAnchor:separator.bottomAnchor].active = YES;
        [starRatingWrapper.heightAnchor constraintEqualToConstant:STAR_BAR_HEIGHT].active = YES;
        
        [self.viewController.bottomLayoutGuide.topAnchor constraintEqualToAnchor:superViewWrapper.bottomAnchor].active = YES;
        
        //Main Content View Internal Constraints
        NSInteger textDisplaySubviewIndex = 0;
        if (imageViewIncluded) {
            
            UIImageView *imageView = mainContentView.subviews[0];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            [imageView.topAnchor constraintEqualToAnchor:mainContentView.topAnchor].active = YES;
            [imageView.leadingAnchor constraintEqualToAnchor:mainContentView.leadingAnchor].active = YES;
            [imageView.trailingAnchor constraintEqualToAnchor:mainContentView.trailingAnchor].active = YES;
            [imageView.heightAnchor constraintEqualToAnchor:imageView.widthAnchor multiplier:1.0/3.0].active = YES;
            [mainContentView.bottomAnchor constraintEqualToAnchor:imageView.bottomAnchor].active = YES;
            
            textDisplaySubviewIndex = 1;
        }
        
        UIView *textDisplayView = mainContentView.subviews[textDisplaySubviewIndex];
        textDisplayView.translatesAutoresizingMaskIntoConstraints = NO;
        [textDisplayView.leadingAnchor constraintEqualToAnchor:mainContentView.leadingAnchor].active = YES;
        [textDisplayView.trailingAnchor constraintEqualToAnchor:mainContentView.trailingAnchor].active = YES;
        [textDisplayView.topAnchor constraintEqualToAnchor:mainContentView.topAnchor].active = YES;
        
        if (!imageViewIncluded) {
            [mainContentView.bottomAnchor constraintEqualToAnchor:textDisplayView.bottomAnchor].active = YES;
        }
        
        //TextDisplayView internal constraints
        NSInteger messageSubViewIndex = 0;
        UILabel *titleLabel;
        
        if (titlePresent) {
            
            messageSubViewIndex = 1;
            titleLabel = textDisplayView.subviews[0];
            titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [titleLabel.leadingAnchor constraintEqualToAnchor:textDisplayView.leadingAnchor constant:TEXT_PADDING].active = YES;
            [titleLabel.trailingAnchor constraintEqualToAnchor:textDisplayView.trailingAnchor constant:0-TEXT_PADDING].active = YES;
            [titleLabel.topAnchor constraintEqualToAnchor:textDisplayView.topAnchor constant:TEXT_PADDING].active = YES;
            
            if (!messagePresent) {
                [titleLabel.bottomAnchor constraintEqualToAnchor:textDisplayView.bottomAnchor constant:0-TEXT_PADDING].active = YES;
            }
        }
        
        if (messagePresent) {
            
            UILabel *messageLabel = textDisplayView.subviews[messageSubViewIndex];
            messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [messageLabel.leadingAnchor constraintEqualToAnchor:textDisplayView.leadingAnchor constant:TEXT_PADDING].active = YES;
            [messageLabel.trailingAnchor constraintEqualToAnchor:textDisplayView.trailingAnchor constant:0-TEXT_PADDING].active = YES;
            
            if (titlePresent) {
                [messageLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:TEXT_PADDING].active = YES;
            } else {
                [messageLabel.topAnchor constraintEqualToAnchor:textDisplayView.topAnchor constant:TEXT_PADDING].active = YES;
            }
            
            [messageLabel.bottomAnchor constraintEqualToAnchor:textDisplayView.bottomAnchor constant:0-TEXT_PADDING].active = YES;
        }
        
        //Star rating view internal constraints
        self.labelsWrapper.translatesAutoresizingMaskIntoConstraints = NO;
        [self.labelsWrapper.topAnchor constraintEqualToAnchor:self.labelsWrapper.superview.topAnchor].active = YES;
        [self.labelsWrapper.bottomAnchor constraintEqualToAnchor:self.labelsWrapper.superview.bottomAnchor].active = YES;
        [self.labelsWrapper.centerXAnchor constraintEqualToAnchor:self.labelsWrapper.superview.centerXAnchor].active = YES;
        
        self.selectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.selectedLabel.topAnchor constraintEqualToAnchor:self.labelsWrapper.topAnchor].active = YES;
        [self.selectedLabel.bottomAnchor constraintEqualToAnchor:self.labelsWrapper.bottomAnchor].active = YES;
        [self.selectedLabel.leadingAnchor constraintEqualToAnchor:self.labelsWrapper.leadingAnchor].active = YES;
        
        self.unselectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.unselectedLabel.topAnchor constraintEqualToAnchor:self.labelsWrapper.topAnchor].active = YES;
        [self.unselectedLabel.bottomAnchor constraintEqualToAnchor:self.labelsWrapper.bottomAnchor].active = YES;
        [self.unselectedLabel.trailingAnchor constraintEqualToAnchor:self.labelsWrapper.trailingAnchor].active = YES;
        
        [self.unselectedLabel.leadingAnchor constraintEqualToAnchor:self.selectedLabel.trailingAnchor].active = YES;
        
    } else {
        NSLog(@"Expected to be running iOS version 10 or above");
    }
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (UIView *)inputAccessoryView {
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
    
    UIView *inputAccessoryView = [[UIView alloc] initWithFrame:frame];
    inputAccessoryView.backgroundColor = [UIColor lightTextColor];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:@"Done"
                                                                    attributes:@{
                                                                                 NSUnderlineStyleAttributeName:
                                                                                     [NSNumber numberWithInt:NSUnderlineStyleNone],
                                                                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:20],
                                                                                 NSForegroundColorAttributeName: [self colorWithHexString:@"0077cc"]
                                                                                 }];
    
    [doneButton setAttributedTitle:attrTitle forState:UIControlStateNormal];
    
    [inputAccessoryView addSubview:doneButton];
    
    doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (@available(iOS 10.0, *)) {
        
        [doneButton.trailingAnchor constraintEqualToAnchor:inputAccessoryView.trailingAnchor constant:-10.0].active = YES;
        [doneButton.topAnchor constraintEqualToAnchor:inputAccessoryView.topAnchor].active = YES;
        [doneButton.bottomAnchor constraintEqualToAnchor:inputAccessoryView.bottomAnchor].active = YES;
        
        [doneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchDown];
        
    } else {
        NSLog(@"Expected to be running iOS version 10 or above");
    }
    
    return inputAccessoryView;
}

- (UIView *)inputView {
    
    return self.pickerView;
}

- (void)doneButtonClicked:(id)sender {
    
    NSInteger rowIndex = [self.pickerView selectedRowInComponent:0];
    
    self.selectedCount = rowIndex+1;
    [self renderStarControl];
    [self.viewController resignFirstResponder];
}

- (void)didReceiveNotification:(UNNotification *)notification  API_AVAILABLE(ios(10.0)) {
    
    self.notification = notification;
    [self initialiseViewHierarchy];
    
    self.pickerManager = [[StarPickerManager alloc] initWithNotification:notification];
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.backgroundColor = [UIColor blackColor];
    
    self.pickerView.dataSource = self.pickerManager;
    self.pickerView.delegate = self.pickerManager;
    
    NSInteger noOfStars = [notification.request.content.userInfo[@"expandableDetails"][@"ratingScale"] integerValue];
    [self.pickerView selectRow:noOfStars/2 inComponent:0 animated:NO];
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion  API_AVAILABLE(ios(10.0)) {
    
    if (@available(iOS 10.0, *)) {
        
        UNNotificationContentExtensionResponseOption completionOption = UNNotificationContentExtensionResponseOptionDoNotDismiss;
        
        if ([response.actionIdentifier isEqualToString:@"WEG_CHOOSE_RATING"]) {
            
            [self.viewController becomeFirstResponder];
            
        } else if ([response.actionIdentifier isEqualToString:@"WEG_SUBMIT_RATING"]) {
            
            if (self.selectedCount > 0) {
                
                NSDictionary *userInfo = self.notification.request.content.userInfo;
                NSDictionary *expandableDetails = userInfo[@"expandableDetails"];
                
                NSString *expId = userInfo[@"experiment_id"];
                NSString *notifId = userInfo[@"notification_id"];
                
                if (expandableDetails) {
                    
                    NSMutableDictionary *systemData = [[NSMutableDictionary alloc] init];
                    
                    [systemData addEntriesFromDictionary:@{
                                                           @"id": notifId,
                                                           @"experiment_id": expId
                                                           }];
                    
                    NSString *submitCTA = expandableDetails[@"submitCTA"][@"actionLink"];
                    
                    if (submitCTA) {
                        
                        NSString *submitCTAId = expandableDetails[@"submitCTA"][@"id"];
                        [systemData setObject:submitCTAId forKey:@"call_to_action"];
                        
                        [self.viewController setCTAWithId:submitCTAId andLink:submitCTA];
                    }
                    
                    completionOption = UNNotificationContentExtensionResponseOptionDismissAndForwardAction;
                    
                    [self.viewController addSystemEventWithName:WEX_RATING_SUBMITTED_EVENT_NAME
                                                     systemData: systemData
                                                applicationData:@{
                                                                  @"we_wk_rating":
                                                                      [NSNumber numberWithInteger:
                                                                       self.selectedCount]
                                                                  }];
                }
            } else {
                
                //Here UI may be updated to prompt choosing a rating value.
            }
        }
        
        completion(completionOption);
        
    } else {
        NSLog(@"Expected to be running iOS version 10 or above");
    }
}

- (UIColor *)colorWithHexString:(NSString *)hexString {
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


#endif

@end
