//
//  MAFilePaths.h
//  Gym Log
//
//  Created by Wade Spires on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MAFilePaths : NSObject

//+ (NSString *)backgroundImageName;
+ (NSString *)docDir;
+ (NSString *)tmpDir;
+ (BOOL)regularFileExists:(NSString *)path;
+ (BOOL)directoryExists:(NSString *)path;
+ (BOOL)erasePath:(NSString *)path error:(NSError **)error;
+ (BOOL)eraseDirPath:(NSString *)path error:(NSError **)error;
+ (BOOL)renamePath:(NSString *)oldPath newPath:(NSString *)newPath error:(NSError **)error;
+ (BOOL)renameDirPath:(NSString *)oldPath newPath:(NSString *)newPath error:(NSError **)error;
+ (BOOL)swapPath:(NSString *)firstPath withPath:(NSString *)secondPath error:(NSError **)error;

+ (NSString *)activitiesFileDir;
+ (NSString *)activitiesFilePath:(NSString *)uid;

+ (NSString *)soundFilePath:(NSString *)baseName;
+ (NSString *)alertSoundsFilePath;
+ (NSArray *)loadAlertSounds;

+ (NSString *)preloadedRoutinesFilePath;

+ (NSString *)helpFile;
+ (NSString *)helpTopicsFile;
+ (NSArray *)loadHelpTopics;

+ (NSString *)creditsFile;

+ (NSString *)equipmentFilePath;
+ (NSArray *)loadEquipmentList;
+ (NSArray *)loadNoBodyweightEquipmentList;

+ (NSString *)exerciseFilterFilePath;
+ (NSMutableDictionary *)exerciseFilter;
+ (NSMutableDictionary *)defaultExerciseFilter;
+ (BOOL)saveFilter:(NSDictionary *)filter;

+ (NSString *)appearanceImageFilename;
+ (UIImage *)appearanceImage;

// Tip icons.
+ (NSString *)billImageFilename;
+ (UIImage *)billImage;
+ (NSString *)tipPercentImageFilename;
+ (UIImage *)tipPercentImage;
+ (NSString *)tipAmountImageFilename;
+ (UIImage *)tipAmountImage;
+ (NSString *)totalImageFilename;
+ (UIImage *)totalImage;
+ (NSString *)peopleImageFilename;
+ (UIImage *)peopleImage;
+ (NSString *)splitTipFilename;
+ (UIImage *)splitTipImage;
+ (NSString *)splitTotalFilename;
+ (UIImage *)splitTotalImage;
+ (NSString *)taxPercentImageFilename;
+ (UIImage *)taxPercentImage;
+ (NSString *)taxAmountImageFilename;
+ (UIImage *)taxAmountImage;
+ (NSString *)filledStarImageFilename;
+ (UIImage *)filledStarImage;
+ (NSString *)emptyStarImageFilename;
+ (UIImage *)emptyStarImage;
+ (NSString *)plusImageFilename;
+ (UIImage *)plusImage;
+ (NSString *)plusImageSelectedFilename;
+ (UIImage *)plusImageSelected;
+ (NSString *)minusImageFilename;
+ (UIImage *)minusImage;
+ (NSString *)minusImageSelectedFilename;
+ (UIImage *)minusImageSelected;
+ (NSString *)roundingImageFilename;
+ (UIImage *)roundingImage;
+ (NSString *)roundNoneImageFilename;
+ (UIImage *)roundNoneImage;
+ (NSString *)roundUpImageFilename;
+ (UIImage *)roundUpImage;
+ (NSString *)roundDownImageFilename;
+ (UIImage *)roundDownImage;
+ (NSString *)roundNearestImageFilename;
+ (UIImage *)roundNearestImage;

// Feedback icons.
+ (NSString *)tellFriendImageFilename;
+ (UIImage *)tellFriendImage;
+ (NSString *)sendFeedbackImageFilename;
+ (UIImage *)sendFeedbackImage;
+ (NSString *)writeReviewImageFilename;
+ (UIImage *)writeReviewImage;
+ (NSString *)creditsImageFilename;
+ (UIImage *)creditsImage;
+ (NSString *)versionImageFilename;
+ (UIImage *)versionImage;

