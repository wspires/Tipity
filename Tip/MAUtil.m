//
//  MAUtil.m
//  Gym Log
//
//  Created by Wade Spires on 10/8/12.
//
//

#import "MAUtil.h"

#import "MADateUtil.h"
#import "MAFilePaths.h"
//#import "MAColorUtil.h"
//#import "MAAppearance.h"
#import "MAStringUtil.h"

//#import <QuartzCore/QuartzCore.h>

@implementation MAUtil

+ (NSString *)version
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString *)frameToString:(CGRect)frame
{
    return [NSString stringWithFormat:(@"%d, %d -> %d, %d (%d x %d)"), (int)frame.origin.x, (int)frame.origin.y, (int)(frame.origin.x + frame.size.width), (int)(frame.origin.y + frame.size.height), (int)frame.size.width, (int)frame.size.height];
}

+ (NSString *)cardioSeparator
{
    // Separating distance and time on different lines to keep it cleaner, especially since time can have milliseconds which includes a dot, too.
    return @"\n";
    
    /*
    // Set separator for Cardio distance and time.
    // Normally, it'd be something like "25:00, 1.5 m", but some locales use ",", so we want "25:00; 1,5 m" instead.
    static dispatch_once_t once;
    static NSString *cardioSep = nil;
    dispatch_once(&once, ^{
        cardioSep = @",";
        NSString *decimalSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
        if ([decimalSep isEqualToString:@","])
        {
            cardioSep = @";";
        }
    });
    return cardioSep;
     */
}

+ (NSString *)comparisonSeparator
{
    // Set separator for Cardio distance and time.
    // Normally, it'd be something like "25:00, 1.5 m", but some locales use ",", so we want "25:00; 1,5 m" instead.
    static dispatch_once_t once;
    static NSString *separator = nil;
    dispatch_once(&once, ^{
        separator = @",";
        NSString *decimalSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
        if ([decimalSep isEqualToString:@","])
        {
            separator = @";";
        }
    });
    return separator;
}

+ (NSString *)nameFromUnitAbbreviation:(NSString *)unit
{
    NSString *name = nil;
    if ([unit isEqualToString:@"mi"])
    {
        name = Localize(@"Miles");
    }
    else if ([unit isEqualToString:@"km"])
    {
        name = Localize(@"Kilometers");
    }
    else if ([unit isEqualToString:@"m"])
    {
        name = Localize(@"Meters");
    }
    else if ([unit isEqualToString:@"lb"])
    {
        name = Localize(@"Pounds");
    }
    else if ([unit isEqualToString:@"kg"])
    {
        name = Localize(@"Kilograms");
    }
    else if ([unit isEqualToString:@"st"])
    {
        name = Localize(@"Stones");
    }
    return name;
}

+ (NSString *)abbreviationFromUnitName:(NSString *)name
{
    NSString *unit = nil;
    if ([name isEqualToString:Localize(@"Miles")])
    {
        unit = @"mi";
    }
    else if ([name isEqualToString:Localize(@"Kilometers")])
    {
        unit = @"km";
    }
    else if ([name isEqualToString:Localize(@"Meters")])
    {
        unit = @"m";
    }
    else if ([name isEqualToString:Localize(@"Pounds")])
    {
        unit = @"lb";
    }
    else if ([name isEqualToString:Localize(@"Kilograms")])
    {
        unit = @"kg";
    }
    else if ([name isEqualToString:Localize(@"Stones")])
    {
        unit = @"st";
    }
    return unit;
}

+ (BOOL)isWeightUnit:(NSString *)unit
{
    return [unit isEqualToString:@"lb"] || [unit isEqualToString:@"kg"];
}

+ (BOOL)isDistanceUnit:(NSString *)unit
{
    return [unit isEqualToString:@"mi"] || [unit isEqualToString:@"km"];
}

+ (BOOL)isHeightUnit:(NSString *)unit
{
    return [unit isEqualToString:@"in"] || [unit isEqualToString:@"m"];
}

