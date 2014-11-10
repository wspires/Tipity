//
//  MAFilePaths.m
//  Gym Log
//
//  Created by Wade Spires on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAFilePaths.h"
#import "MAUtil.h"
#import "MAImageCache.h"
#import "MAAppearance.h"
#import "UIColor+ExtraColors.h"
#import "UIImage+Gradient.h"
#include "MAAppDelegate.h"

static NSString * const BackgroundImageNamePhone = @"Cloth - iPhone.png";
static NSString * const BackgroundImageNamePad = @"Cloth - iPad.png";

static NSString * const RoutinesListName = @"RoutinesList";
static NSString * const RoutinesDirName = @"Routines";
static NSString * const SettingsName = @"Settings";
static NSString * const ActivitiesName = @"Activities";
static NSString * const ExerciseFilterName = @"ExerciseFilterName";

@implementation MAFilePaths

+ (NSString *)backgroundImageName
{
    if ([MAUtil iPad])
    {
        return BackgroundImageNamePad;
    }
    else
    {
        return BackgroundImageNamePhone;
    }
}

+ (NSString *)docDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    // Only 1 path is ever returned.
    return [paths objectAtIndex:0];
}

+ (NSString *)tmpDir
{
    return NSTemporaryDirectory();
}

+ (BOOL)regularFileExists:(NSString *)path
{
    // Verify that the path exists and is not a directory.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory])
    {
        return NO;
    }
    if (isDirectory)
    {
        return NO;
    }
    return YES;
}

+ (BOOL)directoryExists:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
    if (!exists)
    {
        return NO;
    }
    return isDirectory;
}

// Erase file path if the file exists and is not a directory.
// Returns YES if no error occurred when removing the path.
+ (BOOL)erasePath:(NSString *)path error:(NSError **)error
{
    BOOL pathExists = [MAFilePaths regularFileExists:path];
    if (!pathExists)
    {
        return YES;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:path error:error];
}

// Erase file path if the file exists and IS a directory.
// Returns YES if no error occurred when removing the path.
+ (BOOL)eraseDirPath:(NSString *)path error:(NSError **)error
{
    BOOL pathExists = [MAFilePaths directoryExists:path];
    if (!pathExists)
    {
        return YES;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:path error:error];
}

// Rename file path if the file exists.
// Returns YES if no error occurred when renaming the path.
+ (BOOL)renamePath:(NSString *)oldPath newPath:(NSString *)newPath error:(NSError **)error
{
    BOOL pathExists = [MAFilePaths regularFileExists:oldPath];
    if (!pathExists)
    {
        return YES;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager moveItemAtPath:oldPath toPath:newPath error:error];
    return result;
}

// Rename directory path if the file exists.
// Returns YES if no error occurred when renaming the path.
+ (BOOL)renameDirPath:(NSString *)oldPath newPath:(NSString *)newPath error:(NSError **)error
{
    BOOL pathExists = [MAFilePaths directoryExists:oldPath];
    if (!pathExists)
    {
        return YES;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager moveItemAtPath:oldPath toPath:newPath error:error];
}

