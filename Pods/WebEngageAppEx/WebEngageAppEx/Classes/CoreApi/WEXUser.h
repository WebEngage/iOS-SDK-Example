//
//  WEXUser.h
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WEXAnalytics.h"

#define WEG_EVENT_NAME_USER_DELETE_ATTRS    @"user_delete_attributes"
#define WEG_EVENT_NAME_USER_INCREMENT       @"user_increment"
#define WEG_EVENT_NAME_USER_UPDATE          @"user_update"


/**
 *  This enum represents the different user attributes which are known to WebEngage and are treated in its own symantically meaningful way.
 */
typedef NS_ENUM(NSInteger, WEGUserProfileAttribute) {
    /**
     *  User's Email
     */
    WEXUserProfileAttributeEmail = 1 << 1,
    /**
     *  User's Birth Date
     */
    WEXUserProfileAttributeBirthDate = 1 << 2,
    /**
     *  User's Gender
     */
    WEXUserProfileAttributeGender = 1 << 3,
    /**
     *  User's First Name
     */
    WEXUserProfileAttributeFirstName = 1 << 4,
    /**
     *  User's Last Name
     */
    WEXUserProfileAttributeLastName = 1 << 5,
    /**
     *  User's associated Company
     */
    WEXUserProfileAttributeCompany = 1 << 6
};

/**
 *  This Enum represents the different Engagement Types in User's Application.
 */
typedef NS_ENUM(NSInteger, WEGEngagementChannel) {
    /**
     *  Push Notifications
     */
    WEXEngagementChannelPush = 1 << 1,
    /**
     *  InApp Notifications
     */
    WEXEngagementChannelInApp = 1 << 2,
    /**
     *  Email
     */
    WEXEngagementChannelEmail = 1 << 3,
    /**
     *  SMS
     */
    WEXEngagementChannelSMS = 1 << 4,
};


/**
 *  This class is a facade for all the User related data storage. Please note the fact User attributes/ data is stored across devices, meaning setting a first name as 'A' from Android and then setting first name as 'B' from iOS will replace the existing value.
 */
@interface WEXUser : NSObject


/**
 *  Set any custom attribute apart from the shortcut methods provided by the SDK.
 *
 *  @param attributeName Name of the user attribute
 *  @param value         Value of the attribute represented as String.
 */
+ (void)setAttribute:(NSString *)attributeName withStringValue:(NSString *)value;


/**
 *  Set any custom attribute apart from the shortcut methods provided by the SDK.
 *
 *  @param attributeName Name of the user attribute
 *  @param value         Value of the attribute represented as Number or Bool.
 */
+ (void)setAttribute:(NSString *)attributeName withValue:(NSNumber *)value;


/**
 *  Set any custom attribute apart from the shortcut methods provided by the SDK.
 *
 *  @param attributeName Name of the user attribute
 *  @param value         Value of the attribute represented as Array.
 */
+ (void)setAttribute:(NSString *)attributeName withArrayValue:(NSArray *)value;


/**
 *  Set any custom attribute apart from the shortcut methods provided by the SDK.
 *
 *  @param attributeName Name of the user attribute
 *  @param value         Value of the attribute represented as Dictionary.
 */
+ (void)setAttribute:(NSString *)attributeName withDictionaryValue:(NSDictionary *)value;


/**
 *  Set any custom attribute apart from the shortcut methods provided by the SDK.
 *
 *  @param attributeName Name of the user attribute
 *  @param value         Value of the attribute represented as Date.
 */
+ (void)setAttribute:(NSString *)attributeName withDateValue:(NSDate *)value;


/**
 *  Delete the custom attribute set previously
 *
 *  @param attributeName Name of the attribute to be deleted.
 */
+ (void)deleteAttribute:(NSString *)attributeName;


/**
 *  Delete the custom attributes set previously
 *
 *  @param attributes Array of Strings representing names of attributes to be deleted.
 */
+ (void)deleteAttributes:(NSArray *)attributes;


/**
 *  Set the Email address of the user
 *
 *  @param email email address of the user
 */
+ (void)setEmail:(NSString *)email;


/**
 Set the encrypted email of the user.
 
 @param hashedEmail encrypted string for user's email
 */
+ (void)setHashedEmail:(NSString *)hashedEmail;


/**
 Set the phone number of the user
 
 @param phone Phone Number of the user
 */
+ (void)setPhone:(NSString *)phone;


/**
 Set the encrypted phone number of the user
 
 @param hashedPhone encypted phone number string
 */
+ (void)setHashedPhone:(NSString *)hashedPhone;


/**
 *  Date of Birth of the user.
 *
 *  @param dobString Date of birth of the user in the format yyyy-MM-dd.
 */
+ (void)setBirthDateString:(NSString *)dobString;


/**
 *  User's Gender
 *
 *  @param gender String representing User's Gender
 */
+ (void)setGender:(NSString *)gender;


/**
 *  User's first name
 *
 *  @param name first Name
 */
+ (void)setFirstName:(NSString *)name;


/**
 *  User's Last Name
 *
 *  @param name last name
 */
+ (void)setLastName:(NSString *)name;


/**
 *  User's associated company
 *
 *  @param company company name
 */
+ (void)setCompany:(NSString *)company;


/**
 *  Set the Opt In Status for a perticular Engagement type. If App sets Opt In Status as NO for an Engagement Channel, That user will not be engaged with using the given channel.
 *
 *  @param channel WEGEngagementChannel to set the status for
 *  @param statusValue Opt In status YES or NO
 */
+ (void)setOptInStatusForChannel:(WEGEngagementChannel)channel status:(BOOL)statusValue;

@end
