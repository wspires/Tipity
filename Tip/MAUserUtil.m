//
//  MAUserUtil.m
//  Weight Log
//
//  Created by Wade Spires on 6/26/13.
//  Copyright (c) 2013 Wade Spires. All rights reserved.
//

#import "MAUserUtil.h"

#import "MAAppGroup.h"
#import "MADateUtil.h"
#import "MAFilePaths.h"
#import "MAUtil.h"
#import "UIColor+ExtraColors.h"
#import "MAAppDelegate.h"
#import "MATipIAPHelper.h"

// TODO: Make thread-safe and add a sharedInstance with instance methods (like MAActivity) instead of static methods.

static NSString * CurrentUser = nil;
static NSString * const DefaultUserName = @"";
static NSString * const DefaultVisibleUserName = @"Default";

// Base name for file containing current user.
static NSString * const User = @"User";

// Base name for file containing user list.
static NSString * const UserListName = @"UserList.plist";

// Base name for file containing settings.
static NSString * const SettingsName = @"Settings";

static NSString * const DefaultServiceRatingFair = @"10";
static NSString * const DefaultServiceRatingGood = @"15";
static NSString * const DefaultServiceRatingGreat = @"20";

static NSString * const DefaultBackgroundColorId = @"cloth";
static NSString * const DefaultForegroundColorId = @"denimBlueColor";

//static NSString * const DefaultCustomBackgroundColor = @"13486537"; // Converted snow3Color from hex.
static NSString * const DefaultCustomBackgroundColor = @"15725299"; // Converted snow5Color from hex.
static NSString * const DefaultCustomForegroundColor = @"26316"; // Converted denimBlueColor from hex.
static NSString * const DefaultCustomBackgroundImage = @"cloth";
static NSString * const CustomBackgroundImageName = @"customBackgroundImage.png";

static NSString * const DefaultButtonTextFont = @"32";
static NSString * const DefaultButtonTextColor = LightColorString;
static NSString * const DefaultButtonTextSize = @"20";

static NSString * const DefaultTableTextFont = @"Helvetica";
static NSString * const DefaultTableTextSize = @"20";
static NSString * const DefaultTableTextColor = DarkColorString;

static NSString *PerRoutineSettingsKey = @"perRoutineSettings";
static NSString *PerExerciseSettings = @"perExerciseSettings";

@implementation MAUserUtil
@synthesize settings = _settings;
@synthesize user = _user;

+ (MAUserUtil *)sharedInstance
{
    static dispatch_once_t once;
    static MAUserUtil * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        _user = [[MAUserUtil currentUser] copy];
        [self loadSettings];
    }
    return self;
}


- (void)setUser:(NSString *)user
{
    if (!user)
    {
        user = [MAUserUtil defaultUserName];
    }
    _user = [user copy];
    
    if (![MAUserUtil userExists:_user])
    {
        [MAUserUtil addUser:_user];
    }

    // Only write to the current user file if is the shared instance.
    id sharedInstance = [MAUserUtil sharedInstance];
    if (self == sharedInstance)
    {
        BOOL success = NO;
        NSError *error = nil;
        success = [user writeToFile:[MAUserUtil userFilePath] atomically:YES encoding:NSUnicodeStringEncoding error:&error];
        NSAssert(success, @"Failed to switch to user '%@'", user);
    }
    
    [MAUserUtil switchSettingsToUser:_user];
}

- (NSDictionary *)loadSettings
{
    _settings = [MAUserUtil loadSettings];
    return _settings;
}

- (id)objectForKey:(NSString *)key
{
    return [_settings objectForKey:key];
}

// Get the given per-exercise or per-routine setting where perDictSettingsKey is PerExerciseSettings or PerRoutineSettingsKey and nameKey is either the exercise or routine name, respectively. If there is no per-exercise or -routine setting, then nil is returned.
- (id)objectForKey:(NSString *)key perDictSettingsKey:(NSString *)perDictSettingsKey nameKey:(NSString *)nameKey
{
    if ( ! perDictSettingsKey || ! nameKey)
    {
        return nil;
    }
    
    NSDictionary *perDictSettings = [self objectForKey:perDictSettingsKey];
    if ( ! perDictSettings)
    {
        return nil;
    }
    
    NSDictionary *settings = [perDictSettings objectForKey:nameKey];
    if ( ! settings)
    {
        return nil;
    }
    
    id setting = [settings objectForKey:key];
    return setting;
}

