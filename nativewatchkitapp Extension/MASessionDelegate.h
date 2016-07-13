//
//  MASessionDelegate.h
//  Tip
//
//  Created by Wade Spires on 10/24/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import <Foundation/Foundation.h>

// Handles communication between the Apple Watch and iPhone.
// * Activates WCSession object for messaging.
// * Delegate for responding to a message sent by a WCSession object.
// * Interface for sending messages.
@interface MASessionDelegate : NSObject <WCSessionDelegate>

@property (strong, readonly, nonatomic) NSDictionary<NSDate *, NSDictionary<NSString *, id> *> *pendingTransfers;
@property (strong, readonly, nonatomic) NSDictionary<NSDate *, NSDictionary<NSString *, id> *> *failedTransfers;

+ (NSString *)sessionActivatedNotificationName;
+ (NSString *)sessionNotActivatedNotificationName;
+ (NSString *)sessionReachableNotificationName;
+ (NSString *)sessionUnreachableNotificationName;

+ (MASessionDelegate *)sharedInstance;

- (instancetype)init;

// Returns true if [WCSession defaultSession] is activated.
+ (BOOL)isActivated;

// Returns true if a live message can be sent via sendMessage ([WCSession defaultSession] is activated and reachable).
+ (BOOL)canSendMessage;

// Send Message - Interactive Live Data
- (BOOL)sendMessage:(NSDictionary *)message;
- (BOOL)sendMessage:(NSDictionary *)message
       replyHandler:(void (^)(NSDictionary<NSString *, id> *replyMessage))replyHandler;
- (BOOL)sendMessage:(NSDictionary *)message
       replyHandler:(void (^)(NSDictionary<NSString *, id> *replyMessage))replyHandler
       errorHandler:(void (^)(NSError *error))errorHandler;

// Update Application Context - Replaced Background Data
- (BOOL)updateApplicationContextWithObject:(id<NSCoding>)object key:(NSString *)key;
- (BOOL)updateApplicationContextWithObject:(id<NSCoding>)object key:(NSString *)key persist:(BOOL)update;

@end
