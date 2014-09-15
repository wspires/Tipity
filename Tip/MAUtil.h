//
//  MAUtil.h
//  Gym Log
//
//  Created by Wade Spires on 10/8/12.
//
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

// Note: Always comment this out before a new release to disable logging.
//#define MA_DEBUG_MODE

#ifdef MA_DEBUG_MODE
#define DLog( s, ... ) NSLog( @"<%p %@:(%d, %s) %@> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __FUNCTION__, [NSThread currentThread], [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DLog( s, ... )
#endif

#define TLog( s, ... ) NSLog( @"<%p %@:(%d, %s) %@> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __FUNCTION__, [NSThread currentThread], [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#define SFmt( s, ... ) [NSString stringWithFormat:(s), ##__VA_ARGS__]

//#define Localize( s ) NSLocalizedStringFromTable((s), @"InfoPlist", nil)
#define Localize( s ) NSLocalizedString((s), nil)

#define APP_NAME @"Gratuity"
#define APP_ID @"919137272"

// Create "shortcut" for accessing the app delegate. Users must still include MAAppDelegate.h.
#define AppDelegate ((MAAppDelegate *)[UIApplication sharedApplication].delegate)

#define APP_GROUP @"group.com.mindsaspire.Tip"

#define USE_IOS8

// Courtesy of https://github.com/facebook/three20
#ifndef MO_RGBCOLOR
#define MO_RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#endif
#ifndef MO_RGBCOLOR1
#define MO_RGBCOLOR1(c) [UIColor colorWithRed:c/255.0 green:c/255.0 blue:c/255.0 alpha:1]
#endif
#ifndef MO_RGBACOLOR
#define MO_RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#endif


// Simplify declaring types used for tableview indices.
#define DECL_TABLE_IDX(name, value) static NSUInteger const (name) = (value)

NSUInteger DeviceSystemMajorVersion();
#define BELOW_IOS7 (DeviceSystemMajorVersion() < 7)
#define ABOVE_IOS7 ( ! BELOW_IOS7)

#define BELOW_IOS8 (DeviceSystemMajorVersion() < 8)
#define ABOVE_IOS8 ( ! BELOW_IOS8)

@interface MAUtil : NSObject
+ (BOOL)iPad;
+ (NSString *)version;
+ (NSString *)frameToString:(CGRect)frame;

+ (void)setAdjustableNavTitle:(NSString *)title withNavigationItem:(UINavigationItem *)navItem;
+ (void)updateNavItem:(UINavigationItem *)navItem withTitle:(NSString *)title;
+ (UILabel *)adjustableNavTitle:(NSString *)title forNavigationItem:(UINavigationItem *)navItem;

+ (NSString *)trimWhitespace:(NSString *)string;

+ (double)parseDouble:(NSString *)s;
+ (NSString *)formatDouble:(double)d;
+ (NSString *)formatHeight:(double)d;
+ (NSString *)formatCount:(NSUInteger)count;

//+ (NSString *)distanceUnitForWeightUnit:(NSString *)unit;
+ (NSString *)cardioSeparator;
+ (NSString *)comparisonSeparator;
+ (NSAttributedString *)formatSetNumber:(NSUInteger)setNumber;

+ (NSError *)makeError:(NSString *)msg;
+ (UIAlertView *)showAlertWithError:(NSError *)error;

+ (void)findMisbehavingScrollViewsIn:(UIView *)view;

+ (void)removeSubviews:(UIView *)view;

+ (void)brieflyHighlightCells:(NSArray *)indexPaths
                 forTableView:(UITableView *)tableView;
+ (void)brieflyHighlightCell:(NSIndexPath *)indexPath
                 forTableView:(UITableView *)tableView;

+ (NSInteger)toTag:(NSIndexPath *)indexPath;
+ (UIImageView *)setImage:(UIImage *)image forCell:(UITableViewCell *)cell withTag:(NSInteger)tag;

+ (void)setKeyboardTypeForTextField:(UITextField *)textField;
+ (BOOL)numTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
+ (BOOL)hhmmssTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
+ (NSString *)toHHMMSSFromMinutes:(double)minutes;
+ (double)toMinutesFromHHMMSS:(NSString *)hhmmss;
+ (NSString *)padHHMMSS:(NSString *)hhmmss;

+ (NSArray *)localizeArray:(NSArray *)array reverseMap:(NSMutableDictionary *)reverseMap;
+ (NSArray *)localizeArray:(NSArray *)array;

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

+ (NSData *)dataFromString:(NSString *)string;
+ (NSString *)stringFromData:(NSData *)data;

+ (NSString *)escapeCharsInString:(NSString *)string;

+ (NSArray *)splitString:(NSString *)string delimiter:(unichar)delimiter escape:(unichar)escape;
+ (NSArray *)splitCSVString:(NSString *)string;

+ (UILabel *)navView:(UIView *)navView withBackgroundColor:(UIColor *)backgroundColor;

+ (void)addGradientToView:(UIView *)view;

+ (BOOL)isStringOn:(NSString *)string;

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

+ (NSArray *)sortStringArray:(NSArray *)array ascending:(BOOL)ascending;
+ (NSArray *)sortStringArray:(NSArray *)array;
+ (NSArray *)reverseSortStringArray:(NSArray *)array;

+ (double)calculatePercentageChange:(double)newValue oldValue:(double)oldValue;

// Sets an UIActivityIndicatorView as the accessoryView for the cell at indexPath in table tableView and starts animating the activity indicator. Then [receiver performSelector:aSelector withObject:anArgument afterDelay:delay] is invoked.
// Use this from, say, didSelectRowAtIndexPath if a cell that is tapped requires some potentially long running action, such as displaying a view controller that must process a lot of data before being loaded.
+ (void)showActivityIndicatorInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath receiver:(NSObject *)receiver performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay;

+ (void)fadeOutTableView:(UITableView *)tableView;

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

+ (BOOL)stringArray:(NSArray *)array1 isEqualToStringArray:(NSArray *)array2;

+ (CGFloat)rowHeightForTableView:(UITableView *)tableView;

@end
