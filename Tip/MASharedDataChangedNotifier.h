//
//  MAAppNotifications.h
//  Tip
//
//  Created by Wade Spires on 11/28/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

// Local notification center name through which to be notified for changes to the shared app container.
// For example:
// [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sharedDataChanged:) name:MASharedDataChangedNotification object:nil];
static NSString * const MASharedDataChangedNotification = @"com.mindsaspire.Tip.SharedDataChangedNotificationNameForHostApp";

@interface MASharedDataChangedNotifier : NSObject

+ (MASharedDataChangedNotifier *)sharedInstance;

// Start receiving notifications that the shared app container has changed.
// Must call at least once in order to receive MASharedDataChangedNotification local notifications.
- (void)registerForSharedDataChangedNotifications;

// Stop receiving notifications that the shared app container has changed.
// Should call only when the last MASharedDataChangedNotification observer has been removed.
- (void)unregisterForSharedDataChangedNotifications;

// Notify other processes/extensions that the shared data has been changed.
+ (void)postNotification;

@end
