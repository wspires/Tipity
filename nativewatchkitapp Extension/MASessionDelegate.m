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
#import "MANotificationNames.h"
#import "MAUserUtil.h"

// Key and value for the application context dictionary so we can identify where an update originated, so we can ignore updates coming from the same source (e.g., the watch app can ignore updates coming from itself).
static NSString * const MsgSourceKey = @"source";
#ifdef IS_HOST_APP
static NSString * const MsgSource = @"HostApp";
#else
static NSString * const MsgSource = @"Extension";
#endif

@interface MASessionDelegate()

@property (strong, nonatomic) NSMutableDictionary *context;
@property (assign, nonatomic) BOOL isAvailable;

@end

@implementation MASessionDelegate
@synthesize context = _context;
@synthesize isAvailable = _isAvailable;

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
        
        // Automatically start the session.
        _isAvailable = NO;
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
        _isAvailable = YES;
    }
}

- (void)sessionWatchStateDidChange:(WCSession *)session
{
    LOG
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
    LOG_S(@"Watch is paired, and watch app is installed")
    self.isAvailable = YES;
}

- (void)sessionReachabilityDidChange:(WCSession *)session
{
    LOG
    if ( ! session.reachable)
    {
        LOG_S(@"App not reachable");
        return;
    }
    LOG_S(@"Watch is paired, and watch app is installed")
    self.isAvailable = YES;
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message
{
    LOG
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler
{
    LOG
}

- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData
{
    LOG
}

- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData replyHandler:(void(^)(NSData *replyMessageData))replyHandler
{
    LOG
//    replyHandler(nil);
}

- (BOOL)updateApplicationContextWithObject:(id<NSCoding>)object key:(NSString *)key
{
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:object];
    return [self updateApplicationContextWithData:encodedData key:key];
}

- (BOOL)updateApplicationContextWithData:(NSData *)data key:(NSString *)key
{
//    LOG

    // Update context dict for sending, so can keep adding to the new context state.
    [self.context setObject:data forKey:key];

    if ( ! self.isAvailable)
    {
        LOG_S(@"Not Available");
//        return NO;
    }

    WCSession *session = [WCSession defaultSession];
    NSError *error = nil;
    BOOL success = [session updateApplicationContext:self.context error:&error];
    if ( ! success)
    {
        LOG_S(@"%@", error);
    }
    return success;
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)applicationContext
{
//    LOG
    
    // Ignore calls from the same source, e.g., host app to host app or extension to extension.
    NSString *source = [applicationContext objectForKey:MsgSourceKey];
    if (source && [source isEqualToString:MsgSource])
    {
        LOG_S(@"Skip source %@", source)
        return;
    }
    
    // Check the application context for each shared object. If the object changed, unarchive it, save it as the new shared instance, and notify observers that it was changed.
    
    NSData *encodedData = nil;
    encodedData = [applicationContext objectForKey:[MABill sharedContainerKey]];
    if (encodedData)
    {
        MABill *bill = (MABill *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedData];

        // Data arrives on a background queue, so must use the main queue if we update the UI.
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
    
    encodedData = [applicationContext objectForKey:[MAUserUtil sharedContainerKey]];
    if (encodedData)
    {
        MAUserUtil *settings = (MAUserUtil *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedData];

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
