//
//  MAUserUtil.h
//  Weight Log
//
//  Created by Wade Spires on 6/26/13.
//  Copyright (c) 2013 Wade Spires. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *EnableSplit = @"enableSplit";
static NSString *EnableTax = @"enableTax";
static NSString *EnableServiceRating = @"enableServiceRating";
static NSString *ServiceRatingFair = @"serviceRatingFair";
static NSString *ServiceRatingGood = @"serviceRatingGood";
static NSString *ServiceRatingGreat = @"serviceRatingGreat";

static NSString *BackgroundColorId = @"backgroundColorId";
static NSString *ForegroundColorId = @"foregroundColorId";

static NSString *TabBarColor = @"tabBarColor";

static NSString *ButtonTextFont = @"buttonTextFont";
static NSString *ButtonTextSize = @"buttonTextSize";
static NSString *ButtonTextColor = @"buttonTextColor";

static NSString *TableTextFont = @"tableTextFont";
static NSString *TableTextSize = @"tableTextSize";
static NSString *TableTextColor = @"tableTextColor";

#define WhiteColorString @"0xffffff"
#define BlackColorString @"0x000000"
#define LightColorString WhiteColorString;
#define DarkColorString BlackColorString;

@interface MAUserUtil : NSObject

@property (copy, nonatomic) NSString *user;
@property (strong, readonly, nonatomic) NSDictionary *settings;

// Shared instance to easily share the same settings object.
+ (MAUserUtil *)sharedInstance;

- (id)init;
- (NSDictionary *)loadSettings;
- (id)objectForKey:(NSString *)key;
- (BOOL)saveSettings;
- (NSDictionary *)saveSetting:(id)setting forKey:(NSString *)key;

#pragma mark BOOL settings
- (BOOL)enableSplit;
- (void)setEnableSplit:(BOOL)enable;
- (BOOL)enableTax;
- (void)setEnableTax:(BOOL)enable;
- (BOOL)enableServiceRating;
- (void)setEnableServiceRating:(BOOL)enable;
- (NSNumber *)serviceRatingFair;
- (NSNumber *)serviceRatingGood;
- (NSNumber *)serviceRatingGreat;

#pragma mark Current user
+ (NSString *)defaultUserName;
+ (BOOL)isDefaultUser:(NSString *)user;
+ (NSString *)defaultVisibleUserName;
+ (NSString *)userFilePath;
+ (NSString *)usersDir;
+ (NSString *)illegalCharacters;
+ (BOOL)userHasValidCharacters:(NSString *)user;
+ (NSString *)sanitizeFileName:(NSString *)fileName;
+ (NSString *)currentUser;
+ (BOOL)switchToUser:(NSString *)user;

#pragma mark User list
+ (NSString *)userListFilePath;
+ (NSArray *)loadUserList;
+ (BOOL)saveUserList:(NSArray *)userList;
+ (BOOL)userExists:(NSString *)user;
+ (BOOL)addUser:(NSString *)user;
+ (BOOL)removeUser:(NSString *)user;
+ (BOOL)renameUser:(NSString *)oldUser toUser:(NSString *)newUser;

#pragma mark Settings
+ (NSString *)settingsFilePath;
+ (NSDictionary *)loadSettings;
+ (NSMutableDictionary *)defaultSettings;
+ (BOOL)saveSettings:(NSDictionary *)settings;
+ (NSDictionary *)saveSetting:(id)setting forKey:(NSString *)key;

#pragma mark Custom image
+ (NSString *)defaultBackgroundColorId;
+ (NSString *)customBackgroundImageFilePath;
+ (UIImage *)customBackgroundImage;
+ (void)saveImage:(UIImage *)image;

@end
