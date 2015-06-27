//
//  MAAppearance.h
//  Gym Log
//
//  Created by Wade Spires on 9/10/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MAAppearance : NSObject

+ (void)setAppearance;
+ (void)reloadAppearanceSettings;
+ (UIColor *)backgroundColor;
+ (UIColor *)foregroundColor;
+ (UIColor *)selectedColor;
+ (UIColor *)highlightedColor;
+ (UIColor *)disabledColor;
+ (UIColor *)buttonTextColor;

+ (UIColor *)searchBarColor;

+ (UIImage *)tintImage:(UIImage *)image tintColor:(UIColor *)tintColor;
+ (UIImage *)tintImage:(UIImage *)image;
+ (UIImage *)tintedImageNamed:(NSString *)name;
+ (UIColor *)correctColor:(UIColor *)color;

+ (UIImage *)imageWithForegroundGradient:(UIImage *)image;

#ifndef IS_WATCH_EXTENSION
+ (void)setBackgroundColorForCell:(UITableViewCell *)cell;
+ (BOOL)shouldSetFontColorForTableStyle:(UITableViewStyle)tableStyle;
+ (CGFloat)cellFontSize;
+ (void)setFontForCell:(UITableViewCell *)cell tableStyle:(UITableViewStyle)tableStyle;
+ (void)setFontForCell:(UITableViewCell *)cell;
+ (void)setFontForCellLabel:(UILabel *)label tableStyle:(UITableViewStyle)tableStyle;
+ (void)setFontForCellLabel:(UILabel *)label;
+ (void)setAppearanceForCell:(UITableViewCell *)cell tableStyle:(UITableViewStyle)tableStyle;
+ (void)setAppearanceForCell:(UITableViewCell *)cell;
+ (void)setSeparatorStyleForTable:(UITableView *)tableView;
+ (UIColor *)backgroundColorForPicker;
+ (void)setBackgroundColorForDatePicker:(UIDatePicker *)datePicker;
+ (void)setBackgroundColorForPicker:(UIPickerView *)picker;

+ (void)setBackgroundColorForToolbar:(UIToolbar *)toolbar;

+ (void)clearBackgroundForTableView:(UITableView *)tableView;
+ (UILabel *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
   withBackgroundColor:(UIColor *)backgroundColor;
+ (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;

+ (void)setColorForSwitch:(UISwitch *)switchControl;
+ (void)setStyleForUnitLabel:(UILabel *)label;

+ (void)setTextViewAppearance:(UITextView *)view;
+ (void)setTableViewAppearance:(UITableView *)view;
+ (UIColor *)placeholderTextColor;

+ (void)setTableViewHeaderAppearanceForLabel:(UILabel *)label;

+ (void)setTabAndNavBarColor;

+ (NSString *)tableTextFontName;
+ (CGFloat)tableTextFontSize;
+ (UIColor *)tableTextFontColor;
+ (UIFont *)tableTextFont;

+ (void)setSeparatorColor;
+ (UIColor *)separatorColor;
+ (UIColor *)headerLabelTextColor;
+ (UIColor *)detailLabelTextColor;

+ (UIActivityIndicatorViewStyle)tableViewActivityIndicatorStyle;
+ (UIActivityIndicatorViewStyle)activityIndicatorStyle;

// Functions to calculate table view cell height for different text lengths and styles.
+ (CGFloat)heightForRowInTableView:(UITableView *)tableView withAttributedTextInView:(UIView *)view;
+ (CGFloat)heightForTextStyle:(NSString *)textStyle;
+ (CGFloat)heightForTextStyle:(NSString *)textStyle padding:(BOOL)padding;
+ (CGSize)sizeForTextStyle:(NSString *)textStyle;
+ (UILabel *)labelForTextStyle:(NSString *)textStyle;
+ (CGFloat)heightForString:(NSString *)string textStyle:(NSString *)textStyle tableView:(UITableView *)tableView;
+ (CGFloat)heightForString:(NSString *)string textStyle:(NSString *)textStyle frameWidth:(CGFloat)frameWidth defaultHeight:(CGFloat)defaultHeight;
+ (CGFloat)numberOfLinesForString:(NSString *)string textStyle:(NSString *)textStyle frameWidth:(CGFloat)frameWidth defaultHeight:(CGFloat)defaultHeight;
+ (CGFloat)heightForLines:(NSUInteger)numberOfLines textStyle:(NSString *)textStyle defaultHeight:(CGFloat)defaultHeight;
#endif // IS_EXTENSION

@end
