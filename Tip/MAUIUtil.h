//
//  MAUIUtil.h
//  Tip
//
//  Created by Wade Spires on 6/26/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MAUIUtil : NSObject

+ (void)setAdjustableNavTitle:(NSString *)title withNavigationItem:(UINavigationItem *)navItem;
+ (void)updateNavItem:(UINavigationItem *)navItem withTitle:(NSString *)title;
+ (UILabel *)adjustableNavTitle:(NSString *)title forNavigationItem:(UINavigationItem *)navItem;

+ (NSError *)makeError:(NSString *)msg;

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
+ (NSNumberFormatter *)hhmmssFormatter;
+ (NSNumberFormatter *)millisecondFormatter;
+ (BOOL)hhmmssTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
+ (BOOL)automaticDecimalTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
+ (NSString *)toHHMMSSFromMinutes:(double)minutes;
+ (double)toMinutesFromHHMMSS:(NSString *)hhmmss;
+ (NSString *)padHHMMSS:(NSString *)hhmmss;

+ (UILabel *)navView:(UIView *)navView withBackgroundColor:(UIColor *)backgroundColor;

+ (void)addGradientToView:(UIView *)view;
// Sets an UIActivityIndicatorView as the accessoryView for the cell at indexPath in table tableView and starts animating the activity indicator. Then [receiver performSelector:aSelector withObject:anArgument afterDelay:delay] is invoked.
// Use this from, say, didSelectRowAtIndexPath if a cell that is tapped requires some potentially long running action, such as displaying a view controller that must process a lot of data before being loaded.
+ (void)showActivityIndicatorInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath receiver:(NSObject *)receiver performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay;

+ (void)fadeOutTableView:(UITableView *)tableView;

+ (CGFloat)rowHeightForTableView:(UITableView *)tableView;

@end