- (BOOL)saveSettings
{
    [self saveSettingsToSharedDefaults];
    NSString *path = [MAUserUtil settingsFilePath];
    return [_settings writeToFile:path atomically:YES];
}

- (BOOL)saveSettingsToSharedDefaults
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:AppGroup];
    [sharedDefaults setObject:_settings forKey:@"settings"];
    BOOL saved = [sharedDefaults synchronize];
    if ( ! saved)
    {
        TLog(@"Failed to save settings to sharedDefaults");
    }
    return saved;
}

+ (NSDictionary *)loadSettingsFromSharedDefaults
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:AppGroup];
    NSDictionary *settings = [sharedDefaults dictionaryForKey:@"settings"];
    return settings;
}

- (NSDictionary *)saveSetting:(id)setting forKey:(NSString *)key
{
    NSMutableDictionary *newSettings = [[NSMutableDictionary alloc] initWithDictionary:_settings];
    [newSettings setObject:setting forKey:key];
    _settings = newSettings;
    [self saveSettings];
    return newSettings;
}

- (BOOL)enableSplit
{
    NSString *enableStr = [self objectForKey:EnableSplit];
    BOOL const enable = [MAUtil isStringOn:enableStr];
    return enable;
}
- (void)setEnableSplit:(BOOL)enable
{
    NSString *value = @"off";
    if (enable)
    {
        value = @"on";
    }
    [self saveSetting:value forKey:EnableSplit];
}

- (BOOL)enableTax
{
    NSString *enableStr = [self objectForKey:EnableTax];
    BOOL const enable = [MAUtil isStringOn:enableStr];
    return enable;
}
- (void)setEnableTax:(BOOL)enable
{
    NSString *value = @"off";
    if (enable)
    {
        value = @"on";
    }
    [self saveSetting:value forKey:EnableTax];
}

- (BOOL)enableServiceRating
{
    NSString *enableStr = [self objectForKey:EnableServiceRating];
    BOOL const enable = [MAUtil isStringOn:enableStr];
    return enable;
}
- (void)setEnableServiceRating:(BOOL)enable
{
    NSString *value = @"off";
    if (enable)
    {
        value = @"on";
    }
    [self saveSetting:value forKey:EnableServiceRating];
}

- (NSNumber *)serviceRatingFair
{
    NSString *rating = [self objectForKey:ServiceRatingFair];
    NSNumber *number = [NSNumber numberWithDouble:[rating doubleValue]];
    return number;
}
- (NSNumber *)serviceRatingGood
{
    NSString *rating = [self objectForKey:ServiceRatingGood];
    NSNumber *number = [NSNumber numberWithDouble:[rating doubleValue]];
    return number;
}
- (NSNumber *)serviceRatingGreat
{
    NSString *rating = [self objectForKey:ServiceRatingGreat];
    NSNumber *number = [NSNumber numberWithDouble:[rating doubleValue]];
    return number;
}

- (NSDictionary *)saveSetting:(id)setting forKey:(NSString *)key perDictSettingsKey:(NSString *)perDictSettingsKey nameKey:(NSString *)nameKey
{
    if ( ! perDictSettingsKey || ! nameKey)
    {
        // No individual key, so just save as a general setting.
        return [self saveSetting:setting forKey:key];
    }
    
    NSMutableDictionary *newSettings = [NSMutableDictionary dictionaryWithDictionary:_settings];
    
    NSMutableDictionary *perDictSettings = [self objectForKey:perDictSettingsKey];
    if ( ! perDictSettings)
    {
        perDictSettings = [[NSMutableDictionary alloc] init];
    }
    else
    {
        perDictSettings = [NSMutableDictionary dictionaryWithDictionary:perDictSettings];
    }
    
    NSMutableDictionary *settings = [perDictSettings objectForKey:nameKey];
    if ( ! settings)
    {
        settings = [NSMutableDictionary dictionary];
    }
    else
    {
        settings = [NSMutableDictionary dictionaryWithDictionary:settings];
    }
    
    [settings setObject:setting forKey:key];
    [perDictSettings setObject:settings forKey:nameKey];
    [newSettings setObject:perDictSettings forKey:perDictSettingsKey];
    
    _settings = newSettings;
    [self saveSettings];
    return newSettings;
}

