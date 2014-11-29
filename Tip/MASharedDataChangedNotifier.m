//
//  MAAppNotifications.m
//  Tip
//
//  Created by Wade Spires on 11/28/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import "MASharedDataChangedNotifier.h"

#import <CoreFoundation/CoreFoundation.h>

// Define different notification names to differentiate between sending from the phone to the watch and sending from the watch to the phone.
static CFStringRef const kHostAppNotificationName = CFSTR("com.mindsaspire.Tip.SharedDataChangedNotificationNameForHostApp");
static CFStringRef const kExtensionNotificationName = CFSTR("com.mindsaspire.Tip.SharedDataChangedNotificationNameForExtension");

#ifdef IS_HOST_APP
    #define kSendNotificationName kHostAppNotificationName
    #define kRecvNotificationName kExtensionNotificationName
#elif IS_EXTENSION
    #define kSendNotificationName kExtensionNotificationName
    #define kRecvNotificationName kHostAppNotificationName
#else
    #error "Define either IS_HOST_APP or IS_EXTENSION in your build settings for this target (Target -> Build Settings -> Custom Compiler Flags -> Other C Flags: -DIS_HOST_APP=1)"
#endif

@interface MASharedDataChangedNotifier ()
@property (assign, nonatomic) BOOL isRegisteredForNotifications;

- (void)registerForSharedDataChangedNotifications;
- (void)unregisterForSharedDataChangedNotifications;
@end

@implementation MASharedDataChangedNotifier
@synthesize isRegisteredForNotifications = _isRegisteredForNotifications;

+ (MASharedDataChangedNotifier *)sharedInstance
{
    static dispatch_once_t once;
    static MASharedDataChangedNotifier * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        _isRegisteredForNotifications = NO;
    }
    return self;
}

- (void)registerForSharedDataChangedNotifications
{
    if (_isRegisteredForNotifications)
    {
        return;
    }
    
    // Use the Darwin notification center to deliver messages to other processes or extensions.
    // Note, however, that the Darwin notification center ignores the suspensionBehavior parameter.
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationSuspensionBehavior const suspensionBehavior = CFNotificationSuspensionBehaviorDeliverImmediately;
    CFNotificationCenterAddObserver(center, NULL, sharedDataChangedCallback, kRecvNotificationName, NULL, suspensionBehavior);
    
    _isRegisteredForNotifications = YES;
}

- (void)unregisterForSharedDataChangedNotifications
{
    if ( ! _isRegisteredForNotifications)
    {
        return;
    }

    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterRemoveObserver(center, NULL, kRecvNotificationName, NULL);
    
    _isRegisteredForNotifications = NO;
}

void sharedDataChangedCallback(CFNotificationCenterRef center,
                               void * observer,
                               CFStringRef name,
                               void const * object,
                               CFDictionaryRef userInfo)
{
    // This is a plain C function, not a member of any class, so we post a notification to the local notification center to notify all observers in this app that the shared container has been changed.
    [[NSNotificationCenter defaultCenter] postNotificationName:MASharedDataChangedNotification object:nil];
}

+ (void)postNotification
{
    // Use the Darwin notification center to deliver messages to other processes or extensions.
    // Note, however, that the Darwin notification center ignores the userInfo and deliverImmediately parameters.
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFDictionaryRef const userInfo = NULL;
    BOOL const deliverImmediately = YES;
    CFNotificationCenterPostNotification(center, kSendNotificationName, NULL, userInfo, deliverImmediately);
}

@end
