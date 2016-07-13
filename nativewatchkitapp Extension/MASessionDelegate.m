//
//  MASessionDelegate.m
//  Tip
//
//  Created by Wade Spires on 10/24/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#import "MASessionDelegate.h"

#import "MABill.h"
#import "MALogUtil.h"
#import "MAMessageKeys.h"
#import "MANotificationNames.h"
#import "MAPlistUtil.h"
#import "MAUserUtil.h"

#import "NSNotificationCenter+MainQueue.h"

// Key and value for the application context dictionary so we can identify where an update originated, so we can ignore updates coming from the same source (e.g., the watch app can ignore updates coming from itself).
static NSString * const MsgSourceKey = @"source";
#ifdef IS_HOST_APP
static NSString * const MsgSource = @"HostApp";
#else
static NSString * const MsgSource = @"Extension";
#endif

static NSString * const ResendAttempts = @"resendAttempts";
static NSString * const OriginalSendTimeKey = @"originalSendTime";

@interface MASessionDelegate()

@property (strong, nonatomic) NSMutableDictionary<NSString *, id> *context;

@end

@implementation MASessionDelegate
@synthesize pendingTransfers = _pendingTransfers;
@synthesize failedTransfers = _failedTransfers;
@synthesize context = _context;

#pragma mark - Notification Names

+ (NSString *)sessionActivatedNotificationName
{
    return @"sessionActivatedNotification";
}
+ (NSString *)sessionNotActivatedNotificationName
{
    return @"sessionNotActivatedNotification";
}
+ (NSString *)sessionReachableNotificationName
{
    return @"sessionReachableNotification";
}
+ (NSString *)sessionUnreachableNotificationName
{
    return @"sessionUnreachableNotification";
}

#pragma mark - Init WCSession Delegate

+ (MASessionDelegate *)sharedInstance
{
    static dispatch_once_t once;
    static MASessionDelegate * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[MASessionDelegate alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // Initialize the context dict with the message source so it never has to be explicitly set later.
        _context = [[NSMutableDictionary alloc] init];
        [_context setObject:MsgSource forKey:MsgSourceKey];
        
        // Publicly declared as an immutable NSDictionary, but internally it is actually mutable.
        _pendingTransfers = [[NSMutableDictionary alloc] init];
        _failedTransfers = [[NSMutableDictionary alloc] init];
        
        // Automatically start the session.
        [self startWCSession];
    }
    return self;
}

- (void)startWCSession
{
    if ([WCSession isSupported])
    {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error
{
    NSString *activationStateString = @"";
    if (activationState == WCSessionActivationStateActivated)
    {
        activationStateString = @"Activated";
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainQueue:[MASessionDelegate sessionActivatedNotificationName] object:self];
    }
    else if (activationState == WCSessionActivationStateNotActivated)
    {
        activationStateString = @"NotActivated";
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainQueue:[MASessionDelegate sessionNotActivatedNotificationName] object:self];
    }
    else if (activationState == WCSessionActivationStateInactive)
    {
        activationStateString = @"Inactive";
    }
    else
    {
        activationStateString = @"Unknown";
    }
    
    LOG_S(@"activationState = %@, error = %@", activationStateString, error);
}

- (void)sessionDidBecomeInactive:(WCSession *)session
{
    LOG
}

- (void)sessionDidDeactivate:(WCSession *)session
{
    LOG
    // Restart the session.
    [[WCSession defaultSession] activateSession];
}

- (void)sessionWatchStateDidChange:(WCSession *)session
{
    LOG
#ifdef IS_HOST_APP
    if ( ! session.paired)
    {
        LOG_S(@"Watch not paired");
        return;
    }
    if ( ! session.watchAppInstalled)
    {
        LOG_S(@"Watch app not installed");
        return;
    }
#endif // IS_HOST_APP
    LOG_S(@"Watch is paired, and watch app is installed")
}

- (void)sessionReachabilityDidChange:(WCSession *)session
{
    LOG
    if (session.isReachable)
    {
        LOG_S(@"Watch is paired, and watch app is installed")
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainQueue:[MASessionDelegate sessionReachableNotificationName] object:self];
    }
    else
    {
        LOG_S(@"App not reachable");
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainQueue:[MASessionDelegate sessionUnreachableNotificationName] object:self];
    }
}