+ (BOOL)swapPath:(NSString *)firstPath withPath:(NSString *)secondPath error:(NSError **)error
{
    // If one of the paths does not exist, then just treat it as renaming the path that does exist.
    BOOL firstPathExists = [MAFilePaths regularFileExists:firstPath];
    BOOL secondPathExists = [MAFilePaths regularFileExists:secondPath];
    if (!firstPathExists && !secondPathExists)
    {
        return NO;
    }
    else if (firstPathExists && !secondPathExists)
    {
        return [MAFilePaths renamePath:firstPath newPath:secondPath error:error];
    }
    else if (!firstPathExists && secondPathExists)
    {
        return [MAFilePaths renamePath:secondPath newPath:firstPath error:error];
    }
    else
    {
        // Both paths exist, which is handled below.
    }
    
    // Nothing to do if they are the same.
    if ([firstPath isEqualToString:secondPath])
    {
        return YES;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Construct path to a unique temporary file.
    // TODO: Use iOS facilities for getting the temp file.
    NSString *tmpPath = [firstPath copy];
    do
    {
        tmpPath = [NSString stringWithFormat:@"%@.tmp", tmpPath];
    }
    while ([MAFilePaths regularFileExists:tmpPath]);
    
    // Backup the first file.
    BOOL success = [fileManager moveItemAtPath:firstPath toPath:tmpPath error:error];
    if (!success)
    {
        return NO;
    }
    
    // Move second file to the first file, restoring the first file if an error occurs.
    success = [fileManager moveItemAtPath:secondPath toPath:firstPath error:error];
    if (!success)
    {
        // TODO: If this fails too, then the first file is lost. What to do?
        [fileManager moveItemAtPath:tmpPath toPath:firstPath error:nil];
        [MAFilePaths erasePath:tmpPath error:nil];
        return NO;
    }

    // Move first file (saved to the temp file path) to second file.
    // Regardless of an error, try to remove the temp file.
    success = [fileManager moveItemAtPath:tmpPath toPath:secondPath error:error];
    if (!success)
    {
        // If an error occurs, try to restore the original paths, though I would expect these to fail also if an error did occur while moving.
        [fileManager moveItemAtPath:firstPath toPath:secondPath error:nil];
        [fileManager moveItemAtPath:tmpPath toPath:firstPath error:nil];
        [MAFilePaths erasePath:tmpPath error:nil];
        return NO;
    }
    
    return YES;
}

+ (NSString *)activitiesFileDir
{
    NSString *path = [[MAFilePaths docDir]
            stringByAppendingPathComponent:ActivitiesName];
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    return path;
}

+ (NSString *)activitiesFilePath:(NSString *)uid
{
    NSString *path = [MAFilePaths activitiesFileDir];
    path = [path stringByAppendingPathComponent:uid];
    return path;
}

+ (NSString *)soundFilePath:(NSString *)baseName
{
    return [[NSBundle mainBundle] pathForResource:baseName ofType:@"caf"];
}

+ (NSString *)alertSoundsFilePath
{
    return [[NSBundle mainBundle] pathForResource:@"AlertSounds" ofType:@"plist"];
}

+ (NSArray *)loadAlertSounds
{
    NSString *path = [MAFilePaths alertSoundsFilePath];
    if (![MAFilePaths regularFileExists:path])
    {
        return [[NSArray alloc] init];
    }
    
    NSMutableArray *sounds = [[NSMutableArray alloc] initWithContentsOfFile:path];
    for (int i = 0; i != sounds.count; ++i)
    {
        NSMutableArray *soundInfo = [NSMutableArray arrayWithArray:[sounds objectAtIndex:i]];
        
        NSString *soundName = [soundInfo objectAtIndex:0];
        soundName = Localize(soundName);
        [soundInfo setObject:soundName atIndexedSubscript:0];
        
        [sounds setObject:soundInfo atIndexedSubscript:i];
    }

    return sounds;
}

+ (NSString *)preloadedRoutinesFilePath
{
    return [[NSBundle mainBundle] pathForResource:@"PreloadedRoutines" ofType:@"plist"];
}

+ (NSString *)helpFile
{
    return [[NSBundle mainBundle] pathForResource:@"Help" ofType:@"html"];
}

+ (NSString *)helpTopicsFile
{
    return [[NSBundle mainBundle] pathForResource:@"HelpTopics" ofType:@"plist"];
}

+ (NSArray *)loadHelpTopics
{
    NSMutableArray *helpTopics = [[NSMutableArray alloc] initWithContentsOfFile:[MAFilePaths helpTopicsFile]];
    return helpTopics;
}

+ (NSString *)creditsFile
{
    return [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"html"];
}

+ (NSString *)equipmentFilePath
{
    return [[NSBundle mainBundle] pathForResource:@"ExerciseEquipmentList" ofType:@"plist"];
}

+ (NSArray *)loadEquipmentList
{
    NSString *path = [MAFilePaths equipmentFilePath];
    if (![MAFilePaths regularFileExists:path])
    {
        return [[NSArray alloc] init];
    }
    NSArray *list = [[NSArray alloc] initWithContentsOfFile:path];
    list = [MAUtil localizeArray:list];
    return list;
}

+ (NSArray *)loadNoBodyweightEquipmentList
{
    // Load equipment list but exclude Bodyweight so that it will be the default if nothing is checked.
    NSArray *equipmentList = [MAFilePaths loadEquipmentList];
    NSMutableArray *noBodyWeightEquipmentList = [[NSMutableArray alloc] init];
    for (NSString *equipment in equipmentList)
    {
        if ([equipment isEqualToString:Localize(@"Bodyweight")])
        {
            continue;
        }
        [noBodyWeightEquipmentList addObject:equipment];
    }
    return noBodyWeightEquipmentList;
}

+ (NSString *)exerciseFilterFilePath
{
    return [[MAFilePaths docDir]
            stringByAppendingPathComponent:ExerciseFilterName];
}

+ (NSMutableDictionary *)exerciseFilter
{
    NSString *path = [MAFilePaths exerciseFilterFilePath];
    if (![MAFilePaths regularFileExists:path])
    {
        NSMutableDictionary *filter = [MAFilePaths defaultExerciseFilter];
        [MAFilePaths saveFilter:filter];
        return filter;
    }
    return [[NSMutableDictionary alloc] initWithContentsOfFile:path];
}

+ (NSMutableDictionary *)defaultExerciseFilter
{
    NSMutableDictionary *filter = [[NSMutableDictionary alloc] init];
    [filter setObject:[NSNumber numberWithBool:YES] forKey:@"builtin"];
    [filter setObject:[NSNumber numberWithBool:YES] forKey:@"custom"];
    
    NSArray *equipmentList = [MAFilePaths loadEquipmentList];
    for (NSString *equipment in equipmentList)
    {
        [filter setObject:[NSNumber numberWithBool:YES] forKey:equipment];
    }
    
    return filter;
}

+ (BOOL)saveFilter:(NSDictionary *)filter
{
    NSString *path = [MAFilePaths exerciseFilterFilePath];
    return [filter writeToFile:path atomically:YES];
}

// Apply any standard effects to the image before displaying it.
+ (UIImage *)applyEffectsToImagePath:(NSString *)path
{
    // Applying the image effects uses memory and CPU, so cache the image.
    UIImage *image = [[MAImageCache sharedInstance] objectForKey:path];
    if ( ! image)
    {
        image = [UIImage imageNamed:path];
        if ( ! image)
        {
            NSLog(@"Image not found: %@", path);
            return nil;
        }
        image = [MAFilePaths applyEffectsToImage:image];
        // Note that, unlike NSMutableDictionary, NSCache does not copy the key--need to verify whether the key should be copied or not.
        if (image)
        {
            [[MAImageCache sharedInstance] setObject:image forKey:path];
        }
    }
    return image;
}
+ (UIImage *)applyEffectsToImage:(UIImage *)image
{
    //return [MAAppearance tintedImageNamed:image];
    return [MAAppearance imageWithForegroundGradient:image];
}

+ (UIImage *)imageFromCacheAtPath:(NSString *)path
{
    // Applying the image effects uses memory and CPU, so cache the image.
    UIImage *image = [[MAImageCache sharedInstance] objectForKey:path];
    if ( ! image)
    {
        image = [UIImage imageNamed:path];
        // Note that, unlike NSMutableDictionary, NSCache does not copy the key--need to verify whether the key should be copied or not.
        [[MAImageCache sharedInstance] setObject:image forKey:path];
    }
    return image;
}

+ (NSString *)appearanceImageFilename
{
    //    return @"1402304374_bg_color.png";
    return @"949-paint-brush.png";
    //    return @"657-paint-bucket.png";
    //    return @"1017-paint-roller.png";
}
+ (UIImage *)appearanceImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths appearanceImageFilename]];
}

