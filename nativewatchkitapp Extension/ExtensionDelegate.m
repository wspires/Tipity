//
//  ExtensionDelegate.m
//  nativewatchkitapp Extension
//
//  Created by Wade Spires on 6/23/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#import "ExtensionDelegate.h"

#import "MASessionDelegate.h"

@interface ExtensionDelegate()
@end

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching
{
    // Perform any final initialization of your application.
    
    // Creating the shared session automatically starts WCSession.
    [MASessionDelegate sharedInstance];
}

- (void)applicationDidBecomeActive
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillResignActive
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
}

- (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

- (void)handleActionWithIdentifier:(NSString *)identifier
              forLocalNotification:(UILocalNotification *)localNotification
{
    
}

- (void)handleUserActivity:(NSDictionary *)userInfo
{
    
}

@end
