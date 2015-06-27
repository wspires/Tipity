//
//  MAUtil.h
//  Gym Log
//
//  Created by Wade Spires on 10/8/12.
//
//

#import <Foundation/Foundation.h>

#import "MADefines.h"
#import "MALogUtil.h"

#import <UIKit/UIKit.h>

@interface MAUtil : NSObject
+ (NSString *)version;
+ (NSString *)frameToString:(CGRect)frame;

//+ (NSString *)distanceUnitForWeightUnit:(NSString *)unit;
+ (NSString *)cardioSeparator;
+ (NSString *)comparisonSeparator;

+ (NSString *)nameFromUnitAbbreviation:(NSString *)unit;
+ (NSString *)abbreviationFromUnitName:(NSString *)name;
+ (BOOL)isWeightUnit:(NSString *)unit;
+ (BOOL)isDistanceUnit:(NSString *)unit;
+ (BOOL)isHeightUnit:(NSString *)unit;
+ (double)inchToMeter:(double)inch;
+ (double)meterToInch:(double)meter;
+ (double)convertHeight:(double)height unit:(NSString *)unit newUnit:(NSString *)newUnit;
+ (double)poundToKilogram:(double)pound;
+ (double)kilogramToPound:(double)kilogram;
+ (double)mileToKilometer:(double)mile;
+ (double)kilometerToMile:(double)kilometer;
+ (double)meterToMile:(double)meter;
+ (double)metertoKilometer:(double)meter;
+ (double)poundToStone:(double)value;
+ (double)kilogramToStone:(double)value;
+ (double)stoneToPound:(double)value;
+ (double)stoneToKilogram:(double)value;
+ (double)convertWeight:(double)weight unit:(NSString *)unit newUnit:(NSString *)newUnit;

+ (NSString *)formatWeight:(NSNumber *)weight
                     units:(NSString *)units
                prevWeight:(NSNumber *)prevWeight;
+ (NSString *)formatWeight:(NSNumber *)weight
                     units:(NSString *)units
                      time:(NSString *)time
                prevWeight:(NSNumber *)prevWeight;
+ (NSString *)formatWeight:(NSNumber *)weight
                     units:(NSString *)units
                      time:(NSString *)time;
+ (double)calculateBMI:(double)weight weightUnits:(NSString *)weightUnits height:(double)height heightUnits:(NSString *)heightUnits;

+ (double)calculatePercentageChange:(double)newValue oldValue:(double)oldValue;

+ (NSString *)setSeparator;
+ (NSString *)starSymbol;
+ (NSString *)maxSymbol;
+ (NSString *)repSymbol;
+ (NSString *)weightSymbol;
+ (NSString *)totalSymbol;
+ (NSString *)timeSymbol;
+ (NSString *)distanceSymbol;
+ (NSString *)maxRepsString;
+ (NSString *)maxWeightString;
+ (NSString *)maxTotalString;
+ (NSString *)maxTimeString;
+ (NSString *)maxDistanceString;

@end