#pragma mark - Tip icons

+ (NSString *)billImageFilename
{
    return @"887-notepad.png";
}
+ (UIImage *)billImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths billImageFilename]];
}

+ (NSString *)tipPercentImageFilename
{
    return @"pie_chart.png";
//    return @"percent.png";
}
+ (UIImage *)tipPercentImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths tipPercentImageFilename]];
}

+ (NSString *)tipAmountImageFilename
{
    return @"826-money-1.png";
}
+ (UIImage *)tipAmountImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths tipAmountImageFilename]];
}

+ (NSString *)totalImageFilename
{
    return @"827-money-2.png";
}
+ (UIImage *)totalImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths totalImageFilename]];
}

+ (NSString *)peopleImageFilename
{
    return @"people.png";
//    return @"895-user-group.png";
}
+ (UIImage *)peopleImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths peopleImageFilename]];
}

+ (NSString *)splitTipFilename
{
    return @"973-user-tip.png";
}
+ (UIImage *)splitTipImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths splitTipFilename]];
}

+ (NSString *)splitTotalFilename
{
    return @"973-user-total.png";
}
+ (UIImage *)splitTotalImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths splitTotalFilename]];
}

+ (NSString *)taxPercentImageFilename
{
    return @"pie_chart.png";
//    return @"percent.png";
}
+ (UIImage *)taxPercentImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths taxPercentImageFilename]];
}

