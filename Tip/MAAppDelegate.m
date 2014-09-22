//
//  AppDelegate.m
//  Unit Price
//
//  Created by Wade Spires on 8/29/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import "MAAppDelegate.h"

#import "MAAppearance.h"
#import "MATipViewController.h"
#import "MASettingsViewController.h"
#import "MATipIAPHelper.h"
#import "MAUpgradeViewController.h"
#import "MAUserUtil.h"
#import "MAUtil.h"

//#import <HockeySDK/HockeySDK.h>
#import "Appirater.h"

@interface MAAppDelegate ()

@end

@implementation MAAppDelegate
@synthesize rootController = _rootController;
@synthesize tipNavController = _tipNavController;
@synthesize settingsNavController = _settingsNavController;
@synthesize upgradeNavController = _upgradeNavController;
@synthesize imageCache = _imageCache;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _imageCache = [[NSCache alloc] init];

    // As soon as your app launches it will create the singleton MAWeightLogIAPHelper. This means the initWithProducts: method you just modified will be called, which registers itself as the transaction observer. So you will be notified about any transactions that were never quite finished.
    // http://www.raywenderlich.com/21081/introduction-to-in-app-purchases-in-ios-6-tutorial
    BOOL const productPurchased = [MATipIAPHelper ProProductPurchased];
    if ( ! productPurchased)
    {
        [MATipIAPHelper sharedInstance]; // Instantiates the IAP helper, which will also initiate loading the products.
    }

    // Enable HockeyApp for crash reporting.
//    [self enableHockeyApp];

    // As a precaution, get the current user, which will create the current user if it's the first time the app is ran, which we may want to do since it will try to switch to the user in the DB. Otherwise, the DB instance will also try to access the current user
    NSString *currentUser = [MAUserUtil currentUser];
    DLog(@"Initial user: '%@'", currentUser);
    [MAUserUtil switchToUser:currentUser];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.rootController = [self setupTabBarController];
    [self.window setRootViewController:self.rootController];
    
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];

    // Change the tint color to change default color across the UI, like selected tab color, info color, etc.
    [MAAppearance setAppearance];
    if (ABOVE_IOS7)
    {
        self.window.tintColor = [MAAppearance foregroundColor];
    }

    [Appirater appLaunched:YES];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
    MAUpgradeViewController *upgradeViewController;
    
    tipViewController = [[MATipViewController alloc] initWithNibName:@"MATipViewController" bundle:nil];
    settingsViewController = [[MASettingsViewController alloc] initWithNibName:@"MASettingsViewController" bundle:nil];
    upgradeViewController = [[MAUpgradeViewController alloc] initWithNibName:@"MAUpgradeViewController" bundle:nil];
    
    tipViewController.title = Localize(@"Check");
    settingsViewController.title = Localize(@"Settings");
    upgradeViewController.title = Localize(@"Upgrade");
    
    tipViewController.tabBarItem.image = [UIImage imageNamed:@"704-compose.png"];
    tipViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"704-compose-selected.png"];
    settingsViewController.tabBarItem.image = [UIImage imageNamed:@"740-gear.png"];
    settingsViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"740-gear-selected.png"];
    upgradeViewController.tabBarItem.image = [UIImage imageNamed:@"952-shopping-cart.png"];
    upgradeViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"952-shopping-cart-selected.png"];

    // Create the tab bar with the each view controller inside of a nav controller.
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    self.tipNavController = [[UINavigationController alloc] initWithRootViewController:tipViewController];
    self.settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    self.upgradeNavController = [[UINavigationController alloc] initWithRootViewController:upgradeViewController];
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithObjects:self.tipNavController, self.settingsNavController, nil];
//    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithObjects:tipViewController, self.settingsNavController, nil];

    BOOL const productPurchased = [MATipIAPHelper ProProductPurchased];
    if ( ! productPurchased)
    {
        [viewControllers addObject:self.upgradeNavController];
    }
    
    tabBarController.viewControllers = viewControllers;
    
    // Note: tab and nav bar styles are set in MAAppearance.
    
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

/*
- (void)enableHockeyApp
{
    // TODO: Changed identifier (copied from another app).
    NSString *identifier = @"7a7c13d7615c53c2d6dba3432b822656";
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:identifier];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
}
 */

@end