+ (BOOL)isActivated
{
    return ([WCSession defaultSession].activationState == WCSessionActivationStateActivated);
}

+ (BOOL)canSendMessage
{
    return ([MASessionDelegate isActivated] && [WCSession defaultSession].isReachable);
}

#pragma mark - Update Application Context - Replaced Background Data

- (BOOL)updateApplicationContextWithObject:(id<NSCoding>)object key:(NSString *)key
{
    return [self updateApplicationContextWithObject:object key:key persist:YES];
}
- (BOOL)updateApplicationContextWithObject:(id<NSCoding>)object key:(NSString *)key persist:(BOOL)persist
{
    //    LOG
    
    // If persist is set, update context dict for sending, so can keep adding to the new context state since the data is not queued for delivery (only the last context is sent).
    NSMutableDictionary<NSString *, id> *context = nil;
    if (persist)
    {
        // Must make a copy of the persisted context in case the context being sent is compressed since a non-plist object will first be archived as an NSData and then compressed as an NSData. If we did not copy, then a second call would recompress the already-compressed NSData again.
        [self.context setObject:object forKey:key];
        context = [[NSMutableDictionary<NSString *, id> alloc] initWithDictionary:self.context];
    }
    else
    {
        // Send a new context without any pre-existing keys.
        context = [NSMutableDictionary<NSString *, id> dictionary];
        [context setObject:object forKey:key];
    }
    [context setObject:MsgSource forKey:MsgSourceKey];
    [context setObject:[NSDate date] forKey:[MAMessageKeys sendTime]];
    
    if ( ! [MASessionDelegate isActivated])
    {
        LOG_S(@"WCSession is not activated");
        return NO;
    }

    // Convert non-property-list objects to NSData.
    [MAPlistUtil archiveDictionary:context];
    
    NSError *error = nil;
    BOOL success = [[WCSession defaultSession] updateApplicationContext:context error:&error];
    if ( ! success)
    {
        LOG_S(@"Error: %@", error);
    }
    return success;
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)applicationContext
{
    // Decode data while still running in the background
    // Must handle it in the main thread if the UI may be updated.
    applicationContext = [MAPlistUtil unarchiveDictionary:applicationContext];
    
    // Check the application context for each shared object. If the object changed, unarchive it, save it as the new shared instance, and notify observers that it was changed.
    [self session:session didReceiveUserUtilInApplicationContext:applicationContext];
    [self session:session didReceiveBillInApplicationContext:applicationContext];
}

- (void)session:(WCSession *)session didReceiveUserUtilInApplicationContext:(NSDictionary<NSString *, id> *)applicationContext
{
    MAUserUtil *settings = [applicationContext objectForKey:[MAUserUtil sharedContainerKey]];
    if ( ! settings)
    {
        return;
    }
    else if ( ! [settings isKindOfClass:[MAUserUtil class]])
    {
        return;
    }

    //NSDate *sendTime = [applicationContext objectForKey:[MAMessageKeys sendTime]];
    
    dispatch_async(dispatch_get_main_queue(),
    ^{
        BOOL saved = [settings saveAsSharedInstanceAndPostNotification:YES updateApplicationContext:NO];
        if ( ! saved)
        {
            TLog(@"Failed to save settings");
            return;
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:SettingsChangedNotification object:self userInfo:nil];
    });
}

- (void)session:(WCSession *)session didReceiveBillInApplicationContext:(NSDictionary<NSString *, id> *)applicationContext
{
    MABill *bill = [applicationContext objectForKey:[MABill sharedContainerKey]];
    if ( ! bill)
    {
        return;
    }
    else if ( ! [bill isKindOfClass:[MABill class]])
    {
        return;
    }

    //NSDate *sendTime = [applicationContext objectForKey:[MAMessageKeys sendTime]];
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       BOOL saved = [bill saveAsSharedInstanceAndPostNotification:YES updateApplicationContext:NO];
                       if ( ! saved)
                       {
                           TLog(@"Failed to save bill");
                           return;
                       }
                       
                       // Note: already have saved the new shared instance, so send nil as the userInfo instead of the applicationContext since an observer should reload the shared instance not
                       [[NSNotificationCenter defaultCenter] postNotificationName:BillChangedNotification object:self userInfo:nil];
                   });
}