+ (NSString *)historyImageFilename;
+ (UIImage *)historyImage;
+ (NSString *)statsImageFilename;
+ (UIImage *)statsImage;
+ (NSString *)instructionsImageFilename;
+ (UIImage *)instructionsImage;
+ (NSString *)customImageFilename;
+ (UIImage *)customImage;
+ (NSString *)builtinImageFilename;
+ (UIImage *)builtinImage;
+ (NSString *)startWorkoutImageFilename;
+ (UIImage *)startWorkoutImage;
+ (NSString *)summaryImageFilename;
+ (UIImage *)summaryImage;
+ (NSString *)compareWorkoutsImageFilename;
+ (UIImage *)compareWorkoutsImage;
+ (NSString *)blankImageFilename;
+ (UIImage *)blankImage;

+ (NSString *)backgroundColorsFilePath;
+ (NSArray *)loadBackgroundColors;
+ (NSString *)foregroundColorsFilePath;
+ (NSArray *)loadForegroundColors;

+ (NSString *)weightUnitsFilePath;
+ (NSArray *)loadWeightUnits;

+ (NSString *)distanceLogUnitsFilePath;
+ (NSArray *)loadDistanceLogUnits;

+ (NSString *)weightLogUnitsFilePath;
+ (NSArray *)loadWeightLogUnits;
+ (NSString *)weightLogImageFilename;
+ (UIImage *)weightLogImage;
+ (NSString *)weightUnitImageFilename;
+ (UIImage *)weightUnitImage;
+ (NSString *)rulerImageFilename;
+ (UIImage *)rulerImage;
+ (NSString *)goalImageFilename;
+ (UIImage *)goalImage;

+ (NSString *)informationImageFilename;
+ (UIImage *)informationImage;

+ (NSString *)workoutWeightUnitImageFilename;
+ (UIImage *)workoutWeightUnitImage;

+ (NSString *)distanceImageFilename;
+ (UIImage *)distanceImage;

+ (NSString *)upgradeImageFilename;
+ (UIImage *)upgradeImage;

+ (NSString *)shareImageFilename;
+ (UIImage *)shareImage;

+ (NSString *)cameraImageFilename;
+ (UIImage *)cameraImage;

+ (NSString *)heartLogImageFilename;
+ (UIImage *)heartLogImage;

+ (NSString *)dismissArrowImageFilename;
+ (UIImage *)dismissArrowImage;

+ (NSString *)restTimerImageFilename;
+ (UIImage *)restTimerImage;

+ (NSString *)restTimerButtonImageFilename;
+ (UIImage *)restTimerButtonImage;

+ (NSString *)supersetImageFilename;
+ (UIImage *)supersetImage;

+ (NSString *)graphImageFilename;
+ (UIImage *)graphImage;

+ (NSString *)userImageFilename;
+ (UIImage *)userImage;

+ (NSString *)advancedSettingsFilename;
+ (UIImage *)advancedSettingsImage;

+ (NSString *)calendarFilename;
+ (UIImage *)calendarImage;

+ (NSString *)logSetFilename;
+ (UIImage *)logSetImage;

+ (NSString *)starOutlineFilename;
+ (UIImage *)starOutlineImage;

+ (NSString *)starFilledFilename;
+ (UIImage *)starFilledImage;

+ (NSString *)circlePlusFilename;
+ (UIImage *)circlePlusImage;

+ (NSString *)redCircleCrossFilename;
+ (UIImage *)redCircleCrossImage;

+ (NSString *)noAdFilename;
+ (UIImage *)noAdImage;

+ (NSString *)perUnitSizeFilename;
+ (UIImage *)perUnitSizeImage;

+ (NSString *)perUnitPriceFilename;
+ (UIImage *)perUnitPriceImage;

+ (UIImage *)imageFromFilePath:(NSString *)filePath;
+ (BOOL)saveImage:(UIImage *)image withFilePath:(NSString *)filePath;
+ (UIImage *)applyEffectsToImagePath:(NSString *)path;
+ (UIImage *)applyEffectsToImage:(UIImage *)image;

@end
