//
//  MAAppGroupNotifier.m
//  Gym Log
//
//  Created by Wade Spires on 11/28/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import "MAAppGroupNotifier.h"

#import "MAAppGroup.h"
#import "MALogUtil.h"

#import <CoreFoundation/CoreFoundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

// Define different notification names to differentiate between sending from the phone to the watch and sending from the watch to the phone.
#ifdef FREE_VERSION
static CFStringRef const kHostAppNotificationName = CFSTR("com.mindsaspire.Tip.SharedDataChangedNotificationNameForHostApp");
static CFStringRef const kExtensionNotificationName = CFSTR("com.mindsaspire.Tip.SharedDataChangedNotificationNameForExtension");
#else
static CFStringRef const kHostAppNotificationName = CFSTR("com.mindsaspire.Tip.SharedDataChangedNotificationNameForHostApp");
static CFStringRef const kExtensionNotificationName = CFSTR("com.mindsaspire.Tip.SharedDataChangedNotificationNameForExtension");
#endif // FREE_VERSION


#ifdef IS_HOST_APP
    #define kSendNotificationName kHostAppNotificationName
    #define kRecvNotificationName kExtensionNotificationName
#elif IS_EXTENSION
    #define kSendNotificationName kExtensionNotificationName
    #define kRecvNotificationName kHostAppNotificationName
#else
    #error "Define either IS_HOST_APP or IS_EXTENSION in your build settings for this target (Target -> Build Settings -> Custom Compiler Flags -> Other C Flags: -DIS_HOST_APP=1)"
#endif

@interface MAAppGroupNotifier () <WCSessionDelegate>

// Set of registered keys for which to send notifications.
// TODO: Make this a dictionary of observer counts and only unregister when the count is 0.
@property (strong, nonatomic) NSMutableSet *registeredKeys;

@property (strong, nonatomic) WCSession *session;

- (instancetype)init;
@end

@implementation MAAppGroupNotifier
@synthesize registeredKeys = _registeredKeys;

+ (MAAppGroupNotifier *)sharedInstance
{
    static dispatch_once_t once;
    static MAAppGroupNotifier * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance startWCSession];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _registeredKeys = [[NSMutableSet alloc] init];
    }
    return self;
}

+ (NSString *)recvNotificationNameForKey:(NSString *)key
{
    NSString *baseName = (__bridge NSString *)kRecvNotificationName;
    NSString *name = [baseName stringByAppendingPathExtension:key];
    return name;
}

+ (NSString *)sendNotificationNameForKey:(NSString *)key
{
    NSString *baseName = (__bridge NSString *)kSendNotificationName;
    NSString *name = [baseName stringByAppendingPathExtension:key];
    
    
//    NSMutableDictionary *context = [NSMutableDictionary dictionary];
//    [context setObject:@"bar" forKey:@"foo"];
//    NSError *error = nil;
//    BOOL success = [session updateApplicationContext:context error:&error];
//    if ( ! success && error)
//    {
//        LOG_S(@"Error: updateApplicationContext: %@", error);
//    }

    
    return name;
}