+ (NSString *)taxAmountImageFilename
{
//    return @"826-money-1.png";
//    return @"Postage_Stamp.png";
//    return @"561-stamp.png";
    return @"govt_bldg.png";
}
+ (UIImage *)taxAmountImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths taxAmountImageFilename]];
}

+ (NSString *)filledStarImageFilename
{
    return @"726-star-selected.png";
}
+ (UIImage *)filledStarImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths filledStarImageFilename]];
}

+ (NSString *)emptyStarImageFilename
{
    return @"726-star.png";
}
+ (UIImage *)emptyStarImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths emptyStarImageFilename]];
}

+ (NSString *)plusImageFilename
{
    return @"746-plus-circle.png";
}
+ (UIImage *)plusImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths plusImageFilename]];
}
+ (NSString *)plusImageSelectedFilename
{
    return @"746-plus-circle-selected.png";
}
+ (UIImage *)plusImageSelected
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths plusImageSelectedFilename]];
}

+ (NSString *)minusImageFilename
{
    return @"746-minus-circle.png";
}
+ (UIImage *)minusImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths minusImageFilename]];
}
+ (NSString *)minusImageSelectedFilename
{
    return @"746-minus-circle-selected.png";
}
+ (UIImage *)minusImageSelected
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths minusImageSelectedFilename]];
}

#pragma mark - Feedback icons

+ (NSString *)tellFriendImageFilename
{
    return @"702-share.png";
}
+ (UIImage *)tellFriendImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths tellFriendImageFilename]];
}

+ (NSString *)sendFeedbackImageFilename
{
    return @"712-reply.png";
}
+ (UIImage *)sendFeedbackImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths sendFeedbackImageFilename]];
}

+ (NSString *)writeReviewImageFilename
{
    return @"726-star.png";
}
+ (UIImage *)writeReviewImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths writeReviewImageFilename]];
}

+ (NSString *)creditsImageFilename
{
    return @"777-thumbs-up.png";
}
+ (UIImage *)creditsImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths creditsImageFilename]];
}

+ (NSString *)versionImageFilename
{
    return @"724-info.png";
}
+ (UIImage *)versionImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths versionImageFilename]];
}

+ (NSString *)historyImageFilename
{
    return @"item_list.png";
}
+ (UIImage *)historyImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths historyImageFilename]];
}

+ (NSString *)statsImageFilename
{
    return @"1380250962_Stats.png";
}
+ (UIImage *)statsImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths statsImageFilename]];
}

+ (NSString *)instructionsImageFilename
{
    //return @"1380271736_basic3-068_compose_new_document_write_edit.png";
    return @"1380310904_Icon_16.png";
}
+ (UIImage *)instructionsImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths instructionsImageFilename]];
}

+ (NSString *)customImageFilename
{
    return @"1380308490_Icon_25.png";
}
+ (UIImage *)customImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths customImageFilename]];
}

+ (NSString *)builtinImageFilename
{
    return @"1380308431_Icon_47.png";
}
+ (UIImage *)builtinImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths builtinImageFilename]];
}

+ (NSString *)startWorkoutImageFilename
{
    return @"1380332550_Button_3.png"; // Full-size is jaggy.
}
+ (UIImage *)startWorkoutImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths startWorkoutImageFilename]];
}

+ (NSString *)summaryImageFilename
{
    //return @"1380250962_Stats.png";
    return @"1380310904_Icon_16.png";
}
+ (UIImage *)summaryImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths summaryImageFilename]];
}

+ (NSString *)compareWorkoutsImageFilename
{
    return @"1380318238_Icon_34.png";
}
+ (UIImage *)compareWorkoutsImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths compareWorkoutsImageFilename]];
}

