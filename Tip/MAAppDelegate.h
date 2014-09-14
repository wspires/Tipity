//
//  AppDelegate.h
//  Unit Price
//
//  Created by Wade Spires on 8/29/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *rootController;
@property (strong, nonatomic) UINavigationController *productsNavController;
@property (strong, nonatomic) UINavigationController *settingsNavController;
@property (strong, nonatomic) UINavigationController *upgradeNavController;

@property (strong, readonly, nonatomic) NSCache *imageCache;

- (void)setBarStyle:(UIBarStyle)barStyle translucent:(BOOL)translucent;

@end