- (NSDictionary *)removeSettingsForPerDictSettingsKey:(NSString *)perDictSettingsKey nameKey:(NSString *)nameKey
{
    if ( ! perDictSettingsKey || ! nameKey)
    {
        return _settings;
    }
    
    NSMutableDictionary *newSettings = [NSMutableDictionary dictionaryWithDictionary:_settings];
    
    NSMutableDictionary *perDictSettings = [self objectForKey:perDictSettingsKey];
    if ( ! perDictSettings)
    {
        return _settings;
    }
    else
    {
        perDictSettings = [NSMutableDictionary dictionaryWithDictionary:perDictSettings];
    }
    
    NSMutableDictionary *settings = [perDictSettings objectForKey:nameKey];
    if ( ! settings)
    {
        return _settings;
    }
    
    [perDictSettings removeObjectForKey:nameKey];
    if (perDictSettings.count == 0)
    {
        // No more individual settings left, so remove the dict entirely.
        [newSettings removeObjectForKey:perDictSettingsKey];
    }
    else
    {
        [newSettings setObject:perDictSettings forKey:perDictSettingsKey];
    }
    
    _settings = newSettings;
    [self saveSettings];
    return newSettings;
}

#pragma mark Current user

+ (NSString *)defaultUserName
{
    return DefaultUserName;
}

+ (BOOL)isDefaultUser:(NSString *)user
{
    return (!user || [user isEqualToString:[MAUserUtil defaultUserName]]);
}

+ (NSString *)defaultVisibleUserName
{
    return Localize(DefaultVisibleUserName);
}

+ (NSString *)userFilePath
{
    // Note: not contained in users dir to ensure that the name does not happen to conflict with an actual user's files, albeit unlikely.
    return [[MAFilePaths docDir] stringByAppendingPathComponent:User];
}

+ (NSString *)usersDir
{
    NSString *path = [[MAFilePaths docDir] stringByAppendingPathComponent:@"Users"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    return path;
}

// Creates path like Users/Wade. Note that not all files, like the settings, are not contained in the per-user directory because it was not done this way to start. 
+ (NSString *)dirForUser:(NSString *)user
{
    NSString *usersDir = [MAUserUtil usersDir];
    NSString *path = [usersDir stringByAppendingPathComponent:user];
    return path;
}

+ (NSString *)makeDirForUser:(NSString *)user
{
    NSString *usersDir = [MAUserUtil usersDir];
    NSString *path = [usersDir stringByAppendingPathComponent:user];
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    return path;
}

+ (NSString *)illegalCharacters
{
    return @"/\\?%*|\"<>";
}

+ (BOOL)userHasValidCharacters:(NSString *)user
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:[MAUserUtil illegalCharacters]];
    NSRange range = [user rangeOfCharacterFromSet:set];
    BOOL isValid = (range.location == NSNotFound);
    return isValid;
}