+ (NSString *)blankImageFilename
{
    return @"blank.png";
}
+ (UIImage *)blankImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths blankImageFilename]];
}

+ (NSString *)backgroundColorsFilePath
{
    return [[NSBundle mainBundle] pathForResource:@"BackgroundColors" ofType:@"plist"];
}

+ (NSArray *)loadBackgroundColors
{
    return [MAFilePaths loadColorsFromPath:[MAFilePaths backgroundColorsFilePath]];
}

+ (NSString *)foregroundColorsFilePath
{
    return [[NSBundle mainBundle] pathForResource:@"ForegroundColors" ofType:@"plist"];
}

+ (NSArray *)loadForegroundColors
{
    return [MAFilePaths loadColorsFromPath:[MAFilePaths foregroundColorsFilePath]];
}

+ (NSArray *)loadColorsFromPath:(NSString *)path
{
    if (![MAFilePaths regularFileExists:path])
    {
        return [[NSArray alloc] init];
    }
    
    NSMutableArray *colors = [[NSMutableArray alloc] initWithContentsOfFile:path];
    for (int i = 0; i != colors.count; ++i)
    {
        NSMutableDictionary *colorInfo = [NSMutableDictionary dictionaryWithDictionary:[colors objectAtIndex:i]];
        NSString *hexColor = [colorInfo objectForKey:@"hexColor"];
        if (hexColor)
        {
            // Use color from hex.
            unsigned int hexOut;
            NSScanner *scanner = [NSScanner scannerWithString:hexColor];
            [scanner scanHexInt:&hexOut];

            UIColor *color = [UIColor colorWithHex:hexOut];
            [colorInfo setObject:color forKey:@"color"];
        }
        else
        {
            NSArray *rgbColor = [colorInfo objectForKey:@"rgbColor"];
            if (rgbColor)
            {
                // Use color from RGBA.
                NSNumber *redNum = [rgbColor objectAtIndex:0];
                NSNumber *greenNum = [rgbColor objectAtIndex:1];
                NSNumber *blueNum = [rgbColor objectAtIndex:2];
                NSNumber *alphaNum = [[NSNumber alloc] initWithFloat:255.];
                if (rgbColor.count == 4)
                {
                    alphaNum = [rgbColor objectAtIndex:3];
                }
                CGFloat red = redNum.floatValue / 255.;
                CGFloat green = greenNum.floatValue / 255.;
                CGFloat blue = blueNum.floatValue / 255.;
                CGFloat alpha = alphaNum.floatValue / 255.;
                UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
                [colorInfo setObject:color forKey:@"color"];
            }
            else
            {
                // Use color from image.
                NSString *imageName = [colorInfo objectForKey:@"imageName"];
                
                // Handle built-in images that have different files for iPhone and iPad.
                // Note: custom images should not go in this file since it's shared for all users.
                NSString *isCustom = [colorInfo objectForKey:@"isCustom"];
                BOOL const shouldAppendDeviceSuffix = !isCustom || ![isCustom boolValue];
                if (shouldAppendDeviceSuffix)
                {
                    if ([MAUtil iPad])
                    {
                        // E.g., "Cloth - iPad.png"
                        imageName = SFmt(@"%@ - iPad.png", imageName);
                    }
                    else
                    {
                        imageName = SFmt(@"%@ - iPhone.png", imageName);
                    }
                }
                
                UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
                [colorInfo setObject:color forKey:@"color"];
            }
        }
        
        NSString *visibleName = [colorInfo objectForKey:@"visibleName"];
        visibleName = Localize(visibleName);
        [colorInfo setObject:visibleName forKey:@"visibleName"];
        
        [colors setObject:colorInfo atIndexedSubscript:i];
    }
    
    return colors;
}

+ (NSString *)weightUnitsFilePath
{
    return [[NSBundle mainBundle] pathForResource:@"WeightUnits" ofType:@"plist"];
}

+ (NSArray *)loadWeightUnits
{
    NSString *path = [MAFilePaths weightUnitsFilePath];
    NSMutableArray *properties = [[NSMutableArray alloc] initWithContentsOfFile:path];
    return properties;
}

+ (NSString *)distanceLogUnitsFilePath
{
    return [[NSBundle mainBundle] pathForResource:@"DistanceLogUnits" ofType:@"plist"];
}