- (void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector key:(NSString *)key
{
    NSString *notificationName = [self registerKey:key];
    [[NSNotificationCenter defaultCenter] addObserver:notificationObserver selector:notificationSelector name:notificationName object:nil];
}

+ (NSString *)notificationNameForKey:(NSString *)key
{
    return [MAAppGroupNotifier recvNotificationNameForKey:key];
}

- (NSString *)registerKey:(NSString *)key
{
    @synchronized(self)
    {
        NSString *recvName = [MAAppGroupNotifier recvNotificationNameForKey:key];
        if ([self.registeredKeys containsObject:recvName])
        {
            return recvName;
        }
        CFStringRef recvNameRef = (__bridge CFStringRef)recvName;

        // Use the Darwin notification center to deliver messages to other processes or extensions.
        // Note, however, that the Darwin notification center ignores the suspensionBehavior parameter.
        CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationSuspensionBehavior const suspensionBehavior = CFNotificationSuspensionBehaviorDeliverImmediately;
        CFNotificationCenterAddObserver(center, NULL, sharedDataChangedCallback, recvNameRef, NULL, suspensionBehavior);
        
        [self.registeredKeys addObject:recvName];
        return recvName;
    }
}

- (void)removeObserver:(id)notificationObserver key:(NSString *)key
{
    NSString *notificationName = [MAAppGroupNotifier notificationNameForKey:key];
    [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver name:notificationName object:nil];
}

- (void)unregisterKey:(NSString *)key
{
    @synchronized(self)
    {
        NSString *recvName = [MAAppGroupNotifier recvNotificationNameForKey:key];
        if ( ! [self.registeredKeys containsObject:recvName])
        {
            return;
        }
        CFStringRef recvNameRef = (__bridge CFStringRef)recvName;
        
        CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterRemoveObserver(center, NULL, recvNameRef, NULL);
        
        [self.registeredKeys removeObject:recvName];
    }
}

void sharedDataChangedCallback(CFNotificationCenterRef center,
                               void * observer,
                               CFStringRef name,
                               void const * object,
                               CFDictionaryRef userInfo)
{
    // This callback is a plain C function, not a member of any class, so we post a notification to the local notification center to notify all observers in this app that the shared container has been changed.
    
    // Note: if receive a crash here, it's likely due to having an observer that forgot to call removeObserver before it was deallocated.
    NSString *notificationName = (__bridge NSString *)name;
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

+ (void)postNotificationForKey:(NSString *)key
{
    NSString *sendName = [MAAppGroupNotifier sendNotificationNameForKey:key];
    CFStringRef sendNameRef = (__bridge CFStringRef)sendName;

    // Use the Darwin notification center to deliver messages to other processes or extensions.
    // Note, however, that the Darwin notification center ignores the userInfo and deliverImmediately parameters.
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFDictionaryRef const userInfo = NULL;
    BOOL const deliverImmediately = YES;
    CFNotificationCenterPostNotification(center, sendNameRef, NULL, userInfo, deliverImmediately);
}

+ (NSString *)appGroup
{
    return AppGroup;
}

+ (BOOL)saveObject:(id<NSCoding>)object key:(NSString *)key
{
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:[MAAppGroupNotifier appGroup]];
    [defaults setObject:encodedData forKey:key];
    BOOL const saved = [defaults synchronize];
    return saved;
}

+ (BOOL)saveObject:(id<NSCoding>)object postNotificationForKey:(NSString *)key
{
    BOOL const saved = [MAAppGroupNotifier saveObject:object key:key];
    if (saved)
    {
        [MAAppGroupNotifier postNotificationForKey:key];
    }    
    return saved;
}

+ (id<NSCoding>)loadObjectForKey:(NSString *)key
{
    id<NSCoding> object = nil;
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:[MAAppGroupNotifier appGroup]];
    NSData *encodedData = [defaults objectForKey:key];
    if (encodedData)
    {
        object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedData];
    }
    return object;
}

+ (BOOL)removeObjectForKey:(NSString *)key
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:[MAAppGroupNotifier appGroup]];
    [defaults removeObjectForKey:key];
    BOOL const saved = [defaults synchronize];
    return saved;
}

+ (BOOL)removeObjectAndPostNotificationForKey:(NSString *)key
{
    BOOL const saved = [MAAppGroupNotifier removeObjectForKey:key];
    if (saved)
    {
        [MAAppGroupNotifier postNotificationForKey:key];
    }
    return saved;
}

- (void)startWCSession
{
    if ([WCSession isSupported])
    {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        self.session = session;
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
}

- (void)sessionReachabilityDidChange:(WCSession *)session
{
    LOG
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
    
//    MABill *bill = (MABill *)[NSKeyedUnarchiver unarchiveObjectWithData:messageData];
//    LOG_S(@"%@", bill);
    replyHandler(nil);
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)applicationContext
{
    LOG
    
    TLog(@"Context: %@", applicationContext);
    
    // Data arrives on a background queue, so must use the main queue if we update the UI.
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       TLog(@"Context: %@", applicationContext);
                   });
}

- (void)session:(WCSession *)session didFinishUserInfoTransfer:(WCSessionUserInfoTransfer *)userInfoTransfer error:(NSError *)error
{
    LOG
    
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *, id> *)userInfo
{
    LOG
    
    TLog(@"User info: %@", userInfo);
    
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
