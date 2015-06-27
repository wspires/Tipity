//
//  MADateUtil.m
//  Gym Log
//
//  Created by Wade Spires on 7/8/14.
//
//

#import "MADateUtil.h"

#import "MADefines.h"
#import "MALogUtil.h"

@implementation MADateUtil

+ (NSString *)formatDateForSection:(NSDate *)date
{
    // Generate UID by using the current date and time.
    static dispatch_once_t once;
    static NSDateFormatter *dateFormatter = nil;
    dispatch_once(&once, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        
        // Formats using the day of the week and the date.
        // Only display the year if it is different from this year.
        NSString *formatString = nil;
        /*
         unsigned int flags = NSCalendarUnitYear;
         NSCalendar *calendar = [NSCalendar currentCalendar];
         NSDate *today = [NSDate date];
         NSDateComponents *todayComponents = [calendar components:flags fromDate:today];
         NSDateComponents *givenComponents = [calendar components:flags fromDate:date];
         NSDate *todayYear = [calendar dateFromComponents:todayComponents];
         NSDate *givenYear = [calendar dateFromComponents:givenComponents];
         DLog(@"todayYear=%@, givenYear=%@", todayYear, givenYear);
         if ([givenYear compare:todayYear] == NSOrderedSame)
         {
         // No year.
         formatString = [NSDateFormatter dateFormatFromTemplate:@"EdMMM"
         options:0
         locale:[NSLocale currentLocale]];
         }
         else
         {
         formatString = [NSDateFormatter dateFormatFromTemplate:@"EdMMMy"
         options:0
         locale:[NSLocale currentLocale]];
         }
         */
        
        formatString = [NSDateFormatter dateFormatFromTemplate:@"EdMMMy"
                                                       options:0
                                                        locale:[NSLocale autoupdatingCurrentLocale]];
        
        
        [dateFormatter setDateFormat:formatString];
    });
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)formatDateForGraph:(NSDate *)date
{
    // Just forward the call to this function if want the time, too.
    //return [MADateUtil formatDateForSection:date];
    
    // Generate UID by using the current date and time.
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
        //locale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_CO"]; // Spanish language in Colombia.
        [dateFormatter setLocale:locale];
    }
    
    // Formats using the day of the week and the date.
    // Only display the year if it is different from this year.
    NSString *formatString = nil;
    unsigned int flags = NSCalendarUnitYear;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];
    NSDateComponents *todayComponents = [calendar components:flags fromDate:today];
    NSDateComponents *givenComponents = [calendar components:flags fromDate:date];
    NSDate *todayYear = [calendar dateFromComponents:todayComponents];
    NSDate *givenYear = [calendar dateFromComponents:givenComponents];
    DLog(@"todayYear=%@, givenYear=%@", todayYear, givenYear);
    if ([givenYear compare:todayYear] == NSOrderedSame)
    {
        // No year.
        formatString = [NSDateFormatter dateFormatFromTemplate:@"EdMMM"
                                                       options:0
                                                        locale:[NSLocale autoupdatingCurrentLocale]];
    }
    else
    {
        formatString = [NSDateFormatter dateFormatFromTemplate:@"EdMMMy"
                                                       options:0
                                                        locale:[NSLocale autoupdatingCurrentLocale]];
    }
    
    [dateFormatter setDateFormat:formatString];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)formatMonthDateForSection:(NSDate *)date
{
    // Generate UID by using the current date and time.
    static dispatch_once_t once;
    static NSDateFormatter *dateFormatter = nil;
    dispatch_once(&once, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSString *formatString = nil;
        formatString = [NSDateFormatter dateFormatFromTemplate:@"MMMMy"
                                                       options:0
                                                        locale:[NSLocale autoupdatingCurrentLocale]];
        
        
        [dateFormatter setDateFormat:formatString];
    });
    return [dateFormatter stringFromDate:date];
}

