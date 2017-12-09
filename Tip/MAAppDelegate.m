//
//  AppDelegate.m
//  Unit Price
//
//  Created by Wade Spires on 8/29/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import "MAAppDelegate.h"

#import "MAAppearance.h"
#import "MAAppGroup.h"
#import "MADefines.h"
#import "MADeviceUtil.h"
#import "MAImageCache.h"
#import "MATipViewController.h"
#import "MASessionDelegate.h"
#import "MASettingsViewController.h"
#import "MAUserUtil.h"
#import "MAUtil.h"

@interface MAAppDelegate ()

//@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTask;
@end

@implementation MAAppDelegate
@synthesize rootController = _rootController;
@synthesize tipNavController = _tipNavController;
@synthesize settingsNavController = _settingsNavController;
@synthesize upgradeNavController = _upgradeNavController;
@synthesize todayViewBill = _todayViewBill;
@synthesize tipViewController = _tipViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [MAImageCache sharedInstance];

    // Enable HockeyApp for crash reporting.
//    [self enableHockeyApp];

    // As a precaution, get the current user, which will create the current user if it's the first time the app is ran, which we may want to do since it will try to switch to the user in the DB. Otherwise, the DB instance will also try to access the current user
    NSString *currentUser = [MAUserUtil currentUser];
    DLog(@"Initial user: '%@'", currentUser);
    [MAUserUtil switchToUser:currentUser];

    // Accessing the shared instance will cause the settings to be loaded, which is needed for the Watch app in case the host app has not been loaded yet since this still gets called.
    [[MAUserUtil sharedInstance] loadSettings];

    CGRect frame = [UIScreen mainScreen].bounds;
    self.window = [[UIWindow alloc] initWithFrame:frame];
    self.rootController = [self setupTabBarController];
    [self.window setRootViewController:self.rootController];
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];

    // Change the tint color to change default color across the UI, like selected tab color, info color, etc.
    [MAAppearance setAppearance];
    self.window.tintColor = [MAAppearance foregroundColor];

    // Creating the shared session automatically starts WCSession.
    [MASessionDelegate sharedInstance];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    /*
    NSLog(@"applicationDidEnterBackground");
    self.bgTask = [application beginBackgroundTaskWithName:@"MyTask" expirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        NSLog(@"beginBackgroundTaskWithName");

        [application endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"dispatch_async");

        // Do the work associated with the task, preferably in chunks.
        if ( ! self.todayViewBill)
        {
            self.todayViewBill = [[MABill alloc] init];
        }
        else
        {
            // Test changing the bill amount to see if it changes.
            self.todayViewBill.bill = [NSNumber numberWithDouble:self.todayViewBill.bill.doubleValue + 5];
        }

        [application endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    });
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UITabBarController *)setupTabBarController
{
    MATipViewController *tipViewController;
    MASettingsViewController *settingsViewController;

    tipViewController = [[MATipViewController alloc] initWithNibName:@"MATipViewController" bundle:nil];
    settingsViewController = [[MASettingsViewController alloc] initWithNibName:@"MASettingsViewController" bundle:nil];

    tipViewController.title = Localize(@"Check");
    settingsViewController.title = Localize(@"Settings");

    tipViewController.tabBarItem.image = [UIImage imageNamed:@"704-compose.png"];
    tipViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"704-compose-selected.png"];
    settingsViewController.tabBarItem.image = [UIImage imageNamed:@"740-gear.png"];
    settingsViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"740-gear-selected.png"];

    // Create the tab bar with the each view controller inside of a nav controller.
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    self.tipNavController = [[UINavigationController alloc] initWithRootViewController:tipViewController];
    self.settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithObjects:self.tipNavController, self.settingsNavController, nil];
//    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithObjects:tipViewController, self.settingsNavController, nil];

    tabBarController.viewControllers = viewControllers;
    
    // Note: tab and nav bar styles are set in MAAppearance.
    
    self.tipViewController = tipViewController;
    
    return tabBarController;
}

// Called by MAAppearance.
- (void)setBarStyle:(UIBarStyle)barStyle translucent:(BOOL)translucent
{
    self.tipNavController.navigationBar.barStyle = barStyle;
    self.tipNavController.navigationBar.translucent = translucent;
    
    self.settingsNavController.navigationBar.barStyle = barStyle;
    self.settingsNavController.navigationBar.translucent = translucent;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    DLog(@"application openURL");
    
    // Note: this is called after 'application didFinishLaunchingWithOptions' is called.
    if (url)
    {
        NSString *absPath = [url absoluteString];
//        NSString *pathExt = [absPath pathExtension];
//        pathExt = [pathExt lowercaseString];
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:Localize(@"Extension Opened")
//                              message:SFmt(@"%@", absPath)
//                              delegate:nil
//                              cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
//                              otherButtonTitles:nil];
//        [alert show];
        
        self.todayViewBill = [self billFromPath:absPath];
        [self.tipViewController viewWillAppear:YES];
    }
    
    return YES;
}

- (MABill *)billFromPath:(NSString *)path
{
    // Parse URL path like below into a MABill.
    // Tipity://bill=%f;tipPercent=%f
    NSArray *strings = [path componentsSeparatedByString:@"Tipity://"];
    if ( ! strings || strings.count <= 1)
    {
        return nil;
    }
    NSString *billString = [strings objectAtIndex:1];

    BOOL didNotParseAnyField = YES;
    MABill *bill = [[MABill alloc] init];
    strings = [billString componentsSeparatedByString:@";"];
    for (NSString *string in strings)
    {
        NSArray *keyValue = [string componentsSeparatedByString:@"="];
        if ( ! keyValue || keyValue.count != 2)
        {
            continue;
        }
        NSString *key = [keyValue objectAtIndex:0];
        NSString *value = [keyValue objectAtIndex:1];

        if ([key isEqualToString:@"bill"])
        {
            CGFloat doubleValue = value.doubleValue;
            bill.bill = [NSNumber numberWithDouble:doubleValue];
            didNotParseAnyField = NO;
        }
        else if ([key isEqualToString:@"tipPercent"])
        {
            CGFloat doubleValue = value.doubleValue;
            bill.tipPercent = [NSNumber numberWithDouble:doubleValue];
            didNotParseAnyField = NO;
        }
    }

    if (didNotParseAnyField)
    {
        return nil;
    }

    return bill;
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply
{
    // Note: on actual devices, this gets called in the background on the host/iPhone app, but on the simulator, it actually launches the app into the foreground.
    // So, we do not actually need to load the bill here since the bill is loaded from the shared app container when the app is launched already.
//    return;
    
    //
    // Test handleWatchKitExtensionRequest.
    self.todayViewBill = [MABill reloadSharedInstance:YES];
    [self.tipViewController viewWillAppear:YES];

//    self.todayViewBill = [[MABill alloc] init];
    
    NSLog(@"handleWatchKitExtensionRequest: %@", userInfo);
    
    // Execute reply block and pass in another dictionary to send data to the watch extension.
    NSData *encodedBill = [NSKeyedArchiver archivedDataWithRootObject:[MABill sharedInstance]];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:encodedBill forKey:@"bill"];
    reply(dictionary);
     //
}

@end