+ (NSString *)sanitizeFileName:(NSString *)fileName
{
    // TODO: Remove leading dots to avoid hidden names, e.g., no ".foo.plist".
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:[MAUserUtil illegalCharacters]];
    fileName = [[fileName componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
    return fileName;
}

+ (NSString *)currentUser
{
    if (CurrentUser)
    {
        return CurrentUser;
    }
    
    NSString *path = [MAUserUtil userFilePath];
    NSError *error = nil;
    NSString *user = [NSString stringWithContentsOfFile:path encoding:NSUnicodeStringEncoding error:&error];
    if (!user)
    {
        // Assume that failure occurred because this file does not exist, so try creating it.
        user = [MAUserUtil defaultUserName];
        
        // Do not switch to the user if this is the first time running and the user file does not exist. The only time user should be nil is when the app is the first time the app is installed and opened, so we may get here if via the DB's sharedInstance. Since switchToUser: also accesses sharedInstance, it'll lead to a freeze.
        BOOL const noSuchFileError = ([error.domain isEqualToString:NSCocoaErrorDomain] && error.code == NSFileReadNoSuchFileError);
        if (!noSuchFileError)
        {
            NSLog(@"Error loading user (%@): using default user '%@'", error, [MAUserUtil defaultUserName]);
            [MAUserUtil switchToUser:user];
        }
    }
    
    CurrentUser = [user copy];
    return CurrentUser;
}

+ (BOOL)switchToUser:(NSString *)user
{
    if (!user)
    {
        user = [MAUserUtil defaultUserName];
    }
    
    if (![MAUserUtil userExists:user])
    {
        [MAUserUtil addUser:user];
    }
    
    CurrentUser = [user copy];
    
    BOOL success = NO;
    NSError *error = nil;
    success = [user writeToFile:[MAUserUtil userFilePath] atomically:YES encoding:NSUnicodeStringEncoding error:&error];
    NSAssert(success, @"Failed to switch to user '%@'", user);

    [MAUserUtil switchSettingsToUser:user];
    
    return success;
}

#pragma mark User list

+ (NSString *)userListFilePath
{
    return [[MAFilePaths docDir] stringByAppendingPathComponent:UserListName];
}

+ (NSArray *)loadUserList
{
    NSString *path = [MAUserUtil userListFilePath];
    if (![MAFilePaths regularFileExists:path])
    {
        return [[NSArray alloc] init];
    }
    return [[NSArray alloc] initWithContentsOfFile:path];
}

+ (BOOL)saveUserList:(NSArray *)userList
{
    return [userList writeToFile:[MAUserUtil userListFilePath] atomically:YES];
}

+ (BOOL)userExists:(NSString *)user
{
    if ([MAUserUtil isDefaultUser:user])
    {
        return YES;
    }
    
    NSArray *userList = [MAUserUtil loadUserList];
    for (NSString *thisUser in userList)
    {
        if ([thisUser isEqualToString:user])
        {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)addUser:(NSString *)user
{
    // Do not add default user.
    if ([MAUserUtil isDefaultUser:user])
    {
        return NO;
    }
    
    // Add user to list.
    NSMutableArray *newUserList = [[NSMutableArray alloc] init];
    NSArray *userList = [MAUserUtil loadUserList];
    for (NSString *thisUser in userList)
    {
        if ([thisUser isEqualToString:user])
        {
            // Do not add duplicates.
            return NO;
        }
        [newUserList addObject:thisUser];
    }
    [newUserList addObject:user];
    
    BOOL success = [newUserList writeToFile:[MAUserUtil userListFilePath] atomically:YES];
    if (!success)
    {
        NSLog(@"Failed to write to user file while adding user '%@'", user);
        return success;
    }

    [MAUserUtil makeDirForUser:user];

    success = [MAUserUtil addSettingsForUser:user];
    
    return success;
}

+ (BOOL)removeUser:(NSString *)user
{
    // Do not remove default user.
    if ([MAUserUtil isDefaultUser:user])
    {
        return NO;
    }
    
    // Remove user from list.
    NSMutableArray *newUserList = [[NSMutableArray alloc] init];
    NSArray *userList = [MAUserUtil loadUserList];
    for (NSString *thisUser in userList)
    {
        if ([thisUser isEqualToString:user])
        {
            // Skip user to remove.
            continue;
        }
        [newUserList addObject:thisUser];
    }
    
    BOOL success = NO;
    success = [newUserList writeToFile:[MAUserUtil userListFilePath] atomically:YES];
    NSAssert(success, @"Failed to write to user file while removing user '%@'", user);

    success = [MAUserUtil removeSettingsForUser:user];
    if (!success)
    {
        NSLog(@"Failed to remove settings for user '%@'", user);
    }
        
    // Remove user's dir.
    NSError *removeDirError = nil;
    NSString *userDir = [MAUserUtil dirForUser:user];
    success = [MAFilePaths erasePath:userDir error:&removeDirError];
    if (!success)
    {
        NSLog(@"Failed to remove user dir for user '%@': %@", user, removeDirError);
    }

    // Switch to default user if removing current user.
    // Should be done after updating DB and settings since they may need the old current user.
    if ([user isEqualToString:[MAUserUtil currentUser]])
    {
        BOOL success = NO;
        success = [MAUserUtil switchToUser:[MAUserUtil defaultUserName]];
        NSAssert(success, @"Failed to switch to user '%@' while removing user '%@'", [MAUserUtil defaultUserName], user);
    }
    
    return success;
}

+ (BOOL)renameUser:(NSString *)oldUser toUser:(NSString *)newUser;
{
    if ([oldUser isEqualToString:newUser])
    {
        return YES;
    }

    // Do not rename default user.
    if ([MAUserUtil isDefaultUser:oldUser] || [MAUserUtil isDefaultUser:newUser])
    {
        return NO;
    }
    
    // Do not rename user if the older user does not exist or if the new user already exists.
    if (![MAUserUtil userExists:oldUser] || [MAUserUtil userExists:newUser])
    {
        return NO;
    }

    // Remove user from list.
    NSMutableArray *newUserList = [[NSMutableArray alloc] init];
    NSArray *userList = [MAUserUtil loadUserList];
    for (NSString *thisUser in userList)
    {
        if ([thisUser isEqualToString:oldUser])
        {
            // Replace old user with new user.
            [newUserList addObject:newUser];
            continue;
        }
        [newUserList addObject:thisUser];
    }
    
    BOOL success = NO;

    // Rename user dir so the routines get copied over, too.
    NSError *renameDirError = nil;
    NSString *oldDir = [MAUserUtil dirForUser:oldUser];
    NSString *newDir = [MAUserUtil dirForUser:newUser];
    success = [MAFilePaths renameDirPath:oldDir newPath:newDir error:&renameDirError];
    if (!success)
    {
        NSLog(@"Failed to rename user dir from user '%@' to user '%@': %@", oldUser, newUser, renameDirError);
    }

    success = [newUserList writeToFile:[MAUserUtil userListFilePath] atomically:YES];
    NSAssert(success, @"Failed to write to user file while renaming user '%@' to '%@'", oldUser, newUser);

    success = [MAUserUtil renameSettingsForUser:oldUser toUser:newUser];

    // Rename the current user if necessary.
    if ([oldUser isEqualToString:[MAUserUtil currentUser]])
    {
        CurrentUser = [newUser copy];
        
        NSError *error = nil;
        BOOL success = NO;
        success = [newUser writeToFile:[MAUserUtil userFilePath] atomically:YES encoding:NSUnicodeStringEncoding error:&error];
        NSAssert(success, @"Failed to rename user '%@' to '%@'", oldUser, newUser);
    }
    
    return success;
}

#pragma mark Settings

+ (NSString *)userSettingsName:(NSString *)name
{
    return SFmt(@"%@.plist", [MAUserUtil sanitizeFileName:name]);
}

+ (NSString *)userSettingsPath:(NSString *)user
{
    NSString *usersDir = [MAUserUtil usersDir];
    NSString *settingsName = [MAUserUtil userSettingsName:user];
    NSString *path = [usersDir stringByAppendingPathComponent:settingsName];
    return path;
}

+ (NSString *)settingsFilePath
{
    NSString *path = nil;
    NSString *user = [MAUserUtil currentUser];
    if ([MAUserUtil isDefaultUser:user])
    {
        path = [[MAFilePaths docDir] stringByAppendingPathComponent:SettingsName];
    }
    else
    {
        path = [MAUserUtil userSettingsPath:user];
    }
    return path;
}

+ (NSDictionary *)loadSettings
{
    NSString *path = [MAUserUtil settingsFilePath];
    if (![MAFilePaths regularFileExists:path])
    {
        // Create, save, and return default settings if they do not exist.
        NSMutableDictionary *settings = [MAUserUtil defaultSettings];
        [MAUserUtil saveSettings:settings];
        [MAUserUtil addNewSettings:settings];
        return settings;
    }
    
    // Load current settings and add any newly added options.
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    [MAUserUtil addNewSettings:settings];
    return settings;
}

+ (NSMutableDictionary *)defaultSettings
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    [settings setObject:[NSNumber numberWithInt:60] forKey:@"timer1RestTime"];
    [settings setObject:[NSNumber numberWithInt:30] forKey:@"timer2RestTime"];
        
    return settings;
}

// Update settings object with new default options for when the user updates as the settings already exists (so defaultSettings should not be called) but the new properties need to be added.
+ (void)addNewSettings:(NSMutableDictionary *)settings
{
    // Flag to determine if a new setting was set. If even one key is not found in the settings, then this flag will be set to YES, and settings should then be saved.
    BOOL updatedSettings = NO;

// Define macros for checking if a setting is set for a value and assigning a default value if not. Variable updatedSettings will be set to YES if a key was not previously set, so we know that the settings should be saved.
#define CHECK_SETTING(KEY, VALUE) \
    if ( ! [settings objectForKey:(KEY)]) \
    { \
        [settings setObject:(VALUE) forKey:(KEY)]; \
        updatedSettings = YES; \
    }
    
#define CHECK_SETTING_ON(KEY) \
    CHECK_SETTING((KEY), @"on")
    
#define CHECK_SETTING_OFF(KEY) \
    CHECK_SETTING((KEY), @"off")

    // Turn off some settings by default for the free version.
//    NSString *paidVersusFreeBoolValue = @"off";
    
    CHECK_SETTING_OFF(EnableSplit)
    CHECK_SETTING_OFF(EnableTax)
    CHECK_SETTING_ON(EnableServiceRating)
    CHECK_SETTING(ServiceRatingFair, DefaultServiceRatingFair)
    CHECK_SETTING(ServiceRatingGood, DefaultServiceRatingGood)
    CHECK_SETTING(ServiceRatingGreat, DefaultServiceRatingGreat)

    // Appearance settings.
    CHECK_SETTING(BackgroundColorId, [MAUserUtil defaultBackgroundColorId])
    CHECK_SETTING(ForegroundColorId, DefaultForegroundColorId)
    CHECK_SETTING(@"customBackgroundColor", DefaultCustomBackgroundColor)
    CHECK_SETTING(@"customForegroundColor", DefaultCustomForegroundColor)
    CHECK_SETTING(@"customBackgroundImage", DefaultCustomBackgroundImage)
    CHECK_SETTING(TabBarColor, [MAUserUtil defaultTabBarColor])
    CHECK_SETTING(ButtonTextColor, DefaultButtonTextColor)
    CHECK_SETTING(TableTextFont, DefaultTableTextFont)
    CHECK_SETTING(TableTextSize, DefaultTableTextSize)
    CHECK_SETTING(TableTextColor, DefaultTableTextColor)

    if (updatedSettings)
    {
        [MAUserUtil saveSettings:settings];
    }
    
    [MAUserUtil doubleCheckSettings:settings];
}

// Double-check that binary settings have either the value on or off since I released an update where it would be invalid when I added the cardio units because I forgot to reset the value back to on.
+ (BOOL)doubleCheckSettings:(NSMutableDictionary *)settings
{
    BOOL updatedSettings = NO;
    NSString *key = nil;
    NSString *value = @"on"; // Value to turn on given option.

    key = EnableSplit;
    value = [settings objectForKey:key];
    if ( ! [value isEqualToString:@"on"] && ! [value isEqualToString:@"off"])
    {
        value = @"off";
        NSLog(@"Invalid setting for %@: %@", key, value);
        [settings setObject:@"on" forKey:key];
        updatedSettings = YES;
    }

    key = EnableTax;
    value = [settings objectForKey:key];
    if ( ! [value isEqualToString:@"on"] && ! [value isEqualToString:@"off"])
    {
        value = @"off";
        NSLog(@"Invalid setting for %@: %@", key, value);
        [settings setObject:@"on" forKey:key];
        updatedSettings = YES;
    }

    key = EnableServiceRating;
    value = [settings objectForKey:key];
    if ( ! [value isEqualToString:@"on"] && ! [value isEqualToString:@"off"])
    {
        value = @"off";
        NSLog(@"Invalid setting for %@: %@", key, value);
        [settings setObject:@"on" forKey:key];
        updatedSettings = YES;
    }

    if (updatedSettings)
    {
        [MAUserUtil saveSettings:settings];
    }

    return updatedSettings;
}

+ (BOOL)saveSettings:(NSDictionary *)settings
{
    NSString *path = [MAUserUtil settingsFilePath];
    return [settings writeToFile:path atomically:YES];
}

+ (NSDictionary *)saveSetting:(id)setting forKey:(NSString *)key
{
    return [[MAUserUtil sharedInstance] saveSetting:setting forKey:key];
    
    
    /*
    NSDictionary *settings = [MAUserUtil loadSettings];
    NSMutableDictionary *newSettings = [[NSMutableDictionary alloc] initWithDictionary:settings];
    [newSettings setObject:setting forKey:key];
    [MAUserUtil saveSettings:newSettings];
    return newSettings;
     */
}

+ (BOOL)addSettingsForUser:(NSString *)user
{
    return YES;
}

+ (BOOL)switchSettingsToUser:(NSString *)user
{
    return YES;
}

+ (BOOL)removeSettingsForUser:(NSString *)user
{
    // Do not remove default user.
    if ([MAUserUtil isDefaultUser:user])
    {
        DLog(@"Cannot remove settings for default user '%@'", user);
        return NO;
    }
    
    // Switch to default user if removing current user.
    if ([user isEqualToString:[MAUserUtil currentUser]])
    {
        [MAUserUtil switchSettingsToUser:[MAUserUtil defaultUserName]];
    }
    
    NSString *path = [MAUserUtil userSettingsPath:user];
    if (![MAFilePaths regularFileExists:path])
    {
        return NO;
    }
    
    NSError *error = nil;
    BOOL success = [MAFilePaths erasePath:path error:&error];
    if (!success)
    {
        DLog(@"Failed to remove settings for user '%@'", user);
        return NO;
    }
    return success;
}

+ (BOOL)renameSettingsForUser:(NSString *)oldUser toUser:(NSString *)newUser
{
    NSString *oldPath = [MAUserUtil userSettingsPath:oldUser];
    if (![MAFilePaths regularFileExists:oldPath])
    {
        return NO;
    }
    
    NSString *newPath = [MAUserUtil userSettingsPath:newUser];
    
    NSError *error = nil;
    BOOL success = [MAFilePaths renamePath:oldPath newPath:newPath error:&error];
    if (!success)
    {
        DLog(@"Failed to rename settings for user '%@' to user '%@'", oldUser, newUser);
        return NO;
    }
    
    // Switch to settings if renamed current user.
    if ([oldUser isEqualToString:[MAUserUtil currentUser]])
    {
        [MAUserUtil switchSettingsToUser:newUser];
    }

    return success;
}

#pragma mark Custom image

+ (NSString *)defaultBackgroundColorId
{
    if (ABOVE_IOS7)
    {
        return @"snow5Color";
    }
    else
    {
        return @"cloth";
    }
    return DefaultBackgroundColorId;
}

+ (NSString *)defaultTabBarColor
{
    // Set tab bar color. iOS 7 should default to white unless user already has the app and expects the tab bar to still be black. It might make more sense to NOT check [MARunDate isFirstRun] and just force existing users to the light tab bar since they can change it in the settings.
    // New users should default to a light tab bar.
    //BOOL const addingNewUser = NO; // TODO: How to determine this?
    
    // Default
    NSString *defaultTabBarColor = @"dark";
    //if (ABOVE_IOS7 && ([MARunDate isFirstRun] || addingNewUser))
    if (ABOVE_IOS7)
    {
        defaultTabBarColor = @"light";
    }
    else // Not iOS 7 or user already has the app.
    {
        defaultTabBarColor = @"dark";
    }
    return defaultTabBarColor;
}

+ (NSString *)customBackgroundImageFilePath
{
    NSString *user = [MAUserUtil currentUser];
    NSString *usersDir = nil;
    if ([MAUserUtil isDefaultUser:user])
    {
        usersDir = [MAFilePaths docDir];
    }
    else
    {
        usersDir = [MAUserUtil dirForUser:user];
    }
    
    NSString *path = [usersDir stringByAppendingPathComponent:CustomBackgroundImageName];
    return path;
}

+ (UIImage *)customBackgroundImage
{
    NSString *customBackgroundImageFilePath = [MAUserUtil customBackgroundImageFilePath];
    UIImage *image = [MAFilePaths imageFromFilePath:customBackgroundImageFilePath];
    return image;
}

+ (void)saveImage:(UIImage *)image
{
    NSString *customBackgroundImageFilePath = [MAUserUtil customBackgroundImageFilePath];
    [MAFilePaths saveImage:image withFilePath:customBackgroundImageFilePath];
}

@end
