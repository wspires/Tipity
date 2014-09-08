//
//  MADateUtil.h
//  Gym Log
//
//  Created by Wade Spires on 7/8/14.
//
//

#import <Foundation/Foundation.h>

#import <QuartzCore/QuartzCore.h>

@interface MADateUtil : NSObject

+ (NSString *)formatDateForSection:(NSDate *)date;
+ (NSString *)formatDateForGraph:(NSDate *)date;
+ (NSString *)formatMonthDateForSection:(NSDate *)date;
+ (NSString *)dateToYYYYMMDD:(NSDate *)date useGMT:(BOOL)useGMT;
+ (NSString *)dateToYYYYMMDD:(NSDate *)date;
+ (NSDate *)dateFromYYYYMMDD:(NSString *)date;

+ (NSDateFormatter *)fixedDateFormatterGMT;
+ (NSDateFormatter *)fixedDateFormatterLocal;
+ (NSDateFormatter *)fixedDateFormatter:(BOOL)useGMT;
+ (NSDateFormatter *)fixedDateFormatter;
+ (NSString *)dateToString:(NSDate *)date useGMT:(BOOL)useGMT;
+ (NSString *)dateToString:(NSDate *)date;
+ (NSString *)dateToFixedString:(NSDate *)date;
+ (NSString *)dateToUserString:(NSDate *)date;
+ (NSDate *)dateFromString:(NSString *)date useGMT:(BOOL)useGMT;
+ (NSDate *)dateFromString:(NSString *)date;
+ (NSDate *)dateFromFixedString:(NSString *)date;
+ (NSDate *)dateFromUserString:(NSString *)date;
+ (NSString *)fixedDateStringToUserDateString:(NSString *)date;
+ (NSString *)userDateStringToFixedDateString:(NSString *)date;

+ (NSDate *)changeDate:(NSDate *)oldDate
               newDate:(NSDate *)newDate
         offsetSeconds:(NSInteger)offsetSeconds;
+ (NSDateComponents *)diffDatesFromDate:(NSDate *)fromDate
                                 toDate:(NSDate *)toDate;
+ (NSString *)pluralize:(NSString *)str
              withCount:(NSUInteger)count;
+ (NSString *)formatDateDiff:(NSDateComponents *)components;
+ (NSString *)formatDateDiffWithDate:(NSDate *)date;
+ (NSString *)formatDateDiffWithDate:(NSDate *)date latestDate:(NSDate *)latestDate;
+ (NSDateComponents *)diffTimesFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (NSString *)formatTimeDiff:(NSDateComponents *)components;
+ (CGFloat)minutesFromDateComponents:(NSDateComponents *)components;

+ (NSString *)timeFromDate:(NSDate *)date;

@end