+ (double)inchToMeter:(double)inch
{
    static double const InchToMeterFactor = 0.0254;
    return inch * InchToMeterFactor;
}

+ (double)meterToInch:(double)meter
{
    static double const MeterToInchFactor = 39.3701;
    return meter * MeterToInchFactor;
}

+ (double)convertHeight:(double)height unit:(NSString *)unit newUnit:(NSString *)newUnit
{
    if ([unit isEqualToString:newUnit])
    {
        return height;
    }
    
    if ([newUnit isEqualToString:@"in"]
        || [newUnit isEqualToString:@"lb"])
    {
        return [MAUtil meterToInch:height];
    }
    else
    {
        return [MAUtil inchToMeter:height];
    }
}

+ (double)poundToKilogram:(double)pound
{
    static double const ConversionFactor = 0.453592;
    return pound * ConversionFactor;
}

+ (double)kilogramToPound:(double)kilogram
{
    static double const ConversionFactor = 2.20462;
    return kilogram * ConversionFactor;
}

+ (double)mileToKilometer:(double)mile
{
    static double const ConversionFactor = 1.60934;
    return mile * ConversionFactor;
}

+ (double)kilometerToMile:(double)kilometer
{
    static double const ConversionFactor = 0.621371;
    return kilometer * ConversionFactor;
}

+ (double)mileToMeter:(double)mile
{
    static double const ConversionFactor = 1609.34;
    return mile * ConversionFactor;
}

+ (double)kilometerToMeter:(double)kilometer
{
    static double const ConversionFactor = 1000;
    return kilometer * ConversionFactor;
}

+ (double)meterToMile:(double)meter
{
    static double const ConversionFactor = 0.000621371;
    return meter * ConversionFactor;
}

+ (double)metertoKilometer:(double)meter
{
    static double const ConversionFactor = 0.001;
    return meter * ConversionFactor;
}

// Convert to and from stones.
+ (double)poundToStone:(double)value
{
    static double const ConversionFactor = 0.0714286;
    return value * ConversionFactor;
}
+ (double)kilogramToStone:(double)value
{
    static double const ConversionFactor = 0.157473;
    return value * ConversionFactor;
}
+ (double)stoneToPound:(double)value
{
    static double const ConversionFactor = 14;
    return value * ConversionFactor;
}
+ (double)stoneToKilogram:(double)value
{
    static double const ConversionFactor = 6.35029;
    return value * ConversionFactor;
}