+ (NSArray *)loadDistanceLogUnits
{
    NSString *path = [MAFilePaths distanceLogUnitsFilePath];
    NSMutableArray *properties = [[NSMutableArray alloc] initWithContentsOfFile:path];
    return properties;
}

+ (NSString *)weightLogUnitsFilePath
{
    return [[NSBundle mainBundle] pathForResource:@"WeightLogUnits" ofType:@"plist"];
}

+ (NSArray *)loadWeightLogUnits
{
    NSString *path = [MAFilePaths weightLogUnitsFilePath];
    NSMutableArray *properties = [[NSMutableArray alloc] initWithContentsOfFile:path];
    return properties;
}

+ (NSString *)weightLogImageFilename
{
    //return @"App Icon Weight";
    return @"1387804063_scale.png";
}
+ (UIImage *)weightLogImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths weightLogImageFilename]];
}

+ (NSString *)weightUnitImageFilename
{
    return @"1388724351_Weight.png";
}
+ (UIImage *)weightUnitImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths weightUnitImageFilename]];
}

+ (NSString *)rulerImageFilename
{
    return @"1387804534_ruler.png";
}
+ (UIImage *)rulerImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths rulerImageFilename]];
}

+ (NSString *)goalImageFilename
{
    return @"1390801984_target.png";
}
+ (UIImage *)goalImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths goalImageFilename]];
}

+ (NSString *)informationImageFilename
{
    return @"1402305764_icon-ios7-information-outline.png";
}
+ (UIImage *)informationImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths informationImageFilename]];
}

+ (NSString *)workoutWeightUnitImageFilename
{
    return @"1402307297_gym.png";
}
+ (UIImage *)workoutWeightUnitImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths workoutWeightUnitImageFilename]];
}

+ (NSString *)distanceImageFilename
{
    return @"1402307076_cell-0-4.png";
}
+ (UIImage *)distanceImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths distanceImageFilename]];
}

+ (NSString *)upgradeImageFilename
{
    return @"1402390544_icon-arrow-up-a.png";
}
+ (UIImage *)upgradeImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths upgradeImageFilename]];
}

+ (NSString *)shareImageFilename
{
    //return @"1388822753_send_file.png";
    return @"1388813338_share.png";
}
+ (UIImage *)shareImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths shareImageFilename]];
}

+ (NSString *)cameraImageFilename
{
    return @"1385982520_photo.png";
}
+ (UIImage *)cameraImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths cameraImageFilename]];
}

+ (NSString *)heartLogImageFilename
{
    //return @"App Icon Heart";
    return @"1387805292_stethoscope.png";
}
+ (UIImage *)heartLogImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths heartLogImageFilename]];
}

+ (NSString *)dismissArrowImageFilename
{
    return @"arrow_down.png";

}
+ (UIImage *)dismissArrowImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths dismissArrowImageFilename]];
}

// Rest timer image with foreground image color applied on top.
+ (NSString *)restTimerImageFilename
{
    // Thicker rest timer.
    return @"1402287253_timer.png";

    // Thin rest timer.
    //return @"1397907901_timer.png";
    //return @"78-stopwatch@2x.png";
    
    // Original stopwatch icon.
    //return @"1398476017_15.png";
}
+ (UIImage *)restTimerImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths restTimerImageFilename]];
}

// Timer image that goes on the actual rest timer button and should not have any color.
+ (NSString *)restTimerButtonImageFilename
{
    // Thicker rest timer.
    return @"1402287253_timer_64x64.png";
    //return @"1402287253_timer.png";
    
    // Thin rest timer.
    //return @"1397907901_timer_64x64.png";
    //return @"1397907901_timer_32x32.png";
    //return @"1397907901_timer.png";
    //return @"1398476017_15.png";
    
    // Original stopwatch icon.
    //return @"78-stopwatch@2x.png";
}
+ (UIImage *)restTimerButtonImage
{
    NSString *path = [MAFilePaths restTimerButtonImageFilename];
    UIImage *image = [[MAImageCache sharedInstance] objectForKey:path];
    if (!image)
    {
        image = [UIImage imageNamed:[MAFilePaths restTimerButtonImageFilename]];
        UIColor *color = [MAAppearance buttonTextColor];
        image = [MAAppearance tintImage:image tintColor:color];
        
        // Note that, unlike NSMutableDictionary, NSCache does not copy the key--need to verify whether the key should be copied or not.
        [[MAImageCache sharedInstance] setObject:image forKey:path];
    }
    
    return image;
}