// Returns a formatter for fixed-format dates, such as the RFC 3339-style dates used by many Internet protocols. Dates formatted with this formatter are suitable for internal storage such as in a database rather than being visible to users. See this link:
// http://developer.apple.com/library/ios/#qa/qa1480/_index.html
// Returns a new formatter object on each call.
+ (NSDateFormatter *)rfc3339DateFormatter
{
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
    
    // Using the _POSIX variant guarantees that the same format will be used even if en_US were to change in the future.
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    
    return rfc3339DateFormatter;
}

// Return a formatter for fixed-format dates with GMT time zone.
// Returns a shared formatter object.
+ (NSDateFormatter *)fixedDateFormatterGMT
{
    static dispatch_once_t once;
    static NSDateFormatter *rfc3339DateFormatter = nil;
    dispatch_once(&once, ^{
        rfc3339DateFormatter = [MADateUtil rfc3339DateFormatter];
        
        NSTimeZone *gmtTimeZone = nil;
        gmtTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [rfc3339DateFormatter setTimeZone:gmtTimeZone];
    });
    
    return rfc3339DateFormatter;
}

// Return a formatter for fixed-format dates with local time zone.
// Returns a shared formatter object.
+ (NSDateFormatter *)fixedDateFormatterLocal
{
    static dispatch_once_t once;
    static NSDateFormatter *rfc3339DateFormatter = nil;
    dispatch_once(&once, ^{
        rfc3339DateFormatter = [MADateUtil rfc3339DateFormatter];
        
        NSTimeZone *localTimeZone = nil;
        localTimeZone = [NSTimeZone localTimeZone];
        [rfc3339DateFormatter setTimeZone:localTimeZone];
    });
    
    return rfc3339DateFormatter;
}
+ (NSDateFormatter *)fixedDateFormatter:(BOOL)useGMT
{
    if (useGMT)
    {
        return [MADateUtil fixedDateFormatterGMT];
    }
    else
    {
        return [MADateUtil fixedDateFormatterLocal];
    }
}
static BOOL const DefaultToGMT = YES;
+ (NSDateFormatter *)fixedDateFormatter
{
    return [MADateUtil fixedDateFormatterGMT];
}

// The returned string will be in fixed-format and locale-independent.
+ (NSString *)dateToString:(NSDate *)date useGMT:(BOOL)useGMT
{
    NSDateFormatter *formatter = [MADateUtil fixedDateFormatter:useGMT];
    return [formatter stringFromDate:date];
}
+ (NSString *)dateToString:(NSDate *)date
{
    return [MADateUtil dateToString:date useGMT:DefaultToGMT];
}
+ (NSString *)dateToFixedString:(NSDate *)date
{
    return [MADateUtil dateToString:date useGMT:YES];
}
+ (NSString *)dateToUserString:(NSDate *)date
{
    return [MADateUtil dateToString:date useGMT:NO];
}

// The input string should be fixed-format and locale-independent.
+ (NSDate *)dateFromString:(NSString *)date useGMT:(BOOL)useGMT
{
    NSDateFormatter *formatter = [MADateUtil fixedDateFormatter:useGMT];
    return [formatter dateFromString:date];
}
+ (NSDate *)dateFromString:(NSString *)date
{
    return [MADateUtil dateFromString:date useGMT:DefaultToGMT];
}
+ (NSDate *)dateFromFixedString:(NSString *)date
{
    return [MADateUtil dateFromString:date useGMT:YES];
}
+ (NSDate *)dateFromUserString:(NSString *)date;
{
    return [MADateUtil dateFromString:date useGMT:NO];
}

+ (NSString *)fixedDateStringToUserDateString:(NSString *)date
{
    return [MADateUtil dateToUserString:[MADateUtil dateFromFixedString:date]];
}
+ (NSString *)userDateStringToFixedDateString:(NSString *)date
{
    return [MADateUtil dateToFixedString:[MADateUtil dateFromUserString:date]];
}

