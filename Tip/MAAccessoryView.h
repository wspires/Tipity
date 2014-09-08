//
//  MAAccessoryView.h
//  Gym Log
//
//  Created by Wade Spires on 9/9/13.
//
//

#import <UIKit/UIKit.h>

@interface MAAccessoryView : UIView

@property (strong, nonatomic) UIColor *color;
@property (assign, nonatomic) BOOL move;

+ (CGRect)frameWithWidth:(CGFloat)width height:(CGFloat)height;
+ accessoryViewWithColor:(UIColor *)color cellWidth:(CGFloat)cellWidth cellHeight:(CGFloat)cellHeight;
+ accessoryViewWithColor:(UIColor *)color cell:(UITableViewCell *)cell;
+ grayAccessoryViewForCell:(UITableViewCell *)cell;
+ grayMoveAccessoryViewForCell:(UITableViewCell *)cell;
+ (UIColor *)chevronColor;

@end