#pragma mark - Send and Receive Message - Interactive Live Data

//- (BOOL)sendWorkoutSessionRequestForRoutine:(NSString *)routine
//                               replyHandler:(void (^)(NSDictionary<NSString *, id> *replyMessage))replyHandler
//                               errorHandler:(void (^)(NSError *error))errorHandler
//{
//    NSMutableDictionary *message = [MAMessageKeys dictForMsgType:[MAMessageKeys requestWorkoutSession]];
//    [message setObject:routine forKey:@"routine"];
//    
//    return [self sendMessage:message replyHandler:replyHandler errorHandler:errorHandler];
//}

- (BOOL)sendMessage:(NSDictionary *)message
{
    return [self sendMessage:message replyHandler:NULL];
}
- (BOOL)sendMessage:(NSDictionary *)message
       replyHandler:(void (^)(NSDictionary<NSString *, id> *replyMessage))replyHandler
{
    return [self sendMessage:message replyHandler:replyHandler errorHandler:NULL];
}
- (BOOL)sendMessage:(NSDictionary *)message
       replyHandler:(void (^)(NSDictionary<NSString *, id> *replyMessage))replyHandler
       errorHandler:(void (^)(NSError *error))errorHandler
{
    // Convert non-property-list objects to NSData.
    NSMutableDictionary *archivedMessage = [NSMutableDictionary dictionaryWithDictionary:message];
    [MAPlistUtil archiveDictionary:archivedMessage];
    
    // Add extra, useful data to all messages sent.
    // Important: these must already be property-list objects if added after archiveDictionary.
    [archivedMessage setObject:MsgSource forKey:MsgSourceKey];
    [archivedMessage setObject:[NSDate date] forKey:[MAMessageKeys sendTime]];
    
    // Session must be activated and reachable to send a live message.
    // If not, then return NO, so caller knows message could not be sent.
    // Do this check immediately before sending a message to avoid session becoming deactivated in-between.
    if ( ! [MASessionDelegate isActivated])
    {
        LOG_S(@"Not calling sendMessage because WCSession is not activated");
        return NO;
    }
    else if ( ! [WCSession defaultSession].isReachable)
    {
        LOG_S(@"Not calling sendMessage because WCSession is not reachable");
        return NO;
    }
    
    // Sends a message immediately to the paired device and handles a response.
    [[WCSession defaultSession] sendMessage:archivedMessage
                               replyHandler:^(NSDictionary *replyMessage)
     {
         LOG_S(@"Received replyMessage: keys = %@", [replyMessage allKeys])
         
         // Decode reply while still in the background and handle it in the main thread.
         replyMessage = [MAPlistUtil unarchiveDictionary:replyMessage];
         
         if (replyHandler)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 replyHandler(replyMessage);
             });
         }
     }
                               errorHandler:^(NSError * error)
     {
         // Note: Could be that the iPhone is unreachable because they are working out with only the watch, not the phone.
         LOG_S(@"Error sending message (or have non-property-list message or replyMessage): error = %@ (%d), message = %@", error.localizedDescription, (int)error.code, message);
         if (errorHandler)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 errorHandler(error);
             });
         }
     }];
    
    return YES;
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message
{
    LOG
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler
{
    LOG
    replyHandler(nil); // Required to call, but do nothing for now.
}

- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData
{
    LOG
}

- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData replyHandler:(void(^)(NSData *replyMessageData))replyHandler
{
    LOG
    replyHandler(nil); // Required to call, but do nothing for now.
}

- (void)session:(WCSession *)session didFinishUserInfoTransfer:(WCSessionUserInfoTransfer *)userInfoTransfer error:(NSError *)error
{
    LOG
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *, id> *)userInfo
{
    LOG
    
    // Data arrives on a background queue, so must use the main queue if we update the UI.
    dispatch_async(dispatch_get_main_queue(),
    ^{
        TLog(@"User info: %@", userInfo);
    });
}

- (void)session:(WCSession *)session didFinishFileTransfer:(WCSessionFileTransfer *)fileTransfer error:(NSError *)error
{
    LOG
}

- (void)session:(WCSession *)session didReceiveFile:(WCSessionFile *)file
{
    LOG
}

@end