+ (NSString *)dateToYYYYMMDD:(NSDate *)date useGMT:(BOOL)useGMT
{
    NSString *dateStr = [MADateUtil dateToString:date useGMT:useGMT];
    //DLog(@"dateToYYYYMMDD: %@ -> %@", date, dateStr);
    NSRange range;
    range.location = 0; // First part of the string is formatted as "yyyy-MM-dd".
    range.length = 10;
    dateStr = [dateStr substringWithRange:range];
    return dateStr;
}
+ (NSString *)dateToYYYYMMDD:(NSDate *)date
{
    // Note: do not want GMT because the date given is usually given to us literally, such as the activity date or as today's date via [NSDate date] in many queries, so we should not convert to GMT. For example, on 2013-06-09 at time 11:00 PM EST would actually be the next day, 2013-06-10, in GMT, which is not correct.
    return [MADateUtil dateToYYYYMMDD:date useGMT:NO];
    //return [MADateUtil dateToYYYYMMDD:date useGMT:DefaultToGMT];
}

+ (NSDate *)dateFromYYYYMMDD:(NSString *)dateStr
{
    // Create a full date-time string by appending a dummy time.
    // GMT should NOT be used because the dates will look like they are a day behind in the US, so local time should be used.
    dateStr = SFmt(@"%@T00:00:00.000Z", dateStr);
    NSDate *date = [MADateUtil dateFromString:dateStr useGMT:NO];
    return date;
}


// Create a new date using the year, month, and day from the new date and the
// same time of day as the old date.
+ (NSDate *)changeDate:(NSDate *)oldDate
               newDate:(NSDate *)newDate
         offsetSeconds:(NSInteger)offsetSeconds;
{
    static dispatch_once_t once;
    static NSCalendar *calendar = nil;
    dispatch_once(&once, ^{
        //calendar = [NSCalendar currentCalendar];
        calendar = [NSCalendar autoupdatingCurrentCalendar];
    });
    
    NSDate *updatedDate = nil;
    @synchronized(calendar)
    {
        NSDateComponents *timeComponents = [calendar components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:oldDate];
        NSDateComponents *dateComponents = [calendar components:( NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay ) fromDate:newDate];
        
        // Set time component, adding the given number of offset seconds.
        // Note: even if the number of seconds added exceeds 60, the minutes/hours
        // will rollover automatically, which is the correct behavior.
        [dateComponents setHour:[timeComponents hour]];
        [dateComponents setMinute:[timeComponents minute]];
        [dateComponents setSecond:[timeComponents second] + offsetSeconds];
        
        updatedDate = [calendar dateFromComponents:dateComponents];
    }
    return updatedDate;
}

+ (NSDateComponents *)diffDatesFromDate:(NSDate *)fromDate
                                 toDate:(NSDate *)toDate
{
    static dispatch_once_t once;
    static NSCalendar *calendar = nil;
    dispatch_once(&once, ^{
        //calendar = [NSCalendar currentCalendar];
        calendar = [NSCalendar autoupdatingCurrentCalendar];
    });
    
    NSDateComponents *diffComponents = nil;
    @synchronized(calendar)
    {
        // Remove the time components from the dates so only the days are compared
        // when the difference is computed as we could have 2 different days calculated
        // as having 0 days difference if it hasn't been at least 24 hours if we use
        // the dates as-is with the time components.
        NSDateComponents *fromDateComponents = [calendar
                                                components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:fromDate];
        DLog(@"From: Year %d, Month %d, Day %d", fromDateComponents.year, fromDateComponents.month, fromDateComponents.day);
        fromDate = [calendar dateFromComponents:fromDateComponents];
        NSDateComponents *toDateComponents = [calendar
                                              components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:toDate];
        DLog(@"To: Year %d, Month %d, Day %d", toDateComponents.year, toDateComponents.month, toDateComponents.day);
        toDate = [calendar dateFromComponents:toDateComponents];
        
        // Calculate the difference.
        diffComponents = [calendar
                          components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                          fromDate:fromDate
                          toDate:toDate
                          options:0];
        DLog(@"Diff: Year %d, Month %d, Day %d", diffComponents.year, diffComponents.month, diffComponents.day);
    }
    return diffComponents;
}