// Convert weight to new unit. If the new unit is the same as the old unit, the same value is returned.
// Also converts distance: miles to kilometers and vice versa.
+ (double)convertWeight:(double)weight unit:(NSString *)unit newUnit:(NSString *)newUnit
{
    if ([unit isEqualToString:newUnit])
    {
        return weight;
    }
    
    // Weight conversion.
    if ([newUnit isEqualToString:@"lb"]) // To pounds.
    {
        if ([unit isEqualToString:@"kg"] || [unit isEqualToString:@"km"])
        {
            return [MAUtil kilogramToPound:weight];
        }
    }
    else if ([newUnit isEqualToString:@"kg"]) // To kilograms.
    {
        if ([unit isEqualToString:@"lb"] || [unit isEqualToString:@"mi"])
        {
            return [MAUtil poundToKilogram:weight];
        }
    }
    
    // Distance conversion.
    else if ([newUnit isEqualToString:@"mi"]) // To miles.
    {
        if ([unit isEqualToString:@"kg"] || [unit isEqualToString:@"km"])
        {
            return [MAUtil kilometerToMile:weight];
        }
        else if ([unit isEqualToString:@"m"])
        {
            return [MAUtil meterToMile:weight];
        }
    }
    else if ([newUnit isEqualToString:@"km"]) // To kilometers.
    {
        if ([unit isEqualToString:@"lb"] || [unit isEqualToString:@"mi"])
        {
            return [MAUtil mileToKilometer:weight];
        }
        else if ([unit isEqualToString:@"m"])
        {
            return [MAUtil metertoKilometer:weight];
        }
    }
    else if ([newUnit isEqualToString:@"m"]) // To meters.
    {
        if ([unit isEqualToString:@"lb"] || [unit isEqualToString:@"mi"])
        {
            return [MAUtil mileToMeter:weight];
        }
        else if ([unit isEqualToString:@"kg"] || [unit isEqualToString:@"km"])
        {
            return [MAUtil kilometerToMeter:weight];
        }
    }

    // Bodyweight to and from stones.
    else if ([newUnit isEqualToString:@"st"]) // To stones.
    {
        if ([unit isEqualToString:@"lb"] || [unit isEqualToString:@"mi"])
        {
            return [MAUtil poundToStone:weight];
        }
        else if ([unit isEqualToString:@"kg"] || [unit isEqualToString:@"km"])
        {
            return [MAUtil kilogramToStone:weight];
        }
    }
    else if ([unit isEqualToString:@"st"]) // From stones.
    {
        if ([newUnit isEqualToString:@"lb"] || [newUnit isEqualToString:@"mi"])
        {
            return [MAUtil stoneToPound:weight];
        }
        else if ([newUnit isEqualToString:@"kg"] || [newUnit isEqualToString:@"km"])
        {
            return [MAUtil stoneToKilogram:weight];
        }
    }

    return weight;
}

+ (NSString *)formatWeight:(NSNumber *)weight
                     units:(NSString *)units
                prevWeight:(NSNumber *)prevWeight
{
    double weightGain = weight.doubleValue - prevWeight.doubleValue;
    //if (weightGain != 0)
    {
        NSString *sign = @"+";
        if (weightGain < 0)
        {
            sign = @"";
        }
        
        NSString *weightGainStr = [MAStringUtil formatDouble:weightGain];
        return [NSString stringWithFormat:
                @"%@ %@ (%@%@)"
                , [MAStringUtil formatDouble:weight.doubleValue]
                , units
                , sign
                , weightGainStr
                ];
    }
    /*
     else
     {
     return [NSString stringWithFormat:
     @"%@ %@ (=) ― %@"
     , [MAUtil formatDouble:weight.doubleValue]
     , units
     , time
     ];
     }
     */
}

+ (NSString *)formatWeight:(NSNumber *)weight
                     units:(NSString *)units
                      time:(NSString *)time
                prevWeight:(NSNumber *)prevWeight
{
    NSDate *dateTime = [MADateUtil dateFromString:time];
    NSString *date = [MADateUtil formatDateForSection:dateTime];
    time = [MADateUtil timeFromDate:dateTime];
    
    double weightGain = weight.doubleValue - prevWeight.doubleValue;
    //if (weightGain != 0)
    {
        NSString *sign = @"+";
        if (weightGain < 0)
        {
            sign = @"";
        }
        
        NSString *weightGainStr = [MAStringUtil formatDouble:weightGain];
        return [NSString stringWithFormat:
                @"%@ %@ (%@%@) ― %@ ― %@"
                , [MAStringUtil formatDouble:weight.doubleValue]
                , units
                , sign
                , weightGainStr
                , date
                , time
                ];
    }
    /*
     else
     {
     return [NSString stringWithFormat:
     @"%@ %@ (=) ― %@"
     , [MAUtil formatDouble:weight.doubleValue]
     , units
     , time
     ];
     }
     */
}

+ (NSString *)formatWeight:(NSNumber *)weight
                     units:(NSString *)units
                      time:(NSString *)time
{
    return [NSString stringWithFormat:
            @"%@ %@"
            , [MAStringUtil formatDouble:weight.doubleValue]
            , units
            ];
}