+ (NSString *)supersetImageFilename
{
    return @"merge_arrow.png";
}
+ (UIImage *)supersetImage
{
    NSString *path = [MAFilePaths supersetImageFilename];
    UIImage *image = [[MAImageCache sharedInstance] objectForKey:path];
    if (!image)
    {
        image = [UIImage imageNamed:[MAFilePaths supersetImageFilename]];
        UIColor *color = [MAAppearance buttonTextColor];
        image = [MAAppearance tintImage:image tintColor:color];
        
        // Note that, unlike NSMutableDictionary, NSCache does not copy the key--need to verify whether the key should be copied or not.
        [[MAImageCache sharedInstance] setObject:image forKey:path];
    }
    
    return image;
}

+ (NSString *)graphImageFilename
{
    return @"1392723495_thin-354_analytics_line_chart_diagram.png";
}
+ (UIImage *)graphImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths graphImageFilename]];
}

+ (NSString *)userImageFilename
{
    return @"1390267377_user.png";
}
+ (UIImage *)userImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths userImageFilename]];
}

+ (NSString *)advancedSettingsFilename
{
    return @"1398475726_Gear.png";
}
+ (UIImage *)advancedSettingsImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths advancedSettingsFilename]];
}

+ (NSString *)calendarFilename
{
    return @"1407228799_calendar1.png";
}
+ (UIImage *)calendarImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths calendarFilename]];
}

+ (NSString *)logSetFilename
{
    return @"1398674928_pencil_and_paper.png";
}
+ (UIImage *)logSetImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths logSetFilename]];
}

+ (NSString *)starOutlineFilename
{
    return @"1409123580_star-512_line.png";
}
+ (UIImage *)starOutlineImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths starOutlineFilename]];
}

+ (NSString *)starFilledFilename
{
    return @"1409123580_star-512_filled.png";
}
+ (UIImage *)starFilledImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths starFilledFilename]];
}

+ (NSString *)circlePlusFilename
{
    return @"add_new_plus-512.png";
}
+ (UIImage *)circlePlusImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths circlePlusFilename]];
}

+ (NSString *)redCircleCrossFilename
{
    return @"red_circle_cross-512.png";
}
+ (UIImage *)redCircleCrossImage
{
    return [MAFilePaths imageFromCacheAtPath:[MAFilePaths redCircleCrossFilename]];
    //return [MAFilePaths applyEffectsToImagePath:[MAFilePaths redCircleCrossFilename]];
}

+ (NSString *)noAdFilename
{
    return @"724-no-ad.png";
//    return @"1409632591_Block-512.png";
}
+ (UIImage *)noAdImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths noAdFilename]];
}

+ (NSString *)perUnitSizeFilename
{
    return @"1409697265_20-512.png";
}
+ (UIImage *)perUnitSizeImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths perUnitSizeFilename]];
}

+ (NSString *)perUnitPriceFilename
{
    return @"1409738405_internt_web_technology-09-512.png";
}
+ (UIImage *)perUnitPriceImage
{
    return [MAFilePaths applyEffectsToImagePath:[MAFilePaths perUnitPriceFilename]];
}

+ (UIImage *)imageFromFilePath:(NSString *)filePath
{
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

+ (BOOL)saveImage:(UIImage *)image withFilePath:(NSString *)filePath
{
    BOOL success = NO;
    
    NSError *error;
    NSString *extension = [filePath pathExtension];
    if ([[extension lowercaseString] isEqualToString:@"png"])
    {
        success = [UIImagePNGRepresentation(image) writeToFile:filePath options:NSAtomicWrite error:&error];
    }
    else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"])
    {
        success = [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath options:NSAtomicWrite error:&error];
    }
    else
    {
        DLog(@"Failed to save image: invalid extension '%@'", extension);
    }
    
    if (!success)
    {
        NSLog(@"Failed to save image: %@", error);
    }

    return success;
}

@end