// Pluralize string properly given a count.
// E.g., "0 years", "1 year", "2 years", etc.
// The algorithm is not sophisticated and just appends an "s" if the count is
// not 1, while it should append "es" for words ending with "s" and may need
// to account for locales.
+ (NSString *)pluralize:(NSString *)str
              withCount:(NSUInteger)count
{
    if (count == 1)
    {
        return Localize(str);
    }
    str = [NSString stringWithFormat:@"%@s", str];
    return Localize(str);
}

// Format date differences as a string.
// E.g., "1 year, 2 months, 3 days", "1 month, 2 days", "1 day", etc.
// The string will be empty if the difference is 0.
+ (NSString *)formatDateDiff:(NSDateComponents *)components
{
    NSMutableString *str = [[NSMutableString alloc] init];
    if (components.year < 0 || components.month < 0 || components.day < 0)
    {
        return @"-";
    }
    
    if (components.year > 0)
    {
        [str appendFormat:@"%d %@"
         , (int)components.year
         , [MADateUtil pluralize:@"year" withCount:components.year]
         ];
    }
    
    if (components.month > 0)
    {
        if (str.length != 0)
        {
            [str appendFormat:@", "];
        }
        
        [str appendFormat:@"%d %@"
         , (int)components.month
         , [MADateUtil pluralize:@"month" withCount:components.month]
         ];
    }
    
    if (components.day > 0)
    {
        if (str.length != 0)
        {
            [str appendFormat:@", "];
        }
        
        [str appendFormat:@"%d %@"
         , (int)components.day
         , [MADateUtil pluralize:@"day" withCount:components.day]
         ];
    }
    
    return str;
}

+ (NSString *)formatDateDiffWithDate:(NSDate *)date
{
    NSDate *today = [[NSDate alloc] init];
    return [MADateUtil formatDateDiffWithDate:date latestDate:today];
}

+ (NSString *)formatDateDiffWithDate:(NSDate *)date latestDate:(NSDate *)latestDate
{
    if (!date)
    {
        return Localize(@"-");
    }
    
    NSDateComponents *dateDiff = [MADateUtil diffDatesFromDate:date
                                                    toDate:latestDate];
    NSString *dateDiffStr = [MADateUtil formatDateDiff:dateDiff];
    if (dateDiffStr.length == 0)
    {
        dateDiffStr = Localize(@"Today");
    }
    else if (![dateDiffStr isEqualToString:Localize(@"-")])
    {
        dateDiffStr = [NSString stringWithFormat:Localize(@"%@ ago"), dateDiffStr];
    }
    
    return dateDiffStr;
}

+ (NSDateComponents *)diffTimesFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    static dispatch_once_t once;
    static NSCalendar *calendar = nil;
    dispatch_once(&once, ^{
        //calendar = [NSCalendar currentCalendar];
        calendar = [NSCalendar autoupdatingCurrentCalendar];
    });
    
    NSDateComponents *diffComponents = nil;
    @synchronized(calendar)
    {
        diffComponents = [calendar
                          components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                          fromDate:fromDate
                          toDate:toDate
                          options:0];
    }
    return diffComponents;
}

+ (NSString *)formatTimeDiff:(NSDateComponents *)components
{
    NSString *dateStr = [MADateUtil formatDateDiff:components];
    if (dateStr.length != 0)
    {
        dateStr = SFmt(@"%@, ", dateStr);
    }
    NSString *str = SFmt(@"%@%02d:%02d:%02d", dateStr, (int)components.hour, (int)components.minute, (int)components.second);
    return str;
}

+ (CGFloat)minutesFromDateComponents:(NSDateComponents *)components
{
    CGFloat minutes = (components.hour * 60.) + components.minute + (components.second / 60.);
    return minutes;
}

+ (NSString *)timeFromDate:(NSDate *)date
{
    static dispatch_once_t once;
    static NSDateFormatter *dateFormatter = nil;
    dispatch_once(&once, ^{
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        [dateFormatter setLocale:[NSLocale autoupdatingCurrentLocale]];
    });
    return [dateFormatter stringFromDate:date];
}

@end
