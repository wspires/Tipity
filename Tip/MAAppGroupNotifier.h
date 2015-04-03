//
//  MAAppGroupNotifier.h
//  Gym Log
//
//  Created by Wade Spires on 11/28/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

// Local notification center name through which to be notified of changes to the shared app container. For example:
// NSString *notificationName = [[MAAppGroupNotifier sharedInstance] registerKey:@"aKey"];
// [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sharedDataChanged:) name:notificationName object:nil];
// NSString *notificationName = [MAAppGroupNotifier notificationNameForKey:@"aKey"];
// [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];

@interface MAAppGroupNotifier : NSObject

// Singleton through which to register and unregister for keys.
+ (MAAppGroupNotifier *)sharedInstance;

// Returns the name to pass to NSNotificationCenter's addObserver.
+ (NSString *)notificationNameForKey:(NSString *)key;

// Shortcut for registering the key and adding an observer to the default notification center.
- (void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector key:(NSString *)key;

// Start receiving notifications that the shared app container has changed.
// Must call at least once in order to receive local notifications.
// Returns notificationNameForKey, the name to use when adding an observer to a notification center.
- (NSString *)registerKey:(NSString *)key;

// Shortcut for removing the observer from the default notification center for the key.
- (void)removeObserver:(id)notificationObserver key:(NSString *)key;

// Stop receiving notifications that the shared app container has changed.
// Should call only when the last NSNotificationCenter observer for the key has been removed.
- (void)unregisterKey:(NSString *)key;

// Notify other processes/extensions that the shared data has been changed. For example:
// NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.MyCompany.MyApp"];
// [defaults setObject:someObject forKey:@"aKey"];
// BOOL saved = [defaults synchronize];
// if (saved)
// {
//   [MAAppGroupNotifier postNotificationForKey:@"aKey"];
// }
+ (void)postNotificationForKey:(NSString *)key;

// App group name under which to save shared data.
// For example: group.com.MyCompany.MyApp
// Create the app group in the developer portal:
// https://developer.apple.com/account/ios/identifiers/applicationGroup/applicationGroupList.action
// Then enable in Xcode:
// Project -> App Target -> Capabilities -> App Groups -> On
+ (NSString *)appGroup;

// Save NSCoding compliant object to the shared app container for the given key.
// Does NOT post a notification after saving.
+ (BOOL)saveObject:(id<NSCoding>)object key:(NSString *)key;

// Save NSCoding compliant object to the shared app container for the given key.
// DOES post a notification after saving.
+ (BOOL)saveObject:(id<NSCoding>)object postNotificationForKey:(NSString *)key;

// Load NSCoding compliant object from the shared app container for the given key.
+ (id<NSCoding>)loadObjectForKey:(NSString *)key;

+ (BOOL)removeObjectForKey:(NSString *)key;
+ (BOOL)removeObjectAndPostNotificationForKey:(NSString *)key;

@end