+ (double)calculateBMI:(double)weight weightUnits:(NSString *)weightUnits height:(double)height heightUnits:(NSString *)heightUnits
{
    // BMI calculation requires both weight and height. Return 0 if height is 0 even though it is technically undefined.
    if (weight == 0 || height == 0)
    {
        return 0;
    }
    
    // Convert units to metric if necessary.
    double weightInKilograms = weight;
    NSString *newUnit = @"kg";
    if (![weightUnits isEqualToString:newUnit])
    {
        weightInKilograms = [MAUtil convertWeight:weight unit:weightUnits newUnit:newUnit];
    }
    
    double heightInMeters = height;
    if ([heightUnits isEqualToString:@"in"])
    {
        heightInMeters = [MAUtil inchToMeter:height];
    }
    
    // Calculate BMI assuming units are all in metric.
    double bmi = weightInKilograms / (heightInMeters * heightInMeters);
    return bmi;
}

+ (double)calculatePercentageChange:(double)newValue oldValue:(double)oldValue
{
    if (oldValue == 0)
    {
        if (newValue == 0)
        {
            // No change.
            return 0;
        }
        
        // Default to 100% change if no previous value.
        return 100;
    }
    
    return 100. * (newValue - oldValue) / fabs(oldValue);
}

+ (NSString *)setSeparator
{
    return @"×"; // Unicode character for multiplication sign u00D7.
}
+ (NSString *)starSymbol
{
    return @"☆";
    //return @"★";
}
+ (NSString *)maxSymbol
{
    //return @"Max";

    // This is what the Weather app uses for the high, so it makes since to use as the max. However, it does not display properly for some reason, as a ? instead of as an arrow. Perhaps it's a font issue or an issue using attributed text.
    //return @"⤒";
    //return @"\u2912";

    //return @"↑";
    //return @"⇧";
    
    return [MAUtil starSymbol];
    
    //return @"⇯";
    //return @"⊼";
    //return @"∨";
    //return @"⌆";
    //return @"⌅";
    //return @"≛";
    //return @"≤";
    //return @"↥";
}
+ (NSString *)repSymbol
{
    return @"Reps";
    //return [MAUtil setSeparator];
}
+ (NSString *)weightSymbol
{
    return @"Weight";
    //return @"#";
    
    //MAUserUtil *userUtil = [MAUserUtil sharedInstance];
    //return [userUtil objectForKey:WeightUnit];
}
+ (NSString *)totalSymbol
{
    return @"Total";
    //return @"∑";
}
+ (NSString *)timeSymbol
{
    return @"Time";
    
    // http://stackoverflow.com/questions/5437674/what-unicode-character-is-a-good-mark-of-time
    //return @"⌛";
    //return @"⌚";
    //return @"⏳";
    //return @"⧖";
    //return @"⧗";
    //return @"🕒";
}
+ (NSString *)distanceSymbol
{
    return @"Distance";
    //return @"➠";
    //return @"📏";
    
    //return @"⤏";
    //return @"⤍";
    //return @"⤐";
    
    //MAUserUtil *userUtil = [MAUserUtil sharedInstance];
    //return [userUtil objectForKey:CardioUnit];
}
+ (NSString *)maxRepsString
{
    return Localize(SFmt(@"%@ %@", [MAUtil maxSymbol], [MAUtil repSymbol]));
}
+ (NSString *)maxWeightString
{
    return Localize(SFmt(@"%@ %@", [MAUtil maxSymbol], [MAUtil weightSymbol]));
}
+ (NSString *)maxTotalString
{
    return Localize(SFmt(@"%@ %@", [MAUtil maxSymbol], [MAUtil totalSymbol]));
}
+ (NSString *)maxTimeString
{
    return Localize(SFmt(@"%@ %@", [MAUtil maxSymbol], [MAUtil timeSymbol]));
}
+ (NSString *)maxDistanceString
{
    return Localize(SFmt(@"%@ %@", [MAUtil maxSymbol], [MAUtil distanceSymbol]));
}

@end
