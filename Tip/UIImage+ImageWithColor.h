//
//  UIImage+ImageWithColor.h
//  Gym Log
//
//  Created by Wade Spires on 10/20/13.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageWithColor)

// Create a 1x1 image with the given color. The alpha channel of the color is preserved.
+ (UIImage *)imageWithColor:(UIColor *)color;

// Create an image with the given color and size. The alpha channel of the color is preserved.
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

// Create an image with the given color, size, and opacity flag. Set opaque to YES to ignore the color's alpha channel as an optimization.
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size opaque:(BOOL)opaque;

@end
